(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (shared_p_consensus_47116d583e8d77e1 ?v0 - object)
    (writing_prompts__wp_017_p_wearing-pajamas ?v0 - object)
    (writing_prompts__wp_017_p_on-floor ?v0 - object)
    (writing_prompts__wp_017_p_dressed ?v0 - object)
    (writing_prompts__wp_017_p_holding ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_walking ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_petting ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_bites ?v0 - object)
    (writing_prompts__wp_017_p_owns ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_life-is-a-joke ?v0 - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
  )

  (:action writing_prompts__wp_017_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (not (shared_p_consensus_47116d583e8d77e1 ?character))
      )
    :effect
      (shared_p_consensus_47116d583e8d77e1 ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_dress
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (and
          (shared_p_consensus_47116d583e8d77e1 ?character)
          (writing_prompts__wp_017_p_on-floor ?character)
          (not (writing_prompts__wp_017_p_dressed ?character))
        )
      )
    :effect
      (writing_prompts__wp_017_p_dressed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_pet
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (writing_prompts__wp_017_type_animal ?animal)
        (and
          (shared_p_consensus_47116d583e8d77e1 ?character)
          (writing_prompts__wp_017_p_dressed ?character)
          (not (writing_prompts__wp_017_p_bites ?animal))
        )
      )
    :effect
      (writing_prompts__wp_017_p_petting ?character ?animal)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_realize-life-is-a-joke
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (shared_p_consensus_47116d583e8d77e1 ?character)
      )
    :effect
      (writing_prompts__wp_017_p_life-is-a-joke ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (shared_p_consensus_47116d583e8d77e1 ?character)
      )
    :effect
      (and
        (not (shared_p_consensus_47116d583e8d77e1 ?character))
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
        (shared_p_consensus_47116d583e8d77e1 ?character)
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
          (shared_p_consensus_47116d583e8d77e1 ?gang)
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
        (shared_p_consensus_47116d583e8d77e1 ?gang)
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
          (shared_p_consensus_47116d583e8d77e1 ?attacker)
          (shared_p_consensus_47116d583e8d77e1 ?victim)
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
        (shared_p_consensus_47116d583e8d77e1 ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_attacked ?character))
        (writing_prompts__wp_029_p_has-hoard ?character)
      )
    :agents (?character)
  )
)
