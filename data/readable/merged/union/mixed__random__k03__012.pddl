(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object writing_prompts__wp_076_o_peter - object writing_prompts__wp_076_o_hook - object writing_prompts__wp_076_o_lost-boys - object writing_prompts__wp_076_o_pirates - object)
  (:predicates
    (human_281c51d26d5d4ff3_active)
    (human_281c51d26d5d4ff3_type_allworker ?x - object)
    (human_281c51d26d5d4ff3_type_axe ?x - object)
    (human_281c51d26d5d4ff3_type_beast ?x - object)
    (human_281c51d26d5d4ff3_type_blacksmith ?x - object)
    (human_281c51d26d5d4ff3_type_cake ?x - object)
    (human_281c51d26d5d4ff3_type_character ?x - object)
    (human_281c51d26d5d4ff3_type_fox ?x - object)
    (human_281c51d26d5d4ff3_type_girl ?x - object)
    (human_281c51d26d5d4ff3_type_grandmother ?x - object)
    (human_281c51d26d5d4ff3_type_house ?x - object)
    (human_281c51d26d5d4ff3_type_human ?x - object)
    (human_281c51d26d5d4ff3_type_hunter ?x - object)
    (human_281c51d26d5d4ff3_type_object ?x - object)
    (human_281c51d26d5d4ff3_type_thing ?x - object)
    (human_281c51d26d5d4ff3_type_wolf ?x - object)
    (human_281c51d26d5d4ff3_type_worker ?x - object)
    (human_281c51d26d5d4ff3_p_monster ?v0 - object)
    (human_281c51d26d5d4ff3_p_monster-alive)
    (human_281c51d26d5d4ff3_p_rescuer ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescuer-at ?v0 - object)
    (human_281c51d26d5d4ff3_p_alive ?v0 - object)
    (human_281c51d26d5d4ff3_p_has ?v0 - object ?v1 - object)
    (human_281c51d26d5d4ff3_p_eaten ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescued ?v0 - object)
    (human_281c51d26d5d4ff3_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_happy ?v0 - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
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

  (:action human_281c51d26d5d4ff3_a_walk
    :parameters (?c - object ?h1 - object ?h2 - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_character ?c)
        (human_281c51d26d5d4ff3_type_house ?h1)
        (human_281c51d26d5d4ff3_type_house ?h2)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (human_281c51d26d5d4ff3_p_at ?c ?h1)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_at ?c ?h1))
        (human_281c51d26d5d4ff3_p_at ?c ?h2)
        (when
          (human_281c51d26d5d4ff3_p_rescuer ?c)
          (and
            (human_281c51d26d5d4ff3_p_rescuer-at ?h2)
            (not (human_281c51d26d5d4ff3_p_rescuer-at ?h1))
          )
        )
      )
  )

  (:action human_281c51d26d5d4ff3_a_eat
    :parameters (?m - object ?c - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?m)
          (human_281c51d26d5d4ff3_p_alive ?c)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
          (human_281c51d26d5d4ff3_p_at ?m ?h)
          (human_281c51d26d5d4ff3_p_at ?c ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
        )
      )
    :effect
      (human_281c51d26d5d4ff3_p_eaten ?c)
  )

  (:action human_281c51d26d5d4ff3_a_kill
    :parameters (?c - object ?m - object ?a - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_worker ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_axe ?a)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (human_281c51d26d5d4ff3_p_alive ?m)
          (human_281c51d26d5d4ff3_p_has ?c ?a)
          (human_281c51d26d5d4ff3_p_at ?c ?h)
          (human_281c51d26d5d4ff3_p_at ?m ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
          (human_281c51d26d5d4ff3_p_monster-alive)
          (human_281c51d26d5d4ff3_p_rescuer ?c)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_alive ?m))
        (not (human_281c51d26d5d4ff3_p_monster-alive))
      )
  )

  (:action human_281c51d26d5d4ff3_a_escape
    :parameters (?c - object ?m - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_eaten ?c)
          (not (human_281c51d26d5d4ff3_p_alive ?m))
          (human_281c51d26d5d4ff3_p_at ?m ?h)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_eaten ?c))
        (human_281c51d26d5d4ff3_p_rescued ?c)
        (human_281c51d26d5d4ff3_p_at ?c ?h)
      )
  )

  (:action human_281c51d26d5d4ff3_a_give
    :parameters (?c1 - object ?c2 - object ?t - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c1)
        (human_281c51d26d5d4ff3_type_human ?c2)
        (human_281c51d26d5d4ff3_type_thing ?t)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (not (human_281c51d26d5d4ff3_p_eaten ?c2))
          (human_281c51d26d5d4ff3_p_alive ?c1)
          (human_281c51d26d5d4ff3_p_alive ?c2)
          (human_281c51d26d5d4ff3_p_has ?c1 ?t)
          (human_281c51d26d5d4ff3_p_at ?c1 ?h)
          (human_281c51d26d5d4ff3_p_at ?c2 ?h)
        )
      )
    :effect
      (and
        (human_281c51d26d5d4ff3_p_has ?c2 ?t)
        (not (human_281c51d26d5d4ff3_p_has ?c1 ?t))
      )
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_060_p_at ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (tiny_stories__story_060_p_happy ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (tiny_stories__story_060_p_happy ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (tiny_stories__story_060_p_happy ?character)
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
)
