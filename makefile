EMACS ?= emacs
BATCH := $(EMACS) $(EFLAGS) -batch -q -no-site-file -L .

all: fries.elc

clean:
	@rm *.elc

%.elc: %.el
	$(BATCH) --eval '(byte-compile-file "$<")'

.PHONY: clean
