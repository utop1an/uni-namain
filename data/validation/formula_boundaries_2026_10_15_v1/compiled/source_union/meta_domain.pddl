(define (domain narrative_union)
  (:requirements :adl :equality :strips :typing)
  (:types
    d000__t_person d000__t_vacant - d000__t_object
    d001__t_foreign - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:constants
    d000__c_a - d000__t_person
    d001__c_outsider - d001__t_foreign
  )
  (:predicates
    (d000__p_done)
    (d000__p_e ?x - d000__t_vacant)
    (d000__p_p ?x - d000__t_person)
    (d000__p_r ?x - d000__t_person ?y - d000__t_person)
    (d001__p_other)
  )

  (:action d000__a_all_exists
    :parameters (?x - d000__t_person)
    :precondition (forall (?y - d000__t_person) (exists (?z - d000__t_person) (d000__p_r ?y ?z)))
    :effect (d000__p_done)
  )

  (:action d000__a_disjunction
    :parameters (?x - d000__t_person)
    :precondition (or (d000__p_p ?x) (not (d000__p_r ?x ?x)))
    :effect (d000__p_done)
  )

  (:action d000__a_empty_exists
    :parameters (?x - d000__t_person)
    :precondition (exists (?y - d000__t_vacant) (d000__p_e ?y))
    :effect (d000__p_done)
  )

  (:action d000__a_equality
    :parameters (?x - d000__t_person)
    :precondition (= ?x d000__c_a)
    :effect (d000__p_done)
  )

  (:action d000__a_exists_all
    :parameters (?x - d000__t_person)
    :precondition (exists (?y - d000__t_person) (forall (?z - d000__t_person) (d000__p_r ?y ?z)))
    :effect (d000__p_done)
  )

  (:action d000__a_implication
    :parameters (?x - d000__t_person)
    :precondition (imply (d000__p_p ?x) (exists (?y - d000__t_person) (d000__p_r ?x ?y)))
    :effect (d000__p_done)
  )

  (:action d000__a_inequality
    :parameters (?x - d000__t_person)
    :precondition (not (= ?x d000__c_a))
    :effect (d000__p_done)
  )

  (:action d000__a_negated_all
    :parameters (?x - d000__t_person)
    :precondition (not (forall (?y - d000__t_person) (d000__p_p ?y)))
    :effect (d000__p_done)
  )

  (:action d000__a_negated_exists
    :parameters (?x - d000__t_person)
    :precondition (not (exists (?y - d000__t_person) (d000__p_p ?y)))
    :effect (d000__p_done)
  )

  (:action d000__a_negative_empty_exists
    :parameters (?x - d000__t_person)
    :precondition (not (exists (?y - d000__t_vacant) (d000__p_e ?y)))
    :effect (d000__p_done)
  )

  (:action d000__a_negative_vacuous_all
    :parameters (?x - d000__t_person)
    :precondition (not (forall (?y - d000__t_vacant) (d000__p_e ?y)))
    :effect (d000__p_done)
  )

  (:action d000__a_shadowed_nested
    :parameters (?x - d000__t_person)
    :precondition (exists (?y - d000__t_person) (and (d000__p_p ?y) (forall (?y - d000__t_person) (d000__p_r ?y d000__c_a))))
    :effect (d000__p_done)
  )

  (:action d000__a_shadowed_parameter
    :parameters (?x - d000__t_person)
    :precondition (forall (?x - d000__t_person) (or (d000__p_p ?x) (d000__p_r ?x d000__c_a)))
    :effect (d000__p_done)
  )

  (:action d000__a_vacuous_all
    :parameters (?x - d000__t_person)
    :precondition (forall (?y - d000__t_vacant) (d000__p_e ?y))
    :effect (d000__p_done)
  )

  (:action d001__a_touch
    :parameters ()
    :precondition (and)
    :effect (d001__p_other)
  )
)
