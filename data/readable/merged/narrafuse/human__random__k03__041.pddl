(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:constants human_8fa5775aae174731_o_ark - object human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object)
  (:predicates
    (human_4d95b598471c21ee_active)
    (human_4d95b598471c21ee_type_book ?x - object)
    (human_4d95b598471c21ee_type_character ?x - object)
    (human_4d95b598471c21ee_type_item ?x - object)
    (human_4d95b598471c21ee_type_location ?x - object)
    (human_4d95b598471c21ee_type_object ?x - object)
    (human_4d95b598471c21ee_type_ring ?x - object)
    (human_4d95b598471c21ee_type_sword ?x - object)
    (human_4d95b598471c21ee_type_thing ?x - object)
    (human_4d95b598471c21ee_p_player ?v0 - object)
    (human_4d95b598471c21ee_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_c246f56425044c4f ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_active)
    (human_8fa5775aae174731_type_character ?x - object)
    (human_8fa5775aae174731_type_item ?x - object)
    (human_8fa5775aae174731_type_object ?x - object)
    (human_8fa5775aae174731_type_place ?x - object)
    (human_8fa5775aae174731_type_weapon ?x - object)
    (human_8fa5775aae174731_p_open ?v0 - object)
    (shared_p_consensus_ae0592512b1d2354 ?v0 - object)
    (human_8fa5775aae174731_p_armed ?v0 - object)
    (human_8fa5775aae174731_p_burried ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_p_knows-location ?v0 - object ?v1 - object ?v2 - object)
    (shared_p_consensus_e63ebd2e5ed54743 ?v0 - object ?v1 - object)
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
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (not (human_8fa5775aae174731_p_armed ?character)) (exists (?w - object) (and (human_8fa5775aae174731_type_weapon ?w) (shared_p_consensus_c246f56425044c4f ?character ?w))))) :implies (human_8fa5775aae174731_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (human_8fa5775aae174731_p_armed ?character) (forall (?w - object) (or (not (human_8fa5775aae174731_type_weapon ?w)) (not (shared_p_consensus_c246f56425044c4f ?character ?w)))))) :implies (not (human_8fa5775aae174731_p_armed ?character)))

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (human_4d95b598471c21ee_p_connected ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (human_4d95b598471c21ee_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?character ?from))
        (human_4d95b598471c21ee_p_at ?character ?to)
      )
  )

  (:action human_4d95b598471c21ee_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?waker)
        (human_4d95b598471c21ee_type_character ?woken)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?waker ?location)
          (human_4d95b598471c21ee_p_at ?woken ?location)
          (human_4d95b598471c21ee_p_asleep ?woken)
          (not (human_4d95b598471c21ee_p_asleep ?waker))
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_asleep ?woken))
  )

  (:action human_4d95b598471c21ee_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?taker)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?taker ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?thing ?location))
        (shared_p_consensus_c246f56425044c4f ?taker ?thing)
      )
  )

  (:action human_4d95b598471c21ee_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?caster)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_book ?book)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?caster ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (shared_p_consensus_c246f56425044c4f ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
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
          (shared_p_consensus_ae0592512b1d2354 ?character)
          (shared_p_consensus_e63ebd2e5ed54743 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e63ebd2e5ed54743 ?character ?from))
        (shared_p_consensus_e63ebd2e5ed54743 ?character ?to)
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
          (shared_p_consensus_ae0592512b1d2354 ?character)
          (shared_p_consensus_e63ebd2e5ed54743 ?character ?place)
          (human_8fa5775aae174731_p_burried ?item ?place)
          (human_8fa5775aae174731_p_knows-location ?character ?item ?place)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_burried ?item ?place))
        (shared_p_consensus_c246f56425044c4f ?character ?item)
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
          (shared_p_consensus_ae0592512b1d2354 ?giver)
          (shared_p_consensus_e63ebd2e5ed54743 ?giver ?place)
          (shared_p_consensus_c246f56425044c4f ?giver ?item)
          (shared_p_consensus_ae0592512b1d2354 ?receiver)
          (shared_p_consensus_e63ebd2e5ed54743 ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c246f56425044c4f ?giver ?item))
        (shared_p_consensus_c246f56425044c4f ?receiver ?item)
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
          (shared_p_consensus_ae0592512b1d2354 ?killer)
          (shared_p_consensus_e63ebd2e5ed54743 ?killer ?place)
          (shared_p_consensus_c246f56425044c4f ?killer ?weapon)
          (shared_p_consensus_ae0592512b1d2354 ?victim)
          (shared_p_consensus_e63ebd2e5ed54743 ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_ae0592512b1d2354 ?victim))
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
          (shared_p_consensus_ae0592512b1d2354 ?taker)
          (shared_p_consensus_e63ebd2e5ed54743 ?taker ?place)
          (or
            (not (shared_p_consensus_ae0592512b1d2354 ?victim))
            (and
              (human_8fa5775aae174731_p_armed ?taker)
              (not (human_8fa5775aae174731_p_armed ?victim))
            )
          )
          (shared_p_consensus_e63ebd2e5ed54743 ?victim ?place)
          (shared_p_consensus_c246f56425044c4f ?victim ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c246f56425044c4f ?victim ?item))
        (shared_p_consensus_c246f56425044c4f ?taker ?item)
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
          (shared_p_consensus_ae0592512b1d2354 ?character)
          (shared_p_consensus_c246f56425044c4f ?character human_8fa5775aae174731_o_ark)
        )
      )
    :effect
      (and
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
        (not (shared_p_consensus_ae0592512b1d2354 ?character))
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
          (shared_p_consensus_ae0592512b1d2354 ?d)
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
          (shared_p_consensus_e63ebd2e5ed54743 ?d ?l)
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
          (shared_p_consensus_e63ebd2e5ed54743 ?c ?l1)
          (not (human_df5671d8ba8d67d9_p_hospitalised ?c))
        )
      )
    :effect
      (and
        (shared_p_consensus_e63ebd2e5ed54743 ?c ?l2)
        (not (shared_p_consensus_e63ebd2e5ed54743 ?c ?l1))
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
        (shared_p_consensus_e63ebd2e5ed54743 ?c ?l1)
      )
    :effect
      (and
        (shared_p_consensus_e63ebd2e5ed54743 ?c ?l2)
        (not (shared_p_consensus_e63ebd2e5ed54743 ?c ?l1))
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
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
          (shared_p_consensus_e63ebd2e5ed54743 ?d ?l)
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
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
          (shared_p_consensus_e63ebd2e5ed54743 ?d ?l)
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
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
          (shared_p_consensus_e63ebd2e5ed54743 ?d ?l)
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
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
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
          (shared_p_consensus_ae0592512b1d2354 ?p)
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        )
      )
    :effect
      (not (shared_p_consensus_ae0592512b1d2354 ?p))
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
          (shared_p_consensus_e63ebd2e5ed54743 ?p ?l)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_unconscious ?p)
        (not (human_df5671d8ba8d67d9_p_conscious ?p))
      )
  )
)
