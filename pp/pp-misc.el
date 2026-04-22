(setq ring-bell-function 'ignore)
(setq visible-bell nil)
(blink-cursor-mode 0)
(setq make-backup-files nil)
(column-number-mode t)
(global-hl-line-mode)

(winner-mode 1);; don't bring up the stupid file loader GUI
(setq use-file-dialog nil) 
;; Disable re-center when scrolling
(setq scroll-conservatively 9999) 
(setq scroll-margin 1) 
(global-visual-line-mode t)
(defalias 'yes-or-no-p 'y-or-n-p) 
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(setq window-combination-resize t) 

;; Window divider for better contrast between windows
(set-face-attribute 'window-divider nil :foreground "#888888")
(set-face-attribute 'window-divider-first-pixel nil :foreground "#888888")
(set-face-attribute 'window-divider-last-pixel nil :foreground "#888888")
(setq window-divider-default-bottom-width 3)
(setq window-divider-default-right-width 3)
(setq window-divider-default-places t)
(window-divider-mode 1)

;; Tab bar — make active tab more distinct
(set-face-attribute 'tab-bar nil
                    :background "#1a1b26" :foreground "#565f89"
                    :box nil)
(set-face-attribute 'tab-bar-tab nil
                    :background "#7aa2f7" :foreground "#1a1b26"
                    :weight 'bold
                    :box '(:line-width 4 :color "#7aa2f7"))
(set-face-attribute 'tab-bar-tab-inactive nil
                    :background "#24283b" :foreground "#565f89"
                    :weight 'normal
                    :box '(:line-width 4 :color "#24283b"))

(xterm-mouse-mode 1)
(setq revert-without-query '(".*"))
(global-auto-revert-mode 1)

(setq-default mode-line-format (list
				" "
				mode-line-modified " "
				" %e %b "
				" l:%l c:%c %p"
				'(:eval (cond
					 (( eq evil-state 'visual) "V")
					 (( eq evil-state 'normal) "N")
					 (( eq evil-state 'insert) "I")
					 (t "*")))
				))

;; Set smaller font on laptop displays (detected via eDP connector in sysfs).
;; Done in after-init-hook so it runs after themes have loaded and reset faces.
(when (and (file-directory-p "/sys/class/drm/")
           (cl-some (lambda (dir)
                      (string= (string-trim
                                (with-temp-buffer
                                  (insert-file-contents (expand-file-name "status" dir))
                                  (buffer-string)))
                               "connected"))
                    (directory-files "/sys/class/drm/" t "eDP")))
  (add-hook 'after-init-hook
            (lambda () (set-face-attribute 'default nil :height 90))))

;; Fonts — uncomment one to use
;; (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 120)
;; (set-face-attribute 'default nil :family "Fira Code" :height 120)
;; (set-face-attribute 'default nil :family "Cascadia Code" :height 120)
;; (set-face-attribute 'default nil :family "VictorMono Nerd Font" :height 120)
;; (set-face-attribute 'default nil :family "Source Code Pro" :height 120)
;(set-face-attribute 'default nil :family "Hack" :height 120)
;; (set-face-attribute 'default nil :family "Monaspace Neon" :height 120)
;; (set-face-attribute 'default nil :family "Monaspace Argon" :height 120)
;; (set-face-attribute 'default nil :family "Monaspace Xenon" :height 120)
;; (set-face-attribute 'default nil :family "Monaspace Radon" :height 120)
;; (set-face-attribute 'default nil :family "Monaspace Krypton" :height 120)
;; (set-face-attribute 'default nil :family "Geist Mono" :height 120)
;; (set-face-attribute 'default nil :family "iA Writer Mono S" :height 120)
;; (set-face-attribute 'default nil :family "Noto Sans Mono" :height 120)

;; GitHub issues in org buffer
(defun pp/gh-my-issues ()
  "Display GitHub issues assigned to me as an org buffer."
  (interactive)
  (let* ((json (shell-command-to-string
                "gh issue list --assignee @me --json number,title,repository,state,url --limit 50"))
         (issues (json-parse-string json :object-type 'alist :array-type 'list))
         (buf (get-buffer-create "*GitHub Issues*")))
    (with-current-buffer buf
      (read-only-mode -1)
      (erase-buffer)
      (insert "#+TITLE: My GitHub Issues\n\n")
      (dolist (issue issues)
        (let-alist issue
          (insert (format "* TODO #%s %s\n" .number .title))
          (insert (format "  :PROPERTIES:\n  :REPO: %s\n  :URL: %s\n  :END:\n\n"
                          (alist-get 'nameWithOwner .repository) .url))))
      (org-mode)
      (goto-char (point-min))
      (read-only-mode 1))
    (switch-to-buffer buf)))

;; Spell checking
(setq ispell-program-name "hunspell"
      ispell-dictionary "en_US")
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'prog-mode-hook #'flyspell-prog-mode)

(provide 'pp-misc)
