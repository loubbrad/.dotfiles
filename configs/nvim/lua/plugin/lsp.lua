vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/rafamadriz/friendly-snippets',
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1' },
}, { confirm = false })

require('blink.cmp').setup({
    keymap = {
        preset = 'default',
        ['<CR>']  = { 'accept', 'fallback' },
        ['<Tab>'] = { 'accept', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-l>'] = { 'show_documentation', 'hide_documentation', 'show_signature', 'hide_signature', 'fallback' },
    },
    -- Workaround to download rust binary
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = { force_version = "v1.8.0" },
    },
    signature = {
        enabled = true,
        window = { border = "single", show_documentation = true },
    },
    completion = {
        accept = { auto_brackets = { enabled = true } },
        keyword = { range = 'full' },
        documentation = { auto_show = false, window = { border = "single" } },
        menu = { draw = { columns = { { 'kind_icon', 'label', gap = 1 } } } },
    },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
})

local function toggle_lsp_float(open)
    require('commands').toggle_float(
        function() return vim.b.lsp_floating_preview end,
        open
    )
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', function() require('fzf-lua').lsp_definitions() end, opts)
        vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<C-l>', function()
            toggle_lsp_float(function() vim.lsp.buf.hover({ border = "single" }) end)
        end, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<C-e>', function()
            toggle_lsp_float(function() vim.diagnostic.open_float({ border = "single" }) end)
        end, opts)
    end,
})

local capabilities = require('blink.cmp').get_lsp_capabilities()

local function disable_semantic_tokens(client)
    client.server_capabilities.semanticTokensProvider = nil
end

local servers = {
    ty = {
        cmd = { 'ty', 'server' },
        filetypes = { 'python' },
        settings = {
            ty = {
                completions = { autoImport = false },
            }
        }
    },
    bashls = {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'sh', 'bash', 'zsh' },
    },
    zls = {
        cmd = { 'zls' },
        filetypes = { 'zig' },
        root_markers = { 'build.zig' },
        on_attach = disable_semantic_tokens,
    },
}

for server, config in pairs(servers) do
    config.capabilities = capabilities
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
end
