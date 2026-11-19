(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (asleep ?p0)
    (has-hoard ?p0)
    (robbed ?p0)
    (soundproof-door ?p0)
    (attacked ?p0)
    (awake ?p0)
    (at ?p0 ?p1)
    (wearing-clothes ?p0)
    (has-device ?p0 ?p1)
    (device-on ?p0)
    (device-connected ?p0)
    (electricity ?p0)
    (working ?p0)
    (school-canceled)
  )
  (:constants writing_prompts__wp_085_o_outside - object)

  (:action sleep
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (awake ?character))
        (asleep ?character)
      )
  )

  (:action rob
    :parameters (?gang)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_character ?gang)
        )
        (awake ?gang)
      )
    :effect
      (robbed ?gang)
  )

  (:action install-soundproof-door
    :parameters (?gang ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
        )
        (and
          (awake ?gang)
          (at ?gang ?place)
          (not (soundproof-door ?place))
        )
      )
    :effect
      (soundproof-door ?place)
  )

  (:action attack
    :parameters (?attacker ?victim)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
        )
        (and
          (awake ?attacker)
          (awake ?victim)
        )
      )
    :effect
      (attacked ?victim)
  )

  (:action clear-passage
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (attacked ?character))
        (has-hoard ?character)
      )
  )

  (:action cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (school-canceled))
      )
    :effect
      (school-canceled)
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_029_active)
            (writing_prompts__wp_029_type_character ?character)
            (writing_prompts__wp_029_type_character ?character)
          )
          (and
            (writing_prompts__wp_085_active)
            (writing_prompts__wp_085_type_character ?character)
            (writing_prompts__wp_085_type_character ?character)
          )
        )
        (and
          (asleep ?character)
          (not (awake ?character))
        )
      )
    :effect
      (and
        (not (asleep ?character))
        (awake ?character)
      )
  )

  (:action put-on-clothes
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_085_active)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_character ?character)
        )
        (and
          (awake ?character)
          (not (wearing-clothes ?character))
        )
      )
    :effect
      (wearing-clothes ?character)
  )

  (:action turn-on-device
    :parameters (?character ?device)
    :precondition
      (and
        (and
          (writing_prompts__wp_085_active)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_device ?device)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_device ?device)
        )
        (and
          (awake ?character)
          (has-device ?character ?device)
          (not (device-on ?device))
        )
      )
    :effect
      (device-on ?device)
  )

  (:action check-connectivity
    :parameters (?character ?device)
    :precondition
      (and
        (and
          (writing_prompts__wp_085_active)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_device ?device)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_device ?device)
        )
        (and
          (awake ?character)
          (device-on ?device)
          (has-device ?character ?device)
        )
      )
    :effect
      (when
        (device-connected ?device)
        (working ?device)
      )
  )

  (:action go-outside
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_085_active)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_place ?place)
          (writing_prompts__wp_085_type_character ?character)
          (writing_prompts__wp_085_type_place ?place)
        )
        (and
          (awake ?character)
          (wearing-clothes ?character)
          (at ?character ?place)
        )
      )
    :effect
      (and
        (not (at ?character ?place))
        (at ?character writing_prompts__wp_085_o_outside)
      )
  )

  (:action talk
    :parameters (?speaker ?listener)
    :precondition
      (and
        (and
          (writing_prompts__wp_085_active)
          (writing_prompts__wp_085_type_character ?speaker)
          (writing_prompts__wp_085_type_character ?listener)
          (writing_prompts__wp_085_type_character ?speaker)
          (writing_prompts__wp_085_type_character ?listener)
        )
        (and
          (awake ?speaker)
          (awake ?listener)
          (at ?speaker writing_prompts__wp_085_o_outside)
          (at ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :effect
      (and)
  )
)
