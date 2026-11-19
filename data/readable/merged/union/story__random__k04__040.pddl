(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_053_o_spade - object tiny_stories__story_053_o_small-box - object writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_053_active)
    (tiny_stories__story_053_type_character ?x - object)
    (tiny_stories__story_053_type_item ?x - object)
    (tiny_stories__story_053_type_object ?x - object)
    (tiny_stories__story_053_type_place ?x - object)
    (tiny_stories__story_053_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_digging ?v0 - object)
    (tiny_stories__story_053_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_opened ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_playing ?v0 - object)
    (writing_prompts__wp_056_active)
    (writing_prompts__wp_056_type_character ?x - object)
    (writing_prompts__wp_056_type_item ?x - object)
    (writing_prompts__wp_056_type_object ?x - object)
    (writing_prompts__wp_056_type_side ?x - object)
    (writing_prompts__wp_056_type_weapon ?x - object)
    (writing_prompts__wp_056_p_alive ?v0 - object)
    (writing_prompts__wp_056_p_armed ?v0 - object)
    (writing_prompts__wp_056_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_fights-for ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_in-formation ?v0 - object)
    (writing_prompts__wp_056_p_eyes-glow-red ?v0 - object)
    (writing_prompts__wp_056_p_damaged ?v0 - object)
    (writing_prompts__wp_056_p_aware ?v0 - object)
    (writing_prompts__wp_083_active)
    (writing_prompts__wp_083_type_character ?x - object)
    (writing_prompts__wp_083_type_object ?x - object)
    (writing_prompts__wp_083_type_place ?x - object)
    (writing_prompts__wp_083_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_betrayed ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_peace ?v0 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (writing_prompts__wp_056_p_has ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (writing_prompts__wp_056_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

  (:action tiny_stories__story_053_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_place ?place)
        (and
          (not (tiny_stories__story_053_p_at ?character ?place))
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
        )
      )
    :effect
      (tiny_stories__story_053_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_dig
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (and
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
          (not (tiny_stories__story_053_p_digging ?character))
        )
      )
    :effect
      (tiny_stories__story_053_p_digging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_digging ?character)
          (not (tiny_stories__story_053_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_053_p_found ?character ?item)
        (tiny_stories__story_053_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_found ?character ?item)
          (not (tiny_stories__story_053_p_opened ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_053_p_opened ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_p_opened ?character tiny_stories__story_053_o_small-box)
      )
    :effect
      (tiny_stories__story_053_p_playing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_fire
    :parameters (?shooter - object ?target - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?shooter)
        (writing_prompts__wp_056_type_character ?target)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (not (= ?shooter ?target))
          (writing_prompts__wp_056_p_alive ?shooter)
          (writing_prompts__wp_056_p_armed ?shooter)
          (writing_prompts__wp_056_p_has ?shooter ?weapon)
          (writing_prompts__wp_056_p_alive ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_056_p_alive ?target))
        (intends ?shooter (not (writing_prompts__wp_056_p_alive ?target)))
      )
    :agents (?shooter)
  )

  (:action writing_prompts__wp_056_a_damage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_damaged ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_damaged ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_aware ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_aware ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_suicide
    :parameters (?character - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (writing_prompts__wp_056_p_armed ?character)
          (writing_prompts__wp_056_p_has ?character ?weapon)
          (writing_prompts__wp_056_p_aware ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_056_p_alive ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_083_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_friends ?character1 ?character2))
        )
      )
    :effect
      (writing_prompts__wp_083_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_083_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_in-love ?character1 ?character2))
          (writing_prompts__wp_083_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_083_a_betray
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_in-love ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_redeem
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_083_p_betrayed ?character1 ?character2))
        (writing_prompts__wp_083_p_in-love ?character1 ?character2)
      )
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_bring-peace
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character)
        (writing_prompts__wp_083_type_place ?place)
        (and
          (not (writing_prompts__wp_083_p_peace ?place))
          (exists
            (?character2 - object)
            (and
              (writing_prompts__wp_083_type_character ?character2)
              (writing_prompts__wp_083_p_in-love ?character ?character2)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_083_p_peace ?place)
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
