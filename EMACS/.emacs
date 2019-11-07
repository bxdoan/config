;; Removing the default start-up buffer
(setq inhibit-startup-message t)
;; Color for selected text
(set-face-background 'region "blue")
;; Change color cursor
(set-cursor-color "#07F328")
;; Change color highligh
(set-face-attribute 'region nil :background "#B67AE6")
;; Change yes-or-no to y-or-n
(fset `yes-or-no-p `y-or-n-p)
;; set keybindings
(global-set-key "\C-l" 'goto-line)
(global-set-key "\C-r" 'query-replace)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)
(global-set-key [f2] 'save-buffer)
(global-set-key [f5] 'revert-buffer-no-confirm-and-reload-emacs)
(global-set-key [f8] 'edts-project-node-init)
(global-set-key [f7] 'my-next-long-line)

;; Match parentheses
(show-paren-mode t)
;; turn off the scroll bar
(scroll-bar-mode -1)
;; Show line-number in the mode line
(line-number-mode 1)
;; disable the menu bar
(menu-bar-mode -1)
;; disable toolbar
(tool-bar-mode -1)
;; Show column-number in the mode line
(column-number-mode 1)
;; Set fill column
(setq-default fill-column 80)
;; enable clipboard
(setq x-select-enable-clipboard t)
;; add count line
(global-linum-mode 1)

;; =============================================================================
;; solidity-mode
;; =============================================================================
(load-file "~/.emacs.d/solidity-mode/solidity-mode.el")
(require 'solidity-mode)
;; =============================================================================
;; set color
;; =============================================================================
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil  :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :family "misc-fixed")))))
(setq-default indent-tabs-mode nil)

;; =============================================================================
;; TABBAR
;; =============================================================================
(load-file "~/.emacs.d/tabbar.el")
(require 'tabbar)
(setq tabbar-use-images nil)
;; (setq tabbar-buffer-groups-function 'my-tabbar-buffer-groups)
(tabbar-mode)
(global-set-key [f3] 'tabbar-backward-tab)
(global-set-key [f4] 'tabbar-forward-tab)
(global-set-key [f6] 'tabbar-forward-group)

;; =============================================================================
;; git-timemachine
;; =============================================================================
(add-to-list 'load-path "/home/$USER/.emacs.d/git-timemachine-master/")
(require 'git-timemachine)
;; M-x git-timemachine
;; p - visit previous historic version
;; n - view next historic version
;; w - copy the abbreviated hash of the current historic version
;; W - copy the full hash of the current historic version
;; g - goto nth version
;; q - exit the timemachine

;; =============================================================================
;; diff-hl
;; =============================================================================
(add-to-list 'load-path "/home/$USER/.emacs.d/diff-hl-master/")
(require 'diff-hl)
(global-diff-hl-mode)
(global-set-key (kbd "C-n") 'diff-hl-next-hunk)
(global-set-key (kbd "C-b") 'diff-hl-previous-hunk)
(global-set-key (kbd "C-.") 'diff-hl-revert-hunk)
(global-set-key (kbd "C-,") 'diff-hl-rollback)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; =============================================================================
;; my-next-long-line
;; =============================================================================
(defun my-next-long-line (arg)
  "Move to the ARGth next long line greater than `fill-column'."
  (interactive "p")
  (or arg (setq arg 1))
  (let ((opoint (point))
        (line-length 0))
    ;; global-variable: fill-column
    (while (and (<= line-length fill-column)
                (zerop (forward-line (if (< arg 0) -1 1))))
      (setq line-length (save-excursion
                          (end-of-line)
                          (current-column))))
    ;; Stop, end of buffer reached.
    (if (> line-length fill-column)
        (if (> arg 1)
            (my-next-long-line (1- arg))
          (if (< arg -1)
              (my-next-long-line (1+ arg))
            (message (format "Long line of %d columns found"
                             line-length))))
      (goto-char opoint)
      (message "Long line not found"))))
(setq-default fill-column 80)

;; =============================================================================
;; revert-buffer-no-confirm-and-reload-emacs
;; =============================================================================
(defun revert-buffer-no-confirm-and-reload-emacs ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t)
  (load-file "~/.emacs"))

;; =============================================================================
;; Auto indent and remove whitespace
;; =============================================================================
(local-set-key (kbd "TAB") 'tab-space-indent)
(defun tab-space-indent ()
  (interactive)
  (save-excursion
    (if (use-region-p)
        (let*
            ((firstline (line-number-at-pos (region-beginning)))
             (lastline (line-number-at-pos (region-end)))
             (firstpoint (lambda () (save-excursion
                                      (goto-line firstline)
                                      (line-beginning-position))))
             (lastpoint (lambda () (save-excursion
                                     (goto-line lastline)
                                     (line-end-position)))))
          (delete-trailing-whitespace (funcall firstpoint) (funcall lastpoint))
          (untabify (funcall firstpoint) (funcall lastpoint)))
      (delete-trailing-whitespace (line-beginning-position) (line-end-position))
      (untabify (line-beginning-position) (line-end-position))))
  (indent-for-tab-command))

;; =============================================================================
;; whitespace
;; =============================================================================
(add-to-list 'load-path "/home/xdoabui/.emacs.d/whitespace/")
(global-whitespace-mode)
(setq whitespace-style '(face tabs))
(set-face-background whitespace-tab "orange")
