" Configuration file for vim

set ts=4
set sw=4
set sts=4
set uc=0
set noet

set nocompatible
set backspace=indent,eol,start

set ai					" autoindent
set tw=80				" textwidth
set nobk				" nobackup
set viminfo='20,\"50
set history=50
set ruler
set foldmethod=marker
set wildmode=longest,full
set laststatus=2
set spc=
set flp=^[-*+]\\+\\s\\+
set fo+=n
" The vim packages I'm using don't have sorted tag files for the help.
set notagbsearch

set modeline

set encoding=utf-8

set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Show highlighting groups under cursor.
noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")  . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
noremap <Leader><Leader> "*
noremap <Leader>w :%s/\v(^--)@<!\s+$//g<CR>

" We know xterm-debian is a color terminal
if &term =~ "xterm" || &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
	set t_Co=16
	set t_Sf=[3%dm
	set t_Sb=[4%dm
endif

" Ignore vcscommand and pathogen in old versions of vim.
if v:version < 700
	let VCSCommandDisableAll = 1
else
	runtime autoload/pathogen.vim
	let Fn = function("pathogen#infect")
	execute Fn()
endif

syntax enable

if has("autocmd")
	" Enabled file type detection
	" Use the default filetype settings. If you also want to load indent files
	" to automatically do language-dependent indenting add 'indent' as well.
	filetype plugin indent on
endif

function! s:SelectPerlSyntasticCheckers()
	" If the file has at least 500 lines or there's not a ~/.perlcriticrc...
	if len(getline(500, 500)) == 1 || !filereadable(expand("$HOME") . '/.perlcriticrc')
		let b:syntastic_checkers = ['perl']
	else
		let b:syntastic_checkers = ['perl', 'perlcritic']
	endif
endfunction

augroup setf
	au BufEnter,BufRead,BufNewFile *.adoc										setf asciidoc
	au BufEnter,BufRead,BufNewFile *.txt										setf asciidoc
	au BufEnter,BufRead,BufNewFile merge_request_testing.*	setf asciidoc
	au BufEnter,BufRead,BufNewFile *.dbx										setf docbkxml
	au BufEnter,BufRead,BufNewFile *.mx											setf groff
	au BufEnter,BufRead,BufNewFile reportbug-*							setf mail
	au BufEnter,BufRead,BufNewFile reportbug.*							setf mail
	au BufEnter,BufRead,BufNewFile *.xml										setf xml
	au BufEnter,BufRead,BufNewFile *.xsl										setf xslt
	au BufEnter,BufRead,BufNewFile *.pasm										setf parrot
	au BufEnter,BufRead,BufNewFile *.pir										setf pir
augroup end

augroup setl
	au FileType asciidoc		setl tw=80 ts=2 sw=2 sts=2 spell com=b://
	au FileType cpp					setl cin cino=t0
	au FileType c						setl cin cino=t0
	au FileType cs					setl cin cino=t0
	au FileType docbkxml		setl cms=<!--%s-->
	au FileType gitcommit		setl tw=80 spell com=b:#
	au FileType javascript	setl cin cino=t0,j1,J1
	au FileType java				setl cin cino=t0,j1
	au FileType mail				setl tw=72 ts=2 sw=2 sts=2 et spell com=n:>
	au FileType python			setl et si
	au FileType rst					setl et si ts=2 sw=2 sts=2 spell
	au FileType ruby				setl ts=2 sw=2 sts=2 et si
	au FileType sass				setl tw=0 noet
	au FileType scss				setl tw=0 noet
	au FileType xslt				setl tw=0 ts=2 sw=2 sts=2 noet
augroup end

augroup call
	au FileType perl				call s:SelectPerlSyntasticCheckers()
augroup end

augroup whitespace
	au BufWinEnter *				match bmcTrailingWhitespace /\v(^--)@<!\s+$/
	au InsertEnter *				match bmcTrailingWhitespace /\v(^--)@<!\s+%#@<!$/
	au InsertLeave *				match bmcTrailingWhitespace /\v(^--)@<!\s+$/
	" Prevent a memory leak in old versions of Vim.
	au BufWinLeave *				call clearmatches()
	au ColorScheme *				hi def link bmcTrailingWhitespace	Error
augroup end

" For /bin/sh.
let g:is_posix=1

let g:perl_include_pod = 0

let g:syntastic_perl_lib_path = ['./lib']
let g:Powerline_symbols = 'unicode'
let g:Powerline_colorscheme = 'solarized256'
let g:ctrlp_extensions = ['buffertag']
let g:ctrlp_clear_cache_on_exit = 0

" Set paper size from /etc/papersize if available (Debian-specific)
if filereadable('/etc/papersize')
	let s:papersize = matchstr(system('/bin/cat /etc/papersize'), '\p*')
	if strlen(s:papersize)
		let &printoptions = "paper:" . s:papersize
	endif
	unlet! s:papersize
endif


if has("gui_running")
	set lines=24 " Needed on drpepper.
	set columns=80
	let &guicursor = &guicursor . ",a:blinkon0"
	colorscheme ct_grey
	if has("gui_gtk")
		set guifont=Monospace\ 9
	elseif has("gui_kde")
	elseif has("gui_x11")
	else
	endif
elseif &t_Co == 256
	colorscheme ct_grey
else
	colorscheme ct_grey
endif

" vim: set ts=2 sw=2 sts=2 noet:
