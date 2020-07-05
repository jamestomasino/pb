# Install to /usr/local unless otherwise specified, such as `make PREFIX=/app`
PREFIX?=/usr/local

# What to run to install various files
INSTALL?=install
# Run to install the actual binary
INSTALL_PROGRAM=$(INSTALL) -Dm 755
# Run to install application data, with differing permissions
INSTALL_DATA=$(INSTALL) -Dm 644

# Directories into which to install the various files
bindir=$(DESTDIR)$(PREFIX)/bin
sharedir=$(DESTDIR)$(PREFIX)/share

# Attempt to find bash completion dir in order of preference
ifneq ($(wildcard /etc/bash_completion.d/.),)
  cpldir ?= /etc/bash_completion.d
endif

HAS_BREW := $(shell command -v brew 2> /dev/null)
ifdef HAS_BREW
  cpldir ?= $$(brew --prefix)/etc/bash_completion.d
endif

HAS_PKGCONFIG := $(shell command -v pkg-config 2> /dev/null)
ifdef HAS_PKGCONFIG
  cpldir ?= $$(pkg-config --variable=completionsdir bash-completion 2> /dev/null)
endif

help:
	@echo "targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)##\(.*\)/  \1|\3/p' \
	| column -t  -s '|'

install: pb pb.1 ## system install
	$(INSTALL_PROGRAM) pb $(bindir)/pb
	$(INSTALL_DATA) pb.1 $(sharedir)/man/man1/pb.1
ifdef cpldir
	$(INSTALL_DATA) pb.d $(cpldir)/pb
endif

uninstall: ## system uninstall
	rm -f $(bindir)/pb
	rm -f $(sharedir)/man/man1/pb.1
ifdef cpldir
	rm -f $(cpldir)/pb
endif

.PHONY: install uninstall help
