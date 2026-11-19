(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_023_p_happy ?v0 - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
    (writing_prompts__wp_047_p_at-peace ?v0 - object)
    (writing_prompts__wp_047_p_sharing-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_047_p_advanced-technology ?v0 - object)
    (writing_prompts__wp_047_p_facing-destruction)
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
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (not (writing_prompts__wp_069_p_supports-life ?zone)) (writing_prompts__wp_069_p_hot ?zone))) :implies (writing_prompts__wp_069_p_supports-life ?zone))
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (writing_prompts__wp_069_p_supports-life ?zone) (writing_prompts__wp_069_p_cold ?zone))) :implies (not (writing_prompts__wp_069_p_supports-life ?zone)))

  (:action tiny_stories__story_023_a_play
    :parameters (?character - object ?animal - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_type_location ?place)
        (and
          (tiny_stories__story_023_p_at ?character ?place)
          (tiny_stories__story_023_p_at ?animal ?place)
        )
      )
    :effect
      (tiny_stories__story_023_p_playing ?character ?animal)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_stop-playing
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_p_playing ?character ?animal)
      )
    :effect
      (not (tiny_stories__story_023_p_playing ?character ?animal))
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_move
    :parameters (?object - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_object ?object)
        (tiny_stories__story_023_type_location ?from)
        (tiny_stories__story_023_type_location ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_023_p_at ?object ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_023_p_at ?object ?from))
        (tiny_stories__story_023_p_at ?object ?to)
      )
    :agents (?object)
  )

  (:action tiny_stories__story_023_a_can-run
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_can-run ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_can-fly
    :parameters (?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_animal ?animal)
      )
    :effect
      (tiny_stories__story_023_p_can-fly ?animal)
    :agents (?animal)
  )

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (tiny_stories__story_034_p_has ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_has ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_047_a_unite
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_facing-destruction)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_develop-technology
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_advanced-technology ?nation1)
        (writing_prompts__wp_047_p_advanced-technology ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_avoid-destruction
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (and
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation1)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation2)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation3)
        )
      )
    :effect
      (not (writing_prompts__wp_047_p_facing-destruction))
  )

  (:action writing_prompts__wp_047_a_maintain-peace
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_at-peace ?nation1)
          (writing_prompts__wp_047_p_at-peace ?nation2)
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
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
