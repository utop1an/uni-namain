(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_074_active)
    (tiny_stories__story_074_type_character ?x - object)
    (tiny_stories__story_074_type_object ?x - object)
    (tiny_stories__story_089_active)
    (tiny_stories__story_089_type_character ?x - object)
    (tiny_stories__story_089_type_object ?x - object)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_060_type_character ?x - object)
    (writing_prompts__wp_060_type_item ?x - object)
    (writing_prompts__wp_060_type_object ?x - object)
    (writing_prompts__wp_060_type_place ?x - object)
    (alive ?p0)
    (clean ?p0)
    (locked ?p0)
    (wearing ?p0 ?p1)
    (fits ?p0 ?p1)
    (at ?p0 ?p1)
    (has ?p0 ?p1)
    (happy ?p0)
    (magic ?p0)
    (granted-wish ?p0)
    (playing ?p0)
    (tired ?p0)
    (sleeping ?p0)
    (awake ?p0)
    (has-energy ?p0)
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

  (:action clean-item
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (not (clean ?object))
        )
      )
    :effect
      (clean ?object)
  )

  (:action adjust-item
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (not (fits ?object ?character))
        )
      )
    :effect
      (fits ?object ?character)
  )

  (:action wear-item
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_060_active)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
          (writing_prompts__wp_060_type_character ?character)
          (writing_prompts__wp_060_type_item ?object)
        )
        (and
          (alive ?character)
          (has ?character ?object)
          (fits ?object ?character)
          (not (wearing ?character ?object))
        )
      )
    :effect
      (wearing ?character ?object)
  )

  (:action sit-down
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (happy ?character))
      )
    :effect
      (happy ?character)
  )

  (:action become-magic
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (magic ?character))
      )
    :effect
      (magic ?character)
  )

  (:action grant-wish
    :parameters (?granter ?wish)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?granter)
          (tiny_stories__story_074_type_object ?wish)
          (tiny_stories__story_074_type_character ?granter)
        )
        (magic ?granter)
      )
    :effect
      (granted-wish ?wish)
  )

  (:action stop-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (playing ?character)
      )
    :effect
      (and
        (not (playing ?character))
        (tired ?character)
      )
  )

  (:action sleep
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (and
          (tired ?character)
          (not (sleeping ?character))
        )
      )
    :effect
      (and
        (not (awake ?character))
        (sleeping ?character)
      )
  )

  (:action go-to
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_object ?place)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (at ?character ?place))
      )
    :effect
      (at ?character ?place)
  )

  (:action share-snack
    :parameters (?sharer ?receiver ?snack)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?sharer)
          (tiny_stories__story_074_type_character ?receiver)
          (tiny_stories__story_074_type_object ?snack)
          (tiny_stories__story_074_type_character ?sharer)
          (tiny_stories__story_074_type_character ?receiver)
        )
        (and
          (has ?sharer ?snack)
          (not (has ?receiver ?snack))
        )
      )
    :effect
      (has ?receiver ?snack)
  )

  (:action start-playing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (and
          (awake ?character)
          (not (playing ?character))
          (has-energy ?character)
        )
      )
    :effect
      (playing ?character)
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_089_active)
          (tiny_stories__story_089_type_character ?character)
          (tiny_stories__story_089_type_character ?character)
        )
        (sleeping ?character)
      )
    :effect
      (and
        (awake ?character)
        (not (sleeping ?character))
        (not (tired ?character))
        (has-energy ?character)
      )
  )
)
