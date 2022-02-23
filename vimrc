set nocompatible

command M :w | :make
nnoremap t lbve~l
nmap X bde
nmap J 5jzz
vnoremap J 5jzz
nmap K 5kzz
vnoremap K 5kzz
nmap F <C-F>zz
nmap Q <C-B>zz
nmap  o<Esc>
map G G$
map £ ^

" store history of past sessions
set undofile 

syntax enable
syntax on
highlight trailingWhitespace ctermbg=darkgreen guibg=lightgreen
match trailingWhitespace /\s\+$/

set showmode
set shiftwidth=4
set tabstop=4
set softtabstop=4
set autoindent
set smartindent
set cindent
set noswapfile
set mouse=a
set expandtab
set fileformat=unix

autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
autocmd FileType c set tabstop=2 shiftwidth=2

" typing keys in visual mode overwrites the buffer
vnoremap a sa
vnoremap c sc
vnoremap e se
vnoremap f sf
vnoremap g sg
vnoremap m sm
vnoremap n sn
vnoremap o so
vnoremap p sp
vnoremap q sq
vnoremap r sr
vnoremap s ss
vnoremap t st
vnoremap v sv
vnoremap y sy
vnoremap z sz
vnoremap 0 s0
vnoremap 1 s1
vnoremap 2 s2
vnoremap 3 s3
vnoremap 4 s4
vnoremap 5 s5
vnoremap 6 s6
vnoremap 7 s7
vnoremap 8 s8
vnoremap 9 s9
vnoremap x xi

" better indentation
vnoremap < <gv
vnoremap > >gv

" backspace
set backspace=2

augroup vimrcEx
au!

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
\ if line("'\"") >= 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif


augroup END
