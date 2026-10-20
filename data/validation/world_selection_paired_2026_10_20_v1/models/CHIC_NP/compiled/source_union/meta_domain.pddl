(define (domain narrative_union)
  (:requirements :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_chicken-licken d000__c_cock-lock d000__c_drake-lake d000__c_duck-luck d000__c_fox-lox d000__c_gander-lander d000__c_goose-loose d000__c_hen-len d000__c_king d000__c_turkey-lurkey - d000__t_entity
    d000__c_acorn d000__c_sky - d000__t_item
    d000__c_foxhole d000__c_wood - d000__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_decided_to_tell_king ?e - d000__t_entity)
    (d000__p_eaten_by_fox ?e - d000__t_entity)
    (d000__p_following_fox ?e - d000__t_entity)
    (d000__p_going_to_wood ?e - d000__t_entity)
    (d000__p_informed_about_sky_fall ?informer - d000__t_entity ?listener - d000__t_entity)
    (d000__p_met ?e1 - d000__t_entity ?e2 - d000__t_entity)
    (d000__p_sky_fell_on_head ?e - d000__t_entity)
    (d000__p_turned_back ?e - d000__t_entity)
  )

  (:action d000__a_be_eaten_by_fox
    :parameters (?e - d000__t_entity ?l - d000__t_location)
    :precondition (and (d000__p_following_fox ?e) (d000__p_at ?e ?l) (not (d000__p_eaten_by_fox ?e)))
    :effect (and (d000__p_at ?e d000__c_foxhole) (d000__p_eaten_by_fox ?e) (not (d000__p_at ?e ?l)) (not (d000__p_following_fox ?e)))
  )

  (:action d000__a_decide_to_tell_king
    :parameters (?e - d000__t_entity)
    :precondition (and (exists (?inf - d000__t_entity) (d000__p_informed_about_sky_fall ?inf ?e)) (not (d000__p_decided_to_tell_king ?e)))
    :effect (d000__p_decided_to_tell_king ?e)
  )

  (:action d000__a_follow_fox
    :parameters (?e - d000__t_entity)
    :precondition (and (d000__p_decided_to_tell_king ?e) (not (d000__p_following_fox ?e)))
    :effect (d000__p_following_fox ?e)
  )

  (:action d000__a_go_to_wood
    :parameters (?e - d000__t_entity)
    :precondition (and (not (d000__p_at ?e d000__c_wood)) (not (d000__p_going_to_wood ?e)))
    :effect (d000__p_going_to_wood ?e)
  )

  (:action d000__a_inform_about_sky_fall
    :parameters (?informer - d000__t_entity ?listener - d000__t_entity)
    :precondition (and (d000__p_met ?informer ?listener) (d000__p_sky_fell_on_head d000__c_chicken-licken) (not (d000__p_informed_about_sky_fall ?informer ?listener)))
    :effect (d000__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d000__a_meet_character
    :parameters (?e1 - d000__t_entity ?e2 - d000__t_entity ?l - d000__t_location)
    :precondition (and (d000__p_at ?e1 ?l) (d000__p_at ?e2 ?l) (not (d000__p_met ?e1 ?e2)))
    :effect (and (d000__p_met ?e1 ?e2) (d000__p_met ?e2 ?e1))
  )

  (:action d000__a_turn_back
    :parameters (?e - d000__t_entity)
    :precondition (and (d000__p_going_to_wood ?e) (not (d000__p_turned_back ?e)))
    :effect (and (d000__p_turned_back ?e) (not (d000__p_going_to_wood ?e)))
  )
)
