(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (shared_p_consensus_bcda1f9bbd7cd334 ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_c9a187cc674aeb40 ?v0 - object ?v1 - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (tiny_stories__story_070_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_clean ?v0 - object)
    (tiny_stories__story_070_p_steal-intention ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_014_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_alive ?v0 - object)
    (writing_prompts__wp_014_p_riding ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_relaxed ?v0 - object)
    (writing_prompts__wp_014_p_flying ?v0 - object)
    (writing_prompts__wp_014_p_in-vehicle ?v0 - object ?v1 - object)
  )

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_bcda1f9bbd7cd334 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bcda1f9bbd7cd334 ?character ?roomfrom))
        (shared_p_consensus_bcda1f9bbd7cd334 ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_bcda1f9bbd7cd334 ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_c9a187cc674aeb40 ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (shared_p_consensus_c9a187cc674aeb40 ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
  )

  (:action tiny_stories__story_070_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?apologizer)
        (tiny_stories__story_070_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (tiny_stories__story_070_p_friends ?apologizer ?apologized))
        )
      )
    :effect
      (tiny_stories__story_070_p_friends ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_070_a_try-steal
    :parameters (?stealer - object ?item - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?stealer)
        (tiny_stories__story_070_type_item ?item)
        (tiny_stories__story_070_type_character ?owner)
        (and
          (not (= ?stealer ?owner))
          (shared_p_consensus_c9a187cc674aeb40 ?owner ?item)
          (tiny_stories__story_070_p_steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_070_p_steal-intention ?stealer ?item))
        (not (tiny_stories__story_070_p_friends ?stealer ?owner))
        (shared_p_consensus_c9a187cc674aeb40 ?stealer ?item)
        (not (shared_p_consensus_c9a187cc674aeb40 ?owner ?item))
      )
    :agents (?stealer)
  )

  (:action tiny_stories__story_070_a_clean-item
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?cleaner)
        (tiny_stories__story_070_type_item ?item)
        (and
          (not (tiny_stories__story_070_p_clean ?item))
          (shared_p_consensus_c9a187cc674aeb40 ?cleaner ?item)
        )
      )
    :effect
      (tiny_stories__story_070_p_clean ?item)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_070_a_drop-in-puddle
    :parameters (?dropper - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?dropper)
        (tiny_stories__story_070_type_item ?item)
        (and
          (shared_p_consensus_c9a187cc674aeb40 ?dropper ?item)
          (tiny_stories__story_070_p_clean ?item)
        )
      )
    :effect
      (not (tiny_stories__story_070_p_clean ?item))
    :agents (?dropper)
  )

  (:action writing_prompts__wp_014_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_place ?from)
        (writing_prompts__wp_014_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_014_p_alive ?character)
          (shared_p_consensus_bcda1f9bbd7cd334 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_bcda1f9bbd7cd334 ?character ?from))
        (shared_p_consensus_bcda1f9bbd7cd334 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_has ?character ?vehicle)
          (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
        )
      )
    :effect
      (writing_prompts__wp_014_p_riding ?character ?vehicle)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_riding ?character ?vehicle)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_flying ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_flying ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_flying ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_flying ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_try-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_relaxed ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_relaxed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_relaxed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_relaxed ?character))
    :agents (?character)
  )
)
