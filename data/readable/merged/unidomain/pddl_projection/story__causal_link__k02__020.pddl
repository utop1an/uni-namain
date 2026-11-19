(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (hiding ?p0)
    (seeking ?p0)
    (found ?p0 ?p1)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
  )

  (:action stop-seeking
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_character ?character)
        )
        (seeking ?character)
      )
    :effect
      (not (seeking ?character))
  )

  (:action start-hiding
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (hiding ?character)
  )

  (:action start-seeking
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (seeking ?character)
  )

  (:action find
    :parameters (?seeker ?hider ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
        )
        (and
          (seeking ?seeker)
          (hiding ?hider)
          (at ?seeker ?place)
          (at ?hider ?place)
        )
      )
    :effect
      (and
        (found ?seeker ?hider)
        (not (hiding ?hider))
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
