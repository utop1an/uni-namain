(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_029_active)
    (tiny_stories__story_029_type_character ?x - object)
    (tiny_stories__story_029_type_item ?x - object)
    (tiny_stories__story_029_type_object ?x - object)
    (tiny_stories__story_029_type_place ?x - object)
    (shared_p_consensus_a5ea3cd8ee54291d ?v0 - object ?v1 - object)
    (shared_p_consensus_5bb000375d8dcebe ?v0 - object)
    (shared_p_consensus_45232eef0471751f ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_near ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_in-nest ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_alive ?v0 - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_45232eef0471751f ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_45232eef0471751f ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_029_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_place ?from)
        (tiny_stories__story_029_type_place ?to)
        (and
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_a5ea3cd8ee54291d ?character ?from)
          (not (shared_p_consensus_a5ea3cd8ee54291d ?character ?to))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a5ea3cd8ee54291d ?character ?from))
        (shared_p_consensus_a5ea3cd8ee54291d ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_45232eef0471751f ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_pick-up
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (tiny_stories__story_029_p_near ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_45232eef0471751f ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_help-bird
    :parameters (?character - object ?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_5bb000375d8dcebe ?bird)
          (not (tiny_stories__story_029_p_in-nest ?bird))
        )
      )
    :effect
      (tiny_stories__story_029_p_in-nest ?bird)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_bird-falls
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (shared_p_consensus_5bb000375d8dcebe ?bird)
          (tiny_stories__story_029_p_in-nest ?bird)
        )
      )
    :effect
      (not (tiny_stories__story_029_p_in-nest ?bird))
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
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_a5ea3cd8ee54291d ?character ?place)
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
          (shared_p_consensus_5bb000375d8dcebe ?character)
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
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_a5ea3cd8ee54291d ?character ?place)
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
          (shared_p_consensus_5bb000375d8dcebe ?character)
          (shared_p_consensus_a5ea3cd8ee54291d ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_a5ea3cd8ee54291d ?character ?from))
        (shared_p_consensus_a5ea3cd8ee54291d ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_45232eef0471751f ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (shared_p_consensus_45232eef0471751f ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_45232eef0471751f ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (shared_p_consensus_45232eef0471751f ?killer ?weapon)
          (writing_prompts__wp_054_p_alive ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_054_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_at ?character ?from))
        (writing_prompts__wp_054_p_at ?character ?to)
      )
    :agents (?character)
  )
)
