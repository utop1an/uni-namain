(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
  (:predicates
    (human_1fe4b2f08d46fd1e_active)
    (human_1fe4b2f08d46fd1e_type_creature ?x - object)
    (human_1fe4b2f08d46fd1e_type_item ?x - object)
    (human_1fe4b2f08d46fd1e_type_monster ?x - object)
    (human_1fe4b2f08d46fd1e_type_object ?x - object)
    (human_1fe4b2f08d46fd1e_type_person ?x - object)
    (human_1fe4b2f08d46fd1e_type_place ?x - object)
    (human_1fe4b2f08d46fd1e_type_valuable ?x - object)
    (shared_p_consensus_484a1b1db8159933 ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (shared_p_consensus_388cef442081d722 ?v0 - object ?v1 - object)
    (shared_p_consensus_399e50af7e951219 ?v0 - object ?v1 - object)
    (shared_p_consensus_2480b9295c28aaa9 ?v0 - object ?v1 - object)
    (shared_p_consensus_5b2b3bfe7c0edb14 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
    (human_662247ec644ef452_active)
    (human_662247ec644ef452_type_animal ?x - object)
    (human_662247ec644ef452_type_item ?x - object)
    (human_662247ec644ef452_type_living ?x - object)
    (human_662247ec644ef452_type_object ?x - object)
    (human_662247ec644ef452_type_person ?x - object)
    (human_662247ec644ef452_type_place ?x - object)
    (human_662247ec644ef452_type_sickness ?x - object)
    (human_662247ec644ef452_type_valuable ?x - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
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
          (shared_p_consensus_484a1b1db8159933 ?creature)
          (shared_p_consensus_388cef442081d722 ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_388cef442081d722 ?creature ?to)
        (not (shared_p_consensus_388cef442081d722 ?creature ?from))
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
          (shared_p_consensus_484a1b1db8159933 ?proposer)
          (shared_p_consensus_388cef442081d722 ?proposer ?place)
          (shared_p_consensus_484a1b1db8159933 ?proposee)
          (shared_p_consensus_388cef442081d722 ?proposee ?place)
          (shared_p_consensus_5b2b3bfe7c0edb14 ?proposer ?proposee)
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
          (shared_p_consensus_484a1b1db8159933 ?accepter)
          (shared_p_consensus_388cef442081d722 ?accepter ?place)
          (shared_p_consensus_484a1b1db8159933 ?proposer)
          (shared_p_consensus_388cef442081d722 ?proposer ?place)
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
          (shared_p_consensus_484a1b1db8159933 ?groom)
          (shared_p_consensus_388cef442081d722 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (shared_p_consensus_484a1b1db8159933 ?bride)
          (shared_p_consensus_388cef442081d722 ?bride ?place)
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
              (shared_p_consensus_399e50af7e951219 ?groom ?v)
            )
            (human_1fe4b2f08d46fd1e_p_rich ?bride)
          )
        )
        (when
          (shared_p_consensus_5b2b3bfe7c0edb14 ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_happy ?groom)
        )
        (when
          (shared_p_consensus_5b2b3bfe7c0edb14 ?bride ?groom)
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
          (shared_p_consensus_484a1b1db8159933 ?thief)
          (shared_p_consensus_388cef442081d722 ?thief ?place)
          (shared_p_consensus_388cef442081d722 ?item ?place)
          (shared_p_consensus_2480b9295c28aaa9 ?item ?victim)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?thief ?item)
        (when
          (shared_p_consensus_388cef442081d722 ?victim ?place)
          (intends ?victim (shared_p_consensus_399e50af7e951219 ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (shared_p_consensus_399e50af7e951219 ?victim ?v))
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
          (shared_p_consensus_484a1b1db8159933 ?monster)
          (shared_p_consensus_388cef442081d722 ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (shared_p_consensus_484a1b1db8159933 ?creature)
          (shared_p_consensus_388cef442081d722 ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (shared_p_consensus_484a1b1db8159933 ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (human_1fe4b2f08d46fd1e_p_happy ?creature))
      )
    :agents (?monster)
  )

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (shared_p_consensus_484a1b1db8159933 ?victim)
      )
    :effect
      (and
        (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)
        (intends ?victim (not (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)))
        (forall
          (?p - object)
          (when
            (and
              (human_662247ec644ef452_type_person ?p)
              (shared_p_consensus_5b2b3bfe7c0edb14 ?p ?victim)
            )
            (intends ?p (not (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)))
          )
        )
      )
  )

  (:action human_662247ec644ef452_a_die
    :parameters (?person - object ?sickness - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_sickness ?sickness)
        (and
          (shared_p_consensus_484a1b1db8159933 ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (shared_p_consensus_484a1b1db8159933 ?person))
  )

  (:action human_662247ec644ef452_a_travel
    :parameters (?person - object ?from - object ?to - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_place ?from)
        (human_662247ec644ef452_type_place ?to)
        (and
          (shared_p_consensus_484a1b1db8159933 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_388cef442081d722 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_388cef442081d722 ?person ?to)
        (not (shared_p_consensus_388cef442081d722 ?person ?from))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_forcetravel
    :parameters (?person - object ?victim - object ?from - object ?to - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?from)
        (human_662247ec644ef452_type_place ?to)
        (and
          (shared_p_consensus_484a1b1db8159933 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_388cef442081d722 ?person ?from)
          (shared_p_consensus_484a1b1db8159933 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_388cef442081d722 ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_388cef442081d722 ?person ?to)
        (not (shared_p_consensus_388cef442081d722 ?person ?from))
        (shared_p_consensus_388cef442081d722 ?victim ?to)
        (not (shared_p_consensus_388cef442081d722 ?victim ?from))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_give
    :parameters (?giver - object ?receiver - object ?item - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?giver)
        (human_662247ec644ef452_type_person ?receiver)
        (human_662247ec644ef452_type_item ?item)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_484a1b1db8159933 ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_388cef442081d722 ?giver ?place)
          (shared_p_consensus_399e50af7e951219 ?giver ?item)
          (shared_p_consensus_484a1b1db8159933 ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_388cef442081d722 ?receiver ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?receiver ?item)
        (not (shared_p_consensus_399e50af7e951219 ?giver ?item))
        (when
          (shared_p_consensus_2480b9295c28aaa9 ?item ?giver)
          (shared_p_consensus_2480b9295c28aaa9 ?item ?receiver)
        )
      )
    :agents (?giver ?receiver)
  )

  (:action human_662247ec644ef452_a_tieup
    :parameters (?person - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_484a1b1db8159933 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_388cef442081d722 ?person ?place)
          (shared_p_consensus_484a1b1db8159933 ?victim)
          (shared_p_consensus_388cef442081d722 ?victim ?place)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_free ?victim))
        (intends ?victim (human_662247ec644ef452_p_free ?victim))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_untie
    :parameters (?person - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_484a1b1db8159933 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_388cef442081d722 ?person ?place)
          (shared_p_consensus_484a1b1db8159933 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_388cef442081d722 ?victim ?place)
        )
      )
    :effect
      (human_662247ec644ef452_p_free ?victim)
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_take
    :parameters (?taker - object ?item - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?taker)
        (human_662247ec644ef452_type_item ?item)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (not (= ?taker ?victim))
          (shared_p_consensus_484a1b1db8159933 ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_388cef442081d722 ?taker ?place)
          (shared_p_consensus_484a1b1db8159933 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_388cef442081d722 ?victim ?place)
          (shared_p_consensus_399e50af7e951219 ?victim ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?taker ?item)
        (not (shared_p_consensus_399e50af7e951219 ?victim ?item))
        (when
          (shared_p_consensus_2480b9295c28aaa9 ?item ?victim)
          (and
            (intends ?victim (shared_p_consensus_399e50af7e951219 ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (shared_p_consensus_388cef442081d722 ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (shared_p_consensus_399e50af7e951219 ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
              )
            )
          )
        )
      )
    :agents (?taker)
  )

  (:action human_662247ec644ef452_a_heal
    :parameters (?healer - object ?patient - object ?sickness - object ?medicine - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?healer)
        (human_662247ec644ef452_type_person ?patient)
        (human_662247ec644ef452_type_sickness ?sickness)
        (human_662247ec644ef452_type_item ?medicine)
        (human_662247ec644ef452_type_place ?place)
        (and
          (human_662247ec644ef452_p_cures ?medicine ?sickness)
          (shared_p_consensus_484a1b1db8159933 ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_388cef442081d722 ?healer ?place)
          (shared_p_consensus_399e50af7e951219 ?healer ?medicine)
          (shared_p_consensus_484a1b1db8159933 ?patient)
          (shared_p_consensus_388cef442081d722 ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (shared_p_consensus_399e50af7e951219 ?healer ?medicine))
      )
    :agents (?healer ?patient)
  )
)
