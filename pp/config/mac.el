(when (eq system-type 'darwin)
    (when (display-graphic-p)
      (add-hook 'emacs-startup-hook
		(lambda ()
		  (do-applescript "tell application \"Emacs\" to activate")))))
    
