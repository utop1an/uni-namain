(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_005_o_tim - object)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (shared_p_consensus_af8f747d589b668c ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (shared_p_consensus_47cc9cce106cb86e ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_005_active)
    (tiny_stories__story_005_type_character ?x - object)
    (tiny_stories__story_005_type_object ?x - object)
    (tiny_stories__story_005_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_shaking-tree ?v0 - object)
    (tiny_stories__story_005_p_wind-blows)
  )

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (shared_p_consensus_af8f747d589b668c ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_af8f747d589b668c ?character ?from))
        (shared_p_consensus_af8f747d589b668c ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (shared_p_consensus_af8f747d589b668c ?interrogator ?location)
          (shared_p_consensus_af8f747d589b668c ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (shared_p_consensus_af8f747d589b668c ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (shared_p_consensus_af8f747d589b668c ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (shared_p_consensus_af8f747d589b668c ?saver ?location)
          (shared_p_consensus_af8f747d589b668c ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (shared_p_consensus_af8f747d589b668c ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (shared_p_consensus_47cc9cce106cb86e ?notsaved))
      )
    :agents (?saver)
  )

  (:action tiny_stories__story_005_a_play
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?object)
        (and
          (shared_p_consensus_47cc9cce106cb86e ?character)
          (tiny_stories__story_005_p_has ?character ?object)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_shake-tree
    :parameters (?character - object ?tree - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?tree)
        (and
          (shared_p_consensus_47cc9cce106cb86e ?character)
          (shared_p_consensus_af8f747d589b668c ?character ?tree)
        )
      )
    :effect
      (tiny_stories__story_005_p_shaking-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_stop-shaking-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_p_shaking-tree ?character)
      )
    :effect
      (not (tiny_stories__story_005_p_shaking-tree ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_wind-blows-object
    :parameters (?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_object ?object)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_has tiny_stories__story_005_o_tim ?object))
  )

  (:action tiny_stories__story_005_a_start-wind
    :parameters ()
    :precondition
      (tiny_stories__story_005_active)
    :effect
      (tiny_stories__story_005_p_wind-blows)
  )

  (:action tiny_stories__story_005_a_stop-wind
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_wind-blows))
  )
)
