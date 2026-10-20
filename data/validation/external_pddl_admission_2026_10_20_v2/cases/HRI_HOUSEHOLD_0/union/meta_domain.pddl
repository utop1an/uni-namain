(define (domain narrative_union)
  (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
  (:types
    d000__t_apple d000__t_cloth d000__t_diningtableloc d000__t_drawerloc d000__t_household_object d000__t_kitchencounterloc d000__t_location d000__t_lunchboxreceptacle d000__t_receptacle d000__t_robot d000__t_robot1 - d000__t_object
    d000__t_object - object
  )
  (:predicates
    (d000__p_drawerisopen ?drawer - d000__t_location)
    (d000__p_isat ?who - d000__t_robot ?from - d000__t_location)
    (d000__p_isholding ?who - d000__t_robot ?what - d000__t_household_object)
    (d000__p_isholdingreceptacle ?who - d000__t_robot ?what - d000__t_receptacle)
    (d000__p_objectisat ?what - d000__t_household_object ?from - d000__t_location)
    (d000__p_objectisinside ?what - d000__t_household_object ?insideWhat - d000__t_receptacle)
    (d000__p_receptacleisat ?what - d000__t_receptacle ?from - d000__t_location)
  )

  (:action d000__a_navigate
    :parameters (?who - d000__t_robot ?from - d000__t_location ?to - d000__t_location)
    :precondition (and (d000__p_isat ?who ?from) (not (d000__p_isat ?who ?to)))
    :effect (and (not (d000__p_isat ?who ?from)) (d000__p_isat ?who ?to))
  )

  (:action d000__a_opendrawer
    :parameters (?who - d000__t_robot ?drawer - d000__t_location)
    :precondition (d000__p_isat ?who ?drawer)
    :effect (d000__p_drawerisopen ?drawer)
  )

  (:action d000__a_pick
    :parameters (?who - d000__t_robot ?from - d000__t_location ?what - d000__t_household_object)
    :precondition (and (d000__p_isat ?who ?from) (d000__p_objectisat ?what ?from))
    :effect (and (d000__p_isholding ?who ?what) (not (d000__p_objectisat ?what ?from)))
  )

  (:action d000__a_pickreceptacle
    :parameters (?who - d000__t_robot ?from - d000__t_location ?what - d000__t_receptacle)
    :precondition (and (d000__p_isat ?who ?from) (d000__p_receptacleisat ?what ?from))
    :effect (and (d000__p_isholdingreceptacle ?who ?what) (not (d000__p_receptacleisat ?what ?from)))
  )

  (:action d000__a_place
    :parameters (?who - d000__t_robot ?what - d000__t_household_object ?at - d000__t_location)
    :precondition (and (d000__p_isholding ?who ?what) (d000__p_isat ?who ?at))
    :effect (and (not (d000__p_isholding ?who ?what)) (d000__p_objectisat ?what ?at))
  )

  (:action d000__a_placeinside
    :parameters (?who - d000__t_robot ?what - d000__t_household_object ?insideWhat - d000__t_receptacle)
    :precondition (and (d000__p_isholding ?who ?what) (d000__p_isholdingreceptacle ?who ?insideWhat))
    :effect (and (not (d000__p_isholding ?who ?what)) (d000__p_objectisinside ?what ?insideWhat))
  )

  (:action d000__a_placereceptacle
    :parameters (?who - d000__t_robot ?what - d000__t_receptacle ?at - d000__t_location)
    :precondition (and (d000__p_isholdingreceptacle ?who ?what) (d000__p_isat ?who ?at))
    :effect (and (not (d000__p_isholdingreceptacle ?who ?what)) (d000__p_receptacleisat ?what ?at))
  )
)
