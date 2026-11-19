(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (clean ?p0)
    (locked ?p0)
    (fits ?p0 ?p1)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (wearing ?p0 ?p1)
    (damaged ?p0)
    (happy ?p0)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
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

  (:action clean-item
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (not (clean ?object))
        )
      )
    :effect
      (clean ?object)
  )

  (:action adjust-item
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (not (fits ?object ?character))
        )
      )
    :effect
      (fits ?object ?character)
  )

  (:action comfort
    :parameters (?parent ?child)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?parent)
          (tiny_stories__story_075_type_character ?child)
          (tiny_stories__story_075_type_character ?parent)
          (tiny_stories__story_075_type_character ?child)
        )
        (and
          (not (happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (happy ?child)
  )

  (:action request-tow
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
        )
      )
    :effect
      (requested-tow ?character ?place)
  )

  (:action detect-stasis
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_character ?character)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (ancient-technology ?object)
        )
      )
    :effect
      (in-stasis ?object)
  )

  (:action discover-technology
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_place ?place)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
        )
      )
    :effect
      (and
        (has ?character ?object)
        (ancient-technology ?object)
      )
  )

  (:action transport-object
    :parameters (?character ?object ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_place ?from)
          (writing_prompts__wp_011_type_place ?to)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?from)
          (writing_prompts__wp_011_type_place ?to)
        )
        (and
          (alive ?character)
          (at ?character ?from)
          (has ?character ?object)
          (requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
        (not (has ?character ?object))
      )
  )

  (:action slip
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?item)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_item ?item)
        )
        (and
          (wearing ?character ?item)
          (not (damaged ?item))
        )
      )
    :effect
      (damaged ?item)
  )

  (:action wear-item
    :parameters (?character ?item)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_060_active)
            (writing_prompts__wp_060_type_character ?character)
            (writing_prompts__wp_060_type_item ?item)
            (writing_prompts__wp_060_type_character ?character)
            (writing_prompts__wp_060_type_item ?item)
          )
          (and
            (tiny_stories__story_075_active)
            (tiny_stories__story_075_type_character ?character)
            (tiny_stories__story_075_type_dress ?item)
            (tiny_stories__story_075_type_character ?character)
            (tiny_stories__story_075_type_item ?item)
          )
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

  (:action get-new-dress
    :parameters (?character ?old-item ?new-object)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-item)
          (tiny_stories__story_075_type_dress ?new-object)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-item)
        )
        (and
          (damaged ?old-item)
          (wearing ?character ?old-item)
          (not (has ?character ?new-object))
        )
      )
    :effect
      (and
        (not (wearing ?character ?old-item))
        (has ?character ?new-object)
      )
  )
)
