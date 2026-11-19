(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_4d95b598471c21ee_active)
    (human_4d95b598471c21ee_type_book ?x - object)
    (human_4d95b598471c21ee_type_character ?x - object)
    (human_4d95b598471c21ee_type_item ?x - object)
    (human_4d95b598471c21ee_type_location ?x - object)
    (human_4d95b598471c21ee_type_object ?x - object)
    (human_4d95b598471c21ee_type_ring ?x - object)
    (human_4d95b598471c21ee_type_sword ?x - object)
    (human_4d95b598471c21ee_type_thing ?x - object)
    (human_4d95b598471c21ee_p_player ?v0 - object)
    (human_4d95b598471c21ee_p_at ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_has ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_at ?v0 - object ?v1 - object)
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
    (human_67ab241b327ccef0_p_at ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (human_67ab241b327ccef0_p_has ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_active)
    (human_7c98a61edf861243_type_character ?x - object)
    (human_7c98a61edf861243_type_key ?x - object)
    (human_7c98a61edf861243_type_letter ?x - object)
    (human_7c98a61edf861243_type_object ?x - object)
    (human_7c98a61edf861243_type_room ?x - object)
    (human_7c98a61edf861243_type_star ?x - object)
    (human_7c98a61edf861243_type_thing ?x - object)
    (human_7c98a61edf861243_p_locked ?v0 - object)
    (human_7c98a61edf861243_p_at ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_unlocked-by ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_in ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_hidden ?v0 - object)
    (human_7c98a61edf861243_p_has ?v0 - object ?v1 - object)
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
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
  )

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (human_4d95b598471c21ee_p_connected ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (human_4d95b598471c21ee_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?character ?from))
        (human_4d95b598471c21ee_p_at ?character ?to)
      )
  )

  (:action human_4d95b598471c21ee_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?waker)
        (human_4d95b598471c21ee_type_character ?woken)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?waker ?location)
          (human_4d95b598471c21ee_p_at ?woken ?location)
          (human_4d95b598471c21ee_p_asleep ?woken)
          (not (human_4d95b598471c21ee_p_asleep ?waker))
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_asleep ?woken))
  )

  (:action human_4d95b598471c21ee_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?taker)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?taker ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?thing ?location))
        (human_4d95b598471c21ee_p_has ?taker ?thing)
      )
  )

  (:action human_4d95b598471c21ee_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?caster)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_book ?book)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?caster ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (human_4d95b598471c21ee_p_has ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
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
          (human_62959785b3ec220a_p_at ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_at ?character ?from))
        (human_62959785b3ec220a_p_at ?character ?to)
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
          (human_62959785b3ec220a_p_at ?interrogator ?location)
          (human_62959785b3ec220a_p_at ?interrogated ?location)
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
          (human_62959785b3ec220a_p_at ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (human_62959785b3ec220a_p_at ?victim ?placed)
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
          (human_62959785b3ec220a_p_at ?saver ?location)
          (human_62959785b3ec220a_p_at ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (human_62959785b3ec220a_p_at ?notsaved ?location))
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
          (human_67ab241b327ccef0_p_at ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (human_67ab241b327ccef0_p_at ?character ?roomfrom))
        (human_67ab241b327ccef0_p_at ?character ?roomto)
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
          (human_67ab241b327ccef0_p_at ?character ?room)
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
          (not (human_7c98a61edf861243_p_locked ?roomto))
          (human_7c98a61edf861243_p_at ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (human_7c98a61edf861243_p_at ?character ?roomfrom))
        (human_7c98a61edf861243_p_at ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (human_7c98a61edf861243_p_at ?char2 ?roomto)
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
                (human_7c98a61edf861243_p_in ?thing ?roomto)
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
          (not (and (not (human_7c98a61edf861243_p_locked ?roomto)) (human_7c98a61edf861243_p_at ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?roomto)
          (human_7c98a61edf861243_p_at ?character ?roomfrom)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?character ?room)
          (human_7c98a61edf861243_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (human_7c98a61edf861243_p_has ?character ?thing)
        (not (human_7c98a61edf861243_p_in ?thing ?room))
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
          (not (and (human_7c98a61edf861243_p_at ?character ?room) (human_7c98a61edf861243_p_in ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (human_7c98a61edf861243_p_in ?thing ?room))
          (human_7c98a61edf861243_p_at ?character ?room)
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
          (human_7c98a61edf861243_p_locked ?room)
          (human_7c98a61edf861243_p_unlocked-by ?room ?key)
          (human_7c98a61edf861243_p_has ?character ?key)
        )
      )
    :effect
      (and
        (not (human_7c98a61edf861243_p_locked ?room))
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
          (not (and (human_7c98a61edf861243_p_locked ?room) (human_7c98a61edf861243_p_unlocked-by ?room ?key) (human_7c98a61edf861243_p_has ?character ?key)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?room)
          (human_7c98a61edf861243_p_has ?character ?key)
          (not (human_7c98a61edf861243_p_unlocked-by ?room ?key))
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
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (human_87bbd0acdf4611c5_p_at ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
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
          (human_87bbd0acdf4611c5_p_at ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (human_87bbd0acdf4611c5_p_at ?victim ?placed)
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
          (human_87bbd0acdf4611c5_p_at ?saver ?location)
          (human_87bbd0acdf4611c5_p_at ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (human_87bbd0acdf4611c5_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )
)
