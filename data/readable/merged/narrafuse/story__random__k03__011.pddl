(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_018_active)
    (tiny_stories__story_018_type_character ?x - object)
    (tiny_stories__story_018_type_item ?x - object)
    (tiny_stories__story_018_type_object ?x - object)
    (tiny_stories__story_018_type_place ?x - object)
    (shared_p_consensus_2ad87e4bcc535172 ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_open ?v0 - object)
    (tiny_stories__story_018_p_stored ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (writing_prompts__wp_042_p_alive ?v0 - object)
    (writing_prompts__wp_042_p_drunk ?v0 - object)
    (shared_p_consensus_5d66a2e90ca48301 ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_night-show ?v0 - object)
    (writing_prompts__wp_042_p_vomit-stain ?v0 - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
  )

  (:action tiny_stories__story_018_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_place ?place)
        (shared_p_consensus_2ad87e4bcc535172 ?character ?place)
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (tiny_stories__story_018_type_item ?item)
            (tiny_stories__story_018_p_hidden ?item ?place)
          )
          (tiny_stories__story_018_p_found ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (not (tiny_stories__story_018_p_open ?item))
        )
      )
    :effect
      (tiny_stories__story_018_p_open ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_store
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (tiny_stories__story_018_type_place ?place)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (tiny_stories__story_018_p_open ?item)
          (shared_p_consensus_2ad87e4bcc535172 ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_018_p_stored ?item ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_drink
    :parameters (?character - object ?drink - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_drink ?drink)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (shared_p_consensus_5d66a2e90ca48301 ?character ?drink)
        )
      )
    :effect
      (and
        (writing_prompts__wp_042_p_drunk ?character)
        (not (shared_p_consensus_5d66a2e90ca48301 ?character ?drink))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (not (shared_p_consensus_2ad87e4bcc535172 ?character ?place))
        )
      )
    :effect
      (shared_p_consensus_2ad87e4bcc535172 ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_vomit
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (shared_p_consensus_2ad87e4bcc535172 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_042_p_vomit-stain ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_sober-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_p_drunk ?character)
      )
    :effect
      (not (writing_prompts__wp_042_p_drunk ?character))
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
          (shared_p_consensus_5d66a2e90ca48301 ?character ?device)
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
          (shared_p_consensus_5d66a2e90ca48301 ?character ?device)
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
