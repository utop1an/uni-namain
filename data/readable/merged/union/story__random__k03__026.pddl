(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_045_o_mirror - object)
  (:predicates
    (tiny_stories__story_045_active)
    (tiny_stories__story_045_type_character ?x - object)
    (tiny_stories__story_045_type_object ?x - object)
    (tiny_stories__story_045_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_045_p_shares ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_080_active)
    (tiny_stories__story_080_type_book ?x - object)
    (tiny_stories__story_080_type_bookshelf ?x - object)
    (tiny_stories__story_080_type_character ?x - object)
    (tiny_stories__story_080_type_item ?x - object)
    (tiny_stories__story_080_type_object ?x - object)
    (tiny_stories__story_080_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_080_p_on-shelf ?v0 - object ?v1 - object)
    (tiny_stories__story_080_p_fell-down ?v0 - object)
    (tiny_stories__story_080_p_sneezed ?v0 - object)
    (tiny_stories__story_080_p_scared ?v0 - object)
    (tiny_stories__story_080_p_in-room ?v0 - object)
    (tiny_stories__story_080_p_in-kitchen ?v0 - object)
    (tiny_stories__story_080_p_likes ?v0 - object ?v1 - object)
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
  )

  (:action tiny_stories__story_045_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?character)
        (tiny_stories__story_045_type_object ?object)
        (not (tiny_stories__story_045_p_has ?character ?object))
      )
    :effect
      (tiny_stories__story_045_p_has ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_share
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (and
          (tiny_stories__story_045_p_has ?sharer ?object)
          (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
        )
      )
    :effect
      (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_045_a_unshare
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
      )
    :effect
      (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_080_a_read
    :parameters (?character - object ?book - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_type_book ?book)
        (and
          (tiny_stories__story_080_p_has ?character ?book)
          (not (tiny_stories__story_080_p_fell-down ?book))
        )
      )
    :effect
      (intends ?character (tiny_stories__story_080_p_likes ?character ?book))
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_sneeze
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
      )
    :effect
      (tiny_stories__story_080_p_sneezed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_book-fall
    :parameters (?book - object ?bookshelf - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_book ?book)
        (tiny_stories__story_080_type_bookshelf ?bookshelf)
        (tiny_stories__story_080_p_on-shelf ?book ?bookshelf)
      )
    :effect
      (and
        (tiny_stories__story_080_p_fell-down ?book)
        (not (tiny_stories__story_080_p_on-shelf ?book ?bookshelf))
      )
  )

  (:action tiny_stories__story_080_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_sneezed ?character)
      )
    :effect
      (tiny_stories__story_080_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_move-to-kitchen
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_in-room ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_080_p_in-room ?character))
        (tiny_stories__story_080_p_in-kitchen ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_move-to-room
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_in-kitchen ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_080_p_in-kitchen ?character))
        (tiny_stories__story_080_p_in-room ?character)
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
)
