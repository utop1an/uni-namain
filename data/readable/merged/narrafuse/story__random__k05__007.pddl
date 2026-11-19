(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_003_p_broken-pedal ?v0 - object)
    (tiny_stories__story_003_p_fixed-pedal ?v0 - object)
    (tiny_stories__story_003_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_003_p_at-shop ?v0 - object)
    (tiny_stories__story_003_p_happy ?v0 - object)
    (tiny_stories__story_003_p_flying ?v0 - object)
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_030_p_hungry ?v0 - object)
    (shared_p_consensus_e968c4142e4597ec ?v0 - object ?v1 - object)
    (shared_p_consensus_4cce9c1f1e51028a ?v0 - object)
    (tiny_stories__story_030_p_food-available)
    (tiny_stories__story_041_active)
    (tiny_stories__story_041_type_character ?x - object)
    (tiny_stories__story_041_type_object ?x - object)
    (tiny_stories__story_041_p_kind ?v0 - object)
    (tiny_stories__story_041_p_knows-wisdom ?v0 - object)
    (tiny_stories__story_041_p_lost ?v0 - object)
    (tiny_stories__story_041_p_found ?v0 - object)
    (writing_prompts__wp_023_active)
    (writing_prompts__wp_023_type_character ?x - object)
    (writing_prompts__wp_023_type_object ?x - object)
    (writing_prompts__wp_023_p_dead ?v0 - object)
    (writing_prompts__wp_023_p_has-plan ?v0 - object)
    (writing_prompts__wp_023_p_has-time ?v0 - object)
    (writing_prompts__wp_023_p_has-idea ?v0 - object)
    (writing_prompts__wp_023_p_has-tv-show-reference ?v0 - object)
    (writing_prompts__wp_023_p_has-creative-plan ?v0 - object)
    (writing_prompts__wp_023_p_has-better-plan ?v0 - object)
    (writing_prompts__wp_037_active)
    (writing_prompts__wp_037_type_character ?x - object)
    (writing_prompts__wp_037_type_object ?x - object)
    (writing_prompts__wp_037_p_knows ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_together ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_missing ?v0 - object)
    (writing_prompts__wp_037_p_relationship ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_searching ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_found ?v0 - object ?v1 - object)
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
          (tiny_stories__story_003_p_has ?character ?bike)
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

  (:action tiny_stories__story_003_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_happy ?character))
      )
    :effect
      (tiny_stories__story_003_p_happy ?character)
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

  (:action tiny_stories__story_030_a_ask-to-be-friends
    :parameters (?asker - object ?askee - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?asker)
        (tiny_stories__story_030_type_character ?askee)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?asker)
          (shared_p_consensus_4cce9c1f1e51028a ?askee)
          (not (shared_p_consensus_e968c4142e4597ec ?asker ?askee))
        )
      )
    :effect
      (shared_p_consensus_e968c4142e4597ec ?asker ?askee)
    :agents (?asker)
  )

  (:action tiny_stories__story_030_a_search-for-food
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?character)
        (shared_p_consensus_4cce9c1f1e51028a ?character)
      )
    :effect
      (tiny_stories__story_030_p_food-available)
    :agents (?character)
  )

  (:action tiny_stories__story_030_a_feed
    :parameters (?feeder - object ?eater - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?feeder)
        (tiny_stories__story_030_type_character ?eater)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?feeder)
          (shared_p_consensus_4cce9c1f1e51028a ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (tiny_stories__story_030_p_food-available)
        )
      )
    :effect
      (not (tiny_stories__story_030_p_hungry ?eater))
    :agents (?feeder)
  )

  (:action tiny_stories__story_030_a_eat
    :parameters (?eater - object ?eaten - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?eater)
        (tiny_stories__story_030_type_character ?eaten)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (shared_p_consensus_4cce9c1f1e51028a ?eaten)
        )
      )
    :effect
      (not (shared_p_consensus_4cce9c1f1e51028a ?eaten))
    :agents (?eater)
  )

  (:action tiny_stories__story_041_a_become-kind
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?character)
        (not (tiny_stories__story_041_p_kind ?character))
      )
    :effect
      (tiny_stories__story_041_p_kind ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_041_a_learn-wisdom
    :parameters (?learner - object ?teacher - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?learner)
        (tiny_stories__story_041_type_character ?teacher)
        (and
          (not (tiny_stories__story_041_p_knows-wisdom ?learner))
          (tiny_stories__story_041_p_knows-wisdom ?teacher)
        )
      )
    :effect
      (tiny_stories__story_041_p_knows-wisdom ?learner)
    :agents (?learner ?teacher)
  )

  (:action tiny_stories__story_041_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?helper)
        (tiny_stories__story_041_type_character ?helpee)
        (and
          (tiny_stories__story_041_p_kind ?helper)
          (tiny_stories__story_041_p_lost ?helpee)
        )
      )
    :effect
      (tiny_stories__story_041_p_found ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_041_a_become-friends
    :parameters (?c1 - object ?c2 - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?c1)
        (tiny_stories__story_041_type_character ?c2)
        (and
          (not (shared_p_consensus_e968c4142e4597ec ?c1 ?c2))
          (not (= ?c1 ?c2))
        )
      )
    :effect
      (shared_p_consensus_e968c4142e4597ec ?c1 ?c2)
    :agents (?c1 ?c2)
  )

  (:action writing_prompts__wp_023_a_present-plan
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?character)
          (writing_prompts__wp_023_p_has-plan ?character)
        )
      )
    :effect
      (and
        (writing_prompts__wp_023_p_has-idea ?character)
        (when
          (writing_prompts__wp_023_p_has-tv-show-reference ?character)
          (not (writing_prompts__wp_023_p_has-creative-plan ?character))
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_023_a_decide-fate
    :parameters (?council - object ?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?council)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?council)
          (shared_p_consensus_4cce9c1f1e51028a ?character)
          (writing_prompts__wp_023_p_has-idea ?character)
        )
      )
    :effect
      (when
        (writing_prompts__wp_023_p_has-creative-plan ?character)
        (and
          (writing_prompts__wp_023_p_has-better-plan ?character)
          (writing_prompts__wp_023_p_has-time ?character)
        )
      )
    :agents (?council)
  )

  (:action writing_prompts__wp_023_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (shared_p_consensus_4cce9c1f1e51028a ?character)
          (not (writing_prompts__wp_023_p_has-time ?character))
        )
      )
    :effect
      (writing_prompts__wp_023_p_dead ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_037_a_start-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (not (= ?searcher ?target))
          (not (writing_prompts__wp_037_p_searching ?searcher ?target))
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (writing_prompts__wp_037_p_searching ?searcher ?target)
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_stop-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (writing_prompts__wp_037_p_searching ?searcher ?target)
      )
    :effect
      (not (writing_prompts__wp_037_p_searching ?searcher ?target))
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_find
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (writing_prompts__wp_037_p_searching ?searcher ?target)
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_037_p_missing ?target))
        (writing_prompts__wp_037_p_found ?searcher ?target)
      )
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_start-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
          (writing_prompts__wp_037_p_knows ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_037_p_relationship ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_037_a_end-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (writing_prompts__wp_037_p_relationship ?character1 ?character2)
      )
    :effect
      (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
    :agents (?character1 ?character2)
  )
)
