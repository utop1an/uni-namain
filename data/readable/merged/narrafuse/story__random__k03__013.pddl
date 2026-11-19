(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_025_active)
    (tiny_stories__story_025_type_character ?x - object)
    (tiny_stories__story_025_type_object ?x - object)
    (tiny_stories__story_025_type_place ?x - object)
    (shared_p_consensus_fadc8062f34abc0a ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_stuck ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_helped ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (writing_prompts__wp_035_p_alive ?v0 - object)
    (writing_prompts__wp_035_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (writing_prompts__wp_091_p_feels-awful ?v0 - object)
    (writing_prompts__wp_091_p_thinks-about-breakup ?v0 - object)
    (writing_prompts__wp_091_p_heartbroken ?v0 - object)
    (writing_prompts__wp_091_p_forgiven ?v0 - object)
    (writing_prompts__wp_091_p_learned ?v0 - object)
    (writing_prompts__wp_091_p_moved-on ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (shared_p_consensus_fadc8062f34abc0a ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (writing_prompts__wp_035_p_alive ?character))

  (:action tiny_stories__story_025_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?from)
        (tiny_stories__story_025_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_fadc8062f34abc0a ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_fadc8062f34abc0a ?character ?from))
        (shared_p_consensus_fadc8062f34abc0a ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_get-stuck
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?place)
        (and
          (shared_p_consensus_fadc8062f34abc0a ?character ?place)
          (not (tiny_stories__story_025_p_stuck ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_025_p_stuck ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_help
    :parameters (?helper - object ?helpee - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?helper)
        (tiny_stories__story_025_type_character ?helpee)
        (tiny_stories__story_025_type_place ?place)
        (and
          (not (= ?helper ?helpee))
          (shared_p_consensus_fadc8062f34abc0a ?helper ?place)
          (tiny_stories__story_025_p_stuck ?helpee ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_025_p_stuck ?helpee ?place))
        (tiny_stories__story_025_p_helped ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_025_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character1)
        (tiny_stories__story_025_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (tiny_stories__story_025_p_friends ?character1 ?character2))
          (tiny_stories__story_025_p_helped ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_025_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_035_a_travel
    :parameters (?character - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_place ?to)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (shared_p_consensus_fadc8062f34abc0a ?character ?to))
        )
      )
    :effect
      (shared_p_consensus_fadc8062f34abc0a ?character ?to)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-smoking
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_has ?character ?item)
          (not (writing_prompts__wp_035_p_smoking ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_smoking ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-dancing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_dancing ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_dancing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-eating
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_has ?character ?item)
          (not (writing_prompts__wp_035_p_eating ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_eating ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_shrink
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_shrunk ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_shrunk ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_change-clothes
    :parameters (?character - object ?old-item - object ?new-item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?old-item)
        (writing_prompts__wp_035_type_item ?new-item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_wearing ?character ?old-item)
          (writing_prompts__wp_035_p_has ?character ?new-item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_035_p_wearing ?character ?old-item))
        (writing_prompts__wp_035_p_wearing ?character ?new-item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_forgive
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_feels-awful ?character)
          (not (writing_prompts__wp_091_p_forgiven ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_forgiven ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_learn
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_heartbroken ?character)
          (not (writing_prompts__wp_091_p_learned ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_learned ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_move-on
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_thinks-about-breakup ?character)
          (writing_prompts__wp_091_p_forgiven ?character)
          (writing_prompts__wp_091_p_learned ?character)
          (not (writing_prompts__wp_091_p_moved-on ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_moved-on ?character)
    :agents (?character)
  )
)
