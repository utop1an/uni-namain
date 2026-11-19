(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character ?x - object)
    (writing_prompts__wp_089_type_item ?x - object)
    (writing_prompts__wp_089_type_object ?x - object)
    (writing_prompts__wp_089_type_room ?x - object)
    (writing_prompts__wp_089_type_thing ?x - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (at ?p0 ?p1)
    (has-key ?p0)
    (has ?p0 ?p1)
    (in ?p0 ?p1)
    (sick ?p0)
    (called-911 ?p0 ?p1)
    (performing ?p0)
    (applause)
    (satisfied ?p0)
    (disappeared ?p0)
    (trick-performed)
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
    :parameters (?character ?item ?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?item)
          (writing_prompts__wp_089_type_room ?room)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?item)
          (writing_prompts__wp_089_type_room ?room)
        )
        (and
          (at ?character ?room)
          (in ?item ?room)
        )
      )
    :effect
      (and
        (not (in ?item ?room))
        (has ?character ?item)
      )
  )

  (:action leave-item
    :parameters (?character ?item ?room)
    :precondition
      (and
        (and
          (writing_prompts__wp_089_active)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?item)
          (writing_prompts__wp_089_type_room ?room)
          (writing_prompts__wp_089_type_character ?character)
          (writing_prompts__wp_089_type_item ?item)
          (writing_prompts__wp_089_type_room ?room)
        )
        (and
          (at ?character ?room)
          (has ?character ?item)
        )
      )
    :effect
      (and
        (not (has ?character ?item))
        (in ?item ?room)
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

  (:action perform-show
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (not (performing ?magician))
      )
    :effect
      (and
        (performing ?magician)
        (applause)
      )
  )

  (:action perform-final-trick
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (and
          (performing ?magician)
          (not (trick-performed))
        )
      )
    :effect
      (and
        (trick-performed)
        (disappeared ?magician)
      )
  )

  (:action become-satisfied
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?character)
          (writing_prompts__wp_096_type_character ?character)
        )
        (and
          (performing ?character)
          (trick-performed)
          (applause)
          (not (satisfied ?character))
        )
      )
    :effect
      (satisfied ?character)
  )

  (:action stop-applause
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (applause)
      )
    :effect
      (not (applause))
  )
)
