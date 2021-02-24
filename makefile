EMACS ?= emacs
BATCH := $(EMACS) $(EFLAGS) -batch -q -no-site-file -L .

all: scala-disassembler.elc

clean:
	$(RM) *.elc

%.elc: %.el
        (BATCH) --eval '(byte-compile-file "$<")'

.PHONY: check clean
