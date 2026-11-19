(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_003_p_broken-pedal ?v0 - object)
    (tiny_stories__story_003_p_fixed-pedal ?v0 - object)
    (tiny_stories__story_003_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_003_p_at-shop ?v0 - object)
    (tiny_stories__story_003_p_happy ?v0 - object)
    (tiny_stories__story_003_p_flying ?v0 - object)
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_014_p_at-park ?v0 - object)
    (tiny_stories__story_014_p_on-swing ?v0 - object)
    (tiny_stories__story_014_p_swinging ?v0 - object)
    (tiny_stories__story_014_p_sharing ?v0 - object ?v1 - object)
    (tiny_stories__story_014_p_happy ?v0 - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_happy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
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

  (:action tiny_stories__story_003_a_go-to-shop
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_at-shop ?character))
      )
    :effect
      (tiny_stories__story_003_p_at-shop ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_fix-pedal
    :parameters (?character - object ?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_at-shop ?character)
          (tiny_stories__story_003_p_has ?character ?bike)
          (tiny_stories__story_003_p_broken-pedal ?bike)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_003_p_broken-pedal ?bike))
        (tiny_stories__story_003_p_fixed-pedal ?bike)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_happy ?character))
      )
    :effect
      (tiny_stories__story_003_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_start-flying
    :parameters (?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_fixed-pedal ?bike)
          (not (tiny_stories__story_003_p_flying ?bike))
        )
      )
    :effect
      (tiny_stories__story_003_p_flying ?bike)
  )

  (:action tiny_stories__story_014_a_go-to-park
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (not (tiny_stories__story_014_p_at-park ?character))
      )
    :effect
      (tiny_stories__story_014_p_at-park ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_get-on-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_at-park ?character)
          (not (tiny_stories__story_014_p_on-swing ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_on-swing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_start-swinging
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (not (tiny_stories__story_014_p_swinging ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_swinging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_share-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_swinging ?character1)
          (tiny_stories__story_014_p_swinging ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_sharing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_014_a_get-off-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (tiny_stories__story_014_p_swinging ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_014_p_on-swing ?character))
        (not (tiny_stories__story_014_p_swinging ?character))
        (tiny_stories__story_014_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_thank
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_sharing ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_happy ?character1)
    :agents (?character1 ?character2)
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
