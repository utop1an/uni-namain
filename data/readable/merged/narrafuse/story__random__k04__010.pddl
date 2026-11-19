(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_009_p_reading ?v0 - object)
    (tiny_stories__story_009_p_playing ?v0 - object)
    (tiny_stories__story_009_p_calm ?v0 - object)
    (tiny_stories__story_009_p_books-fall)
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
    (writing_prompts__wp_074_active)
    (writing_prompts__wp_074_type_character ?x - object)
    (writing_prompts__wp_074_type_object ?x - object)
    (writing_prompts__wp_074_p_influenced ?v0 - object)
    (writing_prompts__wp_074_p_isolated ?v0 - object)
    (writing_prompts__wp_074_p_hates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_manipulates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_despises ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_apologized ?v0 - object ?v1 - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (writing_prompts__wp_075_p_president ?v0 - object)
    (writing_prompts__wp_075_p_speaker ?v0 - object)
    (writing_prompts__wp_075_p_vice-president ?v0 - object)
    (writing_prompts__wp_075_p_belongs-to ?v0 - object ?v1 - object)
    (writing_prompts__wp_075_p_economy-collapsed)
    (writing_prompts__wp_075_p_real-estate-monopoly)
    (writing_prompts__wp_075_p_planned-parenthood-defunded)
    (writing_prompts__wp_075_p_planned-parenthood-shutdown)
    (writing_prompts__wp_075_p_planned-parenthood-criminalized)
    (writing_prompts__wp_075_p_prison-population-increased)
    (writing_prompts__wp_075_p_political-prisoner ?v0 - object)
  )

  (:action tiny_stories__story_009_a_start-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_reading ?character))
      )
    :effect
      (tiny_stories__story_009_p_reading ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_reading ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_reading ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_playing ?character))
      )
    :effect
      (tiny_stories__story_009_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_playing ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_playing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-calm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_calm ?character))
      )
    :effect
      (tiny_stories__story_009_p_calm ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-uncalm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_calm ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_calm ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (tiny_stories__story_009_p_books-fall))
      )
    :effect
      (tiny_stories__story_009_p_books-fall)
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

  (:action writing_prompts__wp_074_a_influence
    :parameters (?influencer - object ?influenced - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?influencer)
        (writing_prompts__wp_074_type_character ?influenced)
        (and
          (not (= ?influencer ?influenced))
          (not (writing_prompts__wp_074_p_influenced ?influenced))
        )
      )
    :effect
      (writing_prompts__wp_074_p_influenced ?influenced)
    :agents (?influencer)
  )

  (:action writing_prompts__wp_074_a_isolate
    :parameters (?isolator - object ?isolated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?isolator)
        (writing_prompts__wp_074_type_character ?isolated)
        (and
          (not (= ?isolator ?isolated))
          (not (writing_prompts__wp_074_p_isolated ?isolated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_isolated ?isolated)
    :agents (?isolator)
  )

  (:action writing_prompts__wp_074_a_manipulate
    :parameters (?manipulator - object ?manipulated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?manipulator)
        (writing_prompts__wp_074_type_character ?manipulated)
        (and
          (not (= ?manipulator ?manipulated))
          (not (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated)
    :agents (?manipulator)
  )

  (:action writing_prompts__wp_074_a_hate
    :parameters (?hater - object ?hated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?hater)
        (writing_prompts__wp_074_type_character ?hated)
        (and
          (not (= ?hater ?hated))
          (not (writing_prompts__wp_074_p_hates ?hater ?hated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_hates ?hater ?hated)
    :agents (?hater)
  )

  (:action writing_prompts__wp_074_a_despise
    :parameters (?despiser - object ?despised - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?despiser)
        (writing_prompts__wp_074_type_character ?despised)
        (and
          (not (= ?despiser ?despised))
          (not (writing_prompts__wp_074_p_despises ?despiser ?despised))
        )
      )
    :effect
      (writing_prompts__wp_074_p_despises ?despiser ?despised)
    :agents (?despiser)
  )

  (:action writing_prompts__wp_074_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?apologizer)
        (writing_prompts__wp_074_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (writing_prompts__wp_074_p_apologized ?apologizer ?apologized))
        )
      )
    :effect
      (writing_prompts__wp_074_p_apologized ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action writing_prompts__wp_075_a_announce-state-of-the-union
    :parameters (?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?president)
        (writing_prompts__wp_075_p_president ?president)
      )
    :agents (?president)
  )

  (:action writing_prompts__wp_075_a_introduce-president
    :parameters (?speaker - object ?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?speaker)
        (writing_prompts__wp_075_type_character ?president)
        (and
          (writing_prompts__wp_075_p_speaker ?speaker)
          (writing_prompts__wp_075_p_president ?president)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_075_a_attend-state-of-the-union
    :parameters (?vice-president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?vice-president)
        (writing_prompts__wp_075_p_vice-president ?vice-president)
      )
    :agents (?vice-president)
  )
)
