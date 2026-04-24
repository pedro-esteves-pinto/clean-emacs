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

;; Tab-scoped buffer lists. With `bufferlo-mode' on, `consult-buffer',
;; `switch-to-buffer', and friends only offer buffers belonging to the current
;; tab — that's what keeps feature tabs from cross-contaminating.
(use-package bufferlo
  :init (bufferlo-mode))

(use-package consult-projectile
  :after (consult projectile)
  :config
  ;; Deliberately NOT adding `consult-source-buffer' here: it's a global source
  ;; and would leak buffers from other feature tabs into this tab's picker.
  (add-to-list 'consult-projectile-sources 'consult-source-bookmark t)
  (setq projectile-project-compilation-function #'pp-compile))

(provide 'pp-buffer-management)
