(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (tiny_stories__story_060_p_happy ?v0 - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (tiny_stories__story_094_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_094_p_happy ?v0 - object)
    (tiny_stories__story_094_p_sad ?v0 - object)
    (tiny_stories__story_094_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_active)
    (writing_prompts__wp_016_type_character ?x - object)
    (writing_prompts__wp_016_type_item ?x - object)
    (writing_prompts__wp_016_type_object ?x - object)
    (writing_prompts__wp_016_type_place ?x - object)
    (writing_prompts__wp_016_p_alive ?v0 - object)
    (writing_prompts__wp_016_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_p_knows-survival-skills ?v0 - object)
    (writing_prompts__wp_016_p_computers-working)
    (writing_prompts__wp_016_p_caused-apocalypse ?v0 - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (writing_prompts__wp_042_p_alive ?v0 - object)
    (writing_prompts__wp_042_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_drunk ?v0 - object)
    (writing_prompts__wp_042_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_night-show ?v0 - object)
    (writing_prompts__wp_042_p_vomit-stain ?v0 - object)
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

  (:action tiny_stories__story_094_a_receive-gift
    :parameters (?receiver - object ?giver - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?receiver)
        (tiny_stories__story_094_type_character ?giver)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?receiver ?giver))
          (tiny_stories__story_094_p_happy ?giver)
          (not (tiny_stories__story_094_p_has ?receiver ?item))
          (tiny_stories__story_094_p_has ?giver ?item)
        )
      )
    :effect
      (and
        (tiny_stories__story_094_p_has ?receiver ?item)
        (tiny_stories__story_094_p_happy ?receiver)
      )
    :agents (?receiver ?giver)
  )

  (:action tiny_stories__story_094_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (not (tiny_stories__story_094_p_sad ?character))
        )
      )
    :effect
      (tiny_stories__story_094_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_take-toy
    :parameters (?taker - object ?victim - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?taker)
        (tiny_stories__story_094_type_character ?victim)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?taker ?victim))
          (tiny_stories__story_094_p_has ?victim ?item)
          (not (tiny_stories__story_094_p_has ?taker ?item))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?victim ?item))
        (tiny_stories__story_094_p_has ?taker ?item)
        (tiny_stories__story_094_p_sad ?victim)
      )
    :agents (?taker)
  )

  (:action tiny_stories__story_094_a_lose-toy
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (tiny_stories__story_094_p_has ?character ?item)
          (tiny_stories__story_094_p_happy ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_094_p_has ?character ?item))
        (tiny_stories__story_094_p_sad ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_016_a_learn-survival-skills
    :parameters (?learner - object ?teacher - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?learner)
        (writing_prompts__wp_016_type_character ?teacher)
        (and
          (writing_prompts__wp_016_p_alive ?learner)
          (writing_prompts__wp_016_p_alive ?teacher)
          (writing_prompts__wp_016_p_knows-survival-skills ?teacher)
          (not (writing_prompts__wp_016_p_knows-survival-skills ?learner))
        )
      )
    :effect
      (writing_prompts__wp_016_p_knows-survival-skills ?learner)
    :agents (?learner ?teacher)
  )

  (:action writing_prompts__wp_016_a_cause-apocalypse
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?character)
        (and
          (writing_prompts__wp_016_p_alive ?character)
          (writing_prompts__wp_016_p_computers-working)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_016_p_computers-working))
        (writing_prompts__wp_016_p_caused-apocalypse ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_016_a_kill
    :parameters (?killer - object ?victim - object)
    :precondition
      (and
        (writing_prompts__wp_016_active)
        (writing_prompts__wp_016_type_character ?killer)
        (writing_prompts__wp_016_type_character ?victim)
        (and
          (writing_prompts__wp_016_p_alive ?killer)
          (writing_prompts__wp_016_p_alive ?victim)
          (not (= ?killer ?victim))
        )
      )
    :effect
      (not (writing_prompts__wp_016_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_042_a_drink
    :parameters (?character - object ?drink - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_drink ?drink)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (writing_prompts__wp_042_p_has ?character ?drink)
        )
      )
    :effect
      (and
        (writing_prompts__wp_042_p_drunk ?character)
        (not (writing_prompts__wp_042_p_has ?character ?drink))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (not (writing_prompts__wp_042_p_at ?character ?place))
        )
      )
    :effect
      (writing_prompts__wp_042_p_at ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_vomit
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (writing_prompts__wp_042_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_042_p_vomit-stain ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_sober-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_p_drunk ?character)
      )
    :effect
      (not (writing_prompts__wp_042_p_drunk ?character))
    :agents (?character)
  )
)
