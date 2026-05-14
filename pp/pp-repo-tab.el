;;; pp-repo-tab.el --- Dedicated A/B/C/D tab for an arbitrary repo -*- lexical-binding: t -*-
;;
;; Parallel to `pp-feature--open-tab', but for any directory rather than a
;; worktree managed by the feature workflow.  Use `pp-repo-open-tab' to open
;; (or switch to) a tab with the dedicated layout rooted at a given directory.

;;; Code:

(require 'tab-bar)
(require 'dired)
(require 'pp-dedicated-windows)

(defvar vterm-buffer-name)
(declare-function vterm "vterm" ())
(declare-function vterm-send-string "vterm" (string &optional paste-p))
(declare-function vterm-send-return "vterm" ())

(defun pp-repo-tab--existing-names ()
  (mapcar (lambda (tab) (alist-get 'name tab))
          (funcall tab-bar-tabs-function)))

(defun pp-repo-tab--make-vterm (root name &optional startup-command)
  (require 'vterm)
  (let ((default-directory root)
        (vterm-buffer-name name))
    (vterm))
  (when startup-command
    (vterm-send-string startup-command)
    (vterm-send-return)))

;;;###autoload
(defun pp-repo-open-tab (root)
  "Open or switch to a tab for ROOT with the dedicated A/B/C/D layout.
A hosts a claude vterm in ROOT, B a shell vterm in ROOT, C a dired buffer
on ROOT, D is left on *scratch*.  The tab is named after ROOT's basename."
  (interactive "DRepo root: ")
  (let* ((root (file-name-as-directory (expand-file-name root)))
         (name (file-name-nondirectory (directory-file-name root)))
         (claude-name (format "claude-%s" name))
         (vterm-name (format "vterm-%s" name)))
    (if (member name (pp-repo-tab--existing-names))
        (tab-bar-switch-to-tab name)
      (let ((tab-bar-new-tab-to 'rightmost))
        (tab-bar-new-tab))
      (tab-bar-rename-tab name)
      ;; Scrub dedication/parameters cloned from the previous tab.
      (dolist (w (window-list nil 'no-mini))
        (set-window-dedicated-p w nil)
        (set-window-parameter w 'no-delete-other-windows nil)
        (set-window-parameter w 'pp-slot nil))
      (let ((ignore-window-parameters t)) (delete-other-windows))
      (switch-to-buffer (get-scratch-buffer-create))
      (save-window-excursion
        (pp-repo-tab--make-vterm root claude-name "claude"))
      (save-window-excursion
        (pp-repo-tab--make-vterm root vterm-name))
      (pp-dedicated-windows-build
       (get-buffer claude-name) (get-buffer vterm-name))
      (dired root))))

(provide 'pp-repo-tab)
;;; pp-repo-tab.el ends here
