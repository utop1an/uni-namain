(define (domain revised_merged)
  (:requirements :adl :typing :equality)
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
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (the-doctor ?p0)
    (the-doctor-treating ?p0)
    (the-doctor-overworked)
    (the-doctor-mistake)
    (has-symptom ?p0 ?p1)
    (conscious ?p0)
    (unconscious ?p0)
    (alive ?p0)
    (patient-room ?p0 ?p1)
    (occupied ?p0)
    (at ?p0 ?p1)
    (treatment-for ?p0 ?p1)
    (male ?p0)
    (female ?p0)
    (hospitalised ?p0)
    (wrong-treatment-prescribed ?p0 ?p1)
    (treatment-prescribed ?p0 ?p1)
    (receiving-treatment ?p0 ?p1)
    (level-of-work ?p0 ?p1)
    (connected ?p0 ?p1)
    (broken ?p0)
    (has ?p0 ?p1)
    (playing ?p0 ?p1)
    (apologized ?p0 ?p1)
    (cleaned ?p0)
    (forgiven ?p0 ?p1)
  )
  (:constants human_df5671d8ba8d67d9_o_three - object human_df5671d8ba8d67d9_o_zero - object)

  (:action admit
    :parameters (?d ?p ?l ?w1 ?w2)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w1)
          (human_df5671d8ba8d67d9_type_level ?w2)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w1)
          (human_df5671d8ba8d67d9_type_level ?w2)
        )
        (and
          (alive ?d)
          (alive ?p)
          (at ?p ?l)
          (at ?d ?l)
          (not (occupied ?l))
          (not (hospitalised ?p))
          (level-of-work ?d ?w1)
          (connected ?w1 ?w2)
          (the-doctor ?d)
        )
      )
    :effect
      (and
        (the-doctor-treating ?p)
        (hospitalised ?p)
        (patient-room ?p ?l)
        (occupied ?l)
        (not (level-of-work ?d ?w1))
        (level-of-work ?d ?w2)
      )
  )

  (:action walk
    :parameters (?c ?l1 ?l2)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_character ?c)
          (human_df5671d8ba8d67d9_type_location ?l1)
          (human_df5671d8ba8d67d9_type_location ?l2)
          (human_df5671d8ba8d67d9_type_character ?c)
          (human_df5671d8ba8d67d9_type_location ?l1)
          (human_df5671d8ba8d67d9_type_location ?l2)
        )
        (and
          (at ?c ?l1)
          (not (hospitalised ?c))
        )
      )
    :effect
      (and
        (at ?c ?l2)
        (not (at ?c ?l1))
      )
  )

  (:action move
    :parameters (?c ?l1 ?l2)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_patient ?c)
          (human_df5671d8ba8d67d9_type_location ?l1)
          (human_df5671d8ba8d67d9_type_location ?l2)
          (human_df5671d8ba8d67d9_type_patient ?c)
          (human_df5671d8ba8d67d9_type_location ?l1)
          (human_df5671d8ba8d67d9_type_location ?l2)
        )
        (at ?c ?l1)
      )
    :effect
      (and
        (at ?c ?l2)
        (not (at ?c ?l1))
      )
  )

  (:action assess
    :parameters (?d ?p ?s ?t ?l ?w)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w)
        )
        (and
          (level-of-work ?d ?w)
          (not (= ?w human_df5671d8ba8d67d9_o_three))
          (alive ?p)
          (the-doctor ?d)
          (the-doctor-treating ?p)
          (at ?p ?l)
          (at ?d ?l)
          (patient-room ?p ?l)
          (has-symptom ?p ?s)
          (treatment-for ?t ?s)
        )
      )
    :effect
      (treatment-prescribed ?p ?t)
  )

  (:action get-work-help
    :parameters (?d ?l)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_level ?l)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_level ?l)
        )
        (and
          (level-of-work ?d ?l)
          (not (= ?l human_df5671d8ba8d67d9_o_zero))
        )
      )
    :effect
      (and
        (not (level-of-work ?d ?l))
        (level-of-work ?d human_df5671d8ba8d67d9_o_zero)
        (not (the-doctor-overworked))
      )
  )

  (:action mistake-assess
    :parameters (?d ?p ?s ?t ?l ?w)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_level ?w)
        )
        (and
          (level-of-work ?d ?w)
          (= ?w human_df5671d8ba8d67d9_o_three)
          (alive ?p)
          (the-doctor ?d)
          (the-doctor-treating ?p)
          (at ?p ?l)
          (at ?d ?l)
          (has-symptom ?p ?s)
          (treatment-for ?t ?s)
          (not (receiving-treatment ?p ?t))
        )
      )
    :effect
      (and
        (wrong-treatment-prescribed ?p ?t)
        (the-doctor-overworked)
        (the-doctor-mistake)
      )
  )

  (:action treat
    :parameters (?d ?p ?t ?l)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_doctor ?d)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
        )
        (and
          (treatment-prescribed ?p ?t)
          (alive ?p)
          (the-doctor ?d)
          (the-doctor-treating ?p)
          (at ?p ?l)
          (at ?d ?l)
          (patient-room ?p ?l)
          (not (receiving-treatment ?p ?t))
        )
      )
    :effect
      (and
        (not (treatment-prescribed ?p ?t))
        (receiving-treatment ?p ?t)
      )
  )

  (:action recover
    :parameters (?p ?t ?s ?l)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
        )
        (and
          (receiving-treatment ?p ?t)
          (alive ?p)
          (at ?p ?l)
          (patient-room ?p ?l)
          (has-symptom ?p ?s)
        )
      )
    :effect
      (not (has-symptom ?p ?s))
  )

  (:action die
    :parameters (?p ?t ?s ?l)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
        )
        (and
          (receiving-treatment ?p ?t)
          (alive ?p)
          (at ?p ?l)
          (patient-room ?p ?l)
        )
      )
    :effect
      (not (alive ?p))
  )

  (:action lose-consciousness
    :parameters (?p ?t ?s ?l)
    :precondition
      (and
        (and
          (human_df5671d8ba8d67d9_active)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
          (human_df5671d8ba8d67d9_type_patient ?p)
          (human_df5671d8ba8d67d9_type_treatment ?t)
          (human_df5671d8ba8d67d9_type_symptom ?s)
          (human_df5671d8ba8d67d9_type_medicalloc ?l)
        )
        (and
          (receiving-treatment ?p ?t)
          (conscious ?p)
          (at ?p ?l)
        )
      )
    :effect
      (and
        (unconscious ?p)
        (not (conscious ?p))
      )
  )

  (:action play
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?character)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?character)
          (tiny_stories__story_085_type_item ?item)
        )
        (and
          (not (broken ?item))
          (has ?character ?item)
        )
      )
    :effect
      (playing ?character ?item)
  )

  (:action break-item
    :parameters (?breaker ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?breaker)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?breaker)
          (tiny_stories__story_085_type_item ?item)
        )
        (and
          (not (broken ?item))
          (playing ?breaker ?item)
        )
      )
    :effect
      (broken ?item)
  )

  (:action apologize
    :parameters (?apologizer ?apologizee)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?apologizer)
          (tiny_stories__story_085_type_character ?apologizee)
          (tiny_stories__story_085_type_character ?apologizer)
          (tiny_stories__story_085_type_character ?apologizee)
        )
        (not (= ?apologizer ?apologizee))
      )
    :effect
      (apologized ?apologizer ?apologizee)
  )

  (:action clean
    :parameters (?cleaner ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?cleaner)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?cleaner)
          (tiny_stories__story_085_type_item ?item)
        )
        (broken ?item)
      )
    :effect
      (cleaned ?cleaner)
  )

  (:action forgive
    :parameters (?forgiver ?forgivee)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?forgiver)
          (tiny_stories__story_085_type_character ?forgivee)
          (tiny_stories__story_085_type_character ?forgiver)
          (tiny_stories__story_085_type_character ?forgivee)
        )
        (and
          (not (= ?forgiver ?forgivee))
          (apologized ?forgivee ?forgiver)
        )
      )
    :effect
      (forgiven ?forgiver ?forgivee)
  )
)
