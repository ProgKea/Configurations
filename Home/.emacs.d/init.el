;;;; Setup
;; Melpa
(require 'package)
(setq package-archives '(
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Use Package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq package-native-compile t)
(setq comp-async-report-warnings-errors nil)
(setq comp-deferred-compilation t)
(setq use-package-always-ensure t)

;; Install Straight
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; MacOS
(setq mac-right-option-modifier 'none)
(global-set-key (kbd "C-s-f") #'toggle-frame-fullscreen)

(setq package-install-upgrade-built-in t)

(setq enable-local-variables :all)

(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(column-number-mode 1)
(menu-bar--display-line-numbers-mode-relative)
(global-auto-revert-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)

;; Themes
(use-package gruber-darker-theme)
(use-package ef-themes)
(use-package zenburn-theme)
(use-package handmade-theme
  :straight (handmade-theme :type git :host github :repo "ProgKea/handmade-theme")
  :config
  (add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/straight/repos/handmade-theme")))

;; Preferences
(defalias 'yes-or-no-p 'y-or-n-p)
(setq compilation-ask-about-save nil)
(setq scroll-margin 8)
(setq auto-save-default nil)
(setq ring-bell-function 'ignore)
(setq tags-revert-without-query t)
(setq buffer-save-without-query t)
(setq-default fast-but-imprecise-scrolling t)
(setq-default compilation-scroll-output t)

;;; Backups
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      vc-make-backup-files t
      version-control t
      kept-old-versions 0
      kept-new-versions 10
      delete-old-versions t
      backup-by-copying t)

;; Indentation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; Magit
(use-package magit
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (setq magit-commit-show-diff nil))

;; Vertico
(use-package vertico
  :after evil
  :init (vertico-mode 1)
  :config
  (evil-define-key 'normal vertico-map (kbd "j") #'vertico-next)
  (evil-define-key 'normal vertico-map (kbd "k") #'vertico-previous)
  (evil-define-key 'normal vertico-map (kbd "G") #'vertico-last)
  (evil-define-key 'normal vertico-map (kbd "gg") #'vertico-first)
  (evil-define-key 'normal vertico-map (kbd "C-u") #'vertico-scroll-down)
  (evil-define-key 'normal vertico-map (kbd "C-d") #'vertico-scroll-up)
  (evil-define-key 'insert vertico-map (kbd "C-n") #'vertico-next)
  (evil-define-key 'insert vertico-map (kbd "C-p") #'vertico-previous)
  (evil-define-key 'normal vertico-map (kbd "<tab>") #'vertico-insert))

;; cape
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

;; Orderless
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrride nil))

(use-package savehist
  :ensure nil ; it is built-in
  :config
  (add-hook 'after-init-hook #'savehist-mode))

(use-package corfu
  :after evil
  :config
  (setq corfu-preselect-first nil)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)
  (setq corfu-quit-at-boundary 'separator)

  (global-corfu-mode)
  (evil-define-key 'insert corfu-mode-map (kbd "C-e") #'corfu-quit)
  (evil-define-key 'insert corfu-mode-map (kbd "C-i") #'corfu-insert-separator)
  (evil-define-key 'insert 'global (kbd "C-j") #'complete-symbol)
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package yasnippet
  :after evil
  :config
  (setq yas-also-auto-indent-first-line t)
  (setq yas-triggers-in-field nil)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))

  ;; (evil-define-key '(insert normal) yas-minor-mode-map (kbd "TAB") #'yas-expand)

  (yas-global-mode))

;; Undo Tree
(use-package undo-tree
  :after evil
  :diminish
  :init
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  (setq undo-tree-enable-undo-in-region nil)
  (evil-define-key 'normal 'global (kbd "<leader>u") #'undo-tree-visualize)
  :config
  (evil-set-undo-system 'undo-tree)
  (global-undo-tree-mode 1))

(use-package ansi-color
  :ensure nil
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

;; Compilation
(use-package compile
  :after evil
  :ensure nil
  :init
  (evil-define-key 'normal 'global (kbd "<down>") #'next-error)
  (evil-define-key 'normal 'global (kbd "<up>") #'previous-error)

  (evil-define-key 'normal 'global (kbd "C-j") #'recompile)
  (evil-define-key 'normal lisp-interaction-mode-map (kbd "C-j") #'eval-print-last-sexp)
  (evil-define-key 'normal 'global (kbd "C-k") #'compile)

  (evil-define-key 'normal compilation-mode-map (kbd "C-j") #'recompile)
  (evil-define-key 'normal compilation-mode-map (kbd "C-k") #'compile)

  (setq compile-command ""))

(use-package flymake
  :ensure nil
  :after evil
  :config
  (evil-define-key 'normal 'global (kbd "C-n") #'flymake-goto-next-error)
  (evil-define-key 'normal 'global (kbd "C-p") #'flymake-goto-prev-error))

(use-package dired
  :after evil
  :ensure nil
  :config
  (add-hook #'dired-mode-hook #'auto-revert-mode)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-dwim-target t)
  (evil-define-key 'normal dired-mode-map (kbd "C-v") #'vterm))

;; Window
(use-package window
  :ensure nil
  :config
  (setq display-buffer-alist '(("\\*compilation\\*"
                                (display-buffer-reuse-mode-window)
                                (dedicated . t)
                                (side . bottom)
                                (window-height . 0.2))
                               ("\\*Async Shell Command\\*\\(<[[:digit:]]+>\\)?"
                                (display-buffer-no-window))
                               ("\\*rg\\*"
                                (display-buffer-reuse-mode-window display-buffer-below-selected)
                                (dedicated . t))
                               ("\\*xref\\*"
                                (display-buffer-reuse-mode-window display-buffer-below-selected)
                                (dedicated . t)))))

(use-package winner
  :ensure nil
  :config
  (winner-mode 1)
  (define-key winner-mode-map (kbd "S-<left>") #'winner-undo)
  (define-key winner-mode-map (kbd "S-<right>") #'winner-redo))

;; Dumb Jump
(use-package dumb-jump
  :config
  (setq dumb-jump-force-searcher 'rg)
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; Languages
(use-package cc-mode
  :ensure nil
  :init
  (setq-default c-basic-offset 2
                c-default-style '((java-mode . "java")
                                  (awk-mode . "awk")
                                  (other . "bsd")))
  :config
  (add-hook 'c-mode-hook (lambda () (c-toggle-comment-style -1))))

(use-package odin-mode
  :straight (:type git :host github :repo "mattt-b/odin-mode"))

(use-package markdown-mode)

(use-package plantuml-mode
  :after org
  :config
  (setq plantuml-jar-path "~/ThirdParty/Plantuml")
  (setq org-plantuml-jar-path "~/ThirdParty/Plantuml")
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((plantuml . t))))

(use-package emmet-mode
  :after evil
  :config
  (add-hook 'mhtml-mode-hook #'emmet-mode)

  (evil-define-key 'insert emmet-mode-keymap (kbd "C-j") #'emmet-expand-line)
  (evil-define-key 'insert emmet-mode-keymap (kbd "S-C-j") #'emmet-expand-yas))

(use-package kotlin-mode)

(use-package yaml-mode)

(use-package swift-mode)

(use-package jai-mode
  :straight (:type git :host github :repo "elp-revive/jai-mode"))

(use-package glsl-mode)

(use-package python
  :ensure nil
  :init
  (setq python-indent-offset 2))

(use-package rainbow-mode)

;; Projectile
(use-package projectile
  :after evil
  :init
  (use-package rg) ;; NOTE(kd): For projectile-ripgrep to work

  (when (file-directory-p "~/Programming")
    (setq projectile-project-search-path '("~/Programming")))
  (projectile-mode 1)
  (evil-define-key 'normal 'global (kbd "C-f") #'projectile-find-file)
  (evil-define-key 'normal 'global (kbd "C-ö") #'projectile-dired)
  (evil-define-key 'normal 'global (kbd "C-s") #'projectile-switch-project)
  (evil-define-key 'normal 'global (kbd "C-x p t") #'projectile-run-vterm)

  ;; NOTE(kd): this is the same key prefix I use for consult
  (let ((key-prefix "C-a "))
    (evil-define-key 'normal 'global (kbd (concat key-prefix "R")) #'projectile-ripgrep)))

;; Consult
(use-package consult
  :after evil
  :config
  (let ((key-prefix "C-a "))
    (evil-define-key 'normal 'global (kbd (concat key-prefix "r")) #'consult-ripgrep)
    (evil-define-key 'normal 'global (kbd (concat key-prefix "l")) #'consult-line)
    (evil-define-key 'normal 'global (kbd (concat key-prefix "c")) #'consult-compile-error)
    (evil-define-key 'normal 'global (kbd (concat key-prefix "a t")) #'consult-theme)
    (evil-define-key 'normal 'global (kbd (concat key-prefix "f")) #'consult-find))
  (evil-define-key nil 'global (kbd "C-x b") #'consult-buffer))

;; Editorconfig
(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

;; Vim keybindings
(use-package evil
  :init
  (setq evil-want-Y-yank-to-eol t)
  (setq cursor-type 'box)
  (setq evil-normal-state-cursor '(box))
  (setq evil-insert-state-cursor '(box))
  (setq evil-operator-state-cursor '(box))
  (setq evil-visual-state-cursor 'box)
  (setq evil-motion-state-cursor 'box)
  (setq evil-replace-state-cursor 'box)
  (setq evil-want-keybinding nil)
  (setq evil-want-minibuffer t)
  :config
  (global-set-key (kbd "C-u") #'evil-scroll-page-up)
  (add-to-list 'evil-normal-state-modes #'shell-mode)

  (evil-set-leader 'normal (kbd "SPC"))
  (evil-set-leader 'visual (kbd "SPC"))

  ;; To make always escape escape
  (define-key key-translation-map (kbd "ESC") (kbd "C-g"))
  (evil-define-key 'normal minibuffer-mode-map (kbd "<escape>") #'abort-minibuffers)
  (evil-define-key 'normal evil-ex-completion-map (kbd "<escape>") #'abort-minibuffers)
  (evil-define-key 'normal evil-ex-search-keymap (kbd "<escape>") #'abort-minibuffers)
  (evil-define-key 'normal minibuffer-mode-map (kbd "<return>") #'exit-minibuffer)

  (evil-define-key 'normal 'global (kbd "<leader>w") #'save-buffer)
  (evil-define-key 'normal 'global (kbd "C-l") #'async-shell-command)
  (evil-define-key 'visual 'global (kbd "gc") #'comment-or-uncomment-region)
  (evil-define-key 'visual 'global (kbd "C-a") #'align-regexp)
  (evil-define-key 'normal c-mode-map (kbd "<leader>h") #'ff-find-other-file)
  (evil-define-key 'normal c++-mode-map (kbd "<leader>h") #'ff-find-other-file)

  (evil-define-key 'visual 'global (kbd "gi") #'upcase-initials-region)

  (evil-mode 1))

(use-package evil-goggles
  :config
  (setq evil-goggles-enable-delete nil)
  (setq evil-goggles-enable-change nil)
  (evil-goggles-mode))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Autocompletion and Snippets
;; Language Support
(use-package typescript-mode
  :config
  (add-hook 'typescript-mode-hook (lambda ()
                                    (setq typescript-indent-level 2)))
 (add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode)))

(use-package js
  :ensure nil
  :config
  (add-hook 'javascript-mode-hook (lambda ()
                                    (setq javascript-indent-level 2))))

(use-package rust-mode)

(use-package zig-mode)

(use-package nim-mode)

(use-package go-mode)

(use-package lua-mode)

(use-package dart-mode)

(defun metadesk-indent-line ()
  "Indent current line of Metadesk code."
  (interactive)
  (let ((savep (> (current-column) (current-indentation)))
        (indent (condition-case nil (max (metadesk-calculate-indentation) 0)
                  (error 0))))
    (if savep
        (save-excursion (indent-line-to indent))
      (indent-line-to indent))))

(defun metadesk-calculate-indentation ()
  "Return the column to which the current line should be indented."
  (* tab-width (min (car (syntax-ppss (line-beginning-position)))
                    (car (syntax-ppss (line-end-position))))))

(define-generic-mode metadesk-mode
  '("//" ("/*" . "*/"))
  ()
  '(("@" . 'font-lock-keyword-face))
  (list ".*\\.mdesk$")
  (list
   (lambda ()
     (setq-local tab-width 2)
     (setq-local indent-tabs-mode nil)
     (setq-local indent-line-function 'metadesk-indent-line)))
  "Major mode for metadesk")


;; which key
(use-package which-key
  :config
  (which-key-mode 1))

;; Encryption
(use-package epa-file
  :ensure nil
  :config
  (epa-file-enable))

(use-package evil-org
  :after org)

;; org-mode
(defun kd/org-hook ()
  (display-line-numbers-mode -1)
  (flyspell-mode 1)
  (evil-org-mode)
  (add-hook 'after-save-hook #'flyspell-buffer nil t))

(use-package guess-language
  :config
  (setq guess-language-languages '(en de))
  (add-hook 'org-mode-hook #'guess-language-mode))

(use-package flyspell
  :ensure nil
  :config
  (evil-define-key 'normal flyspell-mode-map (kbd "<leader>j") #'flyspell-correct-word-before-point))

(use-package org
  :config
  (add-hook 'org-mode-hook #'kd/org-hook)
  (add-hook 'org-babel-after-execute-hook #'org-redisplay-inline-images)

  (setq org-confirm-babel-evaluate nil)
  (setq org-startup-with-inline-images t)
  (setq org-startup-with-latex-preview t)
  (setq org-fontify-whole-heading-line t)

  ;; latex preview
  (plist-put org-format-latex-options :scale 2.0)

  (custom-set-faces
   '(org-level-1 ((t (:height 1.5))))
   '(org-level-2 ((t (:height 1.4))))
   '(org-level-3 ((t (:height 1.3))))
   '(org-level-4 ((t (:height 1.2))))
   '(org-level-5 ((t (:height 1.1)))))
  
  (setq
   ;; Edit settings
   org-auto-align-tags nil
   org-tags-column 0
   org-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; Org styling, hide markup etc.
   org-pretty-entities t

   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "◀── now ─────────────────────────────────────────────────")

  ;; Ellipsis styling
  (setq org-ellipsis "…")
  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))

(use-package org-modern
  :config
  (add-hook 'org-mode-hook #'global-org-modern-mode))

(use-package org-download
  :after org
  :bind ("C-c p" . org-download-clipboard))

(use-package ob-python
  :ensure nil
  :config
  (setq org-babel-python-command "python3"))

(use-package org-roam
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n t" . org-roam-tag-add)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (setq org-roam-directory (file-truename "~/KnowledgeGarden"))
  (setq org-agenda-files (list (file-truename "~/KnowledgeGarden")))

  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))
(put 'downcase-region 'disabled nil)

(use-package eglot
  :ensure nil
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  (add-hook 'typescript-mode-hook 'eglot-ensure)
  (add-hook 'go-mode-hook 'eglot-ensure)

  (evil-define-key 'normal eglot-mode-map (kbd "<leader>r") #'eglot-rename)
  (evil-define-key 'normal eglot-mode-map (kbd "<leader>f") #'eglot-format-buffer)
  (evil-define-key 'normal eglot-mode-map (kbd "<leader>a") #'eglot-code-actions))

(use-package vterm
  :config
  (add-hook 'vterm-mode-hook (lambda ()
                               (setq-local global-hl-line-mode nil))))

(use-package sudo-edit)

(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

(defvar monospace-font "Liberation Mono-14")
;; (set-frame-font "Liberation Mono-14")
(add-to-list 'default-frame-alist '(font . "Liberation Mono-14"))

(if (eq system-type 'darwin)
    (progn
      (setq ispell-program-name "~/.brew/bin/aspell")
      (add-to-list 'default-frame-alist `(font . ,monospace-font))
      (set-face-font 'fixed-pitch monospace-font)
      ;; (set-face-font 'variable-pitch "Roboto Condensed-15"))
    (progn
      (add-to-list 'default-frame-alist `(font . ,monospace-font))
      (set-face-font 'fixed-pitch monospace-font)
      ;; (set-face-font 'variable-pitch "Roboto Condensed-13")
      ))
