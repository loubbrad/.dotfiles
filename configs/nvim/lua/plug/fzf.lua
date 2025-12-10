MiniDeps.add('ibhagwan/fzf-lua')
local fzf = require('fzf-lua')
fzf.setup({})

vim.keymap.set('n', '<leader>f', fzf.files, { desc = 'Fzf Files' })
vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Fzf Grep' })
vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Fzf Buffers' })
