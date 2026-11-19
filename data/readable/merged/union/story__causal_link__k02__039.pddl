(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_033_active)
    (tiny_stories__story_033_type_character ?x - object)
    (tiny_stories__story_033_type_object ?x - object)
    (tiny_stories__story_033_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_happy ?v0 - object)
    (tiny_stories__story_033_p_sad ?v0 - object)
    (tiny_stories__story_033_p_offered-snack ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_snack-is-lie ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_trusts ?v0 - object ?v1 - object)
    (tiny_stories__story_033_p_compassionate ?v0 - object)
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

  (:action tiny_stories__story_033_a_go-to-place
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?character1)
        (tiny_stories__story_033_type_character ?character2)
        (and
          (not (tiny_stories__story_033_p_at ?character1 ?character2))
          (tiny_stories__story_033_p_happy ?character1)
        )
      )
    :effect
      (and
        (tiny_stories__story_033_p_at ?character1 ?character2)
        (not (tiny_stories__story_033_p_happy ?character1))
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_033_a_offer-snack
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?giver)
        (tiny_stories__story_033_type_character ?receiver)
        (and
          (tiny_stories__story_033_p_at ?receiver ?giver)
          (tiny_stories__story_033_p_compassionate ?giver)
        )
      )
    :effect
      (tiny_stories__story_033_p_offered-snack ?giver ?receiver)
    :agents (?giver)
  )

  (:action tiny_stories__story_033_a_reveal-lie
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?giver)
        (tiny_stories__story_033_type_character ?receiver)
        (and
          (tiny_stories__story_033_p_offered-snack ?giver ?receiver)
          (not (tiny_stories__story_033_p_compassionate ?giver))
        )
      )
    :effect
      (and
        (tiny_stories__story_033_p_snack-is-lie ?giver ?receiver)
        (not (tiny_stories__story_033_p_happy ?receiver))
        (tiny_stories__story_033_p_sad ?receiver)
      )
    :agents (?giver)
  )

  (:action tiny_stories__story_033_a_run-away
    :parameters (?runner - object ?from - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?runner)
        (tiny_stories__story_033_type_character ?from)
        (and
          (tiny_stories__story_033_p_at ?runner ?from)
          (tiny_stories__story_033_p_sad ?runner)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_033_p_at ?runner ?from))
        (not (tiny_stories__story_033_p_trusts ?runner ?from))
      )
    :agents (?runner)
  )

  (:action tiny_stories__story_033_a_learn-lesson
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_033_active)
        (tiny_stories__story_033_type_character ?character)
        (and
          (tiny_stories__story_033_p_sad ?character)
          (not (tiny_stories__story_033_p_trusts ?character ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_033_p_sad ?character))
        (tiny_stories__story_033_p_happy ?character)
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
