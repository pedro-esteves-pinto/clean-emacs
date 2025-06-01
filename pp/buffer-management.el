(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless)))

(use-package consult)

(use-package projectile
  :config
  (projectile-mode)
  (setq projectile-enable-caching t))

(use-package counsel-projectile
  :after (projectile counsel)
  :config (counsel-projectile-mode))

(use-package consult-projectile
  :after (consult projectile)
  :config
  (dolist (src '(consult--source-buffer consult--source-bookmark))
    (add-to-list 'consult-projectile-sources src t))
  (setq projectile-project-compilation-function #'pp-compile))
