;; Sample Fennel file — exercises Conjure eval, vim-sexp, parinfer, rainbow
;; delimiters, and treesitter highlight.

(fn greet [name]
  (.. "Hello, " name "!"))

(fn add [a b]
  (+ a b))

(local numbers [1 2 3 4 5])

(fn sum [xs]
  (var total 0)
  (each [_ x (ipairs xs)]
    (set total (+ total x)))
  total)

(fn map-fn [f xs]
  (let [out []]
    (each [_ x (ipairs xs)]
      (table.insert out (f x)))
    out))

;; Eval with Conjure:
;;   (greet "Fennel")
;;   (add 2 3)
;;   (sum numbers)
;;   (map-fn (fn [x] (* x x)) numbers)
