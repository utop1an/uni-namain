(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (shared_p_consensus_11ffa670cbaaaada ?v0 - object ?v1 - object)
    (shared_p_consensus_f9a8269ff601a25b ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (shared_p_consensus_8ee28d7ee67a5420 ?v0 - object ?v1 - object)
    (shared_p_consensus_1f72a79b43e07543 ?v0 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (shared_p_consensus_8ee28d7ee67a5420 ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (shared_p_consensus_1f72a79b43e07543 ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (writing_prompts__wp_054_p_has ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (writing_prompts__wp_054_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_f9a8269ff601a25b ?character ?dress)
          (not (shared_p_consensus_11ffa670cbaaaada ?character ?dress))
        )
      )
    :effect
      (shared_p_consensus_11ffa670cbaaaada ?character ?dress)
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
          (shared_p_consensus_11ffa670cbaaaada ?character ?dress)
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
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
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
          (shared_p_consensus_11ffa670cbaaaada ?character ?old-dress)
          (not (shared_p_consensus_f9a8269ff601a25b ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_11ffa670cbaaaada ?character ?old-dress))
        (shared_p_consensus_f9a8269ff601a25b ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_travel
    :parameters (?character - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_place ?to)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (not (shared_p_consensus_8ee28d7ee67a5420 ?character ?to))
        )
      )
    :effect
      (shared_p_consensus_8ee28d7ee67a5420 ?character ?to)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-smoking
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_f9a8269ff601a25b ?character ?item)
          (not (writing_prompts__wp_035_p_smoking ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_smoking ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-dancing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (not (writing_prompts__wp_035_p_dancing ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_dancing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-eating
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_f9a8269ff601a25b ?character ?item)
          (not (writing_prompts__wp_035_p_eating ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_eating ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_shrink
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (not (writing_prompts__wp_035_p_shrunk ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_shrunk ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_change-clothes
    :parameters (?character - object ?old-item - object ?new-item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?old-item)
        (writing_prompts__wp_035_type_item ?new-item)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_11ffa670cbaaaada ?character ?old-item)
          (shared_p_consensus_f9a8269ff601a25b ?character ?new-item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_11ffa670cbaaaada ?character ?old-item))
        (shared_p_consensus_11ffa670cbaaaada ?character ?new-item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (writing_prompts__wp_054_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?place)
          (writing_prompts__wp_054_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_has ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (shared_p_consensus_1f72a79b43e07543 ?killer)
          (shared_p_consensus_8ee28d7ee67a5420 ?killer ?place)
          (writing_prompts__wp_054_p_has ?killer ?weapon)
          (shared_p_consensus_1f72a79b43e07543 ?victim)
          (shared_p_consensus_8ee28d7ee67a5420 ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_1f72a79b43e07543 ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_1f72a79b43e07543 ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8ee28d7ee67a5420 ?character ?from))
        (shared_p_consensus_8ee28d7ee67a5420 ?character ?to)
      )
    :agents (?character)
  )
)
