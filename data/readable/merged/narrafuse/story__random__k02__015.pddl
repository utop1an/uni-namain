(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_048_active)
    (tiny_stories__story_048_type_character ?x - object)
    (tiny_stories__story_048_type_object ?x - object)
    (tiny_stories__story_048_type_place ?x - object)
    (tiny_stories__story_048_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_048_p_dry ?v0 - object)
    (tiny_stories__story_048_p_wet ?v0 - object)
    (tiny_stories__story_048_p_happy ?v0 - object)
    (tiny_stories__story_048_p_sad ?v0 - object)
    (shared_p_consensus_3c19970d791225e8 ?v0 - object ?v1 - object)
    (tiny_stories__story_083_active)
    (tiny_stories__story_083_type_character ?x - object)
    (tiny_stories__story_083_type_object ?x - object)
    (tiny_stories__story_083_p_fierce ?v0 - object)
    (tiny_stories__story_083_p_scared ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_sneezed ?v0 - object)
  )

  (:action tiny_stories__story_048_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?from)
        (tiny_stories__story_048_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_048_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_at ?character ?from))
        (tiny_stories__story_048_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_play
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_dry ?place)
        )
      )
    :effect
      (tiny_stories__story_048_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_dry-place
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (tiny_stories__story_048_p_at ?character ?place)
          (tiny_stories__story_048_p_wet ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_wet ?place))
        (tiny_stories__story_048_p_dry ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_083_a_play
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_3c19970d791225e8 ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_playing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_083_a_sneeze
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character)
      )
    :effect
      (tiny_stories__story_083_p_sneezed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_083_a_become-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_083_p_fierce ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_scared ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_083_a_stop-being-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (tiny_stories__story_083_p_scared ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_083_p_scared ?character1 ?character2))
    :agents (?character1)
  )

  (:action fused_a_consensus_33d89d016c435de9
    :parameters (?m0 - object ?m1 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?m0)
          (tiny_stories__story_048_type_character ?m1)
          (and
            (not (= ?m0 ?m1))
            (tiny_stories__story_048_p_happy ?m0)
            (tiny_stories__story_048_p_happy ?m1)
          )
        )
        (and
          (tiny_stories__story_083_active)
          (tiny_stories__story_083_type_character ?m0)
          (tiny_stories__story_083_type_character ?m1)
          (and
            (not (= ?m0 ?m1))
            (not (shared_p_consensus_3c19970d791225e8 ?m0 ?m1))
          )
        )
      )
    :effect
      (shared_p_consensus_3c19970d791225e8 ?m0 ?m1)
    :agents (?m0 ?m1)
  )
)
