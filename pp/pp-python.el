(provide 'pp-python)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 "pyright-langserver" "--stdio")))

(defun pp-my-python-setup ()
  "Changes to the default Python setup."
  (interactive)
  (setq indent-tabs-mode nil)
  (setq python-indent-offset 4)
  (modify-syntax-entry ?_ "w")
  (eglot-ensure)
  (when (boundp 'flymake-indicator-type)
    (setq-local flymake-indicator-type (if (display-graphic-p) 'fringes nil)))
  (when (boundp 'flymake-show-diagnostics-at-end-of-line)
    (setq-local flymake-show-diagnostics-at-end-of-line nil))
  (eldoc-mode 1)
  (setq-local eldoc-display-functions '(eldoc-display-in-echo-area))
  (when (fboundp 'flymake-eldoc-function)
    (add-hook 'eldoc-documentation-functions #'flymake-eldoc-function nil t))
  (display-line-numbers-mode))

(add-hook 'python-mode-hook #'pp-my-python-setup)
(add-hook 'python-ts-mode-hook #'pp-my-python-setup)
