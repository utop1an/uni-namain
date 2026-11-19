(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_031_o_old-house - object)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (shared_p_consensus_b39965a571708a09 ?v0 - object ?v1 - object)
    (tiny_stories__story_031_p_has-skin ?v0 - object)
    (tiny_stories__story_031_p_kneel ?v0 - object)
    (tiny_stories__story_031_p_rewarded ?v0 - object)
    (tiny_stories__story_031_p_tried ?v0 - object)
    (tiny_stories__story_031_p_voice-happy ?v0 - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
  )

  (:action tiny_stories__story_031_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_type_place ?from)
        (tiny_stories__story_031_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_b39965a571708a09 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_b39965a571708a09 ?character ?from))
        (shared_p_consensus_b39965a571708a09 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_kneel
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (shared_p_consensus_b39965a571708a09 ?character tiny_stories__story_031_o_old-house)
      )
    :effect
      (tiny_stories__story_031_p_kneel ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_try
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_kneel ?character)
      )
    :effect
      (tiny_stories__story_031_p_tried ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_evaluate
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_tried ?character)
      )
    :effect
      (tiny_stories__story_031_p_voice-happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_reward
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_voice-happy ?character)
      )
    :effect
      (tiny_stories__story_031_p_rewarded ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_take-skin
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (and
          (not (tiny_stories__story_031_p_voice-happy ?character))
          (tiny_stories__story_031_p_has-skin ?character)
        )
      )
    :effect
      (not (tiny_stories__story_031_p_has-skin ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (shared_p_consensus_b39965a571708a09 ?character ?place))
      )
    :effect
      (shared_p_consensus_b39965a571708a09 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )
)
