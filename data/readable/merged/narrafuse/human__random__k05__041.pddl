(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_36d2ec3e17905e8a_o_railwaydeveloper - object human_36d2ec3e17905e8a_o_thecity - object human_36d2ec3e17905e8a_o_thefarmer - object human_8fa5775aae174731_o_ark - object)
  (:predicates
    (human_36d2ec3e17905e8a_active)
    (human_36d2ec3e17905e8a_type_animal ?x - object)
    (human_36d2ec3e17905e8a_type_city ?x - object)
    (human_36d2ec3e17905e8a_type_dairyfarmer ?x - object)
    (human_36d2ec3e17905e8a_type_item ?x - object)
    (human_36d2ec3e17905e8a_type_object ?x - object)
    (human_36d2ec3e17905e8a_type_person ?x - object)
    (human_36d2ec3e17905e8a_type_place ?x - object)
    (human_36d2ec3e17905e8a_type_ranch ?x - object)
    (human_36d2ec3e17905e8a_type_rancher ?x - object)
    (human_36d2ec3e17905e8a_type_saloon ?x - object)
    (human_36d2ec3e17905e8a_type_sheriff ?x - object)
    (human_36d2ec3e17905e8a_type_sickness ?x - object)
    (human_36d2ec3e17905e8a_type_son ?x - object)
    (human_36d2ec3e17905e8a_type_texasranger ?x - object)
    (human_36d2ec3e17905e8a_type_valuable ?x - object)
    (human_36d2ec3e17905e8a_p_thefarmchar ?v0 - object)
    (human_36d2ec3e17905e8a_p_themover ?v0 - object)
    (human_36d2ec3e17905e8a_p_thecriminal ?v0 - object)
    (human_36d2ec3e17905e8a_p_theinvalid ?v0 - object)
    (human_36d2ec3e17905e8a_p_invalid-unwell)
    (human_36d2ec3e17905e8a_p_invalid-recovered)
    (human_36d2ec3e17905e8a_p_done-crime ?v0 - object)
    (human_36d2ec3e17905e8a_p_crime-done)
    (human_36d2ec3e17905e8a_p_arrested ?v0 - object)
    (human_36d2ec3e17905e8a_p_criminal-arrested)
    (human_36d2ec3e17905e8a_p_thearrester ?v0 - object)
    (human_36d2ec3e17905e8a_p_family ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_survived-winter)
    (human_36d2ec3e17905e8a_p_has-axe ?v0 - object)
    (human_36d2ec3e17905e8a_p_spring)
    (human_36d2ec3e17905e8a_p_autumn)
    (human_36d2ec3e17905e8a_p_winter)
    (human_36d2ec3e17905e8a_p_prepared-for-winter)
    (human_36d2ec3e17905e8a_p_has-medicine ?v0 - object)
    (human_36d2ec3e17905e8a_p_healthy ?v0 - object)
    (human_36d2ec3e17905e8a_p_family-ok)
    (human_36d2ec3e17905e8a_p_winter-proofed-house)
    (human_36d2ec3e17905e8a_p_has-firewood ?v0 - object)
    (human_36d2ec3e17905e8a_p_decided-move-city)
    (human_36d2ec3e17905e8a_p_has-cash ?v0 - object)
    (human_36d2ec3e17905e8a_p_wants ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_owns ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_has-ticket ?v0 - object)
    (human_36d2ec3e17905e8a_p_moved-to-city)
    (shared_p_consensus_6c8eaac82b3dfcf5 ?v0 - object)
    (shared_p_consensus_1c8096fb3f6d1b91 ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_belongsto ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_has ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_sick ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_cures ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_loves ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_recovered ?v0 - object)
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_8a3eb7870e80d6a8 ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_active)
    (human_8fa5775aae174731_type_character ?x - object)
    (human_8fa5775aae174731_type_item ?x - object)
    (human_8fa5775aae174731_type_object ?x - object)
    (human_8fa5775aae174731_type_place ?x - object)
    (human_8fa5775aae174731_type_weapon ?x - object)
    (human_8fa5775aae174731_p_open ?v0 - object)
    (human_8fa5775aae174731_p_armed ?v0 - object)
    (human_8fa5775aae174731_p_burried ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_p_knows-location ?v0 - object ?v1 - object ?v2 - object)
    (shared_p_consensus_8271540c172814fc ?v0 - object ?v1 - object)
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
    (human_ab9663f1e67ea2f0_p_at ?v0 - object ?v1 - object)
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
    (human_cf10335d299ae37f_active)
    (human_cf10335d299ae37f_type_creature ?x - object)
    (human_cf10335d299ae37f_type_landform ?x - object)
    (human_cf10335d299ae37f_type_object ?x - object)
    (human_cf10335d299ae37f_type_place ?x - object)
    (human_cf10335d299ae37f_type_ship ?x - object)
    (human_cf10335d299ae37f_p_alive ?v0 - object)
    (human_cf10335d299ae37f_p_stunned ?v0 - object)
    (human_cf10335d299ae37f_p_habitable ?v0 - object)
    (human_cf10335d299ae37f_p_safe ?v0 - object)
    (human_cf10335d299ae37f_p_erupting ?v0 - object)
    (human_cf10335d299ae37f_p_fighting ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_friends ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_captain ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_guardian ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (not (human_8fa5775aae174731_p_armed ?character)) (exists (?w - object) (and (human_8fa5775aae174731_type_weapon ?w) (shared_p_consensus_8a3eb7870e80d6a8 ?character ?w))))) :implies (human_8fa5775aae174731_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (human_8fa5775aae174731_p_armed ?character) (forall (?w - object) (or (not (human_8fa5775aae174731_type_weapon ?w)) (not (shared_p_consensus_8a3eb7870e80d6a8 ?character ?w)))))) :implies (not (human_8fa5775aae174731_p_armed ?character)))

  (:action human_36d2ec3e17905e8a_a_arrest
    :parameters (?s - object ?p - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_sheriff ?s)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (shared_p_consensus_1c8096fb3f6d1b91 ?s ?l)
          (shared_p_consensus_1c8096fb3f6d1b91 ?p ?l)
          (human_36d2ec3e17905e8a_p_done-crime ?p)
          (not (human_36d2ec3e17905e8a_p_arrested ?p))
          (human_36d2ec3e17905e8a_p_thecriminal ?p)
          (not (human_36d2ec3e17905e8a_p_criminal-arrested))
          (human_36d2ec3e17905e8a_p_thearrester ?s)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_arrested ?p)
        (human_36d2ec3e17905e8a_p_criminal-arrested)
      )
  )

  (:action human_36d2ec3e17905e8a_a_repair-house
    :parameters (?p - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (shared_p_consensus_6c8eaac82b3dfcf5 ?p)
      )
    :effect
      (human_36d2ec3e17905e8a_p_winter-proofed-house)
  )

  (:action human_36d2ec3e17905e8a_a_prepare-for-winter
    :parameters (?p - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (and
          (human_36d2ec3e17905e8a_p_autumn)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?p)
          (human_36d2ec3e17905e8a_p_winter-proofed-house)
          (human_36d2ec3e17905e8a_p_has-firewood ?p)
        )
      )
    :effect
      (human_36d2ec3e17905e8a_p_prepared-for-winter)
  )

  (:action human_36d2ec3e17905e8a_a_turn-into-winter
    :parameters ()
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (and
          (human_36d2ec3e17905e8a_p_autumn)
          (human_36d2ec3e17905e8a_p_prepared-for-winter)
        )
      )
    :effect
      (and
        (not (human_36d2ec3e17905e8a_p_autumn))
        (human_36d2ec3e17905e8a_p_winter)
      )
  )

  (:action human_36d2ec3e17905e8a_a_live-through-winter
    :parameters (?p - object ?f - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_person ?f)
        (and
          (human_36d2ec3e17905e8a_p_winter)
          (human_36d2ec3e17905e8a_p_family ?p ?f)
          (human_36d2ec3e17905e8a_p_healthy ?f)
        )
      )
    :effect
      (and
        (not (human_36d2ec3e17905e8a_p_winter))
        (human_36d2ec3e17905e8a_p_spring)
      )
  )

  (:action human_36d2ec3e17905e8a_a_survived
    :parameters (?p - object ?f - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_rancher ?p)
        (human_36d2ec3e17905e8a_type_person ?f)
        (and
          (human_36d2ec3e17905e8a_p_spring)
          (human_36d2ec3e17905e8a_p_thefarmchar ?p)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?p)
          (human_36d2ec3e17905e8a_p_family ?p ?f)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?f)
        )
      )
    :effect
      (human_36d2ec3e17905e8a_p_survived-winter)
  )

  (:action human_36d2ec3e17905e8a_a_travel
    :parameters (?person - object ?from - object ?to - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?person)
        (human_36d2ec3e17905e8a_type_place ?from)
        (human_36d2ec3e17905e8a_type_place ?to)
        (and
          (not (= ?to human_36d2ec3e17905e8a_o_thecity))
          (not (= ?to ?from))
          (shared_p_consensus_6c8eaac82b3dfcf5 ?person)
          (human_36d2ec3e17905e8a_p_healthy ?person)
          (not (human_36d2ec3e17905e8a_p_arrested ?person))
          (shared_p_consensus_1c8096fb3f6d1b91 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_1c8096fb3f6d1b91 ?person ?to)
        (not (shared_p_consensus_1c8096fb3f6d1b91 ?person ?from))
      )
  )

  (:action human_36d2ec3e17905e8a_a_travel-to-city
    :parameters (?p - object ?f - object ?t - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_place ?f)
        (human_36d2ec3e17905e8a_type_place ?t)
        (and
          (= ?t human_36d2ec3e17905e8a_o_thecity)
          (not (= ?t ?f))
          (human_36d2ec3e17905e8a_p_has-ticket ?p)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?p)
          (shared_p_consensus_1c8096fb3f6d1b91 ?p ?f)
          (human_36d2ec3e17905e8a_p_themover ?p)
          (human_36d2ec3e17905e8a_p_decided-move-city)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_moved-to-city)
        (shared_p_consensus_1c8096fb3f6d1b91 ?p ?t)
        (not (shared_p_consensus_1c8096fb3f6d1b91 ?p ?t))
      )
  )

  (:action human_36d2ec3e17905e8a_a_sell-land
    :parameters (?p1 - object ?p2 - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_rancher ?p1)
        (human_36d2ec3e17905e8a_type_person ?p2)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (human_36d2ec3e17905e8a_p_owns ?p1 ?l)
          (human_36d2ec3e17905e8a_p_wants ?p2 ?l)
          (human_36d2ec3e17905e8a_p_has-cash ?p2)
          (human_36d2ec3e17905e8a_p_decided-move-city)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_has-cash ?p1)
        (not (human_36d2ec3e17905e8a_p_has-cash ?p2))
        (human_36d2ec3e17905e8a_p_owns ?p2 ?l)
        (not (human_36d2ec3e17905e8a_p_owns ?p1 ?l))
      )
  )

  (:action human_36d2ec3e17905e8a_a_decide-to-move-to-city
    :parameters (?p - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_rancher ?p)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (shared_p_consensus_1c8096fb3f6d1b91 ?p ?l)
          (human_36d2ec3e17905e8a_p_themover ?p)
        )
      )
    :effect
      (human_36d2ec3e17905e8a_p_decided-move-city)
  )

  (:action human_36d2ec3e17905e8a_a_buy-ticket
    :parameters (?p - object ?r - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_person ?r)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (human_36d2ec3e17905e8a_p_has-cash ?p)
          (= ?r human_36d2ec3e17905e8a_o_railwaydeveloper)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_has-ticket ?p)
        (not (human_36d2ec3e17905e8a_p_has-cash ?p))
        (human_36d2ec3e17905e8a_p_has-cash ?r)
      )
  )

  (:action human_36d2ec3e17905e8a_a_steal-cash
    :parameters (?p1 - object ?p2 - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p1)
        (human_36d2ec3e17905e8a_type_person ?p2)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (shared_p_consensus_1c8096fb3f6d1b91 ?p1 ?l)
          (shared_p_consensus_1c8096fb3f6d1b91 ?p2 ?l)
          (human_36d2ec3e17905e8a_p_has-cash ?p2)
          (human_36d2ec3e17905e8a_p_thecriminal ?p1)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_has-cash ?p1)
        (not (human_36d2ec3e17905e8a_p_has-cash ?p2))
        (human_36d2ec3e17905e8a_p_done-crime ?p1)
        (human_36d2ec3e17905e8a_p_crime-done)
      )
  )

  (:action human_36d2ec3e17905e8a_a_steal-medicine
    :parameters (?p - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (shared_p_consensus_1c8096fb3f6d1b91 ?p ?l)
          (human_36d2ec3e17905e8a_p_theinvalid ?p)
          (human_36d2ec3e17905e8a_p_invalid-unwell)
          (not (human_36d2ec3e17905e8a_p_has-cash ?p))
        )
      )
    :effect
      (human_36d2ec3e17905e8a_p_has-medicine ?p)
  )

  (:action human_36d2ec3e17905e8a_a_steal-firewood
    :parameters (?p1 - object ?p2 - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p1)
        (human_36d2ec3e17905e8a_type_person ?p2)
        (human_36d2ec3e17905e8a_p_has-firewood ?p2)
      )
    :effect
      (not (human_36d2ec3e17905e8a_p_has-firewood ?p2))
  )

  (:action human_36d2ec3e17905e8a_a_chop-wood
    :parameters (?p - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (not (human_36d2ec3e17905e8a_p_has-firewood ?p))
      )
    :effect
      (human_36d2ec3e17905e8a_p_has-firewood ?p)
  )

  (:action human_36d2ec3e17905e8a_a_get-snake-bite
    :parameters (?v - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?v)
        (and
          (human_36d2ec3e17905e8a_p_healthy ?v)
          (human_36d2ec3e17905e8a_p_theinvalid ?v)
        )
      )
    :effect
      (and
        (not (human_36d2ec3e17905e8a_p_healthy ?v))
        (human_36d2ec3e17905e8a_p_invalid-unwell)
        (not (human_36d2ec3e17905e8a_p_invalid-recovered))
      )
  )

  (:action human_36d2ec3e17905e8a_a_get-medicine
    :parameters (?p - object ?h - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_person ?h)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (human_36d2ec3e17905e8a_p_has-cash ?p)
          (not (human_36d2ec3e17905e8a_p_has-medicine ?p))
          (human_36d2ec3e17905e8a_p_has-medicine ?h)
          (shared_p_consensus_1c8096fb3f6d1b91 ?p ?l)
          (shared_p_consensus_1c8096fb3f6d1b91 ?h ?l)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_has-medicine ?p)
        (not (human_36d2ec3e17905e8a_p_has-cash ?p))
        (human_36d2ec3e17905e8a_p_has-cash ?h)
        (not (human_36d2ec3e17905e8a_p_has-medicine ?h))
      )
  )

  (:action human_36d2ec3e17905e8a_a_heal
    :parameters (?h - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_rancher ?h)
        (and
          (human_36d2ec3e17905e8a_p_has-medicine ?h)
          (not (human_36d2ec3e17905e8a_p_healthy ?h))
          (human_36d2ec3e17905e8a_p_theinvalid ?h)
          (human_36d2ec3e17905e8a_p_invalid-unwell)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_healthy ?h)
        (not (human_36d2ec3e17905e8a_p_has-medicine ?h))
        (human_36d2ec3e17905e8a_p_recovered ?h)
        (not (human_36d2ec3e17905e8a_p_invalid-unwell))
        (human_36d2ec3e17905e8a_p_invalid-recovered)
      )
  )

  (:action human_36d2ec3e17905e8a_a_recover
    :parameters (?p - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_person ?p)
        (and
          (not (= ?p human_36d2ec3e17905e8a_o_thefarmer))
          (human_36d2ec3e17905e8a_p_has-medicine ?p)
          (not (human_36d2ec3e17905e8a_p_healthy ?p))
          (human_36d2ec3e17905e8a_p_theinvalid ?p)
          (human_36d2ec3e17905e8a_p_invalid-unwell)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_healthy ?p)
        (not (human_36d2ec3e17905e8a_p_has-medicine ?p))
        (human_36d2ec3e17905e8a_p_recovered ?p)
        (not (human_36d2ec3e17905e8a_p_invalid-unwell))
        (human_36d2ec3e17905e8a_p_invalid-recovered)
      )
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
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_1c8096fb3f6d1b91 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1c8096fb3f6d1b91 ?character ?roomfrom))
        (shared_p_consensus_1c8096fb3f6d1b91 ?character ?roomto)
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
          (shared_p_consensus_1c8096fb3f6d1b91 ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_8a3eb7870e80d6a8 ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
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
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (shared_p_consensus_8a3eb7870e80d6a8 ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
  )

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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?character)
          (shared_p_consensus_8271540c172814fc ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8271540c172814fc ?character ?from))
        (shared_p_consensus_8271540c172814fc ?character ?to)
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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?character)
          (shared_p_consensus_8271540c172814fc ?character ?place)
          (human_8fa5775aae174731_p_burried ?item ?place)
          (human_8fa5775aae174731_p_knows-location ?character ?item ?place)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_burried ?item ?place))
        (shared_p_consensus_8a3eb7870e80d6a8 ?character ?item)
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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?giver)
          (shared_p_consensus_8271540c172814fc ?giver ?place)
          (shared_p_consensus_8a3eb7870e80d6a8 ?giver ?item)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?receiver)
          (shared_p_consensus_8271540c172814fc ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8a3eb7870e80d6a8 ?giver ?item))
        (shared_p_consensus_8a3eb7870e80d6a8 ?receiver ?item)
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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?killer)
          (shared_p_consensus_8271540c172814fc ?killer ?place)
          (shared_p_consensus_8a3eb7870e80d6a8 ?killer ?weapon)
          (shared_p_consensus_6c8eaac82b3dfcf5 ?victim)
          (shared_p_consensus_8271540c172814fc ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_6c8eaac82b3dfcf5 ?victim))
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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?taker)
          (shared_p_consensus_8271540c172814fc ?taker ?place)
          (or
            (not (shared_p_consensus_6c8eaac82b3dfcf5 ?victim))
            (and
              (human_8fa5775aae174731_p_armed ?taker)
              (not (human_8fa5775aae174731_p_armed ?victim))
            )
          )
          (shared_p_consensus_8271540c172814fc ?victim ?place)
          (shared_p_consensus_8a3eb7870e80d6a8 ?victim ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8a3eb7870e80d6a8 ?victim ?item))
        (shared_p_consensus_8a3eb7870e80d6a8 ?taker ?item)
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
          (shared_p_consensus_6c8eaac82b3dfcf5 ?character)
          (shared_p_consensus_8a3eb7870e80d6a8 ?character human_8fa5775aae174731_o_ark)
        )
      )
    :effect
      (and
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
        (not (shared_p_consensus_6c8eaac82b3dfcf5 ?character))
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

  (:action human_ab9663f1e67ea2f0_a_pick-up
    :parameters (?person - object ?thing - object ?place - object)
    :precondition
      (and
        (human_ab9663f1e67ea2f0_active)
        (human_ab9663f1e67ea2f0_type_person ?person)
        (human_ab9663f1e67ea2f0_type_thing ?thing)
        (human_ab9663f1e67ea2f0_type_place ?place)
        (and
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?thing ?place)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?thing ?place))
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?gun ?place)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?gun ?place))
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
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
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
        (human_ab9663f1e67ea2f0_p_at ?person ?store)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?thing)
          (human_ab9663f1e67ea2f0_p_at ?buyer ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?store)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?store)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?roadblock ?place)
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
        (human_ab9663f1e67ea2f0_p_at ?person ?alley)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?alley)
          (human_ab9663f1e67ea2f0_p_at ?mark ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?drinker ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?poker ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
          (human_ab9663f1e67ea2f0_p_at ?friend ?from)
          (human_ab9663f1e67ea2f0_p_drunk ?friend)
          (human_ab9663f1e67ea2f0_p_friendly ?friend ?person)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?friend ?from))
        (human_ab9663f1e67ea2f0_p_at ?friend ?to)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?friend ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?sleeper ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?pawn-broker ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?seller ?place)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?from)
          (human_ab9663f1e67ea2f0_p_at ?horse ?from)
          (human_ab9663f1e67ea2f0_p_has ?person ?horse)
        )
      )
    :effect
      (and
        (human_ab9663f1e67ea2f0_p_at ?person ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?person ?from))
        (human_ab9663f1e67ea2f0_p_at ?horse ?to)
        (not (human_ab9663f1e67ea2f0_p_at ?horse ?from))
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
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?bank)
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
          (human_ab9663f1e67ea2f0_p_at ?person ?place)
          (human_ab9663f1e67ea2f0_p_at ?horse ?place)
          (human_ab9663f1e67ea2f0_p_has ?person ?mother-lode)
        )
      )
    :effect
      (and
        (not (human_ab9663f1e67ea2f0_p_at ?person ?place))
        (not (human_ab9663f1e67ea2f0_p_at ?horse ?place))
        (human_ab9663f1e67ea2f0_p_free-with-money ?person)
        (human_ab9663f1e67ea2f0_p_at ?person ?dest)
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
          (human_ab9663f1e67ea2f0_p_at ?sheriff ?place)
          (human_ab9663f1e67ea2f0_p_at ?criminal ?place)
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

  (:action human_cf10335d299ae37f_a_walk
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_landform ?from)
        (human_cf10335d299ae37f_type_landform ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_8271540c172814fc ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (forall
            (?c - object)
            (or
              (not (human_cf10335d299ae37f_type_creature ?c))
              (and
                (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
                (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              )
            )
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_8271540c172814fc ?creature ?to)
        (not (shared_p_consensus_8271540c172814fc ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-from-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_ship ?from)
        (human_cf10335d299ae37f_type_place ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_8271540c172814fc ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_8271540c172814fc ?creature ?to)
        (not (shared_p_consensus_8271540c172814fc ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              (when
                (human_cf10335d299ae37f_p_guardian ?c ?to)
                (intends ?c (not (human_cf10335d299ae37f_p_alive ?creature)))
              )
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-to-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?from)
        (human_cf10335d299ae37f_type_ship ?to)
        (and
          (not (= ?from ?to))
          (human_cf10335d299ae37f_p_alive ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_8271540c172814fc ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?to)
        )
      )
    :effect
      (and
        (shared_p_consensus_8271540c172814fc ?creature ?to)
        (not (shared_p_consensus_8271540c172814fc ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_attack
    :parameters (?attacker - object ?victim - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?attacker)
        (human_cf10335d299ae37f_type_creature ?victim)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (human_cf10335d299ae37f_p_alive ?attacker)
          (not (human_cf10335d299ae37f_p_stunned ?attacker))
          (shared_p_consensus_8271540c172814fc ?attacker ?place)
          (human_cf10335d299ae37f_p_alive ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (shared_p_consensus_8271540c172814fc ?victim ?place)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_fighting ?attacker ?victim)
        (intends ?victim (not (human_cf10335d299ae37f_p_fighting ?attacker ?victim)))
      )
    :agents (?attacker)
  )

  (:action human_cf10335d299ae37f_a_kill
    :parameters (?killer - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?killer)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?killer)
          (not (human_cf10335d299ae37f_p_stunned ?killer))
          (human_cf10335d299ae37f_p_alive ?victim)
          (or
            (human_cf10335d299ae37f_p_fighting ?killer ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          )
        )
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_alive ?victim))
        (when
          (human_cf10335d299ae37f_p_fighting ?killer ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?killer ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?killer))
        )
      )
    :agents (?killer)
  )

  (:action human_cf10335d299ae37f_a_stun
    :parameters (?stunner - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?stunner)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?stunner)
          (not (human_cf10335d299ae37f_p_stunned ?stunner))
          (human_cf10335d299ae37f_p_alive ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (or
            (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          )
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_stunned ?victim)
        (when
          (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?stunner ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?stunner))
        )
      )
    :agents (?stunner)
  )

  (:action human_cf10335d299ae37f_a_break-free
    :parameters (?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (human_cf10335d299ae37f_p_alive ?victim)
          (human_cf10335d299ae37f_p_stunned ?victim)
        )
      )
    :effect
      (not (human_cf10335d299ae37f_p_stunned ?victim))
    :agents (?victim)
  )

  (:action human_cf10335d299ae37f_a_make-peace
    :parameters (?peacemaker - object ?creature - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?peacemaker)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (human_cf10335d299ae37f_p_alive ?peacemaker)
          (not (human_cf10335d299ae37f_p_stunned ?peacemaker))
          (shared_p_consensus_8271540c172814fc ?peacemaker ?place)
          (human_cf10335d299ae37f_p_alive ?creature)
          (shared_p_consensus_8271540c172814fc ?creature ?place)
          (not (human_cf10335d299ae37f_p_fighting ?peacemaker ?creature))
          (not (human_cf10335d299ae37f_p_fighting ?creature ?peacemaker))
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_friends ?peacemaker ?creature)
        (human_cf10335d299ae37f_p_friends ?creature ?peacemaker)
      )
    :agents (?peacemaker)
  )

  (:action human_cf10335d299ae37f_a_begin-erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_erupting ?landform)
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (shared_p_consensus_8271540c172814fc ?c ?landform)
            )
            (and
              (not (human_cf10335d299ae37f_p_safe ?c))
              (intends ?c (human_cf10335d299ae37f_p_safe ?c))
            )
          )
        )
      )
  )

  (:action human_cf10335d299ae37f_a_erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
        (human_cf10335d299ae37f_p_erupting ?landform)
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_habitable ?landform))
        (not (human_cf10335d299ae37f_p_erupting ?landform))
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (shared_p_consensus_8271540c172814fc ?c ?landform)
            )
            (not (human_cf10335d299ae37f_p_alive ?c))
          )
        )
      )
  )
)
