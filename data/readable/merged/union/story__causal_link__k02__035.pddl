(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (tiny_stories__story_089_p_playing ?v0 - object)
    (tiny_stories__story_089_p_tired ?v0 - object)
    (tiny_stories__story_089_p_sleeping ?v0 - object)
    (tiny_stories__story_089_p_awake ?v0 - object)
    (tiny_stories__story_089_p_has-energy ?v0 - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_has-device ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
  )

  (:action tiny_stories__story_089_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_awake ?character)
          (not (tiny_stories__story_089_p_playing ?character))
          (tiny_stories__story_089_p_has-energy ?character)
        )
      )
    :effect
      (tiny_stories__story_089_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_playing ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_playing ?character))
        (tiny_stories__story_089_p_tired ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (tiny_stories__story_089_p_tired ?character)
          (not (tiny_stories__story_089_p_sleeping ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_089_p_awake ?character))
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_089_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (tiny_stories__story_089_p_sleeping ?character)
      )
    :effect
      (and
        (tiny_stories__story_089_p_awake ?character)
        (not (tiny_stories__story_089_p_sleeping ?character))
        (not (tiny_stories__story_089_p_tired ?character))
        (tiny_stories__story_089_p_has-energy ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (not (writing_prompts__wp_085_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_085_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_put-on-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (not (writing_prompts__wp_085_p_wearing-clothes ?character))
        )
      )
    :effect
      (writing_prompts__wp_085_p_wearing-clothes ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_turn-on-device
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_has-device ?character ?device)
          (not (writing_prompts__wp_085_p_device-on ?device))
        )
      )
    :effect
      (writing_prompts__wp_085_p_device-on ?device)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_check-connectivity
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_device-on ?device)
          (writing_prompts__wp_085_p_has-device ?character ?device)
        )
      )
    :effect
      (when
        (writing_prompts__wp_085_p_device-connected ?device)
        (writing_prompts__wp_085_p_working ?device)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_go-outside
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_place ?place)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_wearing-clothes ?character)
          (writing_prompts__wp_085_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_085_p_at ?character ?place))
        (writing_prompts__wp_085_p_at ?character writing_prompts__wp_085_o_outside)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_talk
    :parameters (?speaker - object ?listener - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?speaker)
        (writing_prompts__wp_085_type_character ?listener)
        (and
          (writing_prompts__wp_085_p_awake ?speaker)
          (writing_prompts__wp_085_p_awake ?listener)
          (writing_prompts__wp_085_p_at ?speaker writing_prompts__wp_085_o_outside)
          (writing_prompts__wp_085_p_at ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :agents (?speaker ?listener)
  )

  (:action writing_prompts__wp_085_a_cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (writing_prompts__wp_085_p_school-canceled))
      )
    :effect
      (writing_prompts__wp_085_p_school-canceled)
  )
)
