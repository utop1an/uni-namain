(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (shared_p_consensus_e0fb843b926a896e ?v0 - object)
    (shared_p_consensus_f6f927665f0a872f ?v0 - object ?v1 - object)
    (shared_p_consensus_caef1caec545cbba ?v0 - object ?v1 - object)
    (shared_p_consensus_a99b83d6e8676154 ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_804301514d612d1d ?v0 - object ?v1 - object)
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
          (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom))
        (shared_p_consensus_f6f927665f0a872f ?character ?roomto)
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
          (shared_p_consensus_f6f927665f0a872f ?character ?room)
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
          (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom))
        (shared_p_consensus_f6f927665f0a872f ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (shared_p_consensus_f6f927665f0a872f ?char2 ?roomto)
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
          (not (and (not (shared_p_consensus_e0fb843b926a896e ?roomto)) (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_e0fb843b926a896e ?roomto)
          (shared_p_consensus_f6f927665f0a872f ?character ?roomfrom)
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
          (shared_p_consensus_f6f927665f0a872f ?informant ?room)
          (shared_p_consensus_f6f927665f0a872f ?informed ?room)
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
          (shared_p_consensus_f6f927665f0a872f ?informant ?room)
          (shared_p_consensus_f6f927665f0a872f ?informed ?room)
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
          (shared_p_consensus_f6f927665f0a872f ?informant ?room)
          (shared_p_consensus_f6f927665f0a872f ?informed ?room)
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
          (shared_p_consensus_f6f927665f0a872f ?informant ?room)
          (shared_p_consensus_f6f927665f0a872f ?informed ?room)
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
          (shared_p_consensus_f6f927665f0a872f ?character ?room)
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
          (not (and (shared_p_consensus_f6f927665f0a872f ?character ?room) (shared_p_consensus_a99b83d6e8676154 ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
          (shared_p_consensus_f6f927665f0a872f ?character ?room)
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
)
