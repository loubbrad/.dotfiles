MiniDeps.add({ source = 'stevearc/conform.nvim' })
require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format" },
    },
    format_on_save = {
        timeout_ms = 1000,
    },
    formatters = {
        ruff_format = {
            append_args = { "--line-length", "80" },
        },
    },
})
