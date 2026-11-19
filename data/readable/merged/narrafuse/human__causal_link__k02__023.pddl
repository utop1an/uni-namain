(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object)
  (:predicates
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
    (shared_p_consensus_aedf1aefb5891e42 ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_has ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (shared_p_consensus_ca099d318f75bb6c ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
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

  (:action human_3cd8b87ba572801b_a_slay
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_aedf1aefb5891e42 ?slayer ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?m ?place)
          (shared_p_consensus_ca099d318f75bb6c ?slayer)
          (shared_p_consensus_ca099d318f75bb6c ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (shared_p_consensus_ca099d318f75bb6c ?m))
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
          (shared_p_consensus_aedf1aefb5891e42 ?slayer ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?m ?place)
          (shared_p_consensus_ca099d318f75bb6c ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (shared_p_consensus_ca099d318f75bb6c ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ca099d318f75bb6c ?m))
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
          (shared_p_consensus_aedf1aefb5891e42 ?pillager ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?body ?place)
          (shared_p_consensus_ca099d318f75bb6c ?pillager)
          (not (shared_p_consensus_ca099d318f75bb6c ?body))
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
          (shared_p_consensus_aedf1aefb5891e42 ?giver ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?givee ?place)
          (shared_p_consensus_ca099d318f75bb6c ?givee)
          (shared_p_consensus_ca099d318f75bb6c ?giver)
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
          (shared_p_consensus_aedf1aefb5891e42 ?char ?place)
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (shared_p_consensus_ca099d318f75bb6c ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_aedf1aefb5891e42 ?g ?place)
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
          (shared_p_consensus_ca099d318f75bb6c ?target)
          (shared_p_consensus_ca099d318f75bb6c ?lover)
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
          (shared_p_consensus_ca099d318f75bb6c ?groom)
          (shared_p_consensus_ca099d318f75bb6c ?bride)
          (shared_p_consensus_aedf1aefb5891e42 ?groom ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?bride ?place)
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
          (shared_p_consensus_aedf1aefb5891e42 ?m ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (shared_p_consensus_ca099d318f75bb6c ?m)
          (shared_p_consensus_ca099d318f75bb6c ?f)
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
          (shared_p_consensus_ca099d318f75bb6c ?kn)
          (shared_p_consensus_ca099d318f75bb6c ?ki)
          (shared_p_consensus_aedf1aefb5891e42 ?ki ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?kn ?place)
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
          (shared_p_consensus_ca099d318f75bb6c ?m)
          (shared_p_consensus_ca099d318f75bb6c ?char)
          (shared_p_consensus_aedf1aefb5891e42 ?m ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?char ?place)
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
          (shared_p_consensus_ca099d318f75bb6c ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_ca099d318f75bb6c ?love)
          (shared_p_consensus_aedf1aefb5891e42 ?char ?place)
          (shared_p_consensus_aedf1aefb5891e42 ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
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
          (shared_p_consensus_ca099d318f75bb6c ?d)
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
          (shared_p_consensus_aedf1aefb5891e42 ?d ?l)
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

  (:action human_df5671d8ba8d67d9_a_move
    :parameters (?c - object ?l1 - object ?l2 - object)
    :precondition
      (and
        (human_df5671d8ba8d67d9_active)
        (human_df5671d8ba8d67d9_type_patient ?c)
        (human_df5671d8ba8d67d9_type_location ?l1)
        (human_df5671d8ba8d67d9_type_location ?l2)
        (shared_p_consensus_aedf1aefb5891e42 ?c ?l1)
      )
    :effect
      (and
        (shared_p_consensus_aedf1aefb5891e42 ?c ?l2)
        (not (shared_p_consensus_aedf1aefb5891e42 ?c ?l1))
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
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
          (shared_p_consensus_aedf1aefb5891e42 ?d ?l)
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
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
          (shared_p_consensus_aedf1aefb5891e42 ?d ?l)
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
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
          (shared_p_consensus_aedf1aefb5891e42 ?d ?l)
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
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
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
          (shared_p_consensus_ca099d318f75bb6c ?p)
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        )
      )
    :effect
      (not (shared_p_consensus_ca099d318f75bb6c ?p))
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
          (shared_p_consensus_aedf1aefb5891e42 ?p ?l)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_unconscious ?p)
        (not (human_df5671d8ba8d67d9_p_conscious ?p))
      )
  )

  (:action fused_a_consensus_f0da4c4850daa3a7
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_character ?m0)
          (human_3cd8b87ba572801b_type_location ?m1)
          (human_3cd8b87ba572801b_type_location ?m2)
          (and
            (shared_p_consensus_aedf1aefb5891e42 ?m0 ?m1)
            (shared_p_consensus_ca099d318f75bb6c ?m0)
            (not (= ?m1 ?m2))
          )
        )
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_character ?m0)
          (human_df5671d8ba8d67d9_type_location ?m1)
          (human_df5671d8ba8d67d9_type_location ?m2)
          (and
            (shared_p_consensus_aedf1aefb5891e42 ?m0 ?m1)
            (not (human_df5671d8ba8d67d9_p_hospitalised ?m0))
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_aedf1aefb5891e42 ?m0 ?m2)
        (not (shared_p_consensus_aedf1aefb5891e42 ?m0 ?m1))
      )
  )
)
