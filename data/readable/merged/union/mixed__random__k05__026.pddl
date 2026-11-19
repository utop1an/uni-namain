(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:constants writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object)
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
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_awake ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (tiny_stories__story_027_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_found ?v0 - object)
    (tiny_stories__story_027_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_searched ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_active)
    (writing_prompts__wp_006_type_character ?x - object)
    (writing_prompts__wp_006_type_object ?x - object)
    (writing_prompts__wp_006_type_place ?x - object)
    (writing_prompts__wp_006_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_alive ?v0 - object)
    (writing_prompts__wp_006_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_accepts-past ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_knows-self ?v0 - object)
    (writing_prompts__wp_006_p_sings ?v0 - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
    (writing_prompts__wp_047_p_at-peace ?v0 - object)
    (writing_prompts__wp_047_p_sharing-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_047_p_advanced-technology ?v0 - object)
    (writing_prompts__wp_047_p_facing-destruction)
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

  (:action tiny_stories__story_011_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (not (tiny_stories__story_011_p_at ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_011_p_at ?character ?place)
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
          (tiny_stories__story_011_p_at ?character ?place)
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

  (:action tiny_stories__story_027_a_hide
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (tiny_stories__story_027_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_027_p_hidden ?toy ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?place)
        (and
          (tiny_stories__story_027_p_at ?character ?place)
          (not (tiny_stories__story_027_p_searched ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_027_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_find
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (and
          (tiny_stories__story_027_p_at ?character ?place)
          (tiny_stories__story_027_p_hidden ?toy ?place)
          (tiny_stories__story_027_p_searched ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_027_p_found ?toy)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?from)
        (tiny_stories__story_027_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_027_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_027_p_at ?character ?from))
        (tiny_stories__story_027_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_type_place ?from)
        (writing_prompts__wp_006_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_006_p_alive ?character)
          (writing_prompts__wp_006_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_006_p_at ?character ?from))
        (writing_prompts__wp_006_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_006_p_sings ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_006_p_alive ?character1)
          (writing_prompts__wp_006_p_alive ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_accept-past
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_006_p_alive ?character1)
          (writing_prompts__wp_006_p_alive ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_accepts-past ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_know-self
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_006_p_knows-self ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_047_a_unite
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_facing-destruction)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_develop-technology
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_advanced-technology ?nation1)
        (writing_prompts__wp_047_p_advanced-technology ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_avoid-destruction
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (and
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation1)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation2)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation3)
        )
      )
    :effect
      (not (writing_prompts__wp_047_p_facing-destruction))
  )

  (:action writing_prompts__wp_047_a_maintain-peace
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_at-peace ?nation1)
          (writing_prompts__wp_047_p_at-peace ?nation2)
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
  )
)
