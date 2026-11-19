(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_38198a30be4e025e ?v0 - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_041_active)
    (tiny_stories__story_041_type_character ?x - object)
    (tiny_stories__story_041_type_object ?x - object)
    (shared_p_consensus_b0e4aafa1ac51551 ?v0 - object ?v1 - object)
    (tiny_stories__story_041_p_kind ?v0 - object)
    (tiny_stories__story_041_p_knows-wisdom ?v0 - object)
    (tiny_stories__story_041_p_lost ?v0 - object)
    (tiny_stories__story_041_p_found ?v0 - object)
    (tiny_stories__story_042_active)
    (tiny_stories__story_042_type_character ?x - object)
    (tiny_stories__story_042_type_object ?x - object)
    (tiny_stories__story_042_p_at-carnival ?v0 - object)
    (tiny_stories__story_042_p_wants-to-play ?v0 - object)
    (tiny_stories__story_042_p_played ?v0 - object)
    (tiny_stories__story_042_p_weight-too-low ?v0 - object)
    (tiny_stories__story_042_p_upset ?v0 - object)
    (tiny_stories__story_042_p_comforted ?v0 - object)
    (tiny_stories__story_097_active)
    (tiny_stories__story_097_type_character ?x - object)
    (tiny_stories__story_097_type_object ?x - object)
    (tiny_stories__story_097_p_sad ?v0 - object)
    (tiny_stories__story_097_p_ready ?v0 - object)
    (tiny_stories__story_097_p_practice ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_023_a_play
    :parameters (?character - object ?animal - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_type_location ?place)
        (and
          (tiny_stories__story_023_p_at ?character ?place)
          (tiny_stories__story_023_p_at ?animal ?place)
        )
      )
    :effect
      (tiny_stories__story_023_p_playing ?character ?animal)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_stop-playing
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_p_playing ?character ?animal)
      )
    :effect
      (not (tiny_stories__story_023_p_playing ?character ?animal))
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (shared_p_consensus_38198a30be4e025e ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_move
    :parameters (?object - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_object ?object)
        (tiny_stories__story_023_type_location ?from)
        (tiny_stories__story_023_type_location ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_023_p_at ?object ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_023_p_at ?object ?from))
        (tiny_stories__story_023_p_at ?object ?to)
      )
    :agents (?object)
  )

  (:action tiny_stories__story_023_a_can-run
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_can-run ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_can-fly
    :parameters (?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_animal ?animal)
      )
    :effect
      (tiny_stories__story_023_p_can-fly ?animal)
    :agents (?animal)
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

  (:action tiny_stories__story_042_a_go-to-carnival
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
      )
    :effect
      (tiny_stories__story_042_p_at-carnival ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_want-to-play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_at-carnival ?character)
      )
    :effect
      (tiny_stories__story_042_p_wants-to-play ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (and
          (tiny_stories__story_042_p_at-carnival ?character)
          (tiny_stories__story_042_p_wants-to-play ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_042_p_played ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_become-upset
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :effect
      (tiny_stories__story_042_p_upset ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_comfort
    :parameters (?comforter - object ?comforted - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?comforter)
        (tiny_stories__story_042_type_character ?comforted)
        (and
          (not (= ?comforter ?comforted))
          (tiny_stories__story_042_p_upset ?comforted)
        )
      )
    :effect
      (tiny_stories__story_042_p_comforted ?comforted)
    :agents (?comforter)
  )

  (:action tiny_stories__story_097_a_cheer-up
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_b0e4aafa1ac51551 ?character1 ?character2)
          (tiny_stories__story_097_p_sad ?character2)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_097_p_sad ?character2))
        (shared_p_consensus_38198a30be4e025e ?character2)
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_097_a_help-practice
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_b0e4aafa1ac51551 ?character1 ?character2)
          (not (tiny_stories__story_097_p_ready ?character2))
        )
      )
    :effect
      (tiny_stories__story_097_p_practice ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_097_a_become-ready
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character)
        (exists
          (?helper - object)
          (and
            (tiny_stories__story_097_type_character ?helper)
            (tiny_stories__story_097_p_practice ?helper ?character)
          )
        )
      )
    :effect
      (tiny_stories__story_097_p_ready ?character)
    :agents (?character)
  )

  (:action fused_a_consensus_7a5fb071d929fe54
    :parameters (?m0 - object ?m1 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_041_active)
          (tiny_stories__story_041_type_character ?m0)
          (tiny_stories__story_041_type_character ?m1)
          (and
            (not (shared_p_consensus_b0e4aafa1ac51551 ?m0 ?m1))
            (not (= ?m0 ?m1))
          )
        )
        (and
          (tiny_stories__story_097_active)
          (tiny_stories__story_097_type_character ?m0)
          (tiny_stories__story_097_type_character ?m1)
          (not (= ?m0 ?m1))
        )
      )
    :effect
      (shared_p_consensus_b0e4aafa1ac51551 ?m0 ?m1)
    :agents (?m0 ?m1)
  )
)
