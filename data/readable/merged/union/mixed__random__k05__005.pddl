(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants writing_prompts__wp_012_o_garage - object writing_prompts__wp_012_o_house - object)
  (:predicates
    (human_230a940d5d5977a6_active)
    (human_230a940d5d5977a6_type_actor ?x - object)
    (human_230a940d5d5977a6_type_allpolice ?x - object)
    (human_230a940d5d5977a6_type_car ?x - object)
    (human_230a940d5d5977a6_type_citizen ?x - object)
    (human_230a940d5d5977a6_type_crime ?x - object)
    (human_230a940d5d5977a6_type_detective ?x - object)
    (human_230a940d5d5977a6_type_inspector ?x - object)
    (human_230a940d5d5977a6_type_item ?x - object)
    (human_230a940d5d5977a6_type_motorbike ?x - object)
    (human_230a940d5d5977a6_type_object ?x - object)
    (human_230a940d5d5977a6_type_place ?x - object)
    (human_230a940d5d5977a6_type_police ?x - object)
    (human_230a940d5d5977a6_type_trafficcop ?x - object)
    (human_230a940d5d5977a6_type_vehicle ?x - object)
    (human_230a940d5d5977a6_p_arrester ?v0 - object)
    (human_230a940d5d5977a6_p_arrester-at ?v0 - object)
    (human_230a940d5d5977a6_p_at ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_has ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_alive ?v0 - object)
    (human_230a940d5d5977a6_p_under-arrest ?v0 - object)
    (human_230a940d5d5977a6_p_angry ?v0 - object)
    (human_230a940d5d5977a6_p_knows-clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_suspect ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_murder-clue ?v0 - object)
    (human_230a940d5d5977a6_p_clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_is-basketball-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-theft ?v0 - object)
    (human_230a940d5d5977a6_p_is-arrest-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-murder ?v0 - object)
    (human_230a940d5d5977a6_p_has-car ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_working ?v0 - object)
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_014_p_at-park ?v0 - object)
    (tiny_stories__story_014_p_on-swing ?v0 - object)
    (tiny_stories__story_014_p_swinging ?v0 - object)
    (tiny_stories__story_014_p_sharing ?v0 - object ?v1 - object)
    (tiny_stories__story_014_p_happy ?v0 - object)
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
    (tiny_stories__story_097_active)
    (tiny_stories__story_097_type_character ?x - object)
    (tiny_stories__story_097_type_object ?x - object)
    (tiny_stories__story_097_p_friend ?v0 - object ?v1 - object)
    (tiny_stories__story_097_p_happy ?v0 - object)
    (tiny_stories__story_097_p_sad ?v0 - object)
    (tiny_stories__story_097_p_ready ?v0 - object)
    (tiny_stories__story_097_p_practice ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_active)
    (writing_prompts__wp_012_type_character ?x - object)
    (writing_prompts__wp_012_type_object ?x - object)
    (writing_prompts__wp_012_type_robot ?x - object)
    (writing_prompts__wp_012_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_assembled ?v0 - object)
    (writing_prompts__wp_012_p_has-robot ?v0 - object ?v1 - object)
    (writing_prompts__wp_012_p_working-on-task ?v0 - object)
    (writing_prompts__wp_012_p_playing-game ?v0 - object)
  )

  (:action human_230a940d5d5977a6_a_travel
    :parameters (?a - object ?c - object ?p1 - object ?p2 - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_car ?c)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (and
          (human_230a940d5d5977a6_p_working ?c)
          (human_230a940d5d5977a6_p_at ?a ?p1)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_at ?a ?p2)
        (not (human_230a940d5d5977a6_p_at ?a ?p1))
        (when
          (human_230a940d5d5977a6_p_arrester ?a)
          (and
            (human_230a940d5d5977a6_p_arrester-at ?p2)
            (not (human_230a940d5d5977a6_p_arrester-at ?p1))
          )
        )
      )
  )

  (:action human_230a940d5d5977a6_a_arrest
    :parameters (?p - object ?a - object ?p1 - object ?p2 - object ?c - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?p)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (human_230a940d5d5977a6_type_crime ?c)
        (and
          (human_230a940d5d5977a6_p_at ?p ?p1)
          (human_230a940d5d5977a6_p_at ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (human_230a940d5d5977a6_p_alive ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_at ?a ?p2)
        (not (human_230a940d5d5977a6_p_at ?a ?p1))
        (human_230a940d5d5977a6_p_at ?p ?p2)
        (not (human_230a940d5d5977a6_p_at ?p ?p1))
        (human_230a940d5d5977a6_p_under-arrest ?a)
      )
  )

  (:action human_230a940d5d5977a6_a_steal
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_has ?b ?i)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_has ?a ?i)
        (not (human_230a940d5d5977a6_p_has ?b ?i))
        (human_230a940d5d5977a6_p_angry ?b)
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_play-basketball
    :parameters (?a - object ?b - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_is-basketball-place ?p)
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
          (not (= ?a ?b))
        )
      )
    :effect
      (and
        (not (human_230a940d5d5977a6_p_angry ?a))
        (not (human_230a940d5d5977a6_p_angry ?b))
      )
  )

  (:action human_230a940d5d5977a6_a_kill
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_alive ?b)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_has ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (human_230a940d5d5977a6_p_alive ?b))
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_findclues
    :parameters (?a - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_shareclues
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_police ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?b ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_suspect-of-crime
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (human_230a940d5d5977a6_p_has ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action tiny_stories__story_014_a_go-to-park
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (not (tiny_stories__story_014_p_at-park ?character))
      )
    :effect
      (tiny_stories__story_014_p_at-park ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_get-on-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_at-park ?character)
          (not (tiny_stories__story_014_p_on-swing ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_on-swing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_start-swinging
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (not (tiny_stories__story_014_p_swinging ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_swinging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_share-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_swinging ?character1)
          (tiny_stories__story_014_p_swinging ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_sharing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_014_a_get-off-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (tiny_stories__story_014_p_swinging ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_014_p_on-swing ?character))
        (not (tiny_stories__story_014_p_swinging ?character))
        (tiny_stories__story_014_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_thank
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_sharing ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_happy ?character1)
    :agents (?character1 ?character2)
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

  (:action tiny_stories__story_097_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_097_p_friend ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_097_a_cheer-up
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_097_p_friend ?character1 ?character2)
          (tiny_stories__story_097_p_sad ?character2)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_097_p_sad ?character2))
        (tiny_stories__story_097_p_happy ?character2)
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_097_a_help-practice
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_097_p_friend ?character1 ?character2)
          (not (tiny_stories__story_097_p_ready ?character2))
        )
      )
    :effect
      (tiny_stories__story_097_p_practice ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_097_a_become-ready
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character)
        (exists
          (?helper - object)
          (and
            (tiny_stories__story_097_type_character ?helper)
            (tiny_stories__story_097_p_practice ?helper ?character)
          )
        )
      )
    :effect
      (tiny_stories__story_097_p_ready ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_assemble
    :parameters (?character - object ?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_garage)
          (not (writing_prompts__wp_012_p_assembled ?robot))
        )
      )
    :effect
      (and
        (writing_prompts__wp_012_p_assembled ?robot)
        (writing_prompts__wp_012_p_has-robot ?character ?robot)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_start-task
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_robot ?robot)
        (and
          (writing_prompts__wp_012_p_assembled ?robot)
          (not (writing_prompts__wp_012_p_working-on-task ?robot))
        )
      )
    :effect
      (writing_prompts__wp_012_p_working-on-task ?robot)
    :agents (?robot)
  )

  (:action writing_prompts__wp_012_a_play-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (and
          (writing_prompts__wp_012_p_at ?character writing_prompts__wp_012_o_house)
          (not (writing_prompts__wp_012_p_playing-game ?character))
        )
      )
    :effect
      (writing_prompts__wp_012_p_playing-game ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_012_a_stop-game
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_012_active)
        (writing_prompts__wp_012_type_character ?character)
        (writing_prompts__wp_012_p_playing-game ?character)
      )
    :effect
      (not (writing_prompts__wp_012_p_playing-game ?character))
    :agents (?character)
  )
)
