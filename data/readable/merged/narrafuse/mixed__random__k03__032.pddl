(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_72bec7307b121ea5_active)
    (human_72bec7307b121ea5_type_book ?x - object)
    (human_72bec7307b121ea5_type_character ?x - object)
    (human_72bec7307b121ea5_type_item ?x - object)
    (human_72bec7307b121ea5_type_location ?x - object)
    (human_72bec7307b121ea5_type_object ?x - object)
    (human_72bec7307b121ea5_type_ring ?x - object)
    (human_72bec7307b121ea5_type_sword ?x - object)
    (human_72bec7307b121ea5_type_thing ?x - object)
    (human_72bec7307b121ea5_p_player ?v0 - object)
    (human_72bec7307b121ea5_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_0d978bd7b45acafe ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_asleep ?v0 - object)
    (human_72bec7307b121ea5_p_connected ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_enchanted ?v0 - object)
    (human_72bec7307b121ea5_p_is ?v0 - object ?v1 - object)
    (tiny_stories__story_042_active)
    (tiny_stories__story_042_type_character ?x - object)
    (tiny_stories__story_042_type_object ?x - object)
    (tiny_stories__story_042_p_at-carnival ?v0 - object)
    (tiny_stories__story_042_p_wants-to-play ?v0 - object)
    (tiny_stories__story_042_p_played ?v0 - object)
    (tiny_stories__story_042_p_weight-too-low ?v0 - object)
    (tiny_stories__story_042_p_upset ?v0 - object)
    (tiny_stories__story_042_p_comforted ?v0 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_alive ?v0 - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
  )

  (:action human_72bec7307b121ea5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?character)
        (human_72bec7307b121ea5_type_location ?to)
        (human_72bec7307b121ea5_type_location ?from)
        (and
          (human_72bec7307b121ea5_p_connected ?to ?from)
          (not (human_72bec7307b121ea5_p_asleep ?character))
          (human_72bec7307b121ea5_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_72bec7307b121ea5_p_at ?character ?from))
        (human_72bec7307b121ea5_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_72bec7307b121ea5_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?waker)
        (human_72bec7307b121ea5_type_character ?woken)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?waker ?location)
          (human_72bec7307b121ea5_p_at ?woken ?location)
          (human_72bec7307b121ea5_p_asleep ?woken)
          (not (human_72bec7307b121ea5_p_asleep ?waker))
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_asleep ?woken))
    :agents (?waker)
  )

  (:action human_72bec7307b121ea5_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?taker)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?taker ?location)
          (human_72bec7307b121ea5_p_at ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?taker))
          (not (human_72bec7307b121ea5_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_72bec7307b121ea5_p_at ?thing ?location))
        (shared_p_consensus_0d978bd7b45acafe ?taker ?thing)
      )
    :agents (?taker)
  )

  (:action human_72bec7307b121ea5_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?caster)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_book ?book)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?caster ?location)
          (human_72bec7307b121ea5_p_at ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?caster))
          (shared_p_consensus_0d978bd7b45acafe ?caster ?book)
          (human_72bec7307b121ea5_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_enchanted ?thing))
    :agents (?caster)
  )

  (:action tiny_stories__story_042_a_go-to-carnival
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
      )
    :effect
      (tiny_stories__story_042_p_at-carnival ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_want-to-play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_at-carnival ?character)
      )
    :effect
      (tiny_stories__story_042_p_wants-to-play ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (and
          (tiny_stories__story_042_p_at-carnival ?character)
          (tiny_stories__story_042_p_wants-to-play ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_042_p_played ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_become-upset
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?character)
        (tiny_stories__story_042_p_weight-too-low ?character)
      )
    :effect
      (tiny_stories__story_042_p_upset ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_042_a_comfort
    :parameters (?comforter - object ?comforted - object)
    :precondition
      (and
        (tiny_stories__story_042_active)
        (tiny_stories__story_042_type_character ?comforter)
        (tiny_stories__story_042_type_character ?comforted)
        (and
          (not (= ?comforter ?comforted))
          (tiny_stories__story_042_p_upset ?comforted)
        )
      )
    :effect
      (tiny_stories__story_042_p_comforted ?comforted)
    :agents (?comforter)
  )

  (:action writing_prompts__wp_036_a_create-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (writing_prompts__wp_036_p_alive ?character)
      )
    :effect
      (and
        (writing_prompts__wp_036_p_created ?character ?lightbox)
        (shared_p_consensus_0d978bd7b45acafe ?character ?lightbox)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_anchor-light
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (shared_p_consensus_0d978bd7b45acafe ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_anchored ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_charge-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_anchored ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_charged ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_use-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_charged ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (shared_p_consensus_0d978bd7b45acafe ?character ?lightbox)
        )
      )
    :effect
      (and
        (writing_prompts__wp_036_p_used ?character ?lightbox)
        (not (writing_prompts__wp_036_p_charged ?lightbox))
      )
    :agents (?character)
  )
)
