(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_001_o_outside - object)
  (:predicates
    (tiny_stories__story_001_active)
    (tiny_stories__story_001_type_character ?x - object)
    (tiny_stories__story_001_type_object ?x - object)
    (tiny_stories__story_001_type_place ?x - object)
    (tiny_stories__story_001_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_001_p_raining)
    (tiny_stories__story_001_p_sunny)
    (tiny_stories__story_001_p_muddy ?v0 - object)
    (tiny_stories__story_001_p_playing ?v0 - object)
    (tiny_stories__story_001_p_scared ?v0 - object)
    (tiny_stories__story_001_p_brave ?v0 - object)
    (tiny_stories__story_001_p_safe ?v0 - object)
    (tiny_stories__story_001_p_inside ?v0 - object)
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (tiny_stories__story_066_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_happy ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
  )

  (:action tiny_stories__story_001_a_go-outside
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_inside ?character)
          (tiny_stories__story_001_p_sunny)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_inside ?character))
        (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_go-inside
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside))
        (tiny_stories__story_001_p_inside ?character)
        (tiny_stories__story_001_p_safe ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_play-in-mud
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (tiny_stories__story_001_type_place ?place)
        (and
          (tiny_stories__story_001_p_at ?character ?place)
          (tiny_stories__story_001_p_muddy ?place)
        )
      )
    :effect
      (tiny_stories__story_001_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_become-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
          (not (tiny_stories__story_001_p_scared ?character))
        )
      )
    :effect
      (tiny_stories__story_001_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_become-brave
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
          (tiny_stories__story_001_p_scared ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_scared ?character))
        (tiny_stories__story_001_p_brave ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_stop-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_p_raining)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_raining))
        (tiny_stories__story_001_p_sunny)
      )
  )

  (:action tiny_stories__story_001_a_start-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_p_sunny)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_sunny))
        (tiny_stories__story_001_p_raining)
      )
  )

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (tiny_stories__story_066_p_at ?character ?place)
          (not (tiny_stories__story_066_p_has ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_066_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (tiny_stories__story_066_p_at ?giver ?place)
          (tiny_stories__story_066_p_has ?giver ?item)
          (tiny_stories__story_066_p_at ?receiver ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_066_p_has ?giver ?item))
        (tiny_stories__story_066_p_has ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (tiny_stories__story_066_p_at ?character ?place)
          (tiny_stories__story_066_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (tiny_stories__story_066_p_happy ?target))
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?target)
    :agents (?character)
  )
)
