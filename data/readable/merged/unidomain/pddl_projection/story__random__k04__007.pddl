(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (reading ?p0)
    (playing ?p0)
    (calm ?p0)
    (books-fall)
    (hiding ?p0)
    (seeking ?p0)
    (found ?p0 ?p1)
    (at ?p0 ?p1)
    (alive ?p0)
    (has ?p0 ?p1)
    (clean ?p0)
    (locked ?p0)
    (wearing ?p0 ?p1)
    (fits ?p0 ?p1)
    (president ?p0)
    (speaker ?p0)
    (vice-president ?p0)
    (belongs-to ?p0 ?p1)
    (economy-collapsed)
    (real-estate-monopoly)
    (planned-parenthood-defunded)
    (planned-parenthood-shutdown)
    (planned-parenthood-criminalized)
    (prison-population-increased)
    (political-prisoner ?p0)
  )

  (:action start-reading
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (reading ?character))
      )
    :effect
      (reading ?character)
  )

  (:action stop-reading
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (reading ?character)
      )
    :effect
      (not (reading ?character))
  )

  (:action start-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (playing ?character))
      )
    :effect
      (playing ?character)
  )

  (:action stop-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (playing ?character)
      )
    :effect
      (not (playing ?character))
  )

  (:action become-calm
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (not (calm ?character))
      )
    :effect
      (calm ?character)
  )

  (:action become-uncalm
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_009_active)
          (tiny_stories__story_009_type_character ?character)
          (tiny_stories__story_009_type_character ?character)
        )
        (calm ?character)
      )
    :effect
      (not (calm ?character))
  )

  (:action books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (books-fall))
      )
    :effect
      (books-fall)
  )

  (:action stop-seeking
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_character ?character)
        )
        (seeking ?character)
      )
    :effect
      (not (seeking ?character))
  )

  (:action start-hiding
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (hiding ?character)
  )

  (:action start-seeking
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?character)
          (tiny_stories__story_038_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (seeking ?character)
  )

  (:action find
    :parameters (?seeker ?hider ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_038_active)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
          (tiny_stories__story_038_type_character ?seeker)
          (tiny_stories__story_038_type_character ?hider)
          (tiny_stories__story_038_type_place ?place)
        )
        (and
          (seeking ?seeker)
          (hiding ?hider)
          (at ?seeker ?place)
          (at ?hider ?place)
        )
      )
    :effect
      (and
        (found ?seeker ?hider)
        (not (hiding ?hider))
      )
  )

  (:action clean-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (clean ?item))
        )
      )
    :effect
      (clean ?item)
  )

  (:action lock-door
    :parameters (?character ?door)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?door)
        )
        (and
          (alive ?character)
          (not (locked ?door))
        )
      )
    :effect
      (locked ?door)
  )

  (:action adjust-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (not (fits ?item ?character))
        )
      )
    :effect
      (fits ?item ?character)
  )

  (:action wear-item
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?item)
        )
        (and
          (alive ?character)
          (has ?character ?item)
          (fits ?item ?character)
          (not (wearing ?character ?item))
        )
      )
    :effect
      (wearing ?character ?item)
  )

  (:action introduce-president
    :parameters (?speaker ?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
        )
        (and
          (speaker ?speaker)
          (president ?president)
        )
      )
    :effect
      (and)
  )

  (:action announce-state-of-the-union
    :parameters (?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?president)
        )
        (president ?president)
      )
    :effect
      (and)
  )

  (:action attend-state-of-the-union
    :parameters (?vice-president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?vice-president)
          (writing_prompts__wp_075_type_character ?vice-president)
        )
        (vice-president ?vice-president)
      )
    :effect
      (and)
  )
)
