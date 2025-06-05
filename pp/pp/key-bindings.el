
(global-set-key (kbd "M-x") 'counsel-M-x)

(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
  "<SPC>" 'consult-projectile
  "b" 'pp-compile
  ";" 'comment-dwim
  "m" 'magit-status)

(evil-leader/set-key
  "ld" 'xref-find-definitions
  "lD" 'xref-find-definitions-other-window
  "lr" 'xref-find-references
  "la" 'eglot-code-actions
  "lR" 'eglot-rename
  "lh" 'eldoc-print-current-symbol-info
  "lf" 'eglot-format
  "lt" 'eglot-find-typeDefinition
  )

(global-set-key (read-kbd-macro "M-SPC") 'dabbrev-expand)
(global-set-key (kbd "<f12>") 'consult-projectile)
(global-set-key (kbd "<f6>") 'display-line-numbers-mode)
(global-set-key (kbd "M-e") 'pp-next-error)
(global-set-key (kbd "M-E") 'pp-previous-error)

(windmove-default-keybindings)
