(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_1fe4b2f08d46fd1e_active)
    (human_1fe4b2f08d46fd1e_type_creature ?x - object)
    (human_1fe4b2f08d46fd1e_type_item ?x - object)
    (human_1fe4b2f08d46fd1e_type_monster ?x - object)
    (human_1fe4b2f08d46fd1e_type_object ?x - object)
    (human_1fe4b2f08d46fd1e_type_person ?x - object)
    (human_1fe4b2f08d46fd1e_type_place ?x - object)
    (human_1fe4b2f08d46fd1e_type_valuable ?x - object)
    (human_1fe4b2f08d46fd1e_p_alive ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (shared_p_consensus_5c22530a89120541 ?v0 - object ?v1 - object)
    (shared_p_consensus_b686f72c6cd907e9 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_belongsto ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_loves ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
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
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
  )

  (:action human_1fe4b2f08d46fd1e_a_travel
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?from)
        (human_1fe4b2f08d46fd1e_type_place ?to)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?creature)
          (shared_p_consensus_5c22530a89120541 ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_5c22530a89120541 ?creature ?to)
        (not (shared_p_consensus_5c22530a89120541 ?creature ?from))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_propose
    :parameters (?proposer - object ?proposee - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_person ?proposee)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?proposer)
          (shared_p_consensus_5c22530a89120541 ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposee)
          (shared_p_consensus_5c22530a89120541 ?proposee ?place)
          (human_1fe4b2f08d46fd1e_p_loves ?proposer ?proposee)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?proposee)
    :agents (?proposer)
  )

  (:action human_1fe4b2f08d46fd1e_a_accept
    :parameters (?accepter - object ?proposer - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?accepter)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?accepter)
          (shared_p_consensus_5c22530a89120541 ?accepter ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposer)
          (shared_p_consensus_5c22530a89120541 ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?accepter)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasaccepted ?accepter ?proposer)
    :agents (?accepter)
  )

  (:action human_1fe4b2f08d46fd1e_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?groom)
        (human_1fe4b2f08d46fd1e_type_person ?bride)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?groom)
          (shared_p_consensus_5c22530a89120541 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (human_1fe4b2f08d46fd1e_p_alive ?bride)
          (shared_p_consensus_5c22530a89120541 ?bride ?place)
          (human_1fe4b2f08d46fd1e_p_hasaccepted ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_single ?bride)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_marriedto ?groom ?bride)
        (human_1fe4b2f08d46fd1e_p_marriedto ?bride ?groom)
        (not (human_1fe4b2f08d46fd1e_p_single ?groom))
        (not (human_1fe4b2f08d46fd1e_p_single ?bride))
        (forall
          (?v - object)
          (when
            (and
              (human_1fe4b2f08d46fd1e_type_valuable ?v)
              (shared_p_consensus_b686f72c6cd907e9 ?groom ?v)
            )
            (human_1fe4b2f08d46fd1e_p_rich ?bride)
          )
        )
        (when
          (human_1fe4b2f08d46fd1e_p_loves ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_happy ?groom)
        )
        (when
          (human_1fe4b2f08d46fd1e_p_loves ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_happy ?bride)
        )
      )
    :agents (?groom ?bride)
  )

  (:action human_1fe4b2f08d46fd1e_a_steal
    :parameters (?thief - object ?victim - object ?item - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?thief)
        (human_1fe4b2f08d46fd1e_type_creature ?victim)
        (human_1fe4b2f08d46fd1e_type_item ?item)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (not (= ?thief ?victim))
          (human_1fe4b2f08d46fd1e_p_alive ?thief)
          (shared_p_consensus_5c22530a89120541 ?thief ?place)
          (shared_p_consensus_5c22530a89120541 ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (shared_p_consensus_b686f72c6cd907e9 ?thief ?item)
        (when
          (shared_p_consensus_5c22530a89120541 ?victim ?place)
          (intends ?victim (shared_p_consensus_b686f72c6cd907e9 ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (shared_p_consensus_b686f72c6cd907e9 ?victim ?v))
            )
          )
          (not (human_1fe4b2f08d46fd1e_p_rich ?victim))
        )
      )
    :agents (?thief)
  )

  (:action human_1fe4b2f08d46fd1e_a_get-hungry
    :parameters (?creature - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (not (human_1fe4b2f08d46fd1e_p_hungry ?creature))
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_hungry ?creature)
        (intends ?creature (not (human_1fe4b2f08d46fd1e_p_hungry ?creature)))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_eat
    :parameters (?monster - object ?creature - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_monster ?monster)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?monster)
          (shared_p_consensus_5c22530a89120541 ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (human_1fe4b2f08d46fd1e_p_alive ?creature)
          (shared_p_consensus_5c22530a89120541 ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (human_1fe4b2f08d46fd1e_p_alive ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (human_1fe4b2f08d46fd1e_p_happy ?creature))
      )
    :agents (?monster)
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
          (shared_p_consensus_5c22530a89120541 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_5c22530a89120541 ?character ?from))
        (shared_p_consensus_5c22530a89120541 ?character ?to)
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
          (shared_p_consensus_5c22530a89120541 ?waker ?location)
          (shared_p_consensus_5c22530a89120541 ?woken ?location)
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
          (shared_p_consensus_5c22530a89120541 ?taker ?location)
          (shared_p_consensus_5c22530a89120541 ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_5c22530a89120541 ?thing ?location))
        (shared_p_consensus_b686f72c6cd907e9 ?taker ?thing)
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
          (shared_p_consensus_5c22530a89120541 ?caster ?location)
          (shared_p_consensus_5c22530a89120541 ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (shared_p_consensus_b686f72c6cd907e9 ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
  )
)
