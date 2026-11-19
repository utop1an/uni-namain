(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :domain-axioms :equality :intentionality :negative-preconditions :strips :typing)
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
    (shared_p_consensus_012faaa48f5d8a8e ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_6eb1b6fda00b5d10 ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_63523128a54053aa ?v0 - object ?v1 - object)
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
    (human_230a940d5d5977a6_active)
    (human_230a940d5d5977a6_type_actor ?x - object)
    (human_230a940d5d5977a6_type_allpolice ?x - object)
    (human_230a940d5d5977a6_type_car ?x - object)
    (human_230a940d5d5977a6_type_citizen ?x - object)
    (human_230a940d5d5977a6_type_crime ?x - object)
    (human_230a940d5d5977a6_type_detective ?x - object)
    (human_230a940d5d5977a6_type_inspector ?x - object)
    (human_230a940d5d5977a6_type_item ?x - object)
    (human_230a940d5d5977a6_type_motorbike ?x - object)
    (human_230a940d5d5977a6_type_object ?x - object)
    (human_230a940d5d5977a6_type_place ?x - object)
    (human_230a940d5d5977a6_type_police ?x - object)
    (human_230a940d5d5977a6_type_trafficcop ?x - object)
    (human_230a940d5d5977a6_type_vehicle ?x - object)
    (human_230a940d5d5977a6_p_arrester ?v0 - object)
    (human_230a940d5d5977a6_p_arrester-at ?v0 - object)
    (shared_p_consensus_d124bfab1514147b ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_under-arrest ?v0 - object)
    (human_230a940d5d5977a6_p_angry ?v0 - object)
    (human_230a940d5d5977a6_p_knows-clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_suspect ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_murder-clue ?v0 - object)
    (human_230a940d5d5977a6_p_clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_is-basketball-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-theft ?v0 - object)
    (human_230a940d5d5977a6_p_is-arrest-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-murder ?v0 - object)
    (human_230a940d5d5977a6_p_has-car ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_working ?v0 - object)
    (human_3cd8b87ba572801b_active)
    (human_3cd8b87ba572801b_type_aristocrat ?x - object)
    (human_3cd8b87ba572801b_type_canmarry ?x - object)
    (human_3cd8b87ba572801b_type_character ?x - object)
    (human_3cd8b87ba572801b_type_dragon ?x - object)
    (human_3cd8b87ba572801b_type_emperor ?x - object)
    (human_3cd8b87ba572801b_type_female ?x - object)
    (human_3cd8b87ba572801b_type_genie ?x - object)
    (human_3cd8b87ba572801b_type_ismagic ?x - object)
    (human_3cd8b87ba572801b_type_king ?x - object)
    (human_3cd8b87ba572801b_type_knight ?x - object)
    (human_3cd8b87ba572801b_type_location ?x - object)
    (human_3cd8b87ba572801b_type_lord ?x - object)
    (human_3cd8b87ba572801b_type_male ?x - object)
    (human_3cd8b87ba572801b_type_monarch ?x - object)
    (human_3cd8b87ba572801b_type_monster ?x - object)
    (human_3cd8b87ba572801b_type_object ?x - object)
    (human_3cd8b87ba572801b_type_person ?x - object)
    (human_3cd8b87ba572801b_type_princess ?x - object)
    (human_3cd8b87ba572801b_type_spirit ?x - object)
    (human_3cd8b87ba572801b_type_thing ?x - object)
    (human_3cd8b87ba572801b_type_zombie ?x - object)
    (human_3cd8b87ba572801b_p_bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_bachelor-loves ?v0 - object)
    (human_3cd8b87ba572801b_p_loves-bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_magic-char ?v0 - object)
    (human_3cd8b87ba572801b_p_controls-magic ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_magic-char-alive)
    (human_3cd8b87ba572801b_p_scary ?v0 - object)
    (human_3cd8b87ba572801b_p_single ?v0 - object)
    (human_3cd8b87ba572801b_p_beautiful ?v0 - object)
    (human_3cd8b87ba572801b_p_magic ?v0 - object)
    (human_3cd8b87ba572801b_p_controls ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_married-to ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loves ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loyal-to ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_has ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (shared_p_consensus_0f420d4ef11a2e5a ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_012faaa48f5d8a8e ?character)) (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location) (shared_p_consensus_63523128a54053aa ?character ?item))) :implies (and (not (shared_p_consensus_63523128a54053aa ?character ?item)) (shared_p_consensus_6eb1b6fda00b5d10 ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_012faaa48f5d8a8e ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_63523128a54053aa ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_63523128a54053aa ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_012faaa48f5d8a8e ?character) (shared_p_consensus_63523128a54053aa ?character ?item) (shared_p_consensus_012faaa48f5d8a8e ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_012faaa48f5d8a8e ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_012faaa48f5d8a8e ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_012faaa48f5d8a8e ?guard))) :implies (intends ?guard (not (shared_p_consensus_012faaa48f5d8a8e ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_012faaa48f5d8a8e ?predator) (shared_p_consensus_6eb1b6fda00b5d10 ?predator ?location) (shared_p_consensus_012faaa48f5d8a8e ?character) (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_012faaa48f5d8a8e ?character))))

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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_63523128a54053aa ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from))
        (shared_p_consensus_6eb1b6fda00b5d10 ?character ?to)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location)
          (shared_p_consensus_012faaa48f5d8a8e ?target)
          (shared_p_consensus_6eb1b6fda00b5d10 ?target ?location)
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
          (not (shared_p_consensus_012faaa48f5d8a8e ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_012faaa48f5d8a8e ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_012faaa48f5d8a8e ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_012faaa48f5d8a8e ?target))
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?poison)
          (shared_p_consensus_63523128a54053aa ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?poison))
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?food))
        (not (human_1e91389e12439414_p_hungry ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (shared_p_consensus_012faaa48f5d8a8e ?character))
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location)
          (shared_p_consensus_6eb1b6fda00b5d10 ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6eb1b6fda00b5d10 ?item ?location))
        (shared_p_consensus_63523128a54053aa ?character ?item)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location)
          (shared_p_consensus_63523128a54053aa ?character ?character_item)
          (shared_p_consensus_012faaa48f5d8a8e ?seller)
          (shared_p_consensus_6eb1b6fda00b5d10 ?seller ?location)
          (shared_p_consensus_6eb1b6fda00b5d10 ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?character_item))
        (shared_p_consensus_63523128a54053aa ?seller ?character_item)
        (not (shared_p_consensus_6eb1b6fda00b5d10 ?seller_item ?location))
        (shared_p_consensus_63523128a54053aa ?character ?seller_item)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location)
          (shared_p_consensus_63523128a54053aa ?character ?item)
          (shared_p_consensus_012faaa48f5d8a8e ?receiver)
          (shared_p_consensus_6eb1b6fda00b5d10 ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?item))
        (shared_p_consensus_63523128a54053aa ?receiver ?item)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?spell))
        (shared_p_consensus_63523128a54053aa ?character ?light)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?spell)
          (shared_p_consensus_63523128a54053aa ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?spell))
        (not (shared_p_consensus_63523128a54053aa ?character ?item))
        (shared_p_consensus_63523128a54053aa ?character ?money)
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?spell)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?location)
          (shared_p_consensus_012faaa48f5d8a8e ?target)
          (shared_p_consensus_6eb1b6fda00b5d10 ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?spell))
        (not (shared_p_consensus_012faaa48f5d8a8e ?target))
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
          (shared_p_consensus_012faaa48f5d8a8e ?character)
          (shared_p_consensus_63523128a54053aa ?character ?spell)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?spell))
        (not (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from))
        (shared_p_consensus_6eb1b6fda00b5d10 ?character ?to)
      )
    :agents (?character)
  )

  (:action human_230a940d5d5977a6_a_travel
    :parameters (?a - object ?c - object ?p1 - object ?p2 - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_car ?c)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (and
          (human_230a940d5d5977a6_p_working ?c)
          (shared_p_consensus_d124bfab1514147b ?a ?p1)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?a ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?a ?p1))
        (when
          (human_230a940d5d5977a6_p_arrester ?a)
          (and
            (human_230a940d5d5977a6_p_arrester-at ?p2)
            (not (human_230a940d5d5977a6_p_arrester-at ?p1))
          )
        )
      )
  )

  (:action human_230a940d5d5977a6_a_arrest
    :parameters (?p - object ?a - object ?p1 - object ?p2 - object ?c - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?p)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (human_230a940d5d5977a6_type_crime ?c)
        (and
          (shared_p_consensus_d124bfab1514147b ?p ?p1)
          (shared_p_consensus_d124bfab1514147b ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (shared_p_consensus_012faaa48f5d8a8e ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?a ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?a ?p1))
        (shared_p_consensus_d124bfab1514147b ?p ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?p ?p1))
        (human_230a940d5d5977a6_p_under-arrest ?a)
      )
  )

  (:action human_230a940d5d5977a6_a_steal
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_63523128a54053aa ?b ?i)
          (not (= ?a ?b))
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_63523128a54053aa ?a ?i)
        (not (shared_p_consensus_63523128a54053aa ?b ?i))
        (human_230a940d5d5977a6_p_angry ?b)
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_play-basketball
    :parameters (?a - object ?b - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_is-basketball-place ?p)
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?b)
          (not (= ?a ?b))
        )
      )
    :effect
      (and
        (not (human_230a940d5d5977a6_p_angry ?a))
        (not (human_230a940d5d5977a6_p_angry ?b))
      )
  )

  (:action human_230a940d5d5977a6_a_kill
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_012faaa48f5d8a8e ?b)
          (not (= ?a ?b))
          (shared_p_consensus_63523128a54053aa ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_012faaa48f5d8a8e ?b))
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_findclues
    :parameters (?a - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_shareclues
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_police ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?b)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?b ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_suspect-of-crime
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (shared_p_consensus_63523128a54053aa ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action human_3cd8b87ba572801b_a_travel
    :parameters (?traveller - object ?from - object ?to - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?traveller)
        (human_3cd8b87ba572801b_type_location ?from)
        (human_3cd8b87ba572801b_type_location ?to)
        (and
          (shared_p_consensus_d124bfab1514147b ?traveller ?from)
          (shared_p_consensus_0f420d4ef11a2e5a ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?traveller ?to)
        (not (shared_p_consensus_d124bfab1514147b ?traveller ?from))
      )
  )

  (:action human_3cd8b87ba572801b_a_slay
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?slayer ?place)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_0f420d4ef11a2e5a ?slayer)
          (shared_p_consensus_0f420d4ef11a2e5a ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (shared_p_consensus_0f420d4ef11a2e5a ?m))
  )

  (:action human_3cd8b87ba572801b_a_slay-magic-char
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?slayer ?place)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_0f420d4ef11a2e5a ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (shared_p_consensus_0f420d4ef11a2e5a ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0f420d4ef11a2e5a ?m))
        (human_3cd8b87ba572801b_p_magic-char ?m)
        (not (human_3cd8b87ba572801b_p_magic-char-alive))
      )
  )

  (:action human_3cd8b87ba572801b_a_pillage
    :parameters (?pillager - object ?body - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?pillager)
        (human_3cd8b87ba572801b_type_character ?body)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?pillager ?place)
          (shared_p_consensus_d124bfab1514147b ?body ?place)
          (shared_p_consensus_0f420d4ef11a2e5a ?pillager)
          (not (shared_p_consensus_0f420d4ef11a2e5a ?body))
          (human_3cd8b87ba572801b_p_has ?body ?t)
          (not (human_3cd8b87ba572801b_p_has ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?pillager ?t)
        (not (human_3cd8b87ba572801b_p_has ?body ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_give
    :parameters (?giver - object ?givee - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?giver)
        (human_3cd8b87ba572801b_type_character ?givee)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (not (= ?giver ?givee))
          (shared_p_consensus_d124bfab1514147b ?giver ?place)
          (shared_p_consensus_d124bfab1514147b ?givee ?place)
          (shared_p_consensus_0f420d4ef11a2e5a ?givee)
          (shared_p_consensus_0f420d4ef11a2e5a ?giver)
          (human_3cd8b87ba572801b_p_has ?giver ?t)
          (not (human_3cd8b87ba572801b_p_has ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?givee ?t)
        (not (human_3cd8b87ba572801b_p_has ?giver ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_summon
    :parameters (?char - object ?g - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_ismagic ?g)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_confined ?g)
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (shared_p_consensus_0f420d4ef11a2e5a ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?g ?place)
        (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
        (human_3cd8b87ba572801b_p_controls-magic ?char ?lamp)
        (not (human_3cd8b87ba572801b_p_in ?g ?lamp))
        (not (human_3cd8b87ba572801b_p_confined ?g))
      )
  )

  (:action human_3cd8b87ba572801b_a_love-spell
    :parameters (?g - object ?target - object ?lover - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?target)
        (human_3cd8b87ba572801b_type_canmarry ?lover)
        (and
          (not (human_3cd8b87ba572801b_p_confined ?g))
          (not (human_3cd8b87ba572801b_p_loves ?target ?lover))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_0f420d4ef11a2e5a ?target)
          (shared_p_consensus_0f420d4ef11a2e5a ?lover)
          (not (= ?g ?target))
          (not (= ?g ?lover))
          (not (= ?target ?lover))
          (human_3cd8b87ba572801b_p_intends-loves ?g ?target ?lover)
          (human_3cd8b87ba572801b_p_bachelor ?lover)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?target ?lover)
        (human_3cd8b87ba572801b_p_loves-bachelor ?target)
      )
  )

  (:action human_3cd8b87ba572801b_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?groom)
        (human_3cd8b87ba572801b_type_person ?bride)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_0f420d4ef11a2e5a ?groom)
          (shared_p_consensus_0f420d4ef11a2e5a ?bride)
          (shared_p_consensus_d124bfab1514147b ?groom ?place)
          (shared_p_consensus_d124bfab1514147b ?bride ?place)
          (human_3cd8b87ba572801b_p_loves ?groom ?bride)
          (human_3cd8b87ba572801b_p_loves ?bride ?groom)
          (human_3cd8b87ba572801b_p_single ?groom)
          (human_3cd8b87ba572801b_p_bachelor ?groom)
          (human_3cd8b87ba572801b_p_single ?bride)
          (not (= ?groom ?bride))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_married-to ?groom ?bride)
        (human_3cd8b87ba572801b_p_married-to ?bride ?groom)
        (not (human_3cd8b87ba572801b_p_single ?groom))
        (not (human_3cd8b87ba572801b_p_single ?bride))
      )
  )

  (:action human_3cd8b87ba572801b_a_fall-in-love
    :parameters (?m - object ?f - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?m)
        (human_3cd8b87ba572801b_type_female ?f)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_bachelor ?m)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_d124bfab1514147b ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (shared_p_consensus_0f420d4ef11a2e5a ?m)
          (shared_p_consensus_0f420d4ef11a2e5a ?f)
          (not (human_3cd8b87ba572801b_p_loves ?m ?f))
          (human_3cd8b87ba572801b_p_beautiful ?f)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?m ?f)
        (human_3cd8b87ba572801b_p_bachelor-loves ?f)
      )
  )

  (:action human_3cd8b87ba572801b_a_order
    :parameters (?ki - object ?kn - object ?place - object ?t - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_king ?ki)
        (human_3cd8b87ba572801b_type_knight ?kn)
        (human_3cd8b87ba572801b_type_location ?place)
        (human_3cd8b87ba572801b_type_thing ?t)
        (and
          (human_3cd8b87ba572801b_p_loyal-to ?kn ?ki)
          (shared_p_consensus_0f420d4ef11a2e5a ?kn)
          (shared_p_consensus_0f420d4ef11a2e5a ?ki)
          (shared_p_consensus_d124bfab1514147b ?ki ?place)
          (shared_p_consensus_d124bfab1514147b ?kn ?place)
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-has ?kn ?ki ?t)
  )

  (:action human_3cd8b87ba572801b_a_appear-threatening
    :parameters (?m - object ?char - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_0f420d4ef11a2e5a ?m)
          (shared_p_consensus_0f420d4ef11a2e5a ?char)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (human_3cd8b87ba572801b_p_scary ?m)
          (not (= ?m ?char))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-not-alive ?char ?m)
  )

  (:action human_3cd8b87ba572801b_a_command
    :parameters (?char - object ?g - object ?love - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?love)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (shared_p_consensus_0f420d4ef11a2e5a ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_0f420d4ef11a2e5a ?love)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (shared_p_consensus_d124bfab1514147b ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6eb1b6fda00b5d10 ?character ?from))
        (shared_p_consensus_6eb1b6fda00b5d10 ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (shared_p_consensus_6eb1b6fda00b5d10 ?interrogator ?location)
          (shared_p_consensus_6eb1b6fda00b5d10 ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (shared_p_consensus_6eb1b6fda00b5d10 ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (shared_p_consensus_6eb1b6fda00b5d10 ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (shared_p_consensus_6eb1b6fda00b5d10 ?saver ?location)
          (shared_p_consensus_6eb1b6fda00b5d10 ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (shared_p_consensus_6eb1b6fda00b5d10 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (shared_p_consensus_0f420d4ef11a2e5a ?notsaved))
      )
    :agents (?saver)
  )
)
