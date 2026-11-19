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
    (tiny_stories__story_041_active)
    (tiny_stories__story_041_type_character ?x - object)
    (tiny_stories__story_041_type_object ?x - object)
    (tiny_stories__story_041_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_041_p_kind ?v0 - object)
    (tiny_stories__story_041_p_knows-wisdom ?v0 - object)
    (tiny_stories__story_041_p_lost ?v0 - object)
    (tiny_stories__story_041_p_found ?v0 - object)
    (writing_prompts__wp_022_active)
    (writing_prompts__wp_022_type_character ?x - object)
    (writing_prompts__wp_022_type_object ?x - object)
    (writing_prompts__wp_022_p_pranked ?v0 - object ?v1 - object)
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
          (not (tiny_stories__story_041_p_friends ?c1 ?c2))
          (not (= ?c1 ?c2))
        )
      )
    :effect
      (tiny_stories__story_041_p_friends ?c1 ?c2)
    :agents (?c1 ?c2)
  )

  (:action writing_prompts__wp_022_a_prank
    :parameters (?pranker - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_022_active)
        (writing_prompts__wp_022_type_character ?pranker)
        (writing_prompts__wp_022_type_character ?target)
      )
    :effect
      (writing_prompts__wp_022_p_pranked ?pranker ?target)
    :agents (?pranker)
  )
)
