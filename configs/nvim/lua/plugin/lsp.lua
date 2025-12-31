MiniDeps.add({ source = 'neovim/nvim-lspconfig' })
MiniDeps.add({
  source = 'saghen/blink.cmp',
  depends = { 'rafamadriz/friendly-snippets' },
})

require('blink.cmp').setup({
    keymap = {
        preset = 'default',
        ['<CR>']  = { 'accept', 'fallback' },
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-l>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    -- Workaround to download rust binary
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = { force_version = "v1.8.0" },
    },
    signature = { enabled = true },
    completion = {
        accept = { auto_brackets = { enabled = true } },
        keyword = { range = 'full' },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', function() require('fzf-lua').lsp_definitions() end, opts)
        vim.keymap.set('n', '<leader>gd', function() _G.smart_split_action(function() require('fzf-lua').lsp_definitions() end) end, opts)
        vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, opts)
        vim.keymap.set('n', '<leader>gr', function() _G.smart_split_action(function() require('fzf-lua').lsp_references() end) end, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<C-h>', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

local capabilities = require('blink.cmp').get_lsp_capabilities()
local servers = { 'ty', 'basedpyright' }

for _, server in ipairs(servers) do
    if vim.fn.executable(server) == 1 then
        local config = {
            capabilities = capabilities,
        }

        if server == 'basedpyright' then
            config.settings = {
                basedpyright = {
                    analysis = {
                        typeCheckingMode = "off",
                        diagnosticMode = "openFilesOnly",
                    },
                },
            }

        elseif server == 'ty' then
            config.settings = {
                ty = {
                    -- diagnosticMode = "off"
                }
            }
end

    vim.lsp.config(server, config)
    vim.lsp.enable(server)
    end
end
