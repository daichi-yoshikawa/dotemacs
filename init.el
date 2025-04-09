;;;;; Install packages
(setq package-archives
  '(("gnu" . "https://elpa.gnu.org/packages/")
    ("melpa" . "https://melpa.org/packages/")
    ("org" . "https://orgmode.org/elpa/")))
(package-initialize)

(defvar my-package-list
  '(anzu
    company
    cmake-mode
    dockerfile-mode
    ini-mode
    flycheck
    js2-mode
    json-mode
    markdown-mode
    multi-term
    neotree
    simple-httpd
    stylus-mode
    sws-mode
    tide
    typescript-mode
    undo-fu
    volatile-highlights
    vue-mode
    web-mode
    yaml-mode)
  "packages to be installed")
(require 'package)
(setq package-pinned-packages
      '((anzu . "melpa")
        (company . "melpa")
        (cmake-mode . "melpa")
        (dockerfile-mode . "melpa")
        (flycheck . "melpa")
        (ini-mode . "melpa")
        (js2-mode . "melpa")
        (json-mode . "melpa")
        (markdown-mode . "melpa")
        (multi-term . "melpa")
        (neotree . "melpa")
        (simple-httpd . "melpa")
        (stylus-mode . "melpa")
        (sws-mode . "melpa")
        (tide . "melpa")
        (typescript-mode . "melpa")
        (undo-fu . "melpa")
        (volatile-highlights . "melpa")
        (vue-mode . "melpa")
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
(setq create-lockfiles nil)
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

;;;;; Undo, redo
(require 'undo-fu)

(global-unset-key (kbd "C-z")) ; disable suspend button
(global-unset-key (kbd "C-x C-z")) ; disable suspend button

(global-set-key (kbd "C-z") 'undo-fu-only-undo)
(global-set-key (kbd "C-/") 'undo-fu-only-redo)

;;;;; Disable C-[ to close split window without disabling M-x.
(defun my-keyboard-escape-quit ()
  "An alternative to `keyboard-escape-quit' that doesn't close windows."
  (interactive)
  (let (orig-buf (current-buffer))
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (if (and buffer-file-name (buffer-modified-p))
          (message "Modified file: %s" (buffer-file-name))
        (when (and (get-buffer-process buf) (not (eq buf orig-buf)))
          (set-process-query-on-exit-flag (get-buffer-process buf) nil)
          (kill-buffer buf))))))

(require 'anzu)
(global-anzu-mode t)

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
(define-key key-translation-map (kbd "C-]") (kbd "<escape>"))
(define-key key-translation-map (kbd "C-[") nil)

;;;;; Tab and whitespace
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq indent-line-function 'insert-tab)
(setq c-basic-offset 2)
(load "whitespace")
(global-whitespace-mode t)
(setq whitespace-style '(tab-mark))
(setq-default show-trailing-whitespace t)

;;;;; Bracket
(setq show-paren-style 'mixed)
(show-paren-mode t) ;Highlight a pair of bracket
(electric-pair-mode t) ;Close bracket automatically
(set-face-attribute 'show-paren-match nil :background "#5d5d5d")

;;;;; Directory tree
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(setq neo-show-hidden-files t)
(setq neo-smart-open t)

;;;;; Python
(setq-default python-indent 2)
(setq-default python-indent-offset 2)

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
    (c-set-offset 'innamespace 2) ; Indent namespaces
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

;;;;; Web server
;; Usage :
;; 1. M-x customize-option
;; 2. Customize variable: httpd-root
;; 3. Set path to desired root dir.
;; 4. M-x httpd-start
;; 5. M-x httpd-stop
(require 'simple-httpd)
(setq httpd-port 8080)

;;;;; HTML, CSS
;; M-x package-list-packages
;; package-install
;; multi-web-mode
;; If need to support template, M-x -> web-mode-set-engine -> jinja2
;; web-modeの読み込みとファイル関連付け
(require 'web-mode)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(add-hook 'web-mode-hook
  (lambda ()
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset 2)
    (setq web-mode-code-indent-offset 2)
    (setq web-mode-script-padding 2)
    (setq web-mode-style-padding 2)
    (setq web-mode-block-padding 2)
    (setq css-indent-level 2)

    (setq web-mode-enable-current-element-highlight t)
    (setq web-mode-enable-auto-pairing t)
    (setq web-mode-enable-auto-closing t)
    (setq web-mode-enable-css-colorization t)

    (set-face-attribute 'web-mode-comment-face nil
                        :foreground "#6d6d6d")
    (set-face-attribute 'web-mode-doctype-face nil
                        :foreground "Blue")
    (set-face-attribute 'web-mode-html-tag-face nil
                        :foreground "#00cc66")
    (set-face-attribute 'web-mode-html-attr-value-face nil
                        :foreground "#66cc00")
    (set-face-attribute 'web-mode-html-attr-name-face nil
                        :foreground "#bdbdbd")
  ))

;;;;; JavaScript
(setq js-indent-level 2)

;;;;; Json
(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json?\\'" . json-mode))

;;;;; Yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yaml?\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yml?\\'" . yaml-mode))

;;;;; INI
(require 'ini-mode)
(add-to-list 'auto-mode-alist '("\\.ini?\\'" . ini-mode))
(add-to-list 'auto-mode-alist '("\\.in?\\'" . ini-mode))

;;;;; Dockerfile
(require 'dockerfile-mode)
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
 '(httpd-root "~/Work/genki/app")
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;;; Vue.js
(require 'vue-mode)
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-mode))

(require 'stylus-mode)
(add-to-list 'vue-mode-hook
  (lambda ()
    (when (equal major-mode 'vue-mode)
      (let ((tag (plist-get (text-properties-at (point)) 'tag-beg)))
        (when (and tag (string= tag "style"))
          (stylus-mode))))))

;;;;; Typescript
(require 'typescript-mode)
(add-to-list 'auto-mode-alist '("\\.ts?\\'" . typescript-mode))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; configure javascript-tide checker to run after your default javascript checker
  (flycheck-add-next-checker 'typescript-tide 'javascript-eslint)
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)
