(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_042_active)
    (tiny_stories__story_042_type_character ?x - object)
    (tiny_stories__story_042_type_object ?x - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (writing_prompts__wp_037_active)
    (writing_prompts__wp_037_type_character ?x - object)
    (writing_prompts__wp_037_type_object ?x - object)
    (in-tree ?p0)
    (wants-to-eat ?p0 ?p1)
    (hard ?p0)
    (broken ?p0)
    (eaten ?p0)
    (helping ?p0 ?p1)
    (happy ?p0)
    (tired ?p0)
    (played-together ?p0 ?p1)
    (at ?p0 ?p1)
    (knows ?p0 ?p1)
    (together ?p0 ?p1)
    (missing ?p0)
    (relationship ?p0 ?p1)
    (searching ?p0 ?p1)
    (found ?p0 ?p1)
    (has ?p0 ?p1)
    (on-top ?p0 ?p1)
    (friends ?p0 ?p1)
    (scared ?p0)
    (at-carnival ?p0)
    (wants-to-play ?p0)
    (played ?p0)
    (weight-too-low ?p0)
    (upset ?p0)
    (comforted ?p0)
  )

  (:action climb-tree
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?character)
          (tiny_stories__story_063_type_character ?character)
        )
        (not (in-tree ?character))
      )
    :effect
      (in-tree ?character)
  )

  (:action help
    :parameters (?helper ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?helper)
          (tiny_stories__story_063_type_character ?helpee)
          (tiny_stories__story_063_type_character ?helper)
          (tiny_stories__story_063_type_character ?helpee)
        )
        (and)
      )
    :effect
      (helping ?helper ?helpee)
  )

  (:action break-object
    :parameters (?character ?object ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?character)
          (tiny_stories__story_063_type_object ?object)
          (tiny_stories__story_063_type_character ?helpee)
          (tiny_stories__story_063_type_character ?character)
          (tiny_stories__story_063_type_character ?helpee)
        )
        (and
          (hard ?object)
          (helping ?character ?helpee)
        )
      )
    :effect
      (broken ?object)
  )

  (:action rest
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_077_active)
          (tiny_stories__story_077_type_character ?character)
          (tiny_stories__story_077_type_character ?character)
        )
        (tired ?character)
      )
    :effect
      (not (tired ?character))
  )

  (:action want-to-eat
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?character)
          (tiny_stories__story_063_type_object ?object)
          (tiny_stories__story_063_type_character ?character)
        )
        (and)
      )
    :effect
      (wants-to-eat ?character ?object)
  )

  (:action try-to-eat
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?character)
          (tiny_stories__story_063_type_object ?object)
          (tiny_stories__story_063_type_character ?character)
        )
        (and
          (wants-to-eat ?character ?object)
          (hard ?object)
        )
      )
    :effect
      (not (eaten ?object))
  )

  (:action eat-together
    :parameters (?character1 ?character2 ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_063_active)
          (tiny_stories__story_063_type_character ?character1)
          (tiny_stories__story_063_type_character ?character2)
          (tiny_stories__story_063_type_object ?object)
          (tiny_stories__story_063_type_character ?character1)
          (tiny_stories__story_063_type_character ?character2)
        )
        (and
          (broken ?object)
          (helping ?character1 ?character2)
        )
      )
    :effect
      (eaten ?object)
  )

  (:action play
    :parameters (?character1 ?character2 ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_077_active)
          (tiny_stories__story_077_type_character ?character1)
          (tiny_stories__story_077_type_character ?character2)
          (tiny_stories__story_077_type_place ?place)
          (tiny_stories__story_077_type_character ?character1)
          (tiny_stories__story_077_type_character ?character2)
          (tiny_stories__story_077_type_place ?place)
        )
        (and
          (not (= ?character1 ?character2))
          (at ?character1 ?place)
          (at ?character2 ?place)
        )
      )
    :effect
      (and
        (played-together ?character1 ?character2)
        (happy ?character1)
        (happy ?character2)
        (tired ?character1)
        (tired ?character2)
      )
  )

  (:action start-search
    :parameters (?searcher ?target)
    :precondition
      (and
        (and
          (writing_prompts__wp_037_active)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
        )
        (and
          (not (= ?searcher ?target))
          (not (searching ?searcher ?target))
          (missing ?target)
        )
      )
    :effect
      (searching ?searcher ?target)
  )

  (:action stop-search
    :parameters (?searcher ?target)
    :precondition
      (and
        (and
          (writing_prompts__wp_037_active)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
        )
        (searching ?searcher ?target)
      )
    :effect
      (not (searching ?searcher ?target))
  )

  (:action find
    :parameters (?searcher ?target)
    :precondition
      (and
        (and
          (writing_prompts__wp_037_active)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
          (writing_prompts__wp_037_type_character ?searcher)
          (writing_prompts__wp_037_type_character ?target)
        )
        (and
          (searching ?searcher ?target)
          (missing ?target)
        )
      )
    :effect
      (and
        (not (missing ?target))
        (found ?searcher ?target)
      )
  )

  (:action become-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character1)
          (tiny_stories__story_040_type_character ?character2)
          (tiny_stories__story_040_type_character ?character1)
          (tiny_stories__story_040_type_character ?character2)
        )
        (not (= ?character1 ?character2))
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action overcome-fear
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_character ?character)
        )
        (scared ?character)
      )
    :effect
      (not (scared ?character))
  )

  (:action become-upset
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_042_active)
          (tiny_stories__story_042_type_character ?character)
          (tiny_stories__story_042_type_character ?character)
        )
        (weight-too-low ?character)
      )
    :effect
      (upset ?character)
  )

  (:action comfort
    :parameters (?comforter ?comforted)
    :precondition
      (and
        (and
          (tiny_stories__story_042_active)
          (tiny_stories__story_042_type_character ?comforter)
          (tiny_stories__story_042_type_character ?comforted)
          (tiny_stories__story_042_type_character ?comforter)
          (tiny_stories__story_042_type_character ?comforted)
        )
        (and
          (not (= ?comforter ?comforted))
          (upset ?comforted)
        )
      )
    :effect
      (comforted ?comforted)
  )

  (:action start-relationship
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_037_active)
          (writing_prompts__wp_037_type_character ?character1)
          (writing_prompts__wp_037_type_character ?character2)
          (writing_prompts__wp_037_type_character ?character1)
          (writing_prompts__wp_037_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (not (relationship ?character1 ?character2))
          (knows ?character1 ?character2)
        )
      )
    :effect
      (relationship ?character1 ?character2)
  )

  (:action end-relationship
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_037_active)
          (writing_prompts__wp_037_type_character ?character1)
          (writing_prompts__wp_037_type_character ?character2)
          (writing_prompts__wp_037_type_character ?character1)
          (writing_prompts__wp_037_type_character ?character2)
        )
        (relationship ?character1 ?character2)
      )
    :effect
      (not (relationship ?character1 ?character2))
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
          (and
            (tiny_stories__story_077_active)
            (tiny_stories__story_077_type_character ?character)
            (tiny_stories__story_077_type_place ?from)
            (tiny_stories__story_077_type_place ?to)
            (tiny_stories__story_077_type_character ?character)
            (tiny_stories__story_077_type_place ?from)
            (tiny_stories__story_077_type_place ?to)
          )
          (and
            (tiny_stories__story_040_active)
            (tiny_stories__story_040_type_character ?character)
            (tiny_stories__story_040_type_place ?from)
            (tiny_stories__story_040_type_place ?to)
            (tiny_stories__story_040_type_character ?character)
            (tiny_stories__story_040_type_place ?from)
            (tiny_stories__story_040_type_place ?to)
          )
        )
        (and
          (not (= ?from ?to))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action retrieve-toy
    :parameters (?character ?toy ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_toy ?toy)
          (tiny_stories__story_040_type_place ?place)
          (tiny_stories__story_040_type_character ?character)
          (tiny_stories__story_040_type_toy ?toy)
          (tiny_stories__story_040_type_place ?place)
        )
        (and
          (at ?character ?place)
          (on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (on-top ?toy ?place))
        (has ?character ?toy)
      )
  )

  (:action go-to-carnival
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_042_active)
          (tiny_stories__story_042_type_character ?character)
          (tiny_stories__story_042_type_character ?character)
        )
        (and)
      )
    :effect
      (at-carnival ?character)
  )

  (:action want-to-play
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_042_active)
          (tiny_stories__story_042_type_character ?character)
          (tiny_stories__story_042_type_character ?character)
        )
        (at-carnival ?character)
      )
    :effect
      (wants-to-play ?character)
  )

  (:action play-game
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_042_active)
          (tiny_stories__story_042_type_character ?character)
          (tiny_stories__story_042_type_character ?character)
        )
        (and
          (at-carnival ?character)
          (wants-to-play ?character)
        )
      )
    :effect
      (and
        (played ?character)
        (weight-too-low ?character)
      )
  )
)
