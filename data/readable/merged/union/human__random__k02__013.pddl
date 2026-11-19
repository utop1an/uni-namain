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
    (human_3cd8b87ba572801b_p_at ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_has ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (human_3cd8b87ba572801b_p_alive ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
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

  (:action human_3cd8b87ba572801b_a_travel
    :parameters (?traveller - object ?from - object ?to - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?traveller)
        (human_3cd8b87ba572801b_type_location ?from)
        (human_3cd8b87ba572801b_type_location ?to)
        (and
          (human_3cd8b87ba572801b_p_at ?traveller ?from)
          (human_3cd8b87ba572801b_p_alive ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_at ?traveller ?to)
        (not (human_3cd8b87ba572801b_p_at ?traveller ?from))
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
          (human_3cd8b87ba572801b_p_at ?slayer ?place)
          (human_3cd8b87ba572801b_p_at ?m ?place)
          (human_3cd8b87ba572801b_p_alive ?slayer)
          (human_3cd8b87ba572801b_p_alive ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (human_3cd8b87ba572801b_p_alive ?m))
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
          (human_3cd8b87ba572801b_p_at ?slayer ?place)
          (human_3cd8b87ba572801b_p_at ?m ?place)
          (human_3cd8b87ba572801b_p_alive ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (human_3cd8b87ba572801b_p_alive ?m))
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
          (human_3cd8b87ba572801b_p_at ?pillager ?place)
          (human_3cd8b87ba572801b_p_at ?body ?place)
          (human_3cd8b87ba572801b_p_alive ?pillager)
          (not (human_3cd8b87ba572801b_p_alive ?body))
          (human_3cd8b87ba572801b_p_has ?body ?t)
          (not (human_3cd8b87ba572801b_p_has ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?pillager ?t)
        (not (human_3cd8b87ba572801b_p_has ?body ?t))
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
          (human_3cd8b87ba572801b_p_at ?giver ?place)
          (human_3cd8b87ba572801b_p_at ?givee ?place)
          (human_3cd8b87ba572801b_p_alive ?givee)
          (human_3cd8b87ba572801b_p_alive ?giver)
          (human_3cd8b87ba572801b_p_has ?giver ?t)
          (not (human_3cd8b87ba572801b_p_has ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?givee ?t)
        (not (human_3cd8b87ba572801b_p_has ?giver ?t))
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
          (human_3cd8b87ba572801b_p_at ?char ?place)
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (human_3cd8b87ba572801b_p_alive ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_at ?g ?place)
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
          (human_3cd8b87ba572801b_p_alive ?target)
          (human_3cd8b87ba572801b_p_alive ?lover)
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
          (human_3cd8b87ba572801b_p_alive ?groom)
          (human_3cd8b87ba572801b_p_alive ?bride)
          (human_3cd8b87ba572801b_p_at ?groom ?place)
          (human_3cd8b87ba572801b_p_at ?bride ?place)
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
          (human_3cd8b87ba572801b_p_at ?m ?place)
          (human_3cd8b87ba572801b_p_at ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_alive ?f)
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
          (human_3cd8b87ba572801b_p_alive ?kn)
          (human_3cd8b87ba572801b_p_alive ?ki)
          (human_3cd8b87ba572801b_p_at ?ki ?place)
          (human_3cd8b87ba572801b_p_at ?kn ?place)
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
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_alive ?char)
          (human_3cd8b87ba572801b_p_at ?m ?place)
          (human_3cd8b87ba572801b_p_at ?char ?place)
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
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (human_3cd8b87ba572801b_p_alive ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (human_3cd8b87ba572801b_p_alive ?love)
          (human_3cd8b87ba572801b_p_at ?char ?place)
          (human_3cd8b87ba572801b_p_at ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )
)
