(define (domain narrative_aligned)
  (:requirements :adl :negative-preconditions :strips :typing)
  (:constants
    d000__c_audience d000__c_buffoon d000__c_cloak d000__c_countryman d000__c_little_pig d000__c_platform d000__c_rich_nobleman d000__c_theater - object
  )
  (:predicates
    (d000__p_applause_given ?a0 - object ?a1 - object)
    (d000__p_audience_calls_for_kickout ?a0 - object ?a1 - object)
    (d000__p_audience_demands_shake_cloak ?a0 - object ?a1 - object ?a2 - object)
    (d000__p_cloak_shaken ?a0 - object ?a1 - object)
    (d000__p_countryman_declares_intent ?a0 - object)
    (d000__p_countryman_performs_with_real_pig ?a0 - object ?a1 - object)
    (d000__p_crowd_present ?a0 - object ?a1 - object)
    (d000__p_imitates_pig ?a0 - object)
    (d000__p_on_platform ?a0 - object ?a1 - object)
    (d000__p_partiality_prevalent)
    (d000__p_performs_without_apparatus ?a0 - object)
    (d000__p_pig_found ?a0 - object ?a1 - object)
    (d000__p_pig_revealed ?a0 - object ?a1 - object)
    (d000__p_reward_announced ?a0 - object)
    (d000__p_theater_opened ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_audience_applaud_performance
    :parameters (?audience - object ?performer - object ?pig - object ?cloak - object)
    :precondition (and (typeguard__d000__t_entity ?audience) (typeguard__d000__t_entity ?performer) (typeguard__d000__t_entity ?pig) (typeguard__d000__t_item ?cloak) (and (d000__p_cloak_shaken ?performer ?cloak) (not (d000__p_pig_found ?performer ?pig))))
    :effect (d000__p_applause_given ?audience ?performer)
  )

  (:action d000__a_audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience - object ?countryman - object ?pig - object)
    :precondition (and (typeguard__d000__t_entity ?audience) (typeguard__d000__t_entity ?countryman) (typeguard__d000__t_entity ?pig) (d000__p_countryman_performs_with_real_pig ?countryman ?pig))
    :effect (d000__p_audience_calls_for_kickout ?audience ?countryman)
  )

  (:action d000__a_audience_demand_shake_cloak_for_pig
    :parameters (?audience - object ?performer - object ?cloak - object)
    :precondition (and (typeguard__d000__t_entity ?audience) (typeguard__d000__t_entity ?performer) (typeguard__d000__t_item ?cloak) (and))
    :effect (d000__p_audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action d000__a_countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - object)
    :precondition (and (typeguard__d000__t_entity ?countryman) (and))
    :effect (d000__p_countryman_declares_intent ?countryman)
  )

  (:action d000__a_countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman - object ?pig - object ?platform - object)
    :precondition (and (typeguard__d000__t_entity ?countryman) (typeguard__d000__t_entity ?pig) (typeguard__d000__t_location ?platform) (and (d000__p_countryman_declares_intent ?countryman) (d000__p_on_platform ?countryman ?platform)))
    :effect (d000__p_countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action d000__a_countryman_reveal_real_pig
    :parameters (?audience - object ?countryman - object ?pig - object)
    :precondition (and (typeguard__d000__t_entity ?audience) (typeguard__d000__t_entity ?countryman) (typeguard__d000__t_entity ?pig) (d000__p_audience_calls_for_kickout ?audience ?countryman))
    :effect (d000__p_pig_revealed ?countryman ?pig)
  )

  (:action d000__a_open_theater_and_announce_reward
    :parameters (?nobleman - object ?theater - object)
    :precondition (and (typeguard__d000__t_entity ?nobleman) (typeguard__d000__t_location ?theater) (and))
    :effect (and (d000__p_theater_opened ?nobleman ?theater) (d000__p_reward_announced ?nobleman))
  )

  (:action d000__a_perform_pig_imitation_without_apparatus
    :parameters (?performer - object ?platform - object)
    :precondition (and (typeguard__d000__t_entity ?performer) (typeguard__d000__t_location ?platform) (d000__p_on_platform ?performer ?platform))
    :effect (and (d000__p_performs_without_apparatus ?performer) (d000__p_imitates_pig ?performer))
  )
)
