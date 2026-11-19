(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (reading ?p0)
    (playing ?p0)
    (calm ?p0)
    (books-fall)
    (foggy ?p0)
    (found ?p0)
    (happy ?p0)
    (friends ?p0 ?p1)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (impatient ?p0)
    (on-table ?p0)
    (smells-nice ?p0)
    (playing-with-ball ?p0)
    (alive ?p0)
    (in-stasis ?p0)
    (ancient-technology ?p0)
    (propellant-device ?p0)
    (shielded ?p0)
    (requested-tow ?p0 ?p1)
  )
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object)

  (:action start-reading
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (reading ?character))
      )
    :effect
      (reading ?character)
  )

  (:action stop-reading
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (reading ?character)
      )
    :effect
      (not (reading ?character))
  )

  (:action start-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (playing ?character))
      )
    :effect
      (playing ?character)
  )

  (:action stop-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (playing ?character)
      )
    :effect
      (not (playing ?character))
  )

  (:action become-calm
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (calm ?character))
      )
    :effect
      (calm ?character)
  )

  (:action become-uncalm
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (calm ?character)
      )
    :effect
      (not (calm ?character))
  )

  (:action books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (books-fall))
      )
    :effect
      (books-fall)
  )

  (:action become-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_character ?character1)
          (tiny_stories__story_022_type_character ?character2)
          (tiny_stories__story_022_type_character ?character1)
          (tiny_stories__story_022_type_character ?character2)
        )
        (not (= ?character1 ?character2))
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_character ?character)
          (tiny_stories__story_022_type_character ?character)
        )
        (and)
      )
    :effect
      (happy ?character)
  )

  (:action clear-fog
    :parameters (?place)
    :precondition
      (and
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_place ?place)
          (tiny_stories__story_022_type_place ?place)
        )
        (foggy ?place)
      )
    :effect
      (not (foggy ?place))
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_character ?character)
          (tiny_stories__story_022_type_place ?from)
          (tiny_stories__story_022_type_place ?to)
          (tiny_stories__story_022_type_character ?character)
          (tiny_stories__story_022_type_place ?from)
          (tiny_stories__story_022_type_place ?to)
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

  (:action search
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_character ?character)
          (tiny_stories__story_022_type_item ?object)
          (tiny_stories__story_022_type_place ?place)
          (tiny_stories__story_022_type_character ?character)
          (tiny_stories__story_022_type_place ?place)
        )
        (and
          (at ?character ?place)
          (not (found ?object))
        )
      )
    :effect
      (when
        (not (foggy ?place))
        (and
          (found ?object)
          (has ?character ?object)
        )
      )
  )

  (:action request-tow
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
        )
      )
    :effect
      (requested-tow ?character ?place)
  )

  (:action smell-nice
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_046_active)
          (tiny_stories__story_046_type_character ?character)
          (tiny_stories__story_046_type_character ?character)
        )
        (has ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (smells-nice ?character)
  )

  (:action play-with-ball
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_046_active)
          (tiny_stories__story_046_type_character ?character)
          (tiny_stories__story_046_type_character ?character)
        )
        (has ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (playing-with-ball ?character)
  )

  (:action detect-stasis
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_character ?character)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (ancient-technology ?object)
        )
      )
    :effect
      (in-stasis ?object)
  )

  (:action try-get
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_046_active)
          (tiny_stories__story_046_type_character ?character)
          (tiny_stories__story_046_type_object ?object)
          (tiny_stories__story_046_type_character ?character)
        )
        (and
          (impatient ?character)
          (on-table ?object)
        )
      )
    :effect
      (and
        (not (on-table ?object))
        (has ?character ?object)
      )
  )

  (:action discover-technology
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_place ?place)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
        )
      )
    :effect
      (and
        (has ?character ?object)
        (ancient-technology ?object)
      )
  )

  (:action transport-object
    :parameters (?character ?object ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_011_active)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_object ?object)
          (writing_prompts__wp_011_type_place ?from)
          (writing_prompts__wp_011_type_place ?to)
          (writing_prompts__wp_011_type_character ?character)
          (writing_prompts__wp_011_type_place ?from)
          (writing_prompts__wp_011_type_place ?to)
        )
        (and
          (alive ?character)
          (at ?character ?from)
          (has ?character ?object)
          (requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
        (not (has ?character ?object))
      )
  )
)
