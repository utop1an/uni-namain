(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing :universal-preconditions)
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
    (shared_p_consensus_2f7b60f225a122a0 ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_a1e3bd65d5956cbd ?v0 - object ?v1 - object)
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
    (shared_p_consensus_bc51addee1c42e02 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_has ?v0 - object ?v1 - object)
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
    (shared_p_consensus_474e2c460340d3ae ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_4ea561be63763523 ?character)) (shared_p_consensus_2f7b60f225a122a0 ?character ?location) (shared_p_consensus_a1e3bd65d5956cbd ?character ?item))) :implies (and (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?item)) (shared_p_consensus_2f7b60f225a122a0 ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_4ea561be63763523 ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_a1e3bd65d5956cbd ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_4ea561be63763523 ?character) (shared_p_consensus_a1e3bd65d5956cbd ?character ?item) (shared_p_consensus_4ea561be63763523 ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_4ea561be63763523 ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_4ea561be63763523 ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_4ea561be63763523 ?guard))) :implies (intends ?guard (not (shared_p_consensus_4ea561be63763523 ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_4ea561be63763523 ?predator) (shared_p_consensus_2f7b60f225a122a0 ?predator ?location) (shared_p_consensus_4ea561be63763523 ?character) (shared_p_consensus_2f7b60f225a122a0 ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_4ea561be63763523 ?character))))

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
          (shared_p_consensus_2f7b60f225a122a0 ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_a1e3bd65d5956cbd ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7b60f225a122a0 ?character ?from))
        (shared_p_consensus_2f7b60f225a122a0 ?character ?to)
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
          (shared_p_consensus_2f7b60f225a122a0 ?character ?location)
          (shared_p_consensus_4ea561be63763523 ?target)
          (shared_p_consensus_2f7b60f225a122a0 ?target ?location)
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?poison)
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?poison))
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?food))
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
          (shared_p_consensus_2f7b60f225a122a0 ?character ?location)
          (shared_p_consensus_2f7b60f225a122a0 ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7b60f225a122a0 ?item ?location))
        (shared_p_consensus_a1e3bd65d5956cbd ?character ?item)
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
          (shared_p_consensus_2f7b60f225a122a0 ?character ?location)
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?character_item)
          (shared_p_consensus_4ea561be63763523 ?seller)
          (shared_p_consensus_2f7b60f225a122a0 ?seller ?location)
          (shared_p_consensus_2f7b60f225a122a0 ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?character_item))
        (shared_p_consensus_a1e3bd65d5956cbd ?seller ?character_item)
        (not (shared_p_consensus_2f7b60f225a122a0 ?seller_item ?location))
        (shared_p_consensus_a1e3bd65d5956cbd ?character ?seller_item)
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
          (shared_p_consensus_2f7b60f225a122a0 ?character ?location)
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?item)
          (shared_p_consensus_4ea561be63763523 ?receiver)
          (shared_p_consensus_2f7b60f225a122a0 ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?item))
        (shared_p_consensus_a1e3bd65d5956cbd ?receiver ?item)
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell))
        (shared_p_consensus_a1e3bd65d5956cbd ?character ?light)
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell)
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell))
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?item))
        (shared_p_consensus_a1e3bd65d5956cbd ?character ?money)
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell)
          (shared_p_consensus_2f7b60f225a122a0 ?character ?location)
          (shared_p_consensus_4ea561be63763523 ?target)
          (shared_p_consensus_2f7b60f225a122a0 ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell))
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
          (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell)
          (shared_p_consensus_2f7b60f225a122a0 ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a1e3bd65d5956cbd ?character ?spell))
        (not (shared_p_consensus_2f7b60f225a122a0 ?character ?from))
        (shared_p_consensus_2f7b60f225a122a0 ?character ?to)
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
          (shared_p_consensus_bc51addee1c42e02 ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_bc51addee1c42e02 ?creature ?to)
        (not (shared_p_consensus_bc51addee1c42e02 ?creature ?from))
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
          (shared_p_consensus_bc51addee1c42e02 ?proposer ?place)
          (shared_p_consensus_4ea561be63763523 ?proposee)
          (shared_p_consensus_bc51addee1c42e02 ?proposee ?place)
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
          (shared_p_consensus_bc51addee1c42e02 ?accepter ?place)
          (shared_p_consensus_4ea561be63763523 ?proposer)
          (shared_p_consensus_bc51addee1c42e02 ?proposer ?place)
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
          (shared_p_consensus_bc51addee1c42e02 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (shared_p_consensus_4ea561be63763523 ?bride)
          (shared_p_consensus_bc51addee1c42e02 ?bride ?place)
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
              (human_1fe4b2f08d46fd1e_p_has ?groom ?v)
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
          (shared_p_consensus_bc51addee1c42e02 ?thief ?place)
          (shared_p_consensus_bc51addee1c42e02 ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_has ?thief ?item)
        (when
          (shared_p_consensus_bc51addee1c42e02 ?victim ?place)
          (intends ?victim (human_1fe4b2f08d46fd1e_p_has ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (human_1fe4b2f08d46fd1e_p_has ?victim ?v))
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
          (shared_p_consensus_bc51addee1c42e02 ?monster ?place)
          (shared_p_consensus_ea455b982e3d66ec ?monster)
          (shared_p_consensus_4ea561be63763523 ?creature)
          (shared_p_consensus_bc51addee1c42e02 ?creature ?place)
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

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (shared_p_consensus_474e2c460340d3ae ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (shared_p_consensus_2f7b60f225a122a0 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7b60f225a122a0 ?character ?from))
        (shared_p_consensus_2f7b60f225a122a0 ?character ?to)
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
          (shared_p_consensus_2f7b60f225a122a0 ?waker ?location)
          (shared_p_consensus_2f7b60f225a122a0 ?woken ?location)
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
          (shared_p_consensus_2f7b60f225a122a0 ?taker ?location)
          (shared_p_consensus_2f7b60f225a122a0 ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7b60f225a122a0 ?thing ?location))
        (shared_p_consensus_a1e3bd65d5956cbd ?taker ?thing)
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
          (shared_p_consensus_2f7b60f225a122a0 ?caster ?location)
          (shared_p_consensus_2f7b60f225a122a0 ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (shared_p_consensus_a1e3bd65d5956cbd ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
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
          (shared_p_consensus_474e2c460340d3ae ?to ?from)
          (shared_p_consensus_bc51addee1c42e02 ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc51addee1c42e02 ?character ?from))
        (shared_p_consensus_bc51addee1c42e02 ?character ?to)
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
          (shared_p_consensus_bc51addee1c42e02 ?interrogator ?location)
          (shared_p_consensus_bc51addee1c42e02 ?interrogated ?location)
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
          (shared_p_consensus_bc51addee1c42e02 ?placer ?location)
          (shared_p_consensus_474e2c460340d3ae ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (shared_p_consensus_bc51addee1c42e02 ?victim ?placed)
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
          (shared_p_consensus_bc51addee1c42e02 ?saver ?location)
          (shared_p_consensus_bc51addee1c42e02 ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (shared_p_consensus_bc51addee1c42e02 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )
)
