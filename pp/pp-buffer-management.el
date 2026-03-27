(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless)))

;; In-buffer completion popup (uses completion-at-point).
(use-package corfu
  :custom
  (corfu-auto nil)
  (corfu-cycle t)
  (corfu-preview-current nil)
  :init
  (global-corfu-mode))

(use-package consult)

(use-package projectile
  :config
  (projectile-mode)
  (setq projectile-enable-caching t))

(use-package consult-projectile
  :after (consult projectile)
  :config
  ;; Include Consult's global buffers and bookmarks in the multiview.
  (dolist (src '(consult-source-buffer consult-source-bookmark))
    (add-to-list 'consult-projectile-sources src t))
  (setq projectile-project-compilation-function #'pp-compile))

(provide 'pp-buffer-management)
