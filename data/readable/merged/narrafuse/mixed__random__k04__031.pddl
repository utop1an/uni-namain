(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (shared_p_consensus_c5c24d27740d675c ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (human_67ab241b327ccef0_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_awake ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_042_active)
    (tiny_stories__story_042_type_character ?x - object)
    (tiny_stories__story_042_type_object ?x - object)
    (tiny_stories__story_042_p_at-carnival ?v0 - object)
    (tiny_stories__story_042_p_wants-to-play ?v0 - object)
    (tiny_stories__story_042_p_played ?v0 - object)
    (tiny_stories__story_042_p_weight-too-low ?v0 - object)
    (tiny_stories__story_042_p_upset ?v0 - object)
    (tiny_stories__story_042_p_comforted ?v0 - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (writing_prompts__wp_032_p_alive ?v0 - object)
    (writing_prompts__wp_032_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_wolves-attack ?v0 - object)
    (writing_prompts__wp_032_p_wolves-killed ?v0 - object)
  )

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_c5c24d27740d675c ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c5c24d27740d675c ?character ?roomfrom))
        (shared_p_consensus_c5c24d27740d675c ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_c5c24d27740d675c ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (human_67ab241b327ccef0_p_has ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (human_67ab241b327ccef0_p_has ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
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
          (not (shared_p_consensus_c5c24d27740d675c ?character ?place))
        )
      )
    :effect
      (shared_p_consensus_c5c24d27740d675c ?character ?place)
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
          (shared_p_consensus_c5c24d27740d675c ?character ?place)
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

  (:action tiny_stories__story_042_a_go-to-carnival
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
      )
    :effect
      (tiny_stories__story_042_p_at-carnival ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_want-to-play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_at-carnival ?character)
      )
    :effect
      (tiny_stories__story_042_p_wants-to-play ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (and
          (tiny_stories__story_042_p_at-carnival ?character)
          (tiny_stories__story_042_p_wants-to-play ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_042_p_played ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_become-upset
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :effect
      (tiny_stories__story_042_p_upset ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_comfort
    :parameters (?comforter - object ?comforted - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?comforter)
        (tiny_stories__story_042_type_character ?comforted)
        (and
          (not (= ?comforter ?comforted))
          (tiny_stories__story_042_p_upset ?comforted)
        )
      )
    :effect
      (tiny_stories__story_042_p_comforted ?comforted)
    :agents (?comforter)
  )

  (:action writing_prompts__wp_032_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?from)
        (writing_prompts__wp_032_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_032_p_alive ?character)
          (writing_prompts__wp_032_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_032_p_at ?character ?from))
        (writing_prompts__wp_032_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_kill-wolves
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?place)
        (and
          (writing_prompts__wp_032_p_alive ?character)
          (writing_prompts__wp_032_p_at ?character ?place)
          (writing_prompts__wp_032_p_wolves-attack ?place)
        )
      )
    :effect
      (writing_prompts__wp_032_p_wolves-killed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_p_alive ?character)
      )
    :effect
      (not (writing_prompts__wp_032_p_alive ?character))
    :agents (?character)
  )
)
