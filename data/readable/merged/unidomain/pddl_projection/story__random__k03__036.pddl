(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (writing_prompts__wp_090_active)
    (writing_prompts__wp_090_type_character ?x - object)
    (writing_prompts__wp_090_type_object ?x - object)
    (writing_prompts__wp_098_active)
    (writing_prompts__wp_098_type_character ?x - object)
    (writing_prompts__wp_098_type_object ?x - object)
    (alive ?p0)
    (feeling ?p0)
    (last-soul ?p0)
    (understand ?p0)
    (witness ?p0)
    (end ?p0)
    (worker ?p0)
    (clean ?p0)
    (makes-toys ?p0)
    (nervous ?p0)
    (friends-with ?p0 ?p1)
    (happy ?p0)
    (famous ?p0)
    (wears-earmuffs ?p0)
    (filled-with-ice ?p0)
    (candidate ?p0)
    (president ?p0)
    (endured-pain ?p0)
  )
  (:constants tiny_stories__story_067_o_factory - object)

  (:action start-feeling
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (feeling ?character))
        )
      )
    :effect
      (feeling ?character)
  )

  (:action witness-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (witness ?character))
        )
      )
    :effect
      (witness ?character)
  )

  (:action understand-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (witness ?character)
          (not (understand ?character))
        )
      )
    :effect
      (understand ?character)
  )

  (:action last-soul-fades
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (last-soul ?character)
          (understand ?character)
        )
      )
    :effect
      (not (alive ?character))
  )

  (:action humanity-ends
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (understand ?character)
          (not (end ?character))
        )
      )
    :effect
      (end ?character)
  )

  (:action start-working
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (and)
      )
    :effect
      (worker ?character)
  )

  (:action clean-factory
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (clean tiny_stories__story_067_o_factory)
  )

  (:action make-toys
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (makes-toys ?character)
  )

  (:action become-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character1)
          (tiny_stories__story_067_type_character ?character2)
          (tiny_stories__story_067_type_character ?character1)
          (tiny_stories__story_067_type_character ?character2)
        )
        (and
          (worker ?character1)
          (worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (friends-with ?character1 ?character2)
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (worker ?character)
      )
    :effect
      (happy ?character)
  )

  (:action become-less-nervous
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?character)
          (tiny_stories__story_067_type_character ?character)
        )
        (and
          (worker ?character)
          (nervous ?character)
        )
      )
    :effect
      (not (nervous ?character))
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
)
