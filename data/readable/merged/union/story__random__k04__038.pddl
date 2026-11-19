(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_050_p_playing-with-toys ?v0 - object)
    (tiny_stories__story_050_p_found-blocks ?v0 - object)
    (tiny_stories__story_050_p_stacking-blocks ?v0 - object)
    (tiny_stories__story_050_p_stack-tall ?v0 - object)
    (tiny_stories__story_050_p_stack-strong ?v0 - object)
    (tiny_stories__story_050_p_happy ?v0 - object)
    (tiny_stories__story_050_p_helping ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_059_active)
    (writing_prompts__wp_059_type_character ?x - object)
    (writing_prompts__wp_059_type_object ?x - object)
    (writing_prompts__wp_059_p_friend ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_needs-help ?v0 - object)
    (writing_prompts__wp_059_p_smiling ?v0 - object)
    (writing_prompts__wp_059_p_laughing ?v0 - object)
    (writing_prompts__wp_059_p_provides-help ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_talks-to ?v0 - object ?v1 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (writing_prompts__wp_056_p_has ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (writing_prompts__wp_056_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

  (:action tiny_stories__story_050_a_play-with-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
      )
    :effect
      (tiny_stories__story_050_p_playing-with-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_find-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_playing-with-toys ?character)
      )
    :effect
      (tiny_stories__story_050_p_found-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_stack-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_found-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stacking-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_make-stack-tall
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stacking-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stack-tall ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?helper)
        (tiny_stories__story_050_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_050_p_stack-tall ?helpee)
        )
      )
    :effect
      (tiny_stories__story_050_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_050_a_make-stack-strong
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (and
          (tiny_stories__story_050_p_stack-tall ?character)
          (tiny_stories__story_050_p_helping ?character ?character)
        )
      )
    :effect
      (tiny_stories__story_050_p_stack-strong ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stack-strong ?character)
      )
    :effect
      (tiny_stories__story_050_p_happy ?character)
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

  (:action writing_prompts__wp_059_a_talk
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_talks-to ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_provide-help
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
          (writing_prompts__wp_059_p_needs-help ?b)
          (writing_prompts__wp_059_p_talks-to ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_provides-help ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_start-smiling
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_smiling ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_smiling ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_059_a_start-laughing
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_laughing ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_laughing ?character)
    :agents (?character)
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
