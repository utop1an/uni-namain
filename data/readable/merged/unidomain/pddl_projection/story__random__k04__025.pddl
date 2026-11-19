(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (hungry ?p0)
    (friend ?p0 ?p1)
    (alive ?p0)
    (food-available)
    (in-tree ?p0)
    (wants-to-eat ?p0 ?p1)
    (hard ?p0)
    (broken ?p0)
    (eaten ?p0)
    (helping ?p0 ?p1)
    (sailor ?p0)
    (nice ?p0)
    (sailing ?p0)
    (together ?p0 ?p1)
    (feels-awful ?p0)
    (thinks-about-breakup ?p0)
    (heartbroken ?p0)
    (forgiven ?p0)
    (learned ?p0)
    (moved-on ?p0)
  )

  (:action ask-to-be-friends
    :parameters (?asker ?askee)
    :precondition
      (and
        (and
          (tiny_stories__story_030_active)
          (tiny_stories__story_030_type_character ?asker)
          (tiny_stories__story_030_type_character ?askee)
          (tiny_stories__story_030_type_character ?asker)
          (tiny_stories__story_030_type_character ?askee)
        )
        (and
          (alive ?asker)
          (alive ?askee)
          (not (friend ?asker ?askee))
        )
      )
    :effect
      (friend ?asker ?askee)
  )

  (:action search-for-food
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_030_active)
          (tiny_stories__story_030_type_character ?character)
          (tiny_stories__story_030_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (food-available)
  )

  (:action feed
    :parameters (?feeder ?eater)
    :precondition
      (and
        (and
          (tiny_stories__story_030_active)
          (tiny_stories__story_030_type_character ?feeder)
          (tiny_stories__story_030_type_character ?eater)
          (tiny_stories__story_030_type_character ?feeder)
          (tiny_stories__story_030_type_character ?eater)
        )
        (and
          (alive ?feeder)
          (alive ?eater)
          (hungry ?eater)
          (food-available)
        )
      )
    :effect
      (not (hungry ?eater))
  )

  (:action eat
    :parameters (?eater ?eaten)
    :precondition
      (and
        (and
          (tiny_stories__story_030_active)
          (tiny_stories__story_030_type_character ?eater)
          (tiny_stories__story_030_type_character ?eaten)
          (tiny_stories__story_030_type_character ?eater)
          (tiny_stories__story_030_type_character ?eaten)
        )
        (and
          (alive ?eater)
          (hungry ?eater)
          (alive ?eaten)
        )
      )
    :effect
      (not (alive ?eaten))
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

  (:action learn-to-sail
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character)
          (tiny_stories__story_098_type_character ?character)
        )
        (and)
      )
    :effect
      (sailor ?character)
  )

  (:action become-nice
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character)
          (tiny_stories__story_098_type_character ?character)
        )
        (and)
      )
    :effect
      (nice ?character)
  )

  (:action sail-together
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character1)
          (tiny_stories__story_098_type_character ?character2)
          (tiny_stories__story_098_type_character ?character1)
          (tiny_stories__story_098_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (sailor ?character1)
          (sailor ?character2)
        )
      )
    :effect
      (together ?character1 ?character2)
  )

  (:action thank
    :parameters (?thanker ?thankee)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?thanker)
          (tiny_stories__story_098_type_character ?thankee)
          (tiny_stories__story_098_type_character ?thanker)
          (tiny_stories__story_098_type_character ?thankee)
        )
        (not (= ?thanker ?thankee))
      )
    :effect
      (nice ?thanker)
  )

  (:action forgive
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_091_active)
          (writing_prompts__wp_091_type_character ?character)
          (writing_prompts__wp_091_type_character ?character)
        )
        (and
          (feels-awful ?character)
          (not (forgiven ?character))
        )
      )
    :effect
      (forgiven ?character)
  )

  (:action learn
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_091_active)
          (writing_prompts__wp_091_type_character ?character)
          (writing_prompts__wp_091_type_character ?character)
        )
        (and
          (heartbroken ?character)
          (not (learned ?character))
        )
      )
    :effect
      (learned ?character)
  )

  (:action move-on
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_091_active)
          (writing_prompts__wp_091_type_character ?character)
          (writing_prompts__wp_091_type_character ?character)
        )
        (and
          (thinks-about-breakup ?character)
          (forgiven ?character)
          (learned ?character)
          (not (moved-on ?character))
        )
      )
    :effect
      (moved-on ?character)
  )

  (:action help
    :parameters (?helper ?helpee)
    :precondition
      (and
        (or
          (and
            (tiny_stories__story_063_active)
            (tiny_stories__story_063_type_character ?helper)
            (tiny_stories__story_063_type_character ?helpee)
            (tiny_stories__story_063_type_character ?helper)
            (tiny_stories__story_063_type_character ?helpee)
          )
          (and
            (tiny_stories__story_098_active)
            (tiny_stories__story_098_type_character ?helper)
            (tiny_stories__story_098_type_character ?helpee)
            (tiny_stories__story_098_type_character ?helper)
            (tiny_stories__story_098_type_character ?helpee)
          )
        )
        (not (= ?helper ?helpee))
      )
    :effect
      (helping ?helper ?helpee)
  )
)
