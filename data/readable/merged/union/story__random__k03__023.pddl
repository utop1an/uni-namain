(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_084_o_rocket - object)
  (:predicates
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (tiny_stories__story_039_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_084_active)
    (tiny_stories__story_084_type_character ?x - object)
    (tiny_stories__story_084_type_item ?x - object)
    (tiny_stories__story_084_type_object ?x - object)
    (tiny_stories__story_084_type_place ?x - object)
    (tiny_stories__story_084_type_toy ?x - object)
    (tiny_stories__story_084_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_played-with ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_happy ?v0 - object)
    (writing_prompts__wp_031_active)
    (writing_prompts__wp_031_type_character ?x - object)
    (writing_prompts__wp_031_type_object ?x - object)
    (writing_prompts__wp_031_type_ship ?x - object)
    (writing_prompts__wp_031_p_alive ?v0 - object)
    (writing_prompts__wp_031_p_on-ship ?v0 - object ?v1 - object)
    (writing_prompts__wp_031_p_moby-dick-spotted ?v0 - object)
    (writing_prompts__wp_031_p_moby-dick-attacking ?v0 - object)
    (writing_prompts__wp_031_p_read-moby-dick ?v0 - object)
    (writing_prompts__wp_031_p_trained-in-whale-killing ?v0 - object)
    (writing_prompts__wp_031_p_battle-stations ?v0 - object)
  )

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (tiny_stories__story_039_p_at ?character ?place)
          (tiny_stories__story_039_p_lost ?character ?cap)
        )
      )
    :effect
      (tiny_stories__story_039_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_find
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (and
          (tiny_stories__story_039_p_lost ?character ?cap)
          (forall
            (?place - object)
            (or
              (not (tiny_stories__story_039_type_place ?place))
              (tiny_stories__story_039_p_searched ?character ?place)
            )
          )
        )
      )
    :effect
      (and
        (tiny_stories__story_039_p_found ?character ?cap)
        (not (tiny_stories__story_039_p_lost ?character ?cap))
        (tiny_stories__story_039_p_has ?character ?cap)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_lose
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_p_has ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (tiny_stories__story_039_p_has ?character ?cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_replace
    :parameters (?character - object ?old-cap - object ?new-cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?old-cap)
        (tiny_stories__story_039_type_cap ?new-cap)
        (and
          (tiny_stories__story_039_p_found ?character ?old-cap)
          (not (tiny_stories__story_039_p_has ?character ?old-cap))
          (tiny_stories__story_039_p_has ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_039_p_found ?character ?old-cap))
        (tiny_stories__story_039_p_has ?character ?old-cap)
        (not (tiny_stories__story_039_p_has ?character ?new-cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (tiny_stories__story_084_p_at ?character ?place)
          (not (tiny_stories__story_084_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_084_p_found ?character ?item)
        (tiny_stories__story_084_p_has ?character ?item)
        (tiny_stories__story_084_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_show
    :parameters (?shower - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?shower)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_character ?receiver)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?shower ?receiver))
          (tiny_stories__story_084_p_at ?shower ?place)
          (tiny_stories__story_084_p_has ?shower ?item)
          (tiny_stories__story_084_p_at ?receiver ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_happy ?receiver)
    :agents (?shower ?receiver)
  )

  (:action tiny_stories__story_084_a_play
    :parameters (?character1 - object ?character2 - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character1)
        (tiny_stories__story_084_type_character ?character2)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_084_p_at ?character1 ?place)
          (tiny_stories__story_084_p_has ?character1 ?item)
          (tiny_stories__story_084_p_at ?character2 ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_played-with ?character1 ?item)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_084_a_fly-high
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_p_played-with ?character tiny_stories__story_084_o_rocket)
      )
    :effect
      (tiny_stories__story_084_p_happy ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_spot-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_moby-dick-attack
    :parameters (?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_ship ?ship)
        (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
      )
    :effect
      (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
  )

  (:action writing_prompts__wp_031_a_order-battle-stations
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_moby-dick-spotted ?ship)
        )
      )
    :effect
      (writing_prompts__wp_031_p_battle-stations ?ship)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_try-kill-moby-dick
    :parameters (?character - object ?ship - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_type_ship ?ship)
        (and
          (writing_prompts__wp_031_p_alive ?character)
          (writing_prompts__wp_031_p_on-ship ?character ?ship)
          (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
          (writing_prompts__wp_031_p_moby-dick-attacking ?ship)
          (writing_prompts__wp_031_p_battle-stations ?ship)
        )
      )
    :effect
      (not (writing_prompts__wp_031_p_moby-dick-attacking ?ship))
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_read-moby-dick
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_031_p_read-moby-dick ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_031_a_train-in-whale-killing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_031_active)
        (writing_prompts__wp_031_type_character ?character)
        (writing_prompts__wp_031_p_read-moby-dick ?character)
      )
    :effect
      (writing_prompts__wp_031_p_trained-in-whale-killing ?character)
    :agents (?character)
  )
)
