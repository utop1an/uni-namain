(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_035_o_tim - object)
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
    (shared_p_consensus_64f1b89383f8f321 ?v0 - object ?v1 - object)
    (shared_p_consensus_9ce24643bf5b38bf ?v0 - object ?v1 - object)
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
    (tiny_stories__story_035_active)
    (tiny_stories__story_035_type_character ?x - object)
    (tiny_stories__story_035_type_object ?x - object)
    (tiny_stories__story_035_p_birthday ?v0 - object)
    (tiny_stories__story_035_p_box-closed)
    (tiny_stories__story_035_p_box-open)
    (tiny_stories__story_035_p_cake-spoiled)
    (tiny_stories__story_035_p_cake-good)
    (tiny_stories__story_035_p_listened-to-mom ?v0 - object)
    (tiny_stories__story_035_p_waited-for-birthday ?v0 - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (shared_p_consensus_8d4a8c2946b200a2 ?v0 - object)
    (writing_prompts__wp_042_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_drunk ?v0 - object)
    (writing_prompts__wp_042_p_night-show ?v0 - object)
    (writing_prompts__wp_042_p_vomit-stain ?v0 - object)
    (writing_prompts__wp_064_active)
    (writing_prompts__wp_064_type_character ?x - object)
    (writing_prompts__wp_064_type_item ?x - object)
    (writing_prompts__wp_064_type_object ?x - object)
    (writing_prompts__wp_064_type_place ?x - object)
    (writing_prompts__wp_064_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_064_p_delivered ?v0 - object)
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p1)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_64f1b89383f8f321 ?a ?p2)
        (not (shared_p_consensus_64f1b89383f8f321 ?a ?p1))
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
          (shared_p_consensus_64f1b89383f8f321 ?p ?p1)
          (shared_p_consensus_64f1b89383f8f321 ?a ?p1)
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
        (shared_p_consensus_64f1b89383f8f321 ?a ?p2)
        (not (shared_p_consensus_64f1b89383f8f321 ?a ?p1))
        (shared_p_consensus_64f1b89383f8f321 ?p ?p2)
        (not (shared_p_consensus_64f1b89383f8f321 ?p ?p1))
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
          (shared_p_consensus_64f1b89383f8f321 ?b ?p)
          (shared_p_consensus_9ce24643bf5b38bf ?b ?i)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_9ce24643bf5b38bf ?a ?i)
        (not (shared_p_consensus_9ce24643bf5b38bf ?b ?i))
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (shared_p_consensus_64f1b89383f8f321 ?b ?p)
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
          (shared_p_consensus_64f1b89383f8f321 ?b ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_alive ?b)
          (not (= ?a ?b))
          (shared_p_consensus_9ce24643bf5b38bf ?a ?i)
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (shared_p_consensus_64f1b89383f8f321 ?b ?p)
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
          (shared_p_consensus_64f1b89383f8f321 ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (shared_p_consensus_64f1b89383f8f321 ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (shared_p_consensus_9ce24643bf5b38bf ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action tiny_stories__story_035_a_wait-for-birthday
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_birthday ?character))
          (not (tiny_stories__story_035_p_waited-for-birthday ?character))
        )
      )
    :effect
      (tiny_stories__story_035_p_waited-for-birthday ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_listen-to-mom
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_listened-to-mom ?character))
          (tiny_stories__story_035_p_waited-for-birthday ?character)
        )
      )
    :effect
      (tiny_stories__story_035_p_listened-to-mom ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_open-box
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (tiny_stories__story_035_p_box-closed)
          (tiny_stories__story_035_p_birthday ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_box-closed))
        (tiny_stories__story_035_p_box-open)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_spoil-cake
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (not (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim))
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_cake-good))
        (tiny_stories__story_035_p_cake-spoiled)
      )
  )

  (:action tiny_stories__story_035_a_keep-cake-good
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim)
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (tiny_stories__story_035_p_cake-good)
  )

  (:action writing_prompts__wp_042_a_drink
    :parameters (?character - object ?drink - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_drink ?drink)
        (and
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (shared_p_consensus_9ce24643bf5b38bf ?character ?drink)
        )
      )
    :effect
      (and
        (writing_prompts__wp_042_p_drunk ?character)
        (not (shared_p_consensus_9ce24643bf5b38bf ?character ?drink))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (not (writing_prompts__wp_042_p_at ?character ?place))
        )
      )
    :effect
      (writing_prompts__wp_042_p_at ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_vomit
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (writing_prompts__wp_042_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_042_p_vomit-stain ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_sober-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_p_drunk ?character)
      )
    :effect
      (not (writing_prompts__wp_042_p_drunk ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_place ?from)
        (writing_prompts__wp_064_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (shared_p_consensus_64f1b89383f8f321 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_64f1b89383f8f321 ?character ?from))
        (shared_p_consensus_64f1b89383f8f321 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_deliver
    :parameters (?character - object ?item - object ?destination - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?destination)
        (and
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (shared_p_consensus_64f1b89383f8f321 ?character ?destination)
          (writing_prompts__wp_064_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_064_p_has ?character ?item))
        (writing_prompts__wp_064_p_delivered ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_064_a_pick-up
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_064_active)
        (writing_prompts__wp_064_type_character ?character)
        (writing_prompts__wp_064_type_item ?item)
        (writing_prompts__wp_064_type_place ?place)
        (and
          (shared_p_consensus_8d4a8c2946b200a2 ?character)
          (shared_p_consensus_64f1b89383f8f321 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_064_p_has ?character ?item)
    :agents (?character)
  )
)
