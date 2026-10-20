(define (domain narrative_union)
  (:requirements :adl :strips :typing)
  (:types
    d000__t_item - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_a d000__c_b - d000__t_item
  )
  (:predicates
    (d000__p_p ?x - d000__t_item)
    (d000__p_q ?x - d000__t_item)
  )

  (:action d000__a_spread
    :parameters (?x - d000__t_item)
    :precondition (and)
    :effect (when (d000__p_p ?x) (forall (?x - d000__t_item) (d000__p_q ?x)))
  )
)
