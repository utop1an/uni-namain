(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_048_active)
    (tiny_stories__story_048_type_character ?x - object)
    (tiny_stories__story_048_type_object ?x - object)
    (tiny_stories__story_048_type_place ?x - object)
    (tiny_stories__story_048_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_048_p_dry ?v0 - object)
    (tiny_stories__story_048_p_wet ?v0 - object)
    (tiny_stories__story_048_p_happy ?v0 - object)
    (tiny_stories__story_048_p_sad ?v0 - object)
    (tiny_stories__story_048_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_022_active)
    (writing_prompts__wp_022_type_character ?x - object)
    (writing_prompts__wp_022_type_object ?x - object)
    (writing_prompts__wp_022_p_pranked ?v0 - object ?v1 - object)
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

  (:action tiny_stories__story_048_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?from)
        (tiny_stories__story_048_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_048_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_at ?character ?from))
        (tiny_stories__story_048_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_play
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_dry ?place)
        )
      )
    :effect
      (tiny_stories__story_048_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_dry-place
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_wet ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_wet ?place))
        (tiny_stories__story_048_p_dry ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character1)
        (tiny_stories__story_048_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_048_p_happy ?character1)
          (tiny_stories__story_048_p_happy ?character2)
        )
      )
    :effect
      (tiny_stories__story_048_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_022_a_prank
    :parameters (?pranker - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_022_active)
        (writing_prompts__wp_022_type_character ?pranker)
        (writing_prompts__wp_022_type_character ?target)
      )
    :effect
      (writing_prompts__wp_022_p_pranked ?pranker ?target)
    :agents (?pranker)
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
