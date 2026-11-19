(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (on-shelf ?p0)
    (organized ?p0)
    (reads ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (happy ?p0)
    (sad ?p0)
  )

  (:action find
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?item)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?item)
        )
        (and
          (not (has ?character ?item))
          (reads ?character)
        )
      )
    :effect
      (has ?character ?item)
  )

  (:action put-on-shelf
    :parameters (?character ?item ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?item)
          (tiny_stories__story_028_type_place ?place)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?item)
          (tiny_stories__story_028_type_place ?place)
        )
        (and
          (has ?character ?item)
          (at ?character ?place)
        )
      )
    :effect
      (and
        (not (has ?character ?item))
        (on-shelf ?item)
        (organized ?place)
      )
  )

  (:action read
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_character ?character)
        )
        (reads ?character)
      )
    :effect
      (happy ?character)
  )

  (:action smell-soap
    :parameters (?character ?soap)
    :precondition
      (and
        (and
          (tiny_stories__story_028_active)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?soap)
          (tiny_stories__story_028_type_character ?character)
          (tiny_stories__story_028_type_item ?soap)
        )
        (and
          (on-shelf ?soap)
          (reads ?character)
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
)
