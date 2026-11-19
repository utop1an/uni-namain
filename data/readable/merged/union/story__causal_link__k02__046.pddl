(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_048_active)
    (tiny_stories__story_048_type_character ?x - object)
    (tiny_stories__story_048_type_object ?x - object)
    (tiny_stories__story_048_type_place ?x - object)
    (tiny_stories__story_048_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_048_p_dry ?v0 - object)
    (tiny_stories__story_048_p_wet ?v0 - object)
    (tiny_stories__story_048_p_happy ?v0 - object)
    (tiny_stories__story_048_p_sad ?v0 - object)
    (tiny_stories__story_048_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_happy ?v0 - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
  )

  (:action tiny_stories__story_048_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?from)
        (tiny_stories__story_048_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_048_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_at ?character ?from))
        (tiny_stories__story_048_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_play
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_dry ?place)
        )
      )
    :effect
      (tiny_stories__story_048_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_dry-place
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_wet ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_wet ?place))
        (tiny_stories__story_048_p_dry ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character1)
        (tiny_stories__story_048_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_048_p_happy ?character1)
          (tiny_stories__story_048_p_happy ?character2)
        )
      )
    :effect
      (tiny_stories__story_048_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_060_p_at ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (tiny_stories__story_060_p_happy ?character)
    :agents (?character)
  )
)
