#!/usr/bin/env python3
import argparse
import os
import shutil
import sys
import tempfile
from datetime import datetime
from pathlib import Path


BACKUP_DIR_NAME = "backups"
PROTECTED_NAMES = {"authorized_keys", "authorized_keys2"}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Merge staged SSH files into ~/.ssh without touching authorized keys."
    )
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--ssh-dir", type=Path, default=Path.home() / ".ssh")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def ssh_relative_path(path, root):
    rel = path.relative_to(root)
    if ".ssh" in rel.parts:
        parts = rel.parts[rel.parts.index(".ssh") + 1 :]
        if not parts:
            return None
        return Path(*parts)
    return rel


def secure_directory(path, root):
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    while True:
        path.chmod(0o700)
        if path == root:
            return
        path = path.parent


def build_plan(files, staging_dir, ssh_dir):
    plan = []
    destinations = set()

    for src in sorted(files):
        rel = ssh_relative_path(src, staging_dir)
        if rel is None:
            continue
        if rel.name in PROTECTED_NAMES:
            print(f"skipping protected file: {ssh_dir / rel}")
            continue
        if rel.parts[0] == BACKUP_DIR_NAME:
            raise RuntimeError(f"archive targets reserved directory: {rel}")

        dst = ssh_dir / rel
        resolved = dst.resolve()
        if not resolved.is_relative_to(ssh_dir):
            raise RuntimeError(f"unsafe destination: {dst}")
        if dst.is_symlink():
            raise RuntimeError(f"refusing to replace symlink: {dst}")
        if dst.exists() and not dst.is_file():
            raise RuntimeError(f"destination is not a regular file: {dst}")
        if resolved in destinations:
            raise RuntimeError(f"duplicate destination in archive: {dst}")

        destinations.add(resolved)
        plan.append((src, dst, rel))

    return plan


def backup_replacements(plan, ssh_dir):
    replacements = [(dst, rel) for _, dst, rel in plan if dst.exists()]
    if not replacements:
        return

    backup_root = ssh_dir / BACKUP_DIR_NAME
    if backup_root.is_symlink() or (backup_root.exists() and not backup_root.is_dir()):
        raise RuntimeError(f"unsafe backup directory: {backup_root}")

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    backup_dir = backup_root / timestamp
    secure_directory(backup_dir, ssh_dir)

    for src, rel in replacements:
        dst = backup_dir / rel
        secure_directory(dst.parent, ssh_dir)
        shutil.copy2(src, dst)
        print(f"backed up {src} -> {dst}")


def install_file(src, dst, ssh_dir):
    secure_directory(dst.parent, ssh_dir)
    mode = 0o644 if dst.name.endswith(".pub") else 0o600

    with tempfile.NamedTemporaryFile(dir=dst.parent, delete=False) as output:
        tmp = Path(output.name)
        with src.open("rb") as input_file:
            shutil.copyfileobj(input_file, output)

    try:
        tmp.chmod(mode)
        os.replace(tmp, dst)
    finally:
        tmp.unlink(missing_ok=True)
    print(f"installed {dst}")


def main():
    args = parse_args()
    source_dir = args.source_dir.expanduser().resolve()
    ssh_dir = args.ssh_dir.expanduser().resolve()

    if not source_dir.is_dir():
        print(f"missing source directory: {source_dir}", file=sys.stderr)
        return 1

    entries = list(source_dir.rglob("*"))
    unsafe = [
        path
        for path in entries
        if path.is_symlink() or not (path.is_file() or path.is_dir())
    ]
    if unsafe:
        raise RuntimeError(f"source contains an unsafe entry: {unsafe[0]}")

    files = [path for path in entries if path.is_file()]
    if not files:
        print("source did not contain any regular files", file=sys.stderr)
        return 1

    plan = build_plan(files, source_dir, ssh_dir)
    if not plan:
        print("source did not contain any installable files", file=sys.stderr)
        return 1

    if args.dry_run:
        for _, dst, _ in plan:
            action = "replace" if dst.exists() else "install"
            print(f"would {action} {dst}")
        return 0

    secure_directory(ssh_dir, ssh_dir)
    backup_replacements(plan, ssh_dir)
    for src, dst, _ in plan:
        install_file(src, dst, ssh_dir)

    return 0


if __name__ == "__main__":
    try:
        status = main()
    except (OSError, RuntimeError) as error:
        print(f"error: {error}", file=sys.stderr)
        status = 1
    raise SystemExit(status)
