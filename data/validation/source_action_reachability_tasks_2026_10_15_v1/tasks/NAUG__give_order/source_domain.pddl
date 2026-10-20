(define (domain The_Naughty_Comet)
   (:requirements
      :negative-preconditions :strips :typing)

   (:types 
      entity - object
      item - object
      location - object
   )

   (:constants 
      bungo - entity
      chalk - item
      comet_house - location
      comet_master - entity
      courtyard - location
      earth - entity
      gate - location
      long_tail_45 - entity
      meteor - entity
      meteor_keeper - entity
      no1_express - entity
      short_tail_73 - entity
      slate - item
      sun - entity
   )

   (:predicates 
      (arrested ?c - entity ?m - entity)
      (at ?e - entity ?l - location)
      (avoid ?c - entity ?b - entity)
      (burned ?c - entity)
      (crossed_out ?c - entity)
      (delivered ?m - entity ?p - entity)
      (detained ?m - entity)
      (gate_open )
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

   (:action give_order
     :parameters (?c ?master - entity)
     :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
     :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
   )
   
   (:action start_travel
     :parameters (?c - entity)
     :precondition (and (has_mission ?c) (gate_open))
     :effect (and (traveling ?c) (not (at ?c courtyard)))
   )
   
   (:action avoid_body
     :parameters (?b ?c - entity)
     :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
     :effect (not (near ?c ?b))
   )
   
   (:action turn_left_on_meeting
     :parameters (?c ?other - entity)
     :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
     :effect (left_turn_rule ?c)
   )
   
   (:action prohibit_speaking_to_meteor
     :parameters (?c - entity)
     :precondition (has_mission ?c)
     :effect (prohibit_speak ?c)
   )
   
   (:action speak_to_meteor
     :parameters (?c ?m - entity)
     :precondition (and (traveling ?c) (prohibit_speak ?c) (near ?c ?m))
     :effect (and (speaks_to ?c ?m) (rule_violation ?c))
   )
   
   (:action approach_sun
     :parameters (?c - entity)
     :precondition (and (traveling ?c) (avoid ?c sun))
     :effect (near ?c sun)
   )
   
   (:action burn_up
     :parameters (?c - entity)
     :precondition (near ?c sun)
     :effect (and (burned ?c) (not (traveling ?c)) (not (has_mission ?c)))
   )
   
   (:action cross_out_comet
     :parameters (?c - entity)
     :precondition (burned ?c)
     :effect (and (crossed_out ?c) (not (on_list ?c)))
   )
   
   (:action call_comet_forward
     :parameters (?c ?master - entity)
     :precondition (and (at ?c courtyard) (at ?master courtyard))
     :effect (summoned ?c)
   )
   
   (:action arrest_meteor
     :parameters (?c ?m - entity)
     :precondition (and (traveling ?c) (near ?c ?m))
     :effect (and (arrested ?c ?m) (detained ?m))
   )
   
   (:action deliver_meteor_to_bungo
     :parameters (?m - entity)
     :precondition (detained ?m)
     :effect (delivered ?m bungo)
   )
   
   (:action punish_meteor
     :parameters (?m - entity)
     :precondition (delivered ?m bungo)
     :effect (punished ?m)
   )
)