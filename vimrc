command M :w | :make
nnoremap t lbve~l
nmap X bde
map J 5jzz
map K 5kzz
nmap F <C-F>zz
nmap Q <C-B>zz
nmap  o<Esc>
map G G$

syntax enable
syntax on
highlight trailingWhitespace ctermbg=darkgreen guibg=lightgreen
match trailingWhitespace /\s\+$/
set showmode
set shiftwidth=4
set autoindent
set smartindent
set cindent
set noswapfile

autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab
set softtabstop=4
set expandtab


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
