(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_017_active)
    (tiny_stories__story_017_type_character ?x - object)
    (tiny_stories__story_017_type_object ?x - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (at ?p0 ?p1)
    (assembled ?p0)
    (has-robot ?p0 ?p1)
    (working-on-task ?p0)
    (playing-game ?p0)
    (liberated ?p0)
    (defeated-illuminati)
    (alien-exists ?p0)
    (alien-gone ?p0)
    (alive ?p0)
    (has-emotion ?p0 ?p1)
    (knows-change ?p0)
    (memorize ?p0)
    (broken-pedal ?p0)
    (fixed-pedal ?p0)
    (has ?p0 ?p1)
    (at-shop ?p0)
    (flying ?p0)
    (happy ?p0)
    (watches-tv ?p0)
    (rude ?p0)
    (nice ?p0)
    (wants-to-watch-tv ?p0)
  )
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)

  (:action assemble
    :parameters (?character ?robot)
    :precondition
      (and
        (and
          (writing_prompts__wp_012_active)
          (writing_prompts__wp_012_type_character ?character)
          (writing_prompts__wp_012_type_robot ?robot)
          (writing_prompts__wp_012_type_character ?character)
          (writing_prompts__wp_012_type_robot ?robot)
        )
        (and
          (at ?character writing_prompts__wp_012_o_garage)
          (not (assembled ?robot))
        )
      )
    :effect
      (and
        (assembled ?robot)
        (has-robot ?character ?robot)
      )
  )

  (:action start-task
    :parameters (?robot)
    :precondition
      (and
        (and
          (writing_prompts__wp_012_active)
          (writing_prompts__wp_012_type_robot ?robot)
          (writing_prompts__wp_012_type_robot ?robot)
        )
        (and
          (assembled ?robot)
          (not (working-on-task ?robot))
        )
      )
    :effect
      (working-on-task ?robot)
  )

  (:action play-game
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_012_active)
          (writing_prompts__wp_012_type_character ?character)
          (writing_prompts__wp_012_type_character ?character)
        )
        (and
          (at ?character writing_prompts__wp_012_o_house)
          (not (playing-game ?character))
        )
      )
    :effect
      (playing-game ?character)
  )

  (:action stop-game
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_012_active)
          (writing_prompts__wp_012_type_character ?character)
          (writing_prompts__wp_012_type_character ?character)
        )
        (playing-game ?character)
      )
    :effect
      (not (playing-game ?character))
  )

  (:action liberate
    :parameters (?alien ?human)
    :precondition
      (and
        (and
          (writing_prompts__wp_057_active)
          (writing_prompts__wp_057_type_character ?alien)
          (writing_prompts__wp_057_type_character ?human)
          (writing_prompts__wp_057_type_character ?alien)
          (writing_prompts__wp_057_type_character ?human)
        )
        (and
          (alien-exists ?alien)
          (not (liberated ?human))
        )
      )
    :effect
      (liberated ?human)
  )

  (:action defeat-illuminati
    :parameters (?alien)
    :precondition
      (and
        (and
          (writing_prompts__wp_057_active)
          (writing_prompts__wp_057_type_character ?alien)
          (writing_prompts__wp_057_type_character ?alien)
        )
        (and
          (alien-exists ?alien)
          (not (defeated-illuminati))
        )
      )
    :effect
      (defeated-illuminati)
  )

  (:action disappear
    :parameters (?alien)
    :precondition
      (and
        (and
          (writing_prompts__wp_057_active)
          (writing_prompts__wp_057_type_character ?alien)
          (writing_prompts__wp_057_type_character ?alien)
        )
        (alien-exists ?alien)
      )
    :effect
      (alien-gone ?alien)
  )

  (:action reappear
    :parameters (?alien)
    :precondition
      (and
        (and
          (writing_prompts__wp_057_active)
          (writing_prompts__wp_057_type_character ?alien)
          (writing_prompts__wp_057_type_character ?alien)
        )
        (alien-gone ?alien)
      )
    :effect
      (alien-exists ?alien)
  )

  (:action experience-emotion
    :parameters (?character ?emotion)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_emotion ?emotion)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_emotion ?emotion)
        )
        (alive ?character)
      )
    :effect
      (has-emotion ?character ?emotion)
  )

  (:action notice-change
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (knows-change ?character)
  )

  (:action memorize-appearance
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_081_active)
          (writing_prompts__wp_081_type_character ?character)
          (writing_prompts__wp_081_type_character ?character)
        )
        (and
          (alive ?character)
          (knows-change ?character)
        )
      )
    :effect
      (memorize ?character)
  )

  (:action go-to-shop
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_character ?character)
        )
        (not (at-shop ?character))
      )
    :effect
      (at-shop ?character)
  )

  (:action fix-pedal
    :parameters (?character ?bike)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_object ?bike)
          (tiny_stories__story_003_type_character ?character)
        )
        (and
          (at-shop ?character)
          (has ?character ?bike)
          (broken-pedal ?bike)
        )
      )
    :effect
      (and
        (not (broken-pedal ?bike))
        (fixed-pedal ?bike)
      )
  )

  (:action start-flying
    :parameters (?bike)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_object ?bike)
        )
        (and
          (fixed-pedal ?bike)
          (not (flying ?bike))
        )
      )
    :effect
      (flying ?bike)
  )

  (:action start-watching-tv
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?character)
          (tiny_stories__story_017_type_character ?character)
        )
        (wants-to-watch-tv ?character)
      )
    :effect
      (watches-tv ?character)
  )

  (:action stop-watching-tv
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?character)
          (tiny_stories__story_017_type_character ?character)
        )
        (watches-tv ?character)
      )
    :effect
      (not (watches-tv ?character))
  )

  (:action become-nice
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?character)
          (tiny_stories__story_017_type_character ?character)
        )
        (rude ?character)
      )
    :effect
      (and
        (not (rude ?character))
        (nice ?character)
      )
  )

  (:action become-rude
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?character)
          (tiny_stories__story_017_type_character ?character)
        )
        (nice ?character)
      )
    :effect
      (and
        (not (nice ?character))
        (rude ?character)
      )
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (or
          (and
            (tiny_stories__story_003_active)
            (tiny_stories__story_003_type_character ?character)
            (tiny_stories__story_003_type_character ?character)
          )
          (and
            (tiny_stories__story_017_active)
            (tiny_stories__story_017_type_character ?character)
            (tiny_stories__story_017_type_character ?character)
          )
        )
        (not (happy ?character))
      )
    :effect
      (happy ?character)
  )

  (:action become-unhappy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?character)
          (tiny_stories__story_017_type_character ?character)
        )
        (happy ?character)
      )
    :effect
      (not (happy ?character))
  )
)
