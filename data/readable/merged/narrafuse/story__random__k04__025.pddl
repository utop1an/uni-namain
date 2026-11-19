(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_030_p_hungry ?v0 - object)
    (tiny_stories__story_030_p_friend ?v0 - object ?v1 - object)
    (tiny_stories__story_030_p_alive ?v0 - object)
    (tiny_stories__story_030_p_food-available)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (shared_p_consensus_163c7ff70d35a80b ?v0 - object ?v1 - object)
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (tiny_stories__story_098_p_sailor ?v0 - object)
    (tiny_stories__story_098_p_nice ?v0 - object)
    (tiny_stories__story_098_p_sailing ?v0 - object)
    (tiny_stories__story_098_p_together ?v0 - object ?v1 - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (writing_prompts__wp_091_p_feels-awful ?v0 - object)
    (writing_prompts__wp_091_p_thinks-about-breakup ?v0 - object)
    (writing_prompts__wp_091_p_heartbroken ?v0 - object)
    (writing_prompts__wp_091_p_forgiven ?v0 - object)
    (writing_prompts__wp_091_p_learned ?v0 - object)
    (writing_prompts__wp_091_p_moved-on ?v0 - object)
  )

  (:action tiny_stories__story_030_a_ask-to-be-friends
    :parameters (?asker - object ?askee - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?asker)
        (tiny_stories__story_030_type_character ?askee)
        (and
          (tiny_stories__story_030_p_alive ?asker)
          (tiny_stories__story_030_p_alive ?askee)
          (not (tiny_stories__story_030_p_friend ?asker ?askee))
        )
      )
    :effect
      (tiny_stories__story_030_p_friend ?asker ?askee)
    :agents (?asker)
  )

  (:action tiny_stories__story_030_a_search-for-food
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?character)
        (tiny_stories__story_030_p_alive ?character)
      )
    :effect
      (tiny_stories__story_030_p_food-available)
    :agents (?character)
  )

  (:action tiny_stories__story_030_a_feed
    :parameters (?feeder - object ?eater - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?feeder)
        (tiny_stories__story_030_type_character ?eater)
        (and
          (tiny_stories__story_030_p_alive ?feeder)
          (tiny_stories__story_030_p_alive ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (tiny_stories__story_030_p_food-available)
        )
      )
    :effect
      (not (tiny_stories__story_030_p_hungry ?eater))
    :agents (?feeder)
  )

  (:action tiny_stories__story_030_a_eat
    :parameters (?eater - object ?eaten - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?eater)
        (tiny_stories__story_030_type_character ?eaten)
        (and
          (tiny_stories__story_030_p_alive ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (tiny_stories__story_030_p_alive ?eaten)
        )
      )
    :effect
      (not (tiny_stories__story_030_p_alive ?eaten))
    :agents (?eater)
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (shared_p_consensus_163c7ff70d35a80b ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (shared_p_consensus_163c7ff70d35a80b ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (shared_p_consensus_163c7ff70d35a80b ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_098_a_learn-to-sail
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_sailor ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?helper)
        (tiny_stories__story_098_type_character ?helpee)
        (not (= ?helper ?helpee))
      )
    :effect
      (shared_p_consensus_163c7ff70d35a80b ?helper ?helpee)
    :agents (?helper ?helpee)
  )

  (:action tiny_stories__story_098_a_sail-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character1)
        (tiny_stories__story_098_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_098_p_sailor ?character1)
          (tiny_stories__story_098_p_sailor ?character2)
        )
      )
    :effect
      (tiny_stories__story_098_p_together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_098_a_thank
    :parameters (?thanker - object ?thankee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?thanker)
        (tiny_stories__story_098_type_character ?thankee)
        (not (= ?thanker ?thankee))
      )
    :effect
      (tiny_stories__story_098_p_nice ?thanker)
    :agents (?thanker)
  )

  (:action writing_prompts__wp_091_a_forgive
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_feels-awful ?character)
          (not (writing_prompts__wp_091_p_forgiven ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_forgiven ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_learn
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_heartbroken ?character)
          (not (writing_prompts__wp_091_p_learned ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_learned ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_move-on
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_thinks-about-breakup ?character)
          (writing_prompts__wp_091_p_forgiven ?character)
          (writing_prompts__wp_091_p_learned ?character)
          (not (writing_prompts__wp_091_p_moved-on ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_moved-on ?character)
    :agents (?character)
  )
)
