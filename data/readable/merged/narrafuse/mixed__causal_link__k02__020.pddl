(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (shared_p_consensus_95acac710d37a5ac ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_065_active)
    (tiny_stories__story_065_type_character ?x - object)
    (tiny_stories__story_065_type_object ?x - object)
    (tiny_stories__story_065_p_hurt ?v0 - object)
    (tiny_stories__story_065_p_touching ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_scared ?v0 - object)
    (tiny_stories__story_065_p_hugging ?v0 - object ?v1 - object)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (shared_p_consensus_95acac710d37a5ac ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_95acac710d37a5ac ?character ?from))
        (shared_p_consensus_95acac710d37a5ac ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (shared_p_consensus_95acac710d37a5ac ?interrogator ?location)
          (shared_p_consensus_95acac710d37a5ac ?interrogated ?location)
          (human_87bbd0acdf4611c5_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_87bbd0acdf4611c5_p_knows ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (human_87bbd0acdf4611c5_p_henchman ?placer)
          (human_87bbd0acdf4611c5_p_has ?placer ?victim)
          (shared_p_consensus_95acac710d37a5ac ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (shared_p_consensus_95acac710d37a5ac ?victim ?placed)
        (human_87bbd0acdf4611c5_p_captured ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (shared_p_consensus_95acac710d37a5ac ?saver ?location)
          (shared_p_consensus_95acac710d37a5ac ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (shared_p_consensus_95acac710d37a5ac ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )

  (:action tiny_stories__story_065_a_move
    :parameters (?character - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (shared_p_consensus_95acac710d37a5ac ?character ?location))
          (not (tiny_stories__story_065_p_scared ?character))
        )
      )
    :effect
      (shared_p_consensus_95acac710d37a5ac ?character ?location)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_touch
    :parameters (?character - object ?object - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_touching ?character ?object))
          (shared_p_consensus_95acac710d37a5ac ?character ?location)
        )
      )
    :effect
      (tiny_stories__story_065_p_touching ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-touching
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_p_touching ?character ?object)
      )
    :effect
      (not (tiny_stories__story_065_p_touching ?character ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-hurt
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_hurt ?character))
      )
    :effect
      (tiny_stories__story_065_p_hurt ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_scared ?character))
      )
    :effect
      (tiny_stories__story_065_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_065_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (and
          (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
          (not (tiny_stories__story_065_p_hugging ?character2 ?character1))
        )
      )
    :effect
      (tiny_stories__story_065_p_hugging ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_065_a_stop-hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (tiny_stories__story_065_p_hugging ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
    :agents (?character1 ?character2)
  )
)
