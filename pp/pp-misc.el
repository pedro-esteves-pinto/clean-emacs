(setq ring-bell-function 'ignore)
(setq visible-bell nil)
(blink-cursor-mode 0)
(setq make-backup-files nil)
(column-number-mode t)
(global-hl-line-mode)

(winner-mode 1);; don't bring up the stupid file loader GUI
(setq use-file-dialog nil) 
;; Disable re-center when scrolling
(setq scroll-conservatively 9999) 
(setq scroll-margin 1) 
(global-visual-line-mode t) 
(defalias 'yes-or-no-p 'y-or-n-p) 
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(global-hl-line-mode)
(setq window-combination-resize t) 

(xterm-mouse-mode 1)
(global-auto-revert-mode 1)
