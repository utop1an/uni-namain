(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_045_o_mirror - object)
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
    (shared_p_consensus_1e1af3e80ad535e8 ?v0 - object)
    (human_1e91389e12439414_p_armed ?v0 - object)
    (human_1e91389e12439414_p_dark ?v0 - object)
    (human_1e91389e12439414_p_poisoned ?v0 - object)
    (human_1e91389e12439414_p_path ?v0 - object ?v1 - object)
    (shared_p_consensus_1b341119fe0dfa4f ?v0 - object ?v1 - object)
    (human_1e91389e12439414_p_knows-location ?v0 - object ?v1 - object)
    (shared_p_consensus_c7dc0ca9a8cbc1f3 ?v0 - object ?v1 - object)
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
    (tiny_stories__story_045_active)
    (tiny_stories__story_045_type_character ?x - object)
    (tiny_stories__story_045_type_object ?x - object)
    (tiny_stories__story_045_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_045_p_shares ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (tiny_stories__story_090_p_in-drawer ?v0 - object)
    (tiny_stories__story_090_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_wants-to-take ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_brave ?v0 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
  )
  (:axiom :vars (?character - object ?item - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_location ?location) (and (not (shared_p_consensus_1e1af3e80ad535e8 ?character)) (shared_p_consensus_1b341119fe0dfa4f ?character ?location) (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item))) :implies (and (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)) (shared_p_consensus_1b341119fe0dfa4f ?item ?location)))
  (:axiom :vars (?character - object ?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (and (not (shared_p_consensus_1e1af3e80ad535e8 ?character)) (human_1e91389e12439414_p_owns ?character ?item))) :implies (not (human_1e91389e12439414_p_owns ?character ?item)))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (not (human_1e91389e12439414_p_owned ?item)) (exists (?c - object) (and (human_1e91389e12439414_type_humanoid ?c) (human_1e91389e12439414_p_owns ?c ?item))))) :implies (human_1e91389e12439414_p_owned ?item))
  (:axiom :vars (?item - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_item ?item) (and (human_1e91389e12439414_p_owned ?item) (forall (?c - object) (or (not (human_1e91389e12439414_type_humanoid ?c)) (not (human_1e91389e12439414_p_owns ?c ?item)))))) :implies (not (human_1e91389e12439414_p_owned ?item)))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (not (human_1e91389e12439414_p_armed ?character)) (exists (?w - object) (and (human_1e91389e12439414_type_weapon ?w) (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?w))))) :implies (human_1e91389e12439414_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_character ?character) (and (human_1e91389e12439414_p_armed ?character) (forall (?w - object) (or (not (human_1e91389e12439414_type_weapon ?w)) (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?w)))))) :implies (not (human_1e91389e12439414_p_armed ?character)))
  (:axiom :vars (?character - object ?item - object ?owner - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_item ?item) (human_1e91389e12439414_type_humanoid ?owner) (and (not (= ?character ?owner)) (shared_p_consensus_1e1af3e80ad535e8 ?character) (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item) (shared_p_consensus_1e1af3e80ad535e8 ?owner) (human_1e91389e12439414_p_owns ?owner ?item))) :implies (and (intends ?owner (not (shared_p_consensus_1e1af3e80ad535e8 ?character))) (when (human_1e91389e12439414_p_citizen ?owner) (human_1e91389e12439414_p_criminal ?character))))
  (:axiom :vars (?character - object ?guard - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_guard ?guard) (and (shared_p_consensus_1e1af3e80ad535e8 ?character) (human_1e91389e12439414_p_criminal ?character) (shared_p_consensus_1e1af3e80ad535e8 ?guard))) :implies (intends ?guard (not (shared_p_consensus_1e1af3e80ad535e8 ?character))))
  (:axiom :vars (?predator - object ?character - object ?location - object) :context (and (human_1e91389e12439414_active) (human_1e91389e12439414_type_predator ?predator) (human_1e91389e12439414_type_humanoid ?character) (human_1e91389e12439414_type_location ?location) (and (shared_p_consensus_1e1af3e80ad535e8 ?predator) (shared_p_consensus_1b341119fe0dfa4f ?predator ?location) (shared_p_consensus_1e1af3e80ad535e8 ?character) (shared_p_consensus_1b341119fe0dfa4f ?character ?location))) :implies (intends ?predator (not (shared_p_consensus_1e1af3e80ad535e8 ?character))))

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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?from)
          (human_1e91389e12439414_p_path ?from ?to)
          (human_1e91389e12439414_p_knows-location ?character ?to)
          (or
            (not (human_1e91389e12439414_p_dark ?to))
            (exists
              (?l - object)
              (and
                (human_1e91389e12439414_type_light ?l)
                (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?l)
              )
            )
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1b341119fe0dfa4f ?character ?from))
        (shared_p_consensus_1b341119fe0dfa4f ?character ?to)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?location)
          (shared_p_consensus_1e1af3e80ad535e8 ?target)
          (shared_p_consensus_1b341119fe0dfa4f ?target ?location)
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
          (not (shared_p_consensus_1e1af3e80ad535e8 ?target))
        )
        (when
          (and
            (human_1e91389e12439414_p_armed ?character)
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_1e1af3e80ad535e8 ?target))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (human_1e91389e12439414_p_armed ?target)
          )
          (not (shared_p_consensus_1e1af3e80ad535e8 ?character))
        )
        (when
          (and
            (not (human_1e91389e12439414_p_armed ?character))
            (not (human_1e91389e12439414_p_armed ?target))
          )
          (not (shared_p_consensus_1e1af3e80ad535e8 ?target))
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?poison)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?poison))
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?food)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?food))
        (not (human_1e91389e12439414_p_hungry ?character))
        (when
          (human_1e91389e12439414_p_poisoned ?food)
          (not (shared_p_consensus_1e1af3e80ad535e8 ?character))
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?location)
          (shared_p_consensus_1b341119fe0dfa4f ?item ?location)
          (or
            (not (human_1e91389e12439414_p_guard ?character))
            (not (human_1e91389e12439414_p_owned ?item))
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1b341119fe0dfa4f ?item ?location))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?location)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?character_item)
          (shared_p_consensus_1e1af3e80ad535e8 ?seller)
          (shared_p_consensus_1b341119fe0dfa4f ?seller ?location)
          (shared_p_consensus_1b341119fe0dfa4f ?seller_item ?location)
          (human_1e91389e12439414_p_owns ?seller ?seller_item)
          (human_1e91389e12439414_p_buying ?seller ?character_item)
          (human_1e91389e12439414_p_selling ?seller ?seller_item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?character_item))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?seller ?character_item)
        (not (shared_p_consensus_1b341119fe0dfa4f ?seller_item ?location))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?seller_item)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?location)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)
          (shared_p_consensus_1e1af3e80ad535e8 ?receiver)
          (shared_p_consensus_1b341119fe0dfa4f ?receiver ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?receiver ?item)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell)
          (human_1e91389e12439414_p_summons ?spell ?light)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?light)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)
          (human_1e91389e12439414_p_summons ?spell ?money)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell))
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item))
        (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?money)
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?location)
          (shared_p_consensus_1e1af3e80ad535e8 ?target)
          (shared_p_consensus_1b341119fe0dfa4f ?target ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell))
        (not (shared_p_consensus_1e1af3e80ad535e8 ?target))
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
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?from)
          (human_1e91389e12439414_p_leads_to ?spell ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?spell))
        (not (shared_p_consensus_1b341119fe0dfa4f ?character ?from))
        (shared_p_consensus_1b341119fe0dfa4f ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?character)
        (tiny_stories__story_045_type_object ?object)
        (not (tiny_stories__story_045_p_has ?character ?object))
      )
    :effect
      (tiny_stories__story_045_p_has ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_share
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (and
          (tiny_stories__story_045_p_has ?sharer ?object)
          (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
        )
      )
    :effect
      (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_045_a_unshare
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
      )
    :effect
      (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_090_a_find-toy
    :parameters (?character - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?character)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_p_in-drawer ?toy)
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_in-drawer ?toy))
        (tiny_stories__story_090_p_friends ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_090_a_want-to-take
    :parameters (?taker - object ?toy - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_type_character ?owner)
        (and
          (not (= ?taker ?owner))
          (tiny_stories__story_090_p_friends ?owner ?toy)
        )
      )
    :effect
      (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
    :agents (?taker)
  )

  (:action tiny_stories__story_090_a_stand-up
    :parameters (?defender - object ?taker - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?defender)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (and
          (not (= ?defender ?taker))
          (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
          (tiny_stories__story_090_p_friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_wants-to-take ?taker ?toy))
        (tiny_stories__story_090_p_brave ?defender)
      )
    :agents (?defender)
  )

  (:action writing_prompts__wp_064_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_place ?from)
        (writing_prompts__wp_064_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1b341119fe0dfa4f ?character ?from))
        (shared_p_consensus_1b341119fe0dfa4f ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_deliver
    :parameters (?character - object ?item - object ?destination - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?destination)
        (and
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?destination)
          (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item))
        (writing_prompts__wp_064_p_delivered ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_pick-up
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?place)
        (and
          (shared_p_consensus_1e1af3e80ad535e8 ?character)
          (shared_p_consensus_1b341119fe0dfa4f ?character ?place)
        )
      )
    :effect
      (shared_p_consensus_c7dc0ca9a8cbc1f3 ?character ?item)
    :agents (?character)
  )
)
