
;;; init.el --- Refactored Configuration
;;;;; 1. Package Management Setup
(require 'package)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")))

(package-initialize)

;; Install use-package if not present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Automatically install packages defined in use-package
(setq use-package-always-ensure t)


;;;;; 2. Basic Settings (Encoding, UI, Backup)

;; Encoding
(prefer-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-locale-environment nil)

;; UI Cleanup
(load-theme 'misterioso t)
(column-number-mode t)
(tool-bar-mode 0)
(menu-bar-mode 0)
(setq inhibit-startup-message t) ; Hide splash screen

;; File Handling
(setq create-lockfiles nil)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq history-length 1024)

;; Indentation Defaults
(setq-default indent-tabs-mode nil) ; Use spaces
(setq-default tab-width 2)
(setq-default c-basic-offset 2)
(setq indent-line-function 'insert-tab)

;; Window Management
(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))

(global-set-key (kbd "C-t") 'other-window-or-split)
(global-set-key (kbd "C-i") 'scroll-down-command)

;; Prevent "C-[" from accidentally closing windows via escape
(define-key key-translation-map (kbd "C-]") (kbd "<escape>"))

;; Prevent "ESC ESC ESC" from closing windows.
(global-set-key (kbd "ESC ESC ESC") 'keyboard-quit)

;; Disable annoying help bindings
(dolist (key '("C-h n" "C-h C-n" "C-h C-d" "C-h C-c" "C-h C-e" "C-h C-f"
               "C-h g" "C-h C-o" "C-h C-p" "C-h C-t" "C-h C-w" "C-h h"
               "C-h C-a" "<f1> a"))
  (global-unset-key (kbd key)))


;;;;; 3. Core Editor Features

;; Bracket Pair Handling
(use-package elec-pair
  :ensure nil ; Built-in
  :hook (prog-mode . electric-pair-mode))

(use-package paren
  :ensure nil ; Built-in
  :config
  (setq show-paren-style 'mixed)
  (show-paren-mode t)
  (set-face-attribute 'show-paren-match nil :background "#5d5d5d"))

;; Whitespace visualization
(use-package whitespace
  :ensure nil ; Built-in
  :config
  (setq whitespace-style '(tab-mark face)) ; Simple config
  (setq-default show-trailing-whitespace t)
  (global-whitespace-mode t))

;; Undo/Redo (undo-fu)
(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-/") 'undo-fu-only-redo))

;; Visual feedback on operations
(use-package volatile-highlights
  :config
  (volatile-highlights-mode t))

;; Search/Replace visualizer
(use-package anzu
  :config
  (global-anzu-mode t))

;; Auto-completion (Company)
(use-package company
  :config
  (global-company-mode)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 2) ; Shortened slightly
  (setq company-selection-wrap-around t)
  (setq company-tooltip-align-annotations t)
  :bind
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("C-s" . company-filter-candidates)
        ("C-M-i" . company-complete-selection)
        ("<tab>" . company-complete-selection))
  (:map company-search-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous))
  (:map global-map
        ("C-M-i" . company-complete)))


;;;;; 4. Navigation & Tools

(use-package neotree
  :bind ([f8] . neotree-toggle)
  :config
  (setq neo-show-hidden-files t)
  (setq neo-smart-open t))

(use-package multi-term
  :config
  (setq multi-term-program "/bin/bash")
  (add-hook 'term-mode-hook
            (lambda ()
              (term-set-escape-char ?\C-t)
              (define-key term-raw-map "\C-t" 'next-multiframe-window)
              (define-key term-raw-map "\M-y" 'yank-pop)
              (define-key term-raw-map "\M-w" 'kill-ring-save))))


;;;;; 5. Programming Languages

;; Syntax Checking
(use-package flycheck
  :init (global-flycheck-mode))

;; C/C++
(add-to-list 'auto-mode-alist '("\\.cu?\\'" . c++-mode))
(add-hook 'c-mode-common-hook
          (lambda ()
            (c-set-style "bsd")
            (setq c-basic-offset 2)
            (setq c-tab-always-indent t)
            (setq indent-tabs-mode nil)
            (c-set-offset 'innamespace 2)
            (c-set-offset 'arglist-close 0)
            ;; Enable newline-and-indent on Enter
            (local-set-key "\C-m" 'newline-and-indent)))

;; Python
(use-package python
  :ensure nil ; Built-in
  :config
  (setq python-indent-offset 2))

;; JSON / YAML / Docker / INI
(use-package json-mode)
(use-package yaml-mode)
(use-package dockerfile-mode)
(use-package ini-mode)

;; TypeScript
(use-package typescript-mode
  :mode "\\.ts\\'"
  :config
  (setq typescript-indent-level 2))

;; Web Mode (HTML, Vue, Templates)
(use-package web-mode
  :mode
  ("\\.html?\\'" . web-mode)
  ("\\.vue\\'"   . web-mode)
  :config
  (setq web-mode-enable-engine-detection t)
  (setq web-mode-content-types-alist '(("vue" . "\\.vue\\'")))

  ;; Indentation
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-block-padding 2)

  ;; Highlighting & Behavior
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-auto-pairing nil) ; Let electric-pair handle it
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-css-colorization t)

  ;; Faces (Colors)
  (set-face-attribute 'web-mode-comment-face nil :foreground "#6d6d6d")
  (set-face-attribute 'web-mode-doctype-face nil :foreground "Blue")
  (set-face-attribute 'web-mode-html-tag-face nil :foreground "#00cc66")
  (set-face-attribute 'web-mode-html-attr-value-face nil :foreground "#66cc00")
  (set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#bdbdbd"))

;; LaTeX (YaTeX)
(use-package yatex
  :ensure t
  :mode ("\\.tex\\'" . yatex-mode)
  :config
  (setq tex-command "platex2pdf")
  (setq dvi2-command (if (eq system-type 'darwin) "open -a Preview" "evince"))
  (add-hook 'yatex-mode-hook (lambda () (setq auto-fill-function nil))))

;; Simple HTTPD (Kept but cleaned)
(use-package simple-httpd
  :config
  (setq httpd-port 8080))
  ;; Note: Set httpd-root manually via M-x customize-variable if needed,
  ;; avoiding hardcoded paths in init.el for portability.

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

 ;; Rust
(use-package rust-mode
  :mode "\\.rs\\'"
  :config
  (setq rust-format-on-save t)) ; Auto-format on save

;; Cargo Integration
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

;; LSP (Language Server Protocol)
;; Core LSP features: completion, defintions, and errors
(use-package lsp-mode
  :init
  ;; Performance tunning (Recommended settings)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  (setq lsp-idle-delay 0.500)
  :hook
  ((rust-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

;; LSP UI (popups, documentation, etc.)
(use-package lsp-ui
  :commands lsp-ui-mode)
