
(evil-leader/set-leader "<SPC>")


(evil-leader/set-key
  "<SPC>" 'consult-projectile
  "b" 'pp-compile
  "g" 'revert-buffer
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
  "lt" 'eglot-find-typeDefinition)

;; org-roam keybindings
(evil-leader/set-key
  "nf" 'org-roam-node-find
  "ni" 'org-roam-node-insert
  "nc" 'org-roam-capture
  "nl" 'org-roam-buffer-toggle
  "nd" 'org-roam-dailies-goto-today
  "nD" 'org-roam-dailies-goto-date)

(global-set-key (read-kbd-macro "M-SPC") 'dabbrev-expand)
(global-set-key (kbd "<f12>") 'consult-projectile)
(global-set-key (kbd "<f6>") 'display-line-numbers-mode)
(global-set-key (kbd "M-e") 'pp-next-error)
(global-set-key (kbd "M-E") 'pp-previous-error)

(defun my-vterm-goto (n)
  "Switch to vterm-N, creating it if needed."
  (let* ((name (format "vterm-%d" n))
         (buf (get-buffer name)))
    (if (buffer-live-p buf)
        (pop-to-buffer buf)
      (let ((vterm-buffer-name name))
        (vterm)))))

(dolist (n '(6 7 8))
  (global-set-key
   (kbd (format "M-%d" n))
   `(lambda ()
      (interactive)
      (my-vterm-goto ,n))))

(windmove-default-keybindings)
(with-eval-after-load 'vterm
  (dolist (state '(insert emacs))
    (evil-define-key state vterm-mode-map
      (kbd "S-<left>")  #'windmove-left
      (kbd "S-<right>") #'windmove-right
      (kbd "S-<up>")    #'windmove-up
      (kbd "S-<down>")  #'windmove-down))

  ;; vterm grabs most keys, so mirror the global M-6/7/8 bindings here.
  (dolist (n '(6 7 8))
    (define-key vterm-mode-map
      (kbd (format "M-%d" n))
      `(lambda ()
         (interactive)
         (my-vterm-goto ,n)))
    (when (boundp 'vterm-copy-mode-map)
      (define-key vterm-copy-mode-map
        (kbd (format "M-%d" n))
        `(lambda ()
           (interactive)
           (my-vterm-goto ,n))))))

(require 'pp-compilation)

(defun pp-c++-keybindings ()
  "Set C++ specific keybindings"
  (interactive)
  (define-key c-mode-base-map (kbd "M-e") 'pp-next-error)
  (define-key c-mode-base-map (kbd "M-E") 'pp-previous-error))

(add-hook 'c++-mode-hook (lambda () (pp-c++-keybindings)))

(provide 'pp-keybindings)
