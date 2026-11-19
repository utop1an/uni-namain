(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_015_active)
    (tiny_stories__story_015_type_character ?x - object)
    (tiny_stories__story_015_type_dog ?x - object)
    (tiny_stories__story_015_type_object ?x - object)
    (tiny_stories__story_015_p_friend ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_practices ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_participates ?v0 - object)
    (tiny_stories__story_015_p_wins ?v0 - object)
    (tiny_stories__story_015_p_plays-with-toy-stack ?v0 - object)
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
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_alive ?v0 - object)
    (writing_prompts__wp_060_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_015_a_practice-running
    :parameters (?helper - object ?runner - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?helper)
        (tiny_stories__story_015_type_dog ?runner)
        (and
          (tiny_stories__story_015_p_friend ?helper ?runner)
          (not (tiny_stories__story_015_p_practices ?helper ?runner))
        )
      )
    :effect
      (tiny_stories__story_015_p_practices ?helper ?runner)
    :agents (?helper ?runner)
  )

  (:action tiny_stories__story_015_a_participate-in-race
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_participates ?dog))
      )
    :effect
      (tiny_stories__story_015_p_participates ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_win-race
    :parameters (?dog - object ?helper - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (tiny_stories__story_015_type_dog ?helper)
        (and
          (tiny_stories__story_015_p_participates ?dog)
          (tiny_stories__story_015_p_practices ?dog ?helper)
        )
      )
    :effect
      (tiny_stories__story_015_p_wins ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_play-with-toy-stack
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_plays-with-toy-stack ?dog))
      )
    :effect
      (tiny_stories__story_015_p_plays-with-toy-stack ?dog)
    :agents (?dog)
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

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (writing_prompts__wp_060_p_alive ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (not (writing_prompts__wp_060_p_clean ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_clean ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?door)
        (and
          (writing_prompts__wp_060_p_alive ?character)
          (not (writing_prompts__wp_060_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_060_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_adjust-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (writing_prompts__wp_060_p_alive ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (not (writing_prompts__wp_060_p_fits ?item ?character))
        )
      )
    :effect
      (writing_prompts__wp_060_p_fits ?item ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_wear-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (writing_prompts__wp_060_p_alive ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )
)
