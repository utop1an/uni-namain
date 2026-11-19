(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_001_o_tv - object)
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
    (writing_prompts__wp_001_active)
    (writing_prompts__wp_001_type_character ?x - object)
    (writing_prompts__wp_001_type_item ?x - object)
    (writing_prompts__wp_001_type_object ?x - object)
    (writing_prompts__wp_001_type_place ?x - object)
    (writing_prompts__wp_001_type_weapon ?x - object)
    (writing_prompts__wp_001_p_alive ?v0 - object)
    (writing_prompts__wp_001_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_001_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_001_p_on ?v0 - object)
    (writing_prompts__wp_001_p_broadcasting ?v0 - object)
    (writing_prompts__wp_001_p_generator-active ?v0 - object)
  )
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)) (writing_prompts__wp_001_p_generator-active ?place))) :implies (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv))
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv) (not (writing_prompts__wp_001_p_generator-active ?place)))) :implies (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)))

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

  (:action writing_prompts__wp_001_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?from)
        (writing_prompts__wp_001_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_001_p_at ?character ?from))
        (writing_prompts__wp_001_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-on
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_has ?character ?item)
          (not (writing_prompts__wp_001_p_on ?item))
        )
      )
    :effect
      (writing_prompts__wp_001_p_on ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-off
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_has ?character ?item)
          (writing_prompts__wp_001_p_on ?item)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_on ?item))
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_start-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?place)
          (not (writing_prompts__wp_001_p_generator-active ?place))
        )
      )
    :effect
      (writing_prompts__wp_001_p_generator-active ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_stop-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?place)
          (writing_prompts__wp_001_p_generator-active ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_generator-active ?place))
    :agents (?character)
  )
)
