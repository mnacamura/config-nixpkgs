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

"" vim-easy-align
nnoremap gA ga
nmap ga <Plug>(EasyAlign)
vmap ga <Plug>(EasyAlign)

"" iron.nvim
let g:iron_map_defaults = 0
let g:iron_map_extended = 0
map <Leader>r [iron]
noremap [iron] <Nop>
nmap <silent> [iron]r :IronRepl<CR><Esc>
nmap [iron]t :IronReplHere 
nmap <silent> [iron]R :IronRestart<CR>
nmap [iron]s :IronSend! 
nmap [iron]S :IronSend 
nmap <silent> [iron]f :IronFocus<CR>
nmap [iron]w :IronWatchCurrentFile 
nmap [iron]u :IronUnwatchCurrentFile<CR>
nmap <silent> gr <Plug>(iron-send-motion)
vmap <silent> gr <Plug>(iron-visual-send)
nmap <silent> [iron]. <Plug>(iron-repeat-cmd)
nmap <silent> [iron]l <Plug>(iron-send-line)
nmap <silent> [iron]<CR> <Plug>(iron-cr)
nmap <silent> [iron]<C-c> <Plug>(iron-interrupt)
nmap <silent> [iron]q <Plug>(iron-exit)
nmap <silent> [iron]<C-l> <Plug>(iron-clear)

" TODO: Not sure but required to init iron later
augroup iron_init
  autocmd!
  au VimEnter * call s:init_iron()
augroup END
fun! s:init_iron() abort
  lua << EOF
local iron = require('iron')
iron.core.set_config {
  repl_open_cmd = 'top 10 split',
  preferred = {
    fennel = 'fennel',
    r7rs = 'gauche',
    scheme = 'gauche'
  }
}
iron.core.add_repl_definitions {
  fennel = { fennel = { command = {'fennel'} } },
  scheme = { gauche = { command = {'gosh'} } },
  r7rs = { gauche = { command = {'gosh'} } }
}
EOF
endfun

" See https://vim.fandom.com/wiki/Insert_current_date_or_time
fun! UpdateTimestamp(format)
  if !&modified | return | endif
  let l:pos = getpos('.')
  let l:n = min([10, line('$')])
  let l:date = strftime(a:format)
  if match(getline(1, l:n), l:date) > -1 | return | endif
  let l:cmd = '1,' . l:n . 's#\v\c(Last %(Change|Modified): ).*#\1' . l:date . '#e'
  keepj exec l:cmd
  call histdel('search', -1)
  call setpos('.', l:pos)
endfun
augroup update_timestamp
  autocmd!
  au BufWritePre * call UpdateTimestamp('%Y-%m-%d')
augroup END

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

"" File type extensions {{{1

"" Markdown
let g:pandoc#formatting#mode = 'hA'
let g:pandoc#formatting#textwidth = 78
let g:pandoc#command#latex_engine = 'lualatex'
let g:pandoc#folding#mode = 'stacked'
let g:pandoc#hypertext#create_if_no_alternates_exists = 1
let g:pandoc#hypertext#split_open_cmd = 'botright split'
let g:pandoc#syntax#conceal#use = 0
augroup pandoc
  au!
  au FileType pandoc nmap <buffer> <silent> <LocalLeader><Tab> :TOC<CR>
augroup END

"" Impure settings {{{1

let s:init_vim = $HOME . '/.config/nvim/init.vim'
if filereadable(s:init_vim)
  exec 'source ' . s:init_vim
else
  echomsg 'Warning: ' . s:init_vim . ' is not readable'
endif

" vim: fdm=marker sw=2 et
