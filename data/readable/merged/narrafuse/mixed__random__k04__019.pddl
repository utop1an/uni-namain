(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_36d2ec3e17905e8a_o_railwaydeveloper - object human_36d2ec3e17905e8a_o_thecity - object human_36d2ec3e17905e8a_o_thefarmer - object tiny_stories__story_008_o_ball - object)
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
    (shared_p_consensus_62a91647f34507c4 ?v0 - object)
    (human_36d2ec3e17905e8a_p_at ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_belongsto ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_has ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_sick ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_cures ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_loves ?v0 - object ?v1 - object)
    (human_36d2ec3e17905e8a_p_recovered ?v0 - object)
    (tiny_stories__story_008_active)
    (tiny_stories__story_008_type_character ?x - object)
    (tiny_stories__story_008_type_item ?x - object)
    (tiny_stories__story_008_type_object ?x - object)
    (tiny_stories__story_008_type_toy ?x - object)
    (tiny_stories__story_008_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_008_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_008_p_played-together ?v0 - object ?v1 - object)
    (tiny_stories__story_008_p_happy ?v0 - object)
    (writing_prompts__wp_016_active)
    (writing_prompts__wp_016_type_character ?x - object)
    (writing_prompts__wp_016_type_item ?x - object)
    (writing_prompts__wp_016_type_object ?x - object)
    (writing_prompts__wp_016_type_place ?x - object)
    (writing_prompts__wp_016_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_p_knows-survival-skills ?v0 - object)
    (writing_prompts__wp_016_p_computers-working)
    (writing_prompts__wp_016_p_caused-apocalypse ?v0 - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (writing_prompts__wp_031_p_alive ?v0 - object)
    (writing_prompts__wp_031_p_on-ship ?v0 - object ?v1 - object)
    (writing_prompts__wp_031_p_moby-dick-spotted ?v0 - object)
    (writing_prompts__wp_031_p_moby-dick-attacking ?v0 - object)
    (writing_prompts__wp_031_p_read-moby-dick ?v0 - object)
    (writing_prompts__wp_031_p_trained-in-whale-killing ?v0 - object)
    (writing_prompts__wp_031_p_battle-stations ?v0 - object)
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
        (shared_p_consensus_62a91647f34507c4 ?p)
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
          (shared_p_consensus_62a91647f34507c4 ?p)
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
          (shared_p_consensus_62a91647f34507c4 ?p)
          (human_36d2ec3e17905e8a_p_family ?p ?f)
          (shared_p_consensus_62a91647f34507c4 ?f)
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
          (shared_p_consensus_62a91647f34507c4 ?person)
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
          (shared_p_consensus_62a91647f34507c4 ?p)
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

  (:action tiny_stories__story_008_a_give-toy
    :parameters (?giver - object ?toy - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_008_active)
        (tiny_stories__story_008_type_character ?giver)
        (tiny_stories__story_008_type_toy ?toy)
        (tiny_stories__story_008_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (tiny_stories__story_008_p_has ?giver ?toy)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_008_p_has ?giver ?toy))
        (tiny_stories__story_008_p_has ?receiver ?toy)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_008_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_008_active)
        (tiny_stories__story_008_type_character ?character1)
        (tiny_stories__story_008_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_008_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_008_a_play-together
    :parameters (?character1 - object ?character2 - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_008_active)
        (tiny_stories__story_008_type_character ?character1)
        (tiny_stories__story_008_type_character ?character2)
        (tiny_stories__story_008_type_toy ?toy)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_008_p_has ?character1 ?toy)
          (tiny_stories__story_008_p_friends ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_008_p_played-together ?character1 ?character2)
        (tiny_stories__story_008_p_happy ?character1)
        (tiny_stories__story_008_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_016_a_learn-survival-skills
    :parameters (?learner - object ?teacher - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?learner)
        (writing_prompts__wp_016_type_character ?teacher)
        (and
          (shared_p_consensus_62a91647f34507c4 ?learner)
          (shared_p_consensus_62a91647f34507c4 ?teacher)
          (writing_prompts__wp_016_p_knows-survival-skills ?teacher)
          (not (writing_prompts__wp_016_p_knows-survival-skills ?learner))
        )
      )
    :effect
      (writing_prompts__wp_016_p_knows-survival-skills ?learner)
    :agents (?learner ?teacher)
  )

  (:action writing_prompts__wp_016_a_cause-apocalypse
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?character)
        (and
          (shared_p_consensus_62a91647f34507c4 ?character)
          (writing_prompts__wp_016_p_computers-working)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_016_p_computers-working))
        (writing_prompts__wp_016_p_caused-apocalypse ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_016_a_kill
    :parameters (?killer - object ?victim - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?killer)
        (writing_prompts__wp_016_type_character ?victim)
        (and
          (shared_p_consensus_62a91647f34507c4 ?killer)
          (shared_p_consensus_62a91647f34507c4 ?victim)
          (not (= ?killer ?victim))
        )
      )
    :effect
      (not (shared_p_consensus_62a91647f34507c4 ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_031_a_spot-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_moby-dick-attack
    :parameters (?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_ship ?ship)
        (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
  )

  (:action writing_prompts__wp_031_a_order-battle-stations
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_battle-stations ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_try-kill-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
          (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
          (writing_prompts__wp_031_p_battle-stations ?ship)
        )
      )
    :effect
      (not (writing_prompts__wp_031_p_moby-dick-attacking ?ship))
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_read-moby-dick
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_031_p_read-moby-dick ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_train-in-whale-killing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_read-moby-dick ?character)
      )
    :effect
      (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
    :agents (?character)
  )
)
