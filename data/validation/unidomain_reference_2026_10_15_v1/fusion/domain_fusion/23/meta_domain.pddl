(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    audience bird brother_astronomer brother_hunter brother_tailor brother_thief buffoon chaffinch Chicken-licken Cock-lock countryman dragon Drake-lake duck Duck-luck father four_np__c_king Fox-lox Gander-lander Goose-loose grettel hans_np__c_father hansel Hen-len King little_pig mentor_astronomer mentor_hunter mentor_tailor mentor_thief mother princess rich_nobleman Turkey-lurkey witch - entity
    Acorn apple bread_piece brushwood cake cloak crumb eggs gun kettle milk needle nut oven pancake pearl pebble planks precious_stone ship Sky sticks sugar_window telescope - item
    branch cottage cross_way dead_tree door father_house forest FoxHole hill house kingdom lake path platform rock_sea roof room sea stable_location theater town_gate tree window Wood - location
  )
  (:predicates
    (applause_given ?audience - entity ?performer - entity)
    (at ?e - entity ?l - location)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (bird_heard ?c - entity ?l - location)
    (bread_given ?c - entity)
    (captured ?c - entity)
    (cloak_shaken ?performer - entity ?cloak - item)
    (collected ?c - entity ?i - item)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crossed_lake ?c - entity)
    (crowd_present ?audience - entity ?theater - location)
    (crumb_on_path ?l - location)
    (dead ?e - entity)
    (decided_to_tell_king ?e - entity)
    (dragon_dead)
    (duck_helped ?c - entity ?d - entity)
    (eaten_by_fox ?e - entity)
    (eggs_fetched ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (fire_lit ?l - location)
    (following_fox ?e - entity)
    (going_to_wood ?e - entity)
    (half_kingdom ?e - entity ?k - location)
    (has ?e - entity ?i - item)
    (imitates_pig ?performer - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (locked ?l - location)
    (lost ?c - entity)
    (met ?e1 - entity ?e2 - entity)
    (on_platform ?performer - entity ?platform - location)
    (partiality_prevalent)
    (pebble_on_path ?l - location)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (princess_rescued ?e - entity)
    (reunited_with_father ?c - entity)
    (reward_announced ?nobleman - entity)
    (ship_broken)
    (ship_repaired)
    (sky_fell_on_head ?e - entity)
    (state_reached ?e - entity)
    (theater_opened ?nobleman - entity ?theater - location)
  )

  (:action abandon_children_in_forest
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :effect (and (at ?h ?forest) (at ?g ?forest) (lost ?h) (lost ?g) (bread_given ?h) (bread_given ?g) (fire_lit ?forest))
  )

  (:action acquire_reward_by_opening_theater
    :parameters (?nobleman - entity ?theater - location ?reward - item)
    :precondition (and (state_reached ?nobleman) (has ?nobleman ?reward) (theater_opened ?nobleman ?theater))
    :effect (and (state_reached ?nobleman) (has ?nobleman ?reward))
  )

  (:action audience_applaud_performance
    :parameters (?audience ?performer ?pig - entity ?cloak - item)
    :precondition (and (cloak_shaken ?performer ?cloak) (not (pig_found ?performer ?pig)))
    :effect (applause_given ?audience ?performer)
  )

  (:action audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (countryman_performs_with_real_pig ?countryman ?pig)
    :effect (audience_calls_for_kickout ?audience ?countryman)
  )

  (:action audience_demand_shake_cloak_for_pig
    :parameters (?audience ?performer - entity ?cloak - item)
    :effect (audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action be_eaten_by_fox
    :parameters (?e - entity ?l - location)
    :precondition (and (following_fox ?e) (at ?e ?l) (not (eaten_by_fox ?e)))
    :effect (and (at ?e FoxHole) (eaten_by_fox ?e) (not (at ?e ?l)) (not (following_fox ?e)))
  )

  (:action call_duck_for_crossing
    :parameters (?duck ?g ?h - entity ?lake - location)
    :precondition (and (at ?h ?lake) (at ?g ?lake) (at ?duck ?lake))
    :effect (and (duck_helped ?h ?duck) (duck_helped ?g ?duck) (crossed_lake ?h) (crossed_lake ?g))
  )

  (:action count_eggs
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope) (at ?a tree))
    :effect (has ?a eggs)
  )

  (:action countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - entity)
    :effect (countryman_declares_intent ?countryman)
  )

  (:action countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman ?pig - entity ?platform - location)
    :precondition (and (countryman_declares_intent ?countryman) (on_platform ?countryman ?platform))
    :effect (countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action countryman_reveal_real_pig
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (audience_calls_for_kickout ?audience ?countryman)
    :effect (pig_revealed ?countryman ?pig)
  )

  (:action decide_to_tell_king
    :parameters (?e - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?e)) (not (decided_to_tell_king ?e)))
    :effect (decided_to_tell_king ?e)
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
    :precondition (and (is_thief ?t) (at ?t tree) (item_at eggs tree))
    :effect (and (eggs_fetched ?t) (has ?t eggs) (not (item_at eggs tree)))
  )

  (:action follow_breadcrumbs_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (when (crumb_on_path ?path_loc) (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g))))
  )

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (decided_to_tell_king ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
  )

  (:action follow_pebbles_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (pebble_on_path ?path_loc) (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g)))
  )

  (:action go_to_wood
    :parameters (?e - entity)
    :precondition (and (not (at ?e Wood)) (not (going_to_wood ?e)))
    :effect (going_to_wood ?e)
  )

  (:action hear_bird_and_follow_to_witch_house
    :parameters (?bird ?g ?h - entity ?branch ?cottage - location)
    :precondition (and (at ?h ?branch) (at ?g ?branch) (bird_heard ?h ?branch) (bird_heard ?g ?branch))
    :effect (and (at ?h ?cottage) (at ?g ?cottage) (not (at ?h ?branch)) (not (at ?g ?branch)))
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
  )

  (:action learn_astronomer_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_astronomer ?b) (has ?b telescope))
  )

  (:action learn_hunter_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_hunter ?b) (has ?b gun))
  )

  (:action learn_tailor_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_tailor ?b) (has ?b needle))
  )

  (:action learn_thief_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (is_thief ?b)
  )

  (:action leave_at_location
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (not (at ?e ?l)))
  )

  (:action locate_princess
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope))
    :effect (at princess rock_sea)
  )

  (:action meet_character
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l) (not (met ?e1 ?e2)))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
  )

  (:action move_to_destination_and_resolve_state
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (at ?e ?l) (not (lost ?e)))
  )

  (:action obtain_ship
    :parameters (?a - entity)
    :precondition (is_astronomer ?a)
    :effect (has ?a ship)
  )

  (:action perform_pig_imitation_without_apparatus
    :parameters (?performer - entity ?platform - location)
    :precondition (on_platform ?performer ?platform)
    :effect (and (performs_without_apparatus ?performer) (imitates_pig ?performer))
  )

  (:action push_witch_into_oven
    :parameters (?g ?witch - entity ?oven - item ?room - location)
    :precondition (and (at ?g ?room) (at ?witch ?room))
    :effect (and (dead ?witch) (not (at ?witch ?room)))
  )

  (:action repair_ship
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (ship_broken))
    :effect (and (ship_repaired) (not (ship_broken)))
  )

  (:action return_eggs_to_nest
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (eggs_sewn brother_tailor) (at ?t tree) (has ?t eggs))
    :effect (and (item_at eggs tree) (not (has ?t eggs)))
  )

  (:action return_home_with_princess
    :parameters (?a - entity)
    :precondition (and (ship_repaired) (at ?a sea))
    :effect (and (at ?a house) (at princess house) (not (at ?a sea)))
  )

  (:action seek_way_out_in_forest
    :parameters (?g ?h - entity ?f - location)
    :precondition (and (at ?h ?f) (at ?g ?f))
    :effect (and (lost ?h) (at ?g ?f))
  )

  (:action separate_at_crossroads
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (has ?b sticks)
  )

  (:action sew_eggs
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (eggs_shot brother_hunter))
    :effect (eggs_sewn ?t)
  )

  (:action shoot_dragon
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (at dragon rock_sea))
    :effect (and (dragon_dead) (ship_broken) (not (at dragon rock_sea)))
  )

  (:action shoot_eggs
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (eggs_fetched brother_thief))
    :effect (eggs_shot ?h)
  )

  (:action steal_princess
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (at ?t rock_sea) (at princess rock_sea) (at dragon rock_sea))
    :effect (and (princess_rescued ?t) (at princess sea) (not (at princess rock_sea)))
  )

  (:action swim_after_ship_break
    :parameters (?b - entity)
    :precondition (ship_broken)
    :effect (at ?b sea)
  )

  (:action turn_back
    :parameters (?e - entity)
    :precondition (and (going_to_wood ?e) (not (state_reached ?e)))
    :effect (and (state_reached ?e) (not (going_to_wood ?e)))
  )

  (:action witch_captures_children
    :parameters (?g ?h ?witch - entity ?cottage ?stable - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage) (not (locked ?stable)))
    :effect (and (captured ?h) (locked ?stable) (at ?h ?stable) (not (at ?h ?cottage)))
  )
)
