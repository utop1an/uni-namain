(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :equality :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:constants human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (shared_p_consensus_56f599b4b2a95564 ?v0 - object ?v1 - object)
    (shared_p_consensus_230e936cb4321851 ?v0 - object ?v1 - object)
    (shared_p_consensus_1719447f86a90b85 ?v0 - object ?v1 - object)
    (shared_p_consensus_f68c01c25cae39cf ?v0 - object)
    (shared_p_consensus_17564f47ff2596a8 ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (shared_p_consensus_bcbf21fe0f9f55c1 ?v0 - object)
    (shared_p_consensus_dba043dcf4aed0cc ?v0 - object)
    (shared_p_consensus_e8675832023f971b ?v0 - object)
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
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
    (human_df5671d8ba8d67d9_p_alive ?v0 - object)
    (human_df5671d8ba8d67d9_p_patient-room ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_occupied ?v0 - object)
    (shared_p_consensus_8fe53f3e6b53eaa8 ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_treatment-for ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_male ?v0 - object)
    (human_df5671d8ba8d67d9_p_female ?v0 - object)
    (human_df5671d8ba8d67d9_p_hospitalised ?v0 - object)
    (human_df5671d8ba8d67d9_p_wrong-treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_receiving-treatment ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_level-of-work ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_connected ?v0 - object ?v1 - object)
    (tiny_stories__story_074_active)
    (tiny_stories__story_074_type_character ?x - object)
    (tiny_stories__story_074_type_object ?x - object)
    (tiny_stories__story_074_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_074_p_happy ?v0 - object)
    (tiny_stories__story_074_p_magic ?v0 - object)
    (tiny_stories__story_074_p_granted-wish ?v0 - object)
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
          (shared_p_consensus_1719447f86a90b85 ?to ?from)
          (shared_p_consensus_56f599b4b2a95564 ?character ?from)
          (shared_p_consensus_bcbf21fe0f9f55c1 ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_56f599b4b2a95564 ?character ?from))
        (shared_p_consensus_56f599b4b2a95564 ?character ?to)
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
          (shared_p_consensus_56f599b4b2a95564 ?interrogator ?location)
          (shared_p_consensus_56f599b4b2a95564 ?interrogated ?location)
          (shared_p_consensus_f68c01c25cae39cf ?interrogated)
        )
      )
    :effect
      (shared_p_consensus_bcbf21fe0f9f55c1 ?interrogator)
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
          (shared_p_consensus_e8675832023f971b ?placer)
          (shared_p_consensus_230e936cb4321851 ?placer ?victim)
          (shared_p_consensus_56f599b4b2a95564 ?placer ?location)
          (shared_p_consensus_1719447f86a90b85 ?placed ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_230e936cb4321851 ?placer ?victim))
        (shared_p_consensus_56f599b4b2a95564 ?victim ?placed)
        (shared_p_consensus_dba043dcf4aed0cc ?victim)
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
          (shared_p_consensus_56f599b4b2a95564 ?saver ?location)
          (shared_p_consensus_56f599b4b2a95564 ?saved ?location)
          (shared_p_consensus_dba043dcf4aed0cc ?saved)
          (shared_p_consensus_dba043dcf4aed0cc ?notsaved)
          (not (shared_p_consensus_56f599b4b2a95564 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (shared_p_consensus_17564f47ff2596a8 ?notsaved))
      )
    :agents (?saver)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (shared_p_consensus_1719447f86a90b85 ?to ?from)
          (shared_p_consensus_56f599b4b2a95564 ?character ?from)
          (shared_p_consensus_bcbf21fe0f9f55c1 ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_56f599b4b2a95564 ?character ?from))
        (shared_p_consensus_56f599b4b2a95564 ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (shared_p_consensus_56f599b4b2a95564 ?interrogator ?location)
          (shared_p_consensus_56f599b4b2a95564 ?interrogated ?location)
          (shared_p_consensus_f68c01c25cae39cf ?interrogated)
        )
      )
    :effect
      (shared_p_consensus_bcbf21fe0f9f55c1 ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (shared_p_consensus_e8675832023f971b ?placer)
          (shared_p_consensus_230e936cb4321851 ?placer ?victim)
          (shared_p_consensus_56f599b4b2a95564 ?placer ?location)
          (shared_p_consensus_1719447f86a90b85 ?placed ?location)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_230e936cb4321851 ?placer ?victim))
        (shared_p_consensus_56f599b4b2a95564 ?victim ?placed)
        (shared_p_consensus_dba043dcf4aed0cc ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (shared_p_consensus_56f599b4b2a95564 ?saver ?location)
          (shared_p_consensus_56f599b4b2a95564 ?saved ?location)
          (shared_p_consensus_dba043dcf4aed0cc ?saved)
          (shared_p_consensus_dba043dcf4aed0cc ?notsaved)
          (not (shared_p_consensus_56f599b4b2a95564 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (shared_p_consensus_17564f47ff2596a8 ?notsaved))
      )
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
          (human_df5671d8ba8d67d9_p_alive ?d)
          (human_df5671d8ba8d67d9_p_alive ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?d ?l)
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
          (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l1)
          (not (human_df5671d8ba8d67d9_p_hospitalised ?c))
        )
      )
    :effect
      (and
        (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l2)
        (not (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l1))
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
        (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l1)
      )
    :effect
      (and
        (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l2)
        (not (shared_p_consensus_8fe53f3e6b53eaa8 ?c ?l1))
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
          (human_df5671d8ba8d67d9_p_alive ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?d ?l)
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
          (human_df5671d8ba8d67d9_p_alive ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?d ?l)
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
          (human_df5671d8ba8d67d9_p_alive ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?d ?l)
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
          (human_df5671d8ba8d67d9_p_alive ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
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
          (human_df5671d8ba8d67d9_p_alive ?p)
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        )
      )
    :effect
      (not (human_df5671d8ba8d67d9_p_alive ?p))
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
          (shared_p_consensus_8fe53f3e6b53eaa8 ?p ?l)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_unconscious ?p)
        (not (human_df5671d8ba8d67d9_p_conscious ?p))
      )
  )

  (:action tiny_stories__story_074_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (tiny_stories__story_074_type_object ?place)
        (not (shared_p_consensus_8fe53f3e6b53eaa8 ?character ?place))
      )
    :effect
      (shared_p_consensus_8fe53f3e6b53eaa8 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_sit-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (not (tiny_stories__story_074_p_happy ?character))
      )
    :effect
      (tiny_stories__story_074_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_share-snack
    :parameters (?sharer - object ?receiver - object ?snack - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?sharer)
        (tiny_stories__story_074_type_character ?receiver)
        (tiny_stories__story_074_type_object ?snack)
        (and
          (tiny_stories__story_074_p_has ?sharer ?snack)
          (not (tiny_stories__story_074_p_has ?receiver ?snack))
        )
      )
    :effect
      (tiny_stories__story_074_p_has ?receiver ?snack)
    :agents (?sharer)
  )

  (:action tiny_stories__story_074_a_become-magic
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?character)
        (not (tiny_stories__story_074_p_magic ?character))
      )
    :effect
      (tiny_stories__story_074_p_magic ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_074_a_grant-wish
    :parameters (?granter - object ?wish - object)
    :precondition
      (and
        (tiny_stories__story_074_active)
        (tiny_stories__story_074_type_character ?granter)
        (tiny_stories__story_074_type_object ?wish)
        (tiny_stories__story_074_p_magic ?granter)
      )
    :effect
      (tiny_stories__story_074_p_granted-wish ?wish)
    :agents (?granter)
  )
)
