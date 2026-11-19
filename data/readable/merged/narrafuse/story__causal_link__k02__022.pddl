(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_033_active)
    (tiny_stories__story_033_type_character ?x - object)
    (tiny_stories__story_033_type_object ?x - object)
    (tiny_stories__story_033_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_ef614b4c8bca567e ?v0 - object)
    (tiny_stories__story_033_p_sad ?v0 - object)
    (tiny_stories__story_033_p_offered-snack ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_snack-is-lie ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_trusts ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_compassionate ?v0 - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
  )

  (:action tiny_stories__story_033_a_go-to-place
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?character1)
        (tiny_stories__story_033_type_character ?character2)
        (and
          (not (tiny_stories__story_033_p_at ?character1 ?character2))
          (shared_p_consensus_ef614b4c8bca567e ?character1)
        )
      )
    :effect
      (and
        (tiny_stories__story_033_p_at ?character1 ?character2)
        (not (shared_p_consensus_ef614b4c8bca567e ?character1))
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_033_a_offer-snack
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?giver)
        (tiny_stories__story_033_type_character ?receiver)
        (and
          (tiny_stories__story_033_p_at ?receiver ?giver)
          (tiny_stories__story_033_p_compassionate ?giver)
        )
      )
    :effect
      (tiny_stories__story_033_p_offered-snack ?giver ?receiver)
    :agents (?giver)
  )

  (:action tiny_stories__story_033_a_reveal-lie
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?giver)
        (tiny_stories__story_033_type_character ?receiver)
        (and
          (tiny_stories__story_033_p_offered-snack ?giver ?receiver)
          (not (tiny_stories__story_033_p_compassionate ?giver))
        )
      )
    :effect
      (and
        (tiny_stories__story_033_p_snack-is-lie ?giver ?receiver)
        (not (shared_p_consensus_ef614b4c8bca567e ?receiver))
        (tiny_stories__story_033_p_sad ?receiver)
      )
    :agents (?giver)
  )

  (:action tiny_stories__story_033_a_run-away
    :parameters (?runner - object ?from - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?runner)
        (tiny_stories__story_033_type_character ?from)
        (and
          (tiny_stories__story_033_p_at ?runner ?from)
          (tiny_stories__story_033_p_sad ?runner)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_033_p_at ?runner ?from))
        (not (tiny_stories__story_033_p_trusts ?runner ?from))
      )
    :agents (?runner)
  )

  (:action tiny_stories__story_033_a_learn-lesson
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?character)
        (and
          (tiny_stories__story_033_p_sad ?character)
          (not (tiny_stories__story_033_p_trusts ?character ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_033_p_sad ?character))
        (shared_p_consensus_ef614b4c8bca567e ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_ef614b4c8bca567e ?character)
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
          (shared_p_consensus_ef614b4c8bca567e ?character)
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
        (shared_p_consensus_ef614b4c8bca567e ?character)
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
          (shared_p_consensus_ef614b4c8bca567e ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (shared_p_consensus_ef614b4c8bca567e ?character)
    :agents (?character)
  )
)
