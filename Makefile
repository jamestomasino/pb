PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man

# Attempt to find bash completion dir in order of preference
ifneq ($(wildcard /etc/bash_completion.d/.),)
  CPLDIR ?= /etc/bash_completion.d
endif

HAS_BREW := $(shell command -v brew 2> /dev/null)
ifdef HAS_BREW
  CPLDIR ?= $$(brew --prefix)/etc/bash_completion.d
endif

HAS_PKGCONFIG := $(shell command -v pkg-config 2> /dev/null)
ifdef HAS_PKGCONFIG
  CPLDIR ?= $$(pkg-config --variable=completionsdir bash-completion 2> /dev/null)
endif

install:
	@echo Installing the executable to $(BINDIR)
	@install -D -m 0755 pb $(BINDIR)/pb
	@echo Installing the manual page to $(MANDIR)/man1
	@install -D -m 0644 pb.1 $(MANDIR)/man1/pb.1
ifeq ($(CPLDIR),)
	@echo Installing the command completion to $(CPLDIR)
	@mkdir -p $(CPLDIR)
	@cp -f pb.d $(CPLDIR)/pb
	@chmod 644 $(CPLDIR)/pb
endif

uninstall:
	@echo Removing the executable from $(BINDIR)
	@rm -f $(BINDIR)/pb
	@echo Removing the manual page from $(MANDIR)/man1
	@rm -f $(BINDIR)/man1/pb.1
ifeq ($(CPLDIR),)
	@echo Removing the command completion from $(CPLDIR)
	@rm -f $(CPLDIR)/pb
endif

.PHONY: install uninstall
