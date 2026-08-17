(define (domain The_Naughty_Comet)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    bungo comet_master earth long_tail_45 meteor meteor_keeper no1_express short_tail_73 sun - entity
    chalk slate - item
    comet_house courtyard gate - location
  )
  (:predicates
    (arrested ?c - entity ?m - entity)
    (at ?e - entity ?l - location)
    (avoid ?c - entity ?b - entity)
    (burned ?c - entity)
    (crossed_out ?c - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (gate_open)
    (has_mission ?c - entity)
    (left_turn_rule ?c - entity)
    (near ?c - entity ?b - entity)
    (on_list ?c - entity)
    (prohibit_speak ?c - entity)
    (punished ?m - entity)
    (rule_violation ?c - entity)
    (speaks_to ?c - entity ?m - entity)
    (summoned ?c - entity)
    (traveling ?c - entity)
  )

  (:action approach_sun
    :parameters (?c - entity)
    :precondition (and (traveling ?c) (avoid ?c sun))
    :effect (near ?c sun)
  )

  (:action arrest_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (near ?c ?m))
    :effect (and (arrested ?c ?m) (detained ?m))
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action burn_up
    :parameters (?c - entity)
    :precondition (near ?c sun)
    :effect (and (burned ?c) (not (traveling ?c)) (not (has_mission ?c)))
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard))
    :effect (summoned ?c)
  )

  (:action cross_out_comet
    :parameters (?c - entity)
    :precondition (burned ?c)
    :effect (and (crossed_out ?c) (not (on_list ?c)))
  )

  (:action deliver_meteor_to_bungo
    :parameters (?m - entity)
    :precondition (detained ?m)
    :effect (delivered ?m bungo)
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action punish_meteor
    :parameters (?m - entity)
    :precondition (delivered ?m bungo)
    :effect (punished ?m)
  )

  (:action speak_to_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (prohibit_speak ?c) (near ?c ?m))
    :effect (and (speaks_to ?c ?m) (rule_violation ?c))
  )

  (:action start_travel
    :parameters (?c - entity)
    :precondition (and (has_mission ?c) (gate_open))
    :effect (and (traveling ?c) (not (at ?c courtyard)))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
  )
)
