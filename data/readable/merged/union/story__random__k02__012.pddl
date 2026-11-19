(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (writing_prompts__wp_007_active)
    (writing_prompts__wp_007_type_item ?x - object)
    (writing_prompts__wp_007_type_object ?x - object)
    (writing_prompts__wp_007_type_room ?x - object)
    (writing_prompts__wp_007_p_in ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_occupied ?v0 - object)
    (writing_prompts__wp_007_p_plugged-in ?v0 - object)
    (writing_prompts__wp_007_p_connected ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_well-lit ?v0 - object)
    (writing_prompts__wp_007_p_morning)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (tiny_stories__story_034_p_has ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_has ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_007_a_move-item
    :parameters (?item - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_type_room ?from)
        (writing_prompts__wp_007_type_room ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_007_p_in ?item ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_007_p_in ?item ?from))
        (writing_prompts__wp_007_p_in ?item ?to)
      )
  )

  (:action writing_prompts__wp_007_a_plug-in
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_plugged-in ?item))
      )
    :effect
      (writing_prompts__wp_007_p_plugged-in ?item)
  )

  (:action writing_prompts__wp_007_a_connect
    :parameters (?item1 - object ?item2 - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item1)
        (writing_prompts__wp_007_type_item ?item2)
        (and
          (not (writing_prompts__wp_007_p_connected ?item1 ?item2))
          (not (= ?item1 ?item2))
        )
      )
    :effect
      (writing_prompts__wp_007_p_connected ?item1 ?item2)
  )

  (:action writing_prompts__wp_007_a_morning-comes
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (not (writing_prompts__wp_007_p_well-lit ?room))
          (writing_prompts__wp_007_p_morning)
        )
      )
    :effect
      (writing_prompts__wp_007_p_well-lit ?room)
  )

  (:action writing_prompts__wp_007_a_night-falls
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (writing_prompts__wp_007_p_well-lit ?room)
          (not (writing_prompts__wp_007_p_morning))
        )
      )
    :effect
      (not (writing_prompts__wp_007_p_well-lit ?room))
  )

  (:action writing_prompts__wp_007_a_occupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_occupied ?item))
      )
    :effect
      (writing_prompts__wp_007_p_occupied ?item)
  )

  (:action writing_prompts__wp_007_a_unoccupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_p_occupied ?item)
      )
    :effect
      (not (writing_prompts__wp_007_p_occupied ?item))
  )
)
