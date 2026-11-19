(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (has-skin ?p0)
    (kneel ?p0)
    (rewarded ?p0)
    (tried ?p0)
    (voice-happy ?p0)
    (at ?p0 ?p1)
    (sitting ?p0 ?p1)
    (broken ?p0)
    (big ?p0)
    (small ?p0)
    (important ?p0)
  )
  (:constants tiny_stories__story_031_o_old-house - object)

  (:action try
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (kneel ?character)
      )
    :effect
      (tried ?character)
  )

  (:action reward
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (voice-happy ?character)
      )
    :effect
      (rewarded ?character)
  )

  (:action take-skin
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (and
          (not (voice-happy ?character))
          (has-skin ?character)
        )
      )
    :effect
      (not (has-skin ?character))
  )

  (:action travel
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_place ?from)
          (tiny_stories__story_031_type_place ?to)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_place ?from)
          (tiny_stories__story_031_type_place ?to)
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

  (:action kneel
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (at ?character tiny_stories__story_031_o_old-house)
      )
    :effect
      (kneel ?character)
  )

  (:action evaluate
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (tried ?character)
      )
    :effect
      (voice-happy ?character)
  )

  (:action become-important
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_character ?character)
        )
        (not (important ?character))
      )
    :effect
      (important ?character)
  )

  (:action become-unimportant
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_character ?character)
        )
        (important ?character)
      )
    :effect
      (not (important ?character))
  )

  (:action move
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_place ?place)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_place ?place)
        )
        (not (at ?character ?place))
      )
    :effect
      (at ?character ?place)
  )

  (:action sit
    :parameters (?character ?seat)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_seat ?seat)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_seat ?seat)
        )
        (and
          (not (sitting ?character ?seat))
          (not (broken ?seat))
        )
      )
    :effect
      (sitting ?character ?seat)
  )

  (:action leave
    :parameters (?character ?seat)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_seat ?seat)
          (tiny_stories__story_095_type_character ?character)
          (tiny_stories__story_095_type_seat ?seat)
        )
        (sitting ?character ?seat)
      )
    :effect
      (not (sitting ?character ?seat))
  )

  (:action break-seat
    :parameters (?seat)
    :precondition
      (and
        (and
          (tiny_stories__story_095_active)
          (tiny_stories__story_095_type_seat ?seat)
          (tiny_stories__story_095_type_seat ?seat)
        )
        (not (broken ?seat))
      )
    :effect
      (broken ?seat)
  )
)
