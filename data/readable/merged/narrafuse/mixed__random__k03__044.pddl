(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
  (:predicates
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
    (shared_p_consensus_8a4c130f75a11ed4 ?v0 - object)
    (human_df5671d8ba8d67d9_p_patient-room ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_occupied ?v0 - object)
    (human_df5671d8ba8d67d9_p_at ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_treatment-for ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_male ?v0 - object)
    (human_df5671d8ba8d67d9_p_female ?v0 - object)
    (human_df5671d8ba8d67d9_p_hospitalised ?v0 - object)
    (human_df5671d8ba8d67d9_p_wrong-treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_treatment-prescribed ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_receiving-treatment ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_level-of-work ?v0 - object ?v1 - object)
    (human_df5671d8ba8d67d9_p_connected ?v0 - object ?v1 - object)
    (tiny_stories__story_083_active)
    (tiny_stories__story_083_type_character ?x - object)
    (tiny_stories__story_083_type_object ?x - object)
    (tiny_stories__story_083_p_fierce ?v0 - object)
    (tiny_stories__story_083_p_scared ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_sneezed ?v0 - object)
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (shared_p_consensus_8a4c130f75a11ed4 ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (shared_p_consensus_8a4c130f75a11ed4 ?character))

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
          (shared_p_consensus_8a4c130f75a11ed4 ?d)
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
          (human_df5671d8ba8d67d9_p_at ?d ?l)
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
          (human_df5671d8ba8d67d9_p_at ?c ?l1)
          (not (human_df5671d8ba8d67d9_p_hospitalised ?c))
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_at ?c ?l2)
        (not (human_df5671d8ba8d67d9_p_at ?c ?l1))
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
        (human_df5671d8ba8d67d9_p_at ?c ?l1)
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_at ?c ?l2)
        (not (human_df5671d8ba8d67d9_p_at ?c ?l1))
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
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
          (human_df5671d8ba8d67d9_p_at ?d ?l)
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
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
          (human_df5671d8ba8d67d9_p_at ?d ?l)
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
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_the-doctor ?d)
          (human_df5671d8ba8d67d9_p_the-doctor-treating ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
          (human_df5671d8ba8d67d9_p_at ?d ?l)
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
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
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
          (shared_p_consensus_8a4c130f75a11ed4 ?p)
          (human_df5671d8ba8d67d9_p_at ?p ?l)
          (human_df5671d8ba8d67d9_p_patient-room ?p ?l)
        )
      )
    :effect
      (not (shared_p_consensus_8a4c130f75a11ed4 ?p))
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
          (human_df5671d8ba8d67d9_p_at ?p ?l)
        )
      )
    :effect
      (and
        (human_df5671d8ba8d67d9_p_unconscious ?p)
        (not (human_df5671d8ba8d67d9_p_conscious ?p))
      )
  )

  (:action tiny_stories__story_083_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (tiny_stories__story_083_p_friends ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_083_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_083_a_play
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_083_p_friends ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_playing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_083_a_sneeze
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character)
      )
    :effect
      (tiny_stories__story_083_p_sneezed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_083_a_become-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_083_p_fierce ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_scared ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_083_a_stop-being-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (tiny_stories__story_083_p_scared ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_083_p_scared ?character1 ?character2))
    :agents (?character1)
  )

  (:action writing_prompts__wp_048_a_offer-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (not (writing_prompts__wp_048_p_offered ?character ?trial))
        )
      )
    :effect
      (writing_prompts__wp_048_p_offered ?character ?trial)
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_048_a_choose-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (writing_prompts__wp_048_p_offered ?character ?trial)
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_completed ?character ?trial)
        (not (writing_prompts__wp_048_p_offered ?character ?trial))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_rebirth
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (or
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears)
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_8a4c130f75a11ed4 ?character)
        (not (writing_prompts__wp_048_p_dead ?character))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears))
      )
    :agents (writing_prompts__wp_048_o_death)
  )
)
