(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (at ?p0 ?p1)
    (has-skin ?p0)
    (kneel ?p0)
    (rewarded ?p0)
    (tried ?p0)
    (voice-happy ?p0)
    (at-party ?p0)
    (has ?p0 ?p1)
    (fast ?p0)
    (cake-transformed)
  )
  (:constants tiny_stories__story_031_o_old-house - object)

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
