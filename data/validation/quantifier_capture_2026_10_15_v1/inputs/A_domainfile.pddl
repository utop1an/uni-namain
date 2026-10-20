(define (domain shadow) (:requirements :adl :typing) (:types item)
 (:constants a b - item) (:predicates (p ?x - item) (q ?x - item))
 (:action spread :parameters (?x - item) :precondition (and)
 :effect (when (p ?x) (forall (?x - item) (q ?x)))))