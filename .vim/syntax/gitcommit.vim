" Vim syntax file
" Based off the upstream file, just supporting French as well.

source $VIMRUNTIME/syntax/gitcommit.vim

syn match   gitcommitOnBranch	"\%(^# \)\@<=Sur la branche" contained containedin=gitcommitComment nextgroup=gitcommitBranch skipwhite
syn match   gitcommitOnBranch	"\%(^# \)\@<=Votre branche .\{-\} '" contained containedin=gitcommitComment nextgroup=gitcommitBranch skipwhite
syn match   gitcommitNoBranch	"\%(^# \)\@<=Actuellement sur aucun branche." contained containedin=gitcommitComment
syn match   gitcommitNoChanges	"\%(^# \)\@<=Aucune modification$" contained containedin=gitcommitComment

syn region  gitcommitUntracked	start=/^# Fichiers non suivis/ end=/^#$\|^#\@!/ contains=gitcommitHeader,gitcommitHead,gitcommitUntrackedFile fold
syn match   gitcommitUntrackedFile  "\t\@<=.*"	contained

syn region  gitcommitDiscarded	start=/^# Modifications qui ne seront pas validées :/ end=/^#$\|^#\@!/ contains=gitcommitHeader,gitcommitHead,gitcommitDiscardedType fold

syn region  gitcommitDiscarded	start=/^# Sous-modules modifiés mais non mis à jour :/ end=/^#$\|^#\@!/ contains=gitcommitHeader,gitcommitHead,gitcommitDiscardedType fold
syn region  gitcommitSelected	start=/^# Modifications qui seront validées :/ end=/^#$\|^#\@!/ contains=gitcommitHeader,gitcommitHead,gitcommitSelectedType fold
syn region  gitcommitUnmerged	start=/^# Chemins non fusionnés :/ end=/^#$\|^#\@!/ contains=gitcommitHeader,gitcommitHead,gitcommitUnmergedType fold

" These use a non-breaking space (U+00A0) before the question mark.
syn match   gitcommitDiscardedType	"\t\@<=[a-z][a-z ]*[a-z] \?: "he=e-2	contained containedin=gitcommitComment nextgroup=gitcommitDiscardedFile skipwhite
syn match   gitcommitSelectedType	"\t\@<=[a-z][a-z ]*[a-z] \?: "he=e-2	contained containedin=gitcommitComment nextgroup=gitcommitSelectedFile skipwhite
syn match   gitcommitUnmergedType	"\t\@<=[a-z][a-z ]*[a-z] \?: "he=e-2	contained containedin=gitcommitComment nextgroup=gitcommitUnmergedFile skipwhite

syn match   gitcommitWarning		"\%^[^#].*: needs merge$" nextgroup=gitcommitWarning skipnl
syn match   gitcommitWarning		"^[^#].*: needs merge$" nextgroup=gitcommitWarning skipnl contained
syn match   gitcommitWarning		"^\%(aucune modification.*ajoutée\?\)\>.*\%$"
