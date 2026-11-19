(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (tiny_stories__story_085_p_broken ?v0 - object)
    (tiny_stories__story_085_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_apologized ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_cleaned ?v0 - object)
    (tiny_stories__story_085_p_forgiven ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (writing_prompts__wp_081_p_alive ?v0 - object)
    (writing_prompts__wp_081_p_has-emotion ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_p_knows-change ?v0 - object)
    (writing_prompts__wp_081_p_memorize ?v0 - object)
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

  (:action tiny_stories__story_085_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?character)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_playing ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_085_a_break-item
    :parameters (?breaker - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?breaker)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_playing ?breaker ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_broken ?item)
    :agents (?breaker)
  )

  (:action tiny_stories__story_085_a_apologize
    :parameters (?apologizer - object ?apologizee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?apologizer)
        (tiny_stories__story_085_type_character ?apologizee)
        (not (= ?apologizer ?apologizee))
      )
    :effect
      (tiny_stories__story_085_p_apologized ?apologizer ?apologizee)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_085_a_clean
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?cleaner)
        (tiny_stories__story_085_type_item ?item)
        (tiny_stories__story_085_p_broken ?item)
      )
    :effect
      (tiny_stories__story_085_p_cleaned ?cleaner)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_085_a_forgive
    :parameters (?forgiver - object ?forgivee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?forgiver)
        (tiny_stories__story_085_type_character ?forgivee)
        (and
          (not (= ?forgiver ?forgivee))
          (tiny_stories__story_085_p_apologized ?forgivee ?forgiver)
        )
      )
    :effect
      (tiny_stories__story_085_p_forgiven ?forgiver ?forgivee)
    :agents (?forgiver)
  )

  (:action writing_prompts__wp_081_a_experience-emotion
    :parameters (?character - object ?emotion - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_type_emotion ?emotion)
        (writing_prompts__wp_081_p_alive ?character)
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
        (writing_prompts__wp_081_p_alive ?character)
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
          (writing_prompts__wp_081_p_alive ?character)
          (writing_prompts__wp_081_p_knows-change ?character)
        )
      )
    :effect
      (writing_prompts__wp_081_p_memorize ?character)
    :agents (?character)
  )
)
