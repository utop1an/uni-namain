(define (domain capture)
      (:requirements :strips :typing) (:types person - object) (:constants prisoner - person)
      (:predicates (alive ?p - person) (captured ?p - person))
      (:action capture_alive :parameters (?p - person) :precondition (alive ?p) :effect (captured ?p)))