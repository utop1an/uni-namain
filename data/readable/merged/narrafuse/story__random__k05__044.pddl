(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (shared_p_consensus_bb09d01a7ea5c41d ?v0 - object ?v1 - object)
    (shared_p_consensus_8ff82eb4f533376c ?v0 - object ?v1 - object)
    (shared_p_consensus_ead495494448a931 ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_083_active)
    (tiny_stories__story_083_type_character ?x - object)
    (tiny_stories__story_083_type_object ?x - object)
    (tiny_stories__story_083_p_fierce ?v0 - object)
    (tiny_stories__story_083_p_scared ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_083_p_sneezed ?v0 - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
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
  )

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_bb09d01a7ea5c41d ?character ?place)
          (not (shared_p_consensus_8ff82eb4f533376c ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_8ff82eb4f533376c ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_bb09d01a7ea5c41d ?giver ?place)
          (shared_p_consensus_8ff82eb4f533376c ?giver ?item)
          (shared_p_consensus_bb09d01a7ea5c41d ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8ff82eb4f533376c ?giver ?item))
        (shared_p_consensus_8ff82eb4f533376c ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_bb09d01a7ea5c41d ?character ?place)
          (shared_p_consensus_8ff82eb4f533376c ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_ead495494448a931 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (shared_p_consensus_ead495494448a931 ?target))
        )
      )
    :effect
      (shared_p_consensus_ead495494448a931 ?target)
    :agents (?character)
  )

  (:action tiny_stories__story_083_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (tiny_stories__story_083_p_friends ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_083_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_083_a_play
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_083_p_friends ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_playing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_083_a_sneeze
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character)
      )
    :effect
      (tiny_stories__story_083_p_sneezed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_083_a_become-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_083_p_fierce ?character2)
        )
      )
    :effect
      (tiny_stories__story_083_p_scared ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_083_a_stop-being-scared
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_083_active)
        (tiny_stories__story_083_type_character ?character1)
        (tiny_stories__story_083_type_character ?character2)
        (tiny_stories__story_083_p_scared ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_083_p_scared ?character1 ?character2))
    :agents (?character1)
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
        (shared_p_consensus_ead495494448a931 ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_assemble
    :parameters (?character - object ?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (shared_p_consensus_bb09d01a7ea5c41d ?character writing_prompts__wp_012_o_garage)
          (not (writing_prompts__wp_012_p_assembled ?robot))
        )
      )
    :effect
      (and
        (writing_prompts__wp_012_p_assembled ?robot)
        (shared_p_consensus_8ff82eb4f533376c ?character ?robot)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_start-task
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_assembled ?robot)
          (not (writing_prompts__wp_012_p_working-on-task ?robot))
        )
      )
    :effect
      (writing_prompts__wp_012_p_working-on-task ?robot)
    :agents (?robot)
  )

  (:action writing_prompts__wp_012_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (and
          (shared_p_consensus_bb09d01a7ea5c41d ?character writing_prompts__wp_012_o_house)
          (not (writing_prompts__wp_012_p_playing-game ?character))
        )
      )
    :effect
      (writing_prompts__wp_012_p_playing-game ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_stop-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_p_playing-game ?character)
      )
    :effect
      (not (writing_prompts__wp_012_p_playing-game ?character))
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
)
