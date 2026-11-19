(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_alive ?v0 - object)
    (writing_prompts__wp_060_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
    (writing_prompts__wp_090_active)
    (writing_prompts__wp_090_type_character ?x - object)
    (writing_prompts__wp_090_type_object ?x - object)
    (writing_prompts__wp_090_p_famous ?v0 - object)
    (writing_prompts__wp_090_p_wears-earmuffs ?v0 - object)
    (writing_prompts__wp_090_p_filled-with-ice ?v0 - object)
    (writing_prompts__wp_090_p_candidate ?v0 - object)
    (writing_prompts__wp_090_p_president ?v0 - object)
    (writing_prompts__wp_090_p_endured-pain ?v0 - object)
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
          (writing_prompts__wp_060_p_has ?character ?item)
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
          (writing_prompts__wp_060_p_has ?character ?item)
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
          (writing_prompts__wp_060_p_has ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_become-famous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (not (writing_prompts__wp_090_p_famous ?character))
      )
    :effect
      (writing_prompts__wp_090_p_famous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_wear-earmuffs
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (not (writing_prompts__wp_090_p_wears-earmuffs ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_wears-earmuffs ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_fill-earmuffs-with-ice
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (writing_prompts__wp_090_p_wears-earmuffs ?character)
          (not (writing_prompts__wp_090_p_filled-with-ice ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_filled-with-ice ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_become-candidate
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (not (writing_prompts__wp_090_p_candidate ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_candidate ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_become-president
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_candidate ?character)
          (not (writing_prompts__wp_090_p_president ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_president ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_endure-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (writing_prompts__wp_090_p_filled-with-ice ?character)
          (not (writing_prompts__wp_090_p_endured-pain ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_endured-pain ?character)
    :agents (?character)
  )
)
