(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (connected ?p0 ?p1)
    (apprehended ?p0)
    (alive ?p0)
    (saved ?p0 ?p1)
    (knows ?p0)
    (captured ?p0)
    (henchman ?p0)
    (playing ?p0)
    (tired ?p0)
    (sleeping ?p0)
    (awake ?p0)
    (has-energy ?p0)
  )

  (:action move-location
    :parameters (?character ?to ?from)
    :precondition
      (and
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?character)
          (human_62959785b3ec220a_type_location ?to)
          (human_62959785b3ec220a_type_location ?from)
          (human_62959785b3ec220a_type_character ?character)
          (human_62959785b3ec220a_type_location ?to)
          (human_62959785b3ec220a_type_location ?from)
        )
        (and
          (player ?character)
          (connected ?to ?from)
          (at ?character ?from)
          (knows ?character)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action interrogate-character
    :parameters (?interrogator ?interrogated ?location)
    :precondition
      (and
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?interrogator)
          (human_62959785b3ec220a_type_character ?interrogated)
          (human_62959785b3ec220a_type_location ?location)
          (human_62959785b3ec220a_type_character ?interrogator)
          (human_62959785b3ec220a_type_character ?interrogated)
          (human_62959785b3ec220a_type_location ?location)
        )
        (and
          (player ?interrogator)
          (at ?interrogator ?location)
          (at ?interrogated ?location)
          (apprehended ?interrogated)
        )
      )
    :effect
      (knows ?interrogator)
  )

  (:action place-victim
    :parameters (?placer ?victim ?location ?placed)
    :precondition
      (and
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?placer)
          (human_62959785b3ec220a_type_character ?victim)
          (human_62959785b3ec220a_type_location ?location)
          (human_62959785b3ec220a_type_location ?placed)
          (human_62959785b3ec220a_type_character ?placer)
          (human_62959785b3ec220a_type_character ?victim)
          (human_62959785b3ec220a_type_location ?location)
          (human_62959785b3ec220a_type_location ?placed)
        )
        (and
          (henchman ?placer)
          (has ?placer ?victim)
          (at ?placer ?location)
          (connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (has ?placer ?victim))
        (at ?victim ?placed)
        (captured ?victim)
      )
  )

  (:action save-character
    :parameters (?saver ?saved ?notsaved ?location)
    :precondition
      (and
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?saver)
          (human_62959785b3ec220a_type_character ?saved)
          (human_62959785b3ec220a_type_character ?notsaved)
          (human_62959785b3ec220a_type_location ?location)
          (human_62959785b3ec220a_type_character ?saver)
          (human_62959785b3ec220a_type_character ?saved)
          (human_62959785b3ec220a_type_character ?notsaved)
          (human_62959785b3ec220a_type_location ?location)
        )
        (and
          (player ?saver)
          (at ?saver ?location)
          (at ?saved ?location)
          (captured ?saved)
          (captured ?notsaved)
          (not (at ?notsaved ?location))
        )
      )
    :effect
      (and
        (saved ?saved ?saver)
        (not (alive ?notsaved))
      )
  )

  (:action start-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (and
          (awake ?character)
          (not (playing ?character))
          (has-energy ?character)
        )
      )
    :effect
      (playing ?character)
  )

  (:action stop-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (playing ?character)
      )
    :effect
      (and
        (not (playing ?character))
        (tired ?character)
      )
  )

  (:action sleep
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (and
          (tired ?character)
          (not (sleeping ?character))
        )
      )
    :effect
      (and
        (not (awake ?character))
        (sleeping ?character)
      )
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (sleeping ?character)
      )
    :effect
      (and
        (awake ?character)
        (not (sleeping ?character))
        (not (tired ?character))
        (has-energy ?character)
      )
  )
)
