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
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (delivered ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (alive ?p0)
    (wearing ?p0 ?p1)
    (damaged ?p0)
    (happy ?p0)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
  )

  (:action travel
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_064_active)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_place ?from)
          (writing_prompts__wp_064_type_place ?to)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_place ?from)
          (writing_prompts__wp_064_type_place ?to)
        )
        (and
          (not (= ?from ?to))
          (alive ?character)
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action deliver
    :parameters (?character ?object ?destination)
    :precondition
      (and
        (and
          (writing_prompts__wp_064_active)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_item ?object)
          (writing_prompts__wp_064_type_place ?destination)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_item ?object)
          (writing_prompts__wp_064_type_place ?destination)
        )
        (and
          (alive ?character)
          (at ?character ?destination)
          (has ?character ?object)
        )
      )
    :effect
      (and
        (not (has ?character ?object))
        (delivered ?object)
      )
  )

  (:action pick-up
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_064_active)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_item ?object)
          (writing_prompts__wp_064_type_place ?place)
          (writing_prompts__wp_064_type_character ?character)
          (writing_prompts__wp_064_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
        )
      )
    :effect
      (has ?character ?object)
  )

  (:action slip
    :parameters (?character ?dress)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
        )
        (and
          (wearing ?character ?dress)
          (not (damaged ?dress))
        )
      )
    :effect
      (damaged ?dress)
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

  (:action put-on-dress
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?object)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?object)
        )
        (and
          (has ?character ?object)
          (not (wearing ?character ?object))
        )
      )
    :effect
      (wearing ?character ?object)
  )

  (:action get-new-dress
    :parameters (?character ?old-dress ?new-object)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-dress)
          (tiny_stories__story_075_type_dress ?new-object)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-dress)
        )
        (and
          (damaged ?old-dress)
          (wearing ?character ?old-dress)
          (not (has ?character ?new-object))
        )
      )
    :effect
      (and
        (not (wearing ?character ?old-dress))
        (has ?character ?new-object)
      )
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
)
