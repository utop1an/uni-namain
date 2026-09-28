(define (domain hear) (:requirements :strips :typing) (:types person - object)
          (:predicates (messenger_present ?p - person) (rumor_known ?p - person))
          (:action hear_report :parameters (?p - person) :precondition (messenger_present ?p)
           :effect (rumor_known ?p)))