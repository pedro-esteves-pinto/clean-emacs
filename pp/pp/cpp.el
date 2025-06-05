(provide 'pp-cpp-utils)

(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cc\\'" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.ipp\\'" . c++-mode) auto-mode-alist))

(defun pp-next-cpp-extension (extension)
  (cond
   ((string= extension "h") "H")
   ((string= extension "H") "cc")
   ((string= extension "cc") "cpp")
   ((string= extension "cpp") "C")
   ((string= extension "C") "h")))

(defun pp-cpp-extension (cpp-path)
  (let ((stem-end (string-match "\\.\\(cpp\\|C\\|\\H|cc\\|h\\)$" cpp-path)))
    (if stem-end
	(substring cpp-path (+ 1 stem-end)))))

(defun pp-cpp-stem (cpp-path)
  (let ((extension (pp-cpp-extension cpp-path)))
    (if extension
	(substring cpp-path 0
		   (- (length cpp-path) (length extension) 1)))))

(defun pp-find-first-related-cpp-path (cpp-path &optional last-extension-tried)
  (let* ((extension (pp-cpp-extension cpp-path))
	 (stem (pp-cpp-stem cpp-path))
	 (extension-to-try (pp-next-cpp-extension (if last-extension-tried
						      last-extension-tried
						    extension))))
    (message extension)
    (message stem)
    (message extension-to-try)
    
    (if (and extension-to-try
	     (not (string= extension-to-try extension)))
	(let ((candidate (concat stem "." extension-to-try)))
	  (if (or (get-file-buffer candidate)
		  (file-exists-p candidate))
	      candidate
	    (pp-find-first-related-cpp-path cpp-path extension-to-try))))))

(defun pp-cpp-goto-related-file()
  "Cycle between .h,.H,cc,cpp,C files with the same stem in their names"
  (interactive)
  (message "--------------------------------------------------------------------------------")
  (let ((related-file (pp-find-first-related-cpp-path buffer-file-name)))
    (if related-file
	(if (get-file-buffer related-file)
	    (switch-to-buffer (get-file-buffer related-file))
	  (find-file related-file)))))

(defun pp-cpp-insert-file-name-stem ()
  "Insert in the current buffer the result of c++-get-file-name-stem"
  (interactive)
  (if (pp-cpp-stem (buffer-file-name))
      (insert (file-name-nondirectory (pp-cpp-stem (buffer-file-name))))
    (message "Not a C++ file")))

(defun pp-my-c++-setup ()
  "changes to the default C++ setup"
  (interactive)
  (c-set-style "stroustrup")
  (modify-syntax-entry ?_ "w")
  (setq c-basic-offset 2) ; tab size = 2
  (c-set-offset 'innamespace 2) ; Namespace indentation is 0
  (c-set-offset 'inline-open 0 nil)
  (setq indent-tabs-mode nil) ; Use spaces not tabs when indenting
  (eglot-ensure)
  (display-line-numbers-mode)
  (company-mode 1)
  (font-lock-add-keywords 'c++-mode
			  '(("foreach" . font-lock-keyword-face)
			    ("nullptr" . font-lock-keyword-face)
			    ("co_await" . font-lock-keyword-face)
			    ("co_resume" . font-lock-keyword-face)
			    ("co_return" . font-lock-keyword-face)
			    ("co_yeld" . font-lock-keyword-face)
			    ("constexpr" . font-lock-keyword-face)
			    ("override" . font-lock-keyword-face)
			    ))
  )

(add-hook 'c++-mode-hook (lambda () (pp-my-c++-setup)))
