(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (shared_p_consensus_436f8290a678cf63 ?v0 - object ?v1 - object)
    (shared_p_consensus_2e755074f0ff530a ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_foggy ?v0 - object)
    (tiny_stories__story_022_p_found ?v0 - object)
    (tiny_stories__story_022_p_happy ?v0 - object)
    (shared_p_consensus_d531a6627ec3d8b4 ?v0 - object ?v1 - object)
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (shared_p_consensus_c4632dd8574ffead ?v0 - object)
    (writing_prompts__wp_007_active)
    (writing_prompts__wp_007_type_item ?x - object)
    (writing_prompts__wp_007_type_object ?x - object)
    (writing_prompts__wp_007_type_room ?x - object)
    (writing_prompts__wp_007_p_occupied ?v0 - object)
    (writing_prompts__wp_007_p_plugged-in ?v0 - object)
    (writing_prompts__wp_007_p_connected ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_well-lit ?v0 - object)
    (writing_prompts__wp_007_p_morning)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (writing_prompts__wp_081_p_has-emotion ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_p_knows-change ?v0 - object)
    (writing_prompts__wp_081_p_memorize ?v0 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (shared_p_consensus_d531a6627ec3d8b4 ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_022_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_place ?from)
        (tiny_stories__story_022_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_436f8290a678cf63 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_436f8290a678cf63 ?character ?from))
        (shared_p_consensus_436f8290a678cf63 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_search
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_item ?item)
        (tiny_stories__story_022_type_place ?place)
        (and
          (shared_p_consensus_436f8290a678cf63 ?character ?place)
          (not (tiny_stories__story_022_p_found ?item))
        )
      )
    :effect
      (when
        (not (tiny_stories__story_022_p_foggy ?place))
        (and
          (tiny_stories__story_022_p_found ?item)
          (shared_p_consensus_2e755074f0ff530a ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character1)
        (tiny_stories__story_022_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (shared_p_consensus_d531a6627ec3d8b4 ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_022_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
      )
    :effect
      (tiny_stories__story_022_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_clear-fog
    :parameters (?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_place ?place)
        (tiny_stories__story_022_p_foggy ?place)
      )
    :effect
      (not (tiny_stories__story_022_p_foggy ?place))
  )

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (shared_p_consensus_c4632dd8574ffead ?character)
      )
    :effect
      (shared_p_consensus_2e755074f0ff530a ?character ?mask)
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
          (shared_p_consensus_c4632dd8574ffead ?character)
          (shared_p_consensus_2e755074f0ff530a ?character ?mask)
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
          (shared_p_consensus_c4632dd8574ffead ?character)
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
          (shared_p_consensus_c4632dd8574ffead ?character1)
          (shared_p_consensus_c4632dd8574ffead ?character2)
          (shared_p_consensus_d531a6627ec3d8b4 ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_007_a_move-item
    :parameters (?item - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_type_room ?from)
        (writing_prompts__wp_007_type_room ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_436f8290a678cf63 ?item ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_436f8290a678cf63 ?item ?from))
        (shared_p_consensus_436f8290a678cf63 ?item ?to)
      )
  )

  (:action writing_prompts__wp_007_a_plug-in
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_plugged-in ?item))
      )
    :effect
      (writing_prompts__wp_007_p_plugged-in ?item)
  )

  (:action writing_prompts__wp_007_a_connect
    :parameters (?item1 - object ?item2 - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item1)
        (writing_prompts__wp_007_type_item ?item2)
        (and
          (not (writing_prompts__wp_007_p_connected ?item1 ?item2))
          (not (= ?item1 ?item2))
        )
      )
    :effect
      (writing_prompts__wp_007_p_connected ?item1 ?item2)
  )

  (:action writing_prompts__wp_007_a_morning-comes
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (not (writing_prompts__wp_007_p_well-lit ?room))
          (writing_prompts__wp_007_p_morning)
        )
      )
    :effect
      (writing_prompts__wp_007_p_well-lit ?room)
  )

  (:action writing_prompts__wp_007_a_night-falls
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (writing_prompts__wp_007_p_well-lit ?room)
          (not (writing_prompts__wp_007_p_morning))
        )
      )
    :effect
      (not (writing_prompts__wp_007_p_well-lit ?room))
  )

  (:action writing_prompts__wp_007_a_occupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_occupied ?item))
      )
    :effect
      (writing_prompts__wp_007_p_occupied ?item)
  )

  (:action writing_prompts__wp_007_a_unoccupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_p_occupied ?item)
      )
    :effect
      (not (writing_prompts__wp_007_p_occupied ?item))
  )

  (:action writing_prompts__wp_081_a_experience-emotion
    :parameters (?character - object ?emotion - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_type_emotion ?emotion)
        (shared_p_consensus_c4632dd8574ffead ?character)
      )
    :effect
      (writing_prompts__wp_081_p_has-emotion ?character ?emotion)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_notice-change
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (shared_p_consensus_c4632dd8574ffead ?character)
      )
    :effect
      (writing_prompts__wp_081_p_knows-change ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_memorize-appearance
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (and
          (shared_p_consensus_c4632dd8574ffead ?character)
          (writing_prompts__wp_081_p_knows-change ?character)
        )
      )
    :effect
      (writing_prompts__wp_081_p_memorize ?character)
    :agents (?character)
  )
)
