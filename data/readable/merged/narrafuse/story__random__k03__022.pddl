(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (tiny_stories__story_039_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_9ef78c4bac744d11 ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (tiny_stories__story_063_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_active)
    (writing_prompts__wp_056_type_character ?x - object)
    (writing_prompts__wp_056_type_item ?x - object)
    (writing_prompts__wp_056_type_object ?x - object)
    (writing_prompts__wp_056_type_side ?x - object)
    (writing_prompts__wp_056_type_weapon ?x - object)
    (writing_prompts__wp_056_p_alive ?v0 - object)
    (writing_prompts__wp_056_p_armed ?v0 - object)
    (writing_prompts__wp_056_p_fights-for ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_in-formation ?v0 - object)
    (writing_prompts__wp_056_p_eyes-glow-red ?v0 - object)
    (writing_prompts__wp_056_p_damaged ?v0 - object)
    (writing_prompts__wp_056_p_aware ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (shared_p_consensus_9ef78c4bac744d11 ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (shared_p_consensus_9ef78c4bac744d11 ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (tiny_stories__story_039_p_at ?character ?place)
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
        (shared_p_consensus_9ef78c4bac744d11 ?character ?cap)
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
        (shared_p_consensus_9ef78c4bac744d11 ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (shared_p_consensus_9ef78c4bac744d11 ?character ?cap))
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
          (not (shared_p_consensus_9ef78c4bac744d11 ?character ?old-cap))
          (shared_p_consensus_9ef78c4bac744d11 ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_039_p_found ?character ?old-cap))
        (shared_p_consensus_9ef78c4bac744d11 ?character ?old-cap)
        (not (shared_p_consensus_9ef78c4bac744d11 ?character ?new-cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (tiny_stories__story_063_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (tiny_stories__story_063_p_helping ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (tiny_stories__story_063_p_helping ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
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
          (shared_p_consensus_9ef78c4bac744d11 ?shooter ?weapon)
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
          (shared_p_consensus_9ef78c4bac744d11 ?character ?weapon)
          (writing_prompts__wp_056_p_aware ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_056_p_alive ?character))
    :agents (?character)
  )
)
