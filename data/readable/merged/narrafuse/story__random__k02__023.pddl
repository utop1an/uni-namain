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
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (writing_prompts__wp_032_p_alive ?v0 - object)
    (writing_prompts__wp_032_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_wolves-attack ?v0 - object)
    (writing_prompts__wp_032_p_wolves-killed ?v0 - object)
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

  (:action writing_prompts__wp_032_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?from)
        (writing_prompts__wp_032_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_032_p_alive ?character)
          (writing_prompts__wp_032_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_032_p_at ?character ?from))
        (writing_prompts__wp_032_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_kill-wolves
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?place)
        (and
          (writing_prompts__wp_032_p_alive ?character)
          (writing_prompts__wp_032_p_at ?character ?place)
          (writing_prompts__wp_032_p_wolves-attack ?place)
        )
      )
    :effect
      (writing_prompts__wp_032_p_wolves-killed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_p_alive ?character)
      )
    :effect
      (not (writing_prompts__wp_032_p_alive ?character))
    :agents (?character)
  )
)
