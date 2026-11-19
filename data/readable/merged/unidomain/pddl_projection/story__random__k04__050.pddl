(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_006_active)
    (writing_prompts__wp_006_type_character ?x - object)
    (writing_prompts__wp_006_type_object ?x - object)
    (writing_prompts__wp_006_type_place ?x - object)
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_098_active)
    (writing_prompts__wp_098_type_character ?x - object)
    (writing_prompts__wp_098_type_object ?x - object)
    (in-love ?p0 ?p1)
    (accepts-past ?p0 ?p1)
    (knows-self ?p0)
    (sings ?p0)
    (spirits-present ?p0)
    (spirits-gone ?p0)
    (weak ?p0)
    (love-driven-away ?p0)
    (in-asylum ?p0)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (riding ?p0 ?p1)
    (relaxed ?p0)
    (flying ?p0)
    (in-vehicle ?p0 ?p1)
    (feeling ?p0)
    (last-soul ?p0)
    (understand ?p0)
    (witness ?p0)
    (end ?p0)
  )

  (:action sing
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character)
          (writing_prompts__wp_006_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (sings ?character)
  )

  (:action fall-in-love
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (alive ?character1)
          (alive ?character2)
        )
      )
    :effect
      (in-love ?character1 ?character2)
  )

  (:action accept-past
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (alive ?character1)
          (alive ?character2)
        )
      )
    :effect
      (accepts-past ?character1 ?character2)
  )

  (:action know-self
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character)
          (writing_prompts__wp_006_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (knows-self ?character)
  )

  (:action become-weak
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_009_active)
          (writing_prompts__wp_009_type_character ?character)
          (writing_prompts__wp_009_type_character ?character)
        )
        (and
          (alive ?character)
          (spirits-present ?character)
        )
      )
    :effect
      (weak ?character)
  )

  (:action drive-away-love
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_009_active)
          (writing_prompts__wp_009_type_character ?character)
          (writing_prompts__wp_009_type_character ?character)
        )
        (and
          (alive ?character)
          (spirits-present ?character)
        )
      )
    :effect
      (love-driven-away ?character)
  )

  (:action end-up-in-asylum
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_009_active)
          (writing_prompts__wp_009_type_character ?character)
          (writing_prompts__wp_009_type_character ?character)
        )
        (and
          (alive ?character)
          (spirits-present ?character)
        )
      )
    :effect
      (in-asylum ?character)
  )

  (:action ask-spirits-to-leave
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_009_active)
          (writing_prompts__wp_009_type_character ?character)
          (writing_prompts__wp_009_type_character ?character)
        )
        (and
          (alive ?character)
          (spirits-present ?character)
        )
      )
    :effect
      (and
        (spirits-gone ?character)
        (not (spirits-present ?character))
      )
  )

  (:action regret-asking-spirits-to-leave
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_009_active)
          (writing_prompts__wp_009_type_character ?character)
          (writing_prompts__wp_009_type_character ?character)
        )
        (and
          (alive ?character)
          (spirits-gone ?character)
        )
      )
    :effect
      (spirits-present ?character)
  )

  (:action start-riding
    :parameters (?character ?vehicle)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
        )
        (and
          (alive ?character)
          (has ?character ?vehicle)
          (not (riding ?character ?vehicle))
        )
      )
    :effect
      (riding ?character ?vehicle)
  )

  (:action stop-riding
    :parameters (?character ?vehicle)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
        )
        (and
          (alive ?character)
          (riding ?character ?vehicle)
        )
      )
    :effect
      (not (riding ?character ?vehicle))
  )

  (:action start-flying
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (not (flying ?character))
        )
      )
    :effect
      (flying ?character)
  )

  (:action stop-flying
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (flying ?character)
        )
      )
    :effect
      (not (flying ?character))
  )

  (:action try-relax
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (not (relaxed ?character))
        )
      )
    :effect
      (relaxed ?character)
  )

  (:action stop-relax
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (relaxed ?character)
        )
      )
    :effect
      (not (relaxed ?character))
  )

  (:action start-feeling
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (feeling ?character))
        )
      )
    :effect
      (feeling ?character)
  )

  (:action witness-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (witness ?character))
        )
      )
    :effect
      (witness ?character)
  )

  (:action understand-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (witness ?character)
          (not (understand ?character))
        )
      )
    :effect
      (understand ?character)
  )

  (:action last-soul-fades
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (last-soul ?character)
          (understand ?character)
        )
      )
    :effect
      (not (alive ?character))
  )

  (:action humanity-ends
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (understand ?character)
          (not (end ?character))
        )
      )
    :effect
      (end ?character)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_006_active)
            (writing_prompts__wp_006_type_character ?character)
            (writing_prompts__wp_006_type_place ?from)
            (writing_prompts__wp_006_type_place ?to)
            (writing_prompts__wp_006_type_character ?character)
            (writing_prompts__wp_006_type_place ?from)
            (writing_prompts__wp_006_type_place ?to)
          )
          (and
            (writing_prompts__wp_014_active)
            (writing_prompts__wp_014_type_character ?character)
            (writing_prompts__wp_014_type_place ?from)
            (writing_prompts__wp_014_type_place ?to)
            (writing_prompts__wp_014_type_character ?character)
            (writing_prompts__wp_014_type_place ?from)
            (writing_prompts__wp_014_type_place ?to)
          )
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
)
