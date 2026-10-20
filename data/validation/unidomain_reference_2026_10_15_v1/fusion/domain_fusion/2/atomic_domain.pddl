(define (domain The_Buffoon_And_The_Countryman)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    audience buffoon countryman little_pig rich_nobleman - entity
    cloak - item
    platform theater - location
  )
  (:predicates
    (applause_given ?audience - entity ?performer - entity)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (cloak_shaken ?performer - entity ?cloak - item)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crowd_present ?audience - entity ?theater - location)
    (imitates_pig ?performer - entity)
    (on_platform ?performer - entity ?platform - location)
    (partiality_prevalent)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (reward_announced ?nobleman - entity)
    (theater_opened ?nobleman - entity ?theater - location)
  )

  (:action audience_applaud_performance
    :parameters (?audience ?performer ?pig - entity ?cloak - item)
    :precondition (and (cloak_shaken ?performer ?cloak) (not (pig_found ?performer ?pig)))
    :effect (applause_given ?audience ?performer)
  )

  (:action audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (countryman_performs_with_real_pig ?countryman ?pig)
    :effect (audience_calls_for_kickout ?audience ?countryman)
  )

  (:action audience_demand_shake_cloak_for_pig
    :parameters (?audience ?performer - entity ?cloak - item)
    :effect (audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - entity)
    :effect (countryman_declares_intent ?countryman)
  )

  (:action countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman ?pig - entity ?platform - location)
    :precondition (and (countryman_declares_intent ?countryman) (on_platform ?countryman ?platform))
    :effect (countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action countryman_reveal_real_pig
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (audience_calls_for_kickout ?audience ?countryman)
    :effect (pig_revealed ?countryman ?pig)
  )

  (:action open_theater_and_announce_reward
    :parameters (?nobleman - entity ?theater - location)
    :effect (and (theater_opened ?nobleman ?theater) (reward_announced ?nobleman))
  )

  (:action perform_pig_imitation_without_apparatus
    :parameters (?performer - entity ?platform - location)
    :precondition (on_platform ?performer ?platform)
    :effect (and (performs_without_apparatus ?performer) (imitates_pig ?performer))
  )
)
