"" Color scheme and status line {{{1

if $COLORTERM ==# 'truecolor'  " VTE, Konsole, and iTerm2
  set termguicolors
endif
set background=dark

try
  colorscheme srcery
catch /\v^Vim%(\(\a+\))=:E185/
  " Suppress error messages
endtry

augroup color_tweaks
  autocmd!
  " Srcery orange
  au VimEnter,ColorScheme *
        \ hi Search    ctermbg=166 guibg=#d75f00 |
        \ hi IncSearch ctermbg=166 guibg=#d75f00 |
        \ hi PmenuSel  ctermbg=166 guibg=#d75f00

  " Srcery brred
  au VimEnter,ColorScheme *
        \ hi SpellBad ctermfg=9 guifg=#f75341 gui=undercurl
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
