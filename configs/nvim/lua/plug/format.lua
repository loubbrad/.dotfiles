MiniDeps.add({ source = 'stevearc/conform.nvim' })

require("conform").setup({
    formatters_by_ft = {
        python = { "black" },
    },
    format_on_save = {
        timeout_ms = 1000,        
        -- lsp_format = "fallback", 
    },
    formatters = {
        black = {
            prepend_args = { "--line-length", "80" },
        },
    },
})
