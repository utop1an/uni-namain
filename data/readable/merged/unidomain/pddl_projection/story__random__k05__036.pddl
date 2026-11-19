(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (writing_prompts__wp_004_active)
    (writing_prompts__wp_004_type_character ?x - object)
    (writing_prompts__wp_004_type_object ?x - object)
    (writing_prompts__wp_004_type_planet ?x - object)
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (alive ?p0)
    (happy ?p0)
    (amazed ?p0)
    (supports ?p0 ?p1)
    (persistent ?p0)
    (completed ?p0)
    (on-planet ?p0 ?p1)
    (in-formation ?p0)
    (in-airlock ?p0)
    (wingsuit-active ?p0)
    (suit-pressurized ?p0)
    (reached-altitude ?p0)
    (reached-speed ?p0)
    (at ?p0 ?p1)
    (awake ?p0)
    (wearing-pajamas ?p0)
    (on-floor ?p0)
    (dressed ?p0)
    (holding ?p0 ?p1)
    (walking ?p0 ?p1)
    (petting ?p0 ?p1)
    (bites ?p0)
    (owns ?p0 ?p1)
    (life-is-a-joke ?p0)
    (on-top ?p0 ?p1)
    (friends ?p0 ?p1)
    (scared ?p0)
    (has ?p0 ?p1)
    (impatient ?p0)
    (on-table ?p0)
    (smells-nice ?p0)
    (playing-with-ball ?p0)
  )
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object)

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

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_character ?character)
        )
        (not (awake ?character))
      )
    :effect
      (awake ?character)
  )

  (:action dress
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_character ?character)
        )
        (and
          (awake ?character)
          (on-floor ?character)
          (not (dressed ?character))
        )
      )
    :effect
      (dressed ?character)
  )

  (:action pet
    :parameters (?character ?animal)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_animal ?animal)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_animal ?animal)
        )
        (and
          (awake ?character)
          (dressed ?character)
          (not (bites ?animal))
        )
      )
    :effect
      (petting ?character ?animal)
  )

  (:action realize-life-is-a-joke
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_017_active)
          (writing_prompts__wp_017_type_character ?character)
          (writing_prompts__wp_017_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (life-is-a-joke ?character)
  )

  (:action become-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character1)
          (tiny_stories__story_040_type_character ?character2)
          (tiny_stories__story_040_type_character ?character1)
          (tiny_stories__story_040_type_character ?character2)
        )
        (not (= ?character1 ?character2))
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action overcome-fear
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_character ?character)
        )
        (scared ?character)
      )
    :effect
      (not (scared ?character))
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

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
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
            (tiny_stories__story_040_active)
            (tiny_stories__story_040_type_character ?character)
            (tiny_stories__story_040_type_place ?from)
            (tiny_stories__story_040_type_place ?to)
            (tiny_stories__story_040_type_character ?character)
            (tiny_stories__story_040_type_place ?from)
            (tiny_stories__story_040_type_place ?to)
          )
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

  (:action retrieve-toy
    :parameters (?character ?object ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_toy ?object)
          (tiny_stories__story_040_type_place ?place)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_toy ?object)
          (tiny_stories__story_040_type_place ?place)
        )
        (and
          (at ?character ?place)
          (on-top ?object ?place)
        )
      )
    :effect
      (and
        (not (on-top ?object ?place))
        (has ?character ?object)
      )
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
)
