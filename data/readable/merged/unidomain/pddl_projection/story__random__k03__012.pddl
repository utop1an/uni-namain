(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (writing_prompts__wp_004_active)
    (writing_prompts__wp_004_type_character ?x - object)
    (writing_prompts__wp_004_type_object ?x - object)
    (writing_prompts__wp_004_type_planet ?x - object)
    (on-planet ?p0 ?p1)
    (in-formation ?p0)
    (in-airlock ?p0)
    (wingsuit-active ?p0)
    (suit-pressurized ?p0)
    (reached-altitude ?p0)
    (reached-speed ?p0)
    (has ?p0 ?p1)
    (found ?p0 ?p1)
    (made-handprint ?p0)
    (celebrated ?p0)
    (at ?p0 ?p1)
    (sitting ?p0 ?p1)
    (broken ?p0)
    (big ?p0)
    (small ?p0)
    (important ?p0)
  )
  (:constants tiny_stories__story_019_o_colors - object)

  (:action enter-airlock
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_004_active)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_character ?character)
        )
        (not (in-airlock ?character))
      )
    :effect
      (in-airlock ?character)
  )

  (:action pressurize-suit
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_004_active)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_character ?character)
        )
        (and
          (in-airlock ?character)
          (not (suit-pressurized ?character))
        )
      )
    :effect
      (suit-pressurized ?character)
  )

  (:action jump
    :parameters (?character ?planet)
    :precondition
      (and
        (and
          (writing_prompts__wp_004_active)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_planet ?planet)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_planet ?planet)
        )
        (and
          (suit-pressurized ?character)
          (not (on-planet ?character ?planet))
        )
      )
    :effect
      (and
        (reached-altitude ?character)
        (reached-speed ?character)
      )
  )

  (:action activate-wingsuit
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_004_active)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_character ?character)
        )
        (and
          (reached-altitude ?character)
          (reached-speed ?character)
          (not (wingsuit-active ?character))
        )
      )
    :effect
      (wingsuit-active ?character)
  )

  (:action land
    :parameters (?character ?planet)
    :precondition
      (and
        (and
          (writing_prompts__wp_004_active)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_planet ?planet)
          (writing_prompts__wp_004_type_character ?character)
          (writing_prompts__wp_004_type_planet ?planet)
        )
        (and
          (wingsuit-active ?character)
          (not (on-planet ?character ?planet))
        )
      )
    :effect
      (on-planet ?character ?planet)
  )

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
)
