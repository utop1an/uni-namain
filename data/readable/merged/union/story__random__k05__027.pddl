(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_029_active)
    (tiny_stories__story_029_type_character ?x - object)
    (tiny_stories__story_029_type_item ?x - object)
    (tiny_stories__story_029_type_object ?x - object)
    (tiny_stories__story_029_type_place ?x - object)
    (tiny_stories__story_029_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_alive ?v0 - object)
    (tiny_stories__story_029_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_near ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_in-nest ?v0 - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_happy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (writing_prompts__wp_013_p_human ?v0 - object)
    (writing_prompts__wp_013_p_crow ?v0 - object)
    (writing_prompts__wp_013_p_in-pain ?v0 - object)
    (writing_prompts__wp_013_p_sunlight-available)
    (writing_prompts__wp_013_p_transformed ?v0 - object)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_alive ?v0 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_029_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_place ?from)
        (tiny_stories__story_029_type_place ?to)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_at ?character ?from)
          (not (tiny_stories__story_029_p_at ?character ?to))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_029_p_at ?character ?from))
        (tiny_stories__story_029_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_has ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_pick-up
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_near ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_029_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_help-bird
    :parameters (?character - object ?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_alive ?bird)
          (not (tiny_stories__story_029_p_in-nest ?bird))
        )
      )
    :effect
      (tiny_stories__story_029_p_in-nest ?bird)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_bird-falls
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?bird)
          (tiny_stories__story_029_p_in-nest ?bird)
        )
      )
    :effect
      (not (tiny_stories__story_029_p_in-nest ?bird))
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (tiny_stories__story_095_p_at ?character ?place))
      )
    :effect
      (tiny_stories__story_095_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_start-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_bored ?character)
          (not (tiny_stories__story_100_p_rolling ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_bored ?character))
        (tiny_stories__story_100_p_rolling ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_stop-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_rolling ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_rolling ?character))
        (tiny_stories__story_100_p_dizzy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_lie-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_dizzy ?character)
          (not (tiny_stories__story_100_p_lying-down ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_dizzy ?character))
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_get-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_lying-down ?character))
        (tiny_stories__story_100_p_happy ?character)
      )
    :agents (?character)
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

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (not (writing_prompts__wp_063_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_063_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_call-police
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_063_p_called-police ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_follow-officer
    :parameters (?character - object ?officer - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_character ?officer)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_alive ?officer)
        )
      )
    :effect
      (writing_prompts__wp_063_p_follows ?character ?officer)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_avert-death
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_called-police ?character)
          (exists
            (?officer - object)
            (and
              (writing_prompts__wp_063_type_character ?officer)
              (writing_prompts__wp_063_p_follows ?character ?officer)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_063_p_death-averted ?character)
    :agents (?character)
  )
)
