(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (shared_p_consensus_a82c5cebb25cfc11 ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (tiny_stories__story_063_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (tiny_stories__story_077_p_happy ?v0 - object)
    (tiny_stories__story_077_p_tired ?v0 - object)
    (tiny_stories__story_077_p_played-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_active)
    (writing_prompts__wp_084_type_character ?x - object)
    (writing_prompts__wp_084_type_object ?x - object)
    (writing_prompts__wp_084_p_loves ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_p_confessed ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_p_asked-question ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_p_took-pill ?v0 - object)
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
          (shared_p_consensus_a82c5cebb25cfc11 ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a82c5cebb25cfc11 ?character ?from))
        (shared_p_consensus_a82c5cebb25cfc11 ?character ?to)
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
          (shared_p_consensus_a82c5cebb25cfc11 ?interrogator ?location)
          (shared_p_consensus_a82c5cebb25cfc11 ?interrogated ?location)
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
          (shared_p_consensus_a82c5cebb25cfc11 ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (shared_p_consensus_a82c5cebb25cfc11 ?victim ?placed)
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
          (shared_p_consensus_a82c5cebb25cfc11 ?saver ?location)
          (shared_p_consensus_a82c5cebb25cfc11 ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (shared_p_consensus_a82c5cebb25cfc11 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (tiny_stories__story_063_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (tiny_stories__story_063_p_helping ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (tiny_stories__story_063_p_helping ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_077_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_type_place ?from)
        (tiny_stories__story_077_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_a82c5cebb25cfc11 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a82c5cebb25cfc11 ?character ?from))
        (shared_p_consensus_a82c5cebb25cfc11 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_077_a_play
    :parameters (?character1 - object ?character2 - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character1)
        (tiny_stories__story_077_type_character ?character2)
        (tiny_stories__story_077_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_a82c5cebb25cfc11 ?character1 ?place)
          (shared_p_consensus_a82c5cebb25cfc11 ?character2 ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_077_p_played-together ?character1 ?character2)
        (tiny_stories__story_077_p_happy ?character1)
        (tiny_stories__story_077_p_happy ?character2)
        (tiny_stories__story_077_p_tired ?character1)
        (tiny_stories__story_077_p_tired ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_077_a_rest
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_p_tired ?character)
      )
    :effect
      (not (tiny_stories__story_077_p_tired ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_084_a_take-pill
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?character)
        (not (writing_prompts__wp_084_p_took-pill ?character))
      )
    :effect
      (writing_prompts__wp_084_p_took-pill ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_084_a_ask-love-question
    :parameters (?asker - object ?asked - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?asker)
        (writing_prompts__wp_084_type_character ?asked)
        (not (writing_prompts__wp_084_p_asked-question ?asker ?asked))
      )
    :effect
      (writing_prompts__wp_084_p_asked-question ?asker ?asked)
    :agents (?asker)
  )

  (:action writing_prompts__wp_084_a_confess-love
    :parameters (?confessor - object ?confessed-to - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?confessor)
        (writing_prompts__wp_084_type_character ?confessed-to)
        (and
          (not (writing_prompts__wp_084_p_confessed ?confessor ?confessed-to))
          (writing_prompts__wp_084_p_asked-question ?confessed-to ?confessor)
          (writing_prompts__wp_084_p_took-pill ?confessor)
        )
      )
    :effect
      (and
        (writing_prompts__wp_084_p_confessed ?confessor ?confessed-to)
        (writing_prompts__wp_084_p_loves ?confessor ?confessed-to)
      )
    :agents (?confessor)
  )
)
