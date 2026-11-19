(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
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
    (shared_p_consensus_e8faa5d94c72ad00 ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_046f09697f63372c ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_bc8b4a07c70eeaf7 ?v0 - object ?v1 - object)
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
    (human_662247ec644ef452_p_belongsto ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_loves ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_e8faa5d94c72ad00 ?character)) (shared_p_consensus_046f09697f63372c ?character ?location) (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item))) :implies (and (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item)) (shared_p_consensus_046f09697f63372c ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_e8faa5d94c72ad00 ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_e8faa5d94c72ad00 ?character) (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item) (shared_p_consensus_e8faa5d94c72ad00 ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_e8faa5d94c72ad00 ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_e8faa5d94c72ad00 ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_e8faa5d94c72ad00 ?guard))) :implies (intends ?guard (not (shared_p_consensus_e8faa5d94c72ad00 ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_e8faa5d94c72ad00 ?predator) (shared_p_consensus_046f09697f63372c ?predator ?location) (shared_p_consensus_e8faa5d94c72ad00 ?character) (shared_p_consensus_046f09697f63372c ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_e8faa5d94c72ad00 ?character))))

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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_046f09697f63372c ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_046f09697f63372c ?character ?from))
        (shared_p_consensus_046f09697f63372c ?character ?to)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_046f09697f63372c ?character ?location)
          (shared_p_consensus_e8faa5d94c72ad00 ?target)
          (shared_p_consensus_046f09697f63372c ?target ?location)
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
          (not (shared_p_consensus_e8faa5d94c72ad00 ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_e8faa5d94c72ad00 ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_e8faa5d94c72ad00 ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_e8faa5d94c72ad00 ?target))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?poison)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?poison))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?food))
        (not (human_1e91389e12439414_p_hungry ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (shared_p_consensus_e8faa5d94c72ad00 ?character))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_046f09697f63372c ?character ?location)
          (shared_p_consensus_046f09697f63372c ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_046f09697f63372c ?item ?location))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_046f09697f63372c ?character ?location)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?character_item)
          (shared_p_consensus_e8faa5d94c72ad00 ?seller)
          (shared_p_consensus_046f09697f63372c ?seller ?location)
          (shared_p_consensus_046f09697f63372c ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?character_item))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?seller ?character_item)
        (not (shared_p_consensus_046f09697f63372c ?seller_item ?location))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?seller_item)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_046f09697f63372c ?character ?location)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item)
          (shared_p_consensus_e8faa5d94c72ad00 ?receiver)
          (shared_p_consensus_046f09697f63372c ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?receiver ?item)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?light)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell))
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?item))
        (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?money)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell)
          (shared_p_consensus_046f09697f63372c ?character ?location)
          (shared_p_consensus_e8faa5d94c72ad00 ?target)
          (shared_p_consensus_046f09697f63372c ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell))
        (not (shared_p_consensus_e8faa5d94c72ad00 ?target))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?character)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell)
          (shared_p_consensus_046f09697f63372c ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?character ?spell))
        (not (shared_p_consensus_046f09697f63372c ?character ?from))
        (shared_p_consensus_046f09697f63372c ?character ?to)
      )
    :agents (?character)
  )

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (shared_p_consensus_e8faa5d94c72ad00 ?victim)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (shared_p_consensus_e8faa5d94c72ad00 ?person))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_046f09697f63372c ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_046f09697f63372c ?person ?to)
        (not (shared_p_consensus_046f09697f63372c ?person ?from))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_046f09697f63372c ?person ?from)
          (shared_p_consensus_e8faa5d94c72ad00 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_046f09697f63372c ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_046f09697f63372c ?person ?to)
        (not (shared_p_consensus_046f09697f63372c ?person ?from))
        (shared_p_consensus_046f09697f63372c ?victim ?to)
        (not (shared_p_consensus_046f09697f63372c ?victim ?from))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_046f09697f63372c ?giver ?place)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?giver ?item)
          (shared_p_consensus_e8faa5d94c72ad00 ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_046f09697f63372c ?receiver ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_bc8b4a07c70eeaf7 ?receiver ?item)
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?giver ?item))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_046f09697f63372c ?person ?place)
          (shared_p_consensus_e8faa5d94c72ad00 ?victim)
          (shared_p_consensus_046f09697f63372c ?victim ?place)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_046f09697f63372c ?person ?place)
          (shared_p_consensus_e8faa5d94c72ad00 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_046f09697f63372c ?victim ?place)
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
          (shared_p_consensus_e8faa5d94c72ad00 ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_046f09697f63372c ?taker ?place)
          (shared_p_consensus_e8faa5d94c72ad00 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_046f09697f63372c ?victim ?place)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?victim ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_bc8b4a07c70eeaf7 ?taker ?item)
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?victim ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?victim)
          (and
            (intends ?victim (shared_p_consensus_bc8b4a07c70eeaf7 ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (shared_p_consensus_046f09697f63372c ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (shared_p_consensus_bc8b4a07c70eeaf7 ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
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
          (shared_p_consensus_e8faa5d94c72ad00 ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_046f09697f63372c ?healer ?place)
          (shared_p_consensus_bc8b4a07c70eeaf7 ?healer ?medicine)
          (shared_p_consensus_e8faa5d94c72ad00 ?patient)
          (shared_p_consensus_046f09697f63372c ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (shared_p_consensus_bc8b4a07c70eeaf7 ?healer ?medicine))
      )
    :agents (?healer ?patient)
  )
)
