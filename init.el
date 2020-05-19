;;;;; Install packages
(package-initialize)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))
(add-to-list 'load-path "~/.emacs.d/elisp/")

(defvar my-package-list
  '(anzu company cmake-mode dockerfile-mode ini-mode js2-mode json-mode
    markdown-mode multi-term undo-tree volatile-highlights
    web-mode yaml-mode)
  "packages to be installed")
(require 'package)
(setq package-pinned-packages
      '((anzu . "melpa")
        (company . "melpa")
        (cmake-mode . "melpa")
        (dockerfile-mode . "melpa")
        (ini-mode . "melpa")
        (js2-mode . "melpa")
        (json-mode . "melpa")
        (markdown-mode . "melpa")
        (multi-term . "melpa")
        (undo-tree . "gnu")
        (volatile-highlights . "melpa")
        (web-mode . "melpa")
        (yaml-mode . "melpa")))

(let ((package-refreshed nil))
  (dolist (pkg my-package-list)
    (unless (package-installed-p pkg)
      (when (null package-refreshed)
        (package-refresh-contents)
        (setq package-refreshed t))
      (package-install pkg))))

;;;;; Character code
(prefer-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;;;;; Basic config
(load-theme 'misterioso t)
(column-number-mode t)
(tool-bar-mode 0)
(menu-bar-mode 0)
(setq make-backup-files nil)
(setq auto-save-default nil) 
(setq history-length 1024)
(set-locale-environment nil) ;Don't use location-dependent setting

(defun other-window-or-split ()
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(define-key global-map (kbd "C-t") 'other-window-or-split)
(define-key global-map (kbd "C-i") 'scroll-down-command)

(require 'anzu)
(global-anzu-mode t)
(require 'undo-tree)
(global-undo-tree-mode t)
(global-set-key (kbd "M-/") 'undo-tree-redo)
(require 'volatile-highlights)
(volatile-highlights-mode t)

;;;;; Auto-completion
(require 'company)
(global-company-mode)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 3)
(setq company-selection-wrap-around t)
(global-set-key (kbd "C-M-i") 'company-complete)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
(define-key company-search-map (kbd "C-n") 'company-select-next)
(define-key company-search-map (kbd "C-p") 'company-select-previous)
(define-key company-active-map (kbd "C-s") 'company-filter-candidates)
(define-key company-active-map (kbd "C-M-i") 'company-complete-selection)
(define-key company-active-map [tab] 'company-complete-selection)

;;;;; Tab and whitespace
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)
(load "whitespace")
(global-whitespace-mode t)
(setq whitespace-style '(tab-mark))
(setq-default show-trailing-whitespace t)

;;;;; Bracket
(setq show-paren-style 'mixed)
(show-paren-mode t) ;Highlight a pair of bracket
(electric-pair-mode t) ;Close bracket automatically
(set-face-attribute 'show-paren-match nil :background "#5d5d5d")

;;;;; C, C++
(add-to-list 'auto-mode-alist '("\\.cu?\\'" . c++-mode))
(add-hook
  'c-mode-common-hook
  (lambda ()
    (c-set-style "bsd")
    (setq c-basic-offset 2)
    (setq c-tab-always-indent t)
    (setq tab-width 2)
    (setq indent-tabs-mode nil) ; Use space for indent, not tab
    (c-set-offset 'innamespace 0)
    (c-set-offset 'arglist-close 0)
    (define-key c-mode-base-map "\C-m" 'newline-and-indent)
  )
)

;;;;; Tex
(setq auto-mode-alist
  (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)

(setq tex-command "platex2pdf")
(cond
  ((eq system-type 'gnu/linux)
    (setq dvi2-command "evince"))
  ((eq system-type 'darwin)
    (setq dvi2-command "open -a Preview")))
(add-hook 'yatex-mode-hook '(lambda () (setq auto-fill-function nil)))

;;;;; HTML, CSS
;; M-x package-list-packages
;; package-install
;; web-mode
;; If need to support template, M-x -> web-mode-set-engine -> jinja2
(load "web-mode")
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.scss?\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-auto-paring t)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-css-colorization t)
  ;(when '("\\.html?") (web-mode-set-engine "jinja2"))
  (set-face-attribute 'web-mode-comment-face nil :foreground "#6d6d6d")
  (set-face-attribute 'web-mode-doctype-face nil :foreground "Blue")
  (set-face-attribute 'web-mode-html-tag-face nil :foreground "#00cc66")
  (set-face-attribute 'web-mode-html-attr-value-face nil :foreground "#66cc00")
  ;(set-face-attribute 'web-mode-html-attr-name-face nil :foreground "#5d5d5d")
)
(add-hook 'web-mode-hook 'my-web-mode-hook)

;;;;; JavaScript
(load "js2-mode")
(add-to-list 'auto-mode-alist '("\\.js?\\'" . js2-mode))
(setq js2-basic-offset 2)

;;;;; Json
(load "json-mode")
(add-to-list 'auto-mode-alist '("\\.json?\\'" . json-mode))

;;;;; Yaml
(load "yaml-mode")
(add-to-list 'auto-mode-alist '("\\.yaml?\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yml?\\'" . yaml-mode))

;;;;; INI
(load "ini-mode")
(add-to-list 'auto-mode-alist '("\\.ini?\\'" . ini-mode))
(add-to-list 'auto-mode-alist '("\\.in?\\'" . ini-mode))

;;;;; Dockerfile
(load "dockerfile-mode")
(add-to-list 'auto-mode-alist '("\\Dockerfile\\'" . dockerfile-mode))

;;;;; Terminal
(require 'multi-term)
(setq multi-term-program "/bin/bash")

(add-hook 'term-mode-hook
  (lambda ()
    (term-set-escape-char ?\C-t)
    (define-key term-raw-map "\C-t" 'next-multiframe-window)
    (define-key term-raw-map "\M-y" 'yank-pop)
    (define-key term-raw-map "\M-w" 'kill-ring-save)))

;;;;; The follows are automatically generated.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (js2-mode yaml-mode web-mode json-mode dockerfile-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
