(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_apple d000__c_brick_house d000__c_bricks d000__c_butter_churn d000__c_chimney d000__c_farmer d000__c_fire d000__c_furze_bundle d000__c_furze_house d000__c_hearth d000__c_hill d000__c_man_bricks d000__c_man_furze d000__c_man_straw d000__c_mortar d000__c_mother_pig d000__c_oak_forest d000__c_pig1 d000__c_pig2 d000__c_pig3 d000__c_pig_home d000__c_pot_of_water d000__c_sack d000__c_squire d000__c_squire_orchard d000__c_straw_bundle d000__c_straw_house d000__c_town_fair d000__c_trowel d000__c_turnip_field d000__c_turnips_load d000__c_wolf - object
  )
  (:predicates
    (d000__p_alive ?a0 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_boiling ?a0 - object)
    (d000__p_dead ?a0 - object)
    (d000__p_door_closed ?a0 - object)
    (d000__p_entry_denied ?a0 - object ?a1 - object)
    (d000__p_entry_requested ?a0 - object ?a1 - object)
    (d000__p_escaped ?a0 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_has_bundle ?a0 - object ?a1 - object)
    (d000__p_house ?a0 - object ?a1 - object)
    (d000__p_house_destroyed ?a0 - object)
    (d000__p_house_intact ?a0 - object)
    (d000__p_huffed ?a0 - object)
    (d000__p_inside ?a0 - object ?a1 - object)
    (d000__p_material_requested ?a0 - object ?a1 - object)
    (d000__p_over ?a0 - object ?a1 - object)
    (d000__p_plan ?a0 - object ?a1 - object)
    (d000__p_puffed ?a0 - object)
    (d000__p_rolling ?a0 - object)
    (d000__p_under ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_ask_for_material
    :parameters (?m - object ?p - object ?i - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?i) (and (d000__p_has_bundle ?m ?i) (d000__p_alive ?p) (d000__p_alive ?m)))
    :effect (d000__p_material_requested ?p ?i)
  )

  (:action d000__a_build_house
    :parameters (?p - object ?i - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?i) (typeguard__d000__t_location ?h) (and (d000__p_has ?p ?i) (d000__p_alive ?p) (d000__p_at ?p ?h)))
    :effect (and (d000__p_house ?h ?i) (d000__p_house_intact ?h) (d000__p_door_closed ?h) (not (d000__p_has ?p ?i)))
  )

  (:action d000__a_pig_buys_butter_churn_and_hides
    :parameters (?p - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?c) (and (d000__p_at ?p d000__c_town_fair) (d000__p_alive ?p)))
    :effect (and (d000__p_has ?p ?c) (d000__p_inside ?p ?c))
  )

  (:action d000__a_pig_collects_apples_and_escapes
    :parameters (?p - object ?a - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?a) (typeguard__d000__t_location ?l) (and (d000__p_plan ?p ?l) (d000__p_alive ?p)))
    :effect (and (d000__p_has ?p ?a) (d000__p_escaped ?p) (not (d000__p_plan ?p ?l)))
  )

  (:action d000__a_pig_collects_turnips
    :parameters (?p - object ?i - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?i) (typeguard__d000__t_location ?l) (and (d000__p_plan ?p ?l) (d000__p_alive ?p)))
    :effect (and (d000__p_has ?p ?i) (not (d000__p_plan ?p ?l)))
  )

  (:action d000__a_pig_prepares_boiling_pot_and_fire
    :parameters (?p - object ?fire - object ?pot - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?fire) (typeguard__d000__t_item ?pot) (typeguard__d000__t_location ?h) (and (d000__p_at ?p ?h) (d000__p_has ?p ?pot) (d000__p_has ?p ?fire) (d000__p_alive ?p)))
    :effect (and (d000__p_over ?pot ?fire) (d000__p_under ?pot d000__c_chimney) (d000__p_boiling ?pot))
  )

  (:action d000__a_pig_refuses_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?h) (and (d000__p_entry_requested ?w ?h) (d000__p_alive ?w)))
    :effect (and (d000__p_entry_denied ?w ?h) (not (d000__p_entry_requested ?w ?h)))
  )

  (:action d000__a_pig_rolls_churn_down_hill
    :parameters (?p - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?c) (and (d000__p_inside ?p ?c) (d000__p_alive ?p)))
    :effect (and (d000__p_rolling ?c) (not (d000__p_inside ?p ?c)))
  )

  (:action d000__a_receive_material
    :parameters (?m - object ?p - object ?i - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?i) (and (d000__p_material_requested ?p ?i) (d000__p_has_bundle ?m ?i) (d000__p_alive ?p) (d000__p_alive ?m)))
    :effect (and (d000__p_has ?p ?i) (not (d000__p_material_requested ?p ?i)) (not (d000__p_has_bundle ?m ?i)))
  )

  (:action d000__a_send_sons_on_journey
    :parameters (?m - object ?p - object ?d - object)
    :precondition (and (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?p) (typeguard__d000__t_location ?d) (and (d000__p_at ?m d000__c_pig_home) (d000__p_at ?p d000__c_pig_home) (d000__p_alive ?m) (d000__p_alive ?p)))
    :effect (and (d000__p_plan ?p ?d) (not (d000__p_at ?p d000__c_pig_home)))
  )

  (:action d000__a_wolf_attempts_chimney_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?h) (and (d000__p_house_intact ?h) (d000__p_alive ?w)))
    :effect (d000__p_entry_requested ?w ?h)
  )

  (:action d000__a_wolf_blows_house_down
    :parameters (?w - object ?i - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_item ?i) (typeguard__d000__t_location ?h) (and (d000__p_huffed ?w) (d000__p_puffed ?w) (d000__p_house ?h ?i) (d000__p_door_closed ?h) (d000__p_alive ?w)))
    :effect (and (d000__p_house_destroyed ?h) (not (d000__p_house_intact ?h)) (not (d000__p_door_closed ?h)))
  )

  (:action d000__a_wolf_eats_pig
    :parameters (?p - object ?w - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?h) (and (d000__p_house_destroyed ?h) (d000__p_at ?p ?h) (d000__p_alive ?p) (d000__p_alive ?w)))
    :effect (and (d000__p_dead ?p) (not (d000__p_alive ?p)) (not (d000__p_at ?p ?h)))
  )

  (:action d000__a_wolf_fails_to_blow_house
    :parameters (?w - object ?i - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_item ?i) (typeguard__d000__t_location ?h) (and (d000__p_huffed ?w) (d000__p_puffed ?w) (d000__p_house ?h ?i) (d000__p_alive ?w)))
    :effect (d000__p_house_intact ?h)
  )

  (:action d000__a_wolf_falls_into_pot_and_is_boiled
    :parameters (?w - object ?pot - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_item ?pot) (and (d000__p_boiling ?pot) (d000__p_alive ?w)))
    :effect (and (d000__p_dead ?w) (not (d000__p_alive ?w)))
  )

  (:action d000__a_wolf_flees_from_rolling_object
    :parameters (?w - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_item ?c) (and (d000__p_rolling ?c) (d000__p_alive ?w)))
    :effect (d000__p_escaped ?w)
  )

  (:action d000__a_wolf_huff_and_puff
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?h) (and (d000__p_entry_denied ?w ?h) (d000__p_alive ?w)))
    :effect (and (d000__p_huffed ?w) (d000__p_puffed ?w))
  )

  (:action d000__a_wolf_knocks_and_requests_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?h) (and (d000__p_at ?w ?h) (d000__p_door_closed ?h) (d000__p_alive ?w)))
    :effect (d000__p_entry_requested ?w ?h)
  )

  (:action d000__a_wolf_promises_apple_orchard
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?l) (and (d000__p_alive ?w) (d000__p_alive ?p)))
    :effect (d000__p_plan ?p ?l)
  )

  (:action d000__a_wolf_promises_fair_trip
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?l) (and (d000__p_alive ?w) (d000__p_alive ?p)))
    :effect (d000__p_plan ?p ?l)
  )

  (:action d000__a_wolf_promises_turnip_field
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?p) (typeguard__d000__t_entity ?w) (typeguard__d000__t_location ?l) (and (d000__p_alive ?w) (d000__p_alive ?p)))
    :effect (d000__p_plan ?p ?l)
  )
)
