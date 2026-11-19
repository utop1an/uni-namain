(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (tiny_stories__story_089_p_playing ?v0 - object)
    (tiny_stories__story_089_p_tired ?v0 - object)
    (tiny_stories__story_089_p_sleeping ?v0 - object)
    (tiny_stories__story_089_p_awake ?v0 - object)
    (tiny_stories__story_089_p_has-energy ?v0 - object)
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (writing_prompts__wp_017_p_awake ?v0 - object)
    (writing_prompts__wp_017_p_wearing-pajamas ?v0 - object)
    (writing_prompts__wp_017_p_on-floor ?v0 - object)
    (writing_prompts__wp_017_p_dressed ?v0 - object)
    (writing_prompts__wp_017_p_holding ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_walking ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_petting ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_bites ?v0 - object)
    (writing_prompts__wp_017_p_owns ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_life-is-a-joke ?v0 - object)
  )

  (:action tiny_stories__story_089_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_awake ?character)
          (not (tiny_stories__story_089_p_playing ?character))
          (tiny_stories__story_089_p_has-energy ?character)
        )
      )
    :effect
      (tiny_stories__story_089_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_playing ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_playing ?character))
        (tiny_stories__story_089_p_tired ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_tired ?character)
          (not (tiny_stories__story_089_p_sleeping ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_awake ?character))
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :effect
      (and
        (tiny_stories__story_089_p_awake ?character)
        (not (tiny_stories__story_089_p_sleeping ?character))
        (not (tiny_stories__story_089_p_tired ?character))
        (tiny_stories__story_089_p_has-energy ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (not (writing_prompts__wp_017_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_017_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_dress
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (and
          (writing_prompts__wp_017_p_awake ?character)
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
          (writing_prompts__wp_017_p_awake ?character)
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
        (writing_prompts__wp_017_p_awake ?character)
      )
    :effect
      (writing_prompts__wp_017_p_life-is-a-joke ?character)
    :agents (?character)
  )
)
