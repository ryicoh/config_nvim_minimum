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

packadd vim-jetpack
call jetpack#begin()
  Jetpack 'tani/vim-jetpack', {'opt': 1, 'commit': '2530895'}
  Jetpack 'ggandor/lightspeed.nvim', {'commit': '299eefa'}

  Jetpack 'tpope/vim-surround', {'commit': '3d188ed'}
  Jetpack 'tpope/vim-repeat', {'commit': '24afe92'}
  Jetpack 'tpope/vim-fugitive', {'commit': '99cdb88'}
  Jetpack 'tpope/vim-commentary', {'commit': 'e87cd90'}
  Jetpack 'tpope/vim-rhubarb', {'commit': 'cad60fe'}

  " Jetpack 'kamykn/spelunker.vim', {'commit': 'a0bc530'}
  Jetpack 'ryicoh/vim-cspell', {'tag': 'v0.3'}
  Jetpack 'ryicoh/deepl.vim'

  " Jetpack 'tversteeg/registers.nvim', {'commit': '667ae44'}

  Jetpack 'neovim/nvim-lspconfig', {'commit': '649137c'}
  " Jetpack 'stevearc/dressing.nvim', {'commit': '4436d6f'}

  Jetpack 'junegunn/fzf', { 'do': { -> fzf#install() }, 'commit': 'fd7fab7' }
  Jetpack 'junegunn/fzf.vim', { 'commit': 'fd7fab7' }

  Jetpack 'hrsh7th/nvim-cmp', {'commit': 'c49ad26'}
  Jetpack 'hrsh7th/cmp-nvim-lsp', {'commit': '5922477'}
  Jetpack 'hrsh7th/vim-vsnip', { 'commit': 'e44026b' }
  Jetpack 'hrsh7th/vim-vsnip-integ', { 'commit': '1cf8990' }
  Jetpack 'hrsh7th/cmp-vsnip', {'commit': '989a8a7'}
  Jetpack 'rafamadriz/friendly-snippets', {'commit': '484fb38'}

  Jetpack 'nvim-treesitter/nvim-treesitter', { 'commit': 'ee3e9f4', 'do': ':TSUpdate' }

call jetpack#end()

let &path = ',,' . expand('~/.config/nvim') . ','
if filereadable('go.mod')
  let &path = &path . '**,'
elseif filereadable('package.json')
  let &path = &path . 'src/**,'
endif

augroup lsp_diagnostic
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
" function! s:lsp_completion() abort
"   if pumvisible() || &omnifunc == '' || reg_recording() || mode() != 'i'
"     return
"   endif
" 
"   if (v:char >= 'a' && v:char <= 'z') ||
"    \ (v:char >= 'A' && v:char <= 'Z') ||
"    \ (v:char == '.')
"     call feedkeys("\<C-x>\<C-o>", "n")
"   endif
" endfunction
" 
" autocmd InsertCharPre *.go,*.ts,*.tsx,*.vim call s:lsp_completion()

let $PATH = $PATH . ':' .  expand('~/.config/yarn/global/node_modules/.bin')
lua << EOF
local cmp = require'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-5),
    ['<C-f>'] = cmp.mapping.scroll_docs(5),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'vsnip' },
    { name = 'nvim_lsp' },
  })
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- require("registers").setup{capabilities = capabilities,}
-- require("lspconfig").tsserver.setup{capabilities = capabilities,}
require("lspconfig").gopls.setup{capabilities = capabilities,}
require("lspconfig").vimls.setup{capabilities = capabilities,}
require("lspconfig").vtsls.setup{capabilities = capabilities,}
require'nvim-treesitter.configs'.setup{
  highlight = {
    enable = true,
    disable = function(lang, buf)
      return lang ~= "graphql"
    end,
  }
}
EOF

" DeepL
" set runtimepath^=~/workspace/deepl.vim
let g:deepl#endpoint = "https://api-free.deepl.com/v2/translate"
let g:deepl#auth_key = readfile(expand("~/.config/nvim/deepl_auth_key.txt"))[0]

" replace a visual selection
vmap t<C-e> <Cmd>call deepl#v("EN")<CR>
vmap t<C-j> <Cmd>call deepl#v("JA")<CR>

" translate a current line and display on a new line
nmap t<C-e> yypV<Cmd>call deepl#v("EN")<CR>
nmap t<C-j> yypV<Cmd>call deepl#v("JA")<CR>

" spell checker
let g:spelunker_disable_auto_group = 1
augroup MyCSpell
  au!
  au User ChangeCSpellUnknownWord call spelunker#words#highlight(map(cspell#get_unknown_words(), { _, k -> k.unknown_word }))
augroup end

" cursor
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

" fzf
let $FZF_DEFAULT_COMMAND = "fd --type f"
let $FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --bind ctrl-b:page-up,ctrl-f:page-down,ctrl-u:up+up+up,ctrl-d:down+down+down"
autocmd! FileType fzf tnoremap <expr> <C-r> getreg(nr2char(getchar()))
let g:previewShell = "bat --style=numbers --color=always --line-range :500"
let g:fzf_custom_options = ['--preview', previewShell.' {}']
let g:fzf_history_dir = '~/.local/share/fzf-history'
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

command! W <Nop>
nnoremap <silent> <space>f :<C-u>Files<CR>
nnoremap <silent> <space>h :<C-u>History<CR>
nnoremap <silent> <space>r :<C-u>Rg<CR>

" Expand or jump
imap <expr> <C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-f>'
smap <expr> <C-f> vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<C-f>'
imap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-b>'
smap <expr> <C-b> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<C-b>'

let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
