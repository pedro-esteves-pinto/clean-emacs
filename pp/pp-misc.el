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
(setq window-combination-resize t) 

(xterm-mouse-mode 1)
(global-auto-revert-mode 1)

(setq-default mode-line-format (list
				" "
				mode-line-modified " "
				" %e %b "
				" l:%l c:%c %p"
				'(:eval (cond
					 (( eq evil-state 'visual) "V")
					 (( eq evil-state 'normal) "N")
					 (( eq evil-state 'insert) "I")
					 (t "*")))
				))

;; Set smaller font on laptop displays (detected via eDP connector in sysfs).
;; Done in after-init-hook so it runs after themes have loaded and reset faces.
(when (cl-some (lambda (dir)
                 (string= (string-trim
                           (with-temp-buffer
                             (insert-file-contents (expand-file-name "status" dir))
                             (buffer-string)))
                          "connected"))
               (directory-files "/sys/class/drm/" t "eDP"))
  (add-hook 'after-init-hook
            (lambda () (set-face-attribute 'default nil :height 90))))

(provide 'pp-misc)
