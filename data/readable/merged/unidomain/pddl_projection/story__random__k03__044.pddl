(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
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
    (alive ?p0)
    (happy ?p0)
    (amazed ?p0)
    (supports ?p0 ?p1)
    (persistent ?p0)
    (completed ?p0)
    (at-peace ?p0)
    (sharing-technology ?p0 ?p1)
    (advanced-technology ?p0)
    (facing-destruction)
  )
  (:constants writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object)

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
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_place ?from)
          (tiny_stories__story_078_type_place ?to)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_place ?from)
          (tiny_stories__story_078_type_place ?to)
        )
        (and
          (not (= ?from ?to))
          (alive ?character)
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action become-amazed
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (amazed ?character)
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (happy ?character)
  )

  (:action support-project
    :parameters (?character ?project)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
        )
        (alive ?character)
      )
    :effect
      (supports ?character ?project)
  )

  (:action become-persistent
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (persistent ?character)
  )

  (:action complete-project
    :parameters (?character ?project)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
        )
        (and
          (alive ?character)
          (supports ?character ?project)
          (persistent ?character)
        )
      )
    :effect
      (completed ?project)
  )

  (:action unite
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (facing-destruction)
        )
      )
    :effect
      (and
        (at-peace ?nation1)
        (at-peace ?nation2)
        (sharing-technology ?nation1 ?nation2)
      )
  )

  (:action develop-technology
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (advanced-technology ?nation1)
        (advanced-technology ?nation2)
      )
  )

  (:action avoid-destruction
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (and
          (advanced-technology writing_prompts__wp_047_o_nation1)
          (advanced-technology writing_prompts__wp_047_o_nation2)
          (advanced-technology writing_prompts__wp_047_o_nation3)
        )
      )
    :effect
      (not (facing-destruction))
  )

  (:action maintain-peace
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (at-peace ?nation1)
          (at-peace ?nation2)
          (sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (at-peace ?nation1)
        (at-peace ?nation2)
        (sharing-technology ?nation1 ?nation2)
      )
  )
)
