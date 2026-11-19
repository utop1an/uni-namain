(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (shared_p_consensus_50731404ba53c84c ?v0 - object ?v1 - object)
    (shared_p_consensus_69925c8f8af5f9cd ?v0 - object)
    (tiny_stories__story_077_p_tired ?v0 - object)
    (tiny_stories__story_077_p_played-together ?v0 - object ?v1 - object)
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (tiny_stories__story_078_p_alive ?v0 - object)
    (tiny_stories__story_078_p_amazed ?v0 - object)
    (tiny_stories__story_078_p_supports ?v0 - object ?v1 - object)
    (tiny_stories__story_078_p_persistent ?v0 - object)
    (tiny_stories__story_078_p_completed ?v0 - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_awake ?v0 - object)
    (writing_prompts__wp_029_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
  )

  (:action tiny_stories__story_077_a_play
    :parameters (?character1 - object ?character2 - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character1)
        (tiny_stories__story_077_type_character ?character2)
        (tiny_stories__story_077_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_50731404ba53c84c ?character1 ?place)
          (shared_p_consensus_50731404ba53c84c ?character2 ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_077_p_played-together ?character1 ?character2)
        (shared_p_consensus_69925c8f8af5f9cd ?character1)
        (shared_p_consensus_69925c8f8af5f9cd ?character2)
        (tiny_stories__story_077_p_tired ?character1)
        (tiny_stories__story_077_p_tired ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_077_a_rest
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_p_tired ?character)
      )
    :effect
      (not (tiny_stories__story_077_p_tired ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-amazed
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_amazed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (shared_p_consensus_69925c8f8af5f9cd ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_support-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_supports ?character ?project)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-persistent
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_persistent ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_complete-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (and
          (tiny_stories__story_078_p_alive ?character)
          (tiny_stories__story_078_p_supports ?character ?project)
          (tiny_stories__story_078_p_persistent ?character)
        )
      )
    :effect
      (tiny_stories__story_078_p_completed ?project)
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_awake ?character))
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_asleep ?character))
        (writing_prompts__wp_029_p_awake ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_install-soundproof-door
    :parameters (?gang - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_type_place ?place)
        (and
          (writing_prompts__wp_029_p_awake ?gang)
          (writing_prompts__wp_029_p_at ?gang ?place)
          (not (writing_prompts__wp_029_p_soundproof-door ?place))
        )
      )
    :effect
      (writing_prompts__wp_029_p_soundproof-door ?place)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_rob
    :parameters (?gang - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_p_awake ?gang)
      )
    :effect
      (writing_prompts__wp_029_p_robbed ?gang)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_attack
    :parameters (?attacker - object ?victim - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?attacker)
        (writing_prompts__wp_029_type_character ?victim)
        (and
          (writing_prompts__wp_029_p_awake ?attacker)
          (writing_prompts__wp_029_p_awake ?victim)
        )
      )
    :effect
      (writing_prompts__wp_029_p_attacked ?victim)
    :agents (?attacker)
  )

  (:action writing_prompts__wp_029_a_clear-passage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_attacked ?character))
        (writing_prompts__wp_029_p_has-hoard ?character)
      )
    :agents (?character)
  )

  (:action fused_a_consensus_9a7a0ef69724a561
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_077_active)
          (tiny_stories__story_077_type_character ?m0)
          (tiny_stories__story_077_type_place ?m1)
          (tiny_stories__story_077_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_50731404ba53c84c ?m0 ?m1)
          )
        )
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?m0)
          (tiny_stories__story_078_type_place ?m1)
          (tiny_stories__story_078_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (tiny_stories__story_078_p_alive ?m0)
            (shared_p_consensus_50731404ba53c84c ?m0 ?m1)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_50731404ba53c84c ?m0 ?m1))
        (shared_p_consensus_50731404ba53c84c ?m0 ?m2)
      )
    :agents (?m0)
  )
)
