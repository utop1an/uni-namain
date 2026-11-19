(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (shared_p_consensus_75a3469fee02c6e5 ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_033_type_item ?x - object)
    (writing_prompts__wp_033_type_object ?x - object)
    (writing_prompts__wp_033_type_place ?x - object)
    (writing_prompts__wp_033_type_robot ?x - object)
    (writing_prompts__wp_033_type_weapon ?x - object)
    (writing_prompts__wp_033_p_alive ?v0 - object)
    (shared_p_consensus_540f5de315fa3dee ?v0 - object ?v1 - object)
    (shared_p_consensus_aff2e6f45a5ba7ef ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_thrown ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_damaged ?v0 - object)
    (writing_prompts__wp_033_p_destroyed ?v0 - object)
    (writing_prompts__wp_033_p_revolution-started)
    (writing_prompts__wp_043_active)
    (writing_prompts__wp_043_type_character ?x - object)
    (writing_prompts__wp_043_type_object ?x - object)
    (writing_prompts__wp_043_type_place ?x - object)
    (shared_p_consensus_63f55979f47de0c5 ?v0 - object)
    (writing_prompts__wp_043_p_discovered ?v0 - object)
    (writing_prompts__wp_043_p_knows-about ?v0 - object ?v1 - object)
    (writing_prompts__wp_043_p_is-ceo ?v0 - object)
    (writing_prompts__wp_043_p_is-alien ?v0 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (shared_p_consensus_75a3469fee02c6e5 ?character ?place))
      )
    :effect
      (shared_p_consensus_75a3469fee02c6e5 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_033_a_move
    :parameters (?robot - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_type_place ?from)
        (writing_prompts__wp_033_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_033_p_alive ?robot)
          (shared_p_consensus_540f5de315fa3dee ?robot ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_540f5de315fa3dee ?robot ?from))
        (shared_p_consensus_540f5de315fa3dee ?robot ?to)
      )
    :agents (?robot)
  )

  (:action writing_prompts__wp_033_a_throw-weapon
    :parameters (?thrower - object ?weapon - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?thrower)
        (writing_prompts__wp_033_type_weapon ?weapon)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?thrower)
          (shared_p_consensus_aff2e6f45a5ba7ef ?thrower ?weapon)
          (writing_prompts__wp_033_p_alive ?target)
        )
      )
    :effect
      (writing_prompts__wp_033_p_thrown ?weapon ?target)
    :agents (?thrower)
  )

  (:action writing_prompts__wp_033_a_damage
    :parameters (?damager - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?damager)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?damager)
          (writing_prompts__wp_033_p_alive ?target)
          (exists
            (?weapon - object)
            (and
              (writing_prompts__wp_033_type_weapon ?weapon)
              (writing_prompts__wp_033_p_thrown ?weapon ?target)
            )
          )
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_alive ?target))
        (writing_prompts__wp_033_p_damaged ?target)
      )
    :agents (?damager)
  )

  (:action writing_prompts__wp_033_a_destroy
    :parameters (?destroyer - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?destroyer)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?destroyer)
          (writing_prompts__wp_033_p_damaged ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_damaged ?target))
        (writing_prompts__wp_033_p_destroyed ?target)
      )
    :agents (?destroyer)
  )

  (:action writing_prompts__wp_033_a_start-revolution
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_p_alive ?robot)
      )
    :effect
      (writing_prompts__wp_033_p_revolution-started)
    :agents (?robot)
  )

  (:action writing_prompts__wp_043_a_discover
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?character)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?character)
          (shared_p_consensus_75a3469fee02c6e5 ?character ?place)
          (not (writing_prompts__wp_043_p_discovered ?place))
        )
      )
    :effect
      (writing_prompts__wp_043_p_discovered ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_043_a_learn
    :parameters (?learner - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?learner)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?learner)
          (writing_prompts__wp_043_p_discovered ?place)
        )
      )
    :effect
      (writing_prompts__wp_043_p_knows-about ?learner ?place)
    :agents (?learner)
  )

  (:action writing_prompts__wp_043_a_hold-press-conference
    :parameters (?speaker - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?speaker)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?speaker)
          (writing_prompts__wp_043_p_is-ceo ?speaker)
          (writing_prompts__wp_043_p_knows-about ?speaker ?place)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?place)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_043_a_reveal
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?alien)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?alien)
          (writing_prompts__wp_043_p_is-alien ?alien)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?alien)
        )
      )
    :agents (?alien)
  )

  (:action writing_prompts__wp_064_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_place ?from)
        (writing_prompts__wp_064_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_63f55979f47de0c5 ?character)
          (shared_p_consensus_540f5de315fa3dee ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_540f5de315fa3dee ?character ?from))
        (shared_p_consensus_540f5de315fa3dee ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_deliver
    :parameters (?character - object ?item - object ?destination - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?destination)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?character)
          (shared_p_consensus_540f5de315fa3dee ?character ?destination)
          (shared_p_consensus_aff2e6f45a5ba7ef ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_aff2e6f45a5ba7ef ?character ?item))
        (writing_prompts__wp_064_p_delivered ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_pick-up
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?place)
        (and
          (shared_p_consensus_63f55979f47de0c5 ?character)
          (shared_p_consensus_540f5de315fa3dee ?character ?place)
        )
      )
    :effect
      (shared_p_consensus_aff2e6f45a5ba7ef ?character ?item)
    :agents (?character)
  )
)
