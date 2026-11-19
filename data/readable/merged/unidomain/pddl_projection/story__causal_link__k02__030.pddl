(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (at ?p0 ?p1)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (anchored ?p0)
    (charged ?p0)
    (created ?p0 ?p1)
    (used ?p0 ?p1)
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

  (:action charge-lightbox
    :parameters (?character ?lightbox)
    :precondition
      (and
        (and
          (writing_prompts__wp_036_active)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?lightbox)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?lightbox)
        )
        (and
          (alive ?character)
          (anchored ?lightbox)
          (created ?character ?lightbox)
        )
      )
    :effect
      (charged ?lightbox)
  )

  (:action create-lightbox
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_036_active)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
        )
        (alive ?character)
      )
    :effect
      (and
        (created ?character ?object)
        (has ?character ?object)
      )
  )

  (:action anchor-light
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_036_active)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
        )
        (and
          (alive ?character)
          (created ?character ?object)
          (has ?character ?object)
        )
      )
    :effect
      (anchored ?object)
  )

  (:action use-lightbox
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_036_active)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
          (writing_prompts__wp_036_type_character ?character)
          (writing_prompts__wp_036_type_lightbox ?object)
        )
        (and
          (alive ?character)
          (charged ?object)
          (created ?character ?object)
          (has ?character ?object)
        )
      )
    :effect
      (and
        (used ?character ?object)
        (not (charged ?object))
      )
  )
)
