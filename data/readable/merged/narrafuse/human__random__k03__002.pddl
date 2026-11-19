(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_1e91389e12439414_active)
    (human_1e91389e12439414_type_alchemy_spell ?x - object)
    (human_1e91389e12439414_type_character ?x - object)
    (human_1e91389e12439414_type_food ?x - object)
    (human_1e91389e12439414_type_guard ?x - object)
    (human_1e91389e12439414_type_humanoid ?x - object)
    (human_1e91389e12439414_type_item ?x - object)
    (human_1e91389e12439414_type_kill_spell ?x - object)
    (human_1e91389e12439414_type_light ?x - object)
    (human_1e91389e12439414_type_light_spell ?x - object)
    (human_1e91389e12439414_type_location ?x - object)
    (human_1e91389e12439414_type_love_spell ?x - object)
    (human_1e91389e12439414_type_merchant ?x - object)
    (human_1e91389e12439414_type_money ?x - object)
    (human_1e91389e12439414_type_object ?x - object)
    (human_1e91389e12439414_type_poison ?x - object)
    (human_1e91389e12439414_type_predator ?x - object)
    (human_1e91389e12439414_type_protagonist ?x - object)
    (human_1e91389e12439414_type_spell ?x - object)
    (human_1e91389e12439414_type_teleport_spell ?x - object)
    (human_1e91389e12439414_type_weapon ?x - object)
    (shared_p_consensus_4ea561be63763523 ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_18336735d40614d1 ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_e2a95e589aac4dde ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_buying ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_selling ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_summons ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_leads_to ?v0 - object ?v1 - object)
    (shared_p_consensus_ea455b982e3d66ec ?v0 - object)
    (human_1e91389e12439414_p_citizen ?v0 - object)
    (human_1e91389e12439414_p_guard ?v0 - object)
    (human_1e91389e12439414_p_criminal ?v0 - object)
    (human_1e91389e12439414_p_owned ?v0 - object)
    (human_1e91389e12439414_p_owns ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_active)
    (human_1fe4b2f08d46fd1e_type_creature ?x - object)
    (human_1fe4b2f08d46fd1e_type_item ?x - object)
    (human_1fe4b2f08d46fd1e_type_monster ?x - object)
    (human_1fe4b2f08d46fd1e_type_object ?x - object)
    (human_1fe4b2f08d46fd1e_type_person ?x - object)
    (human_1fe4b2f08d46fd1e_type_place ?x - object)
    (human_1fe4b2f08d46fd1e_type_valuable ?x - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_at ?v0 - object ?v1 - object)
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
    (human_ab9663f1e67ea2f0_p_has ?v0 - object ?v1 - object)
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
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_4ea561be63763523 ?character)) (shared_p_consensus_18336735d40614d1 ?character ?location) (shared_p_consensus_e2a95e589aac4dde ?character ?item))) :implies (and (not (shared_p_consensus_e2a95e589aac4dde ?character ?item)) (shared_p_consensus_18336735d40614d1 ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_4ea561be63763523 ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_e2a95e589aac4dde ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_e2a95e589aac4dde ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_4ea561be63763523 ?character) (shared_p_consensus_e2a95e589aac4dde ?character ?item) (shared_p_consensus_4ea561be63763523 ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_4ea561be63763523 ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_4ea561be63763523 ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_4ea561be63763523 ?guard))) :implies (intends ?guard (not (shared_p_consensus_4ea561be63763523 ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_4ea561be63763523 ?predator) (shared_p_consensus_18336735d40614d1 ?predator ?location) (shared_p_consensus_4ea561be63763523 ?character) (shared_p_consensus_18336735d40614d1 ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_4ea561be63763523 ?character))))

  (:action human_1e91389e12439414_a_walk
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_character ?character)
        (human_1e91389e12439414_type_location ?from)
        (human_1e91389e12439414_type_location ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_18336735d40614d1 ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_e2a95e589aac4dde ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?character ?from))
        (shared_p_consensus_18336735d40614d1 ?character ?to)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_attack
    :parameters (?character - object ?target - object ?location - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_character ?character)
        (human_1e91389e12439414_type_character ?target)
        (human_1e91389e12439414_type_location ?location)
        (and
          (not (= ?character ?target))
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_18336735d40614d1 ?character ?location)
          (shared_p_consensus_4ea561be63763523 ?target)
          (shared_p_consensus_18336735d40614d1 ?target ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (human_1e91389e12439414_p_criminal ?target)
          )
        )
      )
    :effect
      (and
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_4ea561be63763523 ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_4ea561be63763523 ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_4ea561be63763523 ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_4ea561be63763523 ?target))
        )
        (when
          (human_1e91389e12439414_p_citizen ?target)
          (human_1e91389e12439414_p_criminal ?character)
        )
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_poison
    :parameters (?character - object ?poison - object ?food - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_poison ?poison)
        (human_1e91389e12439414_type_food ?food)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?poison)
          (shared_p_consensus_e2a95e589aac4dde ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?poison))
        (human_1e91389e12439414_p_poisoned ?food)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_eat
    :parameters (?character - object ?food - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_humanoid ?character)
        (human_1e91389e12439414_type_food ?food)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?food))
        (not (shared_p_consensus_ea455b982e3d66ec ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (shared_p_consensus_4ea561be63763523 ?character))
        )
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_pickup
    :parameters (?character - object ?item - object ?location - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_humanoid ?character)
        (human_1e91389e12439414_type_item ?item)
        (human_1e91389e12439414_type_location ?location)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_18336735d40614d1 ?character ?location)
          (shared_p_consensus_18336735d40614d1 ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?item ?location))
        (shared_p_consensus_e2a95e589aac4dde ?character ?item)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_trade
    :parameters (?character - object ?character_item - object ?seller - object ?seller_item - object ?location - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_item ?character_item)
        (human_1e91389e12439414_type_merchant ?seller)
        (human_1e91389e12439414_type_item ?seller_item)
        (human_1e91389e12439414_type_location ?location)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_18336735d40614d1 ?character ?location)
          (shared_p_consensus_e2a95e589aac4dde ?character ?character_item)
          (shared_p_consensus_4ea561be63763523 ?seller)
          (shared_p_consensus_18336735d40614d1 ?seller ?location)
          (shared_p_consensus_18336735d40614d1 ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?character_item))
        (shared_p_consensus_e2a95e589aac4dde ?seller ?character_item)
        (not (shared_p_consensus_18336735d40614d1 ?seller_item ?location))
        (shared_p_consensus_e2a95e589aac4dde ?character ?seller_item)
        (not (human_1e91389e12439414_p_owns ?seller ?seller_item))
        (human_1e91389e12439414_p_owns ?character ?seller_item)
        (not (human_1e91389e12439414_p_buying ?seller ?character_item))
        (not (human_1e91389e12439414_p_selling ?seller ?seller_item))
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_give
    :parameters (?character - object ?item - object ?receiver - object ?location - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_item ?item)
        (human_1e91389e12439414_type_humanoid ?receiver)
        (human_1e91389e12439414_type_location ?location)
        (and
          (not (= ?character ?receiver))
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_18336735d40614d1 ?character ?location)
          (shared_p_consensus_e2a95e589aac4dde ?character ?item)
          (shared_p_consensus_4ea561be63763523 ?receiver)
          (shared_p_consensus_18336735d40614d1 ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?item))
        (shared_p_consensus_e2a95e589aac4dde ?receiver ?item)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_cast_light_spell
    :parameters (?character - object ?spell - object ?light - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_light_spell ?spell)
        (human_1e91389e12439414_type_light ?light)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?spell))
        (shared_p_consensus_e2a95e589aac4dde ?character ?light)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_cast_alchemy_spell
    :parameters (?character - object ?spell - object ?item - object ?money - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_alchemy_spell ?spell)
        (human_1e91389e12439414_type_item ?item)
        (human_1e91389e12439414_type_money ?money)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?spell)
          (shared_p_consensus_e2a95e589aac4dde ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?spell))
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?item))
        (shared_p_consensus_e2a95e589aac4dde ?character ?money)
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_cast_kill_spell
    :parameters (?character - object ?spell - object ?target - object ?location - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_humanoid ?character)
        (human_1e91389e12439414_type_kill_spell ?spell)
        (human_1e91389e12439414_type_character ?target)
        (human_1e91389e12439414_type_location ?location)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?spell)
          (shared_p_consensus_18336735d40614d1 ?character ?location)
          (shared_p_consensus_4ea561be63763523 ?target)
          (shared_p_consensus_18336735d40614d1 ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?spell))
        (not (shared_p_consensus_4ea561be63763523 ?target))
      )
    :agents (?character)
  )

  (:action human_1e91389e12439414_a_cast_teleport_spell
    :parameters (?character - object ?spell - object ?from - object ?to - object)
    :precondition
      (and
        (human_1e91389e12439414_active)
        (human_1e91389e12439414_type_protagonist ?character)
        (human_1e91389e12439414_type_teleport_spell ?spell)
        (human_1e91389e12439414_type_location ?from)
        (human_1e91389e12439414_type_location ?to)
        (and
          (shared_p_consensus_4ea561be63763523 ?character)
          (shared_p_consensus_e2a95e589aac4dde ?character ?spell)
          (shared_p_consensus_18336735d40614d1 ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2a95e589aac4dde ?character ?spell))
        (not (shared_p_consensus_18336735d40614d1 ?character ?from))
        (shared_p_consensus_18336735d40614d1 ?character ?to)
      )
    :agents (?character)
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
          (shared_p_consensus_4ea561be63763523 ?creature)
          (human_1fe4b2f08d46fd1e_p_at ?creature ?from)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_at ?creature ?to)
        (not (human_1fe4b2f08d46fd1e_p_at ?creature ?from))
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
          (shared_p_consensus_4ea561be63763523 ?proposer)
          (human_1fe4b2f08d46fd1e_p_at ?proposer ?place)
          (shared_p_consensus_4ea561be63763523 ?proposee)
          (human_1fe4b2f08d46fd1e_p_at ?proposee ?place)
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
          (shared_p_consensus_4ea561be63763523 ?accepter)
          (human_1fe4b2f08d46fd1e_p_at ?accepter ?place)
          (shared_p_consensus_4ea561be63763523 ?proposer)
          (human_1fe4b2f08d46fd1e_p_at ?proposer ?place)
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
          (shared_p_consensus_4ea561be63763523 ?groom)
          (human_1fe4b2f08d46fd1e_p_at ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (shared_p_consensus_4ea561be63763523 ?bride)
          (human_1fe4b2f08d46fd1e_p_at ?bride ?place)
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
              (shared_p_consensus_e2a95e589aac4dde ?groom ?v)
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
          (shared_p_consensus_4ea561be63763523 ?thief)
          (human_1fe4b2f08d46fd1e_p_at ?thief ?place)
          (human_1fe4b2f08d46fd1e_p_at ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (shared_p_consensus_e2a95e589aac4dde ?thief ?item)
        (when
          (human_1fe4b2f08d46fd1e_p_at ?victim ?place)
          (intends ?victim (shared_p_consensus_e2a95e589aac4dde ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (shared_p_consensus_e2a95e589aac4dde ?victim ?v))
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
        (not (shared_p_consensus_ea455b982e3d66ec ?creature))
      )
    :effect
      (and
        (shared_p_consensus_ea455b982e3d66ec ?creature)
        (intends ?creature (not (shared_p_consensus_ea455b982e3d66ec ?creature)))
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
          (shared_p_consensus_4ea561be63763523 ?monster)
          (human_1fe4b2f08d46fd1e_p_at ?monster ?place)
          (shared_p_consensus_ea455b982e3d66ec ?monster)
          (shared_p_consensus_4ea561be63763523 ?creature)
          (human_1fe4b2f08d46fd1e_p_at ?creature ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ea455b982e3d66ec ?monster))
        (not (shared_p_consensus_4ea561be63763523 ?creature))
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?thing ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?thing ?place))
        (human_ab9663f1e67ea2f0_p_has ?person ?thing)
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?gun ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?gun ?place))
        (human_ab9663f1e67ea2f0_p_has ?person ?gun)
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
          (shared_p_consensus_18336735d40614d1 ?person ?bank)
          (human_ab9663f1e67ea2f0_p_has ?bank ?money)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_has ?bank ?money))
        (human_ab9663f1e67ea2f0_p_has ?person ?money)
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
        (shared_p_consensus_18336735d40614d1 ?person ?store)
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?thing)
          (shared_p_consensus_18336735d40614d1 ?buyer ?place)
          (human_ab9663f1e67ea2f0_p_has ?buyer ?money)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_has ?person ?thing))
        (human_ab9663f1e67ea2f0_p_has ?person ?money)
        (not (human_ab9663f1e67ea2f0_p_has ?buyer ?money))
        (human_ab9663f1e67ea2f0_p_has ?buyer ?thing)
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
          (shared_p_consensus_18336735d40614d1 ?person ?store)
          (human_ab9663f1e67ea2f0_p_has ?person ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_has ?person ?thing)
        (not (human_ab9663f1e67ea2f0_p_forsale ?thing ?store))
        (not (human_ab9663f1e67ea2f0_p_has ?person ?money))
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
          (shared_p_consensus_18336735d40614d1 ?person ?store)
          (not (human_ab9663f1e67ea2f0_p_has ?person ?money))
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?roadblock ?place)
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
        (human_ab9663f1e67ea2f0_p_has ?bank ?mother-lode)
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_has ?person ?mother-lode))
        (intends ?person (human_ab9663f1e67ea2f0_p_has ?person ?gun))
        (intends ?person (human_ab9663f1e67ea2f0_p_has ?person ?horse))
        (intends ?person (human_ab9663f1e67ea2f0_p_has ?person ?mother-lode))
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
        (shared_p_consensus_18336735d40614d1 ?person ?alley)
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
          (shared_p_consensus_18336735d40614d1 ?person ?alley)
          (shared_p_consensus_18336735d40614d1 ?mark ?place)
          (human_ab9663f1e67ea2f0_p_hidden ?person)
          (human_ab9663f1e67ea2f0_p_has ?mark ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_has ?person ?money)
        (not (human_ab9663f1e67ea2f0_p_has ?mark ?money))
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
          (shared_p_consensus_18336735d40614d1 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_18336735d40614d1 ?person ?to)
        (not (shared_p_consensus_18336735d40614d1 ?person ?from))
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?drinker ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?money)
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?poker ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?money)
          (human_ab9663f1e67ea2f0_p_bet-at ?winnings ?poker)
        )
      )
    :effect
      (human_ab9663f1e67ea2f0_p_has ?person ?winnings)
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
          (shared_p_consensus_18336735d40614d1 ?person ?from)
          (shared_p_consensus_18336735d40614d1 ?friend ?from)
          (human_ab9663f1e67ea2f0_p_drunk ?friend)
          (human_ab9663f1e67ea2f0_p_friendly ?friend ?person)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?person ?from))
        (shared_p_consensus_18336735d40614d1 ?person ?to)
        (not (shared_p_consensus_18336735d40614d1 ?friend ?from))
        (shared_p_consensus_18336735d40614d1 ?friend ?to)
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?friend ?place)
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?sleeper ?place)
          (human_ab9663f1e67ea2f0_p_sleeping ?sleeper)
          (human_ab9663f1e67ea2f0_p_has ?sleeper ?thing)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_has ?person ?thing)
        (not (human_ab9663f1e67ea2f0_p_has ?sleeper ?thing))
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?pawn-broker ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?thing)
          (human_ab9663f1e67ea2f0_p_has ?pawn-broker ?big-money)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_has ?person ?thing))
        (human_ab9663f1e67ea2f0_p_has ?pawn-broker ?thing)
        (human_ab9663f1e67ea2f0_p_has ?person ?big-money)
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
          (human_ab9663f1e67ea2f0_p_has ?seller ?thing)
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?seller ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?big-money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_has ?person ?thing)
        (not (human_ab9663f1e67ea2f0_p_has ?seller ?thing))
        (not (human_ab9663f1e67ea2f0_p_has ?person ?big-money))
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
          (shared_p_consensus_18336735d40614d1 ?person ?from)
          (shared_p_consensus_18336735d40614d1 ?horse ?from)
          (human_ab9663f1e67ea2f0_p_has ?person ?horse)
        )
      )
    :effect
      (and
        (shared_p_consensus_18336735d40614d1 ?person ?to)
        (not (shared_p_consensus_18336735d40614d1 ?person ?from))
        (shared_p_consensus_18336735d40614d1 ?horse ?to)
        (not (shared_p_consensus_18336735d40614d1 ?horse ?from))
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
          (shared_p_consensus_18336735d40614d1 ?person ?bank)
          (human_ab9663f1e67ea2f0_p_has ?person ?gun)
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
          (shared_p_consensus_18336735d40614d1 ?person ?bank)
          (human_ab9663f1e67ea2f0_p_held-up ?person ?bank)
          (human_ab9663f1e67ea2f0_p_has ?bank ?mother-lode)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_has ?person ?mother-lode)
        (not (human_ab9663f1e67ea2f0_p_held-up ?person ?bank))
        (not (human_ab9663f1e67ea2f0_p_has ?bank ?mother-lode))
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
          (shared_p_consensus_18336735d40614d1 ?person ?place)
          (shared_p_consensus_18336735d40614d1 ?horse ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?mother-lode)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_18336735d40614d1 ?person ?place))
        (not (shared_p_consensus_18336735d40614d1 ?horse ?place))
        (human_ab9663f1e67ea2f0_p_free-with-money ?person)
        (shared_p_consensus_18336735d40614d1 ?person ?dest)
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
          (shared_p_consensus_18336735d40614d1 ?sheriff ?place)
          (shared_p_consensus_18336735d40614d1 ?criminal ?place)
          (human_ab9663f1e67ea2f0_p_has ?sheriff ?cuffs)
          (human_ab9663f1e67ea2f0_p_has ?criminal ?money)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_arrested ?sheriff ?criminal)
        (human_ab9663f1e67ea2f0_p_in-cuffs ?criminal ?cuffs)
        (human_ab9663f1e67ea2f0_p_has ?sheriff ?money)
        (not (human_ab9663f1e67ea2f0_p_has ?criminal ?money))
      )
    :agents (?sheriff)
  )
)
