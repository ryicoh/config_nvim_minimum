colorscheme habamax
if has('termguicolors')
  set termguicolors
endif

set tabstop=2
set shiftwidth=2
set expandtab
set number
set signcolumn=yes
lang en_US.UTF-8

set path=.,~/.config/nvim,/src/**

let $PATH = $PATH . ':' .  expand('~/.config/yarn/global/node_modules/.bin')

augroup my-lsp-diagnostic
  au!
  au DiagnosticChanged *.go,*.ts,*.tsx lua vim.diagnostic.setqflist({open = false})
augroup end

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
