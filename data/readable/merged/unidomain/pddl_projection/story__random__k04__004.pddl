(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (broken-pedal ?p0)
    (fixed-pedal ?p0)
    (has ?p0 ?p1)
    (at-shop ?p0)
    (happy ?p0)
    (flying ?p0)
    (on-ship ?p0 ?p1)
    (moby-dick-spotted ?p0)
    (moby-dick-attacking ?p0)
    (read-moby-dick ?p0)
    (trained-in-whale-killing ?p0)
    (battle-stations ?p0)
    (alive ?p0)
    (president ?p0)
    (speaker ?p0)
    (vice-president ?p0)
    (belongs-to ?p0 ?p1)
    (economy-collapsed)
    (real-estate-monopoly)
    (planned-parenthood-defunded)
    (planned-parenthood-shutdown)
    (planned-parenthood-criminalized)
    (prison-population-increased)
    (political-prisoner ?p0)
    (has-emotion ?p0 ?p1)
    (knows-change ?p0)
    (memorize ?p0)
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

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_character ?character)
        )
        (not (happy ?character))
      )
    :effect
      (happy ?character)
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

  (:action moby-dick-attack
    :parameters (?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (moby-dick-spotted ?ship)
      )
    :effect
      (moby-dick-attacking ?ship)
  )

  (:action train-in-whale-killing
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_character ?character)
        )
        (read-moby-dick ?character)
      )
    :effect
      (trained-in-whale-killing ?character)
  )

  (:action spot-moby-dick
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
        )
      )
    :effect
      (moby-dick-spotted ?ship)
  )

  (:action order-battle-stations
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
          (moby-dick-spotted ?ship)
        )
      )
    :effect
      (battle-stations ?ship)
  )

  (:action try-kill-moby-dick
    :parameters (?character ?ship)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_ship ?ship)
        )
        (and
          (alive ?character)
          (on-ship ?character ?ship)
          (trained-in-whale-killing ?character)
          (moby-dick-attacking ?ship)
          (battle-stations ?ship)
        )
      )
    :effect
      (not (moby-dick-attacking ?ship))
  )

  (:action read-moby-dick
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_031_active)
          (writing_prompts__wp_031_type_character ?character)
          (writing_prompts__wp_031_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (read-moby-dick ?character)
  )

  (:action announce-state-of-the-union
    :parameters (?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?president)
        )
        (president ?president)
      )
    :effect
      (and)
  )

  (:action introduce-president
    :parameters (?speaker ?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
        )
        (and
          (speaker ?speaker)
          (president ?president)
        )
      )
    :effect
      (and)
  )

  (:action attend-state-of-the-union
    :parameters (?vice-president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?vice-president)
          (writing_prompts__wp_075_type_character ?vice-president)
        )
        (vice-president ?vice-president)
      )
    :effect
      (and)
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
)
