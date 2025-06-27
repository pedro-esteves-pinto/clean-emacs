
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

(use-package which-key
  :config (which-key-mode))

(use-package eglot
  :config
  (setq eglot-ignored-server-capabilities '(:hoverProvider :signatureHelpProvider :inlayHintProvider)))

(use-package magit)
(use-package vterm
  :config
  (add-hook 'vterm-mode-hook
	    (lambda ()
	      (setq-local global-hl-line-mode nil) ; Disable global hl-line in vterm
	      (hl-line-mode -1)))                 ; Disable buffer-local hl-line
  )

(setq straight-built-in-pseudo-packages '(org))
(straight-use-package 'org)
(use-package ace-window)


(use-package org
  :straight t
  :config
  (setq org-startup-indented t
        org-hide-leading-stars t
        org-ellipsis "…"))

(straight-use-package 'org-modern)


(load "pp-misc")
(load "pp-mac")
(load "pp-buffer-management")
(load "pp-evil")
(load "pp-compilation")
(load "pp-dired")
(load "pp-cpp")
(load "pp-keybindings")
