(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (tiny_stories__story_027_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_found ?v0 - object)
    (shared_p_consensus_741bc2d82fdf4274 ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_searched ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_alive ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_027_a_hide
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (shared_p_consensus_741bc2d82fdf4274 ?character ?place)
      )
    :effect
      (tiny_stories__story_027_p_hidden ?toy ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?place)
        (and
          (shared_p_consensus_741bc2d82fdf4274 ?character ?place)
          (not (tiny_stories__story_027_p_searched ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_027_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_find
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (and
          (shared_p_consensus_741bc2d82fdf4274 ?character ?place)
          (tiny_stories__story_027_p_hidden ?toy ?place)
          (tiny_stories__story_027_p_searched ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_027_p_found ?toy)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?from)
        (tiny_stories__story_027_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_741bc2d82fdf4274 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_741bc2d82fdf4274 ?character ?from))
        (shared_p_consensus_741bc2d82fdf4274 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_741bc2d82fdf4274 ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_741bc2d82fdf4274 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (shared_p_consensus_741bc2d82fdf4274 ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_741bc2d82fdf4274 ?character ?from))
        (shared_p_consensus_741bc2d82fdf4274 ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )
)
