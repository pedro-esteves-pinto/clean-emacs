;; restore slow settings at end of startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold 800000
                  gc-cons-percentage 0.1
                  file-name-handler-alist file-name-handler-alist-original)))

(add-to-list 'load-path (expand-file-name "pp" user-emacs-directory))

(load "config/straight")
(load "config/misc")
(load "config/mac")
(load "config/buffer-management")

(use-package doom-themes
  :config (load-theme 'doom-one t))

;; Evil mode configuration (Vim keybindings)
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package which-key
  :config (which-key-mode))


(use-package magit)

(global-set-key (kbd "C-x b") #'consult-projectile)


