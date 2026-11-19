(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_36d2ec3e17905e8a_o_railwaydeveloper - object human_36d2ec3e17905e8a_o_thecity - object human_36d2ec3e17905e8a_o_thefarmer - object human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
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
    (human_36d2ec3e17905e8a_p_alive ?v0 - object)
    (human_36d2ec3e17905e8a_p_at ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_belongsto ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_has ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_sick ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_cures ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_loves ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_recovered ?v0 - object)
    (human_662247ec644ef452_active)
    (human_662247ec644ef452_type_animal ?x - object)
    (human_662247ec644ef452_type_item ?x - object)
    (human_662247ec644ef452_type_living ?x - object)
    (human_662247ec644ef452_type_object ?x - object)
    (human_662247ec644ef452_type_person ?x - object)
    (human_662247ec644ef452_type_place ?x - object)
    (human_662247ec644ef452_type_sickness ?x - object)
    (human_662247ec644ef452_type_valuable ?x - object)
    (human_662247ec644ef452_p_alive ?v0 - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (human_662247ec644ef452_p_at ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_belongsto ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_has ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_loves ?v0 - object ?v1 - object)
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
  )

  (:action human_36d2ec3e17905e8a_a_arrest
    :parameters (?s - object ?p - object ?l - object)
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (human_36d2ec3e17905e8a_type_sheriff ?s)
        (human_36d2ec3e17905e8a_type_person ?p)
        (human_36d2ec3e17905e8a_type_place ?l)
        (and
          (human_36d2ec3e17905e8a_p_at ?s ?l)
          (human_36d2ec3e17905e8a_p_at ?p ?l)
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
        (human_36d2ec3e17905e8a_p_alive ?p)
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
          (human_36d2ec3e17905e8a_p_alive ?p)
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
          (human_36d2ec3e17905e8a_p_alive ?p)
          (human_36d2ec3e17905e8a_p_family ?p ?f)
          (human_36d2ec3e17905e8a_p_alive ?f)
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
          (human_36d2ec3e17905e8a_p_alive ?person)
          (human_36d2ec3e17905e8a_p_healthy ?person)
          (not (human_36d2ec3e17905e8a_p_arrested ?person))
          (human_36d2ec3e17905e8a_p_at ?person ?from)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_at ?person ?to)
        (not (human_36d2ec3e17905e8a_p_at ?person ?from))
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
          (human_36d2ec3e17905e8a_p_alive ?p)
          (human_36d2ec3e17905e8a_p_at ?p ?f)
          (human_36d2ec3e17905e8a_p_themover ?p)
          (human_36d2ec3e17905e8a_p_decided-move-city)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_moved-to-city)
        (human_36d2ec3e17905e8a_p_at ?p ?t)
        (not (human_36d2ec3e17905e8a_p_at ?p ?t))
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
          (human_36d2ec3e17905e8a_p_at ?p ?l)
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
          (human_36d2ec3e17905e8a_p_at ?p1 ?l)
          (human_36d2ec3e17905e8a_p_at ?p2 ?l)
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
          (human_36d2ec3e17905e8a_p_at ?p ?l)
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
          (human_36d2ec3e17905e8a_p_at ?p ?l)
          (human_36d2ec3e17905e8a_p_at ?h ?l)
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

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_p_alive ?victim)
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (human_662247ec644ef452_p_alive ?person))
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (human_662247ec644ef452_p_at ?person ?from)
        )
      )
    :effect
      (and
        (human_662247ec644ef452_p_at ?person ?to)
        (not (human_662247ec644ef452_p_at ?person ?from))
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (human_662247ec644ef452_p_at ?person ?from)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (human_662247ec644ef452_p_at ?victim ?from)
        )
      )
    :effect
      (and
        (human_662247ec644ef452_p_at ?person ?to)
        (not (human_662247ec644ef452_p_at ?person ?from))
        (human_662247ec644ef452_p_at ?victim ?to)
        (not (human_662247ec644ef452_p_at ?victim ?from))
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
          (human_662247ec644ef452_p_alive ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (human_662247ec644ef452_p_at ?giver ?place)
          (human_662247ec644ef452_p_has ?giver ?item)
          (human_662247ec644ef452_p_alive ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (human_662247ec644ef452_p_at ?receiver ?place)
        )
      )
    :effect
      (and
        (human_662247ec644ef452_p_has ?receiver ?item)
        (not (human_662247ec644ef452_p_has ?giver ?item))
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (human_662247ec644ef452_p_at ?person ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (human_662247ec644ef452_p_at ?victim ?place)
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
          (human_662247ec644ef452_p_alive ?person)
          (human_662247ec644ef452_p_free ?person)
          (human_662247ec644ef452_p_at ?person ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (human_662247ec644ef452_p_at ?victim ?place)
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
          (human_662247ec644ef452_p_alive ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (human_662247ec644ef452_p_at ?taker ?place)
          (human_662247ec644ef452_p_alive ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (human_662247ec644ef452_p_at ?victim ?place)
          (human_662247ec644ef452_p_has ?victim ?item)
        )
      )
    :effect
      (and
        (human_662247ec644ef452_p_has ?taker ?item)
        (not (human_662247ec644ef452_p_has ?victim ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?victim)
          (and
            (intends ?victim (human_662247ec644ef452_p_has ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (human_662247ec644ef452_p_at ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (human_662247ec644ef452_p_has ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
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
          (human_662247ec644ef452_p_alive ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (human_662247ec644ef452_p_at ?healer ?place)
          (human_662247ec644ef452_p_has ?healer ?medicine)
          (human_662247ec644ef452_p_alive ?patient)
          (human_662247ec644ef452_p_at ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (human_662247ec644ef452_p_has ?healer ?medicine))
      )
    :agents (?healer ?patient)
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
)
