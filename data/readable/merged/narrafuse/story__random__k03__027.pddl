(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_045_o_mirror - object)
  (:predicates
    (tiny_stories__story_045_active)
    (tiny_stories__story_045_type_character ?x - object)
    (tiny_stories__story_045_type_object ?x - object)
    (tiny_stories__story_045_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_045_p_shares ?v0 - object ?v1 - object ?v2 - object)
    (writing_prompts__wp_006_active)
    (writing_prompts__wp_006_type_character ?x - object)
    (writing_prompts__wp_006_type_object ?x - object)
    (writing_prompts__wp_006_type_place ?x - object)
    (shared_p_consensus_abb08ff45b0ef0ba ?v0 - object ?v1 - object)
    (shared_p_consensus_485d785be974d54d ?v0 - object)
    (writing_prompts__wp_006_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_accepts-past ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_knows-self ?v0 - object)
    (writing_prompts__wp_006_p_sings ?v0 - object)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
  )

  (:action tiny_stories__story_045_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?character)
        (tiny_stories__story_045_type_object ?object)
        (not (tiny_stories__story_045_p_has ?character ?object))
      )
    :effect
      (tiny_stories__story_045_p_has ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_share
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (and
          (tiny_stories__story_045_p_has ?sharer ?object)
          (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
        )
      )
    :effect
      (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_045_a_unshare
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
      )
    :effect
      (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
    :agents (?sharer ?receiver)
  )

  (:action writing_prompts__wp_006_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (shared_p_consensus_485d785be974d54d ?character)
      )
    :effect
      (writing_prompts__wp_006_p_sings ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_485d785be974d54d ?character1)
          (shared_p_consensus_485d785be974d54d ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_accept-past
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_485d785be974d54d ?character1)
          (shared_p_consensus_485d785be974d54d ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_accepts-past ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_know-self
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (shared_p_consensus_485d785be974d54d ?character)
      )
    :effect
      (writing_prompts__wp_006_p_knows-self ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_confront
    :parameters (?confronter - object ?confronted - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?confronter)
        (writing_prompts__wp_040_type_character ?confronted)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?confronter ?confronted))
          (shared_p_consensus_485d785be974d54d ?confronter)
          (shared_p_consensus_abb08ff45b0ef0ba ?confronter ?place)
          (shared_p_consensus_485d785be974d54d ?confronted)
          (shared_p_consensus_abb08ff45b0ef0ba ?confronted ?place)
        )
      )
    :agents (?confronter)
  )

  (:action writing_prompts__wp_040_a_defeat
    :parameters (?defeater - object ?defeated - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?defeater)
        (writing_prompts__wp_040_type_character ?defeated)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?defeater ?defeated))
          (shared_p_consensus_485d785be974d54d ?defeater)
          (shared_p_consensus_abb08ff45b0ef0ba ?defeater ?place)
          (shared_p_consensus_485d785be974d54d ?defeated)
          (shared_p_consensus_abb08ff45b0ef0ba ?defeated ?place)
        )
      )
    :effect
      (not (shared_p_consensus_485d785be974d54d ?defeated))
    :agents (?defeater)
  )

  (:action writing_prompts__wp_040_a_show-mercy
    :parameters (?merciful - object ?recipient - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?merciful)
        (writing_prompts__wp_040_type_character ?recipient)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?merciful ?recipient))
          (shared_p_consensus_485d785be974d54d ?merciful)
          (shared_p_consensus_abb08ff45b0ef0ba ?merciful ?place)
          (not (shared_p_consensus_485d785be974d54d ?recipient))
          (shared_p_consensus_abb08ff45b0ef0ba ?recipient ?place)
        )
      )
    :effect
      (shared_p_consensus_485d785be974d54d ?recipient)
    :agents (?merciful)
  )

  (:action fused_a_consensus_c69024e91cfd0bc8
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?m0)
          (writing_prompts__wp_006_type_place ?m1)
          (writing_prompts__wp_006_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_485d785be974d54d ?m0)
            (shared_p_consensus_abb08ff45b0ef0ba ?m0 ?m1)
          )
        )
        (and
          (writing_prompts__wp_040_active)
          (writing_prompts__wp_040_type_character ?m0)
          (writing_prompts__wp_040_type_place ?m1)
          (writing_prompts__wp_040_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_485d785be974d54d ?m0)
            (shared_p_consensus_abb08ff45b0ef0ba ?m0 ?m1)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_abb08ff45b0ef0ba ?m0 ?m1))
        (shared_p_consensus_abb08ff45b0ef0ba ?m0 ?m2)
      )
    :agents (?m0)
  )
)
