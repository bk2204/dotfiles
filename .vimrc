" Configuration file for vim

"" Set up options.
" First things first.
set nocp

" Spacing and indentation.
set ts=4
set sw=4
set sts=4
set noet
set ai

" Backups, saving, and statefulness.
set uc=0				" No swap file.
set nobk				" No backups.
set vi='20,\"50	" 20 marks and 50 lines.
set hi=50				" 50 items in command line history.

" Status line.
set ru					" Turn on ruler.
set ls=2				" Always show a status bar for powerline.

" Folding.
set fdm=marker

" Text handling.
set spc=				" Don't complain about uncapitalized words starting a sentence.
set flp=^[-*+]\\+\\s\\+	" Don't indent lines starting with a number and a dot.
set fo+=n				" Indent lists properly.
set tw=80
set bs=indent,eol,start

" Loading files.
set ml					" Modelines are nice.
set enc=utf-8		" Always use UTF-8.
set wim=longest,full
set su=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc

" Search.
set nohls

"" Terminal issues.
" These terminals are capable of supporting 16 colors, but they lie and only
" claim support for 8.  Fix it so things don't look ugly.
if &term == "xterm" || &term == "xterm-debian" || &term == "xterm-xfree86"
	set t_Co=16
	set t_Sf=[3%dm
	set t_Sb=[4%dm
endif

"" Maps.
" Show highlighting groups under cursor.
noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")  . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
" "* is hard to type.  Map it to something easier.
noremap <Leader><Leader> "*
" Trim trailing whitespace.
noremap <Leader>w :%s/\v(^--)@<!\s+$//g<CR>
" Toggle whitespace highlighting.
noremap <Leader>t :call <SID>ToggleWhitespaceChecking()<CR>
" Beautify files.
vnoremap <Leader>b :call <SID>DoTidy(1)<CR>
nnoremap <Leader>b :call <SID>DoTidy(0)<CR>

"" Automatic file handling.
if has("autocmd")
	filetype plugin indent on
endif

syntax enable

"" Bundles.
" Vim 6.3 has a major problem trying to load Pathogen.
if v:version >= 700
	" Some versions of Vim have a broken autoload, or at least it doesn't work in
	" this case, so help it out.
	runtime autoload/pathogen.vim
	let Fn = function("pathogen#infect")
	execute Fn()
endif

"" Language-specific functions.
" perlcritic is *extremely* slow on large files.
function! s:SelectPerlSyntasticCheckers()
	" If the file has at least 500 lines or there's not a ~/.perlcriticrc...
	if len(getline(500, 500)) == 1 || !filereadable(expand("$HOME") . '/.perlcriticrc')
		let b:syntastic_checkers = ['perl']
	else
		let b:syntastic_checkers = ['perl', 'perlcritic']
	endif
endfunction

" Tidy code.
function! s:DoTidy(visual) range
	let cmd = "cat"
	if &ft == "perl"
		let cmd = "perltidy -q"
	elseif &ft == "python"
		let cmd = "pythontidy"
	endif
	if a:visual == 0
		let text = ":%!" . cmd
		execute text
	elseif a:visual == 1
		let text = ":'<,'>!" . cmd
		execute text
	end
endfunction

"" Whitespace handling functions.
" Turn it on.
function! s:EnableWhitespaceChecking()
	if !exists('b:whitespace')
		let b:whitespace = {'enabled': -1, 'patterns': {}}
	endif
	if b:whitespace['enabled'] == -1
		if &ft == 'help'
			let b:whitespace['enabled'] = 0
		else
			let b:whitespace['enabled'] = 1
		endif
		for i in s:GetPatternList()
			let b:whitespace['patterns'][i] = -1
		endfor
	endif
endfunction

" Toggle it.
function! s:ToggleWhitespaceChecking()
	let b:whitespace['enabled'] = !b:whitespace['enabled']
	call s:SetWhitespacePattern(0)
endfunction

" List of all the patterns.
function! s:GetPatternList()
	return ['trailing', 'spacetab', 'newline']
endfunction

" Set up the patterns.
function! s:SetWhitespacePattern(mode)
	call s:EnableWhitespaceChecking()
	for i in s:GetPatternList()
		try
			call matchdelete(b:whitespace['patterns'][i])
		catch /E80[23]/
		endtry
	endfor
	if b:whitespace['enabled']
		if a:mode == 1
			let pattern = s:SetWhitespacePatternGeneral() . '%#@<!$'
		elseif a:mode == 0
			let pattern = s:SetWhitespacePatternGeneral() . '$'
		end
		let stpat = '\v +\ze\t+'
		let tnpat = '\v\n%$'
		let patterns = {}
		let patterns['trailing'] = matchadd('bmcTrailingWhitespace', pattern)
		let patterns['spacetab'] = matchadd('bmcSpaceTabWhitespace', stpat)
		let patterns['newline'] = matchadd('bmcTrailingNewline', stpat)
		let b:whitespace['patterns'] = patterns
	else
		let b:whitespace['patterns'] = {}
		for i in s:GetPatternList()
			let b:whitespace['patterns'][i] = -1
		endfor
	endif
endfunction

" Create a language-specific trailing whitespace pattern.
function! s:SetWhitespacePatternGeneral()
	if &ft == "mail"
		" ExtEdit puts trailing whitespace in header fields.  Don't warn about this,
		" since it will strip it off.  mutt always inserts "> " for indents; don't
		" warn about that either.  And finally, don't warn about the signature
		" delimiter, since there's nothing we can do about that.
		let pattern = '\v(^(--|[A-Z]+[a-zA-Z-]+:\s*|[> ]*\>))@<!\s+'
	elseif &ft == "diff" || &ft == "review"
		" Don't complain about extra spaces if they start at the beginning of a
		" line.  git and diff insert these.
		let pattern = '\v(^\s*)@<!\s+'
	else
		let pattern = '\v\s+'
	endif
	return pattern
endfunction

"" Autocommands.
" Setting file type.
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

" File type-specific parameters.
augroup setl
	au FileType asciidoc		setl tw=80 ts=2 sw=2 sts=2 spell com=b://
	au FileType cpp					setl cin cino=t0
	au FileType c						setl cin cino=t0
	au FileType cs					setl cin cino=t0
	au FileType docbkxml		setl cms=<!--%s-->
	au FileType gitcommit		setl tw=76 spell com=b:#
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

" Language-specific setup.
augroup call
	au FileType perl				call s:SelectPerlSyntasticCheckers()
augroup end

" Whitespace-related autocommands.
if v:version >= 702 || (v:version == 701 && has("patch40"))
	" matchadd and friends showed up in Vim 7.1.40.
	augroup whitespace
		au BufWinEnter	*				call s:SetWhitespacePattern(0)
		au WinEnter			*				call s:SetWhitespacePattern(0)
		au InsertEnter	*				call s:SetWhitespacePattern(1)
		au InsertLeave	*				call s:SetWhitespacePattern(0)
		" Prevent a memory leak in old versions of Vim.
		au BufWinLeave	*				call clearmatches()
		au WinLeave			*				call clearmatches()
		au Syntax				*				call s:SetWhitespacePattern(0)
		au ColorScheme	*				hi def link bmcTrailingWhitespace	Error
		au ColorScheme	*				hi def link bmcSpaceTabWhitespace	Error
		au ColorScheme	*				hi def link bmcTrailingNewline	Error
	augroup end
endif

"" Miscellaneous variables.
" Make sh highlighting POSIXy.
let g:is_posix=1

" Better just to leave POD as a big comment block.
let g:perl_include_pod = 0

" Make editing git repositories of Perl modules easier.
let g:syntastic_perl_lib_path = ['./lib']

" Powerline settings.
let g:Powerline_symbols = 'unicode'
let g:Powerline_colorscheme = 'solarized256'

" Ctrl-P settings.  Regenerating the cache is expensive on large repos.
let g:ctrlp_extensions = ['buffertag']
let g:ctrlp_clear_cache_on_exit = 0

"" Print settings.
if filereadable('/etc/papersize')
	let s:papersize = matchstr(system('/bin/cat /etc/papersize'), '\p*')
	if strlen(s:papersize)
		let &printoptions = "paper:" . s:papersize
	endif
	unlet! s:papersize
endif

"" Display settings.
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
