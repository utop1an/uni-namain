(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_084_o_rocket - object)
  (:predicates
    (tiny_stories__story_002_active)
    (tiny_stories__story_002_type_bird ?x - object)
    (tiny_stories__story_002_type_object ?x - object)
    (tiny_stories__story_002_type_place ?x - object)
    (tiny_stories__story_002_p_on-ground ?v0 - object)
    (tiny_stories__story_002_p_in-sky ?v0 - object)
    (shared_p_consensus_e8dff6cdaafe6432 ?v0 - object ?v1 - object)
    (tiny_stories__story_002_p_friends ?v0 - object ?v1 - object)
    (shared_p_consensus_9a8768dc767c1a44 ?v0 - object)
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
    (shared_p_consensus_a40c8505fdcdb619 ?v0 - object)
    (tiny_stories__story_036_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_036_p_fairy ?v0 - object)
    (tiny_stories__story_084_active)
    (tiny_stories__story_084_type_character ?x - object)
    (tiny_stories__story_084_type_item ?x - object)
    (tiny_stories__story_084_type_object ?x - object)
    (tiny_stories__story_084_type_place ?x - object)
    (tiny_stories__story_084_type_toy ?x - object)
    (shared_p_consensus_bc238ac4220a4a1d ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_played-with ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_002_a_start-flying
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_002_active)
        (tiny_stories__story_002_type_bird ?bird)
        (tiny_stories__story_002_p_on-ground ?bird)
      )
    :effect
      (and
        (not (tiny_stories__story_002_p_on-ground ?bird))
        (tiny_stories__story_002_p_in-sky ?bird)
      )
    :agents (?bird)
  )

  (:action tiny_stories__story_002_a_stop-flying
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_002_active)
        (tiny_stories__story_002_type_bird ?bird)
        (tiny_stories__story_002_p_in-sky ?bird)
      )
    :effect
      (and
        (not (tiny_stories__story_002_p_in-sky ?bird))
        (tiny_stories__story_002_p_on-ground ?bird)
      )
    :agents (?bird)
  )

  (:action tiny_stories__story_002_a_move
    :parameters (?bird - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_002_active)
        (tiny_stories__story_002_type_bird ?bird)
        (tiny_stories__story_002_type_place ?from)
        (tiny_stories__story_002_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_e8dff6cdaafe6432 ?bird ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e8dff6cdaafe6432 ?bird ?from))
        (shared_p_consensus_e8dff6cdaafe6432 ?bird ?to)
      )
    :agents (?bird)
  )

  (:action tiny_stories__story_002_a_make-friends
    :parameters (?bird1 - object ?bird2 - object)
    :precondition
      (and
        (tiny_stories__story_002_active)
        (tiny_stories__story_002_type_bird ?bird1)
        (tiny_stories__story_002_type_bird ?bird2)
        (and
          (not (= ?bird1 ?bird2))
          (not (tiny_stories__story_002_p_friends ?bird1 ?bird2))
        )
      )
    :effect
      (tiny_stories__story_002_p_friends ?bird1 ?bird2)
    :agents (?bird1 ?bird2)
  )

  (:action tiny_stories__story_002_a_become-happy
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_002_active)
        (tiny_stories__story_002_type_bird ?bird)
        (not (shared_p_consensus_9a8768dc767c1a44 ?bird))
      )
    :effect
      (shared_p_consensus_9a8768dc767c1a44 ?bird)
    :agents (?bird)
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
      (shared_p_consensus_a40c8505fdcdb619 ?pin)
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
          (shared_p_consensus_a40c8505fdcdb619 ?pin)
        )
      )
    :effect
      (intends ?fairy (shared_p_consensus_a40c8505fdcdb619 ?pin))
    :agents (?fairy)
  )

  (:action tiny_stories__story_084_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (shared_p_consensus_e8dff6cdaafe6432 ?character ?place)
          (not (tiny_stories__story_084_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_084_p_found ?character ?item)
        (shared_p_consensus_bc238ac4220a4a1d ?character ?item)
        (shared_p_consensus_9a8768dc767c1a44 ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_show
    :parameters (?shower - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?shower)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_character ?receiver)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?shower ?receiver))
          (shared_p_consensus_e8dff6cdaafe6432 ?shower ?place)
          (shared_p_consensus_bc238ac4220a4a1d ?shower ?item)
          (shared_p_consensus_e8dff6cdaafe6432 ?receiver ?place)
        )
      )
    :effect
      (shared_p_consensus_9a8768dc767c1a44 ?receiver)
    :agents (?shower ?receiver)
  )

  (:action tiny_stories__story_084_a_play
    :parameters (?character1 - object ?character2 - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character1)
        (tiny_stories__story_084_type_character ?character2)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_e8dff6cdaafe6432 ?character1 ?place)
          (shared_p_consensus_bc238ac4220a4a1d ?character1 ?item)
          (shared_p_consensus_e8dff6cdaafe6432 ?character2 ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_played-with ?character1 ?item)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_084_a_fly-high
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_p_played-with ?character tiny_stories__story_084_o_rocket)
      )
    :effect
      (shared_p_consensus_9a8768dc767c1a44 ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_a40c8505fdcdb619 ?character)
          (shared_p_consensus_bc238ac4220a4a1d ?character ?item)
          (not (writing_prompts__wp_060_p_clean ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_clean ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?door)
        (and
          (shared_p_consensus_a40c8505fdcdb619 ?character)
          (not (writing_prompts__wp_060_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_060_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_adjust-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_a40c8505fdcdb619 ?character)
          (shared_p_consensus_bc238ac4220a4a1d ?character ?item)
          (not (writing_prompts__wp_060_p_fits ?item ?character))
        )
      )
    :effect
      (writing_prompts__wp_060_p_fits ?item ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_wear-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_a40c8505fdcdb619 ?character)
          (shared_p_consensus_bc238ac4220a4a1d ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )
)
