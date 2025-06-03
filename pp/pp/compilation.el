(require 'cl-lib)

(defun pp-compile-finish (buffer outstr)
  "Delete compilation window if compilation finished successfully."
  (when (string-match "finished" outstr)
    (delete-windows-on buffer)))

(add-hook 'compilation-finish-functions #'pp-compile-finish)

(defun pp-compile ()
  "Run compile in projectile root, suppress showing compilation buffer unless it fails."
  (interactive)
  (let ((default-directory (projectile-project-root)))
    ;; Temporarily override display-buffer to suppress popup
    (cl-letf (((symbol-function 'display-buffer) #'ignore)
              ((symbol-function 'goto-char) #'ignore)
              ((symbol-function 'set-window-point) #'ignore))
      (let ((compilation-buffer (compile compile-command)))
	(run-at-time
	 "0.1 sec" nil
	 (lambda (buf)
	   (unless (get-buffer-window buf)
	     (set-window-buffer (split-window (frame-root-window) -15 'below)
				buf)))
	 compilation-buffer)))))

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

