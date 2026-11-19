(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (human ?p0)
    (crow ?p0)
    (in-pain ?p0)
    (sunlight-available)
    (transformed ?p0)
    (alive ?p0)
    (on-ship ?p0 ?p1)
    (moby-dick-spotted ?p0)
    (moby-dick-attacking ?p0)
    (read-moby-dick ?p0)
    (trained-in-whale-killing ?p0)
    (battle-stations ?p0)
  )

  (:action experience-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (human ?character)
      )
    :effect
      (in-pain ?character)
  )

  (:action transform-into-crow
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (and
          (human ?character)
          (in-pain ?character)
          (sunlight-available)
        )
      )
    :effect
      (and
        (not (human ?character))
        (crow ?character)
        (transformed ?character)
      )
  )

  (:action transform-back-into-human
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (crow ?character)
      )
    :effect
      (and
        (not (crow ?character))
        (human ?character)
      )
  )

  (:action spot-moby-dick
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
        )
      )
    :effect
      (moby-dick-spotted ?ship)
  )

  (:action moby-dick-attack
    :parameters (?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (moby-dick-spotted ?ship)
      )
    :effect
      (moby-dick-attacking ?ship)
  )

  (:action order-battle-stations
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
          (moby-dick-spotted ?ship)
        )
      )
    :effect
      (battle-stations ?ship)
  )

  (:action try-kill-moby-dick
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
          (trained-in-whale-killing ?character)
          (moby-dick-attacking ?ship)
          (battle-stations ?ship)
        )
      )
    :effect
      (not (moby-dick-attacking ?ship))
  )

  (:action read-moby-dick
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (read-moby-dick ?character)
  )

  (:action train-in-whale-killing
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_character ?character)
        )
        (read-moby-dick ?character)
      )
    :effect
      (trained-in-whale-killing ?character)
  )
)
