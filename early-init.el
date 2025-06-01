;;; early-init.el --- Early startup tweaks for Emacs with straight.el

;; UI optimizations (avoid flicker)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(setq frame-inhibit-implied-resize t)
(setq inhibit-startup-message t)      ; no startup message in *scratch*
(setq initial-scratch-message nil)    ; blank *scratch* buffer
(setq inhibit-startup-echo-area-message user-login-name) ; no echo area message
(setq package-enable-at-startup nil) ;; Don't auto-init packages (we use straight.el)

;; Speed up startup with GC and file handler tweaks These will be
;; reverted back to defaults by a hook in init.el
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      file-name-handler-alist-original file-name-handler-alist
      file-name-handler-alist nil)


