(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:constants human_8fa5775aae174731_o_ark - object)
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
    (shared_p_consensus_d124bfab1514147b ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_has ?v0 - object ?v1 - object)
    (shared_p_consensus_693fff8e2de0e463 ?v0 - object)
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
    (human_3cd8b87ba572801b_active)
    (human_3cd8b87ba572801b_type_aristocrat ?x - object)
    (human_3cd8b87ba572801b_type_canmarry ?x - object)
    (human_3cd8b87ba572801b_type_character ?x - object)
    (human_3cd8b87ba572801b_type_dragon ?x - object)
    (human_3cd8b87ba572801b_type_emperor ?x - object)
    (human_3cd8b87ba572801b_type_female ?x - object)
    (human_3cd8b87ba572801b_type_genie ?x - object)
    (human_3cd8b87ba572801b_type_ismagic ?x - object)
    (human_3cd8b87ba572801b_type_king ?x - object)
    (human_3cd8b87ba572801b_type_knight ?x - object)
    (human_3cd8b87ba572801b_type_location ?x - object)
    (human_3cd8b87ba572801b_type_lord ?x - object)
    (human_3cd8b87ba572801b_type_male ?x - object)
    (human_3cd8b87ba572801b_type_monarch ?x - object)
    (human_3cd8b87ba572801b_type_monster ?x - object)
    (human_3cd8b87ba572801b_type_object ?x - object)
    (human_3cd8b87ba572801b_type_person ?x - object)
    (human_3cd8b87ba572801b_type_princess ?x - object)
    (human_3cd8b87ba572801b_type_spirit ?x - object)
    (human_3cd8b87ba572801b_type_thing ?x - object)
    (human_3cd8b87ba572801b_type_zombie ?x - object)
    (human_3cd8b87ba572801b_p_bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_bachelor-loves ?v0 - object)
    (human_3cd8b87ba572801b_p_loves-bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_magic-char ?v0 - object)
    (human_3cd8b87ba572801b_p_controls-magic ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_magic-char-alive)
    (human_3cd8b87ba572801b_p_scary ?v0 - object)
    (human_3cd8b87ba572801b_p_single ?v0 - object)
    (human_3cd8b87ba572801b_p_beautiful ?v0 - object)
    (human_3cd8b87ba572801b_p_magic ?v0 - object)
    (human_3cd8b87ba572801b_p_controls ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_married-to ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loves ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loyal-to ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (shared_p_consensus_4784f8fc5e9bc617 ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (shared_p_consensus_90c519e56ea594ba ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (shared_p_consensus_dd2c0566f92bc4a5 ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (human_8fa5775aae174731_active)
    (human_8fa5775aae174731_type_character ?x - object)
    (human_8fa5775aae174731_type_item ?x - object)
    (human_8fa5775aae174731_type_object ?x - object)
    (human_8fa5775aae174731_type_place ?x - object)
    (human_8fa5775aae174731_type_weapon ?x - object)
    (human_8fa5775aae174731_p_open ?v0 - object)
    (human_8fa5775aae174731_p_armed ?v0 - object)
    (human_8fa5775aae174731_p_burried ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_p_knows-location ?v0 - object ?v1 - object ?v2 - object)
  )
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (not (human_8fa5775aae174731_p_armed ?character)) (exists (?w - object) (and (human_8fa5775aae174731_type_weapon ?w) (shared_p_consensus_4784f8fc5e9bc617 ?character ?w))))) :implies (human_8fa5775aae174731_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (human_8fa5775aae174731_p_armed ?character) (forall (?w - object) (or (not (human_8fa5775aae174731_type_weapon ?w)) (not (shared_p_consensus_4784f8fc5e9bc617 ?character ?w)))))) :implies (not (human_8fa5775aae174731_p_armed ?character)))

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
          (shared_p_consensus_d124bfab1514147b ?a ?p1)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?a ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?a ?p1))
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
          (shared_p_consensus_d124bfab1514147b ?p ?p1)
          (shared_p_consensus_d124bfab1514147b ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (shared_p_consensus_693fff8e2de0e463 ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?a ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?a ?p1))
        (shared_p_consensus_d124bfab1514147b ?p ?p2)
        (not (shared_p_consensus_d124bfab1514147b ?p ?p1))
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (human_230a940d5d5977a6_p_has ?b ?i)
          (not (= ?a ?b))
          (shared_p_consensus_693fff8e2de0e463 ?a)
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_693fff8e2de0e463 ?b)
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (shared_p_consensus_693fff8e2de0e463 ?b)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_has ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_693fff8e2de0e463 ?b))
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_693fff8e2de0e463 ?b)
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
          (shared_p_consensus_d124bfab1514147b ?a ?p)
          (shared_p_consensus_693fff8e2de0e463 ?a)
          (shared_p_consensus_d124bfab1514147b ?b ?p)
          (shared_p_consensus_693fff8e2de0e463 ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (human_230a940d5d5977a6_p_has ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action human_3cd8b87ba572801b_a_travel
    :parameters (?traveller - object ?from - object ?to - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?traveller)
        (human_3cd8b87ba572801b_type_location ?from)
        (human_3cd8b87ba572801b_type_location ?to)
        (and
          (shared_p_consensus_d124bfab1514147b ?traveller ?from)
          (shared_p_consensus_693fff8e2de0e463 ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?traveller ?to)
        (not (shared_p_consensus_d124bfab1514147b ?traveller ?from))
      )
  )

  (:action human_3cd8b87ba572801b_a_slay
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?slayer ?place)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_693fff8e2de0e463 ?slayer)
          (shared_p_consensus_693fff8e2de0e463 ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (shared_p_consensus_693fff8e2de0e463 ?m))
  )

  (:action human_3cd8b87ba572801b_a_slay-magic-char
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?slayer ?place)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_693fff8e2de0e463 ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (shared_p_consensus_693fff8e2de0e463 ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_693fff8e2de0e463 ?m))
        (human_3cd8b87ba572801b_p_magic-char ?m)
        (not (human_3cd8b87ba572801b_p_magic-char-alive))
      )
  )

  (:action human_3cd8b87ba572801b_a_pillage
    :parameters (?pillager - object ?body - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?pillager)
        (human_3cd8b87ba572801b_type_character ?body)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_d124bfab1514147b ?pillager ?place)
          (shared_p_consensus_d124bfab1514147b ?body ?place)
          (shared_p_consensus_693fff8e2de0e463 ?pillager)
          (not (shared_p_consensus_693fff8e2de0e463 ?body))
          (shared_p_consensus_4784f8fc5e9bc617 ?body ?t)
          (not (shared_p_consensus_4784f8fc5e9bc617 ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (shared_p_consensus_4784f8fc5e9bc617 ?pillager ?t)
        (not (shared_p_consensus_4784f8fc5e9bc617 ?body ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_give
    :parameters (?giver - object ?givee - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?giver)
        (human_3cd8b87ba572801b_type_character ?givee)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (not (= ?giver ?givee))
          (shared_p_consensus_d124bfab1514147b ?giver ?place)
          (shared_p_consensus_d124bfab1514147b ?givee ?place)
          (shared_p_consensus_693fff8e2de0e463 ?givee)
          (shared_p_consensus_693fff8e2de0e463 ?giver)
          (shared_p_consensus_4784f8fc5e9bc617 ?giver ?t)
          (not (shared_p_consensus_4784f8fc5e9bc617 ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (shared_p_consensus_4784f8fc5e9bc617 ?givee ?t)
        (not (shared_p_consensus_4784f8fc5e9bc617 ?giver ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_summon
    :parameters (?char - object ?g - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_ismagic ?g)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_confined ?g)
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (shared_p_consensus_4784f8fc5e9bc617 ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (shared_p_consensus_693fff8e2de0e463 ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_d124bfab1514147b ?g ?place)
        (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
        (human_3cd8b87ba572801b_p_controls-magic ?char ?lamp)
        (not (human_3cd8b87ba572801b_p_in ?g ?lamp))
        (not (human_3cd8b87ba572801b_p_confined ?g))
      )
  )

  (:action human_3cd8b87ba572801b_a_love-spell
    :parameters (?g - object ?target - object ?lover - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?target)
        (human_3cd8b87ba572801b_type_canmarry ?lover)
        (and
          (not (human_3cd8b87ba572801b_p_confined ?g))
          (not (human_3cd8b87ba572801b_p_loves ?target ?lover))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_693fff8e2de0e463 ?target)
          (shared_p_consensus_693fff8e2de0e463 ?lover)
          (not (= ?g ?target))
          (not (= ?g ?lover))
          (not (= ?target ?lover))
          (human_3cd8b87ba572801b_p_intends-loves ?g ?target ?lover)
          (human_3cd8b87ba572801b_p_bachelor ?lover)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?target ?lover)
        (human_3cd8b87ba572801b_p_loves-bachelor ?target)
      )
  )

  (:action human_3cd8b87ba572801b_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?groom)
        (human_3cd8b87ba572801b_type_person ?bride)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_693fff8e2de0e463 ?groom)
          (shared_p_consensus_693fff8e2de0e463 ?bride)
          (shared_p_consensus_d124bfab1514147b ?groom ?place)
          (shared_p_consensus_d124bfab1514147b ?bride ?place)
          (human_3cd8b87ba572801b_p_loves ?groom ?bride)
          (human_3cd8b87ba572801b_p_loves ?bride ?groom)
          (human_3cd8b87ba572801b_p_single ?groom)
          (human_3cd8b87ba572801b_p_bachelor ?groom)
          (human_3cd8b87ba572801b_p_single ?bride)
          (not (= ?groom ?bride))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_married-to ?groom ?bride)
        (human_3cd8b87ba572801b_p_married-to ?bride ?groom)
        (not (human_3cd8b87ba572801b_p_single ?groom))
        (not (human_3cd8b87ba572801b_p_single ?bride))
      )
  )

  (:action human_3cd8b87ba572801b_a_fall-in-love
    :parameters (?m - object ?f - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?m)
        (human_3cd8b87ba572801b_type_female ?f)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_bachelor ?m)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_d124bfab1514147b ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (shared_p_consensus_693fff8e2de0e463 ?m)
          (shared_p_consensus_693fff8e2de0e463 ?f)
          (not (human_3cd8b87ba572801b_p_loves ?m ?f))
          (human_3cd8b87ba572801b_p_beautiful ?f)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?m ?f)
        (human_3cd8b87ba572801b_p_bachelor-loves ?f)
      )
  )

  (:action human_3cd8b87ba572801b_a_order
    :parameters (?ki - object ?kn - object ?place - object ?t - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_king ?ki)
        (human_3cd8b87ba572801b_type_knight ?kn)
        (human_3cd8b87ba572801b_type_location ?place)
        (human_3cd8b87ba572801b_type_thing ?t)
        (and
          (human_3cd8b87ba572801b_p_loyal-to ?kn ?ki)
          (shared_p_consensus_693fff8e2de0e463 ?kn)
          (shared_p_consensus_693fff8e2de0e463 ?ki)
          (shared_p_consensus_d124bfab1514147b ?ki ?place)
          (shared_p_consensus_d124bfab1514147b ?kn ?place)
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-has ?kn ?ki ?t)
  )

  (:action human_3cd8b87ba572801b_a_appear-threatening
    :parameters (?m - object ?char - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_693fff8e2de0e463 ?m)
          (shared_p_consensus_693fff8e2de0e463 ?char)
          (shared_p_consensus_d124bfab1514147b ?m ?place)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (human_3cd8b87ba572801b_p_scary ?m)
          (not (= ?m ?char))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-not-alive ?char ?m)
  )

  (:action human_3cd8b87ba572801b_a_command
    :parameters (?char - object ?g - object ?love - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?love)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (shared_p_consensus_4784f8fc5e9bc617 ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (shared_p_consensus_693fff8e2de0e463 ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_693fff8e2de0e463 ?love)
          (shared_p_consensus_d124bfab1514147b ?char ?place)
          (shared_p_consensus_d124bfab1514147b ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (shared_p_consensus_90c519e56ea594ba ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_90c519e56ea594ba ?character ?from))
        (shared_p_consensus_90c519e56ea594ba ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (shared_p_consensus_90c519e56ea594ba ?interrogator ?location)
          (shared_p_consensus_90c519e56ea594ba ?interrogated ?location)
          (human_87bbd0acdf4611c5_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_87bbd0acdf4611c5_p_knows ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (human_87bbd0acdf4611c5_p_henchman ?placer)
          (human_87bbd0acdf4611c5_p_has ?placer ?victim)
          (shared_p_consensus_90c519e56ea594ba ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (shared_p_consensus_90c519e56ea594ba ?victim ?placed)
        (human_87bbd0acdf4611c5_p_captured ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (shared_p_consensus_90c519e56ea594ba ?saver ?location)
          (shared_p_consensus_90c519e56ea594ba ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (shared_p_consensus_90c519e56ea594ba ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (shared_p_consensus_dd2c0566f92bc4a5 ?notsaved))
      )
  )

  (:action human_8fa5775aae174731_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_place ?from)
        (human_8fa5775aae174731_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_dd2c0566f92bc4a5 ?character)
          (shared_p_consensus_90c519e56ea594ba ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_90c519e56ea594ba ?character ?from))
        (shared_p_consensus_90c519e56ea594ba ?character ?to)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_excavate
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (shared_p_consensus_dd2c0566f92bc4a5 ?character)
          (shared_p_consensus_90c519e56ea594ba ?character ?place)
          (human_8fa5775aae174731_p_burried ?item ?place)
          (human_8fa5775aae174731_p_knows-location ?character ?item ?place)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_burried ?item ?place))
        (shared_p_consensus_4784f8fc5e9bc617 ?character ?item)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?giver)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?receiver)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_dd2c0566f92bc4a5 ?giver)
          (shared_p_consensus_90c519e56ea594ba ?giver ?place)
          (shared_p_consensus_4784f8fc5e9bc617 ?giver ?item)
          (shared_p_consensus_dd2c0566f92bc4a5 ?receiver)
          (shared_p_consensus_90c519e56ea594ba ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4784f8fc5e9bc617 ?giver ?item))
        (shared_p_consensus_4784f8fc5e9bc617 ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action human_8fa5775aae174731_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?killer)
        (human_8fa5775aae174731_type_weapon ?weapon)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (shared_p_consensus_dd2c0566f92bc4a5 ?killer)
          (shared_p_consensus_90c519e56ea594ba ?killer ?place)
          (shared_p_consensus_4784f8fc5e9bc617 ?killer ?weapon)
          (shared_p_consensus_dd2c0566f92bc4a5 ?victim)
          (shared_p_consensus_90c519e56ea594ba ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_dd2c0566f92bc4a5 ?victim))
    :agents (?killer)
  )

  (:action human_8fa5775aae174731_a_take
    :parameters (?taker - object ?item - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?taker)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?taker ?victim))
          (shared_p_consensus_dd2c0566f92bc4a5 ?taker)
          (shared_p_consensus_90c519e56ea594ba ?taker ?place)
          (or
            (not (shared_p_consensus_dd2c0566f92bc4a5 ?victim))
            (and
              (human_8fa5775aae174731_p_armed ?taker)
              (not (human_8fa5775aae174731_p_armed ?victim))
            )
          )
          (shared_p_consensus_90c519e56ea594ba ?victim ?place)
          (shared_p_consensus_4784f8fc5e9bc617 ?victim ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_4784f8fc5e9bc617 ?victim ?item))
        (shared_p_consensus_4784f8fc5e9bc617 ?taker ?item)
      )
    :agents (?taker)
  )

  (:action human_8fa5775aae174731_a_open-ark
    :parameters (?character - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (and
          (shared_p_consensus_dd2c0566f92bc4a5 ?character)
          (shared_p_consensus_4784f8fc5e9bc617 ?character human_8fa5775aae174731_o_ark)
        )
      )
    :effect
      (and
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
        (not (shared_p_consensus_dd2c0566f92bc4a5 ?character))
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_close-ark
    :parameters ()
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
      )
    :effect
      (not (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark))
  )
)
