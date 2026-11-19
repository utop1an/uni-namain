(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants writing_prompts__wp_001_o_tv - object)
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
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (tiny_stories__story_077_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_077_p_happy ?v0 - object)
    (tiny_stories__story_077_p_tired ?v0 - object)
    (tiny_stories__story_077_p_played-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_001_active)
    (writing_prompts__wp_001_type_character ?x - object)
    (writing_prompts__wp_001_type_item ?x - object)
    (writing_prompts__wp_001_type_object ?x - object)
    (writing_prompts__wp_001_type_place ?x - object)
    (writing_prompts__wp_001_type_weapon ?x - object)
    (writing_prompts__wp_001_p_alive ?v0 - object)
    (writing_prompts__wp_001_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_001_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_001_p_on ?v0 - object)
    (writing_prompts__wp_001_p_broadcasting ?v0 - object)
    (writing_prompts__wp_001_p_generator-active ?v0 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_033_type_item ?x - object)
    (writing_prompts__wp_033_type_object ?x - object)
    (writing_prompts__wp_033_type_place ?x - object)
    (writing_prompts__wp_033_type_robot ?x - object)
    (writing_prompts__wp_033_type_weapon ?x - object)
    (writing_prompts__wp_033_p_alive ?v0 - object)
    (writing_prompts__wp_033_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_has-weapon ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_thrown ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_damaged ?v0 - object)
    (writing_prompts__wp_033_p_destroyed ?v0 - object)
    (writing_prompts__wp_033_p_revolution-started)
  )
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)) (writing_prompts__wp_001_p_generator-active ?place))) :implies (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv))
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv) (not (writing_prompts__wp_001_p_generator-active ?place)))) :implies (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))

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

  (:action tiny_stories__story_077_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_type_place ?from)
        (tiny_stories__story_077_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_077_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_077_p_at ?character ?from))
        (tiny_stories__story_077_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_077_a_play
    :parameters (?character1 - object ?character2 - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character1)
        (tiny_stories__story_077_type_character ?character2)
        (tiny_stories__story_077_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_077_p_at ?character1 ?place)
          (tiny_stories__story_077_p_at ?character2 ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_077_p_played-together ?character1 ?character2)
        (tiny_stories__story_077_p_happy ?character1)
        (tiny_stories__story_077_p_happy ?character2)
        (tiny_stories__story_077_p_tired ?character1)
        (tiny_stories__story_077_p_tired ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_077_a_rest
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_p_tired ?character)
      )
    :effect
      (not (tiny_stories__story_077_p_tired ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?from)
        (writing_prompts__wp_001_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_001_p_at ?character ?from))
        (writing_prompts__wp_001_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-on
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_has ?character ?item)
          (not (writing_prompts__wp_001_p_on ?item))
        )
      )
    :effect
      (writing_prompts__wp_001_p_on ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-off
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_has ?character ?item)
          (writing_prompts__wp_001_p_on ?item)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_on ?item))
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_start-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?place)
          (not (writing_prompts__wp_001_p_generator-active ?place))
        )
      )
    :effect
      (writing_prompts__wp_001_p_generator-active ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_stop-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (writing_prompts__wp_001_p_alive ?character)
          (writing_prompts__wp_001_p_at ?character ?place)
          (writing_prompts__wp_001_p_generator-active ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_generator-active ?place))
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )

  (:action writing_prompts__wp_033_a_move
    :parameters (?robot - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_type_place ?from)
        (writing_prompts__wp_033_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_033_p_alive ?robot)
          (writing_prompts__wp_033_p_at ?robot ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_at ?robot ?from))
        (writing_prompts__wp_033_p_at ?robot ?to)
      )
    :agents (?robot)
  )

  (:action writing_prompts__wp_033_a_throw-weapon
    :parameters (?thrower - object ?weapon - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?thrower)
        (writing_prompts__wp_033_type_weapon ?weapon)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?thrower)
          (writing_prompts__wp_033_p_has-weapon ?thrower ?weapon)
          (writing_prompts__wp_033_p_alive ?target)
        )
      )
    :effect
      (writing_prompts__wp_033_p_thrown ?weapon ?target)
    :agents (?thrower)
  )

  (:action writing_prompts__wp_033_a_damage
    :parameters (?damager - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?damager)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?damager)
          (writing_prompts__wp_033_p_alive ?target)
          (exists
            (?weapon - object)
            (and
              (writing_prompts__wp_033_type_weapon ?weapon)
              (writing_prompts__wp_033_p_thrown ?weapon ?target)
            )
          )
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_alive ?target))
        (writing_prompts__wp_033_p_damaged ?target)
      )
    :agents (?damager)
  )

  (:action writing_prompts__wp_033_a_destroy
    :parameters (?destroyer - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?destroyer)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?destroyer)
          (writing_prompts__wp_033_p_damaged ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_damaged ?target))
        (writing_prompts__wp_033_p_destroyed ?target)
      )
    :agents (?destroyer)
  )

  (:action writing_prompts__wp_033_a_start-revolution
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_p_alive ?robot)
      )
    :effect
      (writing_prompts__wp_033_p_revolution-started)
    :agents (?robot)
  )
)
