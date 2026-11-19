(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :domain-axioms :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (shared_p_consensus_3c280ee2628f491f ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (shared_p_consensus_266ba37658481c65 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (shared_p_consensus_371399e48715efaa ?v0 - object)
    (tiny_stories__story_087_active)
    (tiny_stories__story_087_type_character ?x - object)
    (tiny_stories__story_087_type_object ?x - object)
    (tiny_stories__story_087_p_party-prepared ?v0 - object)
    (tiny_stories__story_087_p_has-balloons)
    (tiny_stories__story_087_p_has-cake)
    (tiny_stories__story_087_p_has-present ?v0 - object)
    (tiny_stories__story_087_p_played-games)
    (tiny_stories__story_087_p_thanked-parents ?v0 - object)
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character ?x - object)
    (writing_prompts__wp_089_type_item ?x - object)
    (writing_prompts__wp_089_type_object ?x - object)
    (writing_prompts__wp_089_type_room ?x - object)
    (writing_prompts__wp_089_type_thing ?x - object)
    (writing_prompts__wp_089_p_has-key ?v0 - object)
    (writing_prompts__wp_089_p_in ?v0 - object ?v1 - object)
    (writing_prompts__wp_089_p_sick ?v0 - object)
    (writing_prompts__wp_089_p_called-911 ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (tiny_stories__story_087_active) (tiny_stories__story_087_type_character ?character) (and (not (shared_p_consensus_371399e48715efaa ?character)) (tiny_stories__story_087_p_party-prepared ?character) (tiny_stories__story_087_p_has-balloons) (tiny_stories__story_087_p_has-cake) (tiny_stories__story_087_p_played-games) (tiny_stories__story_087_p_has-present ?character) (tiny_stories__story_087_p_thanked-parents ?character))) :implies (shared_p_consensus_371399e48715efaa ?character))

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
          (shared_p_consensus_3c280ee2628f491f ?interrogator ?location)
          (shared_p_consensus_3c280ee2628f491f ?interrogated ?location)
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
          (shared_p_consensus_3c280ee2628f491f ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (shared_p_consensus_3c280ee2628f491f ?victim ?placed)
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
          (shared_p_consensus_3c280ee2628f491f ?saver ?location)
          (shared_p_consensus_3c280ee2628f491f ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (shared_p_consensus_3c280ee2628f491f ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_266ba37658481c65 ?character ?dress)
          (not (tiny_stories__story_075_p_wearing ?character ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_wearing ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_wearing ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (shared_p_consensus_371399e48715efaa ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (shared_p_consensus_371399e48715efaa ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (tiny_stories__story_075_p_wearing ?character ?old-dress)
          (not (shared_p_consensus_266ba37658481c65 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (shared_p_consensus_266ba37658481c65 ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_prepare-party
    :parameters (?preparer - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?preparer)
        (tiny_stories__story_087_type_character ?receiver)
        (not (tiny_stories__story_087_p_party-prepared ?receiver))
      )
    :effect
      (tiny_stories__story_087_p_party-prepared ?receiver)
    :agents (?preparer ?receiver)
  )

  (:action tiny_stories__story_087_a_decorate-with-balloons
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_has-balloons))
          (tiny_stories__story_087_p_party-prepared ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-balloons)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_prepare-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_has-cake))
          (tiny_stories__story_087_p_party-prepared ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-cake)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_play-games
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (tiny_stories__story_087_p_party-prepared ?character)
      )
    :effect
      (tiny_stories__story_087_p_played-games)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_give-present
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?giver)
        (tiny_stories__story_087_type_character ?receiver)
        (and
          (not (tiny_stories__story_087_p_has-present ?receiver))
          (tiny_stories__story_087_p_party-prepared ?receiver)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-present ?receiver)
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_087_a_thank-parents
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_thanked-parents ?character))
          (tiny_stories__story_087_p_has-present ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_thanked-parents ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_take-item
    :parameters (?character - object ?item - object ?room - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?character)
        (writing_prompts__wp_089_type_item ?item)
        (writing_prompts__wp_089_type_room ?room)
        (and
          (shared_p_consensus_3c280ee2628f491f ?character ?room)
          (writing_prompts__wp_089_p_in ?item ?room)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_089_p_in ?item ?room))
        (shared_p_consensus_266ba37658481c65 ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_leave-item
    :parameters (?character - object ?item - object ?room - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?character)
        (writing_prompts__wp_089_type_item ?item)
        (writing_prompts__wp_089_type_room ?room)
        (and
          (shared_p_consensus_3c280ee2628f491f ?character ?room)
          (shared_p_consensus_266ba37658481c65 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_266ba37658481c65 ?character ?item))
        (writing_prompts__wp_089_p_in ?item ?room)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_call-911
    :parameters (?caller - object ?sick-person - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?caller)
        (writing_prompts__wp_089_type_character ?sick-person)
        (and
          (writing_prompts__wp_089_p_sick ?sick-person)
          (not (writing_prompts__wp_089_p_called-911 ?caller ?sick-person))
        )
      )
    :effect
      (writing_prompts__wp_089_p_called-911 ?caller ?sick-person)
    :agents (?caller)
  )

  (:action fused_a_consensus_33d96cb10475ad16
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?m0)
          (human_62959785b3ec220a_type_location ?m1)
          (human_62959785b3ec220a_type_location ?m2)
          (and
            (human_62959785b3ec220a_p_player ?m0)
            (human_62959785b3ec220a_p_connected ?m1 ?m2)
            (shared_p_consensus_3c280ee2628f491f ?m0 ?m2)
            (human_62959785b3ec220a_p_knows ?m0)
          )
        )
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?m0)
          (writing_prompts__wp_089_type_room ?m2)
          (writing_prompts__wp_089_type_room ?m1)
          (and
            (not (= ?m2 ?m1))
            (shared_p_consensus_3c280ee2628f491f ?m0 ?m2)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3c280ee2628f491f ?m0 ?m2))
        (shared_p_consensus_3c280ee2628f491f ?m0 ?m1)
      )
    :agents (?m0)
  )
)
