;; Sample Scheme file — exercises Conjure eval, vim-sexp, parinfer, rainbow
;; delimiters, and treesitter highlight.

(define (greet name)
  (string-append "Hello, " name "!"))

(define (factorial n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(define numbers '(1 2 3 4 5))

(define (sum lst)
  (if (null? lst)
      0
      (+ (car lst) (sum (cdr lst)))))

(define (map-square lst)
  (map (lambda (x) (* x x)) lst))

;; Eval with Conjure:
;;   (greet "Scheme")
;;   (factorial 5)
;;   (sum numbers)
;;   (map-square numbers)
