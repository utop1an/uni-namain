(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (alive ?p0)
    (spirits-present ?p0)
    (spirits-gone ?p0)
    (weak ?p0)
    (love-driven-away ?p0)
    (in-asylum ?p0)
    (president ?p0)
    (speaker ?p0)
    (vice-president ?p0)
    (belongs-to ?p0 ?p1)
    (economy-collapsed)
    (real-estate-monopoly)
    (planned-parenthood-defunded)
    (planned-parenthood-shutdown)
    (planned-parenthood-criminalized)
    (prison-population-increased)
    (political-prisoner ?p0)
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

  (:action announce-state-of-the-union
    :parameters (?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?president)
        )
        (president ?president)
      )
    :effect
      (and)
  )

  (:action introduce-president
    :parameters (?speaker ?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
        )
        (and
          (speaker ?speaker)
          (president ?president)
        )
      )
    :effect
      (and)
  )

  (:action attend-state-of-the-union
    :parameters (?vice-president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?vice-president)
          (writing_prompts__wp_075_type_character ?vice-president)
        )
        (vice-president ?vice-president)
      )
    :effect
      (and)
  )
)
