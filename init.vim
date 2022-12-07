colorscheme habamax
if has('termguicolors')
  set termguicolors
endif

set tabstop=2
set shiftwidth=2
set expandtab
set number
set signcolumn=yes
set updatetime=50
lang en_US.UTF-8

let &path = ',,' . expand('~/.config/nvim') . ','
if filereadable('go.mod')
  let &path = &path . '**,'
elseif filereadable('package.json')
  let &path = &path . 'src/**,'
endif

augroup my-lsp-diagnostic
  au!
  au DiagnosticChanged *.go,*.ts,*.tsx lua vim.diagnostic.setloclist({open = false})
augroup end

nnoremap ga <Cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap gr <Cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>rn :<C-u>lua vim.lsp.buf.rename('')<Left><Left>
nnoremap <leader>f <Cmd>lua vim.lsp.buf.format()<CR>
nnoremap <leader>q <Cmd>lua vim.diagnostic.setqflist()<CR>
nnoremap [g <Cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]g <Cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap [d <Cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d <Cmd>lua vim.diagnostic.goto_next()<CR>

set completeopt=menuone,noselect,noinsert
function! s:lsp_completion() abort
  if pumvisible() || &omnifunc == '' || reg_recording() || mode() != 'i'
    return
  endif

  if (v:char >= 'a' && v:char <= 'z') ||
   \ (v:char >= 'A' && v:char <= 'Z') ||
   \ (v:char == '.') || v:char <= ''
    call feedkeys("\<C-x>\<C-o>", "n")
  endif
endfunction

autocmd CursorHoldI *.go,*.ts,*.tsx call s:lsp_completion()

let $PATH = $PATH . ':' .  expand('~/.config/yarn/global/node_modules/.bin')
lua << EOF
vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
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

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  pattern = "*.go",
  callback = function()
    vim.lsp.start({
      name = 'gopls',
      cmd = {'gopls'},
      root_dir = vim.fs.dirname(vim.fs.find({'go.mod'}, { upward = true })[1]),
    })
  end
})

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
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

" DeepL
set runtimepath^=~/workspace/deepl.vim
let g:deepl#endpoint = "https://api-free.deepl.com/v2/translate"
let g:deepl#auth_key = readfile(expand("~/.config/nvim/deepl_auth_key.txt"))[0]

" repeat
set runtimepath^=~/.vim/plugged/repeat

" replace a visual selection
vmap t<C-e> <Cmd>call deepl#v("EN")<CR>
vmap t<C-j> <Cmd>call deepl#v("JA")<CR>

" translate a current line and display on a new line
nmap t<C-e> yypV<Cmd>call deepl#v("EN")<CR>
nmap t<C-j> yypV<Cmd>call deepl#v("JA")<CR>
