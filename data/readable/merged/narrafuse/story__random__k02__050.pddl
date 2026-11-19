(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character ?x - object)
    (writing_prompts__wp_089_type_item ?x - object)
    (writing_prompts__wp_089_type_object ?x - object)
    (writing_prompts__wp_089_type_room ?x - object)
    (writing_prompts__wp_089_type_thing ?x - object)
    (writing_prompts__wp_089_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_089_p_has-key ?v0 - object)
    (writing_prompts__wp_089_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_089_p_in ?v0 - object ?v1 - object)
    (writing_prompts__wp_089_p_sick ?v0 - object)
    (writing_prompts__wp_089_p_called-911 ?v0 - object ?v1 - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (writing_prompts__wp_096_p_performing ?v0 - object)
    (writing_prompts__wp_096_p_applause)
    (writing_prompts__wp_096_p_satisfied ?v0 - object)
    (writing_prompts__wp_096_p_disappeared ?v0 - object)
    (writing_prompts__wp_096_p_trick-performed)
  )

  (:action writing_prompts__wp_089_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?character)
        (writing_prompts__wp_089_type_room ?from)
        (writing_prompts__wp_089_type_room ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_089_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_089_p_at ?character ?from))
        (writing_prompts__wp_089_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_take-item
    :parameters (?character - object ?item - object ?room - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?character)
        (writing_prompts__wp_089_type_item ?item)
        (writing_prompts__wp_089_type_room ?room)
        (and
          (writing_prompts__wp_089_p_at ?character ?room)
          (writing_prompts__wp_089_p_in ?item ?room)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_089_p_in ?item ?room))
        (writing_prompts__wp_089_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_leave-item
    :parameters (?character - object ?item - object ?room - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?character)
        (writing_prompts__wp_089_type_item ?item)
        (writing_prompts__wp_089_type_room ?room)
        (and
          (writing_prompts__wp_089_p_at ?character ?room)
          (writing_prompts__wp_089_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_089_p_has ?character ?item))
        (writing_prompts__wp_089_p_in ?item ?room)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_089_a_call-911
    :parameters (?caller - object ?sick-person - object)
    :precondition
      (and
        (writing_prompts__wp_089_active)
        (writing_prompts__wp_089_type_character ?caller)
        (writing_prompts__wp_089_type_character ?sick-person)
        (and
          (writing_prompts__wp_089_p_sick ?sick-person)
          (not (writing_prompts__wp_089_p_called-911 ?caller ?sick-person))
        )
      )
    :effect
      (writing_prompts__wp_089_p_called-911 ?caller ?sick-person)
    :agents (?caller)
  )

  (:action writing_prompts__wp_096_a_perform-show
    :parameters (?magician - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?magician)
        (not (writing_prompts__wp_096_p_performing ?magician))
      )
    :effect
      (and
        (writing_prompts__wp_096_p_performing ?magician)
        (writing_prompts__wp_096_p_applause)
      )
    :agents (?magician)
  )

  (:action writing_prompts__wp_096_a_perform-final-trick
    :parameters (?magician - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?magician)
        (and
          (writing_prompts__wp_096_p_performing ?magician)
          (not (writing_prompts__wp_096_p_trick-performed))
        )
      )
    :effect
      (and
        (writing_prompts__wp_096_p_trick-performed)
        (writing_prompts__wp_096_p_disappeared ?magician)
      )
    :agents (?magician)
  )

  (:action writing_prompts__wp_096_a_become-satisfied
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?character)
        (and
          (writing_prompts__wp_096_p_performing ?character)
          (writing_prompts__wp_096_p_trick-performed)
          (writing_prompts__wp_096_p_applause)
          (not (writing_prompts__wp_096_p_satisfied ?character))
        )
      )
    :effect
      (writing_prompts__wp_096_p_satisfied ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_096_a_stop-applause
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_p_applause)
      )
    :effect
      (not (writing_prompts__wp_096_p_applause))
  )
)
