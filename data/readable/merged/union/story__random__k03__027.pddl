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
    (writing_prompts__wp_006_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_alive ?v0 - object)
    (writing_prompts__wp_006_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_accepts-past ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_knows-self ?v0 - object)
    (writing_prompts__wp_006_p_sings ?v0 - object)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_alive ?v0 - object)
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

  (:action writing_prompts__wp_006_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_type_place ?from)
        (writing_prompts__wp_006_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_006_p_alive ?character)
          (writing_prompts__wp_006_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_006_p_at ?character ?from))
        (writing_prompts__wp_006_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_p_alive ?character)
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
          (writing_prompts__wp_006_p_alive ?character1)
          (writing_prompts__wp_006_p_alive ?character2)
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
          (writing_prompts__wp_006_p_alive ?character1)
          (writing_prompts__wp_006_p_alive ?character2)
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
        (writing_prompts__wp_006_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_006_p_knows-self ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?character)
        (writing_prompts__wp_040_type_place ?from)
        (writing_prompts__wp_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_040_p_alive ?character)
          (writing_prompts__wp_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_040_p_at ?character ?from))
        (writing_prompts__wp_040_p_at ?character ?to)
      )
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
          (writing_prompts__wp_040_p_alive ?confronter)
          (writing_prompts__wp_040_p_at ?confronter ?place)
          (writing_prompts__wp_040_p_alive ?confronted)
          (writing_prompts__wp_040_p_at ?confronted ?place)
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
          (writing_prompts__wp_040_p_alive ?defeater)
          (writing_prompts__wp_040_p_at ?defeater ?place)
          (writing_prompts__wp_040_p_alive ?defeated)
          (writing_prompts__wp_040_p_at ?defeated ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_040_p_alive ?defeated))
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
          (writing_prompts__wp_040_p_alive ?merciful)
          (writing_prompts__wp_040_p_at ?merciful ?place)
          (not (writing_prompts__wp_040_p_alive ?recipient))
          (writing_prompts__wp_040_p_at ?recipient ?place)
        )
      )
    :effect
      (writing_prompts__wp_040_p_alive ?recipient)
    :agents (?merciful)
  )
)
