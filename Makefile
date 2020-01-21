PREFIX := /usr/local

.PHONY: all install

all:
	@echo 'Run `make install` to install'

install:
	install gms $(PREFIX)/bin
