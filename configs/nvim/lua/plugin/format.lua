vim.pack.add({
    'https://github.com/stevearc/conform.nvim',
}, { confirm = false })

require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format" },
        zig = { "zigfmt" },
    },
    format_on_save = {
        timeout_ms = 1000,
        quiet = true,
    },
    formatters = {
        ruff_format = {
            append_args = { "--line-length", "80" },
        },
    },
})
