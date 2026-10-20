(define (domain unified_narrative_domain)
  (:requirements :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    audience buffoon Chicken-licken Cock-lock countryman Drake-lake Duck-luck Fox-lox Gander-lander Goose-loose Hen-len King little_pig rich_nobleman Turkey-lurkey - entity
    Acorn cloak Sky - item
    FoxHole platform theater Wood - location
  )
  (:predicates
    (applause_given ?audience - entity ?performer - entity)
    (at ?e - entity ?l - location)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (cloak_shaken ?performer - entity ?cloak - item)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crowd_present ?audience - entity ?theater - location)
    (decided_to_tell_king ?e - entity)
    (eaten_by_fox ?e - entity)
    (following_fox ?e - entity)
    (going_to_wood ?e - entity)
    (imitates_pig ?performer - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (met ?e1 - entity ?e2 - entity)
    (on_platform ?performer - entity ?platform - location)
    (partiality_prevalent)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (reward_announced ?nobleman - entity)
    (sky_fell_on_head ?e - entity)
    (theater_opened ?nobleman - entity ?theater - location)
    (turned_back ?e - entity)
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

  (:action be_eaten_by_fox
    :parameters (?e - entity ?l - location)
    :precondition (and (following_fox ?e) (at ?e ?l) (not (eaten_by_fox ?e)))
    :effect (and (at ?e FoxHole) (eaten_by_fox ?e) (not (at ?e ?l)) (not (following_fox ?e)))
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

  (:action decide_to_tell_king
    :parameters (?e - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?e)) (not (decided_to_tell_king ?e)))
    :effect (decided_to_tell_king ?e)
  )

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (decided_to_tell_king ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
  )

  (:action go_to_wood
    :parameters (?e - entity)
    :precondition (and (not (at ?e Wood)) (not (going_to_wood ?e)))
    :effect (going_to_wood ?e)
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
  )

  (:action meet_character
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l) (not (met ?e1 ?e2)))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
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

  (:action turn_back
    :parameters (?e - entity)
    :precondition (and (going_to_wood ?e) (not (turned_back ?e)))
    :effect (and (turned_back ?e) (not (going_to_wood ?e)))
  )
)
