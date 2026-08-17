(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    bird brother_astronomer brother_hunter brother_tailor brother_thief chaffinch dragon duck father grettel hansel king mentor_astronomer mentor_hunter mentor_tailor mentor_thief mother princess witch - entity
    apple bread_piece brushwood cake crumb eggs gun kettle milk needle nut oven pancake pearl pebble planks precious_stone ship sticks sugar_window telescope - item
    branch cottage cross_way dead_tree door father_house forest hill house kingdom lake path rock_sea roof room sea stable_location town_gate tree window - location
  )
  (:predicates
    (at ?e - entity ?l - location)
    (bird_heard ?c - entity ?l - location)
    (bread_given ?c - entity)
    (captured ?c - entity)
    (collected ?c - entity ?i - item)
    (crossed_lake ?c - entity)
    (crumb_on_path ?l - location)
    (dead ?e - entity)
    (dragon_dead)
    (duck_helped ?c - entity ?d - entity)
    (eggs_fetched ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (entity_at ?e - entity ?l - location)
    (fire_lit ?l - location)
    (half_kingdom ?e - entity ?k - location)
    (has ?e - entity ?i - item)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (locked ?l - location)
    (lost ?c - entity)
    (pebble_on_path ?l - location)
    (princess_rescued ?e - entity)
    (reunited_with_father ?c - entity)
    (reward_received ?e - entity)
    (ship_broken)
    (ship_repaired)
  )

  (:action abandon_children_in_forest
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :effect (and (at ?h ?forest) (at ?g ?forest) (lost ?h) (lost ?g) (bread_given ?h) (bread_given ?g) (fire_lit ?forest))
  )

  (:action call_duck_for_crossing
    :parameters (?duck ?g ?h - entity ?lake - location)
    :precondition (and (at ?h ?lake) (at ?g ?lake) (at ?duck ?lake))
    :effect (and (duck_helped ?h ?duck) (duck_helped ?g ?duck) (crossed_lake ?h) (crossed_lake ?g))
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

  (:action hear_bird_and_follow_to_witch_house
    :parameters (?bird ?g ?h - entity ?branch ?cottage - location)
    :precondition (and (at ?h ?branch) (at ?g ?branch) (bird_heard ?h ?branch) (bird_heard ?g ?branch))
    :effect (and (at ?h ?cottage) (at ?g ?cottage) (not (at ?h ?branch)) (not (at ?g ?branch)))
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

  (:action obtain_ship
    :parameters (?a - entity)
    :precondition (is_astronomer ?a)
    :effect (has ?a ship)
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

  (:action sail_to_rock
    :parameters (?a - entity)
    :precondition (and (has ?a ship) (entity_at ?a house))
    :effect (and (entity_at ?a rock_sea) (not (entity_at ?a house)))
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

  (:action shoot_dragon
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (entity_at dragon rock_sea))
    :effect (and (dragon_dead) (ship_broken) (not (entity_at dragon rock_sea)))
  )

  (:action shoot_eggs
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (eggs_fetched brother_thief))
    :effect (eggs_shot ?h)
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
