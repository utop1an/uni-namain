(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_7c98a61edf861243_active)
    (human_7c98a61edf861243_type_character ?x - object)
    (human_7c98a61edf861243_type_key ?x - object)
    (human_7c98a61edf861243_type_letter ?x - object)
    (human_7c98a61edf861243_type_object ?x - object)
    (human_7c98a61edf861243_type_room ?x - object)
    (human_7c98a61edf861243_type_star ?x - object)
    (human_7c98a61edf861243_type_thing ?x - object)
    (human_7c98a61edf861243_p_locked ?v0 - object)
    (shared_p_consensus_22c6df81e9734c98 ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_unlocked-by ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_in ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_hidden ?v0 - object)
    (shared_p_consensus_6416b673b88115fe ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-locked ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-at ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-unlocked-by ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-in ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-hidden ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-has ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_029_active)
    (tiny_stories__story_029_type_character ?x - object)
    (tiny_stories__story_029_type_item ?x - object)
    (tiny_stories__story_029_type_object ?x - object)
    (tiny_stories__story_029_type_place ?x - object)
    (tiny_stories__story_029_p_alive ?v0 - object)
    (tiny_stories__story_029_p_near ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_in-nest ?v0 - object)
    (tiny_stories__story_065_active)
    (tiny_stories__story_065_type_character ?x - object)
    (tiny_stories__story_065_type_object ?x - object)
    (tiny_stories__story_065_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_hurt ?v0 - object)
    (tiny_stories__story_065_p_touching ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_scared ?v0 - object)
    (tiny_stories__story_065_p_hugging ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (writing_prompts__wp_017_p_awake ?v0 - object)
    (writing_prompts__wp_017_p_wearing-pajamas ?v0 - object)
    (writing_prompts__wp_017_p_on-floor ?v0 - object)
    (writing_prompts__wp_017_p_dressed ?v0 - object)
    (writing_prompts__wp_017_p_holding ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_walking ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_petting ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_bites ?v0 - object)
    (writing_prompts__wp_017_p_owns ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_life-is-a-joke ?v0 - object)
  )

  (:action human_7c98a61edf861243_a_enter-success
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (human_7c98a61edf861243_p_locked ?roomto))
          (shared_p_consensus_22c6df81e9734c98 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_22c6df81e9734c98 ?character ?roomfrom))
        (shared_p_consensus_22c6df81e9734c98 ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (shared_p_consensus_22c6df81e9734c98 ?char2 ?roomto)
            )
            (and
              (human_7c98a61edf861243_p_believes-at ?character ?char2 ?roomto)
              (human_7c98a61edf861243_p_believes-at ?char2 ?character ?roomto)
            )
          )
        )
        (forall
          (?thing - object)
          (when
            (and
              (human_7c98a61edf861243_type_thing ?thing)
              (and
                (human_7c98a61edf861243_p_in ?thing ?roomto)
                (not (human_7c98a61edf861243_p_hidden ?thing))
              )
            )
            (human_7c98a61edf861243_p_believes-in ?character ?thing ?roomto)
          )
        )
        (not (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom))
        (human_7c98a61edf861243_p_believes-at ?character ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_enter-fail
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_room ?roomfrom)
        (human_7c98a61edf861243_type_room ?roomto)
        (and
          (not (human_7c98a61edf861243_p_believes-locked ?character ?roomto))
          (human_7c98a61edf861243_p_believes-at ?character ?character ?roomfrom)
          (not (and (not (human_7c98a61edf861243_p_locked ?roomto)) (shared_p_consensus_22c6df81e9734c98 ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?roomto)
          (shared_p_consensus_22c6df81e9734c98 ?character ?roomfrom)
        )
        (human_7c98a61edf861243_p_believes-locked ?character ?roomto)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_in
    :parameters (?informant - object ?in_thing - object ?in_room - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_thing ?in_thing)
        (human_7c98a61edf861243_type_room ?in_room)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_22c6df81e9734c98 ?informant ?room)
          (shared_p_consensus_22c6df81e9734c98 ?informed ?room)
          (human_7c98a61edf861243_p_believes-in ?informant ?in_thing ?in_room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_22c6df81e9734c98 ?informant ?room)
          (shared_p_consensus_22c6df81e9734c98 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-in ?informed ?in_thing ?in_room)
      )
  )

  (:action human_7c98a61edf861243_a_speak-to-success_unlocked-by
    :parameters (?informant - object ?unlocked-by_room - object ?unlocked-by_key - object ?informed - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?informant)
        (human_7c98a61edf861243_type_room ?unlocked-by_room)
        (human_7c98a61edf861243_type_key ?unlocked-by_key)
        (human_7c98a61edf861243_type_character ?informed)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (shared_p_consensus_22c6df81e9734c98 ?informant ?room)
          (shared_p_consensus_22c6df81e9734c98 ?informed ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?informant ?unlocked-by_room ?unlocked-by_key)
          (human_7c98a61edf861243_p_believes-at ?informant ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informant ?informed ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informant ?room)
          (human_7c98a61edf861243_p_believes-at ?informed ?informed ?room)
        )
      )
    :effect
      (when
        (and
          (shared_p_consensus_22c6df81e9734c98 ?informant ?room)
          (shared_p_consensus_22c6df81e9734c98 ?informed ?room)
        )
        (human_7c98a61edf861243_p_believes-unlocked-by ?informed ?unlocked-by_room ?unlocked-by_key)
      )
  )

  (:action human_7c98a61edf861243_a_search-for-success
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (shared_p_consensus_22c6df81e9734c98 ?character ?room)
          (human_7c98a61edf861243_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_6416b673b88115fe ?character ?thing)
        (not (human_7c98a61edf861243_p_in ?thing ?room))
        (human_7c98a61edf861243_p_believes-has ?character ?character ?thing)
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_search-for-fail
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_thing ?thing)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-at ?character ?character ?room)
          (human_7c98a61edf861243_p_believes-in ?character ?thing ?room)
          (not (and (shared_p_consensus_22c6df81e9734c98 ?character ?room) (human_7c98a61edf861243_p_in ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (human_7c98a61edf861243_p_in ?thing ?room))
          (shared_p_consensus_22c6df81e9734c98 ?character ?room)
        )
        (not (human_7c98a61edf861243_p_believes-in ?character ?thing ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-success
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (human_7c98a61edf861243_p_locked ?room)
          (human_7c98a61edf861243_p_unlocked-by ?room ?key)
          (shared_p_consensus_6416b673b88115fe ?character ?key)
        )
      )
    :effect
      (and
        (not (human_7c98a61edf861243_p_locked ?room))
        (not (human_7c98a61edf861243_p_believes-locked ?character ?room))
      )
  )

  (:action human_7c98a61edf861243_a_unlock-fail
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_7c98a61edf861243_active)
        (human_7c98a61edf861243_type_character ?character)
        (human_7c98a61edf861243_type_key ?key)
        (human_7c98a61edf861243_type_room ?room)
        (and
          (human_7c98a61edf861243_p_believes-locked ?character ?room)
          (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key)
          (human_7c98a61edf861243_p_believes-has ?character ?character ?key)
          (not (and (human_7c98a61edf861243_p_locked ?room) (human_7c98a61edf861243_p_unlocked-by ?room ?key) (shared_p_consensus_6416b673b88115fe ?character ?key)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?room)
          (shared_p_consensus_6416b673b88115fe ?character ?key)
          (not (human_7c98a61edf861243_p_unlocked-by ?room ?key))
        )
        (not (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key))
      )
  )

  (:action tiny_stories__story_029_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_place ?from)
        (tiny_stories__story_029_type_place ?to)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (shared_p_consensus_22c6df81e9734c98 ?character ?from)
          (not (shared_p_consensus_22c6df81e9734c98 ?character ?to))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_22c6df81e9734c98 ?character ?from))
        (shared_p_consensus_22c6df81e9734c98 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (shared_p_consensus_6416b673b88115fe ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_pick-up
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_near ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_6416b673b88115fe ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_help-bird
    :parameters (?character - object ?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_alive ?bird)
          (not (tiny_stories__story_029_p_in-nest ?bird))
        )
      )
    :effect
      (tiny_stories__story_029_p_in-nest ?bird)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_bird-falls
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?bird)
          (tiny_stories__story_029_p_in-nest ?bird)
        )
      )
    :effect
      (not (tiny_stories__story_029_p_in-nest ?bird))
  )

  (:action tiny_stories__story_065_a_move
    :parameters (?character - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_at ?character ?location))
          (not (tiny_stories__story_065_p_scared ?character))
        )
      )
    :effect
      (tiny_stories__story_065_p_at ?character ?location)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_touch
    :parameters (?character - object ?object - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_touching ?character ?object))
          (tiny_stories__story_065_p_at ?character ?location)
        )
      )
    :effect
      (tiny_stories__story_065_p_touching ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-touching
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_p_touching ?character ?object)
      )
    :effect
      (not (tiny_stories__story_065_p_touching ?character ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-hurt
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_hurt ?character))
      )
    :effect
      (tiny_stories__story_065_p_hurt ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_scared ?character))
      )
    :effect
      (tiny_stories__story_065_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_065_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (and
          (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
          (not (tiny_stories__story_065_p_hugging ?character2 ?character1))
        )
      )
    :effect
      (tiny_stories__story_065_p_hugging ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_065_a_stop-hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (tiny_stories__story_065_p_hugging ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_017_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (not (writing_prompts__wp_017_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_017_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_dress
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (and
          (writing_prompts__wp_017_p_awake ?character)
          (writing_prompts__wp_017_p_on-floor ?character)
          (not (writing_prompts__wp_017_p_dressed ?character))
        )
      )
    :effect
      (writing_prompts__wp_017_p_dressed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_pet
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (writing_prompts__wp_017_type_animal ?animal)
        (and
          (writing_prompts__wp_017_p_awake ?character)
          (writing_prompts__wp_017_p_dressed ?character)
          (not (writing_prompts__wp_017_p_bites ?animal))
        )
      )
    :effect
      (writing_prompts__wp_017_p_petting ?character ?animal)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_realize-life-is-a-joke
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (writing_prompts__wp_017_p_awake ?character)
      )
    :effect
      (writing_prompts__wp_017_p_life-is-a-joke ?character)
    :agents (?character)
  )
)
