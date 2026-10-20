(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_ass d000__c_beam d000__c_bremen d000__c_captain d000__c_cat d000__c_cock d000__c_drinks d000__c_forest d000__c_hearth d000__c_hound d000__c_kettledrums d000__c_lute d000__c_man d000__c_meat d000__c_messenger d000__c_road_to_bremen d000__c_robber d000__c_robbers_cottage d000__c_straw d000__c_table d000__c_window - object
  )
  (:predicates
    (d000__p_agreed ?a0 - object ?a1 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_ate_all ?a0 - object)
    (d000__p_attacked ?a0 - object ?a1 - object)
    (d000__p_attempt_light ?a0 - object)
    (d000__p_bite ?a0 - object ?a1 - object)
    (d000__p_crowed ?a0 - object)
    (d000__p_fled ?a0 - object ?a1 - object)
    (d000__p_invited ?a0 - object ?a1 - object)
    (d000__p_kick ?a0 - object ?a1 - object)
    (d000__p_light_off ?a0 - object)
    (d000__p_light_on ?a0 - object)
    (d000__p_making_noise ?a0 - object)
    (d000__p_moving_towards ?a0 - object ?a1 - object)
    (d000__p_resting ?a0 - object)
    (d000__p_retreated ?a0 - object)
    (d000__p_sees_light ?a0 - object)
    (d000__p_sleeping_at ?a0 - object ?a1 - object)
    (d000__p_stacked_on ?a0 - object ?a1 - object)
    (d000__p_window_shattered)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_approach_cottage
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object ?cottage - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?forest) (and (d000__p_sees_light ?cock) (d000__p_at ?donkey ?forest) (d000__p_at ?hound ?forest) (d000__p_at ?cat ?forest) (d000__p_at ?cock ?forest)))
    :effect (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage) (d000__p_moving_towards ?donkey ?cottage) (d000__p_moving_towards ?hound ?cottage) (d000__p_moving_towards ?cat ?cottage) (d000__p_moving_towards ?cock ?cottage) (not (d000__p_at ?donkey ?forest)) (not (d000__p_at ?hound ?forest)) (not (d000__p_at ?cat ?forest)) (not (d000__p_at ?cock ?forest)))
  )

  (:action d000__a_cat_agrees
    :parameters (?cat - object ?donkey - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?donkey) (d000__p_invited ?donkey ?cat))
    :effect (d000__p_agreed ?cat ?donkey)
  )

  (:action d000__a_cat_attack_messenger
    :parameters (?cat - object ?messenger - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?messenger) (and (d000__p_attempt_light ?messenger) (d000__p_at ?cat d000__c_hearth)))
    :effect (d000__p_attacked ?cat ?messenger)
  )

  (:action d000__a_choose_sleep_spot
    :parameters (?cat - object ?cock - object ?beam - object ?hearth - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_location ?beam) (typeguard__d000__t_location ?hearth) (and (d000__p_at ?cat ?hearth) (d000__p_at ?cock ?beam)))
    :effect (and (d000__p_sleeping_at ?cat ?hearth) (d000__p_sleeping_at ?cock ?beam))
  )

  (:action d000__a_cock_agrees
    :parameters (?cock - object ?donkey - object)
    :precondition (and (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (d000__p_invited ?donkey ?cock))
    :effect (d000__p_agreed ?cock ?donkey)
  )

  (:action d000__a_cock_crow_alert
    :parameters (?cock - object)
    :precondition (and (typeguard__d000__t_entity ?cock) (d000__p_at ?cock d000__c_beam))
    :effect (d000__p_crowed ?cock)
  )

  (:action d000__a_dog_bite_messenger
    :parameters (?hound - object ?messenger - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?hound) (typeguard__d000__t_entity ?messenger) (typeguard__d000__t_location ?cottage) (and (d000__p_attempt_light ?messenger) (d000__p_at ?hound ?cottage)))
    :effect (d000__p_bite ?hound ?messenger)
  )

  (:action d000__a_donkey_kick_messenger
    :parameters (?donkey - object ?messenger - object)
    :precondition (and (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?messenger) (d000__p_attempt_light ?messenger))
    :effect (d000__p_kick ?donkey ?messenger)
  )

  (:action d000__a_eat_feast
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage) (d000__p_window_shattered)))
    :effect (and (d000__p_ate_all ?donkey) (d000__p_ate_all ?hound) (d000__p_ate_all ?cat) (d000__p_ate_all ?cock))
  )

  (:action d000__a_extinguish_light
    :parameters (?cottage - object)
    :precondition (and (typeguard__d000__t_location ?cottage) (d000__p_light_on ?cottage))
    :effect (and (d000__p_light_off ?cottage) (not (d000__p_light_on ?cottage)))
  )

  (:action d000__a_hound_agrees
    :parameters (?donkey - object ?hound - object)
    :precondition (and (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (d000__p_invited ?donkey ?hound))
    :effect (d000__p_agreed ?hound ?donkey)
  )

  (:action d000__a_invite_cat
    :parameters (?cat - object ?donkey - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?donkey) (and))
    :effect (d000__p_invited ?donkey ?cat)
  )

  (:action d000__a_invite_cock
    :parameters (?cock - object ?donkey - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_location ?loc) (and (d000__p_at ?donkey ?loc) (d000__p_at ?cock ?loc)))
    :effect (d000__p_invited ?donkey ?cock)
  )

  (:action d000__a_invite_hound
    :parameters (?donkey - object ?hound - object)
    :precondition (and (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (and))
    :effect (d000__p_invited ?donkey ?hound)
  )

  (:action d000__a_messenger_attempt_light
    :parameters (?messenger - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?messenger) (typeguard__d000__t_location ?cottage) (d000__p_light_off ?cottage))
    :effect (d000__p_attempt_light ?messenger)
  )

  (:action d000__a_plan_scaring_robbers
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage)))
    :effect (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock))
  )

  (:action d000__a_rest_in_forest
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (typeguard__d000__t_location ?forest) (and (d000__p_at ?donkey ?forest) (d000__p_at ?hound ?forest) (d000__p_at ?cat ?forest) (d000__p_at ?cock ?forest)))
    :effect (and (d000__p_resting ?donkey) (d000__p_resting ?hound) (d000__p_resting ?cat) (d000__p_resting ?cock))
  )

  (:action d000__a_robbers_flee
    :parameters (?robber - object ?cottage - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?robber) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?forest) (and (d000__p_window_shattered) (d000__p_at ?robber ?cottage)))
    :effect (and (d000__p_fled ?robber ?forest) (not (d000__p_at ?robber ?cottage)))
  )

  (:action d000__a_robbers_retreat
    :parameters (?robber - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?robber) (typeguard__d000__t_location ?cottage) (d000__p_at ?robber ?cottage))
    :effect (and (d000__p_retreated ?robber) (not (d000__p_at ?robber ?cottage)))
  )

  (:action d000__a_run_away
    :parameters (?donkey - object ?from - object ?to - object)
    :precondition (and (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_location ?from) (typeguard__d000__t_location ?to) (d000__p_at ?donkey ?from))
    :effect (and (d000__p_at ?donkey ?to) (d000__p_moving_towards ?donkey ?to) (not (d000__p_at ?donkey ?from)))
  )

  (:action d000__a_signal_and_make_noise
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (and (d000__p_stacked_on ?hound ?donkey) (d000__p_stacked_on ?cat ?hound) (d000__p_stacked_on ?cock ?cat)))
    :effect (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock) (d000__p_window_shattered))
  )

  (:action d000__a_spot_light
    :parameters (?cock - object ?cottage - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?cock) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?forest) (and (d000__p_at ?cock ?forest) (d000__p_resting ?cock)))
    :effect (and (d000__p_sees_light ?cock) (d000__p_moving_towards ?cock ?cottage))
  )

  (:action d000__a_stack_animals
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock)))
    :effect (and (d000__p_stacked_on ?hound ?donkey) (d000__p_stacked_on ?cat ?hound) (d000__p_stacked_on ?cock ?cat))
  )

  (:action d000__a_travel_together
    :parameters (?cat - object ?cock - object ?donkey - object ?hound - object ?from - object ?to - object)
    :precondition (and (typeguard__d000__t_entity ?cat) (typeguard__d000__t_entity ?cock) (typeguard__d000__t_entity ?donkey) (typeguard__d000__t_entity ?hound) (typeguard__d000__t_location ?from) (typeguard__d000__t_location ?to) (and (d000__p_at ?donkey ?from) (d000__p_at ?hound ?from) (d000__p_at ?cat ?from) (d000__p_at ?cock ?from) (d000__p_agreed ?hound ?donkey) (d000__p_agreed ?cat ?donkey) (d000__p_agreed ?cock ?donkey)))
    :effect (and (d000__p_at ?donkey ?to) (d000__p_at ?hound ?to) (d000__p_at ?cat ?to) (d000__p_at ?cock ?to) (d000__p_moving_towards ?donkey ?to) (d000__p_moving_towards ?hound ?to) (d000__p_moving_towards ?cat ?to) (d000__p_moving_towards ?cock ?to) (not (d000__p_at ?donkey ?from)) (not (d000__p_at ?hound ?from)) (not (d000__p_at ?cat ?from)) (not (d000__p_at ?cock ?from)))
  )
)
