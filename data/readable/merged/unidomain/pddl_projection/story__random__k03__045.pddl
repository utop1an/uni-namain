(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (asleep ?p0)
    (awake ?p0)
    (at ?p0 ?p1)
    (has-hoard ?p0)
    (robbed ?p0)
    (soundproof-door ?p0)
    (attacked ?p0)
    (broken ?p0)
    (has ?p0 ?p1)
    (playing ?p0 ?p1)
    (apologized ?p0 ?p1)
    (cleaned ?p0)
    (forgiven ?p0 ?p1)
    (in-drawer ?p0)
    (friends ?p0 ?p1)
    (wants-to-take ?p0 ?p1)
    (brave ?p0)
  )

  (:action sleep
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (awake ?character))
        (asleep ?character)
      )
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (asleep ?character)
      )
    :effect
      (and
        (not (asleep ?character))
        (awake ?character)
      )
  )

  (:action install-soundproof-door
    :parameters (?gang ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
        )
        (and
          (awake ?gang)
          (at ?gang ?place)
          (not (soundproof-door ?place))
        )
      )
    :effect
      (soundproof-door ?place)
  )

  (:action rob
    :parameters (?gang)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_character ?gang)
        )
        (awake ?gang)
      )
    :effect
      (robbed ?gang)
  )

  (:action attack
    :parameters (?attacker ?victim)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
        )
        (and
          (awake ?attacker)
          (awake ?victim)
        )
      )
    :effect
      (attacked ?victim)
  )

  (:action clear-passage
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (attacked ?character))
        (has-hoard ?character)
      )
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

  (:action find-toy
    :parameters (?character ?toy)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?character)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?character)
          (tiny_stories__story_090_type_toy ?toy)
        )
        (in-drawer ?toy)
      )
    :effect
      (and
        (not (in-drawer ?toy))
        (friends ?character ?toy)
      )
  )

  (:action want-to-take
    :parameters (?taker ?toy ?owner)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?owner)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?owner)
        )
        (and
          (not (= ?taker ?owner))
          (friends ?owner ?toy)
        )
      )
    :effect
      (wants-to-take ?taker ?toy)
  )

  (:action stand-up
    :parameters (?defender ?taker ?toy)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?defender)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?defender)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
        )
        (and
          (not (= ?defender ?taker))
          (wants-to-take ?taker ?toy)
          (friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (wants-to-take ?taker ?toy))
        (brave ?defender)
      )
  )
)
