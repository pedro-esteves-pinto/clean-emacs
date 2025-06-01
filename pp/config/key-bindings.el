
(global-set-key (kbd "M-x") 'counsel-M-x)
(evil-leader/set-leader "<SPC>")
(evil-leader/set-key "<SPC>" 'consult-projectile)
(evil-leader/set-key "mm" 'magit-status "mb" 'vc-annotate) 
(global-set-key (read-kbd-macro "M-SPC") 'dabbrev-expand)
(global-set-key (kbd "<f12>") 'consult-projectile)

(windmove-default-keybindings)
