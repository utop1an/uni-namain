(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (found ?p0 ?p1)
    (made-handprint ?p0)
    (celebrated ?p0)
    (has ?p0 ?p1)
    (at-party ?p0)
    (fast ?p0)
    (cake-transformed)
  )
  (:constants tiny_stories__story_019_o_colors - object)

  (:action find
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?character)
          (tiny_stories__story_019_type_object ?object)
          (tiny_stories__story_019_type_character ?character)
        )
        (not (found ?character ?object))
      )
    :effect
      (found ?character ?object)
  )

  (:action make-handprint
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?character)
          (tiny_stories__story_019_type_character ?character)
        )
        (found ?character tiny_stories__story_019_o_colors)
      )
    :effect
      (made-handprint ?character)
  )

  (:action show-handprint
    :parameters (?shower ?viewer)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?shower)
          (tiny_stories__story_019_type_character ?viewer)
          (tiny_stories__story_019_type_character ?shower)
          (tiny_stories__story_019_type_character ?viewer)
        )
        (and
          (made-handprint ?shower)
          (not (= ?shower ?viewer))
        )
      )
    :effect
      (celebrated ?viewer)
  )

  (:action celebrate
    :parameters (?celebrator ?celebratee)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?celebrator)
          (tiny_stories__story_019_type_character ?celebratee)
          (tiny_stories__story_019_type_character ?celebrator)
          (tiny_stories__story_019_type_character ?celebratee)
        )
        (and
          (celebrated ?celebrator)
          (not (= ?celebrator ?celebratee))
        )
      )
    :effect
      (celebrated ?celebratee)
  )

  (:action go-to-party
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_072_active)
          (tiny_stories__story_072_type_character ?character)
          (tiny_stories__story_072_type_character ?character)
        )
        (not (at-party ?character))
      )
    :effect
      (at-party ?character)
  )

  (:action magic-trick
    :parameters (?magician)
    :precondition
      (and
        (and
          (tiny_stories__story_072_active)
          (tiny_stories__story_072_type_character ?magician)
          (tiny_stories__story_072_type_character ?magician)
        )
        (and
          (at-party ?magician)
          (not (cake-transformed))
        )
      )
    :effect
      (cake-transformed)
  )

  (:action eat-cake
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_072_active)
          (tiny_stories__story_072_type_character ?character)
          (tiny_stories__story_072_type_character ?character)
        )
        (and
          (at-party ?character)
          (cake-transformed)
        )
      )
    :effect
      (fast ?character)
  )

  (:action play
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_072_active)
          (tiny_stories__story_072_type_character ?character)
          (tiny_stories__story_072_type_character ?character)
        )
        (and
          (at-party ?character)
          (fast ?character)
        )
      )
    :effect
      (and)
  )
)
