"" Basic settings {{{1

set clipboard+=unnamedplus
set complete+=k
set cursorline
set diffopt+=vertical
set hidden
set ignorecase
set infercase
set list
set listchars=eol:¬,tab:›_,trail:_,extends:»,precedes:«,nbsp:_
set mouse=nv
set nowrap
set number
set path=.,,
set relativenumber
set scrolloff=5
set shiftwidth=4
set showbreak=»
set showmatch
set smartcase
set smartindent
set softtabstop=-1
set textwidth=100
set undofile
set virtualedit=block
set visualbell
set wildignorecase
set wildmode=list:longest

"" Hack for vim + fish problem:
let $SHELL = '@shell@'
let &shell = $SHELL

"" UI enhancements {{{1

"" clever-f.vim
let g:clever_f_smart_case = 1
let g:clever_f_use_migemo = 1
let g:clever_f_repeat_last_char_inputs = ["\<CR>"]

"" Use ';' as <Leader>, which is now free
let g:mapleader = ';'
let g:maplocalleader = ','

"" unimpaired.vim
map <Leader>o yo

"" Yoink.vim
nmap y <Plug>(YoinkYankPreserveCursorPosition)
xmap y <Plug>(YoinkYankPreserveCursorPosition)
nmap p <Plug>(YoinkPaste_p)
nmap P <Plug>(YoinkPaste_P)
nmap [y <Plug>(YoinkRotateBack)
nmap ]y <Plug>(YoinkRotateForward)
nmap <C-n> <Plug>(YoinkPostPasteSwapBack)
nmap <C-p> <Plug>(YoinkPostPasteSwapForward)
nmap <c-=> <plug>(YoinkPostPasteToggleFormat)
map <Leader>y :Yanks<CR>

"" vim-wordmotion
let g:wordmotion_spaces = '_-.'

"" Color scheme and status line {{{1

if $COLORTERM ==# 'truecolor'  " VTE, Konsole, and iTerm2
  set termguicolors
endif
set background=dark

let g:srcery_transparent_background = 1
let g:srcery_dim_lisp_paren = 1
colorscheme srcery

augroup color_tweaks
  autocmd!
  au VimEnter,ColorScheme *
        \ @hi_pmenusel@ |
        \ @hi_spellcap@ |
        \ @hi_spellbad@ |
        \ @hi_spelllocal@ |
        \ @hi_spellrare@
augroup END

if !exists('g:lightline') | let g:lightline = {} | endif
let g:lightline.colorscheme = 'srcery'
let g:lightline.component_expand = {
      \   'ale_warnings': 'lightline#ale#warnings',
      \   'ale_errors': 'lightline#ale#errors',
      \   'ale_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \   'ale_warnings': 'warning',
      \   'ale_errors': 'error',
      \ }
let g:lightline.active = {
      \  'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'readonly', 'filename', 'modified' ],
      \     [ 'ale_errors', 'ale_warnings', 'ale_ok' ],
      \   ]
      \ }
let g:lightline#ale#indicator_ok = ''

"" Impure settings {{{1

let s:init_vim = $HOME . '/.config/nvim/init.vim'
if filereadable(s:init_vim)
  exec 'source ' . s:init_vim
else
  echomsg 'Warning: ' . s:init_vim . ' is not readable'
endif

" vim: fdm=marker sw=2 et
