(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_020_active)
    (writing_prompts__wp_020_type_character ?x - object)
    (writing_prompts__wp_020_type_object ?x - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (hurting ?p0)
    (struggling ?p0)
    (loved ?p0 ?p1)
    (letting-go ?p0 ?p1)
    (ready ?p0)
    (better-times ?p0)
    (in-box ?p0 ?p1)
    (at ?p0 ?p1)
    (nervous ?p0)
    (composed ?p0)
    (noticed ?p0 ?p1)
    (opened ?p0)
  )

  (:action acknowledge-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character)
          (writing_prompts__wp_020_type_character ?character)
        )
        (and
          (hurting ?character)
          (struggling ?character)
        )
      )
    :effect
      (not (struggling ?character))
  )

  (:action let-go
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character1)
          (writing_prompts__wp_020_type_character ?character2)
          (writing_prompts__wp_020_type_character ?character1)
          (writing_prompts__wp_020_type_character ?character2)
        )
        (and
          (loved ?character1 ?character2)
          (not (ready ?character2))
        )
      )
    :effect
      (letting-go ?character1 ?character2)
  )

  (:action believe-in-better-times
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character)
          (writing_prompts__wp_020_type_character ?character)
        )
        (hurting ?character)
      )
    :effect
      (better-times ?character)
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
)
