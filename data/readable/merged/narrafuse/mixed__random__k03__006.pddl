(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
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
    (shared_p_consensus_3fe69c8d3346c6bc ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_2e1d70c1f27c2938 ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_074_active)
    (writing_prompts__wp_074_type_character ?x - object)
    (writing_prompts__wp_074_type_object ?x - object)
    (writing_prompts__wp_074_p_influenced ?v0 - object)
    (writing_prompts__wp_074_p_isolated ?v0 - object)
    (writing_prompts__wp_074_p_hates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_manipulates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_despises ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_apologized ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (human_1e91389e12439414_p_alive ?character)) (shared_p_consensus_3fe69c8d3346c6bc ?character ?location) (shared_p_consensus_2e1d70c1f27c2938 ?character ?item))) :implies (and (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?item)) (shared_p_consensus_3fe69c8d3346c6bc ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_alive ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_2e1d70c1f27c2938 ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (human_1e91389e12439414_p_alive ?character) (shared_p_consensus_2e1d70c1f27c2938 ?character ?item) (human_1e91389e12439414_p_alive ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (human_1e91389e12439414_p_alive ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (human_1e91389e12439414_p_alive ?character) (human_1e91389e12439414_p_criminal ?character) (human_1e91389e12439414_p_alive ?guard))) :implies (intends ?guard (not (human_1e91389e12439414_p_alive ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (human_1e91389e12439414_p_alive ?predator) (shared_p_consensus_3fe69c8d3346c6bc ?predator ?location) (human_1e91389e12439414_p_alive ?character) (shared_p_consensus_3fe69c8d3346c6bc ?character ?location))) :implies (intends ?predator (not (human_1e91389e12439414_p_alive ?character))))

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
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_2e1d70c1f27c2938 ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3fe69c8d3346c6bc ?character ?from))
        (shared_p_consensus_3fe69c8d3346c6bc ?character ?to)
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
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?location)
          (human_1e91389e12439414_p_alive ?target)
          (shared_p_consensus_3fe69c8d3346c6bc ?target ?location)
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?poison)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?poison))
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?food))
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
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?location)
          (shared_p_consensus_3fe69c8d3346c6bc ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3fe69c8d3346c6bc ?item ?location))
        (shared_p_consensus_2e1d70c1f27c2938 ?character ?item)
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
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?location)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?character_item)
          (human_1e91389e12439414_p_alive ?seller)
          (shared_p_consensus_3fe69c8d3346c6bc ?seller ?location)
          (shared_p_consensus_3fe69c8d3346c6bc ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?character_item))
        (shared_p_consensus_2e1d70c1f27c2938 ?seller ?character_item)
        (not (shared_p_consensus_3fe69c8d3346c6bc ?seller_item ?location))
        (shared_p_consensus_2e1d70c1f27c2938 ?character ?seller_item)
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
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?location)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?item)
          (human_1e91389e12439414_p_alive ?receiver)
          (shared_p_consensus_3fe69c8d3346c6bc ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?item))
        (shared_p_consensus_2e1d70c1f27c2938 ?receiver ?item)
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell))
        (shared_p_consensus_2e1d70c1f27c2938 ?character ?light)
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell))
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?item))
        (shared_p_consensus_2e1d70c1f27c2938 ?character ?money)
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell)
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?location)
          (human_1e91389e12439414_p_alive ?target)
          (shared_p_consensus_3fe69c8d3346c6bc ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell))
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
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell)
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2e1d70c1f27c2938 ?character ?spell))
        (not (shared_p_consensus_3fe69c8d3346c6bc ?character ?from))
        (shared_p_consensus_3fe69c8d3346c6bc ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_074_a_influence
    :parameters (?influencer - object ?influenced - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?influencer)
        (writing_prompts__wp_074_type_character ?influenced)
        (and
          (not (= ?influencer ?influenced))
          (not (writing_prompts__wp_074_p_influenced ?influenced))
        )
      )
    :effect
      (writing_prompts__wp_074_p_influenced ?influenced)
    :agents (?influencer)
  )

  (:action writing_prompts__wp_074_a_isolate
    :parameters (?isolator - object ?isolated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?isolator)
        (writing_prompts__wp_074_type_character ?isolated)
        (and
          (not (= ?isolator ?isolated))
          (not (writing_prompts__wp_074_p_isolated ?isolated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_isolated ?isolated)
    :agents (?isolator)
  )

  (:action writing_prompts__wp_074_a_manipulate
    :parameters (?manipulator - object ?manipulated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?manipulator)
        (writing_prompts__wp_074_type_character ?manipulated)
        (and
          (not (= ?manipulator ?manipulated))
          (not (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated)
    :agents (?manipulator)
  )

  (:action writing_prompts__wp_074_a_hate
    :parameters (?hater - object ?hated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?hater)
        (writing_prompts__wp_074_type_character ?hated)
        (and
          (not (= ?hater ?hated))
          (not (writing_prompts__wp_074_p_hates ?hater ?hated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_hates ?hater ?hated)
    :agents (?hater)
  )

  (:action writing_prompts__wp_074_a_despise
    :parameters (?despiser - object ?despised - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?despiser)
        (writing_prompts__wp_074_type_character ?despised)
        (and
          (not (= ?despiser ?despised))
          (not (writing_prompts__wp_074_p_despises ?despiser ?despised))
        )
      )
    :effect
      (writing_prompts__wp_074_p_despises ?despiser ?despised)
    :agents (?despiser)
  )

  (:action writing_prompts__wp_074_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?apologizer)
        (writing_prompts__wp_074_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (writing_prompts__wp_074_p_apologized ?apologizer ?apologized))
        )
      )
    :effect
      (writing_prompts__wp_074_p_apologized ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action writing_prompts__wp_085_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (not (writing_prompts__wp_085_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_085_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_put-on-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (not (writing_prompts__wp_085_p_wearing-clothes ?character))
        )
      )
    :effect
      (writing_prompts__wp_085_p_wearing-clothes ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_turn-on-device
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?device)
          (not (writing_prompts__wp_085_p_device-on ?device))
        )
      )
    :effect
      (writing_prompts__wp_085_p_device-on ?device)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_check-connectivity
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_device-on ?device)
          (shared_p_consensus_2e1d70c1f27c2938 ?character ?device)
        )
      )
    :effect
      (when
        (writing_prompts__wp_085_p_device-connected ?device)
        (writing_prompts__wp_085_p_working ?device)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_go-outside
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_place ?place)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_wearing-clothes ?character)
          (shared_p_consensus_3fe69c8d3346c6bc ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3fe69c8d3346c6bc ?character ?place))
        (shared_p_consensus_3fe69c8d3346c6bc ?character writing_prompts__wp_085_o_outside)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_talk
    :parameters (?speaker - object ?listener - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?speaker)
        (writing_prompts__wp_085_type_character ?listener)
        (and
          (writing_prompts__wp_085_p_awake ?speaker)
          (writing_prompts__wp_085_p_awake ?listener)
          (shared_p_consensus_3fe69c8d3346c6bc ?speaker writing_prompts__wp_085_o_outside)
          (shared_p_consensus_3fe69c8d3346c6bc ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :agents (?speaker ?listener)
  )

  (:action writing_prompts__wp_085_a_cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (writing_prompts__wp_085_p_school-canceled))
      )
    :effect
      (writing_prompts__wp_085_p_school-canceled)
  )
)
