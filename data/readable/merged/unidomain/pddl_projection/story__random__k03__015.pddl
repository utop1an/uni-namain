(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (scared ?p0)
    (spider-on-wall)
    (cake-made)
    (helping ?p0 ?p1)
    (happy ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (on-shelf ?p0)
    (organized ?p0)
    (reads ?p0)
    (playing-with-toys ?p0)
    (found-blocks ?p0)
    (stacking-blocks ?p0)
    (stack-tall ?p0)
    (stack-strong ?p0)
  )

  (:action see-spider
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?character)
        )
        (and
          (not (scared ?character))
          (not (spider-on-wall))
        )
      )
    :effect
      (and
        (scared ?character)
        (spider-on-wall)
      )
  )

  (:action remove-spider
    :parameters (?character ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?helpee)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?helpee)
        )
        (and
          (spider-on-wall)
          (helping ?character ?helpee)
        )
      )
    :effect
      (not (spider-on-wall))
  )

  (:action make-cake
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?character)
        )
        (and
          (not (cake-made))
          (happy ?character)
        )
      )
    :effect
      (cake-made)
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
        (or
          (and
            (tiny_stories__story_086_active)
            (tiny_stories__story_086_type_character ?helper)
            (tiny_stories__story_086_type_character ?helpee)
            (tiny_stories__story_086_type_character ?helper)
            (tiny_stories__story_086_type_character ?helpee)
          )
          (and
            (tiny_stories__story_050_active)
            (tiny_stories__story_050_type_character ?helper)
            (tiny_stories__story_050_type_character ?helpee)
            (tiny_stories__story_050_type_character ?helper)
            (tiny_stories__story_050_type_character ?helpee)
          )
        )
        (and
          (not (= ?helper ?helpee))
          (scared ?helpee)
          (stack-tall ?helpee)
        )
      )
    :effect
      (and
        (not (scared ?helpee))
        (happy ?helpee)
        (helping ?helper ?helpee)
      )
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
)
