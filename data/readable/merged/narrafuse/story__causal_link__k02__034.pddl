(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_71387248e31cf14b ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (tiny_stories__story_089_p_playing ?v0 - object)
    (tiny_stories__story_089_p_tired ?v0 - object)
    (tiny_stories__story_089_p_sleeping ?v0 - object)
    (tiny_stories__story_089_p_has-energy ?v0 - object)
  )

  (:action tiny_stories__story_011_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (shared_p_consensus_71387248e31cf14b ?character)
          (not (tiny_stories__story_011_p_at ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_011_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sleep
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (shared_p_consensus_71387248e31cf14b ?character)
          (tiny_stories__story_011_p_at ?character ?place)
          (tiny_stories__story_011_p_interesting ?place)
        )
      )
    :effect
      (not (shared_p_consensus_71387248e31cf14b ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (not (shared_p_consensus_71387248e31cf14b ?character))
      )
    :effect
      (shared_p_consensus_71387248e31cf14b ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (shared_p_consensus_71387248e31cf14b ?character)
      )
    :effect
      (tiny_stories__story_011_p_singing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_stop-singing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_singing ?character)
      )
    :effect
      (not (tiny_stories__story_011_p_singing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character1)
        (tiny_stories__story_011_type_character ?character2)
        (and
          (shared_p_consensus_71387248e31cf14b ?character1)
          (shared_p_consensus_71387248e31cf14b ?character2)
          (not (tiny_stories__story_011_p_friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_011_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_089_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_089_active)
        (tiny_stories__story_089_type_character ?character)
        (and
          (shared_p_consensus_71387248e31cf14b ?character)
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
        (not (shared_p_consensus_71387248e31cf14b ?character))
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
        (shared_p_consensus_71387248e31cf14b ?character)
        (not (tiny_stories__story_089_p_sleeping ?character))
        (not (tiny_stories__story_089_p_tired ?character))
        (tiny_stories__story_089_p_has-energy ?character)
      )
    :agents (?character)
  )
)
