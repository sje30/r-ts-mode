;;; r-ts-mode.el --- Proof of concept R mode with treesitter
;; Copyright (C) 2023 Stephen J Eglen

;; Author: Stephen J Eglen <sje30@cam.ac.uk>
;; Maintainer: Stephen J Eglen <sje30@cam.ac.uk>
;; Keywords: languages, R

;; GPL-3 to follow

;;; Commentary:

;; This is currently a proof-of-concept for a programming mode for R.
;; It does not depend on ESS <https://ess.r-project.org>
;; To run, it requires treesit in Emacs 29 and the R language mode
;; from https://github.com/r-lib/tree-sitter-r

;; Much of this code has been adapted from other modes, notably
;; julia-ts-mode.el

;; For examples of what it can do, visit the file:  r-ts-examples.R

(require 'treesit)
(eval-when-compile (require 'rx))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.R\\'" . r-ts-mode))


;; Use (list-faces-display) to pick a face.  Some strong ones that might
;; be useful during testing:
;; vc-conflict-state dark red
;; wwg-green-face
;; wwg-yellow-face
(defvar r--treesit-settings
  (treesit-font-lock-rules
   :feature 'comment
   :language 'r
   '((comment) @font-lock-comment-face)

   :feature 'string
   :language 'r
   '((string) @font-lock-string-face)

   :feature 'constant
   :language 'r
   '([(true) (false) (nan) (na) (inf)] @font-lock-builtin-face)
   
   :language 'r
   :feature 'literal
   '([(float)] @wwg-green-face)

   ;; Match "a = function()..."
   :language 'r
   :feature 'function1
   '((equals_assignment name: (identifier) @font-lock-function-name-face
			value: (function_definition)))

   ;; Match "a <- function()..."
   :language 'r
   :feature 'function2
   '((left_assignment name: (identifier) @font-lock-function-name-face
		      value: (function_definition)))


   ;; Match replacement functions, i.e.
   ;; "threshold<-" <- function()...
   :language 'r
   :feature 'function-replace
   :override t				;conflicts with string
   '((left_assignment name: (string) @font-lock-function-name-face 
		      value: (function_definition)))

   ))

(defvar r-ts--treesit-indent-rules
  (let ((offset 2))
    `((r
       ((node-is "}") parent-bol 0)
       ((node-is ")") parent-bol 0)
       ((node-is "consequence") parent-bol ,offset)
       ((parent-is "brace_list") parent-bol ,offset)
       (no-node parent-bol 0)
       ))))



;;;###autoload
(define-derived-mode r-ts-mode prog-mode "R (TS)"
  "Major mode for Julia files using tree-sitter."
  :group 'R

  (unless (treesit-ready-p 'r)
    (error "Tree-sitter for R is not available"))
  
  (setq-local treesit-font-lock-settings r--treesit-settings)
  (setq-local treesit-font-lock-feature-list
	      '((comment)
		(constant string)
		(function1 function2 function-replace)
		(literal)
		))

  
  (setq-local syntax-propertize-function nil)
  (setq-local indent-line-function nil)

  (treesit-parser-create 'r)

  ;; Comments.
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip (rx "#" (* (syntax whitespace))))

  ;; Indent.
  (setq-local treesit-simple-indent-rules r-ts--treesit-indent-rules)

  ;; ;; Navigation.
  (setq-local treesit-defun-type-regexp
	      (rx (or "function_definition"
		      "struct_definition")))
  (setq-local treesit-defun-name-function #'r-ts--defun-name)

  ;; Imenu.
  (setq-local treesit-simple-imenu-settings
	      `((nil "\\`function_definition\\'" nil nil)))

  (treesit-major-mode-setup))


;; adapted from julia-ts--defun-name
(defun r-ts--defun-name (node)
  "Return the defun name of NODE.
Return nil if there is no name or if NODE is not a defun node."
  (pcase (treesit-node-type node)
    ((or "function_definition" "class_definition")
     (treesit-node-text
      (treesit-node-child-by-field-name
       (treesit-node-parent node) "name")
      t))))


(provide 'r-ts-mode)

