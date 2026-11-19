(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_030_active)
    (writing_prompts__wp_030_type_object ?x - object)
    (writing_prompts__wp_030_type_planet ?x - object)
    (writing_prompts__wp_030_type_society ?x - object)
    (writing_prompts__wp_030_type_technology ?x - object)
    (writing_prompts__wp_030_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_030_p_has-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_030_p_in-habitable-zone ?v0 - object)
    (writing_prompts__wp_030_p_in-high-wind-zone ?v0 - object)
    (writing_prompts__wp_030_p_in-low-wind-zone ?v0 - object)
    (writing_prompts__wp_030_p_explored ?v0 - object ?v1 - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (writing_prompts__wp_091_p_feels-awful ?v0 - object)
    (writing_prompts__wp_091_p_thinks-about-breakup ?v0 - object)
    (writing_prompts__wp_091_p_heartbroken ?v0 - object)
    (writing_prompts__wp_091_p_forgiven ?v0 - object)
    (writing_prompts__wp_091_p_learned ?v0 - object)
    (writing_prompts__wp_091_p_moved-on ?v0 - object)
  )

  (:action writing_prompts__wp_030_a_develop-technology
    :parameters (?society - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_technology ?technology)
      )
    :effect
      (writing_prompts__wp_030_p_has-technology ?society ?technology)
    :agents (?society)
  )

  (:action writing_prompts__wp_030_a_explore
    :parameters (?society - object ?planet - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_planet ?planet)
        (writing_prompts__wp_030_type_technology ?technology)
        (and
          (writing_prompts__wp_030_p_at ?society ?planet)
          (writing_prompts__wp_030_p_has-technology ?society ?technology)
          (or
            (writing_prompts__wp_030_p_in-habitable-zone ?planet)
            (writing_prompts__wp_030_p_in-high-wind-zone ?planet)
            (writing_prompts__wp_030_p_in-low-wind-zone ?planet)
          )
        )
      )
    :effect
      (writing_prompts__wp_030_p_explored ?society ?planet)
    :agents (?society)
  )

  (:action writing_prompts__wp_030_a_move
    :parameters (?society - object ?from - object ?to - object ?technology - object)
    :precondition
      (and
        (writing_prompts__wp_030_active)
        (writing_prompts__wp_030_type_society ?society)
        (writing_prompts__wp_030_type_planet ?from)
        (writing_prompts__wp_030_type_planet ?to)
        (writing_prompts__wp_030_type_technology ?technology)
        (and
          (writing_prompts__wp_030_p_at ?society ?from)
          (writing_prompts__wp_030_p_has-technology ?society ?technology)
          (or
            (writing_prompts__wp_030_p_in-habitable-zone ?to)
            (writing_prompts__wp_030_p_in-high-wind-zone ?to)
            (writing_prompts__wp_030_p_in-low-wind-zone ?to)
          )
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_030_p_at ?society ?from))
        (writing_prompts__wp_030_p_at ?society ?to)
      )
    :agents (?society)
  )

  (:action writing_prompts__wp_091_a_forgive
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_feels-awful ?character)
          (not (writing_prompts__wp_091_p_forgiven ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_forgiven ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_learn
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_heartbroken ?character)
          (not (writing_prompts__wp_091_p_learned ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_learned ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_move-on
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_thinks-about-breakup ?character)
          (writing_prompts__wp_091_p_forgiven ?character)
          (writing_prompts__wp_091_p_learned ?character)
          (not (writing_prompts__wp_091_p_moved-on ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_moved-on ?character)
    :agents (?character)
  )
)
