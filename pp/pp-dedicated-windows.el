;;; pp-dedicated-windows.el --- Fixed four-pane window layout -*- lexical-binding: t -*-
;;
;; Layout:
;;
;;     +-----+-----+-----+
;;     |  A  |     |     |
;;     +-----+  C  |  D  |
;;     |  B  |     |     |
;;     +-----+-----+-----+
;;
;; A and B are strongly dedicated to their assigned buffers and never change.
;; C and D are working windows — file editing, dired, magit, help, etc. all
;; land there because A and B refuse to host anything else.
;;
;; The module is generic: callers supply the buffers for A and B and call
;; `pp-dedicated-windows-build'. Focus helpers and a buffer-replacement helper
;; are provided for slot-aware code.

;;; Code:

(require 'cl-lib)

(defgroup pp-dedicated-windows nil
  "Fixed four-pane window layout with dedicated A and B slots."
  :group 'windows
  :prefix "pp-dedicated-windows-")

(defcustom pp-dedicated-windows-c-width-fraction 0.34
  "Fraction of frame width given to slot C (middle column)."
  :type 'number
  :group 'pp-dedicated-windows)

(defcustom pp-dedicated-windows-d-width-fraction 0.33
  "Fraction of frame width given to slot D (right column)."
  :type 'number
  :group 'pp-dedicated-windows)

(defcustom pp-dedicated-windows-a-height-fraction 0.5
  "Fraction of left-column height given to slot A (top window)."
  :type 'number
  :group 'pp-dedicated-windows)

(defun pp-dedicated-windows--window-with-slot (slot &optional frame)
  "Return the window tagged with SLOT (A, B, C, or D) on FRAME, or nil."
  (cl-find-if (lambda (w) (eq (window-parameter w 'pp-slot) slot))
              (window-list frame 'no-mini)))

(defun pp-dedicated-windows-window (slot &optional frame)
  "Return the window for SLOT (symbol A, B, C, or D), or nil."
  (pp-dedicated-windows--window-with-slot slot frame))

(defun pp-dedicated-windows--dedicate (window buffer)
  "Strongly dedicate WINDOW to BUFFER."
  (set-window-dedicated-p window nil)
  (set-window-buffer window buffer)
  (set-window-dedicated-p window 'strong))

(defun pp-dedicated-windows-build (a-buffer b-buffer)
  "Build the A/B/C/D layout in the current frame.
A-BUFFER goes into slot A (top-left, strongly dedicated).
B-BUFFER goes into slot B (bottom-left, strongly dedicated).
Slots C (middle column) and D (right column) are working windows; C is
left selected and the caller decides what lives there.

Both arguments may be buffers or buffer names; missing buffers are created."
  (dolist (w (window-list nil 'no-mini))
    (set-window-dedicated-p w nil)
    (set-window-parameter w 'no-delete-other-windows nil))
  (let ((ignore-window-parameters t))
    (delete-other-windows))
  ;; `split-window' with a positive SIZE sets the ORIGINAL window's size and
  ;; gives the remainder to the new window.  We want each fraction to describe
  ;; the new sibling (D, C, B), so we pass negative sizes throughout.  Binding
  ;; `window-combination-resize' to nil prevents Emacs from rebalancing earlier
  ;; siblings (e.g. shrinking D) when later splits add a child.
  (let* ((window-combination-resize nil)
         (a (selected-window))
         (root-w (window-total-width a))
         (d-size (round (* root-w pp-dedicated-windows-d-width-fraction)))
         (d (split-window a (- d-size) 'right))
         (c-size (round (* root-w pp-dedicated-windows-c-width-fraction)))
         (c (split-window a (- c-size) 'right))
         (b-size (round (* (window-total-height a)
                           (- 1.0 pp-dedicated-windows-a-height-fraction))))
         (b (split-window a (- b-size) 'below)))
    (set-window-parameter a 'pp-slot 'A)
    (set-window-parameter b 'pp-slot 'B)
    (set-window-parameter c 'pp-slot 'C)
    (set-window-parameter d 'pp-slot 'D)
    ;; Resist `C-x 1' wiping the layout from any of the four.
    (dolist (w (list a b c d))
      (set-window-parameter w 'no-delete-other-windows t))
    (pp-dedicated-windows--dedicate a (get-buffer-create a-buffer))
    (pp-dedicated-windows--dedicate b (get-buffer-create b-buffer))
    (select-window c)
    c))

(defun pp-dedicated-windows-set-buffer (slot buffer)
  "Place BUFFER in SLOT, preserving strong dedication for A and B.
Returns the window, or nil if the layout isn't built in this frame."
  (when-let ((win (pp-dedicated-windows-window slot)))
    (if (memq slot '(A B))
        (pp-dedicated-windows--dedicate win buffer)
      (set-window-buffer win buffer))
    win))

(defun pp-dedicated-windows-select (slot)
  "Select the window for SLOT.  Return the window or nil."
  (when-let ((win (pp-dedicated-windows-window slot)))
    (select-window win)
    win))

(provide 'pp-dedicated-windows)
;;; pp-dedicated-windows.el ends here
