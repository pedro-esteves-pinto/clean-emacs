
;; restore slow settings at end of startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000
                  gc-cons-percentage 0.1
                  file-name-handler-alist file-name-handler-alist-original)))

(add-to-list 'load-path (expand-file-name "pp" user-emacs-directory))


(load "pp-straight")

(use-package doom-themes
  :config (load-theme 'doom-one t))

;; Dim non-selected windows.
(use-package dimmer
  :config
  (setq dimmer-fraction 0.35
        dimmer-adjustment-mode :foreground)
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-mode 1))

(use-package which-key
  :config (which-key-mode))

(use-package eglot
  :config
  (setq eglot-ignored-server-capabilities '(:hoverProvider :signatureHelpProvider :inlayHintProvider :documentHighlightProvider :semanticTokensProvider)))

(use-package magit :defer t)
(use-package vterm
  :config
  (add-hook 'vterm-mode-hook
	    (lambda ()
	      (setq-local global-hl-line-mode nil) ; Disable global hl-line in vterm
	      (hl-line-mode -1)))                 ; Disable buffer-local hl-line
  )

(straight-use-package 'org)
(use-package ace-window :defer t)

(use-package rust-mode :defer t)

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook ((markdown-mode . visual-line-mode)
         (gfm-mode . visual-line-mode))
  :init
  (setq markdown-fontify-code-blocks-natively t)
  (when (executable-find "pandoc")
    (setq markdown-command "pandoc")))
(use-package org
  :straight t
  :config
  (setq org-directory "~/Dropbox/notes"
        org-startup-indented t
        org-hide-leading-stars t
        org-ellipsis "…")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t))))

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package org-roam
  :defer t
  :custom
  (org-roam-directory (expand-file-name "roam" org-directory))
  (org-roam-completion-everywhere t)
  :config
  (org-roam-db-autosync-mode))

(load "pp-misc")
(load "pp-mac")
(load "pp-buffer-management")
(load "pp-evil")
(load "pp-compilation")
(load "pp-dired")
(load "pp-cpp")
(load "pp-journal")
(load "pp-keybindings")
