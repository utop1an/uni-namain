(define (problem formula_problem) (:domain formula_a) (:objects b - person) (:init)
    (:goal (and (forall (?x - person) (exists (?y - person) (= ?x ?y)))
                (not (exists (?v - vacant) (e ?v))) (done))))