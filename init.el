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

(load "pp-misc")
(load "pp-mac")
(load "pp-buffer-management")
(load "pp-evil")
(load "pp-compilation")
(load "pp-dired")
(load "pp-cpp")
(load "pp-keybindings")
