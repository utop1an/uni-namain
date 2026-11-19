(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (party ?p0)
    (cake ?p0)
    (happy ?p0)
    (worker ?p0)
    (clean ?p0)
    (makes-toys ?p0)
    (nervous ?p0)
    (friends-with ?p0 ?p1)
  )
  (:constants tiny_stories__story_060_o_vase - object tiny_stories__story_067_o_factory - object)

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

  (:action start-working
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (and)
      )
    :effect
      (worker ?character)
  )

  (:action clean-factory
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (clean tiny_stories__story_067_o_factory)
  )

  (:action make-toys
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (makes-toys ?character)
  )

  (:action become-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character1)
          (tiny_stories__story_067_type_character ?character2)
          (tiny_stories__story_067_type_character ?character1)
          (tiny_stories__story_067_type_character ?character2)
        )
        (and
          (worker ?character1)
          (worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (friends-with ?character1 ?character2)
  )

  (:action become-less-nervous
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (and
          (worker ?character)
          (nervous ?character)
        )
      )
    :effect
      (not (nervous ?character))
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (happy ?character)
  )
)
