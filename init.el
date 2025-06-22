
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

(use-package org
  :straight t
  :config
  (setq org-startup-indented t
        org-hide-leading-stars t
        org-ellipsis "…"))

(straight-use-package 'org-modern)

(use-package org-modern
  :straight t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿")   ; Example pretty bullets
        org-modern-hide-stars nil
        org-modern-table nil))

(load "pp-misc")
(load "pp-mac")
(load "pp-buffer-management")
(load "pp-evil")
(load "pp-compilation")
(load "pp-dired")
(load "pp-cpp")
(load "pp-keybindings")
