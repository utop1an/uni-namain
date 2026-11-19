(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_067_o_factory - object)
  (:predicates
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_030_p_hungry ?v0 - object)
    (tiny_stories__story_030_p_friend ?v0 - object ?v1 - object)
    (tiny_stories__story_030_p_alive ?v0 - object)
    (tiny_stories__story_030_p_food-available)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (tiny_stories__story_067_p_worker ?v0 - object)
    (tiny_stories__story_067_p_clean ?v0 - object)
    (tiny_stories__story_067_p_makes-toys ?v0 - object)
    (tiny_stories__story_067_p_nervous ?v0 - object)
    (tiny_stories__story_067_p_friends-with ?v0 - object ?v1 - object)
    (tiny_stories__story_067_p_happy ?v0 - object)
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (tiny_stories__story_078_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_078_p_alive ?v0 - object)
    (tiny_stories__story_078_p_happy ?v0 - object)
    (tiny_stories__story_078_p_amazed ?v0 - object)
    (tiny_stories__story_078_p_supports ?v0 - object ?v1 - object)
    (tiny_stories__story_078_p_persistent ?v0 - object)
    (tiny_stories__story_078_p_completed ?v0 - object)
    (writing_prompts__wp_092_active)
    (writing_prompts__wp_092_type_character ?x - object)
    (writing_prompts__wp_092_type_object ?x - object)
    (writing_prompts__wp_092_type_place ?x - object)
    (writing_prompts__wp_092_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_ready ?v0 - object)
    (writing_prompts__wp_092_p_has-lover ?v0 - object)
    (writing_prompts__wp_092_p_has-child ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_is-grandmother ?v0 - object)
    (writing_prompts__wp_092_p_is-ill ?v0 - object)
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

  (:action tiny_stories__story_067_a_start-working
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
      )
    :effect
      (tiny_stories__story_067_p_worker ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_clean-factory
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_clean tiny_stories__story_067_o_factory)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_make-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_makes-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character1)
        (tiny_stories__story_067_type_character ?character2)
        (and
          (tiny_stories__story_067_p_worker ?character1)
          (tiny_stories__story_067_p_worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_067_p_friends-with ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_067_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-less-nervous
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (and
          (tiny_stories__story_067_p_worker ?character)
          (tiny_stories__story_067_p_nervous ?character)
        )
      )
    :effect
      (not (tiny_stories__story_067_p_nervous ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_place ?from)
        (tiny_stories__story_078_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_078_p_alive ?character)
          (tiny_stories__story_078_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_078_p_at ?character ?from))
        (tiny_stories__story_078_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-amazed
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_amazed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_support-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_supports ?character ?project)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-persistent
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_persistent ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_complete-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (and
          (tiny_stories__story_078_p_alive ?character)
          (tiny_stories__story_078_p_supports ?character ?project)
          (tiny_stories__story_078_p_persistent ?character)
        )
      )
    :effect
      (tiny_stories__story_078_p_completed ?project)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_type_place ?from)
        (writing_prompts__wp_092_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_092_p_at ?character ?from)
          (writing_prompts__wp_092_p_ready ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_092_p_at ?character ?from))
        (writing_prompts__wp_092_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_get-ready
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_ready ?character))
      )
    :effect
      (writing_prompts__wp_092_p_ready ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-grandmother
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (and
          (not (writing_prompts__wp_092_p_is-grandmother ?character))
          (exists
            (?child - object)
            (and
              (writing_prompts__wp_092_type_character ?child)
              (writing_prompts__wp_092_p_has-child ?character ?child)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_092_p_is-grandmother ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-ill
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_is-ill ?character))
      )
    :effect
      (writing_prompts__wp_092_p_is-ill ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_recover
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_p_is-ill ?character)
      )
    :effect
      (not (writing_prompts__wp_092_p_is-ill ?character))
    :agents (?character)
  )
)
