(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (connected ?p0 ?p1)
    (apprehended ?p0)
    (saved ?p0 ?p1)
    (knows ?p0)
    (captured ?p0)
    (henchman ?p0)
    (alive ?p0)
    (has-emotion ?p0 ?p1)
    (knows-change ?p0)
    (memorize ?p0)
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
