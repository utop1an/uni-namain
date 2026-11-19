(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_067_o_factory - object)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_at ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (shared_p_consensus_b87a7c348ca3ad53 ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (tiny_stories__story_067_p_worker ?v0 - object)
    (shared_p_consensus_cdd7fb180ef2c9a2 ?v0 - object)
    (tiny_stories__story_067_p_makes-toys ?v0 - object)
    (tiny_stories__story_067_p_nervous ?v0 - object)
    (tiny_stories__story_067_p_friends-with ?v0 - object ?v1 - object)
    (tiny_stories__story_067_p_happy ?v0 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
  )

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (human_62959785b3ec220a_p_at ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_at ?character ?from))
        (human_62959785b3ec220a_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (human_62959785b3ec220a_p_at ?interrogator ?location)
          (human_62959785b3ec220a_p_at ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (human_62959785b3ec220a_p_at ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (human_62959785b3ec220a_p_at ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (human_62959785b3ec220a_p_at ?saver ?location)
          (human_62959785b3ec220a_p_at ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (human_62959785b3ec220a_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (shared_p_consensus_b87a7c348ca3ad53 ?notsaved))
      )
    :agents (?saver)
  )

  (:action tiny_stories__story_067_a_start-working
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
      )
    :effect
      (tiny_stories__story_067_p_worker ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_clean-factory
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (shared_p_consensus_cdd7fb180ef2c9a2 tiny_stories__story_067_o_factory)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_make-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_makes-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character1)
        (tiny_stories__story_067_type_character ?character2)
        (and
          (tiny_stories__story_067_p_worker ?character1)
          (tiny_stories__story_067_p_worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_067_p_friends-with ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_067_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-less-nervous
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (and
          (tiny_stories__story_067_p_worker ?character)
          (tiny_stories__story_067_p_nervous ?character)
        )
      )
    :effect
      (not (tiny_stories__story_067_p_nervous ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_b87a7c348ca3ad53 ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (not (shared_p_consensus_cdd7fb180ef2c9a2 ?item))
        )
      )
    :effect
      (shared_p_consensus_cdd7fb180ef2c9a2 ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?door)
        (and
          (shared_p_consensus_b87a7c348ca3ad53 ?character)
          (not (writing_prompts__wp_060_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_060_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_adjust-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_b87a7c348ca3ad53 ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (not (writing_prompts__wp_060_p_fits ?item ?character))
        )
      )
    :effect
      (writing_prompts__wp_060_p_fits ?item ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_060_a_wear-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (shared_p_consensus_b87a7c348ca3ad53 ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )
)
