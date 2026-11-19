(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (shared_p_consensus_de61cf3243c2ba84 ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (writing_prompts__wp_045_p_in-box ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_nervous ?v0 - object)
    (writing_prompts__wp_045_p_composed ?v0 - object)
    (writing_prompts__wp_045_p_noticed ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_opened ?v0 - object)
  )

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (shared_p_consensus_de61cf3243c2ba84 ?character ?place)
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
        (tiny_stories__story_039_p_has ?character ?cap)
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
        (tiny_stories__story_039_p_has ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (tiny_stories__story_039_p_has ?character ?cap))
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
          (not (tiny_stories__story_039_p_has ?character ?old-cap))
          (tiny_stories__story_039_p_has ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_039_p_found ?character ?old-cap))
        (tiny_stories__story_039_p_has ?character ?old-cap)
        (not (tiny_stories__story_039_p_has ?character ?new-cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (shared_p_consensus_de61cf3243c2ba84 ?character ?place))
      )
    :effect
      (shared_p_consensus_de61cf3243c2ba84 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_enter
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_place ?place)
        (not (writing_prompts__wp_045_p_at ?character ?place))
      )
    :effect
      (writing_prompts__wp_045_p_at ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_notice
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (writing_prompts__wp_045_p_at ?character ?place)
          (writing_prompts__wp_045_p_at ?box ?place)
        )
      )
    :effect
      (writing_prompts__wp_045_p_noticed ?character ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_open-box
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (writing_prompts__wp_045_p_at ?character ?place)
          (writing_prompts__wp_045_p_at ?box ?place)
          (writing_prompts__wp_045_p_noticed ?character ?box)
          (not (writing_prompts__wp_045_p_opened ?box))
        )
      )
    :effect
      (writing_prompts__wp_045_p_opened ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-nervous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_nervous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-composed
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_composed ?character)
    :agents (?character)
  )
)
