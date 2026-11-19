(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_023_p_happy ?v0 - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_073_active)
    (tiny_stories__story_073_type_character ?x - object)
    (tiny_stories__story_073_type_object ?x - object)
    (tiny_stories__story_073_p_play-chess ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_feel-better ?v0 - object)
    (tiny_stories__story_073_p_sit-together ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_sick ?v0 - object)
    (tiny_stories__story_073_p_happy ?v0 - object)
    (writing_prompts__wp_004_active)
    (writing_prompts__wp_004_type_character ?x - object)
    (writing_prompts__wp_004_type_object ?x - object)
    (writing_prompts__wp_004_type_planet ?x - object)
    (writing_prompts__wp_004_p_on-planet ?v0 - object ?v1 - object)
    (writing_prompts__wp_004_p_in-formation ?v0 - object)
    (writing_prompts__wp_004_p_in-airlock ?v0 - object)
    (writing_prompts__wp_004_p_wingsuit-active ?v0 - object)
    (writing_prompts__wp_004_p_suit-pressurized ?v0 - object)
    (writing_prompts__wp_004_p_reached-altitude ?v0 - object)
    (writing_prompts__wp_004_p_reached-speed ?v0 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_012_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_has-robot ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
    (writing_prompts__wp_059_active)
    (writing_prompts__wp_059_type_character ?x - object)
    (writing_prompts__wp_059_type_object ?x - object)
    (writing_prompts__wp_059_p_friend ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_needs-help ?v0 - object)
    (writing_prompts__wp_059_p_smiling ?v0 - object)
    (writing_prompts__wp_059_p_laughing ?v0 - object)
    (writing_prompts__wp_059_p_provides-help ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_talks-to ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_023_a_play
    :parameters (?character - object ?animal - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_type_location ?place)
        (and
          (tiny_stories__story_023_p_at ?character ?place)
          (tiny_stories__story_023_p_at ?animal ?place)
        )
      )
    :effect
      (tiny_stories__story_023_p_playing ?character ?animal)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_stop-playing
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_p_playing ?character ?animal)
      )
    :effect
      (not (tiny_stories__story_023_p_playing ?character ?animal))
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_move
    :parameters (?object - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_object ?object)
        (tiny_stories__story_023_type_location ?from)
        (tiny_stories__story_023_type_location ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_023_p_at ?object ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_023_p_at ?object ?from))
        (tiny_stories__story_023_p_at ?object ?to)
      )
    :agents (?object)
  )

  (:action tiny_stories__story_023_a_can-run
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_can-run ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_can-fly
    :parameters (?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_animal ?animal)
      )
    :effect
      (tiny_stories__story_023_p_can-fly ?animal)
    :agents (?animal)
  )

  (:action tiny_stories__story_073_a_play-chess
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (and
          (not (tiny_stories__story_073_p_sick ?character1))
          (not (tiny_stories__story_073_p_sick ?character2))
          (not (= ?character1 ?character2))
          (tiny_stories__story_073_p_sit-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_073_p_play-chess ?character1 ?character2)
        (tiny_stories__story_073_p_happy ?character1)
        (tiny_stories__story_073_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_073_a_get-sick
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
      )
    :effect
      (tiny_stories__story_073_p_sick ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_feel-better
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
        (tiny_stories__story_073_p_sick ?character)
      )
    :effect
      (not (tiny_stories__story_073_p_sick ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_sit-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_073_p_sit-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_004_a_enter-airlock
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_004_active)
        (writing_prompts__wp_004_type_character ?character)
        (not (writing_prompts__wp_004_p_in-airlock ?character))
      )
    :effect
      (writing_prompts__wp_004_p_in-airlock ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_004_a_pressurize-suit
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_004_active)
        (writing_prompts__wp_004_type_character ?character)
        (and
          (writing_prompts__wp_004_p_in-airlock ?character)
          (not (writing_prompts__wp_004_p_suit-pressurized ?character))
        )
      )
    :effect
      (writing_prompts__wp_004_p_suit-pressurized ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_004_a_jump
    :parameters (?character - object ?planet - object)
    :precondition
      (and
        (writing_prompts__wp_004_active)
        (writing_prompts__wp_004_type_character ?character)
        (writing_prompts__wp_004_type_planet ?planet)
        (and
          (writing_prompts__wp_004_p_suit-pressurized ?character)
          (not (writing_prompts__wp_004_p_on-planet ?character ?planet))
        )
      )
    :effect
      (and
        (writing_prompts__wp_004_p_reached-altitude ?character)
        (writing_prompts__wp_004_p_reached-speed ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_004_a_activate-wingsuit
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_004_active)
        (writing_prompts__wp_004_type_character ?character)
        (and
          (writing_prompts__wp_004_p_reached-altitude ?character)
          (writing_prompts__wp_004_p_reached-speed ?character)
          (not (writing_prompts__wp_004_p_wingsuit-active ?character))
        )
      )
    :effect
      (writing_prompts__wp_004_p_wingsuit-active ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_004_a_land
    :parameters (?character - object ?planet - object)
    :precondition
      (and
        (writing_prompts__wp_004_active)
        (writing_prompts__wp_004_type_character ?character)
        (writing_prompts__wp_004_type_planet ?planet)
        (and
          (writing_prompts__wp_004_p_wingsuit-active ?character)
          (not (writing_prompts__wp_004_p_on-planet ?character ?planet))
        )
      )
    :effect
      (writing_prompts__wp_004_p_on-planet ?character ?planet)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_assemble
    :parameters (?character - object ?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_garage)
          (not (writing_prompts__wp_012_p_assembled ?robot))
        )
      )
    :effect
      (and
        (writing_prompts__wp_012_p_assembled ?robot)
        (writing_prompts__wp_012_p_has-robot ?character ?robot)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_start-task
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_assembled ?robot)
          (not (writing_prompts__wp_012_p_working-on-task ?robot))
        )
      )
    :effect
      (writing_prompts__wp_012_p_working-on-task ?robot)
    :agents (?robot)
  )

  (:action writing_prompts__wp_012_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (and
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_house)
          (not (writing_prompts__wp_012_p_playing-game ?character))
        )
      )
    :effect
      (writing_prompts__wp_012_p_playing-game ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_stop-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_p_playing-game ?character)
      )
    :effect
      (not (writing_prompts__wp_012_p_playing-game ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_059_a_talk
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_talks-to ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_provide-help
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
          (writing_prompts__wp_059_p_needs-help ?b)
          (writing_prompts__wp_059_p_talks-to ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_provides-help ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_start-smiling
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_smiling ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_smiling ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_059_a_start-laughing
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_laughing ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_laughing ?character)
    :agents (?character)
  )
)
