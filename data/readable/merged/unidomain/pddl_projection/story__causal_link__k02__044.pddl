(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (awake ?p0)
    (friends ?p0 ?p1)
    (interesting ?p0)
    (singing ?p0)
    (at ?p0 ?p1)
    (hiding ?p0)
    (seeking ?p0)
    (found ?p0 ?p1)
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (not (awake ?character))
      )
    :effect
      (awake ?character)
  )

  (:action sing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (singing ?character)
  )

  (:action stop-singing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (singing ?character)
      )
    :effect
      (not (singing ?character))
  )

  (:action make-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character1)
          (tiny_stories__story_011_type_character ?character2)
          (tiny_stories__story_011_type_character ?character1)
          (tiny_stories__story_011_type_character ?character2)
        )
        (and
          (awake ?character1)
          (awake ?character2)
          (not (friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action move
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
        )
        (and
          (awake ?character)
          (not (at ?character ?place))
        )
      )
    :effect
      (at ?character ?place)
  )

  (:action sleep
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
        )
        (and
          (awake ?character)
          (at ?character ?place)
          (interesting ?place)
        )
      )
    :effect
      (not (awake ?character))
  )

  (:action stop-seeking
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_character ?character)
        )
        (seeking ?character)
      )
    :effect
      (not (seeking ?character))
  )

  (:action start-hiding
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (hiding ?character)
  )

  (:action start-seeking
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (seeking ?character)
  )

  (:action find
    :parameters (?seeker ?hider ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
        )
        (and
          (seeking ?seeker)
          (hiding ?hider)
          (at ?seeker ?place)
          (at ?hider ?place)
        )
      )
    :effect
      (and
        (found ?seeker ?hider)
        (not (hiding ?hider))
      )
  )
)
