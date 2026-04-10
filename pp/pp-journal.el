
(defun pp-journal-find-location ()
  "Navigate to today's journal entry in Year > Month > Day hierarchy."
  (let* ((year  (format-time-string "%Y"))
         (month (format-time-string "%Y-%m %B"))
         (day   (format-time-string "%Y-%m-%d %A")))
    (goto-char (point-min))
    ;; Year heading
    (unless (re-search-forward (format "^\\* %s$" year) nil t)
      (goto-char (point-max))
      (insert "\n* " year "\n"))
    ;; Month heading
    (let ((year-end (save-excursion
                      (org-end-of-subtree t t)
                      (point))))
      (unless (re-search-forward (format "^\\*\\* %s$" (regexp-quote month)) year-end t)
        (goto-char year-end)
        (insert "** " month "\n")))
    ;; Day heading
    (let ((month-end (save-excursion
                       (org-end-of-subtree t t)
                       (point))))
      (if (re-search-forward (format "^\\*\\*\\* %s$" (regexp-quote day)) month-end t)
          (org-end-of-subtree t t)
        (goto-char month-end)
        (insert "*** " day "\n")))))

(defun pp-journal-capture ()
  "Capture a new journal entry."
  (interactive)
  (org-capture nil "j"))

(setq org-capture-templates
      '(("j" "Journal" plain
         (file+function "~/Dropbox/notes/journal/personal-journal.org"
                        pp-journal-find-location)
         "%i%?"
         :empty-lines 1)))

(provide 'pp-journal)
