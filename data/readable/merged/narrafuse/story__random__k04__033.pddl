(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (shared_p_consensus_2c69aa4dfb7ee123 ?v0 - object ?v1 - object)
    (tiny_stories__story_038_p_hiding ?v0 - object)
    (tiny_stories__story_038_p_seeking ?v0 - object)
    (tiny_stories__story_038_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_075_p_wearing ?v0 - object ?v1 - object)
    (shared_p_consensus_af8a46291c926b37 ?v0 - object ?v1 - object)
    (tiny_stories__story_075_p_damaged ?v0 - object)
    (tiny_stories__story_075_p_happy ?v0 - object)
    (writing_prompts__wp_027_active)
    (writing_prompts__wp_027_type_character ?x - object)
    (writing_prompts__wp_027_type_object ?x - object)
    (writing_prompts__wp_027_type_place ?x - object)
    (writing_prompts__wp_027_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_027_p_clothed ?v0 - object)
    (shared_p_consensus_4b4229386dd07456 ?v0 - object)
    (writing_prompts__wp_027_p_stuck ?v0 - object)
    (writing_prompts__wp_027_p_falling ?v0 - object)
    (writing_prompts__wp_027_p_aware-glitch ?v0 - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (writing_prompts__wp_042_p_drunk ?v0 - object)
    (writing_prompts__wp_042_p_night-show ?v0 - object)
    (writing_prompts__wp_042_p_vomit-stain ?v0 - object)
  )

  (:action tiny_stories__story_038_a_start-hiding
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (shared_p_consensus_2c69aa4dfb7ee123 ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_hiding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_start-seeking
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (shared_p_consensus_2c69aa4dfb7ee123 ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_seeking ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_find
    :parameters (?seeker - object ?hider - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?seeker)
        (tiny_stories__story_038_type_character ?hider)
        (tiny_stories__story_038_type_place ?place)
        (and
          (tiny_stories__story_038_p_seeking ?seeker)
          (tiny_stories__story_038_p_hiding ?hider)
          (shared_p_consensus_2c69aa4dfb7ee123 ?seeker ?place)
          (shared_p_consensus_2c69aa4dfb7ee123 ?hider ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_038_p_found ?seeker ?hider)
        (not (tiny_stories__story_038_p_hiding ?hider))
      )
    :agents (?seeker)
  )

  (:action tiny_stories__story_038_a_stop-seeking
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_p_seeking ?character)
      )
    :effect
      (not (tiny_stories__story_038_p_seeking ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_put-on-dress
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (shared_p_consensus_af8a46291c926b37 ?character ?dress)
          (not (tiny_stories__story_075_p_wearing ?character ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_wearing ?character ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_slip
    :parameters (?character - object ?dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?dress)
        (and
          (tiny_stories__story_075_p_wearing ?character ?dress)
          (not (tiny_stories__story_075_p_damaged ?dress))
        )
      )
    :effect
      (tiny_stories__story_075_p_damaged ?dress)
    :agents (?character)
  )

  (:action tiny_stories__story_075_a_comfort
    :parameters (?parent - object ?child - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?parent)
        (tiny_stories__story_075_type_character ?child)
        (and
          (not (tiny_stories__story_075_p_happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (tiny_stories__story_075_p_happy ?child)
    :agents (?parent)
  )

  (:action tiny_stories__story_075_a_get-new-dress
    :parameters (?character - object ?old-dress - object ?new-dress - object)
    :precondition
      (and
        (tiny_stories__story_075_active)
        (tiny_stories__story_075_type_character ?character)
        (tiny_stories__story_075_type_dress ?old-dress)
        (tiny_stories__story_075_type_dress ?new-dress)
        (and
          (tiny_stories__story_075_p_damaged ?old-dress)
          (tiny_stories__story_075_p_wearing ?character ?old-dress)
          (not (shared_p_consensus_af8a46291c926b37 ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_075_p_wearing ?character ?old-dress))
        (shared_p_consensus_af8a46291c926b37 ?character ?new-dress)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (shared_p_consensus_4b4229386dd07456 ?character)
      )
    :effect
      (writing_prompts__wp_027_p_aware-glitch ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_help-stuck
    :parameters (?helper - object ?stuck-character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?helper)
        (writing_prompts__wp_027_type_character ?stuck-character)
        (and
          (shared_p_consensus_4b4229386dd07456 ?helper)
          (writing_prompts__wp_027_p_stuck ?stuck-character)
          (writing_prompts__wp_027_p_at ?helper ?stuck-character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_stuck ?stuck-character))
        (writing_prompts__wp_027_p_aware-glitch ?helper)
      )
    :agents (?helper)
  )

  (:action writing_prompts__wp_027_a_fall
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (writing_prompts__wp_027_type_place ?place)
        (and
          (shared_p_consensus_4b4229386dd07456 ?character)
          (writing_prompts__wp_027_p_falling ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_027_p_falling ?character))
        (writing_prompts__wp_027_p_at ?character ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_027_a_lose-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_027_active)
        (writing_prompts__wp_027_type_character ?character)
        (and
          (shared_p_consensus_4b4229386dd07456 ?character)
          (writing_prompts__wp_027_p_clothed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_027_p_clothed ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_drink
    :parameters (?character - object ?drink - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_drink ?drink)
        (and
          (shared_p_consensus_4b4229386dd07456 ?character)
          (shared_p_consensus_af8a46291c926b37 ?character ?drink)
        )
      )
    :effect
      (and
        (writing_prompts__wp_042_p_drunk ?character)
        (not (shared_p_consensus_af8a46291c926b37 ?character ?drink))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (shared_p_consensus_4b4229386dd07456 ?character)
          (not (shared_p_consensus_2c69aa4dfb7ee123 ?character ?place))
        )
      )
    :effect
      (shared_p_consensus_2c69aa4dfb7ee123 ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_vomit
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (shared_p_consensus_4b4229386dd07456 ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (shared_p_consensus_2c69aa4dfb7ee123 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_042_p_vomit-stain ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_sober-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_p_drunk ?character)
      )
    :effect
      (not (writing_prompts__wp_042_p_drunk ?character))
    :agents (?character)
  )
)
