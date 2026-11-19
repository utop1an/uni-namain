(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:constants writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
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
    (shared_p_consensus_cfbf71d026712feb ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (tiny_stories__story_094_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_094_p_happy ?v0 - object)
    (tiny_stories__story_094_p_sad ?v0 - object)
    (tiny_stories__story_094_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (shared_p_consensus_cfbf71d026712feb ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (shared_p_consensus_cfbf71d026712feb ?character))

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
        (not (shared_p_consensus_cfbf71d026712feb ?notsaved))
      )
  )

  (:action tiny_stories__story_094_a_receive-gift
    :parameters (?receiver - object ?giver - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?receiver)
        (tiny_stories__story_094_type_character ?giver)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?receiver ?giver))
          (tiny_stories__story_094_p_happy ?giver)
          (not (tiny_stories__story_094_p_has ?receiver ?item))
          (tiny_stories__story_094_p_has ?giver ?item)
        )
      )
    :effect
      (and
        (tiny_stories__story_094_p_has ?receiver ?item)
        (tiny_stories__story_094_p_happy ?receiver)
      )
    :agents (?receiver ?giver)
  )

  (:action tiny_stories__story_094_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (not (tiny_stories__story_094_p_sad ?character))
        )
      )
    :effect
      (tiny_stories__story_094_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_take-toy
    :parameters (?taker - object ?victim - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?taker)
        (tiny_stories__story_094_type_character ?victim)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?taker ?victim))
          (tiny_stories__story_094_p_has ?victim ?item)
          (not (tiny_stories__story_094_p_has ?taker ?item))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?victim ?item))
        (tiny_stories__story_094_p_has ?taker ?item)
        (tiny_stories__story_094_p_sad ?victim)
      )
    :agents (?taker)
  )

  (:action tiny_stories__story_094_a_lose-toy
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (tiny_stories__story_094_p_happy ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?character ?item))
        (tiny_stories__story_094_p_sad ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_offer-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (not (writing_prompts__wp_048_p_offered ?character ?trial))
        )
      )
    :effect
      (writing_prompts__wp_048_p_offered ?character ?trial)
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_048_a_choose-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (writing_prompts__wp_048_p_offered ?character ?trial)
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_completed ?character ?trial)
        (not (writing_prompts__wp_048_p_offered ?character ?trial))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_rebirth
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (or
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears)
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_cfbf71d026712feb ?character)
        (not (writing_prompts__wp_048_p_dead ?character))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears))
      )
    :agents (writing_prompts__wp_048_o_death)
  )
)
