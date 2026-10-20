(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_ass d000__c_captain d000__c_cat d000__c_cock d000__c_hound d000__c_man d000__c_messenger d000__c_robber - d000__t_entity
    d000__c_drinks d000__c_kettledrums d000__c_lute d000__c_meat d000__c_straw d000__c_table - d000__t_item
    d000__c_beam d000__c_bremen d000__c_forest d000__c_hearth d000__c_road_to_bremen d000__c_robbers_cottage d000__c_window - d000__t_location
  )
  (:predicates
    (d000__p_agreed ?e - d000__t_entity ?inviter - d000__t_entity)
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_ate_all ?e - d000__t_entity)
    (d000__p_attacked ?attacker - d000__t_entity ?target - d000__t_entity)
    (d000__p_attempt_light ?messenger - d000__t_entity)
    (d000__p_bite ?dog - d000__t_entity ?target - d000__t_entity)
    (d000__p_crowed ?cock - d000__t_entity)
    (d000__p_fled ?robber - d000__t_entity ?loc - d000__t_location)
    (d000__p_invited ?inviter - d000__t_entity ?invitee - d000__t_entity)
    (d000__p_kick ?donkey - d000__t_entity ?target - d000__t_entity)
    (d000__p_light_off ?loc - d000__t_location)
    (d000__p_light_on ?loc - d000__t_location)
    (d000__p_making_noise ?e - d000__t_entity)
    (d000__p_moving_towards ?e - d000__t_entity ?loc - d000__t_location)
    (d000__p_resting ?e - d000__t_entity)
    (d000__p_retreated ?robber - d000__t_entity)
    (d000__p_sees_light ?e - d000__t_entity)
    (d000__p_sleeping_at ?e - d000__t_entity ?loc - d000__t_location)
    (d000__p_stacked_on ?top - d000__t_entity ?bottom - d000__t_entity)
    (d000__p_window_shattered)
  )

  (:action d000__a_approach_cottage
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity ?cottage - d000__t_location ?forest - d000__t_location)
    :precondition (and (d000__p_sees_light ?cock) (d000__p_at ?donkey ?forest) (d000__p_at ?hound ?forest) (d000__p_at ?cat ?forest) (d000__p_at ?cock ?forest))
    :effect (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage) (d000__p_moving_towards ?donkey ?cottage) (d000__p_moving_towards ?hound ?cottage) (d000__p_moving_towards ?cat ?cottage) (d000__p_moving_towards ?cock ?cottage) (not (d000__p_at ?donkey ?forest)) (not (d000__p_at ?hound ?forest)) (not (d000__p_at ?cat ?forest)) (not (d000__p_at ?cock ?forest)))
  )

  (:action d000__a_cat_agrees
    :parameters (?cat - d000__t_entity ?donkey - d000__t_entity)
    :precondition (d000__p_invited ?donkey ?cat)
    :effect (d000__p_agreed ?cat ?donkey)
  )

  (:action d000__a_cat_attack_messenger
    :parameters (?cat - d000__t_entity ?messenger - d000__t_entity)
    :precondition (and (d000__p_attempt_light ?messenger) (d000__p_at ?cat d000__c_hearth))
    :effect (d000__p_attacked ?cat ?messenger)
  )

  (:action d000__a_choose_sleep_spot
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?beam - d000__t_location ?hearth - d000__t_location)
    :precondition (and (d000__p_at ?cat ?hearth) (d000__p_at ?cock ?beam))
    :effect (and (d000__p_sleeping_at ?cat ?hearth) (d000__p_sleeping_at ?cock ?beam))
  )

  (:action d000__a_cock_agrees
    :parameters (?cock - d000__t_entity ?donkey - d000__t_entity)
    :precondition (d000__p_invited ?donkey ?cock)
    :effect (d000__p_agreed ?cock ?donkey)
  )

  (:action d000__a_cock_crow_alert
    :parameters (?cock - d000__t_entity)
    :precondition (d000__p_at ?cock d000__c_beam)
    :effect (d000__p_crowed ?cock)
  )

  (:action d000__a_dog_bite_messenger
    :parameters (?hound - d000__t_entity ?messenger - d000__t_entity ?cottage - d000__t_location)
    :precondition (and (d000__p_attempt_light ?messenger) (d000__p_at ?hound ?cottage))
    :effect (d000__p_bite ?hound ?messenger)
  )

  (:action d000__a_donkey_kick_messenger
    :parameters (?donkey - d000__t_entity ?messenger - d000__t_entity)
    :precondition (d000__p_attempt_light ?messenger)
    :effect (d000__p_kick ?donkey ?messenger)
  )

  (:action d000__a_eat_feast
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity ?cottage - d000__t_location)
    :precondition (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage) (d000__p_window_shattered))
    :effect (and (d000__p_ate_all ?donkey) (d000__p_ate_all ?hound) (d000__p_ate_all ?cat) (d000__p_ate_all ?cock))
  )

  (:action d000__a_extinguish_light
    :parameters (?cottage - d000__t_location)
    :precondition (d000__p_light_on ?cottage)
    :effect (and (d000__p_light_off ?cottage) (not (d000__p_light_on ?cottage)))
  )

  (:action d000__a_hound_agrees
    :parameters (?donkey - d000__t_entity ?hound - d000__t_entity)
    :precondition (d000__p_invited ?donkey ?hound)
    :effect (d000__p_agreed ?hound ?donkey)
  )

  (:action d000__a_invite_cat
    :parameters (?cat - d000__t_entity ?donkey - d000__t_entity)
    :effect (d000__p_invited ?donkey ?cat)
  )

  (:action d000__a_invite_cock
    :parameters (?cock - d000__t_entity ?donkey - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?donkey ?loc) (d000__p_at ?cock ?loc))
    :effect (d000__p_invited ?donkey ?cock)
  )

  (:action d000__a_invite_hound
    :parameters (?donkey - d000__t_entity ?hound - d000__t_entity)
    :effect (d000__p_invited ?donkey ?hound)
  )

  (:action d000__a_messenger_attempt_light
    :parameters (?messenger - d000__t_entity ?cottage - d000__t_location)
    :precondition (d000__p_light_off ?cottage)
    :effect (d000__p_attempt_light ?messenger)
  )

  (:action d000__a_plan_scaring_robbers
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity ?cottage - d000__t_location)
    :precondition (and (d000__p_at ?donkey ?cottage) (d000__p_at ?hound ?cottage) (d000__p_at ?cat ?cottage) (d000__p_at ?cock ?cottage))
    :effect (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock))
  )

  (:action d000__a_rest_in_forest
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity ?forest - d000__t_location)
    :precondition (and (d000__p_at ?donkey ?forest) (d000__p_at ?hound ?forest) (d000__p_at ?cat ?forest) (d000__p_at ?cock ?forest))
    :effect (and (d000__p_resting ?donkey) (d000__p_resting ?hound) (d000__p_resting ?cat) (d000__p_resting ?cock))
  )

  (:action d000__a_robbers_flee
    :parameters (?robber - d000__t_entity ?cottage - d000__t_location ?forest - d000__t_location)
    :precondition (and (d000__p_window_shattered) (d000__p_at ?robber ?cottage))
    :effect (and (d000__p_fled ?robber ?forest) (not (d000__p_at ?robber ?cottage)))
  )

  (:action d000__a_robbers_retreat
    :parameters (?robber - d000__t_entity ?cottage - d000__t_location)
    :precondition (d000__p_at ?robber ?cottage)
    :effect (and (d000__p_retreated ?robber) (not (d000__p_at ?robber ?cottage)))
  )

  (:action d000__a_run_away
    :parameters (?donkey - d000__t_entity ?from - d000__t_location ?to - d000__t_location)
    :precondition (d000__p_at ?donkey ?from)
    :effect (and (d000__p_at ?donkey ?to) (d000__p_moving_towards ?donkey ?to) (not (d000__p_at ?donkey ?from)))
  )

  (:action d000__a_signal_and_make_noise
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity)
    :precondition (and (d000__p_stacked_on ?hound ?donkey) (d000__p_stacked_on ?cat ?hound) (d000__p_stacked_on ?cock ?cat))
    :effect (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock) (d000__p_window_shattered))
  )

  (:action d000__a_spot_light
    :parameters (?cock - d000__t_entity ?cottage - d000__t_location ?forest - d000__t_location)
    :precondition (and (d000__p_at ?cock ?forest) (d000__p_resting ?cock))
    :effect (and (d000__p_sees_light ?cock) (d000__p_moving_towards ?cock ?cottage))
  )

  (:action d000__a_stack_animals
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity)
    :precondition (and (d000__p_making_noise ?donkey) (d000__p_making_noise ?hound) (d000__p_making_noise ?cat) (d000__p_making_noise ?cock))
    :effect (and (d000__p_stacked_on ?hound ?donkey) (d000__p_stacked_on ?cat ?hound) (d000__p_stacked_on ?cock ?cat))
  )

  (:action d000__a_travel_together
    :parameters (?cat - d000__t_entity ?cock - d000__t_entity ?donkey - d000__t_entity ?hound - d000__t_entity ?from - d000__t_location ?to - d000__t_location)
    :precondition (and (d000__p_at ?donkey ?from) (d000__p_at ?hound ?from) (d000__p_at ?cat ?from) (d000__p_at ?cock ?from) (d000__p_agreed ?hound ?donkey) (d000__p_agreed ?cat ?donkey) (d000__p_agreed ?cock ?donkey))
    :effect (and (d000__p_at ?donkey ?to) (d000__p_at ?hound ?to) (d000__p_at ?cat ?to) (d000__p_at ?cock ?to) (d000__p_moving_towards ?donkey ?to) (d000__p_moving_towards ?hound ?to) (d000__p_moving_towards ?cat ?to) (d000__p_moving_towards ?cock ?to) (not (d000__p_at ?donkey ?from)) (not (d000__p_at ?hound ?from)) (not (d000__p_at ?cat ?from)) (not (d000__p_at ?cock ?from)))
  )
)
