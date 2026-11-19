(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_080_active)
    (tiny_stories__story_080_type_book ?x - object)
    (tiny_stories__story_080_type_bookshelf ?x - object)
    (tiny_stories__story_080_type_character ?x - object)
    (tiny_stories__story_080_type_item ?x - object)
    (tiny_stories__story_080_type_object ?x - object)
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (needs-walk ?p0)
    (in-herenow ?p0)
    (ancient-oath ?p0)
    (guardian ?p0)
    (master ?p0)
    (time-of-passing)
    (has ?p0 ?p1)
    (on-shelf ?p0 ?p1)
    (fell-down ?p0)
    (sneezed ?p0)
    (scared ?p0)
    (in-room ?p0)
    (in-kitchen ?p0)
    (likes ?p0 ?p1)
    (human ?p0)
    (crow ?p0)
    (in-pain ?p0)
    (sunlight-available)
    (transformed ?p0)
  )

  (:action remind-ancient-oath
    :parameters (?dog ?master)
    :precondition
      (and
        (and
          (writing_prompts__wp_049_active)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
        )
        (and
          (guardian ?dog)
          (master ?master)
          (ancient-oath ?dog)
        )
      )
    :effect
      (needs-walk ?master)
  )

  (:action bring-to-herenow
    :parameters (?dog ?master)
    :precondition
      (and
        (and
          (writing_prompts__wp_049_active)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
        )
        (and
          (guardian ?dog)
          (master ?master)
          (not (in-herenow ?master))
        )
      )
    :effect
      (in-herenow ?master)
  )

  (:action walk
    :parameters (?dog ?master)
    :precondition
      (and
        (and
          (writing_prompts__wp_049_active)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
          (writing_prompts__wp_049_type_character ?dog)
          (writing_prompts__wp_049_type_character ?master)
        )
        (and
          (guardian ?dog)
          (master ?master)
          (needs-walk ?master)
        )
      )
    :effect
      (and
        (not (needs-walk ?master))
        (in-herenow ?master)
      )
  )

  (:action time-of-passing
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (not (time-of-passing))
      )
    :effect
      (time-of-passing)
  )

  (:action read
    :parameters (?character ?book)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_book ?book)
        )
        (and
          (has ?character ?book)
          (not (fell-down ?book))
        )
      )
    :effect
      (and)
  )

  (:action sneeze
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (and)
      )
    :effect
      (sneezed ?character)
  )

  (:action book-fall
    :parameters (?book ?bookshelf)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_bookshelf ?bookshelf)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_bookshelf ?bookshelf)
        )
        (on-shelf ?book ?bookshelf)
      )
    :effect
      (and
        (fell-down ?book)
        (not (on-shelf ?book ?bookshelf))
      )
  )

  (:action get-scared
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (sneezed ?character)
      )
    :effect
      (scared ?character)
  )

  (:action move-to-kitchen
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (in-room ?character)
      )
    :effect
      (and
        (not (in-room ?character))
        (in-kitchen ?character)
      )
  )

  (:action move-to-room
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (in-kitchen ?character)
      )
    :effect
      (and
        (not (in-kitchen ?character))
        (in-room ?character)
      )
  )

  (:action experience-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (human ?character)
      )
    :effect
      (in-pain ?character)
  )

  (:action transform-into-crow
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (and
          (human ?character)
          (in-pain ?character)
          (sunlight-available)
        )
      )
    :effect
      (and
        (not (human ?character))
        (crow ?character)
        (transformed ?character)
      )
  )

  (:action transform-back-into-human
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (crow ?character)
      )
    :effect
      (and
        (not (crow ?character))
        (human ?character)
      )
  )
)
