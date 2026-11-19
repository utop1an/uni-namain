(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
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
    (shared_p_consensus_396f45c78ed695d2 ?v0 - object ?v1 - object)
    (shared_p_consensus_c35cff3030492547 ?v0 - object ?v1 - object)
    (shared_p_consensus_59ce20d25d4fa378 ?v0 - object)
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
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (tiny_stories__story_022_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_foggy ?v0 - object)
    (tiny_stories__story_022_p_found ?v0 - object)
    (tiny_stories__story_022_p_happy ?v0 - object)
    (tiny_stories__story_022_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_029_active)
    (tiny_stories__story_029_type_character ?x - object)
    (tiny_stories__story_029_type_item ?x - object)
    (tiny_stories__story_029_type_object ?x - object)
    (tiny_stories__story_029_type_place ?x - object)
    (tiny_stories__story_029_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_near ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_in-nest ?v0 - object)
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p1)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_396f45c78ed695d2 ?a ?p2)
        (not (shared_p_consensus_396f45c78ed695d2 ?a ?p1))
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
          (shared_p_consensus_396f45c78ed695d2 ?p ?p1)
          (shared_p_consensus_396f45c78ed695d2 ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (shared_p_consensus_59ce20d25d4fa378 ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (shared_p_consensus_396f45c78ed695d2 ?a ?p2)
        (not (shared_p_consensus_396f45c78ed695d2 ?a ?p1))
        (shared_p_consensus_396f45c78ed695d2 ?p ?p2)
        (not (shared_p_consensus_396f45c78ed695d2 ?p ?p1))
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_396f45c78ed695d2 ?b ?p)
          (shared_p_consensus_c35cff3030492547 ?b ?i)
          (not (= ?a ?b))
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_c35cff3030492547 ?a ?i)
        (not (shared_p_consensus_c35cff3030492547 ?b ?i))
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (shared_p_consensus_396f45c78ed695d2 ?b ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?b)
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_396f45c78ed695d2 ?b ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (shared_p_consensus_59ce20d25d4fa378 ?b)
          (not (= ?a ?b))
          (shared_p_consensus_c35cff3030492547 ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_59ce20d25d4fa378 ?b))
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (shared_p_consensus_396f45c78ed695d2 ?b ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?b)
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
          (shared_p_consensus_396f45c78ed695d2 ?a ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?a)
          (shared_p_consensus_396f45c78ed695d2 ?b ?p)
          (shared_p_consensus_59ce20d25d4fa378 ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (shared_p_consensus_c35cff3030492547 ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action tiny_stories__story_022_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_place ?from)
        (tiny_stories__story_022_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_396f45c78ed695d2 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_396f45c78ed695d2 ?character ?from))
        (shared_p_consensus_396f45c78ed695d2 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_search
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_item ?item)
        (tiny_stories__story_022_type_place ?place)
        (and
          (shared_p_consensus_396f45c78ed695d2 ?character ?place)
          (not (tiny_stories__story_022_p_found ?item))
        )
      )
    :effect
      (when
        (not (tiny_stories__story_022_p_foggy ?place))
        (and
          (tiny_stories__story_022_p_found ?item)
          (tiny_stories__story_022_p_has ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character1)
        (tiny_stories__story_022_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_022_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_022_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
      )
    :effect
      (tiny_stories__story_022_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_clear-fog
    :parameters (?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_place ?place)
        (tiny_stories__story_022_p_foggy ?place)
      )
    :effect
      (not (tiny_stories__story_022_p_foggy ?place))
  )

  (:action tiny_stories__story_029_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_place ?from)
        (tiny_stories__story_029_type_place ?to)
        (and
          (shared_p_consensus_59ce20d25d4fa378 ?character)
          (tiny_stories__story_029_p_at ?character ?from)
          (not (tiny_stories__story_029_p_at ?character ?to))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_029_p_at ?character ?from))
        (tiny_stories__story_029_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (shared_p_consensus_59ce20d25d4fa378 ?character)
          (shared_p_consensus_c35cff3030492547 ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_pick-up
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (shared_p_consensus_59ce20d25d4fa378 ?character)
          (tiny_stories__story_029_p_near ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_c35cff3030492547 ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_help-bird
    :parameters (?character - object ?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (shared_p_consensus_59ce20d25d4fa378 ?character)
          (shared_p_consensus_59ce20d25d4fa378 ?bird)
          (not (tiny_stories__story_029_p_in-nest ?bird))
        )
      )
    :effect
      (tiny_stories__story_029_p_in-nest ?bird)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_bird-falls
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (shared_p_consensus_59ce20d25d4fa378 ?bird)
          (tiny_stories__story_029_p_in-nest ?bird)
        )
      )
    :effect
      (not (tiny_stories__story_029_p_in-nest ?bird))
  )
)
