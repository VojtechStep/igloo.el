; -*- mode: org -*-

* Room - personal configuration
:PROPERTIES:
:header-args: :tangle no
:END:

This is your private space - generate a =room.org= file by running =make room.org=, and edit it to your heart's content.

** Elfeed

Feeds - an expression that returns a list to be assigned to =elfeed-feeds=.

#+begin_src emacs-lisp :noweb-ref elfeed-feeds
'()
#+end_src

Ignored tags - alist mapping of link id (url) -> a list of ignored categories. An entry is assigned the =junk= tag if it belongs to any of the ignored categories.

An ignored category can be a symbol, a string, or a list, in which case the pattern is considered matched if it matches all the categories inside.

#+begin_src emacs-lisp :noweb-ref elfeed-ignored
'()
#+end_src

** Projects

List of directories which contain your git projects (consult =magit-repository-directories= for documentation)

#+begin_src emacs-lisp :noweb-ref magit-directories
'()
#+end_src
