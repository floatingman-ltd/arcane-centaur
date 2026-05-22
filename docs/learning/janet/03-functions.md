# 03 — Functions in Depth with Janet

← [Previous](02-first-steps.md) | [Index](README.md) | [Next](04-sequences.md) →

---

Functions are the primary building block in Janet. This lesson goes beyond `defn` to cover closures, short-hand function syntax, higher-order functions, the threading macros, and `apply`. Work through every snippet interactively — evaluate as you read.

Open a scratch file and the Conjure log before starting:

```sh
nvim scratch.janet
```

```
,lv
```

---

## 1. Functions Are Values

In Janet, functions are first-class values. You can pass them to other functions, return them, and store them in data structures.

```janet
# Named function
(defn square [x] (* x x))

# Anonymous function stored in a binding
(def cube (fn [x] (* x x x)))

# Short-hand: # creates an anonymous fn, % is the first argument
(def double #(* % 2))

(square 5)    # => 25
(cube 3)      # => 27
(double 7)    # => 14
```

**Try it:** evaluate `(square 5)` with `,ee`, then `(double 7)`. Notice that all three definitions behave identically from the caller's perspective.

The short-hand `#(...)` is handy for small inline functions. `%` is the first argument, `%2` the second, `%3` the third:

```janet
(def add #(+ % %2))
(add 3 4)   # => 7
```

---

## 2. Closures

A function defined inside another function *closes over* the bindings visible at the point of definition. Those bindings survive as long as the closure does.

```janet
(defn make-adder [n]
  (fn [x] (+ x n)))   # closes over n

(def add10 (make-adder 10))
(def add100 (make-adder 100))

(add10 5)    # => 15
(add100 5)   # => 105
```

**Try it:** evaluate `(def add10 (make-adder 10))` with `,er`, then call `(add10 42)` with `,ee`.

Closures are useful for building configurable functions:

```janet
(defn make-greeter [greeting]
  (fn [name] (string greeting ", " name "!")))

(def hi  (make-greeter "Hi"))
(def hey (make-greeter "Hey"))

(hi "Alice")    # => "Hi, Alice!"
(hey "Bob")     # => "Hey, Bob!"
```

Use vim-sexp to refactor: position the cursor on `"Hi"` inside `make-greeter` and press `K` to hover its type — then try `>)` to experiment with slurping.

---

## 3. Higher-Order Functions

Janet's standard library is built around passing functions to other functions.

### map

Apply a function to every element of a sequence, collect results into a tuple:

```janet
(map square [1 2 3 4 5])
# => (1 4 9 16 25)

(map string/upcase ["alice" "bob" "carol"])
# => ("ALICE" "BOB" "CAROL")
```

**Try it:** evaluate `(map square [1 2 3 4 5])` with `,ee`.

### filter

Keep only elements for which the predicate returns truthy:

```janet
(filter even? [1 2 3 4 5 6])
# => (2 4 6)

(filter #(> % 3) [1 2 3 4 5])
# => (4 5)
```

### reduce

Fold a sequence into a single value using an accumulator:

```janet
(reduce + 0 [1 2 3 4 5])    # => 15  (sum)
(reduce * 1 [1 2 3 4 5])    # => 120 (product)
(reduce max 0 [3 1 4 1 5])  # => 5
```

`reduce` takes `(reduce f init seq)` — `f` receives the running accumulator and the current element.

**Try it:** write `(reduce + 0 [1 2 3 4 5])` and evaluate with `,ee`. Then modify the initial value and observe how it shifts the result.

### Composing map and filter

```janet
(->> [1 2 3 4 5 6 7 8 9 10]
     (filter even?)
     (map square))
# => (4 16 36 64 100)
```

(The `->>` threading macro is covered next — evaluate this after section 4.)

---

## 4. Threading Macros

Nested function calls can be hard to read. Threading macros pipe the result of each expression into the next as the **last** (`->>`) or **first** (`->`) argument.

### -> (thread-first)

