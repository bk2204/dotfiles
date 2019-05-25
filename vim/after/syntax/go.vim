syn region      goString            matchgroup=goStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@goStringGroup
syn region      goRawString         matchgroup=goStringDelimiter start=+`+ end=+`+

hi link goStringDelimiter StringDelimiter
