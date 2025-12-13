MiniDeps.add({ source = 'neovim/nvim-lspconfig' })

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)      
        vim.keymap.set('n', '<leader>gd', function() _G.smart_split_action(vim.lsp.buf.definition) end, opts)

        vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)  
        vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts) 
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)            

        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local servers = { 'basedpyright', 'lua_ls' }

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
          },
        },
      }
    end

    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  end
end

