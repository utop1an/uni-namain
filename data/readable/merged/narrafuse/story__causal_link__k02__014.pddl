(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_087_active)
    (tiny_stories__story_087_type_character ?x - object)
    (tiny_stories__story_087_type_object ?x - object)
    (tiny_stories__story_087_p_happy ?v0 - object)
    (tiny_stories__story_087_p_party-prepared ?v0 - object)
    (tiny_stories__story_087_p_has-balloons)
    (tiny_stories__story_087_p_has-cake)
    (tiny_stories__story_087_p_has-present ?v0 - object)
    (tiny_stories__story_087_p_played-games)
    (tiny_stories__story_087_p_thanked-parents ?v0 - object)
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_009_p_alive ?v0 - object)
    (writing_prompts__wp_009_p_spirits-present ?v0 - object)
    (writing_prompts__wp_009_p_spirits-gone ?v0 - object)
    (writing_prompts__wp_009_p_weak ?v0 - object)
    (writing_prompts__wp_009_p_love-driven-away ?v0 - object)
    (writing_prompts__wp_009_p_in-asylum ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (tiny_stories__story_087_active) (tiny_stories__story_087_type_character ?character) (and (not (tiny_stories__story_087_p_happy ?character)) (tiny_stories__story_087_p_party-prepared ?character) (tiny_stories__story_087_p_has-balloons) (tiny_stories__story_087_p_has-cake) (tiny_stories__story_087_p_played-games) (tiny_stories__story_087_p_has-present ?character) (tiny_stories__story_087_p_thanked-parents ?character))) :implies (tiny_stories__story_087_p_happy ?character))

  (:action tiny_stories__story_087_a_prepare-party
    :parameters (?preparer - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?preparer)
        (tiny_stories__story_087_type_character ?receiver)
        (not (tiny_stories__story_087_p_party-prepared ?receiver))
      )
    :effect
      (tiny_stories__story_087_p_party-prepared ?receiver)
    :agents (?preparer ?receiver)
  )

  (:action tiny_stories__story_087_a_decorate-with-balloons
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_has-balloons))
          (tiny_stories__story_087_p_party-prepared ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-balloons)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_prepare-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_has-cake))
          (tiny_stories__story_087_p_party-prepared ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-cake)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_play-games
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (tiny_stories__story_087_p_party-prepared ?character)
      )
    :effect
      (tiny_stories__story_087_p_played-games)
    :agents (?character)
  )

  (:action tiny_stories__story_087_a_give-present
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?giver)
        (tiny_stories__story_087_type_character ?receiver)
        (and
          (not (tiny_stories__story_087_p_has-present ?receiver))
          (tiny_stories__story_087_p_party-prepared ?receiver)
        )
      )
    :effect
      (tiny_stories__story_087_p_has-present ?receiver)
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_087_a_thank-parents
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_087_active)
        (tiny_stories__story_087_type_character ?character)
        (and
          (not (tiny_stories__story_087_p_thanked-parents ?character))
          (tiny_stories__story_087_p_has-present ?character)
        )
      )
    :effect
      (tiny_stories__story_087_p_thanked-parents ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_become-weak
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_weak ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_drive-away-love
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_love-driven-away ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_end-up-in-asylum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_in-asylum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_ask-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (and
        (writing_prompts__wp_009_p_spirits-gone ?character)
        (not (writing_prompts__wp_009_p_spirits-present ?character))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_regret-asking-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-gone ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_spirits-present ?character)
    :agents (?character)
  )
)
