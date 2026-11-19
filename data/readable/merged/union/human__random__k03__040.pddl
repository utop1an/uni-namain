(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
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
    (human_cf10335d299ae37f_active)
    (human_cf10335d299ae37f_type_creature ?x - object)
    (human_cf10335d299ae37f_type_landform ?x - object)
    (human_cf10335d299ae37f_type_object ?x - object)
    (human_cf10335d299ae37f_type_place ?x - object)
    (human_cf10335d299ae37f_type_ship ?x - object)
    (human_cf10335d299ae37f_p_alive ?v0 - object)
    (human_cf10335d299ae37f_p_stunned ?v0 - object)
    (human_cf10335d299ae37f_p_habitable ?v0 - object)
    (human_cf10335d299ae37f_p_safe ?v0 - object)
    (human_cf10335d299ae37f_p_erupting ?v0 - object)
    (human_cf10335d299ae37f_p_at ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_fighting ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_friends ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_captain ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_guardian ?v0 - object ?v1 - object)
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

  (:action human_cf10335d299ae37f_a_walk
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_landform ?from)
        (human_cf10335d299ae37f_type_landform ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (forall
            (?c - object)
            (or
              (not (human_cf10335d299ae37f_type_creature ?c))
              (and
                (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
                (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              )
            )
          )
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-from-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_ship ?from)
        (human_cf10335d299ae37f_type_place ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?from)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              (when
                (human_cf10335d299ae37f_p_guardian ?c ?to)
                (intends ?c (not (human_cf10335d299ae37f_p_alive ?creature)))
              )
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-to-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?from)
        (human_cf10335d299ae37f_type_ship ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?to)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_attack
    :parameters (?attacker - object ?victim - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?attacker)
        (human_cf10335d299ae37f_type_creature ?victim)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (human_cf10335d299ae37f_p_alive ?attacker)
          (not (human_cf10335d299ae37f_p_stunned ?attacker))
          (human_cf10335d299ae37f_p_at ?attacker ?place)
          (human_cf10335d299ae37f_p_alive ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (human_cf10335d299ae37f_p_at ?victim ?place)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_fighting ?attacker ?victim)
        (intends ?victim (not (human_cf10335d299ae37f_p_fighting ?attacker ?victim)))
      )
    :agents (?attacker)
  )

  (:action human_cf10335d299ae37f_a_kill
    :parameters (?killer - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?killer)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?killer)
          (not (human_cf10335d299ae37f_p_stunned ?killer))
          (human_cf10335d299ae37f_p_alive ?victim)
          (or
            (human_cf10335d299ae37f_p_fighting ?killer ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          )
        )
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_alive ?victim))
        (when
          (human_cf10335d299ae37f_p_fighting ?killer ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?killer ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?killer))
        )
      )
    :agents (?killer)
  )

  (:action human_cf10335d299ae37f_a_stun
    :parameters (?stunner - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?stunner)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?stunner)
          (not (human_cf10335d299ae37f_p_stunned ?stunner))
          (human_cf10335d299ae37f_p_alive ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (or
            (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          )
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_stunned ?victim)
        (when
          (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?stunner ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?stunner))
        )
      )
    :agents (?stunner)
  )

  (:action human_cf10335d299ae37f_a_break-free
    :parameters (?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?victim)
          (human_cf10335d299ae37f_p_stunned ?victim)
        )
      )
    :effect
      (not (human_cf10335d299ae37f_p_stunned ?victim))
    :agents (?victim)
  )

  (:action human_cf10335d299ae37f_a_make-peace
    :parameters (?peacemaker - object ?creature - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?peacemaker)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (human_cf10335d299ae37f_p_alive ?peacemaker)
          (not (human_cf10335d299ae37f_p_stunned ?peacemaker))
          (human_cf10335d299ae37f_p_at ?peacemaker ?place)
          (human_cf10335d299ae37f_p_alive ?creature)
          (human_cf10335d299ae37f_p_at ?creature ?place)
          (not (human_cf10335d299ae37f_p_fighting ?peacemaker ?creature))
          (not (human_cf10335d299ae37f_p_fighting ?creature ?peacemaker))
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_friends ?peacemaker ?creature)
        (human_cf10335d299ae37f_p_friends ?creature ?peacemaker)
      )
    :agents (?peacemaker)
  )

  (:action human_cf10335d299ae37f_a_begin-erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_erupting ?landform)
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (human_cf10335d299ae37f_p_at ?c ?landform)
            )
            (and
              (not (human_cf10335d299ae37f_p_safe ?c))
              (intends ?c (human_cf10335d299ae37f_p_safe ?c))
            )
          )
        )
      )
  )

  (:action human_cf10335d299ae37f_a_erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
        (human_cf10335d299ae37f_p_erupting ?landform)
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_habitable ?landform))
        (not (human_cf10335d299ae37f_p_erupting ?landform))
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (human_cf10335d299ae37f_p_at ?c ?landform)
            )
            (not (human_cf10335d299ae37f_p_alive ?c))
          )
        )
      )
  )
)
