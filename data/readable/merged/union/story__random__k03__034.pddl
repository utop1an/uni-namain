(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_065_active)
    (tiny_stories__story_065_type_character ?x - object)
    (tiny_stories__story_065_type_object ?x - object)
    (tiny_stories__story_065_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_hurt ?v0 - object)
    (tiny_stories__story_065_p_touching ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_scared ?v0 - object)
    (tiny_stories__story_065_p_hugging ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_014_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_alive ?v0 - object)
    (writing_prompts__wp_014_p_riding ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_relaxed ?v0 - object)
    (writing_prompts__wp_014_p_flying ?v0 - object)
    (writing_prompts__wp_014_p_in-vehicle ?v0 - object ?v1 - object)
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

  (:action tiny_stories__story_065_a_move
    :parameters (?character - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_at ?character ?location))
          (not (tiny_stories__story_065_p_scared ?character))
        )
      )
    :effect
      (tiny_stories__story_065_p_at ?character ?location)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_touch
    :parameters (?character - object ?object - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_touching ?character ?object))
          (tiny_stories__story_065_p_at ?character ?location)
        )
      )
    :effect
      (tiny_stories__story_065_p_touching ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-touching
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_p_touching ?character ?object)
      )
    :effect
      (not (tiny_stories__story_065_p_touching ?character ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-hurt
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_hurt ?character))
      )
    :effect
      (tiny_stories__story_065_p_hurt ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_scared ?character))
      )
    :effect
      (tiny_stories__story_065_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_065_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (and
          (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
          (not (tiny_stories__story_065_p_hugging ?character2 ?character1))
        )
      )
    :effect
      (tiny_stories__story_065_p_hugging ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_065_a_stop-hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (tiny_stories__story_065_p_hugging ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_014_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_place ?from)
        (writing_prompts__wp_014_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_014_p_at ?character ?from))
        (writing_prompts__wp_014_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_has ?character ?vehicle)
          (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
        )
      )
    :effect
      (writing_prompts__wp_014_p_riding ?character ?vehicle)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_riding ?character ?vehicle)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_flying ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_flying ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_flying ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_flying ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_try-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_relaxed ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_relaxed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_relaxed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_relaxed ?character))
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
