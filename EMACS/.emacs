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
;; set color
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil  :overline nil :underline nil :slant normal :weight normal :height 110 :width normal :family "misc-fixed")))))
;; TABBAR
(load-file "~/.emacs.d/tabbar.el")
(require 'tabbar)
(setq tabbar-use-images nil)
;; (setq tabbar-buffer-groups-function 'my-tabbar-buffer-groups)
(tabbar-mode)
(global-set-key [f3] 'tabbar-backward-tab)
(global-set-key [f4] 'tabbar-forward-tab)
(global-set-key [f6] 'tabbar-forward-group)
(global-set-key [f8] 'edts-project-node-init)
(global-set-key [f7] 'my-next-long-line)
(setq-default indent-tabs-mode nil)

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
;; git-timemachine
;; =============================================================================
(add-to-list 'load-path "/home/doan/.emacs.d/git-timemachine-master/")
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
(add-to-list 'load-path "/home/doan/.emacs.d/diff-hl-master/")
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
