(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
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
    (human_72bec7307b121ea5_p_has ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_asleep ?v0 - object)
    (human_72bec7307b121ea5_p_connected ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_enchanted ?v0 - object)
    (human_72bec7307b121ea5_p_is ?v0 - object ?v1 - object)
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_050_p_playing-with-toys ?v0 - object)
    (tiny_stories__story_050_p_found-blocks ?v0 - object)
    (tiny_stories__story_050_p_stacking-blocks ?v0 - object)
    (tiny_stories__story_050_p_stack-tall ?v0 - object)
    (tiny_stories__story_050_p_stack-strong ?v0 - object)
    (tiny_stories__story_050_p_happy ?v0 - object)
    (tiny_stories__story_050_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))

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
        (human_72bec7307b121ea5_p_has ?taker ?thing)
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
          (human_72bec7307b121ea5_p_has ?caster ?book)
          (human_72bec7307b121ea5_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_enchanted ?thing))
    :agents (?caster)
  )

  (:action tiny_stories__story_050_a_play-with-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
      )
    :effect
      (tiny_stories__story_050_p_playing-with-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_find-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_playing-with-toys ?character)
      )
    :effect
      (tiny_stories__story_050_p_found-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_stack-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_found-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stacking-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_make-stack-tall
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stacking-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stack-tall ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?helper)
        (tiny_stories__story_050_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_050_p_stack-tall ?helpee)
        )
      )
    :effect
      (tiny_stories__story_050_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_050_a_make-stack-strong
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (and
          (tiny_stories__story_050_p_stack-tall ?character)
          (tiny_stories__story_050_p_helping ?character ?character)
        )
      )
    :effect
      (tiny_stories__story_050_p_stack-strong ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stack-strong ?character)
      )
    :effect
      (tiny_stories__story_050_p_happy ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )
)
