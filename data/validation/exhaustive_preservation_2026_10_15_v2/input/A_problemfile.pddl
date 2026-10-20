(define (problem source_a_problem) (:domain source_a)
      (:objects b - person) (:init) (:goal (and (forall (?p - person) (done ?p)) (not (rel b a)))))