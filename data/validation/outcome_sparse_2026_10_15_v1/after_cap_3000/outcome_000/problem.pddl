(define (problem p) (:domain t) (:init (owned a) (owned b) (ready a) (done c)) (:goal (and (done a) (done b) (not (ready a)))))
