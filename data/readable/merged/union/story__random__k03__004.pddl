(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_awake ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (tiny_stories__story_038_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_038_p_hiding ?v0 - object)
    (tiny_stories__story_038_p_seeking ?v0 - object)
    (tiny_stories__story_038_p_found ?v0 - object ?v1 - object)
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_009_p_alive ?v0 - object)
    (writing_prompts__wp_009_p_spirits-present ?v0 - object)
    (writing_prompts__wp_009_p_spirits-gone ?v0 - object)
    (writing_prompts__wp_009_p_weak ?v0 - object)
    (writing_prompts__wp_009_p_love-driven-away ?v0 - object)
    (writing_prompts__wp_009_p_in-asylum ?v0 - object)
  )

  (:action tiny_stories__story_011_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (not (tiny_stories__story_011_p_at ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_011_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sleep
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (tiny_stories__story_011_p_at ?character ?place)
          (tiny_stories__story_011_p_interesting ?place)
        )
      )
    :effect
      (not (tiny_stories__story_011_p_awake ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (not (tiny_stories__story_011_p_awake ?character))
      )
    :effect
      (tiny_stories__story_011_p_awake ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_awake ?character)
      )
    :effect
      (tiny_stories__story_011_p_singing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_stop-singing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_singing ?character)
      )
    :effect
      (not (tiny_stories__story_011_p_singing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character1)
        (tiny_stories__story_011_type_character ?character2)
        (and
          (tiny_stories__story_011_p_awake ?character1)
          (tiny_stories__story_011_p_awake ?character2)
          (not (tiny_stories__story_011_p_friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_011_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_038_a_start-hiding
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_hiding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_start-seeking
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_seeking ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_find
    :parameters (?seeker - object ?hider - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?seeker)
        (tiny_stories__story_038_type_character ?hider)
        (tiny_stories__story_038_type_place ?place)
        (and
          (tiny_stories__story_038_p_seeking ?seeker)
          (tiny_stories__story_038_p_hiding ?hider)
          (tiny_stories__story_038_p_at ?seeker ?place)
          (tiny_stories__story_038_p_at ?hider ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_038_p_found ?seeker ?hider)
        (not (tiny_stories__story_038_p_hiding ?hider))
      )
    :agents (?seeker)
  )

  (:action tiny_stories__story_038_a_stop-seeking
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_p_seeking ?character)
      )
    :effect
      (not (tiny_stories__story_038_p_seeking ?character))
    :agents (?character)
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
)
