(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_031_o_old-house - object)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_031_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_031_p_has-skin ?v0 - object)
    (tiny_stories__story_031_p_kneel ?v0 - object)
    (tiny_stories__story_031_p_rewarded ?v0 - object)
    (tiny_stories__story_031_p_tried ?v0 - object)
    (tiny_stories__story_031_p_voice-happy ?v0 - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
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
          (tiny_stories__story_031_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_031_p_at ?character ?from))
        (tiny_stories__story_031_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_kneel
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_at ?character tiny_stories__story_031_o_old-house)
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

  (:action tiny_stories__story_072_a_go-to-party
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (not (tiny_stories__story_072_p_at-party ?character))
      )
    :effect
      (tiny_stories__story_072_p_at-party ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_magic-trick
    :parameters (?magician - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?magician)
        (and
          (tiny_stories__story_072_p_at-party ?magician)
          (not (tiny_stories__story_072_p_cake-transformed))
        )
      )
    :effect
      (tiny_stories__story_072_p_cake-transformed)
    :agents (?magician)
  )

  (:action tiny_stories__story_072_a_eat-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_cake-transformed)
        )
      )
    :effect
      (tiny_stories__story_072_p_fast ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_fast ?character)
        )
      )
    :agents (?character)
  )
)
