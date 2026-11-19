(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (shared_p_consensus_2ddb75a7410f9a21 ?v0 - object ?v1 - object)
    (shared_p_consensus_23368732e69ec885 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_has ?v0 - object ?v1 - object)
    (shared_p_consensus_1dd866a02e712e9a ?v0 - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_23368732e69ec885 ?character ?dress)
          (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress))
        )
      )
    :effect
      (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress)
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
          (shared_p_consensus_2ddb75a7410f9a21 ?character ?dress)
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
          (shared_p_consensus_2ddb75a7410f9a21 ?character ?old-dress)
          (not (shared_p_consensus_23368732e69ec885 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?old-dress))
        (shared_p_consensus_23368732e69ec885 ?character ?new-dress)
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
        (shared_p_consensus_1dd866a02e712e9a ?character)
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
          (shared_p_consensus_1dd866a02e712e9a ?character)
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
          (shared_p_consensus_1dd866a02e712e9a ?character)
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
          (shared_p_consensus_1dd866a02e712e9a ?character)
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

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_1dd866a02e712e9a ?character)
          (shared_p_consensus_23368732e69ec885 ?character ?item)
          (not (writing_prompts__wp_060_p_clean ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_clean ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?door)
        (and
          (shared_p_consensus_1dd866a02e712e9a ?character)
          (not (writing_prompts__wp_060_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_060_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_adjust-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_1dd866a02e712e9a ?character)
          (shared_p_consensus_23368732e69ec885 ?character ?item)
          (not (writing_prompts__wp_060_p_fits ?item ?character))
        )
      )
    :effect
      (writing_prompts__wp_060_p_fits ?item ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_wear-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_1dd866a02e712e9a ?character)
          (shared_p_consensus_23368732e69ec885 ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (shared_p_consensus_2ddb75a7410f9a21 ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_2ddb75a7410f9a21 ?character ?item)
    :agents (?character)
  )
)
