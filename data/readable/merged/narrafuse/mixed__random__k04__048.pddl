(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
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
    (shared_p_consensus_7d37c410ead202e2 ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (shared_p_consensus_402e605c88abb696 ?v0 - object ?v1 - object)
    (shared_p_consensus_4728058524e94193 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_belongsto ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_loves ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
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
    (shared_p_consensus_4b83e351c7aa7ea7 ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_027_active)
    (writing_prompts__wp_027_type_character ?x - object)
    (writing_prompts__wp_027_type_object ?x - object)
    (writing_prompts__wp_027_type_place ?x - object)
    (writing_prompts__wp_027_p_clothed ?v0 - object)
    (writing_prompts__wp_027_p_alive ?v0 - object)
    (writing_prompts__wp_027_p_stuck ?v0 - object)
    (writing_prompts__wp_027_p_falling ?v0 - object)
    (writing_prompts__wp_027_p_aware-glitch ?v0 - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (writing_prompts__wp_032_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_wolves-attack ?v0 - object)
    (writing_prompts__wp_032_p_wolves-killed ?v0 - object)
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
          (shared_p_consensus_7d37c410ead202e2 ?creature)
          (shared_p_consensus_402e605c88abb696 ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_402e605c88abb696 ?creature ?to)
        (not (shared_p_consensus_402e605c88abb696 ?creature ?from))
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
          (shared_p_consensus_7d37c410ead202e2 ?proposer)
          (shared_p_consensus_402e605c88abb696 ?proposer ?place)
          (shared_p_consensus_7d37c410ead202e2 ?proposee)
          (shared_p_consensus_402e605c88abb696 ?proposee ?place)
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
          (shared_p_consensus_7d37c410ead202e2 ?accepter)
          (shared_p_consensus_402e605c88abb696 ?accepter ?place)
          (shared_p_consensus_7d37c410ead202e2 ?proposer)
          (shared_p_consensus_402e605c88abb696 ?proposer ?place)
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
          (shared_p_consensus_7d37c410ead202e2 ?groom)
          (shared_p_consensus_402e605c88abb696 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (shared_p_consensus_7d37c410ead202e2 ?bride)
          (shared_p_consensus_402e605c88abb696 ?bride ?place)
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
              (shared_p_consensus_4728058524e94193 ?groom ?v)
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
          (shared_p_consensus_7d37c410ead202e2 ?thief)
          (shared_p_consensus_402e605c88abb696 ?thief ?place)
          (shared_p_consensus_402e605c88abb696 ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?thief ?item)
        (when
          (shared_p_consensus_402e605c88abb696 ?victim ?place)
          (intends ?victim (shared_p_consensus_4728058524e94193 ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (shared_p_consensus_4728058524e94193 ?victim ?v))
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
          (shared_p_consensus_7d37c410ead202e2 ?monster)
          (shared_p_consensus_402e605c88abb696 ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (shared_p_consensus_7d37c410ead202e2 ?creature)
          (shared_p_consensus_402e605c88abb696 ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (shared_p_consensus_7d37c410ead202e2 ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (human_1fe4b2f08d46fd1e_p_happy ?creature))
      )
    :agents (?monster)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?thing ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?thing ?place))
        (shared_p_consensus_4728058524e94193 ?person ?thing)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?gun ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?gun ?place))
        (shared_p_consensus_4728058524e94193 ?person ?gun)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?bank)
          (shared_p_consensus_4728058524e94193 ?bank ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4728058524e94193 ?bank ?money))
        (shared_p_consensus_4728058524e94193 ?person ?money)
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
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?store)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4728058524e94193 ?person ?thing)
          (shared_p_consensus_4b83e351c7aa7ea7 ?buyer ?place)
          (shared_p_consensus_4728058524e94193 ?buyer ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4728058524e94193 ?person ?thing))
        (shared_p_consensus_4728058524e94193 ?person ?money)
        (not (shared_p_consensus_4728058524e94193 ?buyer ?money))
        (shared_p_consensus_4728058524e94193 ?buyer ?thing)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?store)
          (shared_p_consensus_4728058524e94193 ?person ?money)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?person ?thing)
        (not (human_ab9663f1e67ea2f0_p_forsale ?thing ?store))
        (not (shared_p_consensus_4728058524e94193 ?person ?money))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?store)
          (not (shared_p_consensus_4728058524e94193 ?person ?money))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?roadblock ?place)
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
        (shared_p_consensus_4728058524e94193 ?bank ?mother-lode)
      )
    :effect
      (and
        (not (shared_p_consensus_4728058524e94193 ?person ?mother-lode))
        (intends ?person (shared_p_consensus_4728058524e94193 ?person ?gun))
        (intends ?person (shared_p_consensus_4728058524e94193 ?person ?horse))
        (intends ?person (shared_p_consensus_4728058524e94193 ?person ?mother-lode))
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
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?alley)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?alley)
          (shared_p_consensus_4b83e351c7aa7ea7 ?mark ?place)
          (human_ab9663f1e67ea2f0_p_hidden ?person)
          (shared_p_consensus_4728058524e94193 ?mark ?money)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?person ?money)
        (not (shared_p_consensus_4728058524e94193 ?mark ?money))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?to)
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?drinker ?place)
          (shared_p_consensus_4728058524e94193 ?person ?money)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?poker ?place)
          (shared_p_consensus_4728058524e94193 ?person ?money)
          (human_ab9663f1e67ea2f0_p_bet-at ?winnings ?poker)
        )
      )
    :effect
      (shared_p_consensus_4728058524e94193 ?person ?winnings)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from)
          (shared_p_consensus_4b83e351c7aa7ea7 ?friend ?from)
          (human_ab9663f1e67ea2f0_p_drunk ?friend)
          (human_ab9663f1e67ea2f0_p_friendly ?friend ?person)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from))
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?to)
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?friend ?from))
        (shared_p_consensus_4b83e351c7aa7ea7 ?friend ?to)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?friend ?place)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?sleeper ?place)
          (human_ab9663f1e67ea2f0_p_sleeping ?sleeper)
          (shared_p_consensus_4728058524e94193 ?sleeper ?thing)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?person ?thing)
        (not (shared_p_consensus_4728058524e94193 ?sleeper ?thing))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?pawn-broker ?place)
          (shared_p_consensus_4728058524e94193 ?person ?thing)
          (shared_p_consensus_4728058524e94193 ?pawn-broker ?big-money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4728058524e94193 ?person ?thing))
        (shared_p_consensus_4728058524e94193 ?pawn-broker ?thing)
        (shared_p_consensus_4728058524e94193 ?person ?big-money)
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
          (shared_p_consensus_4728058524e94193 ?seller ?thing)
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?seller ?place)
          (shared_p_consensus_4728058524e94193 ?person ?big-money)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?person ?thing)
        (not (shared_p_consensus_4728058524e94193 ?seller ?thing))
        (not (shared_p_consensus_4728058524e94193 ?person ?big-money))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from)
          (shared_p_consensus_4b83e351c7aa7ea7 ?horse ?from)
          (shared_p_consensus_4728058524e94193 ?person ?horse)
        )
      )
    :effect
      (and
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?to)
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?person ?from))
        (shared_p_consensus_4b83e351c7aa7ea7 ?horse ?to)
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?horse ?from))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?bank)
          (shared_p_consensus_4728058524e94193 ?person ?gun)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?bank)
          (human_ab9663f1e67ea2f0_p_held-up ?person ?bank)
          (shared_p_consensus_4728058524e94193 ?bank ?mother-lode)
        )
      )
    :effect
      (and
        (shared_p_consensus_4728058524e94193 ?person ?mother-lode)
        (not (human_ab9663f1e67ea2f0_p_held-up ?person ?bank))
        (not (shared_p_consensus_4728058524e94193 ?bank ?mother-lode))
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?horse ?place)
          (shared_p_consensus_4728058524e94193 ?person ?mother-lode)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?person ?place))
        (not (shared_p_consensus_4b83e351c7aa7ea7 ?horse ?place))
        (human_ab9663f1e67ea2f0_p_free-with-money ?person)
        (shared_p_consensus_4b83e351c7aa7ea7 ?person ?dest)
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
          (shared_p_consensus_4b83e351c7aa7ea7 ?sheriff ?place)
          (shared_p_consensus_4b83e351c7aa7ea7 ?criminal ?place)
          (shared_p_consensus_4728058524e94193 ?sheriff ?cuffs)
          (shared_p_consensus_4728058524e94193 ?criminal ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_arrested ?sheriff ?criminal)
        (human_ab9663f1e67ea2f0_p_in-cuffs ?criminal ?cuffs)
        (shared_p_consensus_4728058524e94193 ?sheriff ?money)
        (not (shared_p_consensus_4728058524e94193 ?criminal ?money))
      )
    :agents (?sheriff)
  )

  (:action writing_prompts__wp_027_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (writing_prompts__wp_027_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_027_p_aware-glitch ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_help-stuck
    :parameters (?helper - object ?stuck-character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?helper)
        (writing_prompts__wp_027_type_character ?stuck-character)
        (and
          (writing_prompts__wp_027_p_alive ?helper)
          (writing_prompts__wp_027_p_stuck ?stuck-character)
          (shared_p_consensus_4b83e351c7aa7ea7 ?helper ?stuck-character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_stuck ?stuck-character))
        (writing_prompts__wp_027_p_aware-glitch ?helper)
      )
    :agents (?helper)
  )

  (:action writing_prompts__wp_027_a_fall
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (writing_prompts__wp_027_type_place ?place)
        (and
          (writing_prompts__wp_027_p_alive ?character)
          (writing_prompts__wp_027_p_falling ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_falling ?character))
        (shared_p_consensus_4b83e351c7aa7ea7 ?character ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_lose-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (and
          (writing_prompts__wp_027_p_alive ?character)
          (writing_prompts__wp_027_p_clothed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_027_p_clothed ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?from)
        (writing_prompts__wp_032_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_7d37c410ead202e2 ?character)
          (shared_p_consensus_402e605c88abb696 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_402e605c88abb696 ?character ?from))
        (shared_p_consensus_402e605c88abb696 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_kill-wolves
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?place)
        (and
          (shared_p_consensus_7d37c410ead202e2 ?character)
          (shared_p_consensus_402e605c88abb696 ?character ?place)
          (writing_prompts__wp_032_p_wolves-attack ?place)
        )
      )
    :effect
      (writing_prompts__wp_032_p_wolves-killed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (shared_p_consensus_7d37c410ead202e2 ?character)
      )
    :effect
      (not (shared_p_consensus_7d37c410ead202e2 ?character))
    :agents (?character)
  )
)
