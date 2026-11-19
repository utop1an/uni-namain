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
    (shared_p_consensus_9600d72627dd922b ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (human_67ab241b327ccef0_p_has ?v0 - object ?v1 - object)
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
          (shared_p_consensus_9600d72627dd922b ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9600d72627dd922b ?character ?from))
        (shared_p_consensus_9600d72627dd922b ?character ?to)
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
          (shared_p_consensus_9600d72627dd922b ?interrogator ?location)
          (shared_p_consensus_9600d72627dd922b ?interrogated ?location)
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
          (shared_p_consensus_9600d72627dd922b ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (shared_p_consensus_9600d72627dd922b ?victim ?placed)
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
          (shared_p_consensus_9600d72627dd922b ?saver ?location)
          (shared_p_consensus_9600d72627dd922b ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (shared_p_consensus_9600d72627dd922b ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
  )

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_9600d72627dd922b ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9600d72627dd922b ?character ?roomfrom))
        (shared_p_consensus_9600d72627dd922b ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_9600d72627dd922b ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (human_67ab241b327ccef0_p_has ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (human_67ab241b327ccef0_p_has ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
  )
)
