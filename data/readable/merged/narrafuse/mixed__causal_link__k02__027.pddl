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
    (shared_p_consensus_b61e26e7cdb4b82a ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_fbf69e92951420ef ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_7e8db8c4d50ebfda ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_019_active)
    (writing_prompts__wp_019_type_character ?x - object)
    (writing_prompts__wp_019_type_item ?x - object)
    (writing_prompts__wp_019_type_object ?x - object)
    (writing_prompts__wp_019_type_place ?x - object)
    (writing_prompts__wp_019_p_buried ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_destroyed ?v0 - object)
    (writing_prompts__wp_019_p_explosives-set ?v0 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_b61e26e7cdb4b82a ?character)) (shared_p_consensus_fbf69e92951420ef ?character ?location) (shared_p_consensus_7e8db8c4d50ebfda ?character ?item))) :implies (and (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?item)) (shared_p_consensus_fbf69e92951420ef ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_b61e26e7cdb4b82a ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_7e8db8c4d50ebfda ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_b61e26e7cdb4b82a ?character) (shared_p_consensus_7e8db8c4d50ebfda ?character ?item) (shared_p_consensus_b61e26e7cdb4b82a ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_b61e26e7cdb4b82a ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_b61e26e7cdb4b82a ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_b61e26e7cdb4b82a ?guard))) :implies (intends ?guard (not (shared_p_consensus_b61e26e7cdb4b82a ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_b61e26e7cdb4b82a ?predator) (shared_p_consensus_fbf69e92951420ef ?predator ?location) (shared_p_consensus_b61e26e7cdb4b82a ?character) (shared_p_consensus_fbf69e92951420ef ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_b61e26e7cdb4b82a ?character))))

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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_7e8db8c4d50ebfda ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_fbf69e92951420ef ?character ?from))
        (shared_p_consensus_fbf69e92951420ef ?character ?to)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?location)
          (shared_p_consensus_b61e26e7cdb4b82a ?target)
          (shared_p_consensus_fbf69e92951420ef ?target ?location)
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
          (not (shared_p_consensus_b61e26e7cdb4b82a ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_b61e26e7cdb4b82a ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_b61e26e7cdb4b82a ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_b61e26e7cdb4b82a ?target))
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?poison)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?poison))
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?food))
        (not (human_1e91389e12439414_p_hungry ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (shared_p_consensus_b61e26e7cdb4b82a ?character))
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?location)
          (shared_p_consensus_fbf69e92951420ef ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_fbf69e92951420ef ?item ?location))
        (shared_p_consensus_7e8db8c4d50ebfda ?character ?item)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?location)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?character_item)
          (shared_p_consensus_b61e26e7cdb4b82a ?seller)
          (shared_p_consensus_fbf69e92951420ef ?seller ?location)
          (shared_p_consensus_fbf69e92951420ef ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?character_item))
        (shared_p_consensus_7e8db8c4d50ebfda ?seller ?character_item)
        (not (shared_p_consensus_fbf69e92951420ef ?seller_item ?location))
        (shared_p_consensus_7e8db8c4d50ebfda ?character ?seller_item)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?location)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?item)
          (shared_p_consensus_b61e26e7cdb4b82a ?receiver)
          (shared_p_consensus_fbf69e92951420ef ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?item))
        (shared_p_consensus_7e8db8c4d50ebfda ?receiver ?item)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell))
        (shared_p_consensus_7e8db8c4d50ebfda ?character ?light)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell))
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?item))
        (shared_p_consensus_7e8db8c4d50ebfda ?character ?money)
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell)
          (shared_p_consensus_fbf69e92951420ef ?character ?location)
          (shared_p_consensus_b61e26e7cdb4b82a ?target)
          (shared_p_consensus_fbf69e92951420ef ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell))
        (not (shared_p_consensus_b61e26e7cdb4b82a ?target))
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
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell)
          (shared_p_consensus_fbf69e92951420ef ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?spell))
        (not (shared_p_consensus_fbf69e92951420ef ?character ?from))
        (shared_p_consensus_fbf69e92951420ef ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?from)
        (writing_prompts__wp_019_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_fbf69e92951420ef ?character ?from))
        (shared_p_consensus_fbf69e92951420ef ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_set-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_fbf69e92951420ef ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_019_p_explosives-set ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_detonate-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (writing_prompts__wp_019_p_explosives-set ?place)
        )
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (writing_prompts__wp_019_type_item ?item)
            (writing_prompts__wp_019_p_buried ?item ?place)
          )
          (writing_prompts__wp_019_p_destroyed ?item)
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_destroy-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_item ?item)
        (and
          (shared_p_consensus_b61e26e7cdb4b82a ?character)
          (shared_p_consensus_7e8db8c4d50ebfda ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_7e8db8c4d50ebfda ?character ?item))
        (writing_prompts__wp_019_p_destroyed ?item)
      )
    :agents (?character)
  )
)
