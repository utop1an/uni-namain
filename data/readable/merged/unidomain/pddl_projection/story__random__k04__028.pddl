(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_075_active)
    (tiny_stories__story_075_type_character ?x - object)
    (tiny_stories__story_075_type_dress ?x - object)
    (tiny_stories__story_075_type_item ?x - object)
    (tiny_stories__story_075_type_object ?x - object)
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (writing_prompts__wp_090_active)
    (writing_prompts__wp_090_type_character ?x - object)
    (writing_prompts__wp_090_type_object ?x - object)
    (has-skin ?p0)
    (kneel ?p0)
    (rewarded ?p0)
    (tried ?p0)
    (voice-happy ?p0)
    (wearing ?p0 ?p1)
    (has ?p0 ?p1)
    (damaged ?p0)
    (at ?p0 ?p1)
    (happy ?p0)
    (alive ?p0)
    (amazed ?p0)
    (supports ?p0 ?p1)
    (persistent ?p0)
    (completed ?p0)
    (famous ?p0)
    (wears-earmuffs ?p0)
    (filled-with-ice ?p0)
    (candidate ?p0)
    (president ?p0)
    (endured-pain ?p0)
  )
  (:constants tiny_stories__story_031_o_old-house - object)

  (:action try
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (kneel ?character)
      )
    :effect
      (tried ?character)
  )

  (:action put-on-dress
    :parameters (?character ?dress)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
        )
        (and
          (has ?character ?dress)
          (not (wearing ?character ?dress))
        )
      )
    :effect
      (wearing ?character ?dress)
  )

  (:action slip
    :parameters (?character ?dress)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?dress)
        )
        (and
          (wearing ?character ?dress)
          (not (damaged ?dress))
        )
      )
    :effect
      (damaged ?dress)
  )

  (:action get-new-dress
    :parameters (?character ?old-dress ?new-dress)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-dress)
          (tiny_stories__story_075_type_dress ?new-dress)
          (tiny_stories__story_075_type_character ?character)
          (tiny_stories__story_075_type_dress ?old-dress)
          (tiny_stories__story_075_type_dress ?new-dress)
        )
        (and
          (damaged ?old-dress)
          (wearing ?character ?old-dress)
          (not (has ?character ?new-dress))
        )
      )
    :effect
      (and
        (not (wearing ?character ?old-dress))
        (has ?character ?new-dress)
      )
  )

  (:action kneel
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (at ?character tiny_stories__story_031_o_old-house)
      )
    :effect
      (kneel ?character)
  )

  (:action reward
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (voice-happy ?character)
      )
    :effect
      (rewarded ?character)
  )

  (:action take-skin
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (and
          (not (voice-happy ?character))
          (has-skin ?character)
        )
      )
    :effect
      (not (has-skin ?character))
  )

  (:action comfort
    :parameters (?parent ?child)
    :precondition
      (and
        (and
          (tiny_stories__story_075_active)
          (tiny_stories__story_075_type_character ?parent)
          (tiny_stories__story_075_type_character ?child)
          (tiny_stories__story_075_type_character ?parent)
          (tiny_stories__story_075_type_character ?child)
        )
        (and
          (not (happy ?child))
          (not (= ?parent ?child))
        )
      )
    :effect
      (happy ?child)
  )

  (:action evaluate
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (tried ?character)
      )
    :effect
      (voice-happy ?character)
  )

  (:action become-amazed
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (amazed ?character)
  )

  (:action support-project
    :parameters (?character ?project)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
        )
        (alive ?character)
      )
    :effect
      (supports ?character ?project)
  )

  (:action become-persistent
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (persistent ?character)
  )

  (:action complete-project
    :parameters (?character ?project)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_project ?project)
        )
        (and
          (alive ?character)
          (supports ?character ?project)
          (persistent ?character)
        )
      )
    :effect
      (completed ?project)
  )

  (:action become-famous
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (not (famous ?character))
      )
    :effect
      (famous ?character)
  )

  (:action wear-earmuffs
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (not (wears-earmuffs ?character))
        )
      )
    :effect
      (wears-earmuffs ?character)
  )

  (:action fill-earmuffs-with-ice
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (wears-earmuffs ?character)
          (not (filled-with-ice ?character))
        )
      )
    :effect
      (filled-with-ice ?character)
  )

  (:action endure-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (filled-with-ice ?character)
          (not (endured-pain ?character))
        )
      )
    :effect
      (endured-pain ?character)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
          (and
            (tiny_stories__story_031_active)
            (tiny_stories__story_031_type_character ?character)
            (tiny_stories__story_031_type_place ?from)
            (tiny_stories__story_031_type_place ?to)
            (tiny_stories__story_031_type_character ?character)
            (tiny_stories__story_031_type_place ?from)
            (tiny_stories__story_031_type_place ?to)
          )
          (and
            (tiny_stories__story_078_active)
            (tiny_stories__story_078_type_character ?character)
            (tiny_stories__story_078_type_place ?from)
            (tiny_stories__story_078_type_place ?to)
            (tiny_stories__story_078_type_character ?character)
            (tiny_stories__story_078_type_place ?from)
            (tiny_stories__story_078_type_place ?to)
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

  (:action become-candidate
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (famous ?character)
          (not (candidate ?character))
        )
      )
    :effect
      (candidate ?character)
  )

  (:action become-president
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_090_active)
          (writing_prompts__wp_090_type_character ?character)
          (writing_prompts__wp_090_type_character ?character)
        )
        (and
          (candidate ?character)
          (not (president ?character))
        )
      )
    :effect
      (president ?character)
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_078_active)
          (tiny_stories__story_078_type_character ?character)
          (tiny_stories__story_078_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (happy ?character)
  )
)
