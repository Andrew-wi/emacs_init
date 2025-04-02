; configuration file/customization for emacs. Andrew Winnicki, 2025.

;; theme + make things look nicer
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; font
(set-face-attribute 'default nil :font "DejaVu Sans Mono Book" :height 120)

(load-theme 'wombat)

;; adding package installation
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                       '("org" . "https://orgmode.org/elpa/")))
(package-initialize)

;; on a fresh install, pull all the archives. Otherwise, ignore
(unless package-archive-contents
  (package-refresh-contents))

;; use-package
(require 'use-package)
(setq use-package-always-ensure t)

;; set up beacon cursor
(use-package beacon)
(beacon-mode 1)

;; which-key -- pops up a buffer after a 1s delay showing which keys avail
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

;; lsp-mode
(use-package lsp-mode
  :init)
;;(add-hook 'python-mode-hook #'lsp)
(setq gc-cons-threshold 100000000) ;; setting to 100mb
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; python-mode
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  (python-shell-interpreter "python3")
  (dap-python-executable "python3")
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

;; dap-mode
(use-package dap-mode
  :after lsp-mode
  :hook ((python-mode . dap-ui-mode) (python-mode . dap-mode))
  :config
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy))

;; virtual environment support
(use-package pyvenv
  :config
  (pyvenv-mode 1))

;; flycheck for linting
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; swiper; like better search. But we'll use company-mode in lsp-mode
(use-package swiper :ensure t)

;; ivy mode for better code completion when finding/commands etc
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; company mode, for use in lsp-mode. Improved code completion
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

;; treemacs
(use-package lsp-treemacs
  :after lsp)

;; projectile
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Desktop/projects")
    (setq projectile-project-search-path '("~/Desktop/projects")))
  (setq projectile-switch-project-action #'projectile-dired))

;; magit
(use-package magit)

;; building pdf-tools
(use-package pdf-tools)
(pdf-tools-install)

;; turn on line wrapping globally
(global-visual-line-mode t)

;; display line numbers, columns globally except in pdf-viewer
(global-display-line-numbers-mode 1)
(setq column-number-mode t)
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

;; org-mode
(use-package org
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  
  ;; Must do this so the agenda knows where to look for my files
  (setq org-agenda-files
	'("~/org/todos.org"
	  "~/org/work-log.org"
	  "~/org/habits.org"
          "~/org/active_courses"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")))

  (setq org-todo-keyword-faces
        '(("TODO" . (:foreground "GoldenRod" :weight bold))
          ("NEXT" . (:foreground "Cyan" :background "DarkGreen" :weight bold))
          ("DONE" . (:foreground "LimeGreen" :weight bold))))

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@academics" . ?A)
       ("notes" . ?n)
       ("idea" . ?i)
       ("readings" . ?r)))

  ;; Tag colors
  (setq org-tag-faces
      '(
        ("@academics"  . (:foreground "mediumPurple1" :weight bold))
        ("notes"   . (:foreground "royalblue1"    :weight bold))
        ("idea"  . (:foreground "forest green"  :weight bold))
        ("readings"        . (:foreground "sienna"        :weight bold))
        ))
    
  (setq org-refile-targets
    '(("todos.org" :maxlevel . 1)
      ("work-log.org" :maxlevel . 1)))

    ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  
  ;; >>> capture template, for journals. From James Stoup guide to emacs. >>>
  ;; work log capture template
  (setq org-capture-templates
      '(
	("j" "Work Log Entry"
	 entry (file+datetree "~/org/work-log.org")
	 "* %?"
	 :empty-lines 0)
     
        ("g" "General To-Do"
         entry (file+headline "~/org/todos.org" "General Tasks")
         "* TODO [#B] %?\n:Created: %T\n "
         :empty-lines 0)
	))

  ;; <<< end configurations taken after James Stoup. <<<

  (define-key global-map (kbd "C-c a")
	      (lambda () (interactive) (org-agenda)))

  (define-key global-map (kbd "C-c c")
	      (lambda () (interactive) (org-capture)))
  )

;; make indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)

;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; make bullets look nicer
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))

;; emacs window should always show my system-name and the full path of the buffer, and in the minibuffer (second customization)
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
        '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))
(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))
(global-set-key [C-f1] 'show-file-name) ; Or any other key you want

;; add scroll bar to the right
(setq scroll-bar-mode 'right)
(scroll-bar-mode 1)

;; latex with AuCTeX
(use-package auctex
  :ensure t
  :config
  (setq TeX-source-correlate-mode t)
  (eval-after-load "tex"
  '(define-key TeX-source-correlate-map [C-down-mouse-1]
               #'TeX-view-mouse))
  )
;;(add-hook 'LaTeX-mode-hook #'LaTeX-math-mode)

(use-package reftex)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

;; adding auctex new environments
(add-hook 'LaTeX-mode-hook
   (lambda ()
     (LaTeX-add-environments
      '("definition" LaTeX-env-label)
      '("theorem" LaTeX-env-label)
      '("axiom" LaTeX-env-label))))

;; ;; open PDFs rendered with AUCTeX in pdf-tools
;; (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
;;       TeX-source-correlate-start-server t)
;; (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

;; add cdlatex functionality for intelligent TAB switching, ^ and _
(use-package cdlatex)
(add-hook 'LaTeX-mode-hook #'turn-on-cdlatex)

;; >>> begin automatically generated code <<<
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ede-project-directories
   '("/home/blank-v1/Desktop/projects/myproject/include" "/home/blank-v1/Desktop/projects/myproject/src" "/home/blank-v1/Desktop/projects/myproject"))
 '(package-archives
   '(("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/")
     ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
 '(package-selected-packages
   '(beacon org-bullets cdlatex flycheck magit which-key projectile company swiper ivy pyenv-mode dap-mode lsp-mode ##)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; <<< end automatically generated code <<<
