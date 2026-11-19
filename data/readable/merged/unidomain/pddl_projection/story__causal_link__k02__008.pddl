(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (wearing-pajamas ?p0)
    (on-floor ?p0)
    (dressed ?p0)
    (holding ?p0 ?p1)
    (walking ?p0 ?p1)
    (petting ?p0 ?p1)
    (bites ?p0)
    (owns ?p0 ?p1)
    (life-is-a-joke ?p0)
    (awake ?p0)
    (asleep ?p0)
    (at ?p0 ?p1)
    (has-hoard ?p0)
    (robbed ?p0)
    (soundproof-door ?p0)
    (attacked ?p0)
  )

  (:action dress
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_character ?character)
        )
        (and
          (awake ?character)
          (on-floor ?character)
          (not (dressed ?character))
        )
      )
    :effect
      (dressed ?character)
  )

  (:action pet
    :parameters (?character ?animal)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_animal ?animal)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_animal ?animal)
        )
        (and
          (awake ?character)
          (dressed ?character)
          (not (bites ?animal))
        )
      )
    :effect
      (petting ?character ?animal)
  )

  (:action realize-life-is-a-joke
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (life-is-a-joke ?character)
  )

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

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_017_active)
            (writing_prompts__wp_017_type_character ?character)
            (writing_prompts__wp_017_type_character ?character)
          )
          (and
            (writing_prompts__wp_029_active)
            (writing_prompts__wp_029_type_character ?character)
            (writing_prompts__wp_029_type_character ?character)
          )
        )
        (and
          (not (awake ?character))
          (asleep ?character)
        )
      )
    :effect
      (and
        (awake ?character)
        (not (asleep ?character))
      )
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
)
