(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (tiny_stories__story_094_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_094_p_happy ?v0 - object)
    (tiny_stories__story_094_p_sad ?v0 - object)
    (tiny_stories__story_094_p_at ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_has ?character ?dress)
          (not (tiny_stories__story_075_p_wearing ?character ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_wearing ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_wearing ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (tiny_stories__story_075_p_wearing ?character ?old-dress)
          (not (tiny_stories__story_075_p_has ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (tiny_stories__story_075_p_has ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_receive-gift
    :parameters (?receiver - object ?giver - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?receiver)
        (tiny_stories__story_094_type_character ?giver)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?receiver ?giver))
          (tiny_stories__story_094_p_happy ?giver)
          (not (tiny_stories__story_094_p_has ?receiver ?item))
          (tiny_stories__story_094_p_has ?giver ?item)
        )
      )
    :effect
      (and
        (tiny_stories__story_094_p_has ?receiver ?item)
        (tiny_stories__story_094_p_happy ?receiver)
      )
    :agents (?receiver ?giver)
  )

  (:action tiny_stories__story_094_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (not (tiny_stories__story_094_p_sad ?character))
        )
      )
    :effect
      (tiny_stories__story_094_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_take-toy
    :parameters (?taker - object ?victim - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?taker)
        (tiny_stories__story_094_type_character ?victim)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?taker ?victim))
          (tiny_stories__story_094_p_has ?victim ?item)
          (not (tiny_stories__story_094_p_has ?taker ?item))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?victim ?item))
        (tiny_stories__story_094_p_has ?taker ?item)
        (tiny_stories__story_094_p_sad ?victim)
      )
    :agents (?taker)
  )

  (:action tiny_stories__story_094_a_lose-toy
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (tiny_stories__story_094_p_happy ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?character ?item))
        (tiny_stories__story_094_p_sad ?character)
      )
    :agents (?character)
  )
)
