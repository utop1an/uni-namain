(define (domain unified_narrative_domain)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    bungo comet_master earth farmer long_tail_45 man_bricks man_furze man_straw meteor meteor_keeper mother_pig no1_express pig1 pig2 pig3 short_tail_73 squire sun wolf - entity
    apple bricks butter_churn chalk fire furze_bundle mortar pot_of_water sack slate straw_bundle trowel turnips_load - item
    brick_house chimney comet_house courtyard furze_house gate hearth hill oak_forest pig_home squire_orchard straw_house town_fair turnip_field - location
  )
  (:predicates
    (alive ?e - entity)
    (arrested ?c - entity ?m - entity)
    (at ?e - entity ?l - location)
    (avoid ?c - entity ?b - entity)
    (boiling ?i - item)
    (burned ?c - entity)
    (crossed_out ?c - entity)
    (dead ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (door_closed ?h - location)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (escaped ?e - entity)
    (gate_open)
    (has ?e - entity ?i - item)
    (has_bundle ?m - entity ?i - item)
    (has_mission ?c - entity)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (inside ?e - entity ?c - item)
    (left_turn_rule ?c - entity)
    (material_requested ?p - entity ?i - item)
    (near ?c - entity ?b - entity)
    (on_list ?c - entity)
    (over ?i1 - item ?i2 - item)
    (plan ?e - entity ?l - location)
    (prohibit_speak ?c - entity)
    (puffed ?w - entity)
    (punished ?m - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (speaks_to ?c - entity ?m - entity)
    (summoned ?c - entity)
    (traveling ?c - entity)
    (under ?i - item ?l - location)
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

  (:action ask_for_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (material_requested ?p ?i)
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action build_house
    :parameters (?p - entity ?i - item ?h - location)
    :precondition (and (has ?p ?i) (alive ?p) (at ?p ?h))
    :effect (and (house ?h ?i) (house_intact ?h) (door_closed ?h) (not (has ?p ?i)))
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

  (:action pig_buys_butter_churn_and_hides
    :parameters (?p - entity ?c - item)
    :precondition (and (at ?p town_fair) (alive ?p))
    :effect (and (has ?p ?c) (inside ?p ?c))
  )

  (:action pig_collects_apples_and_escapes
    :parameters (?p - entity ?a - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?a) (escaped ?p) (not (plan ?p ?l)))
  )

  (:action pig_collects_turnips
    :parameters (?p - entity ?i - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?i) (not (plan ?p ?l)))
  )

  (:action pig_prepares_boiling_pot_and_fire
    :parameters (?p - entity ?fire ?pot - item ?h - location)
    :precondition (and (at ?p ?h) (has ?p ?pot) (has ?p ?fire) (alive ?p))
    :effect (and (over ?pot ?fire) (under ?pot chimney) (boiling ?pot))
  )

  (:action pig_refuses_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_requested ?w ?h) (alive ?w))
    :effect (and (entry_denied ?w ?h) (not (entry_requested ?w ?h)))
  )

  (:action pig_rolls_churn_down_hill
    :parameters (?p - entity ?c - item)
    :precondition (and (inside ?p ?c) (alive ?p))
    :effect (and (rolling ?c) (not (inside ?p ?c)))
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

  (:action receive_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (material_requested ?p ?i) (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (and (has ?p ?i) (not (material_requested ?p ?i)) (not (has_bundle ?m ?i)))
  )

  (:action send_sons_on_journey
    :parameters (?m ?p - entity ?d - location)
    :precondition (and (at ?m pig_home) (at ?p pig_home) (alive ?m) (alive ?p))
    :effect (and (plan ?p ?d) (not (at ?p pig_home)))
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

  (:action wolf_attempts_chimney_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (house_intact ?h) (alive ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action wolf_blows_house_down
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (door_closed ?h) (alive ?w))
    :effect (and (house_destroyed ?h) (not (house_intact ?h)) (not (door_closed ?h)))
  )

  (:action wolf_eats_pig
    :parameters (?p ?w - entity ?h - location)
    :precondition (and (house_destroyed ?h) (at ?p ?h) (alive ?p) (alive ?w))
    :effect (and (dead ?p) (not (alive ?p)) (not (at ?p ?h)))
  )

  (:action wolf_fails_to_blow_house
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (alive ?w))
    :effect (house_intact ?h)
  )

  (:action wolf_falls_into_pot_and_is_boiled
    :parameters (?w - entity ?pot - item)
    :precondition (and (boiling ?pot) (alive ?w))
    :effect (and (dead ?w) (not (alive ?w)))
  )

  (:action wolf_flees_from_rolling_object
    :parameters (?w - entity ?c - item)
    :precondition (and (rolling ?c) (alive ?w))
    :effect (escaped ?w)
  )

  (:action wolf_huff_and_puff
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_denied ?w ?h) (alive ?w))
    :effect (and (huffed ?w) (puffed ?w))
  )

  (:action wolf_knocks_and_requests_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (at ?w ?h) (door_closed ?h) (alive ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action wolf_promises_apple_orchard
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_fair_trip
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_turnip_field
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )
)
