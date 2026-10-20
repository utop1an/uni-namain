(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_person - d000__t_object
    d001__t_person - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:predicates
    (d000__p_messenger_present ?p - d000__t_person)
    (d000__p_rumor_known ?p - d000__t_person)
    (d001__p_rumor_known ?p - d001__t_person)
    (d001__p_warning_delivered ?p - d001__t_person)
  )

  (:action d000__a_hear_report
    :parameters (?p - d000__t_person)
    :precondition (d000__p_messenger_present ?p)
    :effect (d000__p_rumor_known ?p)
  )

  (:action d001__a_warn_village
    :parameters (?p - d001__t_person)
    :precondition (d001__p_rumor_known ?p)
    :effect (d001__p_warning_delivered ?p)
  )
)
