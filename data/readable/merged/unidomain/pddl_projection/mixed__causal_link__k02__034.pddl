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
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (asleep ?p0)
    (connected ?p0 ?p1)
    (enchanted ?p0)
    (is ?p0 ?p1)
    (has ?p0 ?p1)
    (alive ?p0)
    (clean ?p0)
    (locked ?p0)
    (wearing ?p0 ?p1)
    (fits ?p0 ?p1)
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

  (:action lock-door
    :parameters (?character ?door)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
        )
        (and
          (alive ?character)
          (not (locked ?door))
        )
      )
    :effect
      (locked ?door)
  )

  (:action clean-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (clean ?item))
        )
      )
    :effect
      (clean ?item)
  )

  (:action adjust-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (fits ?item ?character))
        )
      )
    :effect
      (fits ?item ?character)
  )

  (:action wear-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (fits ?item ?character)
          (not (wearing ?character ?item))
        )
      )
    :effect
      (wearing ?character ?item)
  )
)
