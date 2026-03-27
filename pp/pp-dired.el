(setq dired-listing-switches "-lL --group-directories-first")
(connection-local-set-profile-variables
 'remote-dired-profile
 '((dired-listing-switches . "-lL")))
(connection-local-set-profiles
 '(:application tramp) 'remote-dired-profile)

(add-hook 'dired-mode-hook
	  (lambda () ;; Auto—refresh dired on file change
	    (auto-revert-mode)
	    (setq-default auto-revert-interval 1)
	    (auto-revert-set-timer)))
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)

(provide 'pp-dired)