```janet
# Without threading:
(string/upcase (string/trim "  hello  "))

# With ->:
(-> "  hello  "
    string/trim
    string/upcase)
# => "HELLO"
```

Each step receives the previous result as its **first** argument.

**Try it:** evaluate both forms with `,ee` — confirm they produce the same result.

### ->> (thread-last)

```janet
# Without threading:
(map square (filter even? [1 2 3 4 5 6]))

# With ->>:
(->> [1 2 3 4 5 6]
     (filter even?)
     (map square))
# => (4 16 36)
```

Each step receives the previous result as its **last** argument — ideal for sequence pipelines where the data is the last parameter.

**Try it:** use vim-sexp's `>)` slurp on the `->>` form to pull an extra step in, then `,ee` to re-evaluate.

### When to use which

| Macro | Use when | Data position |
|---|---|---|
| `->` | String transforms, record updates | First arg |
| `->>` | Sequence pipelines (map/filter/reduce) | Last arg |

---

## 5. apply

`apply` calls a function with a sequence as its argument list. Useful when you have arguments in a collection:

```janet
(apply + [1 2 3 4 5])      # => 15
(apply string ["a" "b" "c"])  # => "abc"
(apply max [3 1 4 1 5 9])  # => 9
```

You can mix fixed args with a trailing sequence:

```janet
(apply + 10 20 [1 2 3])   # => 36  (10 + 20 + 1 + 2 + 3)
```

**Try it:** evaluate `(apply max [3 1 4 1 5 9])` and confirm with `,ee`.

---

## 6. Variadic Functions

A function can accept any number of arguments with `& rest`:

```janet
(defn sum [& nums]
  (reduce + 0 nums))

(sum 1 2 3)           # => 6
(sum 1 2 3 4 5 6 7)   # => 28
```

Required arguments come before `&`:

```janet
(defn greet-many [greeting & names]
  (each name names
    (print (string greeting ", " name "!"))))

(greet-many "Hello" "Alice" "Bob" "Carol")
```

**Try it:** evaluate `(greet-many "Hi" "Alice" "Bob")` and watch the Conjure log.

---

## 7. Mini-Project: Word Frequency Pipeline

Build a small word-frequency counter using closures, higher-order functions, and threading.

Put this in `scratch.janet` and evaluate each form in order with `,er`:

```janet
# Step 1: define helpers

(defn words [text]
  (string/split " " (string/trim (string/lower-case text))))

(defn count-words [acc word]
  (put acc word (inc (get acc word 0)))
  acc)

(defn top-n [n freq-table]
  (->> (pairs freq-table)
       (sort-by (fn [[_ count]] (- count)))
       (take n)))
```

```janet
# Step 2: build the pipeline

(def sample
  "the quick brown fox jumps over the lazy dog the fox")

(def frequencies
  (->> sample
       words
       (reduce count-words @{})))

frequencies   # evaluate with ,ee — inspect the table
```

```janet
# Step 3: find the top 3 words

(top-n 3 frequencies)
# => (("the" 3) ("fox" 2) ...)
```

**Workflow:**
1. Evaluate the helpers block with `,eb` — all three functions enter the REPL state.
2. Evaluate `(def frequencies ...)` with `,er`.
3. Place the cursor on `frequencies` and press `,ee` — inspect the table in the Conjure log.
4. Evaluate `(top-n 3 frequencies)` with `,ee`.
5. Try changing `sample` to your own sentence and re-running from step 2.

---

## 8. What to Explore Next

- **Next lesson:** [04 — Sequences](04-sequences.md) — the `seq` macro, generators, and lazy iteration
- **REPL exploration:** call `(doc map)`, `(doc filter)`, `(doc reduce)` in the REPL to read built-in documentation inline
- **Cheatsheet:** `docs/cheatsheets/janet.md` — quick reference for Conjure and vim-sexp keymaps
- **Janet docs:** [janet-lang.org/docs/](https://janet-lang.org/docs/) — Functions, Macros, and the Core library reference
