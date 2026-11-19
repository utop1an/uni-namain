(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :equality :intentionality :negative-preconditions :strips :typing)
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
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_at ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
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

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (human_62959785b3ec220a_p_at ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_at ?character ?from))
        (human_62959785b3ec220a_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (human_62959785b3ec220a_p_at ?interrogator ?location)
          (human_62959785b3ec220a_p_at ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (human_62959785b3ec220a_p_at ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (human_62959785b3ec220a_p_at ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (human_62959785b3ec220a_p_at ?saver ?location)
          (human_62959785b3ec220a_p_at ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (human_62959785b3ec220a_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
  )
)
