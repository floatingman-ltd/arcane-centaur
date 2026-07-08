(ns hello
  "Sample Clojure file — exercises Conjure eval, vim-sexp, parinfer, rainbow
  delimiters, and treesitter highlight. Connect an nREPL, then eval forms with
  <localleader>ee (form) / <localleader>er (root form).")

(defn greet
  "Return a greeting for `name`."
  [name]
  (str "Hello, " name "!"))

(defn add [a b]
  (+ a b))

(def numbers [1 2 3 4 5])

(defn sum-of-squares
  "Sum the squares of a collection of numbers."
  [xs]
  (->> xs
       (map #(* % %))
       (reduce + 0)))

(defn fizzbuzz [n]
  (cond
    (zero? (mod n 15)) "fizzbuzz"
    (zero? (mod n 3))  "fizz"
    (zero? (mod n 5))  "buzz"
    :else              (str n)))

(comment
  ;; Eval these individually with Conjure:
  (greet "Clojure")
  (add 2 3)
  (sum-of-squares numbers)
  (map fizzbuzz (range 1 16)))
