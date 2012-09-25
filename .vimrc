" Configuration file for vim

set ts=4
set sw=4
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

set modeline

set encoding=utf-8

set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" We know xterm-debian is a color terminal
if &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
	set t_Co=16
	set t_Sf=[3%dm
	set t_Sb=[4%dm
endif

call pathogen#infect()

syntax enable

if has("autocmd")
	" Enabled file type detection
	" Use the default filetype settings. If you also want to load indent files
	" to automatically do language-dependent indenting add 'indent' as well.
	filetype plugin indent on
endif

augroup setf
	au BufEnter,BufRead,BufNewFile reportbug.*	setf mail
	au BufEnter,BufRead,BufNewFile reportbug-*	setf mail
	au BufEnter,BufRead,BufNewFile *.mx					setf groff
	au BufEnter,BufRead,BufNewFile *.xml				setf xml
	au BufEnter,BufRead,BufNewFile *.xsl				setf xslt
	au BufEnter,BufRead,BufNewFile *.dbx				setf docbkxml
	au BufEnter,BufRead,BufNewFile *.pasm				setf parrot 
	au BufEnter,BufRead,BufNewFile *.pir				setf pir 
	au BufEnter,BufRead,BufNewFile *.txt				setf asciidoc 
augroup end

augroup setl
  au FileType python		setl et si
  au FileType docbkxml	setl cms=<!--%s-->
  au FileType xslt			setl tw=0 ts=2 sw=2 noet
  au FileType sass			setl tw=0 ts=4 sw=4 noet
  au FileType scss			setl tw=0 ts=4 sw=4 noet
  au FileType c					setl cin cino=t0
  au FileType cpp				setl cin cino=t0
  au FileType cs				setl cin cino=t0
  au FileType rst				setl et si ts=2 sw=2
  au FileType mail			setl tw=72
  au FileType asciidoc	setl ts=2 sw=2
augroup end

" For /bin/sh.
let g:is_posix=1

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

" vim: set ts=2 sw=2 noet:
