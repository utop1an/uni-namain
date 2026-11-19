(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_073_active)
    (tiny_stories__story_073_type_character ?x - object)
    (tiny_stories__story_073_type_object ?x - object)
    (tiny_stories__story_073_p_play-chess ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_feel-better ?v0 - object)
    (tiny_stories__story_073_p_sit-together ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_sick ?v0 - object)
    (tiny_stories__story_073_p_happy ?v0 - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (writing_prompts__wp_045_p_in-box ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_nervous ?v0 - object)
    (writing_prompts__wp_045_p_composed ?v0 - object)
    (writing_prompts__wp_045_p_noticed ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_opened ?v0 - object)
  )

  (:action tiny_stories__story_073_a_play-chess
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (and
          (not (tiny_stories__story_073_p_sick ?character1))
          (not (tiny_stories__story_073_p_sick ?character2))
          (not (= ?character1 ?character2))
          (tiny_stories__story_073_p_sit-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_073_p_play-chess ?character1 ?character2)
        (tiny_stories__story_073_p_happy ?character1)
        (tiny_stories__story_073_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_073_a_get-sick
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
      )
    :effect
      (tiny_stories__story_073_p_sick ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_feel-better
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
        (tiny_stories__story_073_p_sick ?character)
      )
    :effect
      (not (tiny_stories__story_073_p_sick ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_sit-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_073_p_sit-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_045_a_enter
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_place ?place)
        (not (writing_prompts__wp_045_p_at ?character ?place))
      )
    :effect
      (writing_prompts__wp_045_p_at ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_notice
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (writing_prompts__wp_045_p_at ?character ?place)
          (writing_prompts__wp_045_p_at ?box ?place)
        )
      )
    :effect
      (writing_prompts__wp_045_p_noticed ?character ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_open-box
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (writing_prompts__wp_045_p_at ?character ?place)
          (writing_prompts__wp_045_p_at ?box ?place)
          (writing_prompts__wp_045_p_noticed ?character ?box)
          (not (writing_prompts__wp_045_p_opened ?box))
        )
      )
    :effect
      (writing_prompts__wp_045_p_opened ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-nervous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_nervous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-composed
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_composed ?character)
    :agents (?character)
  )
)
