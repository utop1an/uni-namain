(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (writing_prompts__wp_035_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_alive ?v0 - object)
    (writing_prompts__wp_035_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
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
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (writing_prompts__wp_035_p_at ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (writing_prompts__wp_035_p_alive ?character))

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (tiny_stories__story_034_p_has ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_has ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_has ?character ?dress)
          (not (tiny_stories__story_075_p_wearing ?character ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_wearing ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_wearing ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (tiny_stories__story_075_p_wearing ?character ?old-dress)
          (not (tiny_stories__story_075_p_has ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (tiny_stories__story_075_p_has ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_travel
    :parameters (?character - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_place ?to)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_at ?character ?to))
        )
      )
    :effect
      (writing_prompts__wp_035_p_at ?character ?to)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-smoking
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_has ?character ?item)
          (not (writing_prompts__wp_035_p_smoking ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_smoking ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-dancing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_dancing ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_dancing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-eating
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_has ?character ?item)
          (not (writing_prompts__wp_035_p_eating ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_eating ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_shrink
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_shrunk ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_shrunk ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_change-clothes
    :parameters (?character - object ?old-item - object ?new-item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?old-item)
        (writing_prompts__wp_035_type_item ?new-item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_wearing ?character ?old-item)
          (writing_prompts__wp_035_p_has ?character ?new-item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_035_p_wearing ?character ?old-item))
        (writing_prompts__wp_035_p_wearing ?character ?new-item)
      )
    :agents (?character)
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
)
