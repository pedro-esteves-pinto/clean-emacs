
(global-set-key (kbd "M-x") 'counsel-M-x)

(evil-leader/set-leader "<SPC>")


(evil-leader/set-key
  "<SPC>" 'consult-projectile
  "b" 'pp-compile
  "f" 'c-mark-function
  "v" 'ff-find-other-file
  ";" 'comment-dwim
  "w" 'ace-window
  "W" 'ace-swap-window
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
(defun my-vterm-setup-windmove ()
  (define-key vterm-mode-map (kbd "S-<left>")  'windmove-left)
  (define-key vterm-mode-map (kbd "S-<right>") 'windmove-right)
  (define-key vterm-mode-map (kbd "S-<up>")    'windmove-up)
  (define-key vterm-mode-map (kbd "S-<down>")  'windmove-down))

(add-hook 'vterm-mode-hook #'my-vterm-setup-windmove)

(require 'pp-compilation)

(defun pp-c++-keybindings ()
  "Set C++ specific keybindings"
  (interactive)
  (define-key c-mode-base-map (kbd "M-e") 'pp-next-error)
  (define-key c-mode-base-map (kbd "M-E") 'pp-previous-error))

;(add-hook 'c++-mode-hook (lambda () (pp-c++-keybindings)))
