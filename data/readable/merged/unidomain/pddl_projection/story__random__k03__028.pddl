(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_048_active)
    (tiny_stories__story_048_type_character ?x - object)
    (tiny_stories__story_048_type_object ?x - object)
    (tiny_stories__story_048_type_place ?x - object)
    (writing_prompts__wp_022_active)
    (writing_prompts__wp_022_type_character ?x - object)
    (writing_prompts__wp_022_type_object ?x - object)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (needs-walk ?p0)
    (in-herenow ?p0)
    (ancient-oath ?p0)
    (guardian ?p0)
    (master ?p0)
    (time-of-passing)
    (at ?p0 ?p1)
    (dry ?p0)
    (wet ?p0)
    (happy ?p0)
    (sad ?p0)
    (friends ?p0 ?p1)
    (pranked ?p0 ?p1)
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

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?from)
          (tiny_stories__story_048_type_place ?to)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?from)
          (tiny_stories__story_048_type_place ?to)
        )
        (and
          (not (= ?from ?to))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action play
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?place)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?place)
        )
        (and
          (at ?character ?place)
          (dry ?place)
        )
      )
    :effect
      (happy ?character)
  )

  (:action dry-place
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?place)
          (tiny_stories__story_048_type_character ?character)
          (tiny_stories__story_048_type_place ?place)
        )
        (and
          (at ?character ?place)
          (wet ?place)
        )
      )
    :effect
      (and
        (not (wet ?place))
        (dry ?place)
      )
  )

  (:action make-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?character1)
          (tiny_stories__story_048_type_character ?character2)
          (tiny_stories__story_048_type_character ?character1)
          (tiny_stories__story_048_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (happy ?character1)
          (happy ?character2)
        )
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action prank
    :parameters (?pranker ?target)
    :precondition
      (and
        (and
          (writing_prompts__wp_022_active)
          (writing_prompts__wp_022_type_character ?pranker)
          (writing_prompts__wp_022_type_character ?target)
          (writing_prompts__wp_022_type_character ?pranker)
          (writing_prompts__wp_022_type_character ?target)
        )
        (and)
      )
    :effect
      (pranked ?pranker ?target)
  )
)
