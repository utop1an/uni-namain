(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (on-shelf ?p0)
    (organized ?p0)
    (reads ?p0)
    (happy ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (alive ?p0)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
  )

  (:action read
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_character ?character)
        )
        (reads ?character)
      )
    :effect
      (happy ?character)
  )

  (:action smell-soap
    :parameters (?character ?soap)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?soap)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?soap)
        )
        (and
          (on-shelf ?soap)
          (reads ?character)
        )
      )
    :effect
      (happy ?character)
  )

  (:action find
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?object)
          (tiny_stories__story_028_type_character ?character)
        )
        (and
          (not (has ?character ?object))
          (reads ?character)
        )
      )
    :effect
      (has ?character ?object)
  )

  (:action put-on-shelf
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?object)
          (tiny_stories__story_028_type_place ?place)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_place ?place)
        )
        (and
          (has ?character ?object)
          (at ?character ?place)
        )
      )
    :effect
      (and
        (not (has ?character ?object))
        (on-shelf ?object)
        (organized ?place)
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
