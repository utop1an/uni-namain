(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (shared_p_consensus_9600d72627dd922b ?v0 - object ?v1 - object)
    (shared_p_consensus_230e936cb4321851 ?v0 - object ?v1 - object)
    (shared_p_consensus_1719447f86a90b85 ?v0 - object ?v1 - object)
    (shared_p_consensus_f68c01c25cae39cf ?v0 - object)
    (shared_p_consensus_17564f47ff2596a8 ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (shared_p_consensus_bcbf21fe0f9f55c1 ?v0 - object)
    (shared_p_consensus_dba043dcf4aed0cc ?v0 - object)
    (shared_p_consensus_e8675832023f971b ?v0 - object)
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (shared_p_consensus_e0fb843b926a896e ?v0 - object)
    (shared_p_consensus_caef1caec545cbba ?v0 - object ?v1 - object)
    (shared_p_consensus_a99b83d6e8676154 ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_804301514d612d1d ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_active)
    (human_72bec7307b121ea5_type_book ?x - object)
    (human_72bec7307b121ea5_type_character ?x - object)
    (human_72bec7307b121ea5_type_item ?x - object)
    (human_72bec7307b121ea5_type_location ?x - object)
    (human_72bec7307b121ea5_type_object ?x - object)
    (human_72bec7307b121ea5_type_ring ?x - object)
    (human_72bec7307b121ea5_type_sword ?x - object)
    (human_72bec7307b121ea5_type_thing ?x - object)
    (human_72bec7307b121ea5_p_player ?v0 - object)
    (shared_p_consensus_0eca8ebcd2897a24 ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_has ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_asleep ?v0 - object)
    (human_72bec7307b121ea5_p_connected ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_enchanted ?v0 - object)
    (human_72bec7307b121ea5_p_is ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_active)
    (human_7c98a61edf861243_type_character ?x - object)
    (human_7c98a61edf861243_type_key ?x - object)
    (human_7c98a61edf861243_type_letter ?x - object)
    (human_7c98a61edf861243_type_object ?x - object)
    (human_7c98a61edf861243_type_room ?x - object)
    (human_7c98a61edf861243_type_star ?x - object)
    (human_7c98a61edf861243_type_thing ?x - object)
    (human_7c98a61edf861243_p_hidden ?v0 - object)
    (human_7c98a61edf861243_p_believes-locked ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-at ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-unlocked-by ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-in ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-hidden ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-has ?v0 - object ?v1 - object ?v2 - object)
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (human_87bbd0acdf4611c5_p_at ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
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
          (shared_p_consensus_1719447f86a90b85 ?to ?from)
          (shared_p_consensus_9600d72627dd922b ?character ?from)
          (shared_p_consensus_bcbf21fe0f9f55c1 ?character)
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
          (shared_p_consensus_f68c01c25cae39cf ?interrogated)
        )
      )
    :effect
      (shared_p_consensus_bcbf21fe0f9f55c1 ?interrogator)
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
          (shared_p_consensus_e8675832023f971b ?placer)
          (shared_p_consensus_230e936cb4321851 ?placer ?victim)
          (shared_p_consensus_9600d72627dd922b ?placer ?location)
          (shared_p_consensus_1719447f86a90b85 ?placed ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_230e936cb4321851 ?placer ?victim))
        (shared_p_consensus_9600d72627dd922b ?victim ?placed)
        (shared_p_consensus_dba043dcf4aed0cc ?victim)
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
          (shared_p_consensus_dba043dcf4aed0cc ?saved)
          (shared_p_consensus_dba043dcf4aed0cc ?notsaved)
          (not (shared_p_consensus_9600d72627dd922b ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (shared_p_consensus_17564f47ff2596a8 ?notsaved))
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
          (not (shared_p_consensus_e0fb843b926a896e ?roomto))
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
          (shared_p_consensus_a99b83d6e8676154 ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_804301514d612d1d ?character ?thing)
        (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
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
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_caef1caec545cbba ?room ?key)
          (shared_p_consensus_804301514d612d1d ?character ?key)
        )
      )
    :effect
      (not (shared_p_consensus_e0fb843b926a896e ?room))
  )

  (:action human_72bec7307b121ea5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?character)
        (human_72bec7307b121ea5_type_location ?to)
        (human_72bec7307b121ea5_type_location ?from)
        (and
          (human_72bec7307b121ea5_p_connected ?to ?from)
          (not (human_72bec7307b121ea5_p_asleep ?character))
          (shared_p_consensus_0eca8ebcd2897a24 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0eca8ebcd2897a24 ?character ?from))
        (shared_p_consensus_0eca8ebcd2897a24 ?character ?to)
      )
    :agents (?character)
  )

  (:action human_72bec7307b121ea5_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?waker)
        (human_72bec7307b121ea5_type_character ?woken)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?waker ?location)
          (shared_p_consensus_0eca8ebcd2897a24 ?woken ?location)
          (human_72bec7307b121ea5_p_asleep ?woken)
          (not (human_72bec7307b121ea5_p_asleep ?waker))
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_asleep ?woken))
    :agents (?waker)
  )

  (:action human_72bec7307b121ea5_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?taker)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?taker ?location)
          (shared_p_consensus_0eca8ebcd2897a24 ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?taker))
          (not (human_72bec7307b121ea5_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0eca8ebcd2897a24 ?thing ?location))
        (human_72bec7307b121ea5_p_has ?taker ?thing)
      )
    :agents (?taker)
  )

  (:action human_72bec7307b121ea5_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?caster)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_book ?book)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?caster ?location)
          (shared_p_consensus_0eca8ebcd2897a24 ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?caster))
          (human_72bec7307b121ea5_p_has ?caster ?book)
          (human_72bec7307b121ea5_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_enchanted ?thing))
    :agents (?caster)
  )

  (:action human_7c98a61edf861243_a_enter-success
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (shared_p_consensus_e0fb843b926a896e ?roomto))
          (shared_p_consensus_0eca8ebcd2897a24 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0eca8ebcd2897a24 ?character ?roomfrom))
        (shared_p_consensus_0eca8ebcd2897a24 ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (shared_p_consensus_0eca8ebcd2897a24 ?char2 ?roomto)
            )
            (and
              (human_7c98a61edf861243_p_believes-at ?character ?char2 ?roomto)
              (human_7c98a61edf861243_p_believes-at ?char2 ?character ?roomto)
            )
          )
        )
        (forall
          (?thing - object)
          (when
            (and
              (human_7c98a61edf861243_type_thing ?thing)
              (and
                (shared_p_consensus_a99b83d6e8676154 ?thing ?roomto)
                (not (human_7c98a61edf861243_p_hidden ?thing))
              )
            )
            (human_7c98a61edf861243_p_believes-in ?character ?thing ?roomto)
          )
        )
        (not (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom))
        (human_7c98a61edf861243_p_believes-at ?character ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_enter-fail
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (and (not (shared_p_consensus_e0fb843b926a896e ?roomto)) (shared_p_consensus_0eca8ebcd2897a24 ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_e0fb843b926a896e ?roomto)
          (shared_p_consensus_0eca8ebcd2897a24 ?character ?roomfrom)
        )
        (human_7c98a61edf861243_p_believes-locked ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_in
    :parameters (?informant - object ?in_thing - object ?in_room - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_thing ?in_thing)
        (human_7c98a61edf861243_type_room ?in_room)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?informant ?room)
          (shared_p_consensus_0eca8ebcd2897a24 ?informed ?room)
          (human_7c98a61edf861243_p_believes-in ?informant ?in_thing ?in_room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?informant ?room)
          (shared_p_consensus_0eca8ebcd2897a24 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-in ?informed ?in_thing ?in_room)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_unlocked-by
    :parameters (?informant - object ?unlocked-by_room - object ?unlocked-by_key - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_room ?unlocked-by_room)
        (human_7c98a61edf861243_type_key ?unlocked-by_key)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?informant ?room)
          (shared_p_consensus_0eca8ebcd2897a24 ?informed ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?informant ?unlocked-by_room ?unlocked-by_key)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_0eca8ebcd2897a24 ?informant ?room)
          (shared_p_consensus_0eca8ebcd2897a24 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-unlocked-by ?informed ?unlocked-by_room ?unlocked-by_key)
      )
  )

  (:action human_7c98a61edf861243_a_search-for-success
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (shared_p_consensus_0eca8ebcd2897a24 ?character ?room)
          (shared_p_consensus_a99b83d6e8676154 ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_804301514d612d1d ?character ?thing)
        (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
        (human_7c98a61edf861243_p_believes-has ?character ?character ?thing)
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_search-for-fail
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (not (and (shared_p_consensus_0eca8ebcd2897a24 ?character ?room) (shared_p_consensus_a99b83d6e8676154 ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
          (shared_p_consensus_0eca8ebcd2897a24 ?character ?room)
        )
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-success
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_caef1caec545cbba ?room ?key)
          (shared_p_consensus_804301514d612d1d ?character ?key)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e0fb843b926a896e ?room))
        (not (human_7c98a61edf861243_p_believes-locked ?character ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-fail
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (not (and (shared_p_consensus_e0fb843b926a896e ?room) (shared_p_consensus_caef1caec545cbba ?room ?key) (shared_p_consensus_804301514d612d1d ?character ?key)))
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_804301514d612d1d ?character ?key)
          (not (shared_p_consensus_caef1caec545cbba ?room ?key))
        )
        (not (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key))
      )
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
          (shared_p_consensus_1719447f86a90b85 ?to ?from)
          (human_87bbd0acdf4611c5_p_at ?character ?from)
          (shared_p_consensus_bcbf21fe0f9f55c1 ?character)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_at ?character ?from))
        (human_87bbd0acdf4611c5_p_at ?character ?to)
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
          (human_87bbd0acdf4611c5_p_at ?interrogator ?location)
          (human_87bbd0acdf4611c5_p_at ?interrogated ?location)
          (shared_p_consensus_f68c01c25cae39cf ?interrogated)
        )
      )
    :effect
      (shared_p_consensus_bcbf21fe0f9f55c1 ?interrogator)
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
          (shared_p_consensus_e8675832023f971b ?placer)
          (shared_p_consensus_230e936cb4321851 ?placer ?victim)
          (human_87bbd0acdf4611c5_p_at ?placer ?location)
          (shared_p_consensus_1719447f86a90b85 ?placed ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_230e936cb4321851 ?placer ?victim))
        (human_87bbd0acdf4611c5_p_at ?victim ?placed)
        (shared_p_consensus_dba043dcf4aed0cc ?victim)
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
          (human_87bbd0acdf4611c5_p_at ?saver ?location)
          (human_87bbd0acdf4611c5_p_at ?saved ?location)
          (shared_p_consensus_dba043dcf4aed0cc ?saved)
          (shared_p_consensus_dba043dcf4aed0cc ?notsaved)
          (not (human_87bbd0acdf4611c5_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (shared_p_consensus_17564f47ff2596a8 ?notsaved))
      )
  )
)
