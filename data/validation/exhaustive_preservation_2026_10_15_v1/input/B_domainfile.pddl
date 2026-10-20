(define (domain source_b) (:requirements :strips :typing)
      (:types person - object) (:constants outsider - person)
      (:predicates (reverse_rel ?q ?p - person))
      (:action foreign :parameters (?q ?p - person) :precondition (and) :effect (reverse_rel ?q ?p)))