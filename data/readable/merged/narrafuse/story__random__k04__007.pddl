(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_009_p_reading ?v0 - object)
    (tiny_stories__story_009_p_playing ?v0 - object)
    (tiny_stories__story_009_p_calm ?v0 - object)
    (tiny_stories__story_009_p_books-fall)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (tiny_stories__story_038_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_038_p_hiding ?v0 - object)
    (tiny_stories__story_038_p_seeking ?v0 - object)
    (tiny_stories__story_038_p_found ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_060_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_alive ?v0 - object)
    (writing_prompts__wp_060_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_clean ?v0 - object)
    (writing_prompts__wp_060_p_locked ?v0 - object)
    (writing_prompts__wp_060_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_060_p_fits ?v0 - object ?v1 - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (writing_prompts__wp_075_p_president ?v0 - object)
    (writing_prompts__wp_075_p_speaker ?v0 - object)
    (writing_prompts__wp_075_p_vice-president ?v0 - object)
    (writing_prompts__wp_075_p_belongs-to ?v0 - object ?v1 - object)
    (writing_prompts__wp_075_p_economy-collapsed)
    (writing_prompts__wp_075_p_real-estate-monopoly)
    (writing_prompts__wp_075_p_planned-parenthood-defunded)
    (writing_prompts__wp_075_p_planned-parenthood-shutdown)
    (writing_prompts__wp_075_p_planned-parenthood-criminalized)
    (writing_prompts__wp_075_p_prison-population-increased)
    (writing_prompts__wp_075_p_political-prisoner ?v0 - object)
  )

  (:action tiny_stories__story_009_a_start-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_reading ?character))
      )
    :effect
      (tiny_stories__story_009_p_reading ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_reading ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_reading ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_playing ?character))
      )
    :effect
      (tiny_stories__story_009_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_playing ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_playing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-calm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_calm ?character))
      )
    :effect
      (tiny_stories__story_009_p_calm ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-uncalm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_calm ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_calm ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (tiny_stories__story_009_p_books-fall))
      )
    :effect
      (tiny_stories__story_009_p_books-fall)
  )

  (:action tiny_stories__story_038_a_start-hiding
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
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
        (tiny_stories__story_038_p_at ?character ?place)
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
          (tiny_stories__story_038_p_at ?seeker ?place)
          (tiny_stories__story_038_p_at ?hider ?place)
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

  (:action writing_prompts__wp_060_a_clean-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_060_active)
        (writing_prompts__wp_060_type_character ?character)
        (writing_prompts__wp_060_type_item ?item)
        (and
          (writing_prompts__wp_060_p_alive ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (not (writing_prompts__wp_060_p_clean ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_clean ?item)
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
          (writing_prompts__wp_060_p_alive ?character)
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
          (writing_prompts__wp_060_p_alive ?character)
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
          (writing_prompts__wp_060_p_alive ?character)
          (writing_prompts__wp_060_p_has ?character ?item)
          (writing_prompts__wp_060_p_fits ?item ?character)
          (not (writing_prompts__wp_060_p_wearing ?character ?item))
        )
      )
    :effect
      (writing_prompts__wp_060_p_wearing ?character ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_075_a_announce-state-of-the-union
    :parameters (?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?president)
        (writing_prompts__wp_075_p_president ?president)
      )
    :agents (?president)
  )

  (:action writing_prompts__wp_075_a_introduce-president
    :parameters (?speaker - object ?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?speaker)
        (writing_prompts__wp_075_type_character ?president)
        (and
          (writing_prompts__wp_075_p_speaker ?speaker)
          (writing_prompts__wp_075_p_president ?president)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_075_a_attend-state-of-the-union
    :parameters (?vice-president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?vice-president)
        (writing_prompts__wp_075_p_vice-president ?vice-president)
      )
    :agents (?vice-president)
  )
)
