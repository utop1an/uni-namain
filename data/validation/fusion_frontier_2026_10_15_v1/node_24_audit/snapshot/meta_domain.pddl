(define (domain unified_narrative_domain)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ass brown_hen bungo butcher captain cat cock comet_master earth fairy_maiden farmer giant giant_dog giant_wife hound jack jack_mother long_tail_45 man man_bricks man_furze man_straw messenger meteor meteor_keeper milky_white mother_pig no1_express pig1 pig2 pig3 robber short_tail_73 squire sun wolf - entity
    apple axe bricks butter_churn chalk drinks fire furze_bundle gold_bag_1 gold_bag_2 golden_harp kettledrums lute magic_beans meat mortar oak_tree_club pot_of_water sack slate straw straw_bundle table trowel turnips_load - item
    beam beanstalk bremen brick_house castle_road chimney comet_house cottage courtyard forest furze_house garden gate giant_castle hearth hill kettle market musi__c_window naug__c_hearth oak_forest oven pig_home road_to_bremen robbers_cottage squire_orchard straw_house town_fair turnip_field window - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (arrested ?c - entity ?m - entity)
    (asleep ?e - entity)
    (at ?e - entity ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (avoid ?c - entity ?b - entity)
    (bad ?e - entity)
    (beanstalk_grown)
    (bite ?dog - entity ?target - entity)
    (boiling ?i - item)
    (burned ?c - entity)
    (climbing_down ?e - entity)
    (crossed_out ?c - entity)
    (crowed ?cock - entity)
    (dead ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (distracted ?e - entity)
    (door_closed ?h - location)
    (empty ?i - item)
    (entity_state ?e - entity)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (escaped ?e - entity)
    (fled ?robber - entity ?loc - location)
    (gate_open)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (has_bundle ?m - entity ?i - item)
    (has_mission ?c - entity)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (inside ?e - entity ?i - item)
    (intact ?l - location)
    (invited ?inviter - entity ?invitee - entity)
    (kick ?donkey - entity ?target - entity)
    (left_turn_rule ?c - entity)
    (light_off ?loc - location)
    (light_on ?loc - location)
    (located ?i - item ?l - location)
    (making_noise ?e - entity)
    (material_requested ?p - entity ?i - item)
    (moving_towards ?e - entity ?loc - location)
    (naug__p_inside ?e - entity ?c - item)
    (near ?c - entity ?b - entity)
    (offers ?e - entity ?i - item)
    (on ?i - item ?l - location)
    (on_list ?c - entity)
    (over ?i1 - item ?i2 - item)
    (plan ?e - entity ?l - location)
    (planted ?i - item)
    (prohibit_speak ?c - entity)
    (puffed ?w - entity)
    (retreated ?robber - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (sees_light ?e - entity)
    (sleeping_at ?e - entity ?loc - location)
    (speaks_to ?c - entity ?m - entity)
    (stacked_on ?top - entity ?bottom - entity)
    (summoned ?c - entity)
    (traveling ?c - entity)
    (window_shattered)
  )

  (:action approach_location
    :parameters (?j - entity ?l - location)
    :precondition (and (at ?j beanstalk) (beanstalk_grown) (at ?j ?l))
    :effect (and (at ?j ?l) (moving_towards ?j ?l))
  )

  (:action arrest_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (near ?c ?m))
    :effect (and (arrested ?c ?m) (detained ?m))
  )

  (:action ask_for_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (has_bundle ?m ?i) (entity_state ?p) (entity_state ?m))
    :effect (material_requested ?p ?i)
  )

  (:action ask_giant_wife_for_breakfast
    :parameters (?j ?wife - entity)
    :precondition (and (at ?j giant_castle) (at ?wife giant_castle))
    :effect (has_breakfast ?j)
  )

  (:action attempt_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entity_state ?w) (house_intact ?h))
    :effect (and (entry_requested ?w ?h) (light_off ?h))
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action build_house
    :parameters (?p - entity ?i - item ?h - location)
    :precondition (and (has ?p ?i) (entity_state ?p) (at ?p ?h))
    :effect (and (house ?h ?i) (house_intact ?h) (door_closed ?h) (not (has ?p ?i)))
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard))
    :effect (summoned ?c)
  )

  (:action cat_agrees
    :parameters (?cat ?donkey - entity)
    :precondition (invited ?donkey ?cat)
    :effect (agreed ?cat ?donkey)
  )

  (:action cat_attack_messenger
    :parameters (?cat ?messenger - entity)
    :precondition (and (attempt_light ?messenger) (at ?cat hearth))
    :effect (attacked ?cat ?messenger)
  )

  (:action cause_bad
    :parameters (?e - entity)
    :precondition (and (attempt_light ?e))
    :effect (and (bad ?e))
  )

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (at ?cat ?hearth) (at ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
  )

  (:action cock_agrees
    :parameters (?cock ?donkey - entity)
    :precondition (invited ?donkey ?cock)
    :effect (agreed ?cock ?donkey)
  )

  (:action collect_item_from_location
    :parameters (?p - entity ?i - item ?l - location)
    :precondition (and (entity_state ?p) (located ?i ?l))
    :effect (and (has ?p ?i) (not (located ?i ?l)))
  )

  (:action cross_out_comet
    :parameters (?c - entity)
    :precondition (burned ?c)
    :effect (and (crossed_out ?c) (not (on_list ?c)))
  )

  (:action cut_beanstalk
    :parameters (?giant ?mother - entity ?axe - item)
    :precondition (and (intact beanstalk) (climbing_down ?giant))
    :effect (and (dead ?giant) (not (intact beanstalk)))
  )

  (:action deliver_meteor_to_bungo
    :parameters (?m - entity)
    :precondition (detained ?m)
    :effect (delivered ?m bungo)
  )

  (:action eat_feast
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (window_shattered))
    :effect (and (ate_all ?donkey) (ate_all ?hound) (ate_all ?cat) (ate_all ?cock))
  )

  (:action escape_or_force
    :parameters (?e - entity ?l - location)
    :precondition (and (entity_state ?e) (not (entry_denied ?e ?l)))
    :effect (and (fled ?e ?l) (huffed ?e) (puffed ?e))
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action grow_beanstalk
    :parameters (?beans - item)
    :precondition (planted ?beans)
    :effect (and (beanstalk_grown) (intact beanstalk))
  )

  (:action hide_item
    :parameters (?e - entity ?i - item)
    :precondition (and (at ?e giant_castle) (empty ?i) (entity_state ?e))
    :effect (and (inside ?e ?i) (not (at ?e giant_castle)))
  )

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
  )

  (:action interact_with_entity
    :parameters (?m ?t - entity)
    :precondition (and (attempt_light ?m) (near ?m ?t))
    :effect (and (speaks_to ?m ?t) (bite ?m ?t))
  )

  (:action invite_cat
    :parameters (?cat ?donkey - entity)
    :effect (invited ?donkey ?cat)
  )

  (:action invite_cock
    :parameters (?cock ?donkey - entity ?loc - location)
    :precondition (and (at ?donkey ?loc) (at ?cock ?loc))
    :effect (invited ?donkey ?cock)
  )

  (:action invite_hound
    :parameters (?donkey ?hound - entity)
    :effect (invited ?donkey ?hound)
  )

  (:action messenger_attempt_light
    :parameters (?messenger - entity ?cottage - location)
    :precondition (light_off ?cottage)
    :effect (attempt_light ?messenger)
  )

  (:action move_towards_location
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (moving_towards ?e ?l))
  )

  (:action pig_collects_apples_and_escapes
    :parameters (?p - entity ?a - item ?l - location)
    :precondition (and (plan ?p ?l) (entity_state ?p))
    :effect (and (has ?p ?a) (escaped ?p) (not (plan ?p ?l)))
  )

  (:action pig_refuses_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_requested ?w ?h) (entity_state ?w))
    :effect (and (entry_denied ?w ?h) (not (entry_requested ?w ?h)))
  )

  (:action pig_rolls_churn_down_hill
    :parameters (?p - entity ?c - item)
    :precondition (and (naug__p_inside ?p ?c) (entity_state ?p))
    :effect (and (rolling ?c) (not (naug__p_inside ?p ?c)))
  )

  (:action plan_scaring_robbers
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
  )

  (:action plant_beans
    :parameters (?beans - item ?loc - location)
    :precondition (located ?beans ?loc)
    :effect (and (planted ?beans) (not (located ?beans ?loc)))
  )

  (:action prepare_boiling_pot_and_fire
    :parameters (?p - entity ?fire ?pot - item ?h - location)
    :precondition (and (at ?p ?h) (has ?p ?pot) (has ?p ?fire) (entity_state ?p))
    :effect (and (over ?pot ?fire) (located ?pot chimney) (boiling ?pot) (burned ?p))
  )

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action receive_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (material_requested ?p ?i) (has_bundle ?m ?i) (entity_state ?p) (entity_state ?m))
    :effect (and (has ?p ?i) (not (material_requested ?p ?i)) (not (has_bundle ?m ?i)))
  )

  (:action request_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (at ?w ?h) (door_closed ?h) (entity_state ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action rest_in_forest
    :parameters (?cat ?cock ?donkey ?hound - entity ?forest - location)
    :precondition (and (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (entity_state ?donkey) (entity_state ?hound) (entity_state ?cat) (entity_state ?cock))
  )

  (:action retreat_to_location
    :parameters (?e - entity ?l - location)
    :precondition (at ?e ?l)
    :effect (and (not (at ?e ?l)) (retreated ?e))
  )

  (:action return_down_beanstalk
    :parameters (?j - entity)
    :precondition (at ?j giant_castle)
    :effect (and (at ?j cottage) (not (at ?j giant_castle)))
  )

  (:action sell_cow_for_beans
    :parameters (?b ?cow ?j - entity ?beans - item ?l - location)
    :precondition (and (at ?j ?l) (at ?cow ?l) (offers ?b ?beans) (at ?b ?l))
    :effect (and (has ?j ?beans) (not (offers ?b ?beans)) (not (located ?beans ?l)))
  )

  (:action send_sons_on_journey
    :parameters (?m ?p - entity ?d - location)
    :precondition (and (at ?m pig_home) (at ?p pig_home) (entity_state ?m) (entity_state ?p))
    :effect (and (plan ?p ?d) (not (at ?p pig_home)))
  )

  (:action signal_and_make_noise
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock) (window_shattered))
  )

  (:action stack_animals
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
    :effect (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
  )

  (:action start_journey
    :parameters (?c - entity ?l1 - location ?l2 - location)
    :precondition (and (has_mission ?c) (gate_open) (at ?c ?l1))
    :effect (and (traveling ?c) (at ?c ?l2) (not (at ?c ?l1)))
  )

  (:action steal_harp
    :parameters (?giant ?j - entity ?harp - item)
    :precondition (and (on ?harp giant_castle) (asleep ?giant))
    :effect (and (has ?j ?harp) (not (on ?harp giant_castle)))
  )

  (:action steal_hen
    :parameters (?giant ?j - entity ?hen - item)
    :precondition (and (on ?hen giant_castle) (distracted ?giant))
    :effect (and (has ?j ?hen) (not (on ?hen giant_castle)))
  )

  (:action travel_together_with_promise
    :parameters (?cat ?cock ?donkey ?hound ?p - entity ?from ?to - location)
    :precondition (and (at ?donkey ?from) (at ?hound ?from) (at ?cat ?from) (at ?cock ?from) (at ?p ?from) (agreed ?hound ?donkey) (agreed ?cat ?donkey) (agreed ?cock ?donkey))
    :effect (and (at ?donkey ?to) (at ?hound ?to) (at ?cat ?to) (at ?cock ?to) (moving_towards ?donkey ?to) (moving_towards ?hound ?to) (moving_towards ?cat ?to) (moving_towards ?cock ?to) (not (at ?donkey ?from)) (not (at ?hound ?from)) (not (at ?cat ?from)) (not (at ?cock ?from)))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
  )

  (:action wolf_blows_house_down
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (door_closed ?h) (entity_state ?w))
    :effect (and (house_destroyed ?h) (not (house_intact ?h)) (not (door_closed ?h)))
  )

  (:action wolf_eats_pig
    :parameters (?p ?w - entity ?h - location)
    :precondition (and (house_destroyed ?h) (at ?p ?h) (entity_state ?p) (entity_state ?w))
    :effect (and (bad ?p) (not (entity_state ?p)) (not (at ?p ?h)))
  )

  (:action wolf_fails_to_blow_house
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (entity_state ?w))
    :effect (house_intact ?h)
  )

  (:action wolf_falls_into_pot_and_is_boiled
    :parameters (?w - entity ?pot - item)
    :precondition (and (boiling ?pot) (entity_state ?w))
    :effect (and (bad ?w) (not (entity_state ?w)))
  )

  (:action wolf_flees_from_rolling_object
    :parameters (?w - entity ?c - item)
    :precondition (and (rolling ?c) (entity_state ?w))
    :effect (escaped ?w)
  )

  (:action wolf_promises_apple_orchard
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (entity_state ?w) (entity_state ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_turnip_field
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (entity_state ?w) (entity_state ?p))
    :effect (plan ?p ?l)
  )
)
