(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_019_o_colors - object)
  (:predicates
    (tiny_stories__story_017_active)
    (tiny_stories__story_017_type_character ?x - object)
    (tiny_stories__story_017_type_object ?x - object)
    (tiny_stories__story_017_p_watches-tv ?v0 - object)
    (tiny_stories__story_017_p_happy ?v0 - object)
    (tiny_stories__story_017_p_rude ?v0 - object)
    (tiny_stories__story_017_p_nice ?v0 - object)
    (tiny_stories__story_017_p_wants-to-watch-tv ?v0 - object)
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (tiny_stories__story_019_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_made-handprint ?v0 - object)
    (tiny_stories__story_019_p_celebrated ?v0 - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
    (writing_prompts__wp_056_active)
    (writing_prompts__wp_056_type_character ?x - object)
    (writing_prompts__wp_056_type_item ?x - object)
    (writing_prompts__wp_056_type_object ?x - object)
    (writing_prompts__wp_056_type_side ?x - object)
    (writing_prompts__wp_056_type_weapon ?x - object)
    (writing_prompts__wp_056_p_alive ?v0 - object)
    (writing_prompts__wp_056_p_armed ?v0 - object)
    (writing_prompts__wp_056_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_fights-for ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_in-formation ?v0 - object)
    (writing_prompts__wp_056_p_eyes-glow-red ?v0 - object)
    (writing_prompts__wp_056_p_damaged ?v0 - object)
    (writing_prompts__wp_056_p_aware ?v0 - object)
    (writing_prompts__wp_074_active)
    (writing_prompts__wp_074_type_character ?x - object)
    (writing_prompts__wp_074_type_object ?x - object)
    (writing_prompts__wp_074_p_influenced ?v0 - object)
    (writing_prompts__wp_074_p_isolated ?v0 - object)
    (writing_prompts__wp_074_p_hates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_manipulates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_despises ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_apologized ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (writing_prompts__wp_056_p_has ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (writing_prompts__wp_056_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

  (:action tiny_stories__story_017_a_start-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_wants-to-watch-tv ?character)
      )
    :effect
      (tiny_stories__story_017_p_watches-tv ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_stop-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_watches-tv ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_watches-tv ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_rude ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_rude ?character))
        (tiny_stories__story_017_p_nice ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-rude
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_nice ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_nice ?character))
        (tiny_stories__story_017_p_rude ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
      )
    :effect
      (tiny_stories__story_017_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-unhappy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_happy ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_happy ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_019_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?character)
        (tiny_stories__story_019_type_object ?object)
        (not (tiny_stories__story_019_p_found ?character ?object))
      )
    :effect
      (tiny_stories__story_019_p_found ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_019_a_make-handprint
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?character)
        (tiny_stories__story_019_p_found ?character tiny_stories__story_019_o_colors)
      )
    :effect
      (tiny_stories__story_019_p_made-handprint ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_019_a_show-handprint
    :parameters (?shower - object ?viewer - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?shower)
        (tiny_stories__story_019_type_character ?viewer)
        (and
          (tiny_stories__story_019_p_made-handprint ?shower)
          (not (= ?shower ?viewer))
        )
      )
    :effect
      (tiny_stories__story_019_p_celebrated ?viewer)
    :agents (?shower ?viewer)
  )

  (:action tiny_stories__story_019_a_celebrate
    :parameters (?celebrator - object ?celebratee - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?celebrator)
        (tiny_stories__story_019_type_character ?celebratee)
        (and
          (tiny_stories__story_019_p_celebrated ?celebrator)
          (not (= ?celebrator ?celebratee))
        )
      )
    :effect
      (tiny_stories__story_019_p_celebrated ?celebratee)
    :agents (?celebrator ?celebratee)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (tiny_stories__story_095_p_at ?character ?place))
      )
    :effect
      (tiny_stories__story_095_p_at ?character ?place)
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

  (:action writing_prompts__wp_056_a_fire
    :parameters (?shooter - object ?target - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?shooter)
        (writing_prompts__wp_056_type_character ?target)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (not (= ?shooter ?target))
          (writing_prompts__wp_056_p_alive ?shooter)
          (writing_prompts__wp_056_p_armed ?shooter)
          (writing_prompts__wp_056_p_has ?shooter ?weapon)
          (writing_prompts__wp_056_p_alive ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_056_p_alive ?target))
        (intends ?shooter (not (writing_prompts__wp_056_p_alive ?target)))
      )
    :agents (?shooter)
  )

  (:action writing_prompts__wp_056_a_damage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_damaged ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_damaged ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_aware ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_aware ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_suicide
    :parameters (?character - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (writing_prompts__wp_056_p_armed ?character)
          (writing_prompts__wp_056_p_has ?character ?weapon)
          (writing_prompts__wp_056_p_aware ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_056_p_alive ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_074_a_influence
    :parameters (?influencer - object ?influenced - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?influencer)
        (writing_prompts__wp_074_type_character ?influenced)
        (and
          (not (= ?influencer ?influenced))
          (not (writing_prompts__wp_074_p_influenced ?influenced))
        )
      )
    :effect
      (writing_prompts__wp_074_p_influenced ?influenced)
    :agents (?influencer)
  )

  (:action writing_prompts__wp_074_a_isolate
    :parameters (?isolator - object ?isolated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?isolator)
        (writing_prompts__wp_074_type_character ?isolated)
        (and
          (not (= ?isolator ?isolated))
          (not (writing_prompts__wp_074_p_isolated ?isolated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_isolated ?isolated)
    :agents (?isolator)
  )

  (:action writing_prompts__wp_074_a_manipulate
    :parameters (?manipulator - object ?manipulated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?manipulator)
        (writing_prompts__wp_074_type_character ?manipulated)
        (and
          (not (= ?manipulator ?manipulated))
          (not (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated)
    :agents (?manipulator)
  )

  (:action writing_prompts__wp_074_a_hate
    :parameters (?hater - object ?hated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?hater)
        (writing_prompts__wp_074_type_character ?hated)
        (and
          (not (= ?hater ?hated))
          (not (writing_prompts__wp_074_p_hates ?hater ?hated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_hates ?hater ?hated)
    :agents (?hater)
  )

  (:action writing_prompts__wp_074_a_despise
    :parameters (?despiser - object ?despised - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?despiser)
        (writing_prompts__wp_074_type_character ?despised)
        (and
          (not (= ?despiser ?despised))
          (not (writing_prompts__wp_074_p_despises ?despiser ?despised))
        )
      )
    :effect
      (writing_prompts__wp_074_p_despises ?despiser ?despised)
    :agents (?despiser)
  )

  (:action writing_prompts__wp_074_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?apologizer)
        (writing_prompts__wp_074_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (writing_prompts__wp_074_p_apologized ?apologizer ?apologized))
        )
      )
    :effect
      (writing_prompts__wp_074_p_apologized ?apologizer ?apologized)
    :agents (?apologizer)
  )
)
