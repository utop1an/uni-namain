(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_014_p_at-park ?v0 - object)
    (tiny_stories__story_014_p_on-swing ?v0 - object)
    (tiny_stories__story_014_p_swinging ?v0 - object)
    (tiny_stories__story_014_p_sharing ?v0 - object ?v1 - object)
    (shared_p_consensus_90dd6d5e30e5ac15 ?v0 - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (writing_prompts__wp_091_p_feels-awful ?v0 - object)
    (writing_prompts__wp_091_p_thinks-about-breakup ?v0 - object)
    (writing_prompts__wp_091_p_heartbroken ?v0 - object)
    (writing_prompts__wp_091_p_forgiven ?v0 - object)
    (writing_prompts__wp_091_p_learned ?v0 - object)
    (writing_prompts__wp_091_p_moved-on ?v0 - object)
  )

  (:action tiny_stories__story_014_a_go-to-park
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (not (tiny_stories__story_014_p_at-park ?character))
      )
    :effect
      (tiny_stories__story_014_p_at-park ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_get-on-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_at-park ?character)
          (not (tiny_stories__story_014_p_on-swing ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_on-swing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_start-swinging
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (not (tiny_stories__story_014_p_swinging ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_swinging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_share-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_swinging ?character1)
          (tiny_stories__story_014_p_swinging ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_sharing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_014_a_get-off-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (tiny_stories__story_014_p_swinging ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_014_p_on-swing ?character))
        (not (tiny_stories__story_014_p_swinging ?character))
        (shared_p_consensus_90dd6d5e30e5ac15 ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_thank
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_sharing ?character1 ?character2)
        )
      )
    :effect
      (shared_p_consensus_90dd6d5e30e5ac15 ?character1)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_90dd6d5e30e5ac15 ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_90dd6d5e30e5ac15 ?character)
          (tiny_stories__story_060_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_060_p_at ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_90dd6d5e30e5ac15 ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_90dd6d5e30e5ac15 ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (shared_p_consensus_90dd6d5e30e5ac15 ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_forgive
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_feels-awful ?character)
          (not (writing_prompts__wp_091_p_forgiven ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_forgiven ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_learn
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_heartbroken ?character)
          (not (writing_prompts__wp_091_p_learned ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_learned ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_move-on
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_thinks-about-breakup ?character)
          (writing_prompts__wp_091_p_forgiven ?character)
          (writing_prompts__wp_091_p_learned ?character)
          (not (writing_prompts__wp_091_p_moved-on ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_moved-on ?character)
    :agents (?character)
  )
)
