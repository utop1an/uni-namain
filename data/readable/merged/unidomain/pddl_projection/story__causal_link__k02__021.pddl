(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (hidden ?p0 ?p1)
    (found ?p0)
    (searched ?p0 ?p1)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
  )

  (:action hide
    :parameters (?character ?toy ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (hidden ?toy ?place)
  )

  (:action search
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?place)
        )
        (and
          (at ?character ?place)
          (not (searched ?character ?place))
        )
      )
    :effect
      (searched ?character ?place)
  )

  (:action find
    :parameters (?character ?toy ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
        )
        (and
          (at ?character ?place)
          (hidden ?toy ?place)
          (searched ?character ?place)
        )
      )
    :effect
      (found ?toy)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?from)
          (tiny_stories__story_027_type_place ?to)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?from)
          (tiny_stories__story_027_type_place ?to)
        )
        (and
          (not (= ?from ?to))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
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
