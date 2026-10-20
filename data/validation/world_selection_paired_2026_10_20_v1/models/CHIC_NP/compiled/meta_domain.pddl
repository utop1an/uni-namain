(define (domain narrative_aligned)
  (:requirements :adl :existential-preconditions :negative-preconditions :strips :typing)
  (:constants
    d000__c_acorn d000__c_chicken-licken d000__c_cock-lock d000__c_drake-lake d000__c_duck-luck d000__c_fox-lox d000__c_foxhole d000__c_gander-lander d000__c_goose-loose d000__c_hen-len d000__c_king d000__c_sky d000__c_turkey-lurkey d000__c_wood - object
  )
  (:predicates
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_decided_to_tell_king ?a0 - object)
    (d000__p_eaten_by_fox ?a0 - object)
    (d000__p_following_fox ?a0 - object)
    (d000__p_going_to_wood ?a0 - object)
    (d000__p_informed_about_sky_fall ?a0 - object ?a1 - object)
    (d000__p_met ?a0 - object ?a1 - object)
    (d000__p_sky_fell_on_head ?a0 - object)
    (d000__p_turned_back ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_be_eaten_by_fox
    :parameters (?e - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?e) (typeguard__d000__t_location ?l) (and (d000__p_following_fox ?e) (d000__p_at ?e ?l) (not (d000__p_eaten_by_fox ?e))))
    :effect (and (d000__p_at ?e d000__c_foxhole) (d000__p_eaten_by_fox ?e) (not (d000__p_at ?e ?l)) (not (d000__p_following_fox ?e)))
  )

  (:action d000__a_decide_to_tell_king
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (exists (?bound_scope_0 - object) (and (typeguard__d000__t_entity ?bound_scope_0) (d000__p_informed_about_sky_fall ?bound_scope_0 ?e))) (not (d000__p_decided_to_tell_king ?e))))
    :effect (d000__p_decided_to_tell_king ?e)
  )

  (:action d000__a_follow_fox
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (d000__p_decided_to_tell_king ?e) (not (d000__p_following_fox ?e))))
    :effect (d000__p_following_fox ?e)
  )

  (:action d000__a_go_to_wood
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (not (d000__p_at ?e d000__c_wood)) (not (d000__p_going_to_wood ?e))))
    :effect (d000__p_going_to_wood ?e)
  )

  (:action d000__a_inform_about_sky_fall
    :parameters (?informer - object ?listener - object)
    :precondition (and (typeguard__d000__t_entity ?informer) (typeguard__d000__t_entity ?listener) (and (d000__p_met ?informer ?listener) (d000__p_sky_fell_on_head d000__c_chicken-licken) (not (d000__p_informed_about_sky_fall ?informer ?listener))))
    :effect (d000__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d000__a_meet_character
    :parameters (?e1 - object ?e2 - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?e1) (typeguard__d000__t_entity ?e2) (typeguard__d000__t_location ?l) (and (d000__p_at ?e1 ?l) (d000__p_at ?e2 ?l) (not (d000__p_met ?e1 ?e2))))
    :effect (and (d000__p_met ?e1 ?e2) (d000__p_met ?e2 ?e1))
  )

  (:action d000__a_turn_back
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (d000__p_going_to_wood ?e) (not (d000__p_turned_back ?e))))
    :effect (and (d000__p_turned_back ?e) (not (d000__p_going_to_wood ?e)))
  )
)
