(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_person - d000__t_object
    d001__t_person - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:constants
    d000__c_corpse - d000__t_person
    d001__c_prisoner - d001__t_person
  )
  (:predicates
    (d000__p_buried ?p - d000__t_person)
    (d000__p_dead ?p - d000__t_person)
    (d001__p_alive ?p - d001__t_person)
    (d001__p_captured ?p - d001__t_person)
  )

  (:action d000__a_bury
    :parameters (?p - d000__t_person)
    :precondition (d000__p_dead ?p)
    :effect (d000__p_buried ?p)
  )

  (:action d001__a_capture_alive
    :parameters (?p - d001__t_person)
    :precondition (d001__p_alive ?p)
    :effect (d001__p_captured ?p)
  )
)
