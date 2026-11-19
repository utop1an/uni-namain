(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_053_o_spade - object tiny_stories__story_053_o_small-box - object)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_at ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_023_p_happy ?v0 - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_053_active)
    (tiny_stories__story_053_type_character ?x - object)
    (tiny_stories__story_053_type_item ?x - object)
    (tiny_stories__story_053_type_object ?x - object)
    (tiny_stories__story_053_type_place ?x - object)
    (tiny_stories__story_053_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_digging ?v0 - object)
    (tiny_stories__story_053_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_opened ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_playing ?v0 - object)
    (writing_prompts__wp_038_active)
    (writing_prompts__wp_038_type_character ?x - object)
    (writing_prompts__wp_038_type_object ?x - object)
    (writing_prompts__wp_038_type_place ?x - object)
    (writing_prompts__wp_038_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_alive ?v0 - object)
    (writing_prompts__wp_038_p_abducted ?v0 - object)
    (writing_prompts__wp_038_p_has-translator ?v0 - object)
    (writing_prompts__wp_038_p_knows-mistake ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_playing-game ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_friends ?v0 - object ?v1 - object)
  )

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (human_62959785b3ec220a_p_at ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_at ?character ?from))
        (human_62959785b3ec220a_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (human_62959785b3ec220a_p_at ?interrogator ?location)
          (human_62959785b3ec220a_p_at ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (human_62959785b3ec220a_p_at ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (human_62959785b3ec220a_p_at ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (human_62959785b3ec220a_p_at ?saver ?location)
          (human_62959785b3ec220a_p_at ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (human_62959785b3ec220a_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
  )

  (:action tiny_stories__story_023_a_play
    :parameters (?character - object ?animal - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_type_location ?place)
        (and
          (tiny_stories__story_023_p_at ?character ?place)
          (tiny_stories__story_023_p_at ?animal ?place)
        )
      )
    :effect
      (tiny_stories__story_023_p_playing ?character ?animal)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_stop-playing
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_p_playing ?character ?animal)
      )
    :effect
      (not (tiny_stories__story_023_p_playing ?character ?animal))
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_move
    :parameters (?object - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_object ?object)
        (tiny_stories__story_023_type_location ?from)
        (tiny_stories__story_023_type_location ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_023_p_at ?object ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_023_p_at ?object ?from))
        (tiny_stories__story_023_p_at ?object ?to)
      )
    :agents (?object)
  )

  (:action tiny_stories__story_023_a_can-run
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_can-run ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_can-fly
    :parameters (?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_animal ?animal)
      )
    :effect
      (tiny_stories__story_023_p_can-fly ?animal)
    :agents (?animal)
  )

  (:action tiny_stories__story_053_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_place ?place)
        (and
          (not (tiny_stories__story_053_p_at ?character ?place))
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
        )
      )
    :effect
      (tiny_stories__story_053_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_dig
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (and
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
          (not (tiny_stories__story_053_p_digging ?character))
        )
      )
    :effect
      (tiny_stories__story_053_p_digging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_digging ?character)
          (not (tiny_stories__story_053_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_053_p_found ?character ?item)
        (tiny_stories__story_053_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_found ?character ?item)
          (not (tiny_stories__story_053_p_opened ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_053_p_opened ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_p_opened ?character tiny_stories__story_053_o_small-box)
      )
    :effect
      (tiny_stories__story_053_p_playing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_038_a_abduct
    :parameters (?abductor - object ?abductee - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?abductor)
        (writing_prompts__wp_038_type_character ?abductee)
        (writing_prompts__wp_038_type_place ?place)
        (and
          (not (= ?abductor ?abductee))
          (writing_prompts__wp_038_p_alive ?abductor)
          (writing_prompts__wp_038_p_at ?abductor ?place)
          (writing_prompts__wp_038_p_alive ?abductee)
          (writing_prompts__wp_038_p_at ?abductee ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_038_p_abducted ?abductee)
        (not (writing_prompts__wp_038_p_at ?abductee ?place))
      )
    :agents (?abductor)
  )

  (:action writing_prompts__wp_038_a_give-translator
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?giver)
        (writing_prompts__wp_038_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_038_p_alive ?giver)
          (writing_prompts__wp_038_p_alive ?receiver)
          (writing_prompts__wp_038_p_abducted ?receiver)
        )
      )
    :effect
      (writing_prompts__wp_038_p_has-translator ?receiver)
    :agents (?giver)
  )

  (:action writing_prompts__wp_038_a_reveal-mistake
    :parameters (?mistaken - object ?informed - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?mistaken)
        (writing_prompts__wp_038_type_character ?informed)
        (and
          (not (= ?mistaken ?informed))
          (writing_prompts__wp_038_p_alive ?mistaken)
          (writing_prompts__wp_038_p_alive ?informed)
          (writing_prompts__wp_038_p_has-translator ?informed)
        )
      )
    :effect
      (writing_prompts__wp_038_p_knows-mistake ?informed ?mistaken)
    :agents (?mistaken)
  )

  (:action writing_prompts__wp_038_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_has-translator ?character1)
        )
      )
    :effect
      (writing_prompts__wp_038_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_play-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_stop-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
        )
      )
    :effect
      (not (writing_prompts__wp_038_p_playing-game ?character1 ?character2))
    :agents (?character1 ?character2)
  )
)
