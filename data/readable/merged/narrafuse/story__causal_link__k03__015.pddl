(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (shared_p_consensus_2efb2ed4ff373188 ?v0 - object ?v1 - object)
    (shared_p_consensus_2f7dcd64921abca1 ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_e8b8896763c573ac ?v0 - object)
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
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_2f7dcd64921abca1 ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_2f7dcd64921abca1 ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_093_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_place ?place)
        (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
      )
    :effect
      (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_select-mop
    :parameters (?character - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
          (shared_p_consensus_2f7dcd64921abca1 ?character ?mop)
        )
      )
    :effect
      (tiny_stories__story_093_p_selected ?mop)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_receive-mop
    :parameters (?character - object ?dog - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_character ?dog)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
          (shared_p_consensus_2efb2ed4ff373188 ?dog ?place)
          (shared_p_consensus_2f7dcd64921abca1 ?dog ?mop)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7dcd64921abca1 ?dog ?mop))
        (shared_p_consensus_2f7dcd64921abca1 ?character ?mop)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?place)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_2efb2ed4ff373188 ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2efb2ed4ff373188 ?character ?from))
        (shared_p_consensus_2efb2ed4ff373188 ?character ?to)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_2f7dcd64921abca1 ?character ?item)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (shared_p_consensus_2f7dcd64921abca1 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2f7dcd64921abca1 ?character ?item))
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
          (shared_p_consensus_e8b8896763c573ac ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (shared_p_consensus_2f7dcd64921abca1 ?killer ?weapon)
          (shared_p_consensus_e8b8896763c573ac ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_e8b8896763c573ac ?victim))
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
          (shared_p_consensus_e8b8896763c573ac ?character)
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
