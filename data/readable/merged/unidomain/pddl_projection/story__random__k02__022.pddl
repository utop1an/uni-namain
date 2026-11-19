(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (writing_prompts__wp_037_active)
    (writing_prompts__wp_037_type_character ?x - object)
    (writing_prompts__wp_037_type_object ?x - object)
    (broken ?p0)
    (has ?p0 ?p1)
    (playing ?p0 ?p1)
    (apologized ?p0 ?p1)
    (cleaned ?p0)
    (forgiven ?p0 ?p1)
    (knows ?p0 ?p1)
    (together ?p0 ?p1)
    (missing ?p0)
    (relationship ?p0 ?p1)
    (searching ?p0 ?p1)
    (found ?p0 ?p1)
  )

  (:action play
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?character)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?character)
          (tiny_stories__story_085_type_item ?item)
        )
        (and
          (not (broken ?item))
          (has ?character ?item)
        )
      )
    :effect
      (playing ?character ?item)
  )

  (:action break-item
    :parameters (?breaker ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?breaker)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?breaker)
          (tiny_stories__story_085_type_item ?item)
        )
        (and
          (not (broken ?item))
          (playing ?breaker ?item)
        )
      )
    :effect
      (broken ?item)
  )

  (:action apologize
    :parameters (?apologizer ?apologizee)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?apologizer)
          (tiny_stories__story_085_type_character ?apologizee)
          (tiny_stories__story_085_type_character ?apologizer)
          (tiny_stories__story_085_type_character ?apologizee)
        )
        (not (= ?apologizer ?apologizee))
      )
    :effect
      (apologized ?apologizer ?apologizee)
  )

  (:action clean
    :parameters (?cleaner ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?cleaner)
          (tiny_stories__story_085_type_item ?item)
          (tiny_stories__story_085_type_character ?cleaner)
          (tiny_stories__story_085_type_item ?item)
        )
        (broken ?item)
      )
    :effect
      (cleaned ?cleaner)
  )

  (:action forgive
    :parameters (?forgiver ?forgivee)
    :precondition
      (and
        (and
          (tiny_stories__story_085_active)
          (tiny_stories__story_085_type_character ?forgiver)
          (tiny_stories__story_085_type_character ?forgivee)
          (tiny_stories__story_085_type_character ?forgiver)
          (tiny_stories__story_085_type_character ?forgivee)
        )
        (and
          (not (= ?forgiver ?forgivee))
          (apologized ?forgivee ?forgiver)
        )
      )
    :effect
      (forgiven ?forgiver ?forgivee)
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
)
