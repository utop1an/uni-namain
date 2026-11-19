(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_090_active)
    (writing_prompts__wp_090_type_character ?x - object)
    (writing_prompts__wp_090_type_object ?x - object)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (clean ?p0)
    (locked ?p0)
    (wearing ?p0 ?p1)
    (fits ?p0 ?p1)
    (famous ?p0)
    (wears-earmuffs ?p0)
    (filled-with-ice ?p0)
    (candidate ?p0)
    (president ?p0)
    (endured-pain ?p0)
  )

  (:action clean-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (clean ?item))
        )
      )
    :effect
      (clean ?item)
  )

  (:action lock-door
    :parameters (?character ?door)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
        )
        (and
          (alive ?character)
          (not (locked ?door))
        )
      )
    :effect
      (locked ?door)
  )

  (:action adjust-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (fits ?item ?character))
        )
      )
    :effect
      (fits ?item ?character)
  )

  (:action wear-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (fits ?item ?character)
          (not (wearing ?character ?item))
        )
      )
    :effect
      (wearing ?character ?item)
  )

  (:action become-famous
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (not (famous ?character))
      )
    :effect
      (famous ?character)
  )

  (:action wear-earmuffs
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (not (wears-earmuffs ?character))
        )
      )
    :effect
      (wears-earmuffs ?character)
  )

  (:action fill-earmuffs-with-ice
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (wears-earmuffs ?character)
          (not (filled-with-ice ?character))
        )
      )
    :effect
      (filled-with-ice ?character)
  )

  (:action become-candidate
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (not (candidate ?character))
        )
      )
    :effect
      (candidate ?character)
  )

  (:action become-president
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (candidate ?character)
          (not (president ?character))
        )
      )
    :effect
      (president ?character)
  )

  (:action endure-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (filled-with-ice ?character)
          (not (endured-pain ?character))
        )
      )
    :effect
      (endured-pain ?character)
  )
)
