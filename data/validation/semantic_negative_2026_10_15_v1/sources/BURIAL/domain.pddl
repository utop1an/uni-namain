(define (domain burial)
      (:requirements :strips :typing) (:types person - object) (:constants corpse - person)
      (:predicates (dead ?p - person) (buried ?p - person))
      (:action bury :parameters (?p - person) :precondition (dead ?p) :effect (buried ?p)))