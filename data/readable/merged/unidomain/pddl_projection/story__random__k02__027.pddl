(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (writing_prompts__wp_007_active)
    (writing_prompts__wp_007_type_item ?x - object)
    (writing_prompts__wp_007_type_object ?x - object)
    (writing_prompts__wp_007_type_room ?x - object)
    (has ?p0 ?p1)
    (happy ?p0)
    (sad ?p0)
    (at ?p0 ?p1)
    (in ?p0 ?p1)
    (occupied ?p0)
    (plugged-in ?p0)
    (connected ?p0 ?p1)
    (well-lit ?p0)
    (morning)
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

  (:action move-item
    :parameters (?item ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_item ?item)
          (writing_prompts__wp_007_type_room ?from)
          (writing_prompts__wp_007_type_room ?to)
          (writing_prompts__wp_007_type_item ?item)
          (writing_prompts__wp_007_type_room ?from)
          (writing_prompts__wp_007_type_room ?to)
        )
        (and
          (not (= ?from ?to))
          (in ?item ?from)
        )
      )
    :effect
      (and
        (not (in ?item ?from))
        (in ?item ?to)
      )
  )

  (:action plug-in
    :parameters (?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_item ?item)
          (writing_prompts__wp_007_type_item ?item)
        )
        (not (plugged-in ?item))
      )
    :effect
      (plugged-in ?item)
  )

  (:action connect
    :parameters (?item1 ?item2)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_item ?item1)
          (writing_prompts__wp_007_type_item ?item2)
          (writing_prompts__wp_007_type_item ?item1)
          (writing_prompts__wp_007_type_item ?item2)
        )
        (and
          (not (connected ?item1 ?item2))
          (not (= ?item1 ?item2))
        )
      )
    :effect
      (connected ?item1 ?item2)
  )

  (:action morning-comes
    :parameters (?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_room ?room)
          (writing_prompts__wp_007_type_room ?room)
        )
        (and
          (not (well-lit ?room))
          (morning)
        )
      )
    :effect
      (well-lit ?room)
  )

  (:action night-falls
    :parameters (?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_room ?room)
          (writing_prompts__wp_007_type_room ?room)
        )
        (and
          (well-lit ?room)
          (not (morning))
        )
      )
    :effect
      (not (well-lit ?room))
  )

  (:action occupy
    :parameters (?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_item ?item)
          (writing_prompts__wp_007_type_item ?item)
        )
        (not (occupied ?item))
      )
    :effect
      (occupied ?item)
  )

  (:action unoccupy
    :parameters (?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_007_active)
          (writing_prompts__wp_007_type_item ?item)
          (writing_prompts__wp_007_type_item ?item)
        )
        (occupied ?item)
      )
    :effect
      (not (occupied ?item))
  )
)
