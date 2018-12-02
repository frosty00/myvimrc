command M :w | :make
map t lbve~l
map x ldh
map q lBi"Ea"
 
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
