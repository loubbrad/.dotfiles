#!/usr/bin/env python3
import argparse
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path


SKIP_NAMES = {"authorized_keys"}


def parse_args():
    default_archive = Path(__file__).with_name("ssh_archive.tar.gz.gpg")
    parser = argparse.ArgumentParser(
        description="Extract encrypted SSH files into ~/.ssh without touching authorized_keys."
    )
    parser.add_argument("--archive", type=Path, default=default_archive)
    parser.add_argument("--ssh-dir", type=Path, default=Path.home() / ".ssh")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def safe_member(member):
    path = Path(member.name)
    return not path.is_absolute() and ".." not in path.parts


def extract_archive(archive, target):
    proc = subprocess.Popen(["gpg", "--decrypt", str(archive)], stdout=subprocess.PIPE)
    try:
        with tarfile.open(fileobj=proc.stdout, mode="r|gz") as tar:
            for member in tar:
                if not safe_member(member):
                    raise RuntimeError(f"unsafe archive path: {member.name}")
                if member.issym() or member.islnk():
                    print(f"skipping link: {member.name}", file=sys.stderr)
                    continue
                tar.extract(member, target)
    except Exception:
        proc.kill()
        proc.wait()
        raise

    if proc.wait() != 0:
        raise RuntimeError("gpg failed to decrypt the archive")


def ssh_relative_path(path, root):
    rel = path.relative_to(root)
    if ".ssh" in rel.parts:
        parts = rel.parts[rel.parts.index(".ssh") + 1 :]
        if not parts:
            return None
        return Path(*parts)
    return rel


def install_file(src, dst, dry_run):
    if dry_run:
        print(f"would install {dst}")
        return

    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)
    dst.chmod(0o644 if dst.name.endswith(".pub") else 0o600)
    print(f"installed {dst}")


def main():
    args = parse_args()
    archive = args.archive.expanduser()
    ssh_dir = args.ssh_dir.expanduser()

    if not archive.is_file():
        print(f"missing archive: {archive}", file=sys.stderr)
        return 1

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        extract_archive(archive, tmp_path)

        files = [path for path in tmp_path.rglob("*") if path.is_file()]
        if not files:
            print("archive did not contain any regular files", file=sys.stderr)
            return 1

        if not args.dry_run:
            ssh_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
            ssh_dir.chmod(0o700)

        for src in files:
            rel = ssh_relative_path(src, tmp_path)
            if rel is None:
                continue
            if rel.name in SKIP_NAMES:
                print(f"skipping {ssh_dir / rel}")
                continue

            dst = ssh_dir / rel
            if not dst.resolve().is_relative_to(ssh_dir.resolve()):
                print(f"skipping unsafe destination: {dst}", file=sys.stderr)
                continue
            install_file(src, dst, args.dry_run)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
