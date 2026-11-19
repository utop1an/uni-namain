(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (shared_p_consensus_ba1ecf4964a0fe18 ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_happy ?v0 - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
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
          (shared_p_consensus_ba1ecf4964a0fe18 ?interrogator ?location)
          (shared_p_consensus_ba1ecf4964a0fe18 ?interrogated ?location)
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
          (shared_p_consensus_ba1ecf4964a0fe18 ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (shared_p_consensus_ba1ecf4964a0fe18 ?victim ?placed)
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
          (shared_p_consensus_ba1ecf4964a0fe18 ?saver ?location)
          (shared_p_consensus_ba1ecf4964a0fe18 ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (shared_p_consensus_ba1ecf4964a0fe18 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
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
          (shared_p_consensus_ba1ecf4964a0fe18 ?character ?place)
          (shared_p_consensus_ba1ecf4964a0fe18 ?animal ?place)
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
      (tiny_stories__story_023_p_happy ?character)
    :agents (?character)
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

  (:action fused_a_consensus_7f6e37862b8ee05f
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (human_62959785b3ec220a_active)
          (human_62959785b3ec220a_type_character ?m0)
          (human_62959785b3ec220a_type_location ?m1)
          (human_62959785b3ec220a_type_location ?m2)
          (and
            (human_62959785b3ec220a_p_player ?m0)
            (human_62959785b3ec220a_p_connected ?m1 ?m2)
            (shared_p_consensus_ba1ecf4964a0fe18 ?m0 ?m2)
            (human_62959785b3ec220a_p_knows ?m0)
          )
        )
        (and
          (tiny_stories__story_023_active)
          (tiny_stories__story_023_type_object ?m0)
          (tiny_stories__story_023_type_location ?m2)
          (tiny_stories__story_023_type_location ?m1)
          (and
            (not (= ?m2 ?m1))
            (shared_p_consensus_ba1ecf4964a0fe18 ?m0 ?m2)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ba1ecf4964a0fe18 ?m0 ?m2))
        (shared_p_consensus_ba1ecf4964a0fe18 ?m0 ?m1)
      )
    :agents (?m0)
  )
)
