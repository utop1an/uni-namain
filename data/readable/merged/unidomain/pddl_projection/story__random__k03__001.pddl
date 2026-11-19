(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_001_active)
    (tiny_stories__story_001_type_character ?x - object)
    (tiny_stories__story_001_type_object ?x - object)
    (tiny_stories__story_001_type_place ?x - object)
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (alive ?p0)
    (has ?p0 ?p1)
    (wolves-attack ?p0)
    (wolves-killed ?p0)
    (at ?p0 ?p1)
    (raining)
    (sunny)
    (muddy ?p0)
    (playing ?p0)
    (scared ?p0)
    (brave ?p0)
    (safe ?p0)
    (inside ?p0)
    (hidden ?p0 ?p1)
    (found ?p0)
    (searched ?p0 ?p1)
  )
  (:constants tiny_stories__story_001_o_outside - object)

  (:action die
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (not (alive ?character))
  )

  (:action kill-wolves
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?place)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
          (wolves-attack ?place)
        )
      )
    :effect
      (wolves-killed ?character)
  )

  (:action stop-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (raining)
      )
    :effect
      (and
        (not (raining))
        (sunny)
      )
  )

  (:action start-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (sunny)
      )
    :effect
      (and
        (not (sunny))
        (raining)
      )
  )

  (:action go-outside
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_001_active)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_character ?character)
        )
        (and
          (inside ?character)
          (sunny)
        )
      )
    :effect
      (and
        (not (inside ?character))
        (at ?character tiny_stories__story_001_o_outside)
      )
  )

  (:action go-inside
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_001_active)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_character ?character)
        )
        (at ?character tiny_stories__story_001_o_outside)
      )
    :effect
      (and
        (not (at ?character tiny_stories__story_001_o_outside))
        (inside ?character)
        (safe ?character)
      )
  )

  (:action play-in-mud
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_001_active)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_place ?place)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_place ?place)
        )
        (and
          (at ?character ?place)
          (muddy ?place)
        )
      )
    :effect
      (playing ?character)
  )

  (:action become-scared
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_001_active)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_character ?character)
        )
        (and
          (at ?character tiny_stories__story_001_o_outside)
          (not (scared ?character))
        )
      )
    :effect
      (scared ?character)
  )

  (:action become-brave
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_001_active)
          (tiny_stories__story_001_type_character ?character)
          (tiny_stories__story_001_type_character ?character)
        )
        (and
          (at ?character tiny_stories__story_001_o_outside)
          (scared ?character)
        )
      )
    :effect
      (and
        (not (scared ?character))
        (brave ?character)
      )
  )

  (:action hide
    :parameters (?character ?toy ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
        )
        (at ?character ?place)
      )
    :effect
      (hidden ?toy ?place)
  )

  (:action search
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_place ?place)
        )
        (and
          (at ?character ?place)
          (not (searched ?character ?place))
        )
      )
    :effect
      (searched ?character ?place)
  )

  (:action find
    :parameters (?character ?toy ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_027_active)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
          (tiny_stories__story_027_type_character ?character)
          (tiny_stories__story_027_type_toy ?toy)
          (tiny_stories__story_027_type_place ?place)
        )
        (and
          (at ?character ?place)
          (hidden ?toy ?place)
          (searched ?character ?place)
        )
      )
    :effect
      (found ?toy)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_032_active)
            (writing_prompts__wp_032_type_character ?character)
            (writing_prompts__wp_032_type_place ?from)
            (writing_prompts__wp_032_type_place ?to)
            (writing_prompts__wp_032_type_character ?character)
            (writing_prompts__wp_032_type_place ?from)
            (writing_prompts__wp_032_type_place ?to)
          )
          (and
            (tiny_stories__story_027_active)
            (tiny_stories__story_027_type_character ?character)
            (tiny_stories__story_027_type_place ?from)
            (tiny_stories__story_027_type_place ?to)
            (tiny_stories__story_027_type_character ?character)
            (tiny_stories__story_027_type_place ?from)
            (tiny_stories__story_027_type_place ?to)
          )
        )
        (and
          (not (= ?from ?to))
          (alive ?character)
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )
)
