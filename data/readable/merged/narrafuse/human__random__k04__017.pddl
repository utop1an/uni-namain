(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_36d2ec3e17905e8a_o_railwaydeveloper - object human_36d2ec3e17905e8a_o_thecity - object human_36d2ec3e17905e8a_o_thefarmer - object human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object)
  (:predicates
    (human_1fe4b2f08d46fd1e_active)
    (human_1fe4b2f08d46fd1e_type_creature ?x - object)
    (human_1fe4b2f08d46fd1e_type_item ?x - object)
    (human_1fe4b2f08d46fd1e_type_monster ?x - object)
    (human_1fe4b2f08d46fd1e_type_object ?x - object)
    (human_1fe4b2f08d46fd1e_type_person ?x - object)
    (human_1fe4b2f08d46fd1e_type_place ?x - object)
    (human_1fe4b2f08d46fd1e_type_valuable ?x - object)
    (shared_p_consensus_4288513489576a5a ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (shared_p_consensus_f6bbc5df8e22aee7 ?v0 - object ?v1 - object)
    (shared_p_consensus_399e50af7e951219 ?v0 - object ?v1 - object)
    (shared_p_consensus_2480b9295c28aaa9 ?v0 - object ?v1 - object)
    (shared_p_consensus_5b2b3bfe7c0edb14 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
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
    (shared_p_consensus_2f85a3975e7cfe68 ?v0 - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (shared_p_consensus_3d693b867690a304 ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_active)
    (human_df5671d8ba8d67d9_type_character ?x - object)
    (human_df5671d8ba8d67d9_type_doctor ?x - object)
    (human_df5671d8ba8d67d9_type_drugloc ?x - object)
    (human_df5671d8ba8d67d9_type_emergencyloc ?x - object)
    (human_df5671d8ba8d67d9_type_exteriorloc ?x - object)
    (human_df5671d8ba8d67d9_type_family ?x - object)
    (human_df5671d8ba8d67d9_type_familyloc ?x - object)
    (human_df5671d8ba8d67d9_type_generalloc ?x - object)
    (human_df5671d8ba8d67d9_type_intern ?x - object)
    (human_df5671d8ba8d67d9_type_level ?x - object)
    (human_df5671d8ba8d67d9_type_location ?x - object)
    (human_df5671d8ba8d67d9_type_medicalcharacter ?x - object)
    (human_df5671d8ba8d67d9_type_medicalloc ?x - object)
    (human_df5671d8ba8d67d9_type_nurse ?x - object)
    (human_df5671d8ba8d67d9_type_object ?x - object)
    (human_df5671d8ba8d67d9_type_patient ?x - object)
    (human_df5671d8ba8d67d9_type_staffloc ?x - object)
    (human_df5671d8ba8d67d9_type_symptom ?x - object)
    (human_df5671d8ba8d67d9_type_treatment ?x - object)
    (human_df5671d8ba8d67d9_p_the-doctor ?v0 - object)
    (human_df5671d8ba8d67d9_p_the-doctor-treating ?v0 - object)
    (human_df5671d8ba8d67d9_p_the-doctor-overworked)
    (human_df5671d8ba8d67d9_p_the-doctor-mistake)
    (human_df5671d8ba8d67d9_p_has-symptom ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_conscious ?v0 - object)
    (human_df5671d8ba8d67d9_p_unconscious ?v0 - object)
    (human_df5671d8ba8d67d9_p_patient-room ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_occupied ?v0 - object)
    (human_df5671d8ba8d67d9_p_treatment-for ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_male ?v0 - object)
    (human_df5671d8ba8d67d9_p_female ?v0 - object)
    (human_df5671d8ba8d67d9_p_hospitalised ?v0 - object)
    (human_df5671d8ba8d67d9_p_wrong-treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_receiving-treatment ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_level-of-work ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_connected ?v0 - object ?v1 - object)
  )

  (:action human_1fe4b2f08d46fd1e_a_travel
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?from)
        (human_1fe4b2f08d46fd1e_type_place ?to)
        (and
          (shared_p_consensus_4288513489576a5a ?creature)
          (shared_p_consensus_f6bbc5df8e22aee7 ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_f6bbc5df8e22aee7 ?creature ?to)
        (not (shared_p_consensus_f6bbc5df8e22aee7 ?creature ?from))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_propose
    :parameters (?proposer - object ?proposee - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_person ?proposee)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (shared_p_consensus_4288513489576a5a ?proposer)
          (shared_p_consensus_f6bbc5df8e22aee7 ?proposer ?place)
          (shared_p_consensus_4288513489576a5a ?proposee)
          (shared_p_consensus_f6bbc5df8e22aee7 ?proposee ?place)
          (shared_p_consensus_5b2b3bfe7c0edb14 ?proposer ?proposee)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?proposee)
    :agents (?proposer)
  )

  (:action human_1fe4b2f08d46fd1e_a_accept
    :parameters (?accepter - object ?proposer - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?accepter)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (shared_p_consensus_4288513489576a5a ?accepter)
          (shared_p_consensus_f6bbc5df8e22aee7 ?accepter ?place)
          (shared_p_consensus_4288513489576a5a ?proposer)
          (shared_p_consensus_f6bbc5df8e22aee7 ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?accepter)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasaccepted ?accepter ?proposer)
    :agents (?accepter)
  )

  (:action human_1fe4b2f08d46fd1e_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?groom)
        (human_1fe4b2f08d46fd1e_type_person ?bride)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (shared_p_consensus_4288513489576a5a ?groom)
          (shared_p_consensus_f6bbc5df8e22aee7 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (shared_p_consensus_4288513489576a5a ?bride)
          (shared_p_consensus_f6bbc5df8e22aee7 ?bride ?place)
          (human_1fe4b2f08d46fd1e_p_hasaccepted ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_single ?bride)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_marriedto ?groom ?bride)
        (human_1fe4b2f08d46fd1e_p_marriedto ?bride ?groom)
        (not (human_1fe4b2f08d46fd1e_p_single ?groom))
        (not (human_1fe4b2f08d46fd1e_p_single ?bride))
        (forall
          (?v - object)
          (when
            (and
              (human_1fe4b2f08d46fd1e_type_valuable ?v)
              (shared_p_consensus_399e50af7e951219 ?groom ?v)
            )
            (human_1fe4b2f08d46fd1e_p_rich ?bride)
          )
        )
        (when
          (shared_p_consensus_5b2b3bfe7c0edb14 ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_happy ?groom)
        )
        (when
          (shared_p_consensus_5b2b3bfe7c0edb14 ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_happy ?bride)
        )
      )
    :agents (?groom ?bride)
  )

  (:action human_1fe4b2f08d46fd1e_a_steal
    :parameters (?thief - object ?victim - object ?item - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?thief)
        (human_1fe4b2f08d46fd1e_type_creature ?victim)
        (human_1fe4b2f08d46fd1e_type_item ?item)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (not (= ?thief ?victim))
          (shared_p_consensus_4288513489576a5a ?thief)
          (shared_p_consensus_f6bbc5df8e22aee7 ?thief ?place)
          (shared_p_consensus_f6bbc5df8e22aee7 ?item ?place)
          (shared_p_consensus_2480b9295c28aaa9 ?item ?victim)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?thief ?item)
        (when
          (shared_p_consensus_f6bbc5df8e22aee7 ?victim ?place)
          (intends ?victim (shared_p_consensus_399e50af7e951219 ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (shared_p_consensus_399e50af7e951219 ?victim ?v))
            )
          )
          (not (human_1fe4b2f08d46fd1e_p_rich ?victim))
        )
      )
    :agents (?thief)
  )

  (:action human_1fe4b2f08d46fd1e_a_get-hungry
    :parameters (?creature - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (not (human_1fe4b2f08d46fd1e_p_hungry ?creature))
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_hungry ?creature)
        (intends ?creature (not (human_1fe4b2f08d46fd1e_p_hungry ?creature)))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_eat
    :parameters (?monster - object ?creature - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_monster ?monster)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (shared_p_consensus_4288513489576a5a ?monster)
          (shared_p_consensus_f6bbc5df8e22aee7 ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (shared_p_consensus_4288513489576a5a ?creature)
          (shared_p_consensus_f6bbc5df8e22aee7 ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (shared_p_consensus_4288513489576a5a ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (human_1fe4b2f08d46fd1e_p_happy ?creature))
      )
    :agents (?monster)
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
          (shared_p_consensus_f6bbc5df8e22aee7 ?s ?l)
          (shared_p_consensus_f6bbc5df8e22aee7 ?p ?l)
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
        (shared_p_consensus_4288513489576a5a ?p)
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
          (shared_p_consensus_4288513489576a5a ?p)
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
          (shared_p_consensus_4288513489576a5a ?p)
          (human_36d2ec3e17905e8a_p_family ?p ?f)
          (shared_p_consensus_4288513489576a5a ?f)
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
          (shared_p_consensus_4288513489576a5a ?person)
          (human_36d2ec3e17905e8a_p_healthy ?person)
          (not (human_36d2ec3e17905e8a_p_arrested ?person))
          (shared_p_consensus_f6bbc5df8e22aee7 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_f6bbc5df8e22aee7 ?person ?to)
        (not (shared_p_consensus_f6bbc5df8e22aee7 ?person ?from))
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
          (shared_p_consensus_4288513489576a5a ?p)
          (shared_p_consensus_f6bbc5df8e22aee7 ?p ?f)
          (human_36d2ec3e17905e8a_p_themover ?p)
          (human_36d2ec3e17905e8a_p_decided-move-city)
        )
      )
    :effect
      (and
        (human_36d2ec3e17905e8a_p_moved-to-city)
        (shared_p_consensus_f6bbc5df8e22aee7 ?p ?t)
        (not (shared_p_consensus_f6bbc5df8e22aee7 ?p ?t))
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
          (shared_p_consensus_f6bbc5df8e22aee7 ?p ?l)
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
          (shared_p_consensus_f6bbc5df8e22aee7 ?p1 ?l)
          (shared_p_consensus_f6bbc5df8e22aee7 ?p2 ?l)
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
          (shared_p_consensus_f6bbc5df8e22aee7 ?p ?l)
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
          (shared_p_consensus_f6bbc5df8e22aee7 ?p ?l)
          (shared_p_consensus_f6bbc5df8e22aee7 ?h ?l)
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
        (shared_p_consensus_2f85a3975e7cfe68 ?victim)
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
              (shared_p_consensus_5b2b3bfe7c0edb14 ?p ?victim)
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
          (shared_p_consensus_2f85a3975e7cfe68 ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (shared_p_consensus_2f85a3975e7cfe68 ?person))
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
          (shared_p_consensus_2f85a3975e7cfe68 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_3d693b867690a304 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_3d693b867690a304 ?person ?to)
        (not (shared_p_consensus_3d693b867690a304 ?person ?from))
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
          (shared_p_consensus_2f85a3975e7cfe68 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_3d693b867690a304 ?person ?from)
          (shared_p_consensus_2f85a3975e7cfe68 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_3d693b867690a304 ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_3d693b867690a304 ?person ?to)
        (not (shared_p_consensus_3d693b867690a304 ?person ?from))
        (shared_p_consensus_3d693b867690a304 ?victim ?to)
        (not (shared_p_consensus_3d693b867690a304 ?victim ?from))
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
          (shared_p_consensus_2f85a3975e7cfe68 ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_3d693b867690a304 ?giver ?place)
          (shared_p_consensus_399e50af7e951219 ?giver ?item)
          (shared_p_consensus_2f85a3975e7cfe68 ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_3d693b867690a304 ?receiver ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?receiver ?item)
        (not (shared_p_consensus_399e50af7e951219 ?giver ?item))
        (when
          (shared_p_consensus_2480b9295c28aaa9 ?item ?giver)
          (shared_p_consensus_2480b9295c28aaa9 ?item ?receiver)
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
          (shared_p_consensus_2f85a3975e7cfe68 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_3d693b867690a304 ?person ?place)
          (shared_p_consensus_2f85a3975e7cfe68 ?victim)
          (shared_p_consensus_3d693b867690a304 ?victim ?place)
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
          (shared_p_consensus_2f85a3975e7cfe68 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_3d693b867690a304 ?person ?place)
          (shared_p_consensus_2f85a3975e7cfe68 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_3d693b867690a304 ?victim ?place)
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
          (shared_p_consensus_2f85a3975e7cfe68 ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_3d693b867690a304 ?taker ?place)
          (shared_p_consensus_2f85a3975e7cfe68 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_3d693b867690a304 ?victim ?place)
          (shared_p_consensus_399e50af7e951219 ?victim ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_399e50af7e951219 ?taker ?item)
        (not (shared_p_consensus_399e50af7e951219 ?victim ?item))
        (when
          (shared_p_consensus_2480b9295c28aaa9 ?item ?victim)
          (and
            (intends ?victim (shared_p_consensus_399e50af7e951219 ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (shared_p_consensus_3d693b867690a304 ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (shared_p_consensus_399e50af7e951219 ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
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
          (shared_p_consensus_2f85a3975e7cfe68 ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_3d693b867690a304 ?healer ?place)
          (shared_p_consensus_399e50af7e951219 ?healer ?medicine)
          (shared_p_consensus_2f85a3975e7cfe68 ?patient)
          (shared_p_consensus_3d693b867690a304 ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (shared_p_consensus_399e50af7e951219 ?healer ?medicine))
      )
    :agents (?healer ?patient)
  )

  (:action human_df5671d8ba8d67d9_a_admit
    :parameters (?d - object ?p - object ?l - object ?w1 - object ?w2 - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_doctor ?d)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (human_df5671d8ba8d67d9_type_level ?w1)
        (human_df5671d8ba8d67d9_type_level ?w2)
        (and
          (shared_p_consensus_2f85a3975e7cfe68 ?d)
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (shared_p_consensus_3d693b867690a304 ?d ?l)
          (not (human_df5671d8ba8d67d9_p_occupied ?l))
          (not (human_df5671d8ba8d67d9_p_hospitalised ?p))
          (human_df5671d8ba8d67d9_p_level-of-work ?d ?w1)
          (human_df5671d8ba8d67d9_p_connected ?w1 ?w2)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
        (human_df5671d8ba8d67d9_p_hospitalised ?p)
        (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        (human_df5671d8ba8d67d9_p_occupied ?l)
        (not (human_df5671d8ba8d67d9_p_level-of-work ?d ?w1))
        (human_df5671d8ba8d67d9_p_level-of-work ?d ?w2)
      )
  )

  (:action human_df5671d8ba8d67d9_a_walk
    :parameters (?c - object ?l1 - object ?l2 - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_character ?c)
        (human_df5671d8ba8d67d9_type_location ?l1)
        (human_df5671d8ba8d67d9_type_location ?l2)
        (and
          (shared_p_consensus_3d693b867690a304 ?c ?l1)
          (not (human_df5671d8ba8d67d9_p_hospitalised ?c))
        )
      )
    :effect
      (and
        (shared_p_consensus_3d693b867690a304 ?c ?l2)
        (not (shared_p_consensus_3d693b867690a304 ?c ?l1))
      )
  )

  (:action human_df5671d8ba8d67d9_a_move
    :parameters (?c - object ?l1 - object ?l2 - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_patient ?c)
        (human_df5671d8ba8d67d9_type_location ?l1)
        (human_df5671d8ba8d67d9_type_location ?l2)
        (shared_p_consensus_3d693b867690a304 ?c ?l1)
      )
    :effect
      (and
        (shared_p_consensus_3d693b867690a304 ?c ?l2)
        (not (shared_p_consensus_3d693b867690a304 ?c ?l1))
      )
  )

  (:action human_df5671d8ba8d67d9_a_assess
    :parameters (?d - object ?p - object ?s - object ?t - object ?l - object ?w - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_doctor ?d)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_symptom ?s)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (human_df5671d8ba8d67d9_type_level ?w)
        (and
          (human_df5671d8ba8d67d9_p_level-of-work ?d ?w)
          (not (= ?w human_df5671d8ba8d67d9_o_three))
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (shared_p_consensus_3d693b867690a304 ?d ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
          (human_df5671d8ba8d67d9_p_has-symptom ?p ?s)
          (human_df5671d8ba8d67d9_p_treatment-for ?t ?s)
        )
      )
    :effect
      (human_df5671d8ba8d67d9_p_treatment-prescribed ?p ?t)
  )

  (:action human_df5671d8ba8d67d9_a_get-work-help
    :parameters (?d - object ?l - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_doctor ?d)
        (human_df5671d8ba8d67d9_type_level ?l)
        (and
          (human_df5671d8ba8d67d9_p_level-of-work ?d ?l)
          (not (= ?l human_df5671d8ba8d67d9_o_zero))
        )
      )
    :effect
      (and
        (not (human_df5671d8ba8d67d9_p_level-of-work ?d ?l))
        (human_df5671d8ba8d67d9_p_level-of-work ?d human_df5671d8ba8d67d9_o_zero)
        (not (human_df5671d8ba8d67d9_p_the-doctor-overworked))
      )
  )

  (:action human_df5671d8ba8d67d9_a_mistake-assess
    :parameters (?d - object ?p - object ?s - object ?t - object ?l - object ?w - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_doctor ?d)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_symptom ?s)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (human_df5671d8ba8d67d9_type_level ?w)
        (and
          (human_df5671d8ba8d67d9_p_level-of-work ?d ?w)
          (= ?w human_df5671d8ba8d67d9_o_three)
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (shared_p_consensus_3d693b867690a304 ?d ?l)
          (human_df5671d8ba8d67d9_p_has-symptom ?p ?s)
          (human_df5671d8ba8d67d9_p_treatment-for ?t ?s)
          (not (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t))
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_wrong-treatment-prescribed ?p ?t)
        (human_df5671d8ba8d67d9_p_the-doctor-overworked)
        (human_df5671d8ba8d67d9_p_the-doctor-mistake)
      )
  )

  (:action human_df5671d8ba8d67d9_a_treat
    :parameters (?d - object ?p - object ?t - object ?l - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_doctor ?d)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (and
          (human_df5671d8ba8d67d9_p_treatment-prescribed ?p ?t)
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (shared_p_consensus_3d693b867690a304 ?d ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
          (not (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t))
        )
      )
    :effect
      (and
        (not (human_df5671d8ba8d67d9_p_treatment-prescribed ?p ?t))
        (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t)
      )
  )

  (:action human_df5671d8ba8d67d9_a_recover
    :parameters (?p - object ?t - object ?s - object ?l - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_symptom ?s)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (and
          (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t)
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
          (human_df5671d8ba8d67d9_p_has-symptom ?p ?s)
        )
      )
    :effect
      (not (human_df5671d8ba8d67d9_p_has-symptom ?p ?s))
  )

  (:action human_df5671d8ba8d67d9_a_die
    :parameters (?p - object ?t - object ?s - object ?l - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_symptom ?s)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (and
          (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t)
          (shared_p_consensus_2f85a3975e7cfe68 ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        )
      )
    :effect
      (not (shared_p_consensus_2f85a3975e7cfe68 ?p))
  )

  (:action human_df5671d8ba8d67d9_a_lose-consciousness
    :parameters (?p - object ?t - object ?s - object ?l - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_patient ?p)
        (human_df5671d8ba8d67d9_type_treatment ?t)
        (human_df5671d8ba8d67d9_type_symptom ?s)
        (human_df5671d8ba8d67d9_type_medicalloc ?l)
        (and
          (human_df5671d8ba8d67d9_p_receiving-treatment ?p ?t)
          (human_df5671d8ba8d67d9_p_conscious ?p)
          (shared_p_consensus_3d693b867690a304 ?p ?l)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_unconscious ?p)
        (not (human_df5671d8ba8d67d9_p_conscious ?p))
      )
  )
)
