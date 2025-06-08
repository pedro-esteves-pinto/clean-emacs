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
;; Add a window margin when scrolling
(setq scroll-margin 1) 
;; word wrap on word boundaries
(global-visual-line-mode t) 
;; no more yes or no BS
(defalias 'yes-or-no-p 'y-or-n-p) 

;; move customize stuff to its own file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
