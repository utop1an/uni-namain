(define (problem p) (:domain t) (:init (owned a) (owned b) (ready a) (done c)) (:goal (and (not (ready a)) (done a) (done b))))
