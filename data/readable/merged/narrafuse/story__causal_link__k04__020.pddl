(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_084_o_rocket - object)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (shared_p_consensus_11ffa670cbaaaada ?v0 - object ?v1 - object)
    (shared_p_consensus_81e2033e49d4e919 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (shared_p_consensus_762a6bfdbdccacbe ?v0 - object)
    (tiny_stories__story_084_active)
    (tiny_stories__story_084_type_character ?x - object)
    (tiny_stories__story_084_type_item ?x - object)
    (tiny_stories__story_084_type_object ?x - object)
    (tiny_stories__story_084_type_place ?x - object)
    (tiny_stories__story_084_type_toy ?x - object)
    (shared_p_consensus_a0a6c6d2b014484e ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_played-with ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_6fe8802073cec4e4 ?v0 - object)
    (shared_p_consensus_f1dacab806644da4 ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (shared_p_consensus_a0a6c6d2b014484e ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (shared_p_consensus_6fe8802073cec4e4 ?character))

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_81e2033e49d4e919 ?character ?dress)
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
          (not (shared_p_consensus_762a6bfdbdccacbe ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (shared_p_consensus_762a6bfdbdccacbe ?child)
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
          (not (shared_p_consensus_81e2033e49d4e919 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_11ffa670cbaaaada ?character ?old-dress))
        (shared_p_consensus_81e2033e49d4e919 ?character ?new-dress)
      )
    :agents (?character)
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
          (shared_p_consensus_a0a6c6d2b014484e ?character ?place)
          (not (tiny_stories__story_084_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_084_p_found ?character ?item)
        (shared_p_consensus_81e2033e49d4e919 ?character ?item)
        (shared_p_consensus_762a6bfdbdccacbe ?character)
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
          (shared_p_consensus_a0a6c6d2b014484e ?shower ?place)
          (shared_p_consensus_81e2033e49d4e919 ?shower ?item)
          (shared_p_consensus_a0a6c6d2b014484e ?receiver ?place)
        )
      )
    :effect
      (shared_p_consensus_762a6bfdbdccacbe ?receiver)
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
          (shared_p_consensus_a0a6c6d2b014484e ?character1 ?place)
          (shared_p_consensus_81e2033e49d4e919 ?character1 ?item)
          (shared_p_consensus_a0a6c6d2b014484e ?character2 ?place)
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
      (shared_p_consensus_762a6bfdbdccacbe ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_f1dacab806644da4 ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (shared_p_consensus_f1dacab806644da4 ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (writing_prompts__wp_011_p_at ?character ?from)
          (shared_p_consensus_f1dacab806644da4 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_011_p_at ?character ?from))
        (writing_prompts__wp_011_p_at ?character ?to)
        (not (shared_p_consensus_f1dacab806644da4 ?character ?object))
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (not (shared_p_consensus_a0a6c6d2b014484e ?character ?to))
        )
      )
    :effect
      (shared_p_consensus_a0a6c6d2b014484e ?character ?to)
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (shared_p_consensus_f1dacab806644da4 ?character ?item)
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (shared_p_consensus_f1dacab806644da4 ?character ?item)
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
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
          (shared_p_consensus_6fe8802073cec4e4 ?character)
          (shared_p_consensus_11ffa670cbaaaada ?character ?old-item)
          (shared_p_consensus_f1dacab806644da4 ?character ?new-item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_11ffa670cbaaaada ?character ?old-item))
        (shared_p_consensus_11ffa670cbaaaada ?character ?new-item)
      )
    :agents (?character)
  )
)
