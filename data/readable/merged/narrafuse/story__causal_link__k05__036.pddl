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
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_8cd1facae5ce6c3e ?v0 - object ?v1 - object)
    (shared_p_consensus_ff9a88689bd88cb5 ?v0 - object)
    (shared_p_consensus_c6f45c9fb940fa44 ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_035_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_1f72a79b43e07543 ?v0 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (writing_prompts__wp_035_p_at ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (shared_p_consensus_1f72a79b43e07543 ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_c6f45c9fb940fa44 ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_c6f45c9fb940fa44 ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

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

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_c6f45c9fb940fa44 ?character ?object)
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
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_c6f45c9fb940fa44 ?character ?object)
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
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
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
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?from)
          (shared_p_consensus_c6f45c9fb940fa44 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8cd1facae5ce6c3e ?character ?from))
        (shared_p_consensus_8cd1facae5ce6c3e ?character ?to)
        (not (shared_p_consensus_c6f45c9fb940fa44 ?character ?object))
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
          (not (writing_prompts__wp_035_p_at ?character ?to))
        )
      )
    :effect
      (writing_prompts__wp_035_p_at ?character ?to)
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

  (:action writing_prompts__wp_036_a_create-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (shared_p_consensus_ff9a88689bd88cb5 ?character)
      )
    :effect
      (and
        (writing_prompts__wp_036_p_created ?character ?lightbox)
        (writing_prompts__wp_036_p_has ?character ?lightbox)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_anchor-light
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_anchored ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_charge-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_anchored ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_charged ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_use-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_charged ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (and
        (writing_prompts__wp_036_p_used ?character ?lightbox)
        (not (writing_prompts__wp_036_p_charged ?lightbox))
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_c6f45c9fb940fa44 ?character ?item)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
          (shared_p_consensus_c6f45c9fb940fa44 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c6f45c9fb940fa44 ?character ?item))
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
          (shared_p_consensus_8cd1facae5ce6c3e ?killer ?place)
          (shared_p_consensus_c6f45c9fb940fa44 ?killer ?weapon)
          (shared_p_consensus_1f72a79b43e07543 ?victim)
          (shared_p_consensus_8cd1facae5ce6c3e ?victim ?place)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8cd1facae5ce6c3e ?character ?from))
        (shared_p_consensus_8cd1facae5ce6c3e ?character ?to)
      )
    :agents (?character)
  )
)
