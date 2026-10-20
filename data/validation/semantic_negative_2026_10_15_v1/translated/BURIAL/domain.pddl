(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_corpse d001__c_prisoner - object
  )
  (:predicates
    (d000__p_buried ?a0 - object)
    (d001__p_alive ?a0 - object)
    (shared__p_captured_is_dead ?a0 - object)
    (typeguard__d000__t_object ?member - object)
    (typeguard__d000__t_person ?member - object)
    (typeguard__d001__t_object ?member - object)
    (typeguard__d001__t_person ?member - object)
  )

  (:action d000__a_bury
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_person ?p) (shared__p_captured_is_dead ?p))
    :effect (d000__p_buried ?p)
  )

  (:action d001__a_capture_alive
    :parameters (?p - object)
    :precondition (and (typeguard__d001__t_person ?p) (d001__p_alive ?p))
    :effect (shared__p_captured_is_dead ?p)
  )
)
