(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:constants tiny_stories__story_084_o_rocket - object writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (human_87bbd0acdf4611c5_p_at ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_073_active)
    (tiny_stories__story_073_type_character ?x - object)
    (tiny_stories__story_073_type_object ?x - object)
    (tiny_stories__story_073_p_play-chess ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_feel-better ?v0 - object)
    (tiny_stories__story_073_p_sit-together ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_sick ?v0 - object)
    (tiny_stories__story_073_p_happy ?v0 - object)
    (tiny_stories__story_084_active)
    (tiny_stories__story_084_type_character ?x - object)
    (tiny_stories__story_084_type_item ?x - object)
    (tiny_stories__story_084_type_object ?x - object)
    (tiny_stories__story_084_type_place ?x - object)
    (tiny_stories__story_084_type_toy ?x - object)
    (tiny_stories__story_084_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_played-with ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_happy ?v0 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_012_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_has-robot ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (human_87bbd0acdf4611c5_p_at ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_at ?character ?from))
        (human_87bbd0acdf4611c5_p_at ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (human_87bbd0acdf4611c5_p_at ?interrogator ?location)
          (human_87bbd0acdf4611c5_p_at ?interrogated ?location)
          (human_87bbd0acdf4611c5_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_87bbd0acdf4611c5_p_knows ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (human_87bbd0acdf4611c5_p_henchman ?placer)
          (human_87bbd0acdf4611c5_p_has ?placer ?victim)
          (human_87bbd0acdf4611c5_p_at ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (human_87bbd0acdf4611c5_p_at ?victim ?placed)
        (human_87bbd0acdf4611c5_p_captured ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (human_87bbd0acdf4611c5_p_at ?saver ?location)
          (human_87bbd0acdf4611c5_p_at ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (human_87bbd0acdf4611c5_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )

  (:action tiny_stories__story_073_a_play-chess
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (and
          (not (tiny_stories__story_073_p_sick ?character1))
          (not (tiny_stories__story_073_p_sick ?character2))
          (not (= ?character1 ?character2))
          (tiny_stories__story_073_p_sit-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_073_p_play-chess ?character1 ?character2)
        (tiny_stories__story_073_p_happy ?character1)
        (tiny_stories__story_073_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_073_a_get-sick
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
      )
    :effect
      (tiny_stories__story_073_p_sick ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_feel-better
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
        (tiny_stories__story_073_p_sick ?character)
      )
    :effect
      (not (tiny_stories__story_073_p_sick ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_sit-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_073_p_sit-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_084_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (tiny_stories__story_084_p_at ?character ?place)
          (not (tiny_stories__story_084_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_084_p_found ?character ?item)
        (tiny_stories__story_084_p_has ?character ?item)
        (tiny_stories__story_084_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_show
    :parameters (?shower - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?shower)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_character ?receiver)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?shower ?receiver))
          (tiny_stories__story_084_p_at ?shower ?place)
          (tiny_stories__story_084_p_has ?shower ?item)
          (tiny_stories__story_084_p_at ?receiver ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_happy ?receiver)
    :agents (?shower ?receiver)
  )

  (:action tiny_stories__story_084_a_play
    :parameters (?character1 - object ?character2 - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character1)
        (tiny_stories__story_084_type_character ?character2)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_084_p_at ?character1 ?place)
          (tiny_stories__story_084_p_has ?character1 ?item)
          (tiny_stories__story_084_p_at ?character2 ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_played-with ?character1 ?item)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_084_a_fly-high
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_p_played-with ?character tiny_stories__story_084_o_rocket)
      )
    :effect
      (tiny_stories__story_084_p_happy ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_assemble
    :parameters (?character - object ?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_garage)
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
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_house)
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
)
