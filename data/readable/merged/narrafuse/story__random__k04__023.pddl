(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_025_active)
    (tiny_stories__story_025_type_character ?x - object)
    (tiny_stories__story_025_type_object ?x - object)
    (tiny_stories__story_025_type_place ?x - object)
    (shared_p_consensus_1569a5b872945f1e ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_stuck ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_helped ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_027_active)
    (writing_prompts__wp_027_type_character ?x - object)
    (writing_prompts__wp_027_type_object ?x - object)
    (writing_prompts__wp_027_type_place ?x - object)
    (writing_prompts__wp_027_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_027_p_clothed ?v0 - object)
    (writing_prompts__wp_027_p_alive ?v0 - object)
    (writing_prompts__wp_027_p_stuck ?v0 - object)
    (writing_prompts__wp_027_p_falling ?v0 - object)
    (writing_prompts__wp_027_p_aware-glitch ?v0 - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_awake ?v0 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
    (writing_prompts__wp_069_active)
    (writing_prompts__wp_069_type_object ?x - object)
    (writing_prompts__wp_069_type_zone ?x - object)
    (writing_prompts__wp_069_p_habitable ?v0 - object)
    (writing_prompts__wp_069_p_supports-life ?v0 - object)
    (writing_prompts__wp_069_p_hot ?v0 - object)
    (writing_prompts__wp_069_p_cold ?v0 - object)
    (writing_prompts__wp_069_p_gaseous-state ?v0 - object)
    (writing_prompts__wp_069_p_liquid-state ?v0 - object)
    (writing_prompts__wp_069_p_solar-wind ?v0 - object)
  )
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (not (writing_prompts__wp_069_p_supports-life ?zone)) (writing_prompts__wp_069_p_hot ?zone))) :implies (writing_prompts__wp_069_p_supports-life ?zone))
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (writing_prompts__wp_069_p_supports-life ?zone) (writing_prompts__wp_069_p_cold ?zone))) :implies (not (writing_prompts__wp_069_p_supports-life ?zone)))

  (:action tiny_stories__story_025_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?from)
        (tiny_stories__story_025_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_1569a5b872945f1e ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1569a5b872945f1e ?character ?from))
        (shared_p_consensus_1569a5b872945f1e ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_get-stuck
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?place)
        (and
          (shared_p_consensus_1569a5b872945f1e ?character ?place)
          (not (tiny_stories__story_025_p_stuck ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_025_p_stuck ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_help
    :parameters (?helper - object ?helpee - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?helper)
        (tiny_stories__story_025_type_character ?helpee)
        (tiny_stories__story_025_type_place ?place)
        (and
          (not (= ?helper ?helpee))
          (shared_p_consensus_1569a5b872945f1e ?helper ?place)
          (tiny_stories__story_025_p_stuck ?helpee ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_025_p_stuck ?helpee ?place))
        (tiny_stories__story_025_p_helped ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_025_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character1)
        (tiny_stories__story_025_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (tiny_stories__story_025_p_friends ?character1 ?character2))
          (tiny_stories__story_025_p_helped ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_025_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_027_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (writing_prompts__wp_027_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_027_p_aware-glitch ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_help-stuck
    :parameters (?helper - object ?stuck-character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?helper)
        (writing_prompts__wp_027_type_character ?stuck-character)
        (and
          (writing_prompts__wp_027_p_alive ?helper)
          (writing_prompts__wp_027_p_stuck ?stuck-character)
          (writing_prompts__wp_027_p_at ?helper ?stuck-character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_stuck ?stuck-character))
        (writing_prompts__wp_027_p_aware-glitch ?helper)
      )
    :agents (?helper)
  )

  (:action writing_prompts__wp_027_a_fall
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (writing_prompts__wp_027_type_place ?place)
        (and
          (writing_prompts__wp_027_p_alive ?character)
          (writing_prompts__wp_027_p_falling ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_falling ?character))
        (writing_prompts__wp_027_p_at ?character ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_lose-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (and
          (writing_prompts__wp_027_p_alive ?character)
          (writing_prompts__wp_027_p_clothed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_027_p_clothed ?character))
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
          (shared_p_consensus_1569a5b872945f1e ?gang ?place)
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

  (:action writing_prompts__wp_069_a_heat-zone
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_hot ?zone))
          (writing_prompts__wp_069_p_habitable ?zone)
        )
      )
    :effect
      (writing_prompts__wp_069_p_hot ?zone)
  )

  (:action writing_prompts__wp_069_a_cool-zone
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_cold ?zone))
          (not (writing_prompts__wp_069_p_habitable ?zone))
        )
      )
    :effect
      (writing_prompts__wp_069_p_cold ?zone)
  )

  (:action writing_prompts__wp_069_a_gaseous-transition
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_gaseous-state ?zone))
          (writing_prompts__wp_069_p_liquid-state ?zone)
        )
      )
    :effect
      (and
        (writing_prompts__wp_069_p_gaseous-state ?zone)
        (not (writing_prompts__wp_069_p_liquid-state ?zone))
      )
  )

  (:action writing_prompts__wp_069_a_liquid-transition
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_liquid-state ?zone))
          (writing_prompts__wp_069_p_gaseous-state ?zone)
        )
      )
    :effect
      (and
        (writing_prompts__wp_069_p_liquid-state ?zone)
        (not (writing_prompts__wp_069_p_gaseous-state ?zone))
      )
  )

  (:action writing_prompts__wp_069_a_solar-wind-effect
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_solar-wind ?zone))
          (writing_prompts__wp_069_p_gaseous-state ?zone)
        )
      )
    :effect
      (writing_prompts__wp_069_p_solar-wind ?zone)
  )
)
