(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object writing_prompts__wp_054_o_crucifix - object writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_046_p_impatient ?v0 - object)
    (shared_p_consensus_784c52d9bc74b816 ?v0 - object ?v1 - object)
    (tiny_stories__story_046_p_on-table ?v0 - object)
    (tiny_stories__story_046_p_smells-nice ?v0 - object)
    (tiny_stories__story_046_p_playing-with-ball ?v0 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (shared_p_consensus_bad974795eb62815 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_8cd1facae5ce6c3e ?v0 - object ?v1 - object)
    (shared_p_consensus_e8b8896763c573ac ?v0 - object)
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
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_784c52d9bc74b816 ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_784c52d9bc74b816 ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_046_a_try-get
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_type_object ?object)
        (and
          (tiny_stories__story_046_p_impatient ?character)
          (tiny_stories__story_046_p_on-table ?object)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_046_p_on-table ?object))
        (shared_p_consensus_784c52d9bc74b816 ?character ?object)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_smell-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (shared_p_consensus_784c52d9bc74b816 ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (tiny_stories__story_046_p_smells-nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_play-with-ball
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (shared_p_consensus_784c52d9bc74b816 ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (tiny_stories__story_046_p_playing-with-ball ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_bad974795eb62815 ?character ?dress)
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
          (not (shared_p_consensus_bad974795eb62815 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (shared_p_consensus_bad974795eb62815 ?character ?new-dress)
      )
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_bad974795eb62815 ?character ?object)
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
          (shared_p_consensus_bad974795eb62815 ?character ?object)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?from)
          (shared_p_consensus_bad974795eb62815 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8cd1facae5ce6c3e ?character ?from))
        (shared_p_consensus_8cd1facae5ce6c3e ?character ?to)
        (not (shared_p_consensus_bad974795eb62815 ?character ?object))
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_784c52d9bc74b816 ?character ?item)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?place)
          (shared_p_consensus_784c52d9bc74b816 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_784c52d9bc74b816 ?character ?item))
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
          (shared_p_consensus_8cd1facae5ce6c3e ?killer ?place)
          (shared_p_consensus_784c52d9bc74b816 ?killer ?weapon)
          (shared_p_consensus_e8b8896763c573ac ?victim)
          (shared_p_consensus_8cd1facae5ce6c3e ?victim ?place)
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
          (shared_p_consensus_8cd1facae5ce6c3e ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8cd1facae5ce6c3e ?character ?from))
        (shared_p_consensus_8cd1facae5ce6c3e ?character ?to)
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
