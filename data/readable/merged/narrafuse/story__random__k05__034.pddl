(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (tiny_stories__story_039_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_92cc88a28fb8e062 ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (tiny_stories__story_098_p_sailor ?v0 - object)
    (tiny_stories__story_098_p_nice ?v0 - object)
    (tiny_stories__story_098_p_sailing ?v0 - object)
    (tiny_stories__story_098_p_together ?v0 - object ?v1 - object)
    (tiny_stories__story_098_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (writing_prompts__wp_044_p_alive ?v0 - object)
    (writing_prompts__wp_044_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_p_imprisoned ?v0 - object)
    (writing_prompts__wp_044_p_served-sentence ?v0 - object)
    (writing_prompts__wp_044_p_has-serum ?v0 - object)
    (writing_prompts__wp_044_p_religious ?v0 - object)
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

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (tiny_stories__story_039_p_at ?character ?place)
          (tiny_stories__story_039_p_lost ?character ?cap)
        )
      )
    :effect
      (tiny_stories__story_039_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_find
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (and
          (tiny_stories__story_039_p_lost ?character ?cap)
          (forall
            (?place - object)
            (or
              (not (tiny_stories__story_039_type_place ?place))
              (tiny_stories__story_039_p_searched ?character ?place)
            )
          )
        )
      )
    :effect
      (and
        (tiny_stories__story_039_p_found ?character ?cap)
        (not (tiny_stories__story_039_p_lost ?character ?cap))
        (shared_p_consensus_92cc88a28fb8e062 ?character ?cap)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_lose
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (shared_p_consensus_92cc88a28fb8e062 ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (shared_p_consensus_92cc88a28fb8e062 ?character ?cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_replace
    :parameters (?character - object ?old-cap - object ?new-cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?old-cap)
        (tiny_stories__story_039_type_cap ?new-cap)
        (and
          (tiny_stories__story_039_p_found ?character ?old-cap)
          (not (shared_p_consensus_92cc88a28fb8e062 ?character ?old-cap))
          (shared_p_consensus_92cc88a28fb8e062 ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_039_p_found ?character ?old-cap))
        (shared_p_consensus_92cc88a28fb8e062 ?character ?old-cap)
        (not (shared_p_consensus_92cc88a28fb8e062 ?character ?new-cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_92cc88a28fb8e062 ?character ?dress)
          (not (tiny_stories__story_075_p_wearing ?character ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_wearing ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_wearing ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (tiny_stories__story_075_p_wearing ?character ?old-dress)
          (not (shared_p_consensus_92cc88a28fb8e062 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (shared_p_consensus_92cc88a28fb8e062 ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_learn-to-sail
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_sailor ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?helper)
        (tiny_stories__story_098_type_character ?helpee)
        (not (= ?helper ?helpee))
      )
    :effect
      (tiny_stories__story_098_p_helping ?helper ?helpee)
    :agents (?helper ?helpee)
  )

  (:action tiny_stories__story_098_a_sail-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character1)
        (tiny_stories__story_098_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_098_p_sailor ?character1)
          (tiny_stories__story_098_p_sailor ?character2)
        )
      )
    :effect
      (tiny_stories__story_098_p_together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_098_a_thank
    :parameters (?thanker - object ?thankee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?thanker)
        (tiny_stories__story_098_type_character ?thankee)
        (not (= ?thanker ?thankee))
      )
    :effect
      (tiny_stories__story_098_p_nice ?thanker)
    :agents (?thanker)
  )

  (:action writing_prompts__wp_044_a_take-serum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (not (writing_prompts__wp_044_p_has-serum ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_has-serum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_serve-sentence
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (not (writing_prompts__wp_044_p_served-sentence ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_served-sentence ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_release
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (writing_prompts__wp_044_p_served-sentence ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_imprisoned ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_convert
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (not (writing_prompts__wp_044_p_religious ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_religious ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_abandon-religion
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_religious ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_religious ?character))
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
