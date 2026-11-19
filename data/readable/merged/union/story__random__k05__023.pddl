(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
  (:predicates
    (tiny_stories__story_020_active)
    (tiny_stories__story_020_type_character ?x - object)
    (tiny_stories__story_020_type_object ?x - object)
    (tiny_stories__story_020_type_place ?x - object)
    (tiny_stories__story_020_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_020_p_explored ?v0 - object ?v1 - object)
    (tiny_stories__story_020_p_interacted ?v0 - object ?v1 - object)
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_040_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_on-top ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_scared ?v0 - object)
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_050_p_playing-with-toys ?v0 - object)
    (tiny_stories__story_050_p_found-blocks ?v0 - object)
    (tiny_stories__story_050_p_stacking-blocks ?v0 - object)
    (tiny_stories__story_050_p_stack-tall ?v0 - object)
    (tiny_stories__story_050_p_stack-strong ?v0 - object)
    (tiny_stories__story_050_p_happy ?v0 - object)
    (tiny_stories__story_050_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (tiny_stories__story_086_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_086_p_scared ?v0 - object)
    (tiny_stories__story_086_p_spider-on-wall)
    (tiny_stories__story_086_p_happy ?v0 - object)
    (tiny_stories__story_086_p_cake-made)
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_alive ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_alive ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (writing_prompts__wp_048_p_alive ?character))

  (:action tiny_stories__story_020_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_020_active)
        (tiny_stories__story_020_type_character ?character)
        (tiny_stories__story_020_type_place ?from)
        (tiny_stories__story_020_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_020_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_020_p_at ?character ?from))
        (tiny_stories__story_020_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_020_a_interact
    :parameters (?character1 - object ?character2 - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_020_active)
        (tiny_stories__story_020_type_character ?character1)
        (tiny_stories__story_020_type_character ?character2)
        (tiny_stories__story_020_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_020_p_at ?character1 ?place)
          (tiny_stories__story_020_p_at ?character2 ?place)
        )
      )
    :effect
      (tiny_stories__story_020_p_interacted ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_020_a_explore
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_020_active)
        (tiny_stories__story_020_type_character ?character)
        (tiny_stories__story_020_type_place ?place)
        (tiny_stories__story_020_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_020_p_explored ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_place ?from)
        (tiny_stories__story_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_at ?character ?from))
        (tiny_stories__story_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_retrieve-toy
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_toy ?toy)
        (tiny_stories__story_040_type_place ?place)
        (and
          (tiny_stories__story_040_p_at ?character ?place)
          (tiny_stories__story_040_p_on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_on-top ?toy ?place))
        (tiny_stories__story_040_p_has ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character1)
        (tiny_stories__story_040_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_040_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_040_a_overcome-fear
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_040_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_play-with-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
      )
    :effect
      (tiny_stories__story_050_p_playing-with-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_find-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_playing-with-toys ?character)
      )
    :effect
      (tiny_stories__story_050_p_found-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_stack-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_found-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stacking-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_make-stack-tall
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stacking-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stack-tall ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?helper)
        (tiny_stories__story_050_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_050_p_stack-tall ?helpee)
        )
      )
    :effect
      (tiny_stories__story_050_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_050_a_make-stack-strong
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (and
          (tiny_stories__story_050_p_stack-tall ?character)
          (tiny_stories__story_050_p_helping ?character ?character)
        )
      )
    :effect
      (tiny_stories__story_050_p_stack-strong ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stack-strong ?character)
      )
    :effect
      (tiny_stories__story_050_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?helper)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_086_p_scared ?helpee)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_086_p_scared ?helpee))
        (tiny_stories__story_086_p_happy ?helpee)
        (tiny_stories__story_086_p_helping ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_086_a_make-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_cake-made))
          (tiny_stories__story_086_p_happy ?character)
        )
      )
    :effect
      (tiny_stories__story_086_p_cake-made)
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_see-spider
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_scared ?character))
          (not (tiny_stories__story_086_p_spider-on-wall))
        )
      )
    :effect
      (and
        (tiny_stories__story_086_p_scared ?character)
        (tiny_stories__story_086_p_spider-on-wall)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_remove-spider
    :parameters (?character - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (tiny_stories__story_086_p_spider-on-wall)
          (tiny_stories__story_086_p_helping ?character ?helpee)
        )
      )
    :effect
      (not (tiny_stories__story_086_p_spider-on-wall))
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_offer-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (not (writing_prompts__wp_048_p_offered ?character ?trial))
        )
      )
    :effect
      (writing_prompts__wp_048_p_offered ?character ?trial)
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_048_a_choose-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (writing_prompts__wp_048_p_offered ?character ?trial)
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_completed ?character ?trial)
        (not (writing_prompts__wp_048_p_offered ?character ?trial))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_rebirth
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (or
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears)
          )
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_alive ?character)
        (not (writing_prompts__wp_048_p_dead ?character))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears))
      )
    :agents (writing_prompts__wp_048_o_death)
  )
)
