(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (party ?p0)
    (cake ?p0)
    (happy ?p0)
    (bored ?p0)
    (dizzy ?p0)
    (rolling ?p0)
    (lying-down ?p0)
  )
  (:constants tiny_stories__story_060_o_vase - object)

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

  (:action start-rolling
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_100_active)
          (tiny_stories__story_100_type_character ?character)
          (tiny_stories__story_100_type_character ?character)
        )
        (and
          (bored ?character)
          (not (rolling ?character))
        )
      )
    :effect
      (and
        (not (bored ?character))
        (rolling ?character)
      )
  )

  (:action stop-rolling
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_100_active)
          (tiny_stories__story_100_type_character ?character)
          (tiny_stories__story_100_type_character ?character)
        )
        (rolling ?character)
      )
    :effect
      (and
        (not (rolling ?character))
        (dizzy ?character)
      )
  )

  (:action lie-down
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_100_active)
          (tiny_stories__story_100_type_character ?character)
          (tiny_stories__story_100_type_character ?character)
        )
        (and
          (dizzy ?character)
          (not (lying-down ?character))
        )
      )
    :effect
      (and
        (not (dizzy ?character))
        (lying-down ?character)
      )
  )

  (:action get-up
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_100_active)
          (tiny_stories__story_100_type_character ?character)
          (tiny_stories__story_100_type_character ?character)
        )
        (lying-down ?character)
      )
    :effect
      (and
        (not (lying-down ?character))
        (happy ?character)
      )
  )
)
