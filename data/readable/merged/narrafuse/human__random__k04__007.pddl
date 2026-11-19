(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing :universal-preconditions)
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
    (shared_p_consensus_c8721ef8a753bbb3 ?v0 - object ?v1 - object)
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
    (shared_p_consensus_c62101cda8c0d677 ?v0 - object ?v1 - object)
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
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (shared_p_consensus_e0fb843b926a896e ?v0 - object)
    (shared_p_consensus_caef1caec545cbba ?v0 - object ?v1 - object)
    (shared_p_consensus_a99b83d6e8676154 ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_804301514d612d1d ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_active)
    (human_7c98a61edf861243_type_character ?x - object)
    (human_7c98a61edf861243_type_key ?x - object)
    (human_7c98a61edf861243_type_letter ?x - object)
    (human_7c98a61edf861243_type_object ?x - object)
    (human_7c98a61edf861243_type_room ?x - object)
    (human_7c98a61edf861243_type_star ?x - object)
    (human_7c98a61edf861243_type_thing ?x - object)
    (human_7c98a61edf861243_p_hidden ?v0 - object)
    (human_7c98a61edf861243_p_believes-locked ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-at ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-unlocked-by ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-in ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-hidden ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-has ?v0 - object ?v1 - object ?v2 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_012faaa48f5d8a8e ?character)) (shared_p_consensus_c8721ef8a753bbb3 ?character ?location) (shared_p_consensus_63523128a54053aa ?character ?item))) :implies (and (not (shared_p_consensus_63523128a54053aa ?character ?item)) (shared_p_consensus_c8721ef8a753bbb3 ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_012faaa48f5d8a8e ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_63523128a54053aa ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_63523128a54053aa ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_012faaa48f5d8a8e ?character) (shared_p_consensus_63523128a54053aa ?character ?item) (shared_p_consensus_012faaa48f5d8a8e ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_012faaa48f5d8a8e ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_012faaa48f5d8a8e ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_012faaa48f5d8a8e ?guard))) :implies (intends ?guard (not (shared_p_consensus_012faaa48f5d8a8e ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_012faaa48f5d8a8e ?predator) (shared_p_consensus_c8721ef8a753bbb3 ?predator ?location) (shared_p_consensus_012faaa48f5d8a8e ?character) (shared_p_consensus_c8721ef8a753bbb3 ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_012faaa48f5d8a8e ?character))))

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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?from)
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
        (not (shared_p_consensus_c8721ef8a753bbb3 ?character ?from))
        (shared_p_consensus_c8721ef8a753bbb3 ?character ?to)
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?location)
          (shared_p_consensus_012faaa48f5d8a8e ?target)
          (shared_p_consensus_c8721ef8a753bbb3 ?target ?location)
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?location)
          (shared_p_consensus_c8721ef8a753bbb3 ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c8721ef8a753bbb3 ?item ?location))
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?location)
          (shared_p_consensus_63523128a54053aa ?character ?character_item)
          (shared_p_consensus_012faaa48f5d8a8e ?seller)
          (shared_p_consensus_c8721ef8a753bbb3 ?seller ?location)
          (shared_p_consensus_c8721ef8a753bbb3 ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?character_item))
        (shared_p_consensus_63523128a54053aa ?seller ?character_item)
        (not (shared_p_consensus_c8721ef8a753bbb3 ?seller_item ?location))
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?location)
          (shared_p_consensus_63523128a54053aa ?character ?item)
          (shared_p_consensus_012faaa48f5d8a8e ?receiver)
          (shared_p_consensus_c8721ef8a753bbb3 ?receiver ?location)
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?location)
          (shared_p_consensus_012faaa48f5d8a8e ?target)
          (shared_p_consensus_c8721ef8a753bbb3 ?target ?location)
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
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_63523128a54053aa ?character ?spell))
        (not (shared_p_consensus_c8721ef8a753bbb3 ?character ?from))
        (shared_p_consensus_c8721ef8a753bbb3 ?character ?to)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p1)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_c62101cda8c0d677 ?a ?p2)
        (not (shared_p_consensus_c62101cda8c0d677 ?a ?p1))
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
          (shared_p_consensus_c62101cda8c0d677 ?p ?p1)
          (shared_p_consensus_c62101cda8c0d677 ?a ?p1)
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
        (shared_p_consensus_c62101cda8c0d677 ?a ?p2)
        (not (shared_p_consensus_c62101cda8c0d677 ?a ?p1))
        (shared_p_consensus_c62101cda8c0d677 ?p ?p2)
        (not (shared_p_consensus_c62101cda8c0d677 ?p ?p1))
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
          (shared_p_consensus_c62101cda8c0d677 ?b ?p)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_c62101cda8c0d677 ?b ?p)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
          (shared_p_consensus_c62101cda8c0d677 ?b ?p)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_c62101cda8c0d677 ?b ?p)
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
          (shared_p_consensus_c62101cda8c0d677 ?a ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?a)
          (shared_p_consensus_c62101cda8c0d677 ?b ?p)
          (shared_p_consensus_012faaa48f5d8a8e ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (shared_p_consensus_63523128a54053aa ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (shared_p_consensus_e0fb843b926a896e ?roomto))
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c8721ef8a753bbb3 ?character ?roomfrom))
        (shared_p_consensus_c8721ef8a753bbb3 ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_c8721ef8a753bbb3 ?character ?room)
          (shared_p_consensus_a99b83d6e8676154 ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_804301514d612d1d ?character ?thing)
        (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_caef1caec545cbba ?room ?key)
          (shared_p_consensus_804301514d612d1d ?character ?key)
        )
      )
    :effect
      (not (shared_p_consensus_e0fb843b926a896e ?room))
  )

  (:action human_7c98a61edf861243_a_enter-success
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (shared_p_consensus_e0fb843b926a896e ?roomto))
          (shared_p_consensus_c62101cda8c0d677 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c62101cda8c0d677 ?character ?roomfrom))
        (shared_p_consensus_c62101cda8c0d677 ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (shared_p_consensus_c62101cda8c0d677 ?char2 ?roomto)
            )
            (and
              (human_7c98a61edf861243_p_believes-at ?character ?char2 ?roomto)
              (human_7c98a61edf861243_p_believes-at ?char2 ?character ?roomto)
            )
          )
        )
        (forall
          (?thing - object)
          (when
            (and
              (human_7c98a61edf861243_type_thing ?thing)
              (and
                (shared_p_consensus_a99b83d6e8676154 ?thing ?roomto)
                (not (human_7c98a61edf861243_p_hidden ?thing))
              )
            )
            (human_7c98a61edf861243_p_believes-in ?character ?thing ?roomto)
          )
        )
        (not (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom))
        (human_7c98a61edf861243_p_believes-at ?character ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_enter-fail
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (and (not (shared_p_consensus_e0fb843b926a896e ?roomto)) (shared_p_consensus_c62101cda8c0d677 ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_e0fb843b926a896e ?roomto)
          (shared_p_consensus_c62101cda8c0d677 ?character ?roomfrom)
        )
        (human_7c98a61edf861243_p_believes-locked ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_in
    :parameters (?informant - object ?in_thing - object ?in_room - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_thing ?in_thing)
        (human_7c98a61edf861243_type_room ?in_room)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_c62101cda8c0d677 ?informant ?room)
          (shared_p_consensus_c62101cda8c0d677 ?informed ?room)
          (human_7c98a61edf861243_p_believes-in ?informant ?in_thing ?in_room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_c62101cda8c0d677 ?informant ?room)
          (shared_p_consensus_c62101cda8c0d677 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-in ?informed ?in_thing ?in_room)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_unlocked-by
    :parameters (?informant - object ?unlocked-by_room - object ?unlocked-by_key - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_room ?unlocked-by_room)
        (human_7c98a61edf861243_type_key ?unlocked-by_key)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_c62101cda8c0d677 ?informant ?room)
          (shared_p_consensus_c62101cda8c0d677 ?informed ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?informant ?unlocked-by_room ?unlocked-by_key)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_c62101cda8c0d677 ?informant ?room)
          (shared_p_consensus_c62101cda8c0d677 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-unlocked-by ?informed ?unlocked-by_room ?unlocked-by_key)
      )
  )

  (:action human_7c98a61edf861243_a_search-for-success
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (shared_p_consensus_c62101cda8c0d677 ?character ?room)
          (shared_p_consensus_a99b83d6e8676154 ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_804301514d612d1d ?character ?thing)
        (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
        (human_7c98a61edf861243_p_believes-has ?character ?character ?thing)
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_search-for-fail
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (not (and (shared_p_consensus_c62101cda8c0d677 ?character ?room) (shared_p_consensus_a99b83d6e8676154 ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (shared_p_consensus_a99b83d6e8676154 ?thing ?room))
          (shared_p_consensus_c62101cda8c0d677 ?character ?room)
        )
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-success
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_caef1caec545cbba ?room ?key)
          (shared_p_consensus_804301514d612d1d ?character ?key)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e0fb843b926a896e ?room))
        (not (human_7c98a61edf861243_p_believes-locked ?character ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-fail
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (not (and (shared_p_consensus_e0fb843b926a896e ?room) (shared_p_consensus_caef1caec545cbba ?room ?key) (shared_p_consensus_804301514d612d1d ?character ?key)))
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_e0fb843b926a896e ?room)
          (shared_p_consensus_804301514d612d1d ?character ?key)
          (not (shared_p_consensus_caef1caec545cbba ?room ?key))
        )
        (not (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key))
      )
  )
)
