(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (alive ?p0)
    (has ?p0 ?p1)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
    (at ?p0 ?p1)
    (in-box ?p0 ?p1)
    (nervous ?p0)
    (composed ?p0)
    (noticed ?p0 ?p1)
    (opened ?p0)
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

  (:action become-nervous
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_character ?character)
        )
        (and)
      )
    :effect
      (nervous ?character)
  )

  (:action become-composed
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_character ?character)
        )
        (and)
      )
    :effect
      (composed ?character)
  )

  (:action enter
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_place ?place)
        )
        (not (at ?character ?place))
      )
    :effect
      (at ?character ?place)
  )

  (:action notice
    :parameters (?character ?box ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
        )
        (and
          (at ?character ?place)
          (at ?box ?place)
        )
      )
    :effect
      (noticed ?character ?box)
  )

  (:action open-box
    :parameters (?character ?box ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
        )
        (and
          (at ?character ?place)
          (at ?box ?place)
          (noticed ?character ?box)
          (not (opened ?box))
        )
      )
    :effect
      (opened ?box)
  )
)
