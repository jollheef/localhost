(setq explicit-shell-file-name "/bin/sh")
(setq shell-file-name "sh")

;;
;;
;; NixOS
;;
;;


(global-set-key (kbd "C-c C-S-n") 'helm-nixos-options)

(add-hook 'after-init-hook 'global-company-mode)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'company-nixos-options)
  (global-set-key (kbd "TAB") #'company-indent-or-complete-common))

;;
;;
;; Backups
;;
;;

;; Put autosave files (ie #foo#) and backup files (ie foo~) in ~/.emacs.d/.
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/\\1" t)))
(setq backup-directory-alist '((".*" . "~/.emacs.d/backups/")))
;; Create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)
(make-directory "~/.emacs.d/backups/" t)

;;
;;
;; Appearance
;;
;;

;; Disable startup-message (show *scratch* buffer)
(setq inhibit-startup-message t)
;; Set *scratch* buffer mode
(setq initial-major-mode 'text-mode)

;; Disable all bar
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Show time
(setq display-time-format "%H:%M")
(display-time-mode)

;; Show column (line, column)
(column-number-mode)

;; Indent style
(setq c-default-style "linux")

;; Highlight line
;(global-hl-line-mode 1)

;; y-or-n instead of yes-or-no in kill buffer
(defalias 'yes-or-no-p 'y-or-n-p)

;; Set default font
;;(set-default-font "-unknown-Ubuntu Mono-normal-normal-normal-*-*-*-*-*-m-0-iso10646-1")
;;(set-frame-font "Ubuntu Mono 10")

(setq-default indent-tabs-mode t)

;; Color theme
(require 'zenburn-theme)
(load-theme 'zenburn t)

;;
;;
;; Russian layout hotkeys hack
;;
;;

(defun reverse-input-method (input-method)
  "Build the reverse mapping of single letters from INPUT-METHOD."
  (interactive
   (list (read-input-method-name "Use input method (default current): ")))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (let ((current current-input-method)
        (modifiers '(nil (control) (meta) (control meta))))
    (when input-method
      (activate-input-method input-method))
    (when (and current-input-method quail-keyboard-layout)
      (dolist (map (cdr (quail-map)))
        (let* ((to (car map))
               (from (quail-get-translation
                      (cadr map) (char-to-string to) 1)))
          (when (and (characterp from) (characterp to))
            (dolist (mod modifiers)
              (define-key local-function-key-map
                (vector (append mod (list from)))
                (vector (append mod (list to)))))))))
    (when input-method
      (activate-input-method current))))

;; Hotkeys on russian layout
(reverse-input-method 'russian-computer)

;;
;;
;; Key bindings
;;
;;

(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-w") 'backward-kill-word)
(global-set-key (kbd "C-x f") 'recentf-ido-find-file)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-x C-m") 'smex)
(global-set-key (kbd "C-c C-m") 'smex)
(global-set-key (kbd "C-x C-k") 'kill-region)
(global-set-key (kbd "C-S-u") 'ucs-insert)

;;
;;
;; Goodies
;;
;;

(defun recentf-ido-find-file ()
  "Find a recent file using ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

;;
;;
;; Loads
;;
;;

(recentf-mode 1)
(put 'upcase-region 'disabled nil)

(setq inferior-lisp-program "sbcl")

(require 'slime)
(slime-setup '(slime-repl
               slime-fuzzy
               slime-fancy-inspector
               slime-indentation))

(require 'git-gutter)
(global-git-gutter-mode t)

(add-hook 'before-save-hook #'gofmt-before-save)

(setq exec-path (append exec-path (split-string (getenv "PATH") ":")))

(defun auto-complete-for-go ()
  (metafmt-mode 1)
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)

(with-eval-after-load 'go-mode
  (require 'go-autocomplete))

(add-hook 'vhdl-mode-hook (lambda () (setq vhdl-indent-tabs-mode t)))
(put 'downcase-region 'disabled nil)

;; Enable helm-gtags-mode
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)

;; Set key bindings
(eval-after-load "helm-gtags"
  '(progn
     (define-key helm-gtags-mode-map (kbd "M-t") 'helm-gtags-find-tag)
     (define-key helm-gtags-mode-map (kbd "M-r") 'helm-gtags-find-rtag)
     (define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
     (define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
     (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
     (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
     (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)))

;; zsh is hell for ssh-tramp
(eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))

(eval-after-load "w3m"
  '(progn
     (require 'w3m-search)
     (setq w3m-search-default-engine "duckduckgo")
     (add-to-list 'w3m-search-engine-alist
                  '("duckduckgo" "https://www.duckduckgo.com/lite/?kd=-1&q=%s"))))

(setq rust-format-on-save t)

(setq mastodon-instance-url "lor.sh")

(setq gofmt-command "goimports")

(add-hook 'before-save-hook 'gofmt-before-save)

(setq elpy-rpc-python-command "python3")

(selectrum-mode +1)

;; to make sorting and filtering more intelligent
(selectrum-prescient-mode +1)

;; to save your command history on disk, so the sorting gets more
;; intelligent over time
(prescient-persist-mode +1)

;;
;; org-mode
;;

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n g" . org-roam-graph)
	 ("C-c n i" . org-roam-node-insert)
	 ("C-c n c" . org-roam-capture)
	 ;; Dailies
	 ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

;; RFC 5545 compatible keyword sequences; shortcuts of first element in each
;; sequence match those of the capture templates' shortcuts
(setq org-todo-keywords
      '((sequence "NEEDS-ACTION(t)" "IN-PROCESS(i)" "|" "COMPLETED(d)")
	(sequence "TENTATIVE(e)" "|" "CONFIRMED(c)")
	(sequence "DRAFT(j)" "|" "FINAL(f)")
	(sequence "|" "CANCELLED(C)")))

(setq org-startup-folded nil)

(setq org-agenda-files (quote ("~/org")))
