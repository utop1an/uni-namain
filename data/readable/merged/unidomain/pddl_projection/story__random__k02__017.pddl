(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (at ?p0 ?p1)
    (happy ?p0)
    (gave-gift ?p0 ?p1 ?p2)
    (has ?p0 ?p1)
    (friends ?p0 ?p1)
    (clean ?p0)
    (steal-intention ?p0 ?p1)
  )

  (:action make-happy
    :parameters (?character ?target)
    :precondition
      (and
        (and
          (tiny_stories__story_066_active)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_character ?target)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_character ?target)
        )
        (and
          (not (= ?character ?target))
          (not (happy ?target))
        )
      )
    :effect
      (happy ?target)
  )

  (:action find
    :parameters (?character ?item ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_066_active)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_place ?place)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_place ?place)
        )
        (and
          (at ?character ?place)
          (not (has ?character ?item))
        )
      )
    :effect
      (has ?character ?item)
  )

  (:action give
    :parameters (?giver ?item ?receiver ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_066_active)
          (tiny_stories__story_066_type_character ?giver)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_character ?receiver)
          (tiny_stories__story_066_type_place ?place)
          (tiny_stories__story_066_type_character ?giver)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_character ?receiver)
          (tiny_stories__story_066_type_place ?place)
        )
        (and
          (not (= ?giver ?receiver))
          (at ?giver ?place)
          (has ?giver ?item)
          (at ?receiver ?place)
        )
      )
    :effect
      (and
        (not (has ?giver ?item))
        (has ?receiver ?item)
        (gave-gift ?giver ?receiver ?item)
      )
  )

  (:action play
    :parameters (?character ?item ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_066_active)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_place ?place)
          (tiny_stories__story_066_type_character ?character)
          (tiny_stories__story_066_type_item ?item)
          (tiny_stories__story_066_type_place ?place)
        )
        (and
          (at ?character ?place)
          (has ?character ?item)
        )
      )
    :effect
      (happy ?character)
  )

  (:action apologize
    :parameters (?apologizer ?apologized)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?apologizer)
          (tiny_stories__story_070_type_character ?apologized)
          (tiny_stories__story_070_type_character ?apologizer)
          (tiny_stories__story_070_type_character ?apologized)
        )
        (and
          (not (= ?apologizer ?apologized))
          (not (friends ?apologizer ?apologized))
        )
      )
    :effect
      (friends ?apologizer ?apologized)
  )

  (:action try-steal
    :parameters (?stealer ?item ?owner)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?stealer)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?owner)
          (tiny_stories__story_070_type_character ?stealer)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?owner)
        )
        (and
          (not (= ?stealer ?owner))
          (has ?owner ?item)
          (steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (steal-intention ?stealer ?item))
        (not (friends ?stealer ?owner))
        (has ?stealer ?item)
        (not (has ?owner ?item))
      )
  )

  (:action clean-item
    :parameters (?cleaner ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?cleaner)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?cleaner)
          (tiny_stories__story_070_type_item ?item)
        )
        (and
          (not (clean ?item))
          (has ?cleaner ?item)
        )
      )
    :effect
      (clean ?item)
  )

  (:action drop-in-puddle
    :parameters (?dropper ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?dropper)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?dropper)
          (tiny_stories__story_070_type_item ?item)
        )
        (and
          (has ?dropper ?item)
          (clean ?item)
        )
      )
    :effect
      (not (clean ?item))
  )
)
