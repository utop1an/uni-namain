(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_080_active)
    (tiny_stories__story_080_type_book ?x - object)
    (tiny_stories__story_080_type_bookshelf ?x - object)
    (tiny_stories__story_080_type_character ?x - object)
    (tiny_stories__story_080_type_item ?x - object)
    (tiny_stories__story_080_type_object ?x - object)
    (tiny_stories__story_080_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_080_p_on-shelf ?v0 - object ?v1 - object)
    (tiny_stories__story_080_p_fell-down ?v0 - object)
    (tiny_stories__story_080_p_sneezed ?v0 - object)
    (tiny_stories__story_080_p_scared ?v0 - object)
    (tiny_stories__story_080_p_in-room ?v0 - object)
    (tiny_stories__story_080_p_in-kitchen ?v0 - object)
    (tiny_stories__story_080_p_likes ?v0 - object ?v1 - object)
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (writing_prompts__wp_013_p_human ?v0 - object)
    (writing_prompts__wp_013_p_crow ?v0 - object)
    (writing_prompts__wp_013_p_in-pain ?v0 - object)
    (writing_prompts__wp_013_p_sunlight-available)
    (writing_prompts__wp_013_p_transformed ?v0 - object)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (writing_prompts__wp_049_p_needs-walk ?v0 - object)
    (writing_prompts__wp_049_p_in-herenow ?v0 - object)
    (writing_prompts__wp_049_p_ancient-oath ?v0 - object)
    (writing_prompts__wp_049_p_guardian ?v0 - object)
    (writing_prompts__wp_049_p_master ?v0 - object)
    (writing_prompts__wp_049_p_time-of-passing)
  )

  (:action tiny_stories__story_080_a_read
    :parameters (?character - object ?book - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_type_book ?book)
        (and
          (tiny_stories__story_080_p_has ?character ?book)
          (not (tiny_stories__story_080_p_fell-down ?book))
        )
      )
    :effect
      (intends ?character (tiny_stories__story_080_p_likes ?character ?book))
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_sneeze
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
      )
    :effect
      (tiny_stories__story_080_p_sneezed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_book-fall
    :parameters (?book - object ?bookshelf - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_book ?book)
        (tiny_stories__story_080_type_bookshelf ?bookshelf)
        (tiny_stories__story_080_p_on-shelf ?book ?bookshelf)
      )
    :effect
      (and
        (tiny_stories__story_080_p_fell-down ?book)
        (not (tiny_stories__story_080_p_on-shelf ?book ?bookshelf))
      )
  )

  (:action tiny_stories__story_080_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_sneezed ?character)
      )
    :effect
      (tiny_stories__story_080_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_move-to-kitchen
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_in-room ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_080_p_in-room ?character))
        (tiny_stories__story_080_p_in-kitchen ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_080_a_move-to-room
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_080_active)
        (tiny_stories__story_080_type_character ?character)
        (tiny_stories__story_080_p_in-kitchen ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_080_p_in-kitchen ?character))
        (tiny_stories__story_080_p_in-room ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_013_a_experience-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (writing_prompts__wp_013_p_human ?character)
      )
    :effect
      (writing_prompts__wp_013_p_in-pain ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_013_a_transform-into-crow
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (and
          (writing_prompts__wp_013_p_human ?character)
          (writing_prompts__wp_013_p_in-pain ?character)
          (writing_prompts__wp_013_p_sunlight-available)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_013_p_human ?character))
        (writing_prompts__wp_013_p_crow ?character)
        (writing_prompts__wp_013_p_transformed ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_013_a_transform-back-into-human
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_013_active)
        (writing_prompts__wp_013_type_character ?character)
        (writing_prompts__wp_013_p_crow ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_013_p_crow ?character))
        (writing_prompts__wp_013_p_human ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_049_a_remind-ancient-oath
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_ancient-oath ?dog)
        )
      )
    :effect
      (writing_prompts__wp_049_p_needs-walk ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_bring-to-herenow
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (not (writing_prompts__wp_049_p_in-herenow ?master))
        )
      )
    :effect
      (writing_prompts__wp_049_p_in-herenow ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_walk
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_needs-walk ?master)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_049_p_needs-walk ?master))
        (writing_prompts__wp_049_p_in-herenow ?master)
      )
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_time-of-passing
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (not (writing_prompts__wp_049_p_time-of-passing))
      )
    :effect
      (writing_prompts__wp_049_p_time-of-passing)
  )
)
