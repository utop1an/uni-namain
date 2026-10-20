(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_object - object
  )
  (:predicates
    (d000__p_above ?floor1 - d000__t_object ?floor2 - d000__t_object)
    (d000__p_boarded ?person - d000__t_object)
    (d000__p_destin ?person - d000__t_object ?floor - d000__t_object)
    (d000__p_floor ?floor - d000__t_object)
    (d000__p_lift-at ?floor - d000__t_object)
    (d000__p_origin ?person - d000__t_object ?floor - d000__t_object)
    (d000__p_passenger ?passenger - d000__t_object)
    (d000__p_served ?person - d000__t_object)
  )

  (:action d000__a_board
    :parameters (?f - d000__t_object ?p - d000__t_object)
    :precondition (and (d000__p_floor ?f) (d000__p_passenger ?p) (d000__p_lift-at ?f) (d000__p_origin ?p ?f))
    :effect (d000__p_boarded ?p)
  )

  (:action d000__a_depart
    :parameters (?f - d000__t_object ?p - d000__t_object)
    :precondition (and (d000__p_floor ?f) (d000__p_passenger ?p) (d000__p_lift-at ?f) (d000__p_destin ?p ?f) (d000__p_boarded ?p))
    :effect (and (not (d000__p_boarded ?p)) (d000__p_served ?p))
  )

  (:action d000__a_down
    :parameters (?f1 - d000__t_object ?f2 - d000__t_object)
    :precondition (and (d000__p_floor ?f1) (d000__p_floor ?f2) (d000__p_lift-at ?f1) (d000__p_above ?f2 ?f1))
    :effect (and (d000__p_lift-at ?f2) (not (d000__p_lift-at ?f1)))
  )

  (:action d000__a_up
    :parameters (?f1 - d000__t_object ?f2 - d000__t_object)
    :precondition (and (d000__p_floor ?f1) (d000__p_floor ?f2) (d000__p_lift-at ?f1) (d000__p_above ?f1 ?f2))
    :effect (and (d000__p_lift-at ?f2) (not (d000__p_lift-at ?f1)))
  )
)
