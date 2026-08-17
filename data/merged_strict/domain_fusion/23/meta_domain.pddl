(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ass bird brother_astronomer brother_hunter brother_tailor brother_thief brown_hen butcher captain cat chaffinch cock dragon duck fairy_maiden father giant giant_dog giant_wife grettel hansel hound jack jack_mother king man mentor_astronomer mentor_hunter mentor_tailor mentor_thief messenger milky_white mother princess robber witch - entity
    apple axe bread_piece brushwood cake crumb drinks eggs gold_bag_1 gold_bag_2 golden_harp gun kettle kettledrums lute magic_beans meat milk needle nut oak_tree_club oven pancake pearl pebble planks precious_stone ship sticks straw sugar_window table telescope - item
    beam beanstalk branch bremen castle_road cottage cross_way dead_tree door father_house forest garden giant_castle hearth hill house jack_np_kettle jack_np_oven kingdom lake market path road_to_bremen robbers_cottage rock_sea roof room sea stable_location town_gate tree window - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (asleep ?e - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (beanstalk_grown)
    (bird_heard ?c - entity ?l - location)
    (bite ?dog - entity ?target - entity)
    (bread_given ?c - entity)
    (captured ?c - entity)
    (climbing_down ?e - entity)
    (collected ?c - entity ?i - item)
    (crossed_lake ?c - entity)
    (crowed ?cock - entity)
    (crumb_on_path ?l - location)
    (dead ?e - entity)
    (distracted ?e - entity)
    (duck_helped ?c - entity ?d - entity)
    (eggs_fetched ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (empty ?i - item)
    (entity_at ?e - entity ?l - location)
    (fire_lit ?l - location)
    (fled ?robber - entity ?loc - location)
    (half_kingdom ?e - entity ?k - location)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (inside ?e - entity ?i - item)
    (intact ?l - location)
    (invited ?inviter - entity ?invitee - entity)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (kick ?donkey - entity ?target - entity)
    (light_off ?loc - location)
    (light_on ?loc - location)
    (locked ?l - location)
    (lost ?c - entity)
    (making_noise ?e - entity)
    (moving_towards ?e - entity ?loc - location)
    (offers ?e - entity ?i - item)
    (on ?i - item ?l - location)
    (pebble_on_path ?l - location)
    (planted ?i - item)
    (princess_rescued ?e - entity)
    (resting ?e - entity)
    (retreated ?robber - entity)
    (reunited_with_father ?c - entity)
    (reward_received ?e - entity)
    (sees_light ?e - entity)
    (ship_broken)
    (ship_repaired)
    (sleeping_at ?e - entity ?loc - location)
    (stacked_on ?top - entity ?bottom - entity)
    (window_shattered)
  )

  (:action abandon_children_in_forest
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :effect (and (at ?h ?forest) (at ?g ?forest) (lost ?h) (lost ?g) (bread_given ?h) (bread_given ?g) (fire_lit ?forest))
  )

  (:action approach_cottage
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage ?forest - location)
    :precondition (and (sees_light ?cock) (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (moving_towards ?donkey ?cottage) (moving_towards ?hound ?cottage) (moving_towards ?cat ?cottage) (moving_towards ?cock ?cottage) (not (at ?donkey ?forest)) (not (at ?hound ?forest)) (not (at ?cat ?forest)) (not (at ?cock ?forest)))
  )

  (:action ask_giant_wife_for_breakfast
    :parameters (?j ?wife - entity)
    :precondition (and (at ?j giant_castle) (at ?wife giant_castle))
    :effect (has_breakfast ?j)
  )

  (:action call_duck_for_crossing
    :parameters (?duck ?g ?h - entity ?lake - location)
    :precondition (and (at ?h ?lake) (at ?g ?lake) (at ?duck ?lake))
    :effect (and (duck_helped ?h ?duck) (duck_helped ?g ?duck) (crossed_lake ?h) (crossed_lake ?g))
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

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (at ?cat ?hearth) (at ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
  )

  (:action climb_beanstalk
    :parameters (?j - entity)
    :precondition (and (beanstalk_grown) (at ?j beanstalk))
    :effect (and (at ?j giant_castle) (not (at ?j beanstalk)))
  )

  (:action cock_agrees
    :parameters (?cock ?donkey - entity)
    :precondition (invited ?donkey ?cock)
    :effect (agreed ?cock ?donkey)
  )

  (:action cock_crow_alert
    :parameters (?cock - entity)
    :precondition (at ?cock beam)
    :effect (crowed ?cock)
  )

  (:action collect_treasure
    :parameters (?g ?h - entity ?pearl ?precious_stone - item ?cottage - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage))
    :effect (and (has ?h ?pearl) (has ?g ?precious_stone) (collected ?h ?pearl) (collected ?g ?precious_stone))
  )

  (:action count_eggs
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope) (entity_at ?a tree))
    :effect (has ?a eggs)
  )

  (:action cut_beanstalk
    :parameters (?giant ?mother - entity ?axe - item)
    :precondition (and (intact beanstalk) (climbing_down ?giant))
    :effect (and (dead ?giant) (not (intact beanstalk)))
  )

  (:action dog_bite_messenger
    :parameters (?hound ?messenger - entity ?cottage - location)
    :precondition (and (attempt_light ?messenger) (at ?hound ?cottage))
    :effect (bite ?hound ?messenger)
  )

  (:action donkey_kick_messenger
    :parameters (?donkey ?messenger - entity)
    :precondition (attempt_light ?messenger)
    :effect (kick ?donkey ?messenger)
  )

  (:action drop_breadcrumb_on_path
    :parameters (?h - entity ?crumb - item ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (has ?h ?crumb))
    :effect (and (crumb_on_path ?path_loc) (not (has ?h ?crumb)))
  )

  (:action drop_pebble_on_path
    :parameters (?h - entity ?peb - item ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (has ?h ?peb))
    :effect (and (pebble_on_path ?path_loc) (not (has ?h ?peb)))
  )

  (:action eat_feast
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (window_shattered))
    :effect (and (ate_all ?donkey) (ate_all ?hound) (ate_all ?cat) (ate_all ?cock))
  )

  (:action enter_witch_house
    :parameters (?g ?h - entity ?cottage - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage))
    :effect (and (has ?h cake) (has ?g sugar_window))
  )

  (:action escape_from_stable
    :parameters (?g ?h - entity ?cottage ?stable - location)
    :precondition (and (captured ?h) (locked ?stable) (at ?g ?cottage) (at ?h ?stable))
    :effect (and (at ?h ?cottage) (not (at ?h ?stable)) (not (locked ?stable)) (not (captured ?h)))
  )

  (:action extinguish_light
    :parameters (?cottage - location)
    :precondition (light_on ?cottage)
    :effect (and (light_off ?cottage) (not (light_on ?cottage)))
  )

  (:action fetch_eggs
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (entity_at ?t tree) (item_at eggs tree))
    :effect (and (eggs_fetched ?t) (has ?t eggs) (not (item_at eggs tree)))
  )

  (:action follow_breadcrumbs_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (when (crumb_on_path ?path_loc) (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g))))
  )

  (:action follow_pebbles_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (pebble_on_path ?path_loc) (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g)))
  )

  (:action grow_beanstalk
    :parameters (?beans - item)
    :precondition (planted ?beans)
    :effect (and (beanstalk_grown) (intact beanstalk))
  )

  (:action hear_bird_and_follow_to_witch_house
    :parameters (?bird ?g ?h - entity ?branch ?cottage - location)
    :precondition (and (at ?h ?branch) (at ?g ?branch) (bird_heard ?h ?branch) (bird_heard ?g ?branch))
    :effect (and (at ?h ?cottage) (at ?g ?cottage) (not (at ?h ?branch)) (not (at ?g ?branch)))
  )

  (:action hide_in_kettle
    :parameters (?j - entity ?kettle - item)
    :precondition (and (at ?j giant_castle) (empty ?kettle))
    :effect (and (inside ?j ?kettle) (not (at ?j giant_castle)))
  )

  (:action hide_in_oven
    :parameters (?j - entity ?oven - item)
    :precondition (at ?j giant_castle)
    :effect (and (inside ?j ?oven) (not (at ?j giant_castle)))
  )

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
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

  (:action kill_dragon
    :parameters (?d - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (entity_at dragon rock_sea))
    :effect (and (dead ?d - entity) (ship_broken) (not (entity_at dragon rock_sea)))
  )

  (:action learn_astronomer_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_astronomer ?b) (has ?b telescope))
  )

  (:action learn_hunter_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_hunter ?b) (has ?b gun))
  )

  (:action learn_tailor_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_tailor ?b) (has ?b needle))
  )

  (:action learn_thief_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (is_thief ?b)
  )

  (:action leave_children_at_fire
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :precondition (and (at ?h ?forest) (at ?g ?forest) (fire_lit ?forest) (bread_given ?h) (bread_given ?g))
    :effect (and (lost ?h) (lost ?g))
  )

  (:action leave_home
    :parameters (?b - entity)
    :precondition (entity_at ?b house)
    :effect (and (entity_at ?b town_gate) (not (entity_at ?b house)))
  )

  (:action locate_princess
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope))
    :effect (entity_at princess rock_sea)
  )

  (:action messenger_attempt_light
    :parameters (?messenger - entity ?cottage - location)
    :precondition (light_off ?cottage)
    :effect (attempt_light ?messenger)
  )

  (:action obtain_ship
    :parameters (?a - entity)
    :precondition (is_astronomer ?a)
    :effect (has ?a ship)
  )

  (:action plan_scaring_robbers
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
  )

  (:action plant_beans
    :parameters (?beans - item ?loc - location)
    :precondition (at_item ?beans ?loc)
    :effect (and (planted ?beans) (not (at_item ?beans ?loc)))
  )

  (:action push_witch_into_oven
    :parameters (?g ?witch - entity ?oven - item ?room - location)
    :precondition (and (at ?g ?room) (at ?witch ?room))
    :effect (and (dead ?witch) (not (at ?witch ?room)))
  )

  (:action receive_reward
    :parameters (?e - entity)
    :precondition (princess_rescued ?e)
    :effect (and (reward_received ?e) (half_kingdom ?e kingdom))
  )

  (:action repair_ship
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (ship_broken))
    :effect (and (ship_repaired) (not (ship_broken)))
  )

  (:action rest_in_forest
    :parameters (?cat ?cock ?donkey ?hound - entity ?forest - location)
    :precondition (and (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (resting ?donkey) (resting ?hound) (resting ?cat) (resting ?cock))
  )

  (:action return_down_beanstalk
    :parameters (?j - entity)
    :precondition (at ?j giant_castle)
    :effect (and (at ?j cottage) (not (at ?j giant_castle)))
  )

  (:action return_eggs_to_nest
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (eggs_sewn brother_tailor) (entity_at ?t tree) (has ?t eggs))
    :effect (and (item_at eggs tree) (not (has ?t eggs)))
  )

  (:action return_home_and_reunite_with_father
    :parameters (?father ?g ?h - entity ?father_house - location)
    :precondition (and (crossed_lake ?h) (crossed_lake ?g) (at ?father ?father_house))
    :effect (and (at ?h ?father_house) (at ?g ?father_house) (reunited_with_father ?h) (reunited_with_father ?g) (not (lost ?h)) (not (lost ?g)))
  )

  (:action return_home_with_princess
    :parameters (?a - entity)
    :precondition (and (ship_repaired) (entity_at ?a sea))
    :effect (and (entity_at ?a house) (entity_at princess house) (not (entity_at ?a sea)))
  )

  (:action reunite_at_crossroads
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (entity_at ?b house) (not (entity_at ?b cross_way)))
  )

  (:action robbers_flee
    :parameters (?robber - entity ?cottage ?forest - location)
    :precondition (and (window_shattered) (at ?robber ?cottage))
    :effect (and (fled ?robber ?forest) (not (at ?robber ?cottage)))
  )

  (:action robbers_retreat
    :parameters (?robber - entity ?cottage - location)
    :precondition (at ?robber ?cottage)
    :effect (and (retreated ?robber) (not (at ?robber ?cottage)))
  )

  (:action run_away
    :parameters (?donkey - entity ?from ?to - location)
    :precondition (at ?donkey ?from)
    :effect (and (at ?donkey ?to) (moving_towards ?donkey ?to) (not (at ?donkey ?from)))
  )

  (:action sail_to_rock
    :parameters (?a - entity)
    :precondition (and (has ?a ship) (entity_at ?a house))
    :effect (and (entity_at ?a rock_sea) (not (entity_at ?a house)))
  )

  (:action sell_cow_for_beans
    :parameters (?b ?cow ?j - entity ?beans - item ?l - location)
    :precondition (and (at ?j ?l) (at ?cow ?l) (offers ?b ?beans) (at ?b ?l))
    :effect (and (has ?j ?beans) (not (offers ?b ?beans)) (not (at_item ?beans ?l)))
  )

  (:action separate_at_crossroads
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (has ?b sticks)
  )

  (:action sew_eggs
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (eggs_shot brother_hunter))
    :effect (eggs_sewn ?t)
  )

  (:action shoot_eggs
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (eggs_fetched brother_thief))
    :effect (eggs_shot ?h)
  )

  (:action signal_and_make_noise
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock) (window_shattered))
  )

  (:action spot_light
    :parameters (?cock - entity ?cottage ?forest - location)
    :precondition (and (at ?cock ?forest) (resting ?cock))
    :effect (and (sees_light ?cock) (moving_towards ?cock ?cottage))
  )

  (:action stack_animals
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
    :effect (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
  )

  (:action steal_gold_bags
    :parameters (?j - entity ?bag1 ?bag2 - item)
    :precondition (and (asleep giant) (at_item ?bag1 giant_castle) (at_item ?bag2 giant_castle))
    :effect (and (has ?j ?bag1) (has ?j ?bag2) (not (at_item ?bag1 giant_castle)) (not (at_item ?bag2 giant_castle)))
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

  (:action steal_princess
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (entity_at ?t rock_sea) (entity_at princess rock_sea) (entity_at dragon rock_sea))
    :effect (and (princess_rescued ?t) (entity_at princess sea) (not (entity_at princess rock_sea)))
  )

  (:action swim_after_ship_break
    :parameters (?b - entity)
    :precondition (ship_broken)
    :effect (entity_at ?b sea)
  )

  (:action travel_together
    :parameters (?cat ?cock ?donkey ?hound - entity ?from ?to - location)
    :precondition (and (at ?donkey ?from) (at ?hound ?from) (at ?cat ?from) (at ?cock ?from) (agreed ?hound ?donkey) (agreed ?cat ?donkey) (agreed ?cock ?donkey))
    :effect (and (at ?donkey ?to) (at ?hound ?to) (at ?cat ?to) (at ?cock ?to) (moving_towards ?donkey ?to) (moving_towards ?hound ?to) (moving_towards ?cat ?to) (moving_towards ?cock ?to) (not (at ?donkey ?from)) (not (at ?hound ?from)) (not (at ?cat ?from)) (not (at ?cock ?from)))
  )

  (:action wander_forest_seeking_way_out
    :parameters (?g ?h - entity ?forest - location)
    :precondition (and (at ?h ?forest) (at ?g ?forest))
    :effect (and (lost ?h) (lost ?g))
  )

  (:action witch_captures_children
    :parameters (?g ?h ?witch - entity ?cottage ?stable - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage) (not (locked ?stable)))
    :effect (and (captured ?h) (locked ?stable) (at ?h ?stable) (not (at ?h ?cottage)))
  )
)
