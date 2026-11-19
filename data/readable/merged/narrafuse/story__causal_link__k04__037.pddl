(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (shared_p_consensus_a490b70ea0b5bf0b ?v0 - object ?v1 - object)
    (shared_p_consensus_2b391014163c938f ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_happy ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_e8b8896763c573ac ?v0 - object)
    (shared_p_consensus_e16a1acf12b1b732 ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (shared_p_consensus_ddd6ecd5fbfd1f71 ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character ?x - object)
    (writing_prompts__wp_089_type_item ?x - object)
    (writing_prompts__wp_089_type_object ?x - object)
    (writing_prompts__wp_089_type_room ?x - object)
    (writing_prompts__wp_089_type_thing ?x - object)
    (writing_prompts__wp_089_p_has-key ?v0 - object)
    (writing_prompts__wp_089_p_in ?v0 - object ?v1 - object)
    (writing_prompts__wp_089_p_sick ?v0 - object)
    (writing_prompts__wp_089_p_called-911 ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_2b391014163c938f ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_2b391014163c938f ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_a490b70ea0b5bf0b ?character ?place)
          (not (shared_p_consensus_2b391014163c938f ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_2b391014163c938f ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_a490b70ea0b5bf0b ?giver ?place)
          (shared_p_consensus_2b391014163c938f ?giver ?item)
          (shared_p_consensus_a490b70ea0b5bf0b ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2b391014163c938f ?giver ?item))
        (shared_p_consensus_2b391014163c938f ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_a490b70ea0b5bf0b ?character ?place)
          (shared_p_consensus_2b391014163c938f ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (tiny_stories__story_066_p_happy ?target))
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?target)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_a490b70ea0b5bf0b ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_e16a1acf12b1b732 ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_e16a1acf12b1b732 ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_a490b70ea0b5bf0b ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_a490b70ea0b5bf0b ?character ?from)
          (shared_p_consensus_e16a1acf12b1b732 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a490b70ea0b5bf0b ?character ?from))
        (shared_p_consensus_a490b70ea0b5bf0b ?character ?to)
        (not (shared_p_consensus_e16a1acf12b1b732 ?character ?object))
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_2b391014163c938f ?character ?item)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?place)
          (shared_p_consensus_2b391014163c938f ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2b391014163c938f ?character ?item))
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
          (shared_p_consensus_e8b8896763c573ac ?killer)
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?killer ?place)
          (shared_p_consensus_2b391014163c938f ?killer ?weapon)
          (shared_p_consensus_e8b8896763c573ac ?victim)
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_e8b8896763c573ac ?victim))
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?from))
        (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?to)
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
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?from))
        (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?to)
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
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?room)
          (writing_prompts__wp_089_p_in ?item ?room)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_089_p_in ?item ?room))
        (shared_p_consensus_e16a1acf12b1b732 ?character ?item)
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
          (shared_p_consensus_ddd6ecd5fbfd1f71 ?character ?room)
          (shared_p_consensus_e16a1acf12b1b732 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e16a1acf12b1b732 ?character ?item))
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
