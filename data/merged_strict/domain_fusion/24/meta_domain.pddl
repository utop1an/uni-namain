(define (domain unified_narrative_domain)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    bungo coachman comet_master earth eldest_son farmer father_king groom impostor_butterman jack king king_at_palace long_tail_45 man_bricks man_furze man_straw meteor meteor_keeper miller mother_pig no1_express ogre pig1 pig2 pig3 princess puss robber_chief second_son short_tail_73 squire sun wolf - entity
    apple ass bag bag_of_rubies bag_of_sapphires boots bricks butter_churn chalk crown fire furze_bundle hare mill mortar partridge pot_of_water rabbit sack sceptre slate straw_bundle suit trowel turnips_load - item
    back_door back_stairs brick_house chimney city comet_house courtyard field_of_corn field_of_wheat forest furze_house gate hearth hill market_place oak_forest oak_tree ogre_castle palace pig_home river royal_wardrobe squire_orchard straw_house town_fair turnip_field warren - location
  )
  (:predicates
    (alive ?e - entity)
    (arrested ?c - entity ?m - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (avoid ?c - entity ?b - entity)
    (boiling ?i - item)
    (burned ?c - entity)
    (castle_owned_by ?castle - location ?owner - entity)
    (contains ?c - item ?i - item)
    (crossed_out ?c - entity)
    (dead ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (door_closed ?h - location)
    (drowning ?e - entity)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (escaped ?e - entity)
    (gate_open)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (grandmother_mangle_spoken)
    (has ?e - entity ?i - item)
    (has_bundle ?m - entity ?i - item)
    (has_mission ?c - entity)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (inside ?e - entity ?c - item)
    (left_turn_rule ?c - entity)
    (married ?e1 - entity ?e2 - entity)
    (material_requested ?p - entity ?i - item)
    (near ?c - entity ?b - entity)
    (obedient ?e - entity)
    (on_list ?c - entity)
    (over ?i1 - item ?i2 - item)
    (plan ?e - entity ?l - location)
    (price_of_butter_spoken)
    (prohibit_speak ?c - entity)
    (promised_to_serve ?servant - entity ?master - entity)
    (puffed ?w - entity)
    (punished ?m - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (speaks_to ?c - entity ?m - entity)
    (summoned ?c - entity)
    (transformed_into ?e - entity ?form - entity)
    (traveling ?c - entity)
    (under ?i - item ?l - location)
    (wearing ?e - entity ?i - item)
    (with_all_my_heart_spoken)
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

  (:action arrive_at_marble_palace
    :parameters (?p - entity)
    :precondition (at ?p oak_tree)
    :effect (and (at ?p palace) (not (at ?p oak_tree)))
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

  (:action buy_boots
    :parameters (?jack ?puss - entity ?boots - item)
    :precondition (not (has ?puss ?boots))
    :effect (has ?puss ?boots)
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard))
    :effect (summoned ?c)
  )

  (:action cat_call_for_help
    :parameters (?jack ?king ?puss - entity)
    :precondition (drowning ?jack)
    :effect (and (rescued_by ?jack ?king) (not (drowning ?jack)))
  )

  (:action cat_catch_rabbits
    :parameters (?puss - entity ?bag ?rabbit - item ?warren - location)
    :precondition (and (has ?puss ?bag) (at_item ?rabbit ?warren) (not (contains ?bag ?rabbit)))
    :effect (and (contains ?bag ?rabbit) (not (at_item ?rabbit ?warren)))
  )

  (:action cat_deliver_gifts_to_king
    :parameters (?king ?puss - entity ?bag ?rabbit - item ?palace - location)
    :precondition (and (contains ?bag ?rabbit) (at ?puss ?palace))
    :effect (and (gift_delivered ?puss ?king ?rabbit) (not (contains ?bag ?rabbit)))
  )

  (:action cat_disentchant_prisoners
    :parameters (?person ?puss - entity)
    :precondition (alive ?puss)
    :effect (promised_to_serve ?person jack)
  )

  (:action cat_eat_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (transformed_into ?ogre ?mouse)
    :effect (not (transformed_into ?ogre ?mouse))
  )

  (:action cat_ogre_transform_lion
    :parameters (?lion ?ogre ?puss - entity)
    :precondition (and (at ?puss ogre_castle) (alive ?ogre))
    :effect (transformed_into ?ogre ?lion)
  )

  (:action cat_ogre_transform_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (alive ?ogre)
    :effect (transformed_into ?ogre ?mouse)
  )

  (:action cat_open_castle_gates
    :parameters (?king ?puss - entity ?castle - location)
    :precondition (at ?king ?castle)
    :effect (gate_open)
  )

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
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

  (:action encounter_impostor_king
    :parameters (?i ?p - entity)
    :precondition (and (at ?p city) (at ?i market_place))
    :effect (and (at ?p market_place) (not (at ?p city)))
  )

  (:action encounter_robbers_in_forest
    :parameters (?p - entity)
    :precondition (at ?p forest)
    :effect (and (at ?p oak_tree) (not (at ?p forest)))
  )

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action king_requests_information_and_gifts
    :parameters (?k ?p - entity ?r ?s - item)
    :precondition (and (at ?p palace) (has ?p ?r) (has ?p ?s) (at ?k palace))
    :effect (and (has ?k ?r) (has ?k ?s) (not (has ?p ?r)) (not (has ?p ?s)))
  )

  (:action king_send_groom_fetch_suit
    :parameters (?groom ?king - entity ?suit - item ?wardrobe - location)
    :precondition (at_item ?suit ?wardrobe)
    :effect (and (has ?groom ?suit) (not (at_item ?suit ?wardrobe)))
  )

  (:action master_wear_suit
    :parameters (?jack - entity ?suit - item)
    :precondition (has ?jack ?suit)
    :effect (and (wearing ?jack ?suit) (not (has ?jack ?suit)))
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

  (:action princess_accepts_with_heart
    :parameters (?k ?p - entity)
    :precondition (and (married ?p ?k) (not (with_all_my_heart_spoken)))
    :effect (with_all_my_heart_spoken)
  )

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action propose_marriage
    :parameters (?k ?p - entity)
    :precondition (and (at ?p palace) (at ?k palace))
    :effect (married ?p ?k)
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

  (:action receive_rubies_from_impostor
    :parameters (?i ?p - entity ?r - item)
    :precondition (and (price_of_butter_spoken) (at ?p market_place) (has ?i ?r))
    :effect (and (has ?p ?r) (not (has ?i ?r)))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (at ?p oak_tree) (has ?c ?s))
    :effect (and (has ?p ?s) (not (has ?c ?s)))
  )

  (:action run_away_from_palace
    :parameters (?p - entity)
    :precondition (at ?p back_stairs)
    :effect (and (at ?p city) (not (at ?p back_stairs)))
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

  (:action suitors_retire_due_to_phrase
    :parameters (?s - entity)
    :precondition (and (grandmother_mangle_spoken) (at ?s palace))
    :effect (not (married ?s princess))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
  )

  (:action utter_phrase_grandmother_mangle
    :parameters (?p - entity)
    :precondition (and (at ?p oak_tree) (not (grandmother_mangle_spoken)))
    :effect (grandmother_mangle_spoken)
  )

  (:action utter_phrase_price_of_butter
    :parameters (?p - entity)
    :precondition (and (at ?p market_place) (not (price_of_butter_spoken)))
    :effect (price_of_butter_spoken)
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
