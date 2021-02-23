EMACS=emacs
PREFIX:=build
DESTDIR:=$(abspath $(PREFIX)/emacs)

SRC:=igloo.org
TANGLE:=init.el early-init.el lint-conv.el
TARGET:=$(patsubst %.el,%.elc,$(TANGLE))

build: $(TARGET) lint

$(TANGLE): $(SRC)
	$(EMACS) -q --batch --exec="(progn \
	  (setq user-emacs-directory \"$(abspath $(DESTDIR))/\") \
	  (require 'org) \
	  (org-babel-tangle-file \"$(SRC)\"))"

%.elc: %.el
	$(EMACS) -q --batch --exec="(progn \
	  (setq user-emacs-directory \"$(abspath $(DESTDIR))/\") \
	  (byte-compile-file \"$?\"))"

lint: $(TANGLE)
	$(EMACS) -q --batch -l "lint-conv.el" -f lint-from-args $(TANGLE)

install: $(TANGLE) $(TARGET)
	install -Dm644 -t $(DESTDIR) $?

open: install
	emacs -q --exec="(progn \
	  (setq user-init-file \"$(abspath $(DESTDIR))/init.el\") \
	  (setq user-emacs-directory (file-name-directory user-init-file)) \
	  (load (expand-file-name \"early-init.elc\" user-emacs-directory)) \
	  (load user-init-file))"

clean:
	$(RM) -rf $(TANGLE) $(TARGET)

distclean: clean
	$(RM) -rf $(DESTDIR)
