(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_018_active)
    (tiny_stories__story_018_type_character ?x - object)
    (tiny_stories__story_018_type_item ?x - object)
    (tiny_stories__story_018_type_object ?x - object)
    (tiny_stories__story_018_type_place ?x - object)
    (tiny_stories__story_018_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_open ?v0 - object)
    (tiny_stories__story_018_p_stored ?v0 - object ?v1 - object)
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_046_p_impatient ?v0 - object)
    (tiny_stories__story_046_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_046_p_on-table ?v0 - object)
    (tiny_stories__story_046_p_smells-nice ?v0 - object)
    (tiny_stories__story_046_p_playing-with-ball ?v0 - object)
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

  (:action tiny_stories__story_018_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_place ?place)
        (tiny_stories__story_018_p_at ?character ?place)
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (tiny_stories__story_018_type_item ?item)
            (tiny_stories__story_018_p_hidden ?item ?place)
          )
          (tiny_stories__story_018_p_found ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (not (tiny_stories__story_018_p_open ?item))
        )
      )
    :effect
      (tiny_stories__story_018_p_open ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_store
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (tiny_stories__story_018_type_place ?place)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (tiny_stories__story_018_p_open ?item)
          (tiny_stories__story_018_p_at ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_018_p_stored ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_try-get
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_type_object ?object)
        (and
          (tiny_stories__story_046_p_impatient ?character)
          (tiny_stories__story_046_p_on-table ?object)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_046_p_on-table ?object))
        (tiny_stories__story_046_p_has ?character ?object)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_smell-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (tiny_stories__story_046_p_smells-nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_play-with-ball
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (tiny_stories__story_046_p_playing-with-ball ?character)
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
