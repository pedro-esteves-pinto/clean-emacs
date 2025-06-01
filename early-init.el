;;; early-init.el --- Early startup tweaks for Emacs with straight.el

;; UI optimizations (avoid flicker)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)
(setq frame-inhibit-implied-resize t)

;; Don't auto-init packages (we use straight.el)
(setq package-enable-at-startup nil)

;; Speed up startup with GC and file handler tweaks
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      file-name-handler-alist-original file-name-handler-alist
      file-name-handler-alist nil)

(provide 'early-init)
;;; early-init.el ends here


