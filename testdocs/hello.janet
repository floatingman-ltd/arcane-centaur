# Sample Janet file — exercises Conjure eval, vim-sexp, parinfer, rainbow
# delimiters, and treesitter highlight. Has real `defn` forms so vim-sexp
# form objects and Conjure eval have something to act on.

(defn greet
  "Return a greeting for name."
  [name]
  (string "Hello, " name "!"))

(defn add [a b]
  (+ a b))

(def numbers [1 2 3 4 5])

(defn sum
  "Sum a collection of numbers."
  [xs]
  (var total 0)
  (each x xs
    (+= total x))
  total)

# Eval with Conjure:
#   (greet "Janet")
#   (add 2 3)
#   (sum numbers)
(print (greet "World"))
