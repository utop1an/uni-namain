(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (found ?p0 ?p1)
    (made-handprint ?p0)
    (celebrated ?p0)
    (has ?p0 ?p1)
    (alive ?p0)
    (at ?p0 ?p1)
    (drunk ?p0)
    (night-show ?p0)
    (vomit-stain ?p0)
  )
  (:constants tiny_stories__story_019_o_colors - object)

  (:action find
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?character)
          (tiny_stories__story_019_type_object ?object)
          (tiny_stories__story_019_type_character ?character)
        )
        (not (found ?character ?object))
      )
    :effect
      (found ?character ?object)
  )

  (:action make-handprint
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?character)
          (tiny_stories__story_019_type_character ?character)
        )
        (found ?character tiny_stories__story_019_o_colors)
      )
    :effect
      (made-handprint ?character)
  )

  (:action show-handprint
    :parameters (?shower ?viewer)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?shower)
          (tiny_stories__story_019_type_character ?viewer)
          (tiny_stories__story_019_type_character ?shower)
          (tiny_stories__story_019_type_character ?viewer)
        )
        (and
          (made-handprint ?shower)
          (not (= ?shower ?viewer))
        )
      )
    :effect
      (celebrated ?viewer)
  )

  (:action celebrate
    :parameters (?celebrator ?celebratee)
    :precondition
      (and
        (and
          (tiny_stories__story_019_active)
          (tiny_stories__story_019_type_character ?celebrator)
          (tiny_stories__story_019_type_character ?celebratee)
          (tiny_stories__story_019_type_character ?celebrator)
          (tiny_stories__story_019_type_character ?celebratee)
        )
        (and
          (celebrated ?celebrator)
          (not (= ?celebrator ?celebratee))
        )
      )
    :effect
      (celebrated ?celebratee)
  )

  (:action move
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_042_active)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_place ?place)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_place ?place)
        )
        (and
          (alive ?character)
          (not (at ?character ?place))
        )
      )
    :effect
      (at ?character ?place)
  )

  (:action vomit
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_042_active)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_place ?place)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_place ?place)
        )
        (and
          (alive ?character)
          (drunk ?character)
          (at ?character ?place)
        )
      )
    :effect
      (vomit-stain ?place)
  )

  (:action sober-up
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_042_active)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_character ?character)
        )
        (drunk ?character)
      )
    :effect
      (not (drunk ?character))
  )

  (:action drink
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_042_active)
          (writing_prompts__wp_042_type_character ?character)
          (writing_prompts__wp_042_type_drink ?object)
          (writing_prompts__wp_042_type_character ?character)
        )
        (and
          (alive ?character)
          (has ?character ?object)
        )
      )
    :effect
      (and
        (drunk ?character)
        (not (has ?character ?object))
      )
  )
)
