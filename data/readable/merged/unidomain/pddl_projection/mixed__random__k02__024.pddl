(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_4d95b598471c21ee_active)
    (human_4d95b598471c21ee_type_book ?x - object)
    (human_4d95b598471c21ee_type_character ?x - object)
    (human_4d95b598471c21ee_type_item ?x - object)
    (human_4d95b598471c21ee_type_location ?x - object)
    (human_4d95b598471c21ee_type_object ?x - object)
    (human_4d95b598471c21ee_type_ring ?x - object)
    (human_4d95b598471c21ee_type_sword ?x - object)
    (human_4d95b598471c21ee_type_thing ?x - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (asleep ?p0)
    (connected ?p0 ?p1)
    (enchanted ?p0)
    (is ?p0 ?p1)
    (alive ?p0)
    (on-ship ?p0 ?p1)
    (moby-dick-spotted ?p0)
    (moby-dick-attacking ?p0)
    (read-moby-dick ?p0)
    (trained-in-whale-killing ?p0)
    (battle-stations ?p0)
  )

  (:action move-location
    :parameters (?character ?to ?from)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?character)
          (human_4d95b598471c21ee_type_location ?to)
          (human_4d95b598471c21ee_type_location ?from)
          (human_4d95b598471c21ee_type_character ?character)
          (human_4d95b598471c21ee_type_location ?to)
          (human_4d95b598471c21ee_type_location ?from)
        )
        (and
          (connected ?to ?from)
          (not (asleep ?character))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action wake-person
    :parameters (?waker ?woken ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?waker)
          (human_4d95b598471c21ee_type_character ?woken)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?waker)
          (human_4d95b598471c21ee_type_character ?woken)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?waker ?location)
          (at ?woken ?location)
          (asleep ?woken)
          (not (asleep ?waker))
        )
      )
    :effect
      (not (asleep ?woken))
  )

  (:action take-thing
    :parameters (?taker ?thing ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?taker)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?taker)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?taker ?location)
          (at ?thing ?location)
          (not (asleep ?taker))
          (not (enchanted ?thing))
        )
      )
    :effect
      (and
        (not (at ?thing ?location))
        (has ?taker ?thing)
      )
  )

  (:action disenchant-thing
    :parameters (?caster ?thing ?book ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?caster)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_book ?book)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?caster)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_book ?book)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?caster ?location)
          (at ?thing ?location)
          (not (asleep ?caster))
          (has ?caster ?book)
          (enchanted ?thing)
        )
      )
    :effect
      (not (enchanted ?thing))
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
)
