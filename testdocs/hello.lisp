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
