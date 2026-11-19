(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_074_active)
    (tiny_stories__story_074_type_character ?x - object)
    (tiny_stories__story_074_type_object ?x - object)
    (tiny_stories__story_074_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_b0e18e30885a0c64 ?v0 - object ?v1 - object)
    (tiny_stories__story_074_p_happy ?v0 - object)
    (tiny_stories__story_074_p_magic ?v0 - object)
    (tiny_stories__story_074_p_granted-wish ?v0 - object)
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (tiny_stories__story_089_p_playing ?v0 - object)
    (tiny_stories__story_089_p_tired ?v0 - object)
    (tiny_stories__story_089_p_sleeping ?v0 - object)
    (tiny_stories__story_089_p_awake ?v0 - object)
    (tiny_stories__story_089_p_has-energy ?v0 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_alive ?v0 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_074_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (tiny_stories__story_074_type_object ?place)
        (not (tiny_stories__story_074_p_at ?character ?place))
      )
    :effect
      (tiny_stories__story_074_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_sit-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (not (tiny_stories__story_074_p_happy ?character))
      )
    :effect
      (tiny_stories__story_074_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_share-snack
    :parameters (?sharer - object ?receiver - object ?snack - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?sharer)
        (tiny_stories__story_074_type_character ?receiver)
        (tiny_stories__story_074_type_object ?snack)
        (and
          (shared_p_consensus_b0e18e30885a0c64 ?sharer ?snack)
          (not (shared_p_consensus_b0e18e30885a0c64 ?receiver ?snack))
        )
      )
    :effect
      (shared_p_consensus_b0e18e30885a0c64 ?receiver ?snack)
    :agents (?sharer)
  )

  (:action tiny_stories__story_074_a_become-magic
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (not (tiny_stories__story_074_p_magic ?character))
      )
    :effect
      (tiny_stories__story_074_p_magic ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_grant-wish
    :parameters (?granter - object ?wish - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?granter)
        (tiny_stories__story_074_type_object ?wish)
        (tiny_stories__story_074_p_magic ?granter)
      )
    :effect
      (tiny_stories__story_074_p_granted-wish ?wish)
    :agents (?granter)
  )

  (:action tiny_stories__story_089_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_awake ?character)
          (not (tiny_stories__story_089_p_playing ?character))
          (tiny_stories__story_089_p_has-energy ?character)
        )
      )
    :effect
      (tiny_stories__story_089_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_playing ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_playing ?character))
        (tiny_stories__story_089_p_tired ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_tired ?character)
          (not (tiny_stories__story_089_p_sleeping ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_awake ?character))
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :effect
      (and
        (tiny_stories__story_089_p_awake ?character)
        (not (tiny_stories__story_089_p_sleeping ?character))
        (not (tiny_stories__story_089_p_tired ?character))
        (tiny_stories__story_089_p_has-energy ?character)
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
          (writing_prompts__wp_060_p_alive ?character)
          (shared_p_consensus_b0e18e30885a0c64 ?character ?item)
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
          (writing_prompts__wp_060_p_alive ?character)
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
          (writing_prompts__wp_060_p_alive ?character)
          (shared_p_consensus_b0e18e30885a0c64 ?character ?item)
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
          (writing_prompts__wp_060_p_alive ?character)
          (shared_p_consensus_b0e18e30885a0c64 ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )
)
