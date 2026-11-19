(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (writing_prompts__wp_013_p_human ?v0 - object)
    (writing_prompts__wp_013_p_crow ?v0 - object)
    (writing_prompts__wp_013_p_in-pain ?v0 - object)
    (writing_prompts__wp_013_p_sunlight-available)
    (writing_prompts__wp_013_p_transformed ?v0 - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (writing_prompts__wp_031_p_alive ?v0 - object)
    (writing_prompts__wp_031_p_on-ship ?v0 - object ?v1 - object)
    (writing_prompts__wp_031_p_moby-dick-spotted ?v0 - object)
    (writing_prompts__wp_031_p_moby-dick-attacking ?v0 - object)
    (writing_prompts__wp_031_p_read-moby-dick ?v0 - object)
    (writing_prompts__wp_031_p_trained-in-whale-killing ?v0 - object)
    (writing_prompts__wp_031_p_battle-stations ?v0 - object)
  )

  (:action writing_prompts__wp_013_a_experience-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (writing_prompts__wp_013_p_human ?character)
      )
    :effect
      (writing_prompts__wp_013_p_in-pain ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_013_a_transform-into-crow
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (and
          (writing_prompts__wp_013_p_human ?character)
          (writing_prompts__wp_013_p_in-pain ?character)
          (writing_prompts__wp_013_p_sunlight-available)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_013_p_human ?character))
        (writing_prompts__wp_013_p_crow ?character)
        (writing_prompts__wp_013_p_transformed ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_013_a_transform-back-into-human
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (writing_prompts__wp_013_p_crow ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_013_p_crow ?character))
        (writing_prompts__wp_013_p_human ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_spot-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_moby-dick-attack
    :parameters (?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_ship ?ship)
        (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
  )

  (:action writing_prompts__wp_031_a_order-battle-stations
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_battle-stations ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_try-kill-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
          (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
          (writing_prompts__wp_031_p_battle-stations ?ship)
        )
      )
    :effect
      (not (writing_prompts__wp_031_p_moby-dick-attacking ?ship))
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_read-moby-dick
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_031_p_read-moby-dick ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_train-in-whale-killing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_read-moby-dick ?character)
      )
    :effect
      (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
    :agents (?character)
  )
)
