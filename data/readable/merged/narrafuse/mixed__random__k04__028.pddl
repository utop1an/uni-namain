(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
  (:predicates
    (human_662247ec644ef452_active)
    (human_662247ec644ef452_type_animal ?x - object)
    (human_662247ec644ef452_type_item ?x - object)
    (human_662247ec644ef452_type_living ?x - object)
    (human_662247ec644ef452_type_object ?x - object)
    (human_662247ec644ef452_type_person ?x - object)
    (human_662247ec644ef452_type_place ?x - object)
    (human_662247ec644ef452_type_sickness ?x - object)
    (human_662247ec644ef452_type_valuable ?x - object)
    (shared_p_consensus_7eae852bcb73a1e2 ?v0 - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (shared_p_consensus_b435dd9e5c8f1a32 ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_belongsto ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_has ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_loves ?v0 - object ?v1 - object)
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_awake ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (tiny_stories__story_090_p_in-drawer ?v0 - object)
    (tiny_stories__story_090_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_wants-to-take ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_brave ?v0 - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (writing_prompts__wp_081_p_has-emotion ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_p_knows-change ?v0 - object)
    (writing_prompts__wp_081_p_memorize ?v0 - object)
  )

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (shared_p_consensus_7eae852bcb73a1e2 ?victim)
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
          (shared_p_consensus_7eae852bcb73a1e2 ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (shared_p_consensus_7eae852bcb73a1e2 ?person))
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
          (shared_p_consensus_7eae852bcb73a1e2 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_b435dd9e5c8f1a32 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_b435dd9e5c8f1a32 ?person ?to)
        (not (shared_p_consensus_b435dd9e5c8f1a32 ?person ?from))
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
          (shared_p_consensus_7eae852bcb73a1e2 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_b435dd9e5c8f1a32 ?person ?from)
          (shared_p_consensus_7eae852bcb73a1e2 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_b435dd9e5c8f1a32 ?person ?to)
        (not (shared_p_consensus_b435dd9e5c8f1a32 ?person ?from))
        (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?to)
        (not (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?from))
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
          (shared_p_consensus_7eae852bcb73a1e2 ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_b435dd9e5c8f1a32 ?giver ?place)
          (human_662247ec644ef452_p_has ?giver ?item)
          (shared_p_consensus_7eae852bcb73a1e2 ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_b435dd9e5c8f1a32 ?receiver ?place)
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
          (shared_p_consensus_7eae852bcb73a1e2 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_b435dd9e5c8f1a32 ?person ?place)
          (shared_p_consensus_7eae852bcb73a1e2 ?victim)
          (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?place)
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
          (shared_p_consensus_7eae852bcb73a1e2 ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_b435dd9e5c8f1a32 ?person ?place)
          (shared_p_consensus_7eae852bcb73a1e2 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?place)
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
          (shared_p_consensus_7eae852bcb73a1e2 ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_b435dd9e5c8f1a32 ?taker ?place)
          (shared_p_consensus_7eae852bcb73a1e2 ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_b435dd9e5c8f1a32 ?victim ?place)
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
                (intends ?s (and (shared_p_consensus_b435dd9e5c8f1a32 ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (human_662247ec644ef452_p_has ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
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
          (shared_p_consensus_7eae852bcb73a1e2 ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_b435dd9e5c8f1a32 ?healer ?place)
          (human_662247ec644ef452_p_has ?healer ?medicine)
          (shared_p_consensus_7eae852bcb73a1e2 ?patient)
          (shared_p_consensus_b435dd9e5c8f1a32 ?patient ?place)
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

  (:action tiny_stories__story_011_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (not (shared_p_consensus_b435dd9e5c8f1a32 ?character ?place))
        )
      )
    :effect
      (shared_p_consensus_b435dd9e5c8f1a32 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sleep
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (shared_p_consensus_b435dd9e5c8f1a32 ?character ?place)
          (tiny_stories__story_011_p_interesting ?place)
        )
      )
    :effect
      (not (tiny_stories__story_011_p_awake ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (not (tiny_stories__story_011_p_awake ?character))
      )
    :effect
      (tiny_stories__story_011_p_awake ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_awake ?character)
      )
    :effect
      (tiny_stories__story_011_p_singing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_stop-singing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_singing ?character)
      )
    :effect
      (not (tiny_stories__story_011_p_singing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character1)
        (tiny_stories__story_011_type_character ?character2)
        (and
          (tiny_stories__story_011_p_awake ?character1)
          (tiny_stories__story_011_p_awake ?character2)
          (not (tiny_stories__story_011_p_friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_011_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_090_a_find-toy
    :parameters (?character - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?character)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_p_in-drawer ?toy)
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_in-drawer ?toy))
        (tiny_stories__story_090_p_friends ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_090_a_want-to-take
    :parameters (?taker - object ?toy - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_type_character ?owner)
        (and
          (not (= ?taker ?owner))
          (tiny_stories__story_090_p_friends ?owner ?toy)
        )
      )
    :effect
      (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
    :agents (?taker)
  )

  (:action tiny_stories__story_090_a_stand-up
    :parameters (?defender - object ?taker - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?defender)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (and
          (not (= ?defender ?taker))
          (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
          (tiny_stories__story_090_p_friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_wants-to-take ?taker ?toy))
        (tiny_stories__story_090_p_brave ?defender)
      )
    :agents (?defender)
  )

  (:action writing_prompts__wp_081_a_experience-emotion
    :parameters (?character - object ?emotion - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_type_emotion ?emotion)
        (shared_p_consensus_7eae852bcb73a1e2 ?character)
      )
    :effect
      (writing_prompts__wp_081_p_has-emotion ?character ?emotion)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_notice-change
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (shared_p_consensus_7eae852bcb73a1e2 ?character)
      )
    :effect
      (writing_prompts__wp_081_p_knows-change ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_memorize-appearance
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (and
          (shared_p_consensus_7eae852bcb73a1e2 ?character)
          (writing_prompts__wp_081_p_knows-change ?character)
        )
      )
    :effect
      (writing_prompts__wp_081_p_memorize ?character)
    :agents (?character)
  )
)
