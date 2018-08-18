" Vim syntax file
" Language:			C
" Maintainer:		brian m. carlson <sandals@crustytoothpaste.net>
" Last Change:	2006 July 25
" Remark:				Just a few personal changes for C.

source $VIMRUNTIME/syntax/c.vim

" Change all text matching the following expression into a type.
syn match	cLocalType		display "\<[a-z]\+[a-z0-9_]\+_t\>"

hi def link cLocalType		cType

