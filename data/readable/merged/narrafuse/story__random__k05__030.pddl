(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (shared_p_consensus_0002264453d1d889 ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (shared_p_consensus_05c47f86c1b9dc6a ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (shared_p_consensus_990b0e2d04db33c7 ?v0 - object)
    (tiny_stories__story_041_active)
    (tiny_stories__story_041_type_character ?x - object)
    (tiny_stories__story_041_type_object ?x - object)
    (tiny_stories__story_041_p_kind ?v0 - object)
    (tiny_stories__story_041_p_knows-wisdom ?v0 - object)
    (tiny_stories__story_041_p_lost ?v0 - object)
    (tiny_stories__story_041_p_found ?v0 - object)
    (tiny_stories__story_073_active)
    (tiny_stories__story_073_type_character ?x - object)
    (tiny_stories__story_073_type_object ?x - object)
    (tiny_stories__story_073_p_play-chess ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_feel-better ?v0 - object)
    (tiny_stories__story_073_p_sit-together ?v0 - object ?v1 - object)
    (tiny_stories__story_073_p_sick ?v0 - object)
    (shared_p_consensus_fb6e2f31d73e13a3 ?v0 - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (shared_p_consensus_05c47f86c1b9dc6a ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (shared_p_consensus_990b0e2d04db33c7 ?character)
      )
    :effect
      (shared_p_consensus_0002264453d1d889 ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_0002264453d1d889 ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (shared_p_consensus_990b0e2d04db33c7 ?character1)
          (shared_p_consensus_990b0e2d04db33c7 ?character2)
          (shared_p_consensus_05c47f86c1b9dc6a ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_041_a_become-kind
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?character)
        (not (tiny_stories__story_041_p_kind ?character))
      )
    :effect
      (tiny_stories__story_041_p_kind ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_041_a_learn-wisdom
    :parameters (?learner - object ?teacher - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?learner)
        (tiny_stories__story_041_type_character ?teacher)
        (and
          (not (tiny_stories__story_041_p_knows-wisdom ?learner))
          (tiny_stories__story_041_p_knows-wisdom ?teacher)
        )
      )
    :effect
      (tiny_stories__story_041_p_knows-wisdom ?learner)
    :agents (?learner ?teacher)
  )

  (:action tiny_stories__story_041_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?helper)
        (tiny_stories__story_041_type_character ?helpee)
        (and
          (tiny_stories__story_041_p_kind ?helper)
          (tiny_stories__story_041_p_lost ?helpee)
        )
      )
    :effect
      (tiny_stories__story_041_p_found ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_041_a_become-friends
    :parameters (?c1 - object ?c2 - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?c1)
        (tiny_stories__story_041_type_character ?c2)
        (and
          (not (shared_p_consensus_05c47f86c1b9dc6a ?c1 ?c2))
          (not (= ?c1 ?c2))
        )
      )
    :effect
      (shared_p_consensus_05c47f86c1b9dc6a ?c1 ?c2)
    :agents (?c1 ?c2)
  )

  (:action tiny_stories__story_073_a_play-chess
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (and
          (not (tiny_stories__story_073_p_sick ?character1))
          (not (tiny_stories__story_073_p_sick ?character2))
          (not (= ?character1 ?character2))
          (tiny_stories__story_073_p_sit-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_073_p_play-chess ?character1 ?character2)
        (shared_p_consensus_fb6e2f31d73e13a3 ?character1)
        (shared_p_consensus_fb6e2f31d73e13a3 ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_073_a_get-sick
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
      )
    :effect
      (tiny_stories__story_073_p_sick ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_feel-better
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character)
        (tiny_stories__story_073_p_sick ?character)
      )
    :effect
      (not (tiny_stories__story_073_p_sick ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_073_a_sit-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_073_active)
        (tiny_stories__story_073_type_character ?character1)
        (tiny_stories__story_073_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_073_p_sit-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_100_a_start-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_bored ?character)
          (not (tiny_stories__story_100_p_rolling ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_bored ?character))
        (tiny_stories__story_100_p_rolling ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_stop-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_rolling ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_rolling ?character))
        (tiny_stories__story_100_p_dizzy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_lie-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_dizzy ?character)
          (not (tiny_stories__story_100_p_lying-down ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_dizzy ?character))
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_get-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_lying-down ?character))
        (shared_p_consensus_fb6e2f31d73e13a3 ?character)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_0002264453d1d889 ?character ?object)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (shared_p_consensus_0002264453d1d889 ?character ?object)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
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
          (shared_p_consensus_990b0e2d04db33c7 ?character)
          (writing_prompts__wp_011_p_at ?character ?from)
          (shared_p_consensus_0002264453d1d889 ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_011_p_at ?character ?from))
        (writing_prompts__wp_011_p_at ?character ?to)
        (not (shared_p_consensus_0002264453d1d889 ?character ?object))
      )
    :agents (?character)
  )
)
