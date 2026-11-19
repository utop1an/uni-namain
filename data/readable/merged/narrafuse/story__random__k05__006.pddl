(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_003_p_broken-pedal ?v0 - object)
    (tiny_stories__story_003_p_fixed-pedal ?v0 - object)
    (shared_p_consensus_e53efe3f36bb77d7 ?v0 - object ?v1 - object)
    (tiny_stories__story_003_p_at-shop ?v0 - object)
    (shared_p_consensus_1bfb41b000a0598c ?v0 - object)
    (tiny_stories__story_003_p_flying ?v0 - object)
    (tiny_stories__story_017_active)
    (tiny_stories__story_017_type_character ?x - object)
    (tiny_stories__story_017_type_object ?x - object)
    (tiny_stories__story_017_p_watches-tv ?v0 - object)
    (tiny_stories__story_017_p_rude ?v0 - object)
    (tiny_stories__story_017_p_nice ?v0 - object)
    (tiny_stories__story_017_p_wants-to-watch-tv ?v0 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_012_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_057_p_liberated ?v0 - object)
    (writing_prompts__wp_057_p_defeated-illuminati)
    (writing_prompts__wp_057_p_alien-exists ?v0 - object)
    (writing_prompts__wp_057_p_alien-gone ?v0 - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (writing_prompts__wp_081_p_alive ?v0 - object)
    (writing_prompts__wp_081_p_has-emotion ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_p_knows-change ?v0 - object)
    (writing_prompts__wp_081_p_memorize ?v0 - object)
  )

  (:action tiny_stories__story_003_a_go-to-shop
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_at-shop ?character))
      )
    :effect
      (tiny_stories__story_003_p_at-shop ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_fix-pedal
    :parameters (?character - object ?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_at-shop ?character)
          (shared_p_consensus_e53efe3f36bb77d7 ?character ?bike)
          (tiny_stories__story_003_p_broken-pedal ?bike)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_003_p_broken-pedal ?bike))
        (tiny_stories__story_003_p_fixed-pedal ?bike)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_start-flying
    :parameters (?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_fixed-pedal ?bike)
          (not (tiny_stories__story_003_p_flying ?bike))
        )
      )
    :effect
      (tiny_stories__story_003_p_flying ?bike)
  )

  (:action tiny_stories__story_017_a_start-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_wants-to-watch-tv ?character)
      )
    :effect
      (tiny_stories__story_017_p_watches-tv ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_stop-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_watches-tv ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_watches-tv ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_rude ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_rude ?character))
        (tiny_stories__story_017_p_nice ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-rude
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_nice ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_nice ?character))
        (tiny_stories__story_017_p_rude ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-unhappy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (shared_p_consensus_1bfb41b000a0598c ?character)
      )
    :effect
      (not (shared_p_consensus_1bfb41b000a0598c ?character))
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
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_garage)
          (not (writing_prompts__wp_012_p_assembled ?robot))
        )
      )
    :effect
      (and
        (writing_prompts__wp_012_p_assembled ?robot)
        (shared_p_consensus_e53efe3f36bb77d7 ?character ?robot)
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
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_house)
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

  (:action writing_prompts__wp_057_a_liberate
    :parameters (?alien - object ?human - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_type_character ?human)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_liberated ?human))
        )
      )
    :effect
      (writing_prompts__wp_057_p_liberated ?human)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_defeat-illuminati
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_defeated-illuminati))
        )
      )
    :effect
      (writing_prompts__wp_057_p_defeated-illuminati)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_disappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-exists ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-gone ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_reappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-gone ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-exists ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_081_a_experience-emotion
    :parameters (?character - object ?emotion - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_type_emotion ?emotion)
        (writing_prompts__wp_081_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_081_p_has-emotion ?character ?emotion)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_notice-change
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_081_p_knows-change ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_memorize-appearance
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (and
          (writing_prompts__wp_081_p_alive ?character)
          (writing_prompts__wp_081_p_knows-change ?character)
        )
      )
    :effect
      (writing_prompts__wp_081_p_memorize ?character)
    :agents (?character)
  )

  (:action fused_a_consensus_97223e60540884aa
    :parameters (?m0 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?m0)
          (not (shared_p_consensus_1bfb41b000a0598c ?m0))
        )
        (and
          (tiny_stories__story_017_active)
          (tiny_stories__story_017_type_character ?m0)
        )
      )
    :effect
      (shared_p_consensus_1bfb41b000a0598c ?m0)
    :agents (?m0)
  )
)
