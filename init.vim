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

let &path = ',,' . 'src/**,' . expand('~/.config/nvim')

augroup my-lsp-diagnostic
  au!
  au DiagnosticChanged *.go lua vim.diagnostic.setloclist({open = false})
augroup end

nnoremap ga <Cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>rn :<C-u>lua vim.lsp.buf.rename('')<Left><Left>
nnoremap <leader>f <Cmd>lua vim.lsp.buf.format()<CR>
nnoremap <leader>q <Cmd>lua vim.diagnostic.setqflist()<CR>

set completeopt=menuone,noselect,noinsert
function! s:lsp_completion() abort
  if pumvisible()
    return
  endif

  if (
    \ (v:char >= 'a' && v:char <= 'z') ||
    \ (v:char >= 'A' && v:char <= 'Z') ||
    \ (v:char == '.')
    \ )
    call feedkeys("\<C-x>\<C-o>")
  endif
endfunction

autocmd InsertCharPre *.go call s:lsp_completion()

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
