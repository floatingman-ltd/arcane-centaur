;;; Sample Common Lisp file — exercises Conjure/Swank eval, vim-sexp, parinfer,
;;; rainbow delimiters, and treesitter (commonlisp) highlight. Common Lisp uses
;;; `defun` (Clojure's `defn` equivalent). Put the cursor inside a form and press
;;; `vaf` — vim-sexp selects the surrounding s-expression.

(defun greet (name)
  "Return a greeting for NAME."
  (format nil "Hello, ~a!" name))

(defun add (a b)
  (+ a b))

(defparameter *numbers* '(1 2 3 4 5))

(defun sum (xs)
  "Sum a list of numbers."
  (reduce #'+ xs :initial-value 0))

;; Eval with Conjure (connect Swank first):
;;   (greet "Lisp")
;;   (add 2 3)
;;   (sum *numbers*)
(format t "~a~%" (greet "World"))

;;; --- Indent fixture -------------------------------------------------------
;;; Exercises the `lispwords` entries added in after/ftplugin/lisp.lua
;;; (defmethod, defgeneric, defclass, define, letrec). The body of each of
;;; these should indent as a definition body, not as a function call's
;;; arguments. See openspec TEST_PLAN, change align-treesitter-providers, AT.3.

(defclass shape ()
  ((name :initarg :name :accessor shape-name)
   (area :initarg :area :accessor shape-area)))

(defgeneric describe-shape (shape)
  (:documentation "Return a human-readable description of SHAPE."))

(defmethod describe-shape ((s shape))
  (format nil "~a has area ~a"
          (shape-name s)
          (shape-area s)))

(defun classify (shapes)
  (let ((large '())
        (small '()))
    (dolist (s shapes)
      (if (> (shape-area s) 100)
          (push s large)
          (push s small)))
    (values large small)))
