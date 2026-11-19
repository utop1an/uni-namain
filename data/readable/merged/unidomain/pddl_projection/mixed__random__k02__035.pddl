(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_72bec7307b121ea5_active)
    (human_72bec7307b121ea5_type_book ?x - object)
    (human_72bec7307b121ea5_type_character ?x - object)
    (human_72bec7307b121ea5_type_item ?x - object)
    (human_72bec7307b121ea5_type_location ?x - object)
    (human_72bec7307b121ea5_type_object ?x - object)
    (human_72bec7307b121ea5_type_ring ?x - object)
    (human_72bec7307b121ea5_type_sword ?x - object)
    (human_72bec7307b121ea5_type_thing ?x - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (player ?p0)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (asleep ?p0)
    (connected ?p0 ?p1)
    (enchanted ?p0)
    (is ?p0 ?p1)
    (alive ?p0)
    (imprisoned ?p0)
    (served-sentence ?p0)
    (has-serum ?p0)
    (religious ?p0)
  )

  (:action move-location
    :parameters (?character ?to ?from)
    :precondition
      (and
        (and
          (human_72bec7307b121ea5_active)
          (human_72bec7307b121ea5_type_character ?character)
          (human_72bec7307b121ea5_type_location ?to)
          (human_72bec7307b121ea5_type_location ?from)
          (human_72bec7307b121ea5_type_character ?character)
          (human_72bec7307b121ea5_type_location ?to)
          (human_72bec7307b121ea5_type_location ?from)
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
          (human_72bec7307b121ea5_active)
          (human_72bec7307b121ea5_type_character ?waker)
          (human_72bec7307b121ea5_type_character ?woken)
          (human_72bec7307b121ea5_type_location ?location)
          (human_72bec7307b121ea5_type_character ?waker)
          (human_72bec7307b121ea5_type_character ?woken)
          (human_72bec7307b121ea5_type_location ?location)
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
          (human_72bec7307b121ea5_active)
          (human_72bec7307b121ea5_type_character ?taker)
          (human_72bec7307b121ea5_type_item ?thing)
          (human_72bec7307b121ea5_type_location ?location)
          (human_72bec7307b121ea5_type_character ?taker)
          (human_72bec7307b121ea5_type_item ?thing)
          (human_72bec7307b121ea5_type_location ?location)
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

  (:action take-serum
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (has-serum ?character))
        )
      )
    :effect
      (has-serum ?character)
  )

  (:action serve-sentence
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (not (served-sentence ?character))
        )
      )
    :effect
      (served-sentence ?character)
  )

  (:action release
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (served-sentence ?character)
        )
      )
    :effect
      (not (imprisoned ?character))
  )

  (:action convert
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (religious ?character))
        )
      )
    :effect
      (religious ?character)
  )

  (:action abandon-religion
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (religious ?character)
        )
      )
    :effect
      (not (religious ?character))
  )
)
