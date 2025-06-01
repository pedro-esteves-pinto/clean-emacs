(defun pp-compile-finish (buffer outstr)
  (if (string-match "finished" outstr)
      (delete-windows-on buffer)))

(add-hook 'compilation-finish-functions 'pp-compile-finish)

(defadvice compilation-start
    (around inhibit-display
	    (command &optional mode name-function highlight-regexp))
  (if (not (string-match "^\\(find\\|grep\\|ag\\)" command))
      (flet ((display-buffer)
	     (set-window-point)
	     (goto-char))
	(fset 'display-buffer 'ignore)
	(fset 'goto-char 'ignore)
	(fset 'set-window-point 'ignore)
	(save-window-excursion
	  ad-do-it))
    ad-do-it)) 

(defun pp-compile (cmd)
  (ad-activate 'compilation-start)
  (compile cmd)
  (if (not (get-buffer-window "*compilation*"))
      (set-window-buffer (split-window (frame-root-window) -15) "*compilation*"))
  (ad-deactivate 'compilation-start))

(defun pp-next-error () 
  "Move point to next error and highlight it"
  (interactive)
  (next-error)
  (with-current-buffer "*compilation*"
    (message (thing-at-point 'line t))))

(defun pp-previous-error () 
  "Move point to previous error and highlight it"
  (interactive)
  (previous-error)
  (with-current-buffer "*compilation*"
    (message (thing-at-point 'line t))))

(defun pp-ansi-colorize-buffer ()
  (let ((buffer-read-only nil))
    (ansi-color-apply-on-region (point-min) (point-max))))

(add-hook 'compilation-filter-hook 'pp-ansi-colorize-buffer)

(defun pp-compilation-mode-hook ()
  (setq compilation-scroll-output 'first-error) 
  (setq compilation-ask-about-save nil)
  (setq compilation-always-kill t)
  (setq truncate-lines nil)
  (setq truncate-partial-width-windows nil))

(add-hook 'compilation-mode-hook 'pp-compilation-mode-hook)

