(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character ?x - object)
    (writing_prompts__wp_089_type_item ?x - object)
    (writing_prompts__wp_089_type_object ?x - object)
    (writing_prompts__wp_089_type_room ?x - object)
    (writing_prompts__wp_089_type_thing ?x - object)
    (locked ?p0)
    (unlocked-by ?p0 ?p1)
    (hidden ?p0)
    (at ?p0 ?p1)
    (in ?p0 ?p1)
    (has ?p0 ?p1)
    (has-key ?p0)
    (sick ?p0)
    (called-911 ?p0 ?p1)
  )

  (:action enter
    :parameters (?character ?roomfrom ?roomto)
    :precondition
      (and
        (and
          (human_67ab241b327ccef0_active)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_room ?roomfrom)
          (human_67ab241b327ccef0_type_room ?roomto)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_room ?roomfrom)
          (human_67ab241b327ccef0_type_room ?roomto)
        )
        (and
          (not (locked ?roomto))
          (at ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (at ?character ?roomfrom))
        (at ?character ?roomto)
      )
  )

  (:action unlock
    :parameters (?character ?key ?room)
    :precondition
      (and
        (and
          (human_67ab241b327ccef0_active)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_key ?key)
          (human_67ab241b327ccef0_type_room ?room)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_key ?key)
          (human_67ab241b327ccef0_type_room ?room)
        )
        (and
          (locked ?room)
          (unlocked-by ?room ?key)
          (has ?character ?key)
        )
      )
    :effect
      (not (locked ?room))
  )

  (:action search-for
    :parameters (?character ?thing ?room)
    :precondition
      (and
        (and
          (human_67ab241b327ccef0_active)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_thing ?thing)
          (human_67ab241b327ccef0_type_room ?room)
          (human_67ab241b327ccef0_type_character ?character)
          (human_67ab241b327ccef0_type_thing ?thing)
          (human_67ab241b327ccef0_type_room ?room)
        )
        (and
          (at ?character ?room)
          (in ?thing ?room)
        )
      )
    :effect
      (and
        (has ?character ?thing)
        (not (in ?thing ?room))
      )
  )

  (:action call-911
    :parameters (?caller ?sick-person)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?caller)
          (writing_prompts__wp_089_type_character ?sick-person)
          (writing_prompts__wp_089_type_character ?caller)
          (writing_prompts__wp_089_type_character ?sick-person)
        )
        (and
          (sick ?sick-person)
          (not (called-911 ?caller ?sick-person))
        )
      )
    :effect
      (called-911 ?caller ?sick-person)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_room ?from)
          (writing_prompts__wp_089_type_room ?to)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_room ?from)
          (writing_prompts__wp_089_type_room ?to)
        )
        (and
          (not (= ?from ?to))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action take-item
    :parameters (?character ?object ?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?object)
          (writing_prompts__wp_089_type_room ?room)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_thing ?object)
          (writing_prompts__wp_089_type_room ?room)
        )
        (and
          (at ?character ?room)
          (in ?object ?room)
        )
      )
    :effect
      (and
        (not (in ?object ?room))
        (has ?character ?object)
      )
  )

  (:action leave-item
    :parameters (?character ?object ?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?object)
          (writing_prompts__wp_089_type_room ?room)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_thing ?object)
          (writing_prompts__wp_089_type_room ?room)
        )
        (and
          (at ?character ?room)
          (has ?character ?object)
        )
      )
    :effect
      (and
        (not (has ?character ?object))
        (in ?object ?room)
      )
  )
)
