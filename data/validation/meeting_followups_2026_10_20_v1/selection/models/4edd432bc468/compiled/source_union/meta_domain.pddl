(define (domain narrative_union)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_audience d000__c_buffoon d000__c_countryman d000__c_little_pig d000__c_rich_nobleman - d000__t_entity
    d000__c_cloak - d000__t_item
    d000__c_platform d000__c_theater - d000__t_location
  )
  (:predicates
    (d000__p_applause_given ?audience - d000__t_entity ?performer - d000__t_entity)
    (d000__p_audience_calls_for_kickout ?audience - d000__t_entity ?countryman - d000__t_entity)
    (d000__p_audience_demands_shake_cloak ?audience - d000__t_entity ?performer - d000__t_entity ?cloak - d000__t_item)
    (d000__p_cloak_shaken ?performer - d000__t_entity ?cloak - d000__t_item)
    (d000__p_countryman_declares_intent ?countryman - d000__t_entity)
    (d000__p_countryman_performs_with_real_pig ?countryman - d000__t_entity ?pig - d000__t_entity)
    (d000__p_crowd_present ?audience - d000__t_entity ?theater - d000__t_location)
    (d000__p_imitates_pig ?performer - d000__t_entity)
    (d000__p_on_platform ?performer - d000__t_entity ?platform - d000__t_location)
    (d000__p_partiality_prevalent)
    (d000__p_performs_without_apparatus ?performer - d000__t_entity)
    (d000__p_pig_found ?performer - d000__t_entity ?pig - d000__t_entity)
    (d000__p_pig_revealed ?countryman - d000__t_entity ?pig - d000__t_entity)
    (d000__p_reward_announced ?nobleman - d000__t_entity)
    (d000__p_theater_opened ?nobleman - d000__t_entity ?theater - d000__t_location)
  )

  (:action d000__a_audience_applaud_performance
    :parameters (?audience - d000__t_entity ?performer - d000__t_entity ?pig - d000__t_entity ?cloak - d000__t_item)
    :precondition (and (d000__p_cloak_shaken ?performer ?cloak) (not (d000__p_pig_found ?performer ?pig)))
    :effect (d000__p_applause_given ?audience ?performer)
  )

  (:action d000__a_audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience - d000__t_entity ?countryman - d000__t_entity ?pig - d000__t_entity)
    :precondition (d000__p_countryman_performs_with_real_pig ?countryman ?pig)
    :effect (d000__p_audience_calls_for_kickout ?audience ?countryman)
  )

  (:action d000__a_audience_demand_shake_cloak_for_pig
    :parameters (?audience - d000__t_entity ?performer - d000__t_entity ?cloak - d000__t_item)
    :effect (d000__p_audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action d000__a_countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - d000__t_entity)
    :effect (d000__p_countryman_declares_intent ?countryman)
  )

  (:action d000__a_countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman - d000__t_entity ?pig - d000__t_entity ?platform - d000__t_location)
    :precondition (and (d000__p_countryman_declares_intent ?countryman) (d000__p_on_platform ?countryman ?platform))
    :effect (d000__p_countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action d000__a_countryman_reveal_real_pig
    :parameters (?audience - d000__t_entity ?countryman - d000__t_entity ?pig - d000__t_entity)
    :precondition (d000__p_audience_calls_for_kickout ?audience ?countryman)
    :effect (d000__p_pig_revealed ?countryman ?pig)
  )

  (:action d000__a_open_theater_and_announce_reward
    :parameters (?nobleman - d000__t_entity ?theater - d000__t_location)
    :effect (and (d000__p_theater_opened ?nobleman ?theater) (d000__p_reward_announced ?nobleman))
  )

  (:action d000__a_perform_pig_imitation_without_apparatus
    :parameters (?performer - d000__t_entity ?platform - d000__t_location)
    :precondition (d000__p_on_platform ?performer ?platform)
    :effect (and (d000__p_performs_without_apparatus ?performer) (d000__p_imitates_pig ?performer))
  )
)
