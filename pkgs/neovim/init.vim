scriptencoding utf-8

"" Basic settings {{{1

" set clipboard+=unnamedplus
set complete+=k
set cursorline
set diffopt+=vertical
set expandtab
set hidden
set ignorecase
set infercase
set list
set listchars=eol:¬,tab:›_,trail:_,extends:»,precedes:«,nbsp:_
set mouse=nv
set nowrap
set path=.,,
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

"" Use ';' as <Leader>, which is now free
let g:mapleader = ';'
let g:maplocalleader = ','

"" Practical Vim, Tip 42: '%%' expands to '%:h'
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h') . '/' : '%%'

"" Practical Vim, Tip 93: Repeat the last substitution by '&'
nnoremap & :&&<CR>
xnoremap & :&&<CR>

augroup remember_last_cursor_position
  autocmd!
  au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exec "normal g`\"" |
        \ endif
augroup END

"" Colorize columns over &textwidth
exec 'set colorcolumn=+' . join(range(1, 256), ',+')

"" Use ripgrep if available
if executable('rg')
  set grepprg=rg\ -S\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

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

"" Skim key mappings
noremap [skim] <Nop>
map <Leader>e [skim]
nmap <silent> [skim]f :<C-u>Files ./<CR>
nmap [skim]F :<C-u>Files 
nmap <silent> [skim]l :<C-u>GFiles<CR>
nmap <silent> [skim]s :<C-u>GFiles?<CR>
nmap <silent> [skim]b :<C-u>Buffers<CR>
nmap <silent> [skim]g :<C-u>Rg<CR>
nmap <silent> [skim]n :<C-u>BLines<CR>
nmap <silent> [skim]N :<C-u>Lines<CR>
nmap <silent> [skim]t :<C-u>BTags<CR>
nmap <silent> [skim]T :<C-u>Tags<CR>
nmap <silent> [skim]m :<C-u>Marks<CR>
nmap <silent> [skim]M :<C-u>Maps<CR>
nmap <silent> [skim]w :<C-u>Windows<CR>
nmap <silent> [skim]h :<C-u>History<CR>
nmap <silent> [skim]/ :<C-u>History/<CR>
" nmap <silent> [skim]c :<C-u>BCommits<CR>  " fugative.vim is required
" nmap <silent> [skim]C :<C-u>Commits<CR>  " fugative.vim is required
nmap <silent> [skim]e :<C-u>Commands<CR>
nmap <silent> [skim]E :<C-u>History:<CR>

"" Modern Vim, Tip 12: ALE mappings in the style of unimpaired
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

"" clever-f.vim
let g:clever_f_smart_case = 1
let g:clever_f_use_migemo = 1
let g:clever_f_repeat_last_char_inputs = ["\<CR>"]

"" unimpaired.vim
map <Leader>o yo

"" Yoink.vim
let g:yoinkSyncNumberedRegisters = 1
let g:yoinkSavePersistently = 1
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
augroup iron
  autocmd!
  au VimEnter * call s:IronInit()
augroup END
fun! s:IronInit() abort
  lua << EOF
local iron = require'iron'
iron.core.set_config {
  repl_open_cmd = 'top 10 split',
  preferred = {
    fennel = 'fennel',
    r7rs = 'gauche',
    scheme = 'gauche',
    rmarkdown = 'R',
  }
}
local fennel_repls = {
  fennel = {
    command = {'fennel'}
  }
}
local scheme_repls = {
  gauche = {
    command = {'gosh'}
  }
}
iron.core.add_repl_definitions {
  r7rs = scheme_repls,
  scheme = scheme_repls,
  rmarkdown = iron.fts['r'],
}
EOF
endfun

"" Tagbar settings
let g:tagbar_singleclick = 1
" let g:tagbar_autoclose = 1
let g:tagbar_iconchars = ['▸', '▾']
nmap <silent> <Leader>l :TagbarToggle<CR>

"" bullets.vim
let g:bullets_enabled_file_types = [ 'markdown', 'pandoc', 'text', 'gitcommit']
let g:bullets_checkbox_markers = ' x'

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
      \   'ale_checking': 'lightline#ale#checking',
      \   'ale_infos': 'lightline#ale#infos',
      \   'ale_warnings': 'lightline#ale#warnings',
      \   'ale_errors': 'lightline#ale#errors',
      \   'ale_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \   'ale_checking': 'right',
      \   'ale_infos': 'right',
      \   'ale_warnings': 'warning',
      \   'ale_errors': 'error',
      \   'ale_ok': 'right',
      \ }
let  g:lightline.active = {
      \  'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'readonly', 'filename', 'modified' ],
      \     [ 'ale_checking', 'ale_errors', 'ale_warnings', 'ale_infos', 'ale_ok' ],
      \   ],
      \ }
let g:lightline#ale#indicator_ok = ''

"" Japanese settings {{{1

set ambiwidth=double  " □や○の文字があってもカーソル位置がずれないようにする。
set fileencodings=ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932
set formatoptions+=mB  " 日本語の行同士の連結には空白を入力しない
set matchpairs+=（:）,「:」,『:』,【:】,［:］,〈:〉,《:》,‘:’,“:”
set spelllang+=cjk  " 日本語をスペルチェックから除外する

"" 日本語入力がオンのままでも使えるコマンド(Enterキーは必要)
"" http://qiita.com/ssh0/items/9e7f0d8b8f033183dd0b
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap っd dd
nnoremap っy yy

set formatexpr=jpfmt#formatexpr()

"" Tree-sitter {{{1

lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  ignore_install = {
  },
  highlight = {
    enable = true,
    disable = {
    }
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true
  }
}
EOF

"" File type extensions {{{1

"" VimL {{{2
augroup ft_vim
  autocmd!
  au FileType vim setl shiftwidth=2
augroup END

"" Fish {{{2
augroup ft_fish
  autocmd!
  au FileType fish
        \ compiler fish |
        \ setl shiftwidth=2
augroup END

"" Make {{{2
augroup ft_make
  autocmd!
  au FileType make setl tabstop=4
augroup END

"" Markdown {{{2
let g:pandoc#formatting#mode = 'hA'
let g:pandoc#formatting#textwidth = 78
let g:pandoc#command#latex_engine = 'lualatex'
let g:pandoc#folding#mode = 'stacked'
let g:pandoc#hypertext#create_if_no_alternates_exists = 1
let g:pandoc#hypertext#split_open_cmd = 'botright split'
let g:pandoc#syntax#conceal#use = 0
augroup ft_pandoc
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
