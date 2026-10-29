" Harrison Whitner

" 6/1/2020 - basic settings, based on example .vimrc on vim tips wiki

" disable annoying beep and flash on error
set visualbell
set t_vb=

" enable syntax highlighting
syntax on

" highlights search matches
set hlsearch

" ignores case in searches expect if capital is present
set ignorecase
set smartcase

" display line numbers
set number

" use 4 spaces instead of tabs
set shiftwidth=4
set softtabstop=4
set expandtab

" 1/1/2025 - improvements for navigation and deleting characters

" display stats about location in current file
set ruler

" allow deletion of autoindent, line breaks and existing characters
set backspace=indent,eol,start

" 10/29/2026 - keep vim's built-in defaults (jump to last position, scrolloff, incsearch, filetype indent),
" which vim skips once a .vimrc exists
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

