(define (domain narrative_union)
  (:requirements :adl :strips :typing)
  (:types
    d000__t_person - d000__t_object
    d000__t_apprentice - d000__t_person
    d001__t_person - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:constants
    d000__c_a - d000__t_apprentice
    d001__c_outsider - d001__t_person
  )
  (:predicates
    (d000__p_done ?p - d000__t_person)
    (d000__p_ready ?p - d000__t_person)
    (d000__p_rel ?p - d000__t_person ?q - d000__t_person)
    (d001__p_reverse_rel ?q - d001__t_person ?p - d001__t_person)
  )

  (:action d000__a_absent
    :parameters (?p - d000__t_person)
    :precondition (not (exists (?q - d000__t_person) (d000__p_rel ?p ?q)))
    :effect (d000__p_done ?p)
  )

  (:action d000__a_apprentice_step
    :parameters (?p - d000__t_apprentice)
    :precondition (d000__p_ready ?p)
    :effect (d000__p_done ?p)
  )

  (:action d000__a_clear_all
    :parameters ()
    :precondition (forall (?p - d000__t_person) (d000__p_done ?p))
    :effect (forall (?p - d000__t_person) (not (d000__p_ready ?p)))
  )

  (:action d000__a_conditional
    :parameters (?p - d000__t_person)
    :precondition (exists (?q - d000__t_person) (d000__p_ready ?q))
    :effect (when (d000__p_ready ?p) (d000__p_done ?p))
  )

  (:action d000__a_finish_all
    :parameters ()
    :precondition (forall (?p - d000__t_person) (d000__p_ready ?p))
    :effect (forall (?p - d000__t_person) (d000__p_done ?p))
  )

  (:action d000__a_follow
    :parameters (?p - d000__t_person ?q - d000__t_person)
    :precondition (d000__p_rel ?p ?q)
    :effect (d000__p_done ?q)
  )

  (:action d000__a_link
    :parameters (?p - d000__t_person ?q - d000__t_person)
    :precondition (d000__p_ready ?p)
    :effect (d000__p_rel ?p ?q)
  )

  (:action d000__a_prepare
    :parameters (?p - d000__t_person)
    :precondition (not (d000__p_ready ?p))
    :effect (d000__p_ready ?p)
  )

  (:action d001__a_foreign
    :parameters (?q - d001__t_person ?p - d001__t_person)
    :precondition (and)
    :effect (d001__p_reverse_rel ?q ?p)
  )
)
