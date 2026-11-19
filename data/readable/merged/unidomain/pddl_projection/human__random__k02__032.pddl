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
    (human_72bec7307b121ea5_active)
    (human_72bec7307b121ea5_type_book ?x - object)
    (human_72bec7307b121ea5_type_character ?x - object)
    (human_72bec7307b121ea5_type_item ?x - object)
    (human_72bec7307b121ea5_type_location ?x - object)
    (human_72bec7307b121ea5_type_object ?x - object)
    (human_72bec7307b121ea5_type_ring ?x - object)
    (human_72bec7307b121ea5_type_sword ?x - object)
    (human_72bec7307b121ea5_type_thing ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (asleep ?p0)
    (connected ?p0 ?p1)
    (enchanted ?p0)
    (is ?p0 ?p1)
  )

  (:action wake-person
    :parameters (?waker ?woken ?location)
    :precondition
      (and
        (or
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
            (human_72bec7307b121ea5_active)
            (human_72bec7307b121ea5_type_character ?waker)
            (human_72bec7307b121ea5_type_character ?woken)
            (human_72bec7307b121ea5_type_location ?location)
            (human_72bec7307b121ea5_type_character ?waker)
            (human_72bec7307b121ea5_type_character ?woken)
            (human_72bec7307b121ea5_type_location ?location)
          )
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

  (:action move-location
    :parameters (?character ?to ?from)
    :precondition
      (and
        (or
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
            (human_72bec7307b121ea5_active)
            (human_72bec7307b121ea5_type_character ?character)
            (human_72bec7307b121ea5_type_location ?to)
            (human_72bec7307b121ea5_type_location ?from)
            (human_72bec7307b121ea5_type_character ?character)
            (human_72bec7307b121ea5_type_location ?to)
            (human_72bec7307b121ea5_type_location ?from)
          )
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

  (:action take-thing
    :parameters (?taker ?thing ?location)
    :precondition
      (and
        (or
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
            (human_72bec7307b121ea5_active)
            (human_72bec7307b121ea5_type_character ?taker)
            (human_72bec7307b121ea5_type_item ?thing)
            (human_72bec7307b121ea5_type_location ?location)
            (human_72bec7307b121ea5_type_character ?taker)
            (human_72bec7307b121ea5_type_item ?thing)
            (human_72bec7307b121ea5_type_location ?location)
          )
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
        (or
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
            (human_72bec7307b121ea5_active)
            (human_72bec7307b121ea5_type_character ?caster)
            (human_72bec7307b121ea5_type_item ?thing)
            (human_72bec7307b121ea5_type_book ?book)
            (human_72bec7307b121ea5_type_location ?location)
            (human_72bec7307b121ea5_type_character ?caster)
            (human_72bec7307b121ea5_type_item ?thing)
            (human_72bec7307b121ea5_type_book ?book)
            (human_72bec7307b121ea5_type_location ?location)
          )
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
)
