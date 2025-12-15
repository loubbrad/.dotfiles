MiniDeps.add({ source = 'neovim/nvim-lspconfig' })
MiniDeps.add({ source = 'hrsh7th/nvim-cmp' })
MiniDeps.add({ source = 'hrsh7th/cmp-nvim-lsp' })
MiniDeps.add({ source = 'hrsh7th/cmp-buffer' })
MiniDeps.add({ source = 'ray-x/lsp_signature.nvim' })

require('lsp_signature').setup({
    bind = true, 
    hi_parameter = "Normal",
    hint_enable = false, 
    toggle_key = '<C-l>', 
    toggle_key_flip_floatwin_setting = true,
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', function() require('fzf-lua').lsp_definitions() end, opts)
        vim.keymap.set('n', '<leader>gd', function() _G.smart_split_action(function() require('fzf-lua').lsp_definitions() end) end, opts)
        vim.keymap.set('n', 'gr', function() require('fzf-lua').lsp_references() end, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)  
        vim.keymap.set('n', '<C-h>', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    end,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local servers = { 'basedpyright' }

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

local cmp = require('cmp')

cmp.setup({
  window = {
    documentation = cmp.config.disable,
    completion = {
      max_height = 8,
    },
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',  
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  },
})

