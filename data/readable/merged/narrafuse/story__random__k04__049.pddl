(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_076_o_peter - object writing_prompts__wp_076_o_hook - object writing_prompts__wp_076_o_lost-boys - object writing_prompts__wp_076_o_pirates - object)
  (:predicates
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_happy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
    (writing_prompts__wp_019_active)
    (writing_prompts__wp_019_type_character ?x - object)
    (writing_prompts__wp_019_type_item ?x - object)
    (writing_prompts__wp_019_type_object ?x - object)
    (writing_prompts__wp_019_type_place ?x - object)
    (shared_p_consensus_2c5387fa85b5ba12 ?v0 - object)
    (shared_p_consensus_a52d55ef109c7b20 ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_buried ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_destroyed ?v0 - object)
    (writing_prompts__wp_019_p_explosives-set ?v0 - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (writing_prompts__wp_032_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_wolves-attack ?v0 - object)
    (writing_prompts__wp_032_p_wolves-killed ?v0 - object)
    (writing_prompts__wp_076_active)
    (writing_prompts__wp_076_type_character ?x - object)
    (writing_prompts__wp_076_type_group ?x - object)
    (writing_prompts__wp_076_type_object ?x - object)
    (writing_prompts__wp_076_type_place ?x - object)
    (writing_prompts__wp_076_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_076_p_alive ?v0 - object)
    (writing_prompts__wp_076_p_has-weapon ?v0 - object)
    (writing_prompts__wp_076_p_in-group ?v0 - object ?v1 - object)
    (writing_prompts__wp_076_p_group-exists ?v0 - object)
    (writing_prompts__wp_076_p_has-electronics ?v0 - object)
    (writing_prompts__wp_076_p_believes-in-fairies ?v0 - object)
  )

  (:action tiny_stories__story_100_a_start-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_bored ?character)
          (not (tiny_stories__story_100_p_rolling ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_bored ?character))
        (tiny_stories__story_100_p_rolling ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_stop-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_rolling ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_rolling ?character))
        (tiny_stories__story_100_p_dizzy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_lie-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_dizzy ?character)
          (not (tiny_stories__story_100_p_lying-down ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_dizzy ?character))
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_get-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_lying-down ?character))
        (tiny_stories__story_100_p_happy ?character)
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
          (shared_p_consensus_2c5387fa85b5ba12 ?character)
          (shared_p_consensus_a52d55ef109c7b20 ?character ?place)
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
          (shared_p_consensus_2c5387fa85b5ba12 ?character)
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
          (shared_p_consensus_2c5387fa85b5ba12 ?character)
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

  (:action writing_prompts__wp_032_a_kill-wolves
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?place)
        (and
          (shared_p_consensus_2c5387fa85b5ba12 ?character)
          (shared_p_consensus_a52d55ef109c7b20 ?character ?place)
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
        (shared_p_consensus_2c5387fa85b5ba12 ?character)
      )
    :effect
      (not (shared_p_consensus_2c5387fa85b5ba12 ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_076_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_076_active)
        (writing_prompts__wp_076_type_character ?character)
        (writing_prompts__wp_076_type_place ?from)
        (writing_prompts__wp_076_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_076_p_alive ?character)
          (writing_prompts__wp_076_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_076_p_at ?character ?from))
        (writing_prompts__wp_076_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_076_a_fight
    :parameters (?fighter1 - object ?fighter2 - object)
    :precondition
      (and
        (writing_prompts__wp_076_active)
        (writing_prompts__wp_076_type_character ?fighter1)
        (writing_prompts__wp_076_type_character ?fighter2)
        (and
          (not (= ?fighter1 ?fighter2))
          (writing_prompts__wp_076_p_alive ?fighter1)
          (writing_prompts__wp_076_p_has-weapon ?fighter1)
          (writing_prompts__wp_076_p_alive ?fighter2)
          (writing_prompts__wp_076_p_has-weapon ?fighter2)
        )
      )
    :agents (?fighter1 ?fighter2)
  )

  (:action writing_prompts__wp_076_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_076_active)
        (writing_prompts__wp_076_type_character ?character)
        (writing_prompts__wp_076_p_alive ?character)
      )
    :effect
      (not (writing_prompts__wp_076_p_alive ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_076_a_acquire-electronics
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_076_active)
        (writing_prompts__wp_076_type_character ?character)
        (and
          (writing_prompts__wp_076_p_alive ?character)
          (not (writing_prompts__wp_076_p_has-electronics ?character))
        )
      )
    :effect
      (writing_prompts__wp_076_p_has-electronics ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_076_a_stop-believing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_076_active)
        (writing_prompts__wp_076_type_character ?character)
        (and
          (writing_prompts__wp_076_p_alive ?character)
          (writing_prompts__wp_076_p_believes-in-fairies ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_076_p_believes-in-fairies ?character))
    :agents (?character)
  )

  (:action fused_a_consensus_255884c8e39cba91
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (writing_prompts__wp_019_active)
          (writing_prompts__wp_019_type_character ?m0)
          (writing_prompts__wp_019_type_place ?m1)
          (writing_prompts__wp_019_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_2c5387fa85b5ba12 ?m0)
            (shared_p_consensus_a52d55ef109c7b20 ?m0 ?m1)
          )
        )
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?m0)
          (writing_prompts__wp_032_type_place ?m1)
          (writing_prompts__wp_032_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_2c5387fa85b5ba12 ?m0)
            (shared_p_consensus_a52d55ef109c7b20 ?m0 ?m1)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a52d55ef109c7b20 ?m0 ?m1))
        (shared_p_consensus_a52d55ef109c7b20 ?m0 ?m2)
      )
    :agents (?m0)
  )
)
