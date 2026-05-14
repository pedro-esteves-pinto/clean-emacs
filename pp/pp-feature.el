;;; pp-feature.el --- Worktree + tab + claude orchestration -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'tab-bar)
(require 'dired)
(require 'pp-dedicated-windows)

;; Forward declarations for vterm (loaded lazily in `pp-feature--make-claude').
;; The defvar is load-bearing under lexical-binding: without it, the `let'
;; around `(vterm)' would be a lexical binding that vterm's dynamic lookup
;; doesn't see, and the buffer-name override would silently be ignored.
(defvar vterm-buffer-name)
(declare-function vterm "vterm" (&optional arg))
(declare-function vterm-send-string "vterm" (string &optional paste-p))
(declare-function vterm-send-return "vterm" ())

(defvar pp-feature-worktree-parent
  (expand-file-name "~/refine.ink")
  "Parent directory holding all refine.ink worktrees.")

(defvar pp-feature-script
  (expand-file-name "tools/new-worktree.sh" pp-feature-worktree-parent)
  "Path to the new-worktree helper script.")

(defvar pp-feature-name-regexp
  "\\`\\(frontend\\|backend\\)-[0-9]+-"
  "Regexp matching a feature tab name.")

(defvar pp-feature-repos
  '(("frontend" . "Refine-Technologies-Inc/frontend")
    ("backend"  . "Refine-Technologies-Inc/proofreader_python"))
  "Alist mapping project name to its GitHub repo in owner/name form.")

(defvar pp-feature-project-owner "Refine-Technologies-Inc"
  "GitHub owner (org) of the Refine development project.")

(defvar pp-feature-project-number "1"
  "Number of the Refine development project within the org.")

(defvar pp-feature-project-id "PVT_kwDODXZ-Rs4BFXCE"
  "GraphQL node ID of the Refine development project.")

(defvar pp-feature-status-field-id "PVTSSF_lADODXZ-Rs4BFXCEzg2uBIs"
  "GraphQL node ID of the Status single-select field in the project.")

(defvar pp-feature-status-in-progress-id "47fc9ee4"
  "ID of the `In progress' option of the Status field.")

(defun pp-feature--tabs ()
  "Return feature tab names, in bar order."
  (let (names)
    (dolist (tab (funcall tab-bar-tabs-function))
      (let ((name (alist-get 'name tab)))
        (when (and name (string-match-p pp-feature-name-regexp name))
          (push name names))))
    (nreverse names)))

(defun pp-feature--worktrees-on-disk ()
  "Feature worktree directory names under `pp-feature-worktree-parent'."
  (let (names)
    (when (file-directory-p pp-feature-worktree-parent)
      (dolist (entry (directory-files pp-feature-worktree-parent nil nil t))
        (when (and (not (member entry '("." "..")))
                   (string-match-p pp-feature-name-regexp entry)
                   (file-directory-p
                    (expand-file-name entry pp-feature-worktree-parent)))
          (push entry names))))
    (sort names #'string<)))

(defun pp-feature--all ()
  "Union of open feature tabs and on-disk feature worktrees."
  (delete-dups
   (append (pp-feature--tabs) (pp-feature--worktrees-on-disk))))

(defun pp-feature--current-tab ()
  "Return the currently selected tab's alist."
  (cl-find-if (lambda (tab) (eq (car tab) 'current-tab))
              (funcall tab-bar-tabs-function)))

(defun pp-feature--current-feature ()
  "Name of the feature for the current tab, or nil.
Reads the tab's stored name — NOT the current buffer's name, which is what
`tab-bar-tab-name-current' returns and would break as soon as you switch
to a non-feature buffer like `*magit: ...*'."
  (let ((name (alist-get 'name (pp-feature--current-tab))))
    (when (and name (string-match-p pp-feature-name-regexp name))
      name)))

(defun pp-feature--worktree-path (feature)
  (expand-file-name feature pp-feature-worktree-parent))

(defun pp-feature--claude-buffer-name (feature)
  (format "claude-%s" feature))

(defun pp-feature--vterm-buffer-name (feature)
  (format "vterm-%s" feature))

(defun pp-feature--make-vterm (feature name &optional startup-command)
  "Open a vterm buffer NAME in FEATURE's worktree in the selected window.
When STARTUP-COMMAND is non-nil, send it + RET after the shell starts."
  (require 'vterm)
  (let* ((root (pp-feature--worktree-path feature))
         (default-directory root)
         (vterm-buffer-name name))
    (vterm))
  (when startup-command
    (vterm-send-string startup-command)
    (vterm-send-return)))

(defun pp-feature--make-claude (feature)
  "Open a claude vterm for FEATURE in the selected window."
  (pp-feature--make-vterm feature
                          (pp-feature--claude-buffer-name feature)
                          "claude"))

(defun pp-feature--open-tab (feature)
  "Create a new tab for FEATURE using the dedicated A/B/C layout.
A (top-left) = claude, B (bottom-left) = vterm, C (right) = dired.
Focus is left on the dired window."
  (let ((root (pp-feature--worktree-path feature))
        (tab-bar-new-tab-to 'rightmost))
    (tab-bar-new-tab)
    (tab-bar-rename-tab feature)
    ;; The new tab inherits dedication and `no-delete-other-windows' from the
    ;; previous tab's A-slot, which makes tab-bar's internal switch-to-buffer
    ;; fall through to `pop-to-buffer' and silently split the frame.  Scrub
    ;; that state so the layout builder starts from a clean single window.
    (dolist (w (window-list nil 'no-mini))
      (set-window-dedicated-p w nil)
      (set-window-parameter w 'no-delete-other-windows nil)
      (set-window-parameter w 'pp-slot nil))
    (let ((ignore-window-parameters t))
      (delete-other-windows))
    (switch-to-buffer (get-scratch-buffer-create))
    ;; Spawn the claude and vterm buffers off-screen so we can hand live
    ;; buffers to the layout builder.  `save-window-excursion' keeps `vterm''s
    ;; switch-to-buffer side effect from clobbering the soon-to-be layout.
    (save-window-excursion (pp-feature--make-claude feature))
    (save-window-excursion
      (pp-feature--make-vterm feature
                              (pp-feature--vterm-buffer-name feature)))
    (pp-dedicated-windows-build
     (get-buffer (pp-feature--claude-buffer-name feature))
     (get-buffer (pp-feature--vterm-buffer-name feature)))
    (dired root)))

;;;###autoload
(defun pp-feature-new (project issue)
  "Create a worktree for PROJECT and ISSUE, then open it in a tab.
If ISSUE already has an open PR linked to it (via Closes/Fixes) in PROJECT's
repo, the worktree is checked out from that PR's branch instead of a fresh
branch off `dev'. Detection happens inside `pp-feature-script'."
  (interactive
   (list (completing-read "Project: " '("frontend" "backend") nil t)
         (read-string "Issue number: ")))
  (unless (string-match-p "\\`[0-9]+\\'" issue)
    (user-error "Issue number must be numeric: %s" issue))
  (unless (file-executable-p pp-feature-script)
    (user-error "Script not executable: %s" pp-feature-script))
  (let* ((buf-name (format "*new-worktree: %s-%s*" project issue))
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (let ((inhibit-read-only t)) (erase-buffer)))
    (let ((proc (start-process "new-worktree" buf
                               pp-feature-script project issue)))
      (set-process-sentinel proc #'pp-feature--new-sentinel)
      (pop-to-buffer buf))))

(defun pp-feature--new-sentinel (proc _event)
  (when (memq (process-status proc) '(exit signal))
    (if (/= 0 (process-exit-status proc))
        (message "new-worktree.sh failed (exit %d); see %s"
                 (process-exit-status proc)
                 (buffer-name (process-buffer proc)))
      (let* ((out (with-current-buffer (process-buffer proc) (buffer-string)))
             (path (and (string-match "^WORKTREE_DIR=\\(.+\\)$" out)
                        (match-string 1 out))))
        (if path
            (let ((feature (file-name-nondirectory (directory-file-name path))))
              (pp-feature--open-tab feature))
          (message "Worktree created but could not parse WORKTREE_DIR from output"))))))

;;;###autoload
(defun pp-feature-create-issue (project title body)
  "Create a GitHub issue in PROJECT with TITLE and BODY, then run
the same worktree/tab flow as `pp-feature-new' on the resulting issue."
  (interactive
   (list (completing-read "Project: " (mapcar #'car pp-feature-repos) nil t)
         (read-string "Issue title: ")
         (read-string "Issue body (optional): ")))
  (when (string-empty-p title)
    (user-error "Title is required"))
  (let ((repo (cdr (assoc project pp-feature-repos))))
    (unless repo (user-error "Unknown project: %s" project))
    (unless (executable-find "gh")
      (user-error "gh CLI not found on PATH"))
    (pp-feature--check-gh-scopes)
    (let* ((buf-name (format "*create-issue: %s*" project))
           (buf (get-buffer-create buf-name)))
      (with-current-buffer buf
        (let ((inhibit-read-only t)) (erase-buffer)))
      (let ((proc (start-process "gh-issue-create" buf
                                 "gh" "issue" "create"
                                 "--repo" repo
                                 "--assignee" "ppinto-afk"
                                 "--title" title
                                 "--body" body)))
        (process-put proc 'pp-feature-project project)
        (set-process-sentinel proc #'pp-feature--issue-create-sentinel)
        (pop-to-buffer buf)))))

(defun pp-feature--append-buf (buf line)
  (with-current-buffer buf
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (insert line)
      (unless (bolp) (insert "\n")))))

(defun pp-feature--last-error-line (buf)
  "Return the last `error: ...' line in BUF, or nil."
  (with-current-buffer buf
    (save-excursion
      (goto-char (point-max))
      (when (re-search-backward "^error: .*$" nil t)
        (match-string-no-properties 0)))))

(defun pp-feature--proc-error-suffix (proc)
  "Format the tail of a failure `message' for PROC.
Surfaces the last `error:' line from gh when present, instead of forcing the
user to dig through the process buffer."
  (let ((err (pp-feature--last-error-line (process-buffer proc))))
    (if err
        (concat ": " err)
      (format "; see %s" (buffer-name (process-buffer proc))))))

(defun pp-feature--check-gh-scopes ()
  "Signal a `user-error' if gh's token is missing the `project' scope.
The post-issue chain (`gh project item-add' / `item-edit') needs it; without
it the chain dies after issue creation, leaving an orphan issue and no tab."
  (let ((output (shell-command-to-string "gh auth status 2>&1")))
    (cond
     ((string-match "Token scopes:[^\n]*\\bproject\\b" output) t)
     ((string-match "Token scopes:" output)
      (user-error
       "gh token missing `project' scope — run: gh auth refresh -s project"))
     (t
      (user-error "gh auth status failed:\n%s" (string-trim output))))))

(defun pp-feature--issue-create-sentinel (proc _event)
  (when (memq (process-status proc) '(exit signal))
    (if (/= 0 (process-exit-status proc))
        (message "gh issue create failed (exit %d)%s"
                 (process-exit-status proc)
                 (pp-feature--proc-error-suffix proc))
      (let* ((buf (process-buffer proc))
             (out (with-current-buffer buf (buffer-string)))
             (url (and (string-match
                        "\\(https://github\\.com/[^ \n]+/issues/[0-9]+\\)" out)
                       (match-string 1 out)))
             (issue (and url
                         (string-match "/issues/\\([0-9]+\\)" url)
                         (match-string 1 url)))
             (project (process-get proc 'pp-feature-project)))
        (cond
         ((not url)
          (message "Issue create succeeded but could not parse URL"))
         (t
          (pp-feature--project-add buf project issue url)))))))

(defun pp-feature--project-add (buf project issue url)
  (pp-feature--append-buf
   buf (format "==> Adding %s to project %s/%s"
               url pp-feature-project-owner pp-feature-project-number))
  (let ((proc (start-process "gh-project-add" buf
                             "gh" "project" "item-add"
                             pp-feature-project-number
                             "--owner" pp-feature-project-owner
                             "--url" url
                             "--format" "json")))
    (process-put proc 'pp-feature-project project)
    (process-put proc 'pp-feature-issue issue)
    (set-process-sentinel proc #'pp-feature--project-add-sentinel)))

(defun pp-feature--project-add-sentinel (proc _event)
  (when (memq (process-status proc) '(exit signal))
    (let ((project (process-get proc 'pp-feature-project))
          (issue (process-get proc 'pp-feature-issue)))
      (cond
       ((/= 0 (process-exit-status proc))
        (message "gh project item-add failed (exit %d)%s — proceeding with worktree"
                 (process-exit-status proc)
                 (pp-feature--proc-error-suffix proc))
        (pp-feature-new project issue))
       (t
        (let* ((buf (process-buffer proc))
               (out (with-current-buffer buf (buffer-string)))
               (item-id (and (string-match "\\(PVTI_[A-Za-z0-9_-]+\\)" out)
                             (match-string 1 out))))
          (if item-id
              (pp-feature--project-set-status buf project issue item-id)
            (message "Added to project but could not parse item id — proceeding with worktree")
            (pp-feature-new project issue))))))))

(defun pp-feature--project-set-status (buf project issue item-id)
  (pp-feature--append-buf
   buf (format "==> Setting Status=In progress on item %s" item-id))
  (let ((proc (start-process "gh-project-status" buf
                             "gh" "project" "item-edit"
                             "--id" item-id
                             "--field-id" pp-feature-status-field-id
                             "--project-id" pp-feature-project-id
                             "--single-select-option-id"
                             pp-feature-status-in-progress-id)))
    (process-put proc 'pp-feature-project project)
    (process-put proc 'pp-feature-issue issue)
    (set-process-sentinel proc #'pp-feature--project-status-sentinel)))

(defun pp-feature--project-status-sentinel (proc _event)
  (when (memq (process-status proc) '(exit signal))
    (let ((project (process-get proc 'pp-feature-project))
          (issue (process-get proc 'pp-feature-issue)))
      (when (/= 0 (process-exit-status proc))
        (message "gh project item-edit failed (exit %d)%s — proceeding with worktree"
                 (process-exit-status proc)
                 (pp-feature--proc-error-suffix proc)))
      (pp-feature-new project issue))))

;;;###autoload
(defun pp-feature-switch (feature)
  "Jump to FEATURE's tab, creating the tab on the fly if only the worktree exists."
  (interactive
   (list (let ((candidates (pp-feature--all)))
           (unless candidates (user-error "No feature tabs or worktrees"))
           (completing-read "Feature: " candidates nil t))))
  (if (member feature (pp-feature--tabs))
      (tab-bar-switch-to-tab feature)
    (let ((path (pp-feature--worktree-path feature)))
      (unless (file-directory-p path)
        (user-error "Worktree does not exist: %s" path))
      (pp-feature--open-tab feature))))

(defun pp-feature--focus-dedicated-slot (slot factory)
  "Focus SLOT (A or B), running FACTORY (a thunk) first if its buffer is gone.
FACTORY is expected to create the buffer that SLOT should host."
  (let ((win (pp-dedicated-windows-window slot)))
    (unless win (user-error "Dedicated window layout not present in this tab"))
    (let* ((buffer (window-buffer win)))
      (unless (buffer-live-p buffer)
        (save-window-excursion (funcall factory))
        ;; The factory has created a fresh buffer; re-seat it in the slot.
        (pp-dedicated-windows-set-buffer
         slot (window-buffer (selected-window)))))
    (pp-dedicated-windows-select slot)))

;;;###autoload
(defun pp-feature-claude ()
  "Focus this tab's claude window (slot A)."
  (interactive)
  (let ((feature (pp-feature--current-feature)))
    (unless feature (user-error "Not in a feature tab"))
    (pp-feature--focus-dedicated-slot
     'A (lambda () (pp-feature--make-claude feature)))))

;;;###autoload
(defun pp-feature-vterm ()
  "Focus this tab's shell vterm window (slot B)."
  (interactive)
  (let ((feature (pp-feature--current-feature)))
    (unless feature (user-error "Not in a feature tab"))
    (pp-feature--focus-dedicated-slot
     'B (lambda ()
          (pp-feature--make-vterm feature
                                  (pp-feature--vterm-buffer-name feature))))))

;;;###autoload
(defun pp-feature-dired ()
  "Open a dired buffer at the feature's worktree root in slot C."
  (interactive)
  (let ((feature (pp-feature--current-feature)))
    (unless feature (user-error "Not in a feature tab"))
    (pp-dedicated-windows-select 'C)
    (dired (pp-feature--worktree-path feature))))

;;;###autoload
(defun pp-feature-close ()
  "Close the current feature tab and offer to remove its worktree."
  (interactive)
  (let ((feature (pp-feature--current-feature)))
    (unless feature (user-error "Not in a feature tab"))
    (let* ((path (pp-feature--worktree-path feature))
           (repo (cond
                  ((string-prefix-p "frontend-" feature)
                   (expand-file-name "frontend" pp-feature-worktree-parent))
                  ((string-prefix-p "backend-" feature)
                   (expand-file-name "proofreader_python" pp-feature-worktree-parent)))))
      (when (and repo (file-directory-p path)
                 (yes-or-no-p (format "git worktree remove %s? " path)))
        (let ((default-directory repo))
          (call-process "git" nil "*pp-feature-worktree-remove*" nil
                        "worktree" "remove" path)))
      (tab-bar-close-tab))))

;; Narrow consult-projectile to the current feature tab's worktree so the
;; project-scoped sources reflect the tab rather than the current buffer's
;; default-directory (which can drift into sibling worktrees via magit, vterm,
;; dired, etc.).
(defun pp-feature--consult-projectile-advice (orig-fn &rest args)
  (let ((feature (pp-feature--current-feature)))
    (if feature
        (let ((default-directory (pp-feature--worktree-path feature)))
          (apply orig-fn args))
      (apply orig-fn args))))

(with-eval-after-load 'consult-projectile
  (advice-add 'consult-projectile :around #'pp-feature--consult-projectile-advice))

(provide 'pp-feature)
