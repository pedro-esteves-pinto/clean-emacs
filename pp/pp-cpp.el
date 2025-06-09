(provide 'pp-cpp-utils)

(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cc\\'" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.ipp\\'" . c++-mode) auto-mode-alist))

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
  ;(company-mode 1)
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
