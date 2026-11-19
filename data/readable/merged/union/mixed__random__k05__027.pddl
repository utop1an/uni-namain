(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:constants tiny_stories__story_035_o_tim - object)
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
    (human_7c98a61edf861243_p_at ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_unlocked-by ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_in ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_hidden ?v0 - object)
    (human_7c98a61edf861243_p_has ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-locked ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-at ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-unlocked-by ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-in ?v0 - object ?v1 - object ?v2 - object)
    (human_7c98a61edf861243_p_believes-hidden ?v0 - object ?v1 - object)
    (human_7c98a61edf861243_p_believes-has ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_035_active)
    (tiny_stories__story_035_type_character ?x - object)
    (tiny_stories__story_035_type_object ?x - object)
    (tiny_stories__story_035_p_birthday ?v0 - object)
    (tiny_stories__story_035_p_box-closed)
    (tiny_stories__story_035_p_box-open)
    (tiny_stories__story_035_p_cake-spoiled)
    (tiny_stories__story_035_p_cake-good)
    (tiny_stories__story_035_p_listened-to-mom ?v0 - object)
    (tiny_stories__story_035_p_waited-for-birthday ?v0 - object)
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_050_p_playing-with-toys ?v0 - object)
    (tiny_stories__story_050_p_found-blocks ?v0 - object)
    (tiny_stories__story_050_p_stacking-blocks ?v0 - object)
    (tiny_stories__story_050_p_stack-tall ?v0 - object)
    (tiny_stories__story_050_p_stack-strong ?v0 - object)
    (tiny_stories__story_050_p_happy ?v0 - object)
    (tiny_stories__story_050_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_active)
    (writing_prompts__wp_019_type_character ?x - object)
    (writing_prompts__wp_019_type_item ?x - object)
    (writing_prompts__wp_019_type_object ?x - object)
    (writing_prompts__wp_019_type_place ?x - object)
    (writing_prompts__wp_019_p_alive ?v0 - object)
    (writing_prompts__wp_019_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_buried ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_destroyed ?v0 - object)
    (writing_prompts__wp_019_p_explosives-set ?v0 - object)
    (writing_prompts__wp_083_active)
    (writing_prompts__wp_083_type_character ?x - object)
    (writing_prompts__wp_083_type_object ?x - object)
    (writing_prompts__wp_083_type_place ?x - object)
    (writing_prompts__wp_083_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_betrayed ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_peace ?v0 - object)
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
          (human_7c98a61edf861243_p_at ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (human_7c98a61edf861243_p_at ?character ?roomfrom))
        (human_7c98a61edf861243_p_at ?character ?roomto)
        (forall
          (?char2 - object)
          (when
            (and
              (human_7c98a61edf861243_type_character ?char2)
              (human_7c98a61edf861243_p_at ?char2 ?roomto)
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
          (not (and (not (human_7c98a61edf861243_p_locked ?roomto)) (human_7c98a61edf861243_p_at ?character ?roomfrom)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?roomto)
          (human_7c98a61edf861243_p_at ?character ?roomfrom)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?informant ?room)
          (human_7c98a61edf861243_p_at ?informed ?room)
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
          (human_7c98a61edf861243_p_at ?character ?room)
          (human_7c98a61edf861243_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (human_7c98a61edf861243_p_has ?character ?thing)
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
          (not (and (human_7c98a61edf861243_p_at ?character ?room) (human_7c98a61edf861243_p_in ?thing ?room)))
        )
      )
    :effect
      (when
        (and
          (not (human_7c98a61edf861243_p_in ?thing ?room))
          (human_7c98a61edf861243_p_at ?character ?room)
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
          (human_7c98a61edf861243_p_has ?character ?key)
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
          (not (and (human_7c98a61edf861243_p_locked ?room) (human_7c98a61edf861243_p_unlocked-by ?room ?key) (human_7c98a61edf861243_p_has ?character ?key)))
        )
      )
    :effect
      (when
        (and
          (human_7c98a61edf861243_p_locked ?room)
          (human_7c98a61edf861243_p_has ?character ?key)
          (not (human_7c98a61edf861243_p_unlocked-by ?room ?key))
        )
        (not (human_7c98a61edf861243_p_believes-unlocked-by ?character ?room ?key))
      )
  )

  (:action tiny_stories__story_035_a_wait-for-birthday
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_birthday ?character))
          (not (tiny_stories__story_035_p_waited-for-birthday ?character))
        )
      )
    :effect
      (tiny_stories__story_035_p_waited-for-birthday ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_listen-to-mom
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_listened-to-mom ?character))
          (tiny_stories__story_035_p_waited-for-birthday ?character)
        )
      )
    :effect
      (tiny_stories__story_035_p_listened-to-mom ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_open-box
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (tiny_stories__story_035_p_box-closed)
          (tiny_stories__story_035_p_birthday ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_box-closed))
        (tiny_stories__story_035_p_box-open)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_spoil-cake
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (not (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim))
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_cake-good))
        (tiny_stories__story_035_p_cake-spoiled)
      )
  )

  (:action tiny_stories__story_035_a_keep-cake-good
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim)
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (tiny_stories__story_035_p_cake-good)
  )

  (:action tiny_stories__story_050_a_play-with-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
      )
    :effect
      (tiny_stories__story_050_p_playing-with-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_find-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_playing-with-toys ?character)
      )
    :effect
      (tiny_stories__story_050_p_found-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_stack-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_found-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stacking-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_make-stack-tall
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stacking-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stack-tall ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?helper)
        (tiny_stories__story_050_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_050_p_stack-tall ?helpee)
        )
      )
    :effect
      (tiny_stories__story_050_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_050_a_make-stack-strong
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (and
          (tiny_stories__story_050_p_stack-tall ?character)
          (tiny_stories__story_050_p_helping ?character ?character)
        )
      )
    :effect
      (tiny_stories__story_050_p_stack-strong ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stack-strong ?character)
      )
    :effect
      (tiny_stories__story_050_p_happy ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?from)
        (writing_prompts__wp_019_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_019_p_at ?character ?from))
        (writing_prompts__wp_019_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_set-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_019_p_explosives-set ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_detonate-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_explosives-set ?place)
        )
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (writing_prompts__wp_019_type_item ?item)
            (writing_prompts__wp_019_p_buried ?item ?place)
          )
          (writing_prompts__wp_019_p_destroyed ?item)
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_destroy-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_item ?item)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_019_p_has ?character ?item))
        (writing_prompts__wp_019_p_destroyed ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_083_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_friends ?character1 ?character2))
        )
      )
    :effect
      (writing_prompts__wp_083_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_083_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_in-love ?character1 ?character2))
          (writing_prompts__wp_083_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_083_a_betray
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_in-love ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_redeem
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_083_p_betrayed ?character1 ?character2))
        (writing_prompts__wp_083_p_in-love ?character1 ?character2)
      )
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_bring-peace
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character)
        (writing_prompts__wp_083_type_place ?place)
        (and
          (not (writing_prompts__wp_083_p_peace ?place))
          (exists
            (?character2 - object)
            (and
              (writing_prompts__wp_083_type_character ?character2)
              (writing_prompts__wp_083_p_in-love ?character ?character2)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_083_p_peace ?place)
    :agents (?character)
  )
)
