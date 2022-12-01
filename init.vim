colorscheme habamax

let loaded_netrwPlugin = 1

set path=src/**

let $PATH = $PATH . ':' .  expand('~/.config/yarn/global/node_modules/.bin')

lua << EOF
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.ts,*.tsx",
  callback = function()
    vim.lsp.start({
      name = 'tsserver',
      cmd = {'typescript-language-server', '--stdio'},
      root_dir = vim.fs.dirname(vim.fs.find({'tsconfig.json'}, { upward = true })[1]),
      diagnostics_format = "#{m} (#{s}: #{c})",
    })
  end
})
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.go",
  callback = function()
    vim.lsp.start({
      name = 'gopls',
      cmd = {'gopls'},
      root_dir = vim.fs.dirname(vim.fs.find({'go.mod'}, { upward = true })[1]),
    })
  end
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.vim",
  callback = function()
    vim.lsp.start({
      name = 'vim-language-server',
      cmd = {'vim-language-server', '--stdio'},
      root_dir = vim.fs.dirname(vim.fs.find({'.git'}, { upward = true })[1]),
    })
  end
})
EOF
