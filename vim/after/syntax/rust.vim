syn region    rustString      matchgroup=rustStringDelimiter start=+[bc]"+ skip=+\\\\\|\\"+ end=+"+ contains=rustEscape,rustEscapeError,rustStringContinuation
syn region    rustString      matchgroup=rustStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=rustEscape,rustEscapeUnicode,rustEscapeError,rustStringContinuation,@Spell
syn region    rustString      matchgroup=rustStringDelimiter start='[bc]\?r\z(#*\)"' end='"\z1' contains=@Spell

hi link rustStringDelimiter StringDelimiter
