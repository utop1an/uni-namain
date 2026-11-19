(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (tiny_stories__story_066_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_happy ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (tiny_stories__story_070_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_clean ?v0 - object)
    (tiny_stories__story_070_p_steal-intention ?v0 - object ?v1 - object)
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

  (:action tiny_stories__story_070_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?apologizer)
        (tiny_stories__story_070_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (tiny_stories__story_070_p_friends ?apologizer ?apologized))
        )
      )
    :effect
      (tiny_stories__story_070_p_friends ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_070_a_try-steal
    :parameters (?stealer - object ?item - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?stealer)
        (tiny_stories__story_070_type_item ?item)
        (tiny_stories__story_070_type_character ?owner)
        (and
          (not (= ?stealer ?owner))
          (tiny_stories__story_070_p_has ?owner ?item)
          (tiny_stories__story_070_p_steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_070_p_steal-intention ?stealer ?item))
        (not (tiny_stories__story_070_p_friends ?stealer ?owner))
        (tiny_stories__story_070_p_has ?stealer ?item)
        (not (tiny_stories__story_070_p_has ?owner ?item))
      )
    :agents (?stealer)
  )

  (:action tiny_stories__story_070_a_clean-item
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?cleaner)
        (tiny_stories__story_070_type_item ?item)
        (and
          (not (tiny_stories__story_070_p_clean ?item))
          (tiny_stories__story_070_p_has ?cleaner ?item)
        )
      )
    :effect
      (tiny_stories__story_070_p_clean ?item)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_070_a_drop-in-puddle
    :parameters (?dropper - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?dropper)
        (tiny_stories__story_070_type_item ?item)
        (and
          (tiny_stories__story_070_p_has ?dropper ?item)
          (tiny_stories__story_070_p_clean ?item)
        )
      )
    :effect
      (not (tiny_stories__story_070_p_clean ?item))
    :agents (?dropper)
  )
)
