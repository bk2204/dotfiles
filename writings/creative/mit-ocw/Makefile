SUFFIXES	:= .mx .me .mm

.for i in ${SUFFIXES}
SRCS_$i		!= find -name "*$i"; echo
SRCS		+= ${SRCS_$i}
OBJS		+= ${SRCS_$i:$i=.pdf}
.endfor

.SUFFIXES: ${SUFFIXES} .ps .pdf

all: ${OBJS}

clean:
	rm -f *.pdf *.dvi *.ps

.include "${HOME}/.crustytoothpaste/groups/pmakefiles/troff.mk"
