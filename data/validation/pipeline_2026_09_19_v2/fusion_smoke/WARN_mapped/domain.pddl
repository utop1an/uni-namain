(define (domain unified_narrative_domain)
  (:requirements :strips :typing)
  (:types
    person - object
  )
  (:predicates
    (messenger_present ?p - person)
    (rumor_known ?p - person)
    (warning_delivered ?p - person)
  )

  (:action hear_report
    :parameters (?p - person)
    :precondition (messenger_present ?p)
    :effect (rumor_known ?p)
  )

  (:action warn_village
    :parameters (?p - person)
    :precondition (rumor_known ?p)
    :effect (warning_delivered ?p)
  )
)
