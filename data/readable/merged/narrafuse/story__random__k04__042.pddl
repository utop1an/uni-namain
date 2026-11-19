(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_happy ?v0 - object)
    (shared_p_consensus_30a6711cec5332d7 ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
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
    (writing_prompts__wp_020_active)
    (writing_prompts__wp_020_type_character ?x - object)
    (writing_prompts__wp_020_type_object ?x - object)
    (writing_prompts__wp_020_p_hurting ?v0 - object)
    (writing_prompts__wp_020_p_struggling ?v0 - object)
    (writing_prompts__wp_020_p_loved ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_letting-go ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_ready ?v0 - object)
    (writing_prompts__wp_020_p_better-times ?v0 - object)
    (writing_prompts__wp_065_active)
    (writing_prompts__wp_065_type_bunker ?x - object)
    (writing_prompts__wp_065_type_character ?x - object)
    (writing_prompts__wp_065_type_god ?x - object)
    (writing_prompts__wp_065_type_object ?x - object)
    (writing_prompts__wp_065_type_place ?x - object)
    (writing_prompts__wp_065_p_in-bunker ?v0 - object ?v1 - object)
    (writing_prompts__wp_065_p_alive ?v0 - object)
    (writing_prompts__wp_065_p_has-followers ?v0 - object)
    (writing_prompts__wp_065_p_launching-bombs ?v0 - object)
    (writing_prompts__wp_065_p_disease-spreading)
    (writing_prompts__wp_065_p_bombs-launched)
  )
  (:axiom :vars (?character - object ?bunker - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (writing_prompts__wp_065_type_bunker ?bunker) (and (writing_prompts__wp_065_p_in-bunker ?character ?bunker) (writing_prompts__wp_065_p_disease-spreading))) :implies (not (writing_prompts__wp_065_p_alive ?character)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (and (writing_prompts__wp_065_p_bombs-launched) (forall (?bunker - object) (or (not (writing_prompts__wp_065_type_bunker ?bunker)) (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker)))))) :implies (not (writing_prompts__wp_065_p_alive ?character)))

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_has ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_30a6711cec5332d7 ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (tiny_stories__story_060_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (shared_p_consensus_30a6711cec5332d7 ?character ?place))
      )
    :effect
      (shared_p_consensus_30a6711cec5332d7 ?character ?place)
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

  (:action writing_prompts__wp_020_a_acknowledge-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character)
        (and
          (writing_prompts__wp_020_p_hurting ?character)
          (writing_prompts__wp_020_p_struggling ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_020_p_struggling ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_020_a_let-go
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character1)
        (writing_prompts__wp_020_type_character ?character2)
        (and
          (writing_prompts__wp_020_p_loved ?character1 ?character2)
          (not (writing_prompts__wp_020_p_ready ?character2))
        )
      )
    :effect
      (writing_prompts__wp_020_p_letting-go ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_020_a_believe-in-better-times
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character)
        (writing_prompts__wp_020_p_hurting ?character)
      )
    :effect
      (writing_prompts__wp_020_p_better-times ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_enter-bunker
    :parameters (?character - object ?bunker - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (writing_prompts__wp_065_type_bunker ?bunker)
        (and
          (writing_prompts__wp_065_p_alive ?character)
          (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker))
        )
      )
    :effect
      (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_launch-bombs
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (and
          (writing_prompts__wp_065_p_alive ?character)
          (exists
            (?bunker - object)
            (and
              (writing_prompts__wp_065_type_bunker ?bunker)
              (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_launching-bombs ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_spread-disease
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (not (writing_prompts__wp_065_p_disease-spreading))
      )
    :effect
      (writing_prompts__wp_065_p_disease-spreading)
  )

  (:action writing_prompts__wp_065_a_bombs-launched
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (exists
          (?character - object)
          (and
            (writing_prompts__wp_065_type_character ?character)
            (writing_prompts__wp_065_p_launching-bombs ?character)
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_bombs-launched)
  )
)
