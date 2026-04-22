
;; restore slow settings at end of startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000
                  gc-cons-percentage 0.1
                  file-name-handler-alist file-name-handler-alist-original)))

(add-to-list 'load-path (expand-file-name "pp" user-emacs-directory))

(load "pp-straight")
(load "pp-sql")

(use-package doom-themes
  :config (load-theme 'doom-tokyo-night t))

;; Dim non-selected windows.
(use-package dimmer
  :config
  (setq dimmer-fraction 0.50
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

  ;; Dim inactive vterm windows using overlays.
  ;; face-remap can't affect vterm because vterm sets explicit face
  ;; text-properties on each character.  Overlay faces take precedence
  ;; over text-property faces, so a window-specific overlay works.
  (defvar-local pp/vterm-dim-overlays nil
    "Window-specific overlays for dimming inactive vterm buffers.")

  (defun pp/vterm-dim-inactive ()
    "Dim/undim vterm buffers based on whether their window is selected."
    (dolist (win (window-list))
      (with-current-buffer (window-buffer win)
        (when (derived-mode-p 'vterm-mode)
          ;; Remove stale overlay for this window
          (setq pp/vterm-dim-overlays
                (cl-remove-if (lambda (ov)
                                (when (eq (overlay-get ov 'window) win)
                                  (delete-overlay ov) t))
                              pp/vterm-dim-overlays))
          ;; Create dim overlay for inactive windows
          (unless (eq win (selected-window))
            (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
              (overlay-put ov 'window win)
              (overlay-put ov 'face '(:foreground "#666680"))
              (overlay-put ov 'priority 9999)
              (push ov pp/vterm-dim-overlays)))))))

  (add-hook 'window-selection-change-functions
            (lambda (_frame) (pp/vterm-dim-inactive)))
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
  (setq markdown-fontify-code-blocks-natively t
        markdown-hide-markup t)
  (when (executable-find "pandoc")
    (setq markdown-command "pandoc -f markdown -t html5 --standalone")))
(use-package org
  :straight t
  :config
  (setq org-directory "~/Dropbox/notes"
        org-startup-indented t
        org-hide-leading-stars t
        org-ellipsis "…"
        org-return-follows-link t)
  (setq org-confirm-babel-evaluate nil)
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
(load "pp-python")
(load "pp-journal")
(load "pp-keybindings")
