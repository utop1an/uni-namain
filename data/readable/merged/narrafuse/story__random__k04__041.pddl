(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (shared_p_consensus_f6a081cb9eebf5b5 ?v0 - object)
    (shared_p_consensus_e61f3164ec6eff9e ?v0 - object ?v1 - object)
    (shared_p_consensus_f4d31ad3de851b54 ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (tiny_stories__story_094_p_sad ?v0 - object)
    (tiny_stories__story_094_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_016_active)
    (writing_prompts__wp_016_type_character ?x - object)
    (writing_prompts__wp_016_type_item ?x - object)
    (writing_prompts__wp_016_type_object ?x - object)
    (writing_prompts__wp_016_type_place ?x - object)
    (shared_p_consensus_3bd3e42bbf2c1d79 ?v0 - object)
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
        (shared_p_consensus_f6a081cb9eebf5b5 ?character)
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
          (shared_p_consensus_f6a081cb9eebf5b5 ?character)
          (shared_p_consensus_f4d31ad3de851b54 ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_e61f3164ec6eff9e ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_f6a081cb9eebf5b5 ?character)
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
          (shared_p_consensus_f6a081cb9eebf5b5 ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (shared_p_consensus_f6a081cb9eebf5b5 ?character)
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
          (shared_p_consensus_f6a081cb9eebf5b5 ?giver)
          (not (shared_p_consensus_f4d31ad3de851b54 ?receiver ?item))
          (shared_p_consensus_f4d31ad3de851b54 ?giver ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_f4d31ad3de851b54 ?receiver ?item)
        (shared_p_consensus_f6a081cb9eebf5b5 ?receiver)
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
          (shared_p_consensus_f4d31ad3de851b54 ?character ?item)
          (not (tiny_stories__story_094_p_sad ?character))
        )
      )
    :effect
      (shared_p_consensus_f6a081cb9eebf5b5 ?character)
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
          (shared_p_consensus_f4d31ad3de851b54 ?victim ?item)
          (not (shared_p_consensus_f4d31ad3de851b54 ?taker ?item))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f4d31ad3de851b54 ?victim ?item))
        (shared_p_consensus_f4d31ad3de851b54 ?taker ?item)
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
          (shared_p_consensus_f4d31ad3de851b54 ?character ?item)
          (shared_p_consensus_f6a081cb9eebf5b5 ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f4d31ad3de851b54 ?character ?item))
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?learner)
          (shared_p_consensus_3bd3e42bbf2c1d79 ?teacher)
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?character)
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?killer)
          (shared_p_consensus_3bd3e42bbf2c1d79 ?victim)
          (not (= ?killer ?victim))
        )
      )
    :effect
      (not (shared_p_consensus_3bd3e42bbf2c1d79 ?victim))
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?character)
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?character)
          (not (shared_p_consensus_e61f3164ec6eff9e ?character ?place))
        )
      )
    :effect
      (shared_p_consensus_e61f3164ec6eff9e ?character ?place)
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
          (shared_p_consensus_3bd3e42bbf2c1d79 ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (shared_p_consensus_e61f3164ec6eff9e ?character ?place)
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
