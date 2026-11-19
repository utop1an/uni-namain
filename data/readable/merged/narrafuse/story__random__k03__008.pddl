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
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_009_p_alive ?v0 - object)
    (writing_prompts__wp_009_p_spirits-present ?v0 - object)
    (writing_prompts__wp_009_p_spirits-gone ?v0 - object)
    (writing_prompts__wp_009_p_weak ?v0 - object)
    (writing_prompts__wp_009_p_love-driven-away ?v0 - object)
    (writing_prompts__wp_009_p_in-asylum ?v0 - object)
    (writing_prompts__wp_093_active)
    (writing_prompts__wp_093_type_character ?x - object)
    (writing_prompts__wp_093_type_object ?x - object)
    (writing_prompts__wp_093_type_subreddit ?x - object)
    (writing_prompts__wp_093_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_united ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_truce ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_exists ?v0 - object)
    (writing_prompts__wp_093_p_wall-built)
    (writing_prompts__wp_093_p_filled-with-water)
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

  (:action writing_prompts__wp_009_a_become-weak
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_weak ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_drive-away-love
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_love-driven-away ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_end-up-in-asylum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_in-asylum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_ask-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (and
        (writing_prompts__wp_009_p_spirits-gone ?character)
        (not (writing_prompts__wp_009_p_spirits-present ?character))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_regret-asking-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-gone ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_spirits-present ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_093_a_wear
    :parameters (?character - object ?clothing - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_character ?character)
        (writing_prompts__wp_093_type_object ?clothing)
      )
    :effect
      (writing_prompts__wp_093_p_wearing ?character ?clothing)
    :agents (?character)
  )

  (:action writing_prompts__wp_093_a_unite
    :parameters (?subreddit1 - object ?subreddit2 - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit1)
        (writing_prompts__wp_093_type_subreddit ?subreddit2)
        (not (writing_prompts__wp_093_p_united ?subreddit1 ?subreddit2))
      )
    :effect
      (writing_prompts__wp_093_p_united ?subreddit1 ?subreddit2)
    :agents (?subreddit1 ?subreddit2)
  )

  (:action writing_prompts__wp_093_a_establish-truce
    :parameters (?subreddit1 - object ?subreddit2 - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit1)
        (writing_prompts__wp_093_type_subreddit ?subreddit2)
        (not (writing_prompts__wp_093_p_truce ?subreddit1 ?subreddit2))
      )
    :effect
      (writing_prompts__wp_093_p_truce ?subreddit1 ?subreddit2)
    :agents (?subreddit1 ?subreddit2)
  )

  (:action writing_prompts__wp_093_a_create-subreddit
    :parameters (?subreddit - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit)
      )
    :effect
      (writing_prompts__wp_093_p_exists ?subreddit)
    :agents (?subreddit)
  )

  (:action writing_prompts__wp_093_a_build-wall
    :parameters ()
    :precondition
      (writing_prompts__wp_093_active)
    :effect
      (writing_prompts__wp_093_p_wall-built)
  )

  (:action writing_prompts__wp_093_a_fill-wall-with-water
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_p_wall-built)
      )
    :effect
      (writing_prompts__wp_093_p_filled-with-water)
  )
)
