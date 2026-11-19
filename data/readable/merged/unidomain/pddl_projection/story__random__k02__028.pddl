(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (has ?p0 ?p1)
    (happy ?p0)
    (sad ?p0)
    (at ?p0 ?p1)
    (alive ?p0)
    (has-emotion ?p0 ?p1)
    (knows-change ?p0)
    (memorize ?p0)
  )

  (:action receive-gift
    :parameters (?receiver ?giver ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (not (= ?receiver ?giver))
          (happy ?giver)
          (not (has ?receiver ?item))
          (has ?giver ?item)
        )
      )
    :effect
      (and
        (has ?receiver ?item)
        (happy ?receiver)
      )
  )

  (:action play
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (has ?character ?item)
          (not (sad ?character))
        )
      )
    :effect
      (happy ?character)
  )

  (:action take-toy
    :parameters (?taker ?victim ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (not (= ?taker ?victim))
          (has ?victim ?item)
          (not (has ?taker ?item))
        )
      )
    :effect
      (and
        (not (has ?victim ?item))
        (has ?taker ?item)
        (sad ?victim)
      )
  )

  (:action lose-toy
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (has ?character ?item)
          (happy ?character)
        )
      )
    :effect
      (and
        (not (has ?character ?item))
        (sad ?character)
      )
  )

  (:action experience-emotion
    :parameters (?character ?emotion)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_emotion ?emotion)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_emotion ?emotion)
        )
        (alive ?character)
      )
    :effect
      (has-emotion ?character ?emotion)
  )

  (:action notice-change
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (knows-change ?character)
  )

  (:action memorize-appearance
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_character ?character)
        )
        (and
          (alive ?character)
          (knows-change ?character)
        )
      )
    :effect
      (memorize ?character)
  )
)
