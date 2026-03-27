(provide 'pp-cpp)

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
  ;; Eglot uses Flymake for diagnostics.
  ;; Prefer fringe indicators in GUI (avoid "!" in the margin) and disable
  ;; indicators entirely in TTY.
  (when (boundp 'flymake-indicator-type)
    (setq-local flymake-indicator-type (if (display-graphic-p) 'fringes nil)))
  ;; Avoid end-of-line diagnostic overlays.
  (when (boundp 'flymake-show-diagnostics-at-end-of-line)
    (setq-local flymake-show-diagnostics-at-end-of-line nil))
  ;; Show diagnostics at point in the minibuffer (echo area).
  (eldoc-mode 1)
  (setq-local eldoc-display-functions '(eldoc-display-in-echo-area))
  (when (fboundp 'flymake-eldoc-function)
    (add-hook 'eldoc-documentation-functions #'flymake-eldoc-function nil t))
  (display-line-numbers-mode)
  ;(company-mode 1)
  (font-lock-add-keywords 'c++-mode
			  '(("foreach" . font-lock-keyword-face)
			    ("co_await" . font-lock-keyword-face)
			    ("co_resume" . font-lock-keyword-face)
			    ("co_return" . font-lock-keyword-face)
			    ("co_yield" . font-lock-keyword-face)
			    			    ))
  )

(add-hook 'c++-mode-hook (lambda () (pp-my-c++-setup)))
