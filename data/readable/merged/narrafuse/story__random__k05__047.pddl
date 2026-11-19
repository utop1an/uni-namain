(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (tiny_stories__story_090_p_in-drawer ?v0 - object)
    (tiny_stories__story_090_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_wants-to-take ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_brave ?v0 - object)
    (tiny_stories__story_096_active)
    (tiny_stories__story_096_type_character ?x - object)
    (tiny_stories__story_096_type_object ?x - object)
    (tiny_stories__story_096_p_has-swing ?v0 - object)
    (tiny_stories__story_096_p_playing-together ?v0 - object ?v1 - object)
    (tiny_stories__story_096_p_happy ?v0 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (shared_p_consensus_9569395ba769ed30 ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_has-robot ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
    (writing_prompts__wp_030_active)
    (writing_prompts__wp_030_type_object ?x - object)
    (writing_prompts__wp_030_type_planet ?x - object)
    (writing_prompts__wp_030_type_society ?x - object)
    (writing_prompts__wp_030_type_technology ?x - object)
    (writing_prompts__wp_030_p_has-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_030_p_in-habitable-zone ?v0 - object)
    (writing_prompts__wp_030_p_in-high-wind-zone ?v0 - object)
    (writing_prompts__wp_030_p_in-low-wind-zone ?v0 - object)
    (writing_prompts__wp_030_p_explored ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_072_a_go-to-party
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (not (tiny_stories__story_072_p_at-party ?character))
      )
    :effect
      (tiny_stories__story_072_p_at-party ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_magic-trick
    :parameters (?magician - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?magician)
        (and
          (tiny_stories__story_072_p_at-party ?magician)
          (not (tiny_stories__story_072_p_cake-transformed))
        )
      )
    :effect
      (tiny_stories__story_072_p_cake-transformed)
    :agents (?magician)
  )

  (:action tiny_stories__story_072_a_eat-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_cake-transformed)
        )
      )
    :effect
      (tiny_stories__story_072_p_fast ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_fast ?character)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_090_a_find-toy
    :parameters (?character - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?character)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_p_in-drawer ?toy)
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_in-drawer ?toy))
        (tiny_stories__story_090_p_friends ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_090_a_want-to-take
    :parameters (?taker - object ?toy - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_type_character ?owner)
        (and
          (not (= ?taker ?owner))
          (tiny_stories__story_090_p_friends ?owner ?toy)
        )
      )
    :effect
      (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
    :agents (?taker)
  )

  (:action tiny_stories__story_090_a_stand-up
    :parameters (?defender - object ?taker - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?defender)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (and
          (not (= ?defender ?taker))
          (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
          (tiny_stories__story_090_p_friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_wants-to-take ?taker ?toy))
        (tiny_stories__story_090_p_brave ?defender)
      )
    :agents (?defender)
  )

  (:action tiny_stories__story_096_a_invite
    :parameters (?inviter - object ?invitee - object)
    :precondition
      (and
        (tiny_stories__story_096_active)
        (tiny_stories__story_096_type_character ?inviter)
        (tiny_stories__story_096_type_character ?invitee)
        (and
          (not (= ?inviter ?invitee))
          (tiny_stories__story_096_p_has-swing ?inviter)
        )
      )
    :effect
      (tiny_stories__story_096_p_playing-together ?inviter ?invitee)
    :agents (?inviter)
  )

  (:action tiny_stories__story_096_a_play-on-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_096_active)
        (tiny_stories__story_096_type_character ?character1)
        (tiny_stories__story_096_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_096_p_playing-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_096_p_happy ?character1)
        (tiny_stories__story_096_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_012_a_assemble
    :parameters (?character - object ?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (shared_p_consensus_9569395ba769ed30 ?character writing_prompts__wp_012_o_garage)
          (not (writing_prompts__wp_012_p_assembled ?robot))
        )
      )
    :effect
      (and
        (writing_prompts__wp_012_p_assembled ?robot)
        (writing_prompts__wp_012_p_has-robot ?character ?robot)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_start-task
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_assembled ?robot)
          (not (writing_prompts__wp_012_p_working-on-task ?robot))
        )
      )
    :effect
      (writing_prompts__wp_012_p_working-on-task ?robot)
    :agents (?robot)
  )

  (:action writing_prompts__wp_012_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (and
          (shared_p_consensus_9569395ba769ed30 ?character writing_prompts__wp_012_o_house)
          (not (writing_prompts__wp_012_p_playing-game ?character))
        )
      )
    :effect
      (writing_prompts__wp_012_p_playing-game ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_stop-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_p_playing-game ?character)
      )
    :effect
      (not (writing_prompts__wp_012_p_playing-game ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_030_a_develop-technology
    :parameters (?society - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_technology ?technology)
      )
    :effect
      (writing_prompts__wp_030_p_has-technology ?society ?technology)
    :agents (?society)
  )

  (:action writing_prompts__wp_030_a_explore
    :parameters (?society - object ?planet - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_planet ?planet)
        (writing_prompts__wp_030_type_technology ?technology)
        (and
          (shared_p_consensus_9569395ba769ed30 ?society ?planet)
          (writing_prompts__wp_030_p_has-technology ?society ?technology)
          (or
            (writing_prompts__wp_030_p_in-habitable-zone ?planet)
            (writing_prompts__wp_030_p_in-high-wind-zone ?planet)
            (writing_prompts__wp_030_p_in-low-wind-zone ?planet)
          )
        )
      )
    :effect
      (writing_prompts__wp_030_p_explored ?society ?planet)
    :agents (?society)
  )

  (:action writing_prompts__wp_030_a_move
    :parameters (?society - object ?from - object ?to - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_planet ?from)
        (writing_prompts__wp_030_type_planet ?to)
        (writing_prompts__wp_030_type_technology ?technology)
        (and
          (shared_p_consensus_9569395ba769ed30 ?society ?from)
          (writing_prompts__wp_030_p_has-technology ?society ?technology)
          (or
            (writing_prompts__wp_030_p_in-habitable-zone ?to)
            (writing_prompts__wp_030_p_in-high-wind-zone ?to)
            (writing_prompts__wp_030_p_in-low-wind-zone ?to)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9569395ba769ed30 ?society ?from))
        (shared_p_consensus_9569395ba769ed30 ?society ?to)
      )
    :agents (?society)
  )
)
