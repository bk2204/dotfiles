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

set makeprg=pmake

set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" We know xterm-debian is a color terminal
if &term =~ "xterm-debian" || &term =~ "xterm-xfree86"
	set t_Co=16
	set t_Sf=[3%dm
	set t_Sb=[4%dm
endif

vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

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
	au BufEnter,BufRead,BufNewFile *.mx					setf nroff
	au BufEnter,BufRead,BufNewFile *.xml				setf docbkxml
	au BufEnter,BufRead,BufNewFile *.xsl				setf xslt
	au BufEnter,BufRead,BufNewFile *.dbx				setf docbkxml
	au BufEnter,BufRead,BufNewFile *.pasm				setf parrot 
	au BufEnter,BufRead,BufNewFile *.pir				setf pir 
augroup end

augroup setl
  au FileType python		setl et si
  au FileType docbkxml	setl cms=<!--%s-->
  au FileType xslt			setl tw=0 ts=2 sw=2
  au FileType c					setl cin cino=t0
  au FileType cpp				setl cin cino=t0
  au FileType cs				setl cin cino=t0
  au FileType rst				setl et si ts=2 sw=2
  au FileType mail			setl tw=72
augroup end


" Set paper size from /etc/papersize if available (Debian-specific)
if filereadable('/etc/papersize')
	let s:papersize = matchstr(system('/bin/cat /etc/papersize'), '\p*')
	if strlen(s:papersize)
		let &printoptions = "paper:" . s:papersize
	endif
	unlet! s:papersize
endif

colorscheme desert

if has("gui_running")
set lines=24 " Needed on drpepper.
set columns=80
let &guicursor = &guicursor . ",a:blinkon0"
if has("gui_gtk")
set guifont=Monospace\ 9
elseif has("gui_kde")
elseif has("gui_x11")
else
endif
endif

" vim: set ts=2 sw=2 noet:
