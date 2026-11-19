(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_037_active)
    (writing_prompts__wp_037_type_character ?x - object)
    (writing_prompts__wp_037_type_object ?x - object)
    (writing_prompts__wp_037_p_knows ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_together ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_missing ?v0 - object)
    (writing_prompts__wp_037_p_relationship ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_searching ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_found ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_p_alive ?v0 - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
  )

  (:action writing_prompts__wp_037_a_start-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (not (= ?searcher ?target))
          (not (writing_prompts__wp_037_p_searching ?searcher ?target))
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (writing_prompts__wp_037_p_searching ?searcher ?target)
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_stop-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (writing_prompts__wp_037_p_searching ?searcher ?target)
      )
    :effect
      (not (writing_prompts__wp_037_p_searching ?searcher ?target))
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_find
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (writing_prompts__wp_037_p_searching ?searcher ?target)
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_037_p_missing ?target))
        (writing_prompts__wp_037_p_found ?searcher ?target)
      )
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_start-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
          (writing_prompts__wp_037_p_knows ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_037_p_relationship ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_037_a_end-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (writing_prompts__wp_037_p_relationship ?character1 ?character2)
      )
    :effect
      (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_064_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_place ?from)
        (writing_prompts__wp_064_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_064_p_alive ?character)
          (writing_prompts__wp_064_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_064_p_at ?character ?from))
        (writing_prompts__wp_064_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_deliver
    :parameters (?character - object ?item - object ?destination - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?destination)
        (and
          (writing_prompts__wp_064_p_alive ?character)
          (writing_prompts__wp_064_p_at ?character ?destination)
          (writing_prompts__wp_064_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_064_p_has ?character ?item))
        (writing_prompts__wp_064_p_delivered ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_pick-up
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?place)
        (and
          (writing_prompts__wp_064_p_alive ?character)
          (writing_prompts__wp_064_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_064_p_has ?character ?item)
    :agents (?character)
  )
)
