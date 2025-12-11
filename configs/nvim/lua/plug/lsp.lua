MiniDeps.add({ source = 'neovim/nvim-lspconfig' })

require('mini.format').setup({
    formatters = {
        python = { command = 'black', args = { '-l 80', '-' }, stdin = true },
    },
    fallback_to_lsp = false, 
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)      
        vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)  
        vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts) 
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)            
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

local lspconfig = require('lspconfig')
local capabilities = vim.lsp.protocol.make_client_capabilities()
local servers = { 'pyright' }

for _, server in ipairs(servers) do
    if vim.fn.executable(server) == 1 or vim.fn.executable(server .. ".cmd") == 1 then
        lspconfig[server].setup({
            capabilities = capabilities,
        })
    end
end
