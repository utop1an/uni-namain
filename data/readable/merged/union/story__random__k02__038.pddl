(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_awake ?v0 - object)
    (writing_prompts__wp_029_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_alive ?v0 - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
  )

  (:action writing_prompts__wp_029_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_awake ?character))
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_asleep ?character))
        (writing_prompts__wp_029_p_awake ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_install-soundproof-door
    :parameters (?gang - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_type_place ?place)
        (and
          (writing_prompts__wp_029_p_awake ?gang)
          (writing_prompts__wp_029_p_at ?gang ?place)
          (not (writing_prompts__wp_029_p_soundproof-door ?place))
        )
      )
    :effect
      (writing_prompts__wp_029_p_soundproof-door ?place)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_rob
    :parameters (?gang - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_p_awake ?gang)
      )
    :effect
      (writing_prompts__wp_029_p_robbed ?gang)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_attack
    :parameters (?attacker - object ?victim - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?attacker)
        (writing_prompts__wp_029_type_character ?victim)
        (and
          (writing_prompts__wp_029_p_awake ?attacker)
          (writing_prompts__wp_029_p_awake ?victim)
        )
      )
    :effect
      (writing_prompts__wp_029_p_attacked ?victim)
    :agents (?attacker)
  )

  (:action writing_prompts__wp_029_a_clear-passage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_attacked ?character))
        (writing_prompts__wp_029_p_has-hoard ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_create-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (writing_prompts__wp_036_p_alive ?character)
      )
    :effect
      (and
        (writing_prompts__wp_036_p_created ?character ?lightbox)
        (writing_prompts__wp_036_p_has ?character ?lightbox)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_anchor-light
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_anchored ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_charge-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_anchored ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_charged ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_use-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_charged ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (and
        (writing_prompts__wp_036_p_used ?character ?lightbox)
        (not (writing_prompts__wp_036_p_charged ?lightbox))
      )
    :agents (?character)
  )
)
