(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants human_662247ec644ef452_o_jailhouse - object human_662247ec644ef452_o_snakebite - object)
  (:predicates
    (human_281c51d26d5d4ff3_active)
    (human_281c51d26d5d4ff3_type_allworker ?x - object)
    (human_281c51d26d5d4ff3_type_axe ?x - object)
    (human_281c51d26d5d4ff3_type_beast ?x - object)
    (human_281c51d26d5d4ff3_type_blacksmith ?x - object)
    (human_281c51d26d5d4ff3_type_cake ?x - object)
    (human_281c51d26d5d4ff3_type_character ?x - object)
    (human_281c51d26d5d4ff3_type_fox ?x - object)
    (human_281c51d26d5d4ff3_type_girl ?x - object)
    (human_281c51d26d5d4ff3_type_grandmother ?x - object)
    (human_281c51d26d5d4ff3_type_house ?x - object)
    (human_281c51d26d5d4ff3_type_human ?x - object)
    (human_281c51d26d5d4ff3_type_hunter ?x - object)
    (human_281c51d26d5d4ff3_type_object ?x - object)
    (human_281c51d26d5d4ff3_type_thing ?x - object)
    (human_281c51d26d5d4ff3_type_wolf ?x - object)
    (human_281c51d26d5d4ff3_type_worker ?x - object)
    (human_281c51d26d5d4ff3_p_monster ?v0 - object)
    (human_281c51d26d5d4ff3_p_monster-alive)
    (human_281c51d26d5d4ff3_p_rescuer ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescuer-at ?v0 - object)
    (shared_p_consensus_37a155841f4f2b9a ?v0 - object)
    (shared_p_consensus_bcef17e13588288d ?v0 - object ?v1 - object)
    (human_281c51d26d5d4ff3_p_eaten ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescued ?v0 - object)
    (shared_p_consensus_c610f9b0c65c4262 ?v0 - object ?v1 - object)
    (human_662247ec644ef452_active)
    (human_662247ec644ef452_type_animal ?x - object)
    (human_662247ec644ef452_type_item ?x - object)
    (human_662247ec644ef452_type_living ?x - object)
    (human_662247ec644ef452_type_object ?x - object)
    (human_662247ec644ef452_type_person ?x - object)
    (human_662247ec644ef452_type_place ?x - object)
    (human_662247ec644ef452_type_sickness ?x - object)
    (human_662247ec644ef452_type_valuable ?x - object)
    (human_662247ec644ef452_p_free ?v0 - object)
    (human_662247ec644ef452_p_sheriff ?v0 - object)
    (human_662247ec644ef452_p_belongsto ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_sick ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_cures ?v0 - object ?v1 - object)
    (human_662247ec644ef452_p_loves ?v0 - object ?v1 - object)
  )

  (:action human_281c51d26d5d4ff3_a_walk
    :parameters (?c - object ?h1 - object ?h2 - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_character ?c)
        (human_281c51d26d5d4ff3_type_house ?h1)
        (human_281c51d26d5d4ff3_type_house ?h2)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?c)
          (shared_p_consensus_c610f9b0c65c4262 ?c ?h1)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c610f9b0c65c4262 ?c ?h1))
        (shared_p_consensus_c610f9b0c65c4262 ?c ?h2)
        (when
          (human_281c51d26d5d4ff3_p_rescuer ?c)
          (and
            (human_281c51d26d5d4ff3_p_rescuer-at ?h2)
            (not (human_281c51d26d5d4ff3_p_rescuer-at ?h1))
          )
        )
      )
  )

  (:action human_281c51d26d5d4ff3_a_eat
    :parameters (?m - object ?c - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?m)
          (shared_p_consensus_37a155841f4f2b9a ?c)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
          (shared_p_consensus_c610f9b0c65c4262 ?m ?h)
          (shared_p_consensus_c610f9b0c65c4262 ?c ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
        )
      )
    :effect
      (human_281c51d26d5d4ff3_p_eaten ?c)
  )

  (:action human_281c51d26d5d4ff3_a_kill
    :parameters (?c - object ?m - object ?a - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_worker ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_axe ?a)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?c)
          (shared_p_consensus_37a155841f4f2b9a ?m)
          (shared_p_consensus_bcef17e13588288d ?c ?a)
          (shared_p_consensus_c610f9b0c65c4262 ?c ?h)
          (shared_p_consensus_c610f9b0c65c4262 ?m ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
          (human_281c51d26d5d4ff3_p_monster-alive)
          (human_281c51d26d5d4ff3_p_rescuer ?c)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_37a155841f4f2b9a ?m))
        (not (human_281c51d26d5d4ff3_p_monster-alive))
      )
  )

  (:action human_281c51d26d5d4ff3_a_escape
    :parameters (?c - object ?m - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_eaten ?c)
          (not (shared_p_consensus_37a155841f4f2b9a ?m))
          (shared_p_consensus_c610f9b0c65c4262 ?m ?h)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_eaten ?c))
        (human_281c51d26d5d4ff3_p_rescued ?c)
        (shared_p_consensus_c610f9b0c65c4262 ?c ?h)
      )
  )

  (:action human_281c51d26d5d4ff3_a_give
    :parameters (?c1 - object ?c2 - object ?t - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c1)
        (human_281c51d26d5d4ff3_type_human ?c2)
        (human_281c51d26d5d4ff3_type_thing ?t)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (not (human_281c51d26d5d4ff3_p_eaten ?c2))
          (shared_p_consensus_37a155841f4f2b9a ?c1)
          (shared_p_consensus_37a155841f4f2b9a ?c2)
          (shared_p_consensus_bcef17e13588288d ?c1 ?t)
          (shared_p_consensus_c610f9b0c65c4262 ?c1 ?h)
          (shared_p_consensus_c610f9b0c65c4262 ?c2 ?h)
        )
      )
    :effect
      (and
        (shared_p_consensus_bcef17e13588288d ?c2 ?t)
        (not (shared_p_consensus_bcef17e13588288d ?c1 ?t))
      )
  )

  (:action human_662247ec644ef452_a_snakebite
    :parameters (?victim - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?victim)
        (shared_p_consensus_37a155841f4f2b9a ?victim)
      )
    :effect
      (and
        (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)
        (intends ?victim (not (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)))
        (forall
          (?p - object)
          (when
            (and
              (human_662247ec644ef452_type_person ?p)
              (human_662247ec644ef452_p_loves ?p ?victim)
            )
            (intends ?p (not (human_662247ec644ef452_p_sick ?victim human_662247ec644ef452_o_snakebite)))
          )
        )
      )
  )

  (:action human_662247ec644ef452_a_die
    :parameters (?person - object ?sickness - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_sickness ?sickness)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?person)
          (human_662247ec644ef452_p_sick ?person ?sickness)
        )
      )
    :effect
      (not (shared_p_consensus_37a155841f4f2b9a ?person))
  )

  (:action human_662247ec644ef452_a_travel
    :parameters (?person - object ?from - object ?to - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_place ?from)
        (human_662247ec644ef452_type_place ?to)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_c610f9b0c65c4262 ?person ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_c610f9b0c65c4262 ?person ?to)
        (not (shared_p_consensus_c610f9b0c65c4262 ?person ?from))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_forcetravel
    :parameters (?person - object ?victim - object ?from - object ?to - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?from)
        (human_662247ec644ef452_type_place ?to)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_c610f9b0c65c4262 ?person ?from)
          (shared_p_consensus_37a155841f4f2b9a ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_c610f9b0c65c4262 ?victim ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_c610f9b0c65c4262 ?person ?to)
        (not (shared_p_consensus_c610f9b0c65c4262 ?person ?from))
        (shared_p_consensus_c610f9b0c65c4262 ?victim ?to)
        (not (shared_p_consensus_c610f9b0c65c4262 ?victim ?from))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_give
    :parameters (?giver - object ?receiver - object ?item - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?giver)
        (human_662247ec644ef452_type_person ?receiver)
        (human_662247ec644ef452_type_item ?item)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?giver)
          (human_662247ec644ef452_p_free ?giver)
          (shared_p_consensus_c610f9b0c65c4262 ?giver ?place)
          (shared_p_consensus_bcef17e13588288d ?giver ?item)
          (shared_p_consensus_37a155841f4f2b9a ?receiver)
          (human_662247ec644ef452_p_free ?receiver)
          (shared_p_consensus_c610f9b0c65c4262 ?receiver ?place)
        )
      )
    :effect
      (and
        (shared_p_consensus_bcef17e13588288d ?receiver ?item)
        (not (shared_p_consensus_bcef17e13588288d ?giver ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?giver)
          (human_662247ec644ef452_p_belongsto ?item ?receiver)
        )
      )
    :agents (?giver ?receiver)
  )

  (:action human_662247ec644ef452_a_tieup
    :parameters (?person - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_c610f9b0c65c4262 ?person ?place)
          (shared_p_consensus_37a155841f4f2b9a ?victim)
          (shared_p_consensus_c610f9b0c65c4262 ?victim ?place)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_free ?victim))
        (intends ?victim (human_662247ec644ef452_p_free ?victim))
      )
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_untie
    :parameters (?person - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?person)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (shared_p_consensus_37a155841f4f2b9a ?person)
          (human_662247ec644ef452_p_free ?person)
          (shared_p_consensus_c610f9b0c65c4262 ?person ?place)
          (shared_p_consensus_37a155841f4f2b9a ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_c610f9b0c65c4262 ?victim ?place)
        )
      )
    :effect
      (human_662247ec644ef452_p_free ?victim)
    :agents (?person)
  )

  (:action human_662247ec644ef452_a_take
    :parameters (?taker - object ?item - object ?victim - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?taker)
        (human_662247ec644ef452_type_item ?item)
        (human_662247ec644ef452_type_person ?victim)
        (human_662247ec644ef452_type_place ?place)
        (and
          (not (= ?taker ?victim))
          (shared_p_consensus_37a155841f4f2b9a ?taker)
          (human_662247ec644ef452_p_free ?taker)
          (shared_p_consensus_c610f9b0c65c4262 ?taker ?place)
          (shared_p_consensus_37a155841f4f2b9a ?victim)
          (not (human_662247ec644ef452_p_free ?victim))
          (shared_p_consensus_c610f9b0c65c4262 ?victim ?place)
          (shared_p_consensus_bcef17e13588288d ?victim ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_bcef17e13588288d ?taker ?item)
        (not (shared_p_consensus_bcef17e13588288d ?victim ?item))
        (when
          (human_662247ec644ef452_p_belongsto ?item ?victim)
          (and
            (intends ?victim (shared_p_consensus_bcef17e13588288d ?victim ?item))
            (forall
              (?s - object)
              (when
                (and
                  (human_662247ec644ef452_type_person ?s)
                  (human_662247ec644ef452_p_sheriff ?s)
                )
                (intends ?s (and (shared_p_consensus_c610f9b0c65c4262 ?taker human_662247ec644ef452_o_jailhouse) (not (human_662247ec644ef452_p_free ?taker)) (shared_p_consensus_bcef17e13588288d ?victim ?item) (human_662247ec644ef452_p_free ?victim)))
              )
            )
          )
        )
      )
    :agents (?taker)
  )

  (:action human_662247ec644ef452_a_heal
    :parameters (?healer - object ?patient - object ?sickness - object ?medicine - object ?place - object)
    :precondition
      (and
        (human_662247ec644ef452_active)
        (human_662247ec644ef452_type_person ?healer)
        (human_662247ec644ef452_type_person ?patient)
        (human_662247ec644ef452_type_sickness ?sickness)
        (human_662247ec644ef452_type_item ?medicine)
        (human_662247ec644ef452_type_place ?place)
        (and
          (human_662247ec644ef452_p_cures ?medicine ?sickness)
          (shared_p_consensus_37a155841f4f2b9a ?healer)
          (human_662247ec644ef452_p_free ?healer)
          (shared_p_consensus_c610f9b0c65c4262 ?healer ?place)
          (shared_p_consensus_bcef17e13588288d ?healer ?medicine)
          (shared_p_consensus_37a155841f4f2b9a ?patient)
          (shared_p_consensus_c610f9b0c65c4262 ?patient ?place)
          (human_662247ec644ef452_p_sick ?patient ?sickness)
        )
      )
    :effect
      (and
        (not (human_662247ec644ef452_p_sick ?patient ?sickness))
        (not (shared_p_consensus_bcef17e13588288d ?healer ?medicine))
      )
    :agents (?healer ?patient)
  )
)
