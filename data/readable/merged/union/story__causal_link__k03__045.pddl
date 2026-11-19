(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_alive ?v0 - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (writing_prompts__wp_054_p_has ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (writing_prompts__wp_054_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

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

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (writing_prompts__wp_054_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_has ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (writing_prompts__wp_054_p_has ?killer ?weapon)
          (writing_prompts__wp_054_p_alive ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_054_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_at ?character ?from))
        (writing_prompts__wp_054_p_at ?character ?to)
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
