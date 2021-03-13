EMACS=emacs
PREFIX:=build
DESTDIR:=$(abspath $(PREFIX)/emacs)

PERSONAL:=room.org
PERSONAL_TPL:=$(PERSONAL).tpl
PERSONAL_NEW:=$(PERSONAL).new
MAIN:=igloo.org
SRC:=$(MAIN) $(PERSONAL)
TANGLE:=init.el early-init.el lint-conv.el
TARGET:=$(patsubst %.el,%.elc,$(TANGLE))

build: $(TARGET) lint

install: build do-install

$(PERSONAL): $(PERSONAL_TPL)
ifneq ("$(wildcard $(PERSONAL_NEW))", "")
	@echo "--- WARNING ---"
	@echo "A WIP configuration was found in $(PERSONAL_NEW)."
	@echo
	@echo "If you have finished porting your old configuration over,"
	@echo "rename the file to $(PERSONAL)."
	@echo
	@echo "If you wish to replace $(PERSONAL_NEW) with a new version of the template,"
	@echo "delete $(PERSONAL_NEW)."
	@exit 1
else ifneq ("$(wildcard $(PERSONAL))","")
	@cp $(PERSONAL_TPL) $(PERSONAL_NEW)
	@echo "--- WARNING ---"
	@echo "New version of personal configuration template found."
	@echo "The new template can be found in $(PERSONAL_NEW)."
	@echo
	@echo "You should copy parts of your $(PERSONAL) into $(PERSONAL_NEW)"
	@echo "as to match its new structure, and mess with any new configuration"
	@echo "made available by the update."
	@echo "Then, rename $(PERSONAL_NEW) to $(PERSONAL)."
	@exit 1
else
	cp $(PERSONAL_TPL) $(PERSONAL)
endif

$(TANGLE): $(SRC)
	$(EMACS) -q --batch --exec="(progn \
	  (setq user-emacs-directory \"$(abspath $(DESTDIR))/\") \
	  (require 'org) \
	  (setq new-igl (make-temp-file \"igloo-merge\" nil \".org\")) \
	  (with-temp-file new-igl \
	    (insert-file-contents-literally \"$(PERSONAL)\") \
	    (insert-file-contents-literally \"$(MAIN)\")) \
	  (dolist (f (org-babel-tangle-file new-igl)) \
	    (let* ((relname (file-relative-name f temporary-file-directory)) \
	           (newname (expand-file-name relname))) \
	      (rename-file f newname 'replace))) \
	  (delete-file new-igl))"

%.elc: %.el
	$(EMACS) -q --batch --exec="(progn \
	  (setq user-emacs-directory \"$(abspath $(DESTDIR))/\") \
	  (byte-compile-file \"$?\"))"

lint: $(TANGLE)
	$(EMACS) -q --batch -l "lint-conv.el" -f lint-from-args $(TANGLE)

do-install: $(TANGLE) $(TARGET)
	install -Dm644 -t $(DESTDIR) $?

open: install
	$(EMACS) -q --debug-init --exec="(progn \
	  (setq user-emacs-directory \"$(abspath $(DESTDIR))/\") \
	  (setq user-init-file (expand-file-name \"init.el\" user-emacs-directory)) \
	  (load (expand-file-name \"early-init.elc\" user-emacs-directory)) \
	  (load (expand-file-name \"init.elc\") user-emacs-directory))"

clean:
	$(RM) -rf $(TANGLE) $(TARGET)

distclean: clean
	$(RM) -rf $(DESTDIR)
	mkdir -p $(DESTDIR)
