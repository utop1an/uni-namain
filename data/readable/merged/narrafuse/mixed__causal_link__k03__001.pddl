(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
  (:predicates
    (human_662247ec644ef452_active)
    (human_662247ec644ef452_type_animal ?x - object)
    (human_662247ec644ef452_type_item ?x - object)
    (human_662247ec644ef452_type_living ?x - object)
    (human_662247ec644ef452_type_object ?x - object)
    (human_662247ec644ef452_type_person ?x - object)
    (human_662247ec644ef452_type_place ?x - object)
    (human_662247ec644ef452_type_sickness ?x - object)
    (human_662247ec644ef452_type_valuable ?x - object)
    (human_662247ec644ef452_p_alive ?v0 - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (shared_p_consensus_2e2d90d77d6e4325 ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_belongsto ?v0 - object ?v1 - object)
    (shared_p_consensus_46043ce981147080 ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_loves ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_active)
    (human_ab9663f1e67ea2f0_type_alley ?x - object)
    (human_ab9663f1e67ea2f0_type_bank ?x - object)
    (human_ab9663f1e67ea2f0_type_bar ?x - object)
    (human_ab9663f1e67ea2f0_type_big-money ?x - object)
    (human_ab9663f1e67ea2f0_type_bystanders ?x - object)
    (human_ab9663f1e67ea2f0_type_cuffs ?x - object)
    (human_ab9663f1e67ea2f0_type_evil ?x - object)
    (human_ab9663f1e67ea2f0_type_guard ?x - object)
    (human_ab9663f1e67ea2f0_type_gun ?x - object)
    (human_ab9663f1e67ea2f0_type_horse ?x - object)
    (human_ab9663f1e67ea2f0_type_mobile ?x - object)
    (human_ab9663f1e67ea2f0_type_money ?x - object)
    (human_ab9663f1e67ea2f0_type_mother-lode ?x - object)
    (human_ab9663f1e67ea2f0_type_object ?x - object)
    (human_ab9663f1e67ea2f0_type_pawn-broker ?x - object)
    (human_ab9663f1e67ea2f0_type_person ?x - object)
    (human_ab9663f1e67ea2f0_type_place ?x - object)
    (human_ab9663f1e67ea2f0_type_poker-game ?x - object)
    (human_ab9663f1e67ea2f0_type_seller ?x - object)
    (human_ab9663f1e67ea2f0_type_sheriff ?x - object)
    (human_ab9663f1e67ea2f0_type_small-goods ?x - object)
    (human_ab9663f1e67ea2f0_type_store ?x - object)
    (human_ab9663f1e67ea2f0_type_thing ?x - object)
    (human_ab9663f1e67ea2f0_type_valuable ?x - object)
    (human_ab9663f1e67ea2f0_p_connected ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_alley-of ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_at ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_open ?v0 - object)
    (human_ab9663f1e67ea2f0_p_forsale ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_hidden ?v0 - object)
    (human_ab9663f1e67ea2f0_p_drunk ?v0 - object)
    (human_ab9663f1e67ea2f0_p_sleeping ?v0 - object)
    (human_ab9663f1e67ea2f0_p_in-cuffs ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_free-with-money ?v0 - object)
    (human_ab9663f1e67ea2f0_p_friendly ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_blocking ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_guard-of ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_guarded ?v0 - object)
    (human_ab9663f1e67ea2f0_p_bet-at ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_held-up ?v0 - object ?v1 - object)
    (human_ab9663f1e67ea2f0_p_arrested ?v0 - object ?v1 - object)
    (tiny_stories__story_051_active)
    (tiny_stories__story_051_type_animal ?x - object)
    (tiny_stories__story_051_type_character ?x - object)
    (tiny_stories__story_051_type_object ?x - object)
    (tiny_stories__story_051_type_place ?x - object)
    (tiny_stories__story_051_p_hugged ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_door-open ?v0 - object)
    (tiny_stories__story_051_p_friendly ?v0 - object)
  )
  (:axiom :vars (?character - object ?animal - object) :context (and (tiny_stories__story_051_active) (tiny_stories__story_051_type_character ?character) (tiny_stories__story_051_type_animal ?animal) (and (not (tiny_stories__story_051_p_friendly ?animal)) (tiny_stories__story_051_p_hugged ?character ?animal))) :implies (tiny_stories__story_051_p_friendly ?animal))

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_p_alive ?victim)
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
              (human_662247ec644ef452_p_loves ?p ?victim)
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (human_662247ec644ef452_p_alive ?person))
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_2e2d90d77d6e4325 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_2e2d90d77d6e4325 ?person ?to)
        (not (shared_p_consensus_2e2d90d77d6e4325 ?person ?from))
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_2e2d90d77d6e4325 ?person ?from)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_2e2d90d77d6e4325 ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_2e2d90d77d6e4325 ?person ?to)
        (not (shared_p_consensus_2e2d90d77d6e4325 ?person ?from))
        (shared_p_consensus_2e2d90d77d6e4325 ?victim ?to)
        (not (shared_p_consensus_2e2d90d77d6e4325 ?victim ?from))
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
          (human_662247ec644ef452_p_alive ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_2e2d90d77d6e4325 ?giver ?place)
          (shared_p_consensus_46043ce981147080 ?giver ?item)
          (human_662247ec644ef452_p_alive ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_2e2d90d77d6e4325 ?receiver ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?receiver ?item)
        (not (shared_p_consensus_46043ce981147080 ?giver ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?giver)
          (human_662247ec644ef452_p_belongsto ?item ?receiver)
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_2e2d90d77d6e4325 ?person ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (shared_p_consensus_2e2d90d77d6e4325 ?victim ?place)
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_2e2d90d77d6e4325 ?person ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_2e2d90d77d6e4325 ?victim ?place)
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
          (human_662247ec644ef452_p_alive ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_2e2d90d77d6e4325 ?taker ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_2e2d90d77d6e4325 ?victim ?place)
          (shared_p_consensus_46043ce981147080 ?victim ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?taker ?item)
        (not (shared_p_consensus_46043ce981147080 ?victim ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?victim)
          (and
            (intends ?victim (shared_p_consensus_46043ce981147080 ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (shared_p_consensus_2e2d90d77d6e4325 ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (shared_p_consensus_46043ce981147080 ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
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
          (human_662247ec644ef452_p_alive ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_2e2d90d77d6e4325 ?healer ?place)
          (shared_p_consensus_46043ce981147080 ?healer ?medicine)
          (human_662247ec644ef452_p_alive ?patient)
          (shared_p_consensus_2e2d90d77d6e4325 ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (shared_p_consensus_46043ce981147080 ?healer ?medicine))
      )
    :agents (?healer ?patient)
  )

  (:action human_ab9663f1e67ea2f0_a_pick-up
    :parameters (?person - object ?thing - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_thing ?thing)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?thing ?place)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?thing ?place))
        (shared_p_consensus_46043ce981147080 ?person ?thing)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_holster-gun
    :parameters (?person - object ?gun - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_gun ?gun)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?gun ?place)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?gun ?place))
        (shared_p_consensus_46043ce981147080 ?person ?gun)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_withdraw-money
    :parameters (?person - object ?bank - object ?money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_bank ?bank)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
          (shared_p_consensus_46043ce981147080 ?bank ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_46043ce981147080 ?bank ?money))
        (shared_p_consensus_46043ce981147080 ?person ?money)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_open
    :parameters (?person - object ?store - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_store ?store)
        (human_ab9663f1e67ea2f0_p_at ?person ?store)
      )
    :effect
      (human_ab9663f1e67ea2f0_p_open ?store)
  )

  (:action human_ab9663f1e67ea2f0_a_sell
    :parameters (?person - object ?buyer - object ?thing - object ?money - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_person ?buyer)
        (human_ab9663f1e67ea2f0_type_small-goods ?thing)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (shared_p_consensus_46043ce981147080 ?person ?thing)
          (human_ab9663f1e67ea2f0_p_at ?buyer ?place)
          (shared_p_consensus_46043ce981147080 ?buyer ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_46043ce981147080 ?person ?thing))
        (shared_p_consensus_46043ce981147080 ?person ?money)
        (not (shared_p_consensus_46043ce981147080 ?buyer ?money))
        (shared_p_consensus_46043ce981147080 ?buyer ?thing)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_buy-dress
    :parameters (?person - object ?thing - object ?store - object ?money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_valuable ?thing)
        (human_ab9663f1e67ea2f0_type_store ?store)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (and
          (human_ab9663f1e67ea2f0_p_open ?store)
          (human_ab9663f1e67ea2f0_p_forsale ?thing ?store)
          (human_ab9663f1e67ea2f0_p_at ?person ?store)
          (shared_p_consensus_46043ce981147080 ?person ?money)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?person ?thing)
        (not (human_ab9663f1e67ea2f0_p_forsale ?thing ?store))
        (not (shared_p_consensus_46043ce981147080 ?person ?money))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_fail-buy-dress
    :parameters (?person - object ?thing - object ?store - object ?money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_valuable ?thing)
        (human_ab9663f1e67ea2f0_type_store ?store)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (and
          (human_ab9663f1e67ea2f0_p_open ?store)
          (human_ab9663f1e67ea2f0_p_forsale ?thing ?store)
          (human_ab9663f1e67ea2f0_p_at ?person ?store)
          (not (shared_p_consensus_46043ce981147080 ?person ?money))
        )
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_kick-out-of-way
    :parameters (?person - object ?roadblock - object ?alley - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_person ?roadblock)
        (human_ab9663f1e67ea2f0_type_alley ?alley)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?roadblock ?place)
          (human_ab9663f1e67ea2f0_p_blocking ?roadblock ?alley)
        )
      )
    :effect
      (not (human_ab9663f1e67ea2f0_p_blocking ?roadblock ?alley))
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_hatch-plan
    :parameters (?person - object ?gun - object ?horse - object ?bank - object ?mother-lode - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_gun ?gun)
        (human_ab9663f1e67ea2f0_type_horse ?horse)
        (human_ab9663f1e67ea2f0_type_bank ?bank)
        (human_ab9663f1e67ea2f0_type_mother-lode ?mother-lode)
        (shared_p_consensus_46043ce981147080 ?bank ?mother-lode)
      )
    :effect
      (and
        (not (shared_p_consensus_46043ce981147080 ?person ?mother-lode))
        (intends ?person (shared_p_consensus_46043ce981147080 ?person ?gun))
        (intends ?person (shared_p_consensus_46043ce981147080 ?person ?horse))
        (intends ?person (shared_p_consensus_46043ce981147080 ?person ?mother-lode))
        (intends ?person (human_ab9663f1e67ea2f0_p_free-with-money ?person))
      )
  )

  (:action human_ab9663f1e67ea2f0_a_hide-in-dark-alley
    :parameters (?person - object ?alley - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_alley ?alley)
        (human_ab9663f1e67ea2f0_p_at ?person ?alley)
      )
    :effect
      (human_ab9663f1e67ea2f0_p_hidden ?person)
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_pickpocket
    :parameters (?person - object ?mark - object ?money - object ?place - object ?alley - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_person ?mark)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (human_ab9663f1e67ea2f0_type_alley ?alley)
        (and
          (human_ab9663f1e67ea2f0_p_alley-of ?alley ?place)
          (human_ab9663f1e67ea2f0_p_at ?person ?alley)
          (human_ab9663f1e67ea2f0_p_at ?mark ?place)
          (human_ab9663f1e67ea2f0_p_hidden ?person)
          (shared_p_consensus_46043ce981147080 ?mark ?money)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?person ?money)
        (not (shared_p_consensus_46043ce981147080 ?mark ?money))
        (not (human_ab9663f1e67ea2f0_p_hidden ?person))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_move-once
    :parameters (?person - object ?from - object ?to - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_mobile ?person)
        (human_ab9663f1e67ea2f0_type_place ?from)
        (human_ab9663f1e67ea2f0_type_place ?to)
        (and
          (human_ab9663f1e67ea2f0_p_connected ?from ?to)
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_buy-drinks-for
    :parameters (?person - object ?drinker - object ?money - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_person ?drinker)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (human_ab9663f1e67ea2f0_type_bar ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?drinker ?place)
          (shared_p_consensus_46043ce981147080 ?person ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_friendly ?drinker ?person)
        (human_ab9663f1e67ea2f0_p_drunk ?drinker)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_cheat-at-poker
    :parameters (?person - object ?poker - object ?money - object ?winnings - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_poker-game ?poker)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (human_ab9663f1e67ea2f0_type_money ?winnings)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?poker ?place)
          (shared_p_consensus_46043ce981147080 ?person ?money)
          (human_ab9663f1e67ea2f0_p_bet-at ?winnings ?poker)
        )
      )
    :effect
      (shared_p_consensus_46043ce981147080 ?person ?winnings)
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_escort-drunk-friend
    :parameters (?person - object ?friend - object ?from - object ?to - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_person ?friend)
        (human_ab9663f1e67ea2f0_type_place ?from)
        (human_ab9663f1e67ea2f0_type_place ?to)
        (and
          (human_ab9663f1e67ea2f0_p_connected ?from ?to)
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
          (human_ab9663f1e67ea2f0_p_at ?friend ?from)
          (human_ab9663f1e67ea2f0_p_drunk ?friend)
          (human_ab9663f1e67ea2f0_p_friendly ?friend ?person)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?friend ?from))
        (human_ab9663f1e67ea2f0_p_at ?friend ?to)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_lay-to-rest-in-alley
    :parameters (?person - object ?friend - object ?place - object ?bank - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_guard ?friend)
        (human_ab9663f1e67ea2f0_type_alley ?place)
        (human_ab9663f1e67ea2f0_type_bank ?bank)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?friend ?place)
          (human_ab9663f1e67ea2f0_p_drunk ?friend)
          (human_ab9663f1e67ea2f0_p_friendly ?friend ?person)
          (human_ab9663f1e67ea2f0_p_guard-of ?friend ?bank)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_sleeping ?friend)
        (not (human_ab9663f1e67ea2f0_p_guarded ?bank))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_take-thing-off-sleeper
    :parameters (?person - object ?sleeper - object ?thing - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_person ?sleeper)
        (human_ab9663f1e67ea2f0_type_thing ?thing)
        (human_ab9663f1e67ea2f0_type_alley ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?sleeper ?place)
          (human_ab9663f1e67ea2f0_p_sleeping ?sleeper)
          (shared_p_consensus_46043ce981147080 ?sleeper ?thing)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?person ?thing)
        (not (shared_p_consensus_46043ce981147080 ?sleeper ?thing))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_pawn-valuable
    :parameters (?person - object ?pawn-broker - object ?thing - object ?place - object ?big-money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_pawn-broker ?pawn-broker)
        (human_ab9663f1e67ea2f0_type_valuable ?thing)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (human_ab9663f1e67ea2f0_type_big-money ?big-money)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?pawn-broker ?place)
          (shared_p_consensus_46043ce981147080 ?person ?thing)
          (shared_p_consensus_46043ce981147080 ?pawn-broker ?big-money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_46043ce981147080 ?person ?thing))
        (shared_p_consensus_46043ce981147080 ?pawn-broker ?thing)
        (shared_p_consensus_46043ce981147080 ?person ?big-money)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_buy-valuable
    :parameters (?person - object ?seller - object ?thing - object ?place - object ?big-money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_seller ?seller)
        (human_ab9663f1e67ea2f0_type_valuable ?thing)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (human_ab9663f1e67ea2f0_type_big-money ?big-money)
        (and
          (shared_p_consensus_46043ce981147080 ?seller ?thing)
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?seller ?place)
          (shared_p_consensus_46043ce981147080 ?person ?big-money)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?person ?thing)
        (not (shared_p_consensus_46043ce981147080 ?seller ?thing))
        (not (shared_p_consensus_46043ce981147080 ?person ?big-money))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_ride-horse-to
    :parameters (?person - object ?horse - object ?from - object ?to - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_mobile ?person)
        (human_ab9663f1e67ea2f0_type_horse ?horse)
        (human_ab9663f1e67ea2f0_type_place ?from)
        (human_ab9663f1e67ea2f0_type_place ?to)
        (and
          (human_ab9663f1e67ea2f0_p_connected ?from ?to)
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
          (human_ab9663f1e67ea2f0_p_at ?horse ?from)
          (shared_p_consensus_46043ce981147080 ?person ?horse)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
        (human_ab9663f1e67ea2f0_p_at ?horse ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?horse ?from))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_hold-up-bank
    :parameters (?person - object ?gun - object ?bank - object ?sheriff - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_gun ?gun)
        (human_ab9663f1e67ea2f0_type_bank ?bank)
        (human_ab9663f1e67ea2f0_type_sheriff ?sheriff)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
          (shared_p_consensus_46043ce981147080 ?person ?gun)
          (not (human_ab9663f1e67ea2f0_p_guarded ?bank))
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_held-up ?person ?bank)
        (intends ?sheriff (human_ab9663f1e67ea2f0_p_arrested ?sheriff ?person))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_collect-money-from-heist
    :parameters (?person - object ?bank - object ?mother-lode - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_bank ?bank)
        (human_ab9663f1e67ea2f0_type_mother-lode ?mother-lode)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
          (human_ab9663f1e67ea2f0_p_held-up ?person ?bank)
          (shared_p_consensus_46043ce981147080 ?bank ?mother-lode)
        )
      )
    :effect
      (and
        (shared_p_consensus_46043ce981147080 ?person ?mother-lode)
        (not (human_ab9663f1e67ea2f0_p_held-up ?person ?bank))
        (not (shared_p_consensus_46043ce981147080 ?bank ?mother-lode))
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_getaway-with-money
    :parameters (?person - object ?mother-lode - object ?horse - object ?place - object ?dest - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?person)
        (human_ab9663f1e67ea2f0_type_mother-lode ?mother-lode)
        (human_ab9663f1e67ea2f0_type_horse ?horse)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (human_ab9663f1e67ea2f0_type_place ?dest)
        (and
          (human_ab9663f1e67ea2f0_p_connected ?place ?dest)
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?horse ?place)
          (shared_p_consensus_46043ce981147080 ?person ?mother-lode)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?person ?place))
        (not (human_ab9663f1e67ea2f0_p_at ?horse ?place))
        (human_ab9663f1e67ea2f0_p_free-with-money ?person)
        (human_ab9663f1e67ea2f0_p_at ?person ?dest)
      )
    :agents (?person)
  )

  (:action human_ab9663f1e67ea2f0_a_arrest
    :parameters (?criminal - object ?sheriff - object ?place - object ?cuffs - object ?money - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_evil ?criminal)
        (human_ab9663f1e67ea2f0_type_sheriff ?sheriff)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (human_ab9663f1e67ea2f0_type_cuffs ?cuffs)
        (human_ab9663f1e67ea2f0_type_money ?money)
        (and
          (human_ab9663f1e67ea2f0_p_at ?sheriff ?place)
          (human_ab9663f1e67ea2f0_p_at ?criminal ?place)
          (shared_p_consensus_46043ce981147080 ?sheriff ?cuffs)
          (shared_p_consensus_46043ce981147080 ?criminal ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_arrested ?sheriff ?criminal)
        (human_ab9663f1e67ea2f0_p_in-cuffs ?criminal ?cuffs)
        (shared_p_consensus_46043ce981147080 ?sheriff ?money)
        (not (shared_p_consensus_46043ce981147080 ?criminal ?money))
      )
    :agents (?sheriff)
  )

  (:action tiny_stories__story_051_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?from)
        (tiny_stories__story_051_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_2e2d90d77d6e4325 ?character ?from)
          (tiny_stories__story_051_p_door-open ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e2d90d77d6e4325 ?character ?from))
        (shared_p_consensus_2e2d90d77d6e4325 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_hug
    :parameters (?hugger - object ?hugged - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?hugger)
        (tiny_stories__story_051_type_object ?hugged)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_2e2d90d77d6e4325 ?hugger ?place)
          (shared_p_consensus_2e2d90d77d6e4325 ?hugged ?place)
        )
      )
    :effect
      (tiny_stories__story_051_p_hugged ?hugger ?hugged)
    :agents (?hugger)
  )

  (:action tiny_stories__story_051_a_open-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_2e2d90d77d6e4325 ?character ?place)
          (not (tiny_stories__story_051_p_door-open ?place))
        )
      )
    :effect
      (tiny_stories__story_051_p_door-open ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_close-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_2e2d90d77d6e4325 ?character ?place)
          (tiny_stories__story_051_p_door-open ?place)
        )
      )
    :effect
      (not (tiny_stories__story_051_p_door-open ?place))
    :agents (?character)
  )
)
