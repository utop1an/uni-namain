(define (domain warn) (:requirements :strips :typing) (:types person - object)
          (:predicates (rumor_known ?p - person) (warning_delivered ?p - person))
          (:action warn_village :parameters (?p - person) :precondition (rumor_known ?p)
           :effect (warning_delivered ?p)))