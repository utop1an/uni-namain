(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_036_active)
    (tiny_stories__story_036_type_box ?x - object)
    (tiny_stories__story_036_type_character ?x - object)
    (tiny_stories__story_036_type_item ?x - object)
    (tiny_stories__story_036_type_object ?x - object)
    (tiny_stories__story_036_type_pin ?x - object)
    (tiny_stories__story_036_p_in ?v0 - object ?v1 - object)
    (tiny_stories__story_036_p_tidy ?v0 - object)
    (tiny_stories__story_036_p_on-floor ?v0 - object)
    (tiny_stories__story_036_p_scared ?v0 - object)
    (tiny_stories__story_036_p_alive ?v0 - object)
    (tiny_stories__story_036_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_036_p_fairy ?v0 - object)
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
  )

  (:action tiny_stories__story_036_a_pick-up-pin
    :parameters (?character - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?character)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_at ?character ?box)
          (tiny_stories__story_036_p_on-floor ?pin)
          (tiny_stories__story_036_p_tidy ?box)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_036_p_on-floor ?pin))
        (tiny_stories__story_036_p_in ?pin ?box)
        (not (tiny_stories__story_036_p_scared ?pin))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_036_a_open-box
    :parameters (?character - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?character)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_at ?character ?box)
          (tiny_stories__story_036_p_tidy ?box)
        )
      )
    :effect
      (forall
        (?pin - object)
        (when
          (tiny_stories__story_036_type_pin ?pin)
          (and
            (not (tiny_stories__story_036_p_in ?pin ?box))
            (tiny_stories__story_036_p_on-floor ?pin)
            (tiny_stories__story_036_p_scared ?pin)
          )
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_036_a_bring-to-life
    :parameters (?fairy - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?fairy)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_fairy ?fairy)
          (tiny_stories__story_036_p_in ?pin ?box)
        )
      )
    :effect
      (tiny_stories__story_036_p_alive ?pin)
    :agents (?fairy)
  )

  (:action tiny_stories__story_036_a_become-friends
    :parameters (?fairy - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?fairy)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_fairy ?fairy)
          (tiny_stories__story_036_p_alive ?pin)
        )
      )
    :effect
      (intends ?fairy (tiny_stories__story_036_p_alive ?pin))
    :agents (?fairy)
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
)
