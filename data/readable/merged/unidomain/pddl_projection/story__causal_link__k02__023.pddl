(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (playing-with-toys ?p0)
    (found-blocks ?p0)
    (stacking-blocks ?p0)
    (stack-tall ?p0)
    (stack-strong ?p0)
    (helping ?p0 ?p1)
    (happy ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (party ?p0)
    (cake ?p0)
  )
  (:constants tiny_stories__story_060_o_vase - object)

  (:action play-with-toys
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (and)
      )
    :effect
      (playing-with-toys ?character)
  )

  (:action find-blocks
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (playing-with-toys ?character)
      )
    :effect
      (found-blocks ?character)
  )

  (:action stack-blocks
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (found-blocks ?character)
      )
    :effect
      (stacking-blocks ?character)
  )

  (:action make-stack-tall
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (stacking-blocks ?character)
      )
    :effect
      (stack-tall ?character)
  )

  (:action help
    :parameters (?helper ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?helper)
          (tiny_stories__story_050_type_character ?helpee)
          (tiny_stories__story_050_type_character ?helper)
          (tiny_stories__story_050_type_character ?helpee)
        )
        (and
          (not (= ?helper ?helpee))
          (stack-tall ?helpee)
        )
      )
    :effect
      (helping ?helper ?helpee)
  )

  (:action make-stack-strong
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (and
          (stack-tall ?character)
          (helping ?character ?character)
        )
      )
    :effect
      (stack-strong ?character)
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_050_active)
          (tiny_stories__story_050_type_character ?character)
          (tiny_stories__story_050_type_character ?character)
        )
        (stack-strong ?character)
      )
    :effect
      (happy ?character)
  )

  (:action make-cake
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_060_active)
          (tiny_stories__story_060_type_character ?character)
          (tiny_stories__story_060_type_object ?place)
          (tiny_stories__story_060_type_character ?character)
        )
        (happy ?character)
      )
    :effect
      (cake ?place)
  )

  (:action put
    :parameters (?character ?item ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_060_active)
          (tiny_stories__story_060_type_character ?character)
          (tiny_stories__story_060_type_item ?item)
          (tiny_stories__story_060_type_object ?place)
          (tiny_stories__story_060_type_character ?character)
          (tiny_stories__story_060_type_item ?item)
        )
        (and
          (happy ?character)
          (has ?character ?item)
        )
      )
    :effect
      (at ?item ?place)
  )

  (:action start-party
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_060_active)
          (tiny_stories__story_060_type_character ?character)
          (tiny_stories__story_060_type_object ?place)
          (tiny_stories__story_060_type_character ?character)
        )
        (happy ?character)
      )
    :effect
      (party ?place)
  )

  (:action enjoy-party
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_060_active)
          (tiny_stories__story_060_type_character ?character)
          (tiny_stories__story_060_type_object ?place)
          (tiny_stories__story_060_type_character ?character)
        )
        (and
          (happy ?character)
          (party ?place)
        )
      )
    :effect
      (happy ?character)
  )
)
