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
    (human_1e91389e12439414_p_alive ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_3bfd6d519a861504 ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_d458b45953ec44f4 ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_buying ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_selling ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_summons ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_leads_to ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_hungry ?v0 - object)
    (human_1e91389e12439414_p_citizen ?v0 - object)
    (human_1e91389e12439414_p_guard ?v0 - object)
    (human_1e91389e12439414_p_criminal ?v0 - object)
    (human_1e91389e12439414_p_owned ?v0 - object)
    (human_1e91389e12439414_p_owns ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_ff9a88689bd88cb5 ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (human_1e91389e12439414_p_alive ?character)) (shared_p_consensus_3bfd6d519a861504 ?character ?location) (shared_p_consensus_d458b45953ec44f4 ?character ?item))) :implies (and (not (shared_p_consensus_d458b45953ec44f4 ?character ?item)) (shared_p_consensus_3bfd6d519a861504 ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_alive ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_d458b45953ec44f4 ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_d458b45953ec44f4 ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (human_1e91389e12439414_p_alive ?character) (shared_p_consensus_d458b45953ec44f4 ?character ?item) (human_1e91389e12439414_p_alive ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (human_1e91389e12439414_p_alive ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (human_1e91389e12439414_p_alive ?character) (human_1e91389e12439414_p_criminal ?character) (human_1e91389e12439414_p_alive ?guard))) :implies (intends ?guard (not (human_1e91389e12439414_p_alive ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (human_1e91389e12439414_p_alive ?predator) (shared_p_consensus_3bfd6d519a861504 ?predator ?location) (human_1e91389e12439414_p_alive ?character) (shared_p_consensus_3bfd6d519a861504 ?character ?location))) :implies (intends ?predator (not (human_1e91389e12439414_p_alive ?character))))

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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_d458b45953ec44f4 ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3bfd6d519a861504 ?character ?from))
        (shared_p_consensus_3bfd6d519a861504 ?character ?to)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?location)
          (human_1e91389e12439414_p_alive ?target)
          (shared_p_consensus_3bfd6d519a861504 ?target ?location)
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
          (not (human_1e91389e12439414_p_alive ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (human_1e91389e12439414_p_alive ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (human_1e91389e12439414_p_alive ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (human_1e91389e12439414_p_alive ?target))
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?poison)
          (shared_p_consensus_d458b45953ec44f4 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?poison))
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?food))
        (not (human_1e91389e12439414_p_hungry ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (human_1e91389e12439414_p_alive ?character))
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?location)
          (shared_p_consensus_3bfd6d519a861504 ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3bfd6d519a861504 ?item ?location))
        (shared_p_consensus_d458b45953ec44f4 ?character ?item)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?location)
          (shared_p_consensus_d458b45953ec44f4 ?character ?character_item)
          (human_1e91389e12439414_p_alive ?seller)
          (shared_p_consensus_3bfd6d519a861504 ?seller ?location)
          (shared_p_consensus_3bfd6d519a861504 ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?character_item))
        (shared_p_consensus_d458b45953ec44f4 ?seller ?character_item)
        (not (shared_p_consensus_3bfd6d519a861504 ?seller_item ?location))
        (shared_p_consensus_d458b45953ec44f4 ?character ?seller_item)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?location)
          (shared_p_consensus_d458b45953ec44f4 ?character ?item)
          (human_1e91389e12439414_p_alive ?receiver)
          (shared_p_consensus_3bfd6d519a861504 ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?item))
        (shared_p_consensus_d458b45953ec44f4 ?receiver ?item)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?spell))
        (shared_p_consensus_d458b45953ec44f4 ?character ?light)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?spell)
          (shared_p_consensus_d458b45953ec44f4 ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?spell))
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?item))
        (shared_p_consensus_d458b45953ec44f4 ?character ?money)
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?spell)
          (shared_p_consensus_3bfd6d519a861504 ?character ?location)
          (human_1e91389e12439414_p_alive ?target)
          (shared_p_consensus_3bfd6d519a861504 ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?spell))
        (not (human_1e91389e12439414_p_alive ?target))
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
          (human_1e91389e12439414_p_alive ?character)
          (shared_p_consensus_d458b45953ec44f4 ?character ?spell)
          (shared_p_consensus_3bfd6d519a861504 ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d458b45953ec44f4 ?character ?spell))
        (not (shared_p_consensus_3bfd6d519a861504 ?character ?from))
        (shared_p_consensus_3bfd6d519a861504 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (shared_p_consensus_3bfd6d519a861504 ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3bfd6d519a861504 ?character ?from))
        (shared_p_consensus_3bfd6d519a861504 ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_create-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (shared_p_consensus_ff9a88689bd88cb5 ?character)
      )
    :effect
      (and
        (writing_prompts__wp_036_p_created ?character ?lightbox)
        (shared_p_consensus_d458b45953ec44f4 ?character ?lightbox)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_anchor-light
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (shared_p_consensus_d458b45953ec44f4 ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_anchored ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_charge-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_anchored ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_charged ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_use-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (shared_p_consensus_ff9a88689bd88cb5 ?character)
          (writing_prompts__wp_036_p_charged ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (shared_p_consensus_d458b45953ec44f4 ?character ?lightbox)
        )
      )
    :effect
      (and
        (writing_prompts__wp_036_p_used ?character ?lightbox)
        (not (writing_prompts__wp_036_p_charged ?lightbox))
      )
    :agents (?character)
  )
)
