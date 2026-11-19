(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants human_8fa5775aae174731_o_ark - object tiny_stories__story_035_o_tim - object tiny_stories__story_060_o_vase - object)
  (:predicates
    (human_8fa5775aae174731_active)
    (human_8fa5775aae174731_type_character ?x - object)
    (human_8fa5775aae174731_type_item ?x - object)
    (human_8fa5775aae174731_type_object ?x - object)
    (human_8fa5775aae174731_type_place ?x - object)
    (human_8fa5775aae174731_type_weapon ?x - object)
    (human_8fa5775aae174731_p_open ?v0 - object)
    (human_8fa5775aae174731_p_alive ?v0 - object)
    (human_8fa5775aae174731_p_armed ?v0 - object)
    (human_8fa5775aae174731_p_burried ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_p_knows-location ?v0 - object ?v1 - object ?v2 - object)
    (human_8fa5775aae174731_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_29f7a3e645f1f023 ?v0 - object ?v1 - object)
    (tiny_stories__story_035_active)
    (tiny_stories__story_035_type_character ?x - object)
    (tiny_stories__story_035_type_object ?x - object)
    (tiny_stories__story_035_p_birthday ?v0 - object)
    (tiny_stories__story_035_p_box-closed)
    (tiny_stories__story_035_p_box-open)
    (tiny_stories__story_035_p_cake-spoiled)
    (tiny_stories__story_035_p_cake-good)
    (tiny_stories__story_035_p_listened-to-mom ?v0 - object)
    (tiny_stories__story_035_p_waited-for-birthday ?v0 - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_happy ?v0 - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (not (human_8fa5775aae174731_p_armed ?character)) (exists (?w - object) (and (human_8fa5775aae174731_type_weapon ?w) (shared_p_consensus_29f7a3e645f1f023 ?character ?w))))) :implies (human_8fa5775aae174731_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (human_8fa5775aae174731_p_armed ?character) (forall (?w - object) (or (not (human_8fa5775aae174731_type_weapon ?w)) (not (shared_p_consensus_29f7a3e645f1f023 ?character ?w)))))) :implies (not (human_8fa5775aae174731_p_armed ?character)))

  (:action human_8fa5775aae174731_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_place ?from)
        (human_8fa5775aae174731_type_place ?to)
        (and
          (not (= ?from ?to))
          (human_8fa5775aae174731_p_alive ?character)
          (human_8fa5775aae174731_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_at ?character ?from))
        (human_8fa5775aae174731_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_excavate
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (human_8fa5775aae174731_p_alive ?character)
          (human_8fa5775aae174731_p_at ?character ?place)
          (human_8fa5775aae174731_p_burried ?item ?place)
          (human_8fa5775aae174731_p_knows-location ?character ?item ?place)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_burried ?item ?place))
        (shared_p_consensus_29f7a3e645f1f023 ?character ?item)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?giver)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?receiver)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (human_8fa5775aae174731_p_alive ?giver)
          (human_8fa5775aae174731_p_at ?giver ?place)
          (shared_p_consensus_29f7a3e645f1f023 ?giver ?item)
          (human_8fa5775aae174731_p_alive ?receiver)
          (human_8fa5775aae174731_p_at ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_29f7a3e645f1f023 ?giver ?item))
        (shared_p_consensus_29f7a3e645f1f023 ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action human_8fa5775aae174731_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?killer)
        (human_8fa5775aae174731_type_weapon ?weapon)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (human_8fa5775aae174731_p_alive ?killer)
          (human_8fa5775aae174731_p_at ?killer ?place)
          (shared_p_consensus_29f7a3e645f1f023 ?killer ?weapon)
          (human_8fa5775aae174731_p_alive ?victim)
          (human_8fa5775aae174731_p_at ?victim ?place)
        )
      )
    :effect
      (not (human_8fa5775aae174731_p_alive ?victim))
    :agents (?killer)
  )

  (:action human_8fa5775aae174731_a_take
    :parameters (?taker - object ?item - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?taker)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?taker ?victim))
          (human_8fa5775aae174731_p_alive ?taker)
          (human_8fa5775aae174731_p_at ?taker ?place)
          (or
            (not (human_8fa5775aae174731_p_alive ?victim))
            (and
              (human_8fa5775aae174731_p_armed ?taker)
              (not (human_8fa5775aae174731_p_armed ?victim))
            )
          )
          (human_8fa5775aae174731_p_at ?victim ?place)
          (shared_p_consensus_29f7a3e645f1f023 ?victim ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_29f7a3e645f1f023 ?victim ?item))
        (shared_p_consensus_29f7a3e645f1f023 ?taker ?item)
      )
    :agents (?taker)
  )

  (:action human_8fa5775aae174731_a_open-ark
    :parameters (?character - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (and
          (human_8fa5775aae174731_p_alive ?character)
          (shared_p_consensus_29f7a3e645f1f023 ?character human_8fa5775aae174731_o_ark)
        )
      )
    :effect
      (and
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
        (not (human_8fa5775aae174731_p_alive ?character))
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_close-ark
    :parameters ()
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
      )
    :effect
      (not (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark))
  )

  (:action tiny_stories__story_035_a_wait-for-birthday
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_birthday ?character))
          (not (tiny_stories__story_035_p_waited-for-birthday ?character))
        )
      )
    :effect
      (tiny_stories__story_035_p_waited-for-birthday ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_listen-to-mom
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_listened-to-mom ?character))
          (tiny_stories__story_035_p_waited-for-birthday ?character)
        )
      )
    :effect
      (tiny_stories__story_035_p_listened-to-mom ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_open-box
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (tiny_stories__story_035_p_box-closed)
          (tiny_stories__story_035_p_birthday ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_box-closed))
        (tiny_stories__story_035_p_box-open)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_spoil-cake
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (not (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim))
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_cake-good))
        (tiny_stories__story_035_p_cake-spoiled)
      )
  )

  (:action tiny_stories__story_035_a_keep-cake-good
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim)
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (tiny_stories__story_035_p_cake-good)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (shared_p_consensus_29f7a3e645f1f023 ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_060_p_at ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (tiny_stories__story_060_p_happy ?character)
    :agents (?character)
  )
)
