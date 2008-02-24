;; Experimental infix math syntax for Arc.
;;
;; written by Elliott Slaughter 2008-02-22
;;
;; Released under the Perl Foundation's Artistic License 2.0.
;; http://www.perlfoundation.org/artistic_license_2_0

(let +_ +
  (tostring
   (def + args
     (if (some [isa _ 'fn] args)
         (infix-eval (cons (car args) (cons + (cdr args))))
         (apply +_ args)))))

(let -_ -
  (tostring
   (def - args
     (if (some [isa _ 'fn] args)
         (infix-eval (cons (car args) (cons - (cdr args))))
         (apply -_ args)))))

(let *_ *
  (tostring
  (def * args
    (if (some [isa _ 'fn] args)
        (infix-eval (cons (car args) (cons * (cdr args))))
        (apply *_ args)))))

(let /_ /
  (tostring
   (def / args
     (if (some [isa _ 'fn] args)
         (infix-eval (cons (car args) (cons / (cdr args))))
         (apply /_ args)))))

(let precedences `((,+ 1) (,- 1) (,* 2) (,/ 2))
  (def precedence (op)
    (or (alref precedences op) 0))
  
  (def set-precedence (op n)
    (let n (if (isa n 'fn) (precedence n) n)
      (= precedences (cons (list op n) precedences))
      n)))

(defset precedence (x)
  (w/uniq g
    (list (list g x)
          `(precedence ,g)
          `(fn (val) (set-precedence ,g val)))))

(def op< args
  (apply < (map precedence args)))

(def op<= args
  (apply <= (map precedence args)))

(def op> args
  (apply > (map precedence args)))

(def op>= args
  (apply >= (map precedence args)))

(def in->pre (infix prefix ops)
  (if infix
      (if ([or (isa _ 'int) (isa _ 'num)] car.infix)
          (in->pre cdr.infix (cons car.infix prefix) ops)
          ([isa _ 'fn] car.infix)
          (if (and ops (op<= car.infix car.ops))
              (in->pre
                infix
                (cons (list car.ops car.prefix cadr.prefix) cddr.prefix)
                cdr.ops)
              (in->pre cdr.infix prefix (cons car.infix ops))))
      (if ops
          (if (cdr ops)
              (in->pre
                infix
                (cons (list car.ops car.prefix cadr.prefix) cddr.prefix)
                cdr.ops)
              (in->pre infix (list (cons car.ops prefix)) cdr.ops))
          prefix)))

(def infix-eval (infix)
  (let prefix (in->pre (rev infix) nil nil)
    (if (acons prefix)
        (eval car.prefix)
        (eval prefix))))