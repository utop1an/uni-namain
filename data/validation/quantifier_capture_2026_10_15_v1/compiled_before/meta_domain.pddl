(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_a d000__c_b - object
  )
  (:predicates
    (d000__p_p ?a0 - object)
    (d000__p_q ?a0 - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_spread
    :parameters (?x - object)
    :precondition (and (typeguard__d000__t_item ?x) (and))
    :effect (forall (?x - object) (when (and (d000__p_p ?x) (typeguard__d000__t_item ?x)) (d000__p_q ?x)))
  )
)
