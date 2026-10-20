(define (domain narrative_union)
  (:requirements :conditional-effects :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d001__t_entity d001__t_item d001__t_location - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:constants
    d000__c_chicken-licken d000__c_cock-lock d000__c_drake-lake d000__c_duck-luck d000__c_fox-lox d000__c_gander-lander d000__c_goose-loose d000__c_hen-len d000__c_king d000__c_turkey-lurkey - d000__t_entity
    d000__c_acorn d000__c_sky - d000__t_item
    d000__c_foxhole d000__c_wood - d000__t_location
    d001__c_bird d001__c_duck d001__c_father d001__c_grettel d001__c_hansel d001__c_mother d001__c_witch - d001__t_entity
    d001__c_apple d001__c_bread_piece d001__c_brushwood d001__c_cake d001__c_crumb d001__c_kettle d001__c_milk d001__c_nut d001__c_oven d001__c_pancake d001__c_pearl d001__c_pebble d001__c_precious_stone d001__c_sugar_window - d001__t_item
    d001__c_branch d001__c_cottage d001__c_dead_tree d001__c_door d001__c_father_house d001__c_forest d001__c_hill d001__c_lake d001__c_path d001__c_roof d001__c_room d001__c_stable_location d001__c_window - d001__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_decided_to_tell_king ?e - d000__t_entity)
    (d000__p_eaten_by_fox ?e - d000__t_entity)
    (d000__p_following_fox ?e - d000__t_entity)
    (d000__p_going_to_wood ?e - d000__t_entity)
    (d000__p_informed_about_sky_fall ?informer - d000__t_entity ?listener - d000__t_entity)
    (d000__p_met ?e1 - d000__t_entity ?e2 - d000__t_entity)
    (d000__p_sky_fell_on_head ?e - d000__t_entity)
    (d000__p_turned_back ?e - d000__t_entity)
    (d001__p_at ?e - d001__t_entity ?l - d001__t_location)
    (d001__p_bird_heard ?c - d001__t_entity ?l - d001__t_location)
    (d001__p_bread_given ?c - d001__t_entity)
    (d001__p_captured ?c - d001__t_entity)
    (d001__p_collected ?c - d001__t_entity ?i - d001__t_item)
    (d001__p_crossed_lake ?c - d001__t_entity)
    (d001__p_crumb_on_path ?l - d001__t_location)
    (d001__p_dead ?e - d001__t_entity)
    (d001__p_duck_helped ?c - d001__t_entity ?d - d001__t_entity)
    (d001__p_fire_lit ?l - d001__t_location)
    (d001__p_has ?e - d001__t_entity ?i - d001__t_item)
    (d001__p_locked ?l - d001__t_location)
    (d001__p_lost ?c - d001__t_entity)
    (d001__p_pebble_on_path ?l - d001__t_location)
    (d001__p_reunited_with_father ?c - d001__t_entity)
  )

  (:action d000__a_be_eaten_by_fox
    :parameters (?e - d000__t_entity ?l - d000__t_location)
    :precondition (and (d000__p_following_fox ?e) (d000__p_at ?e ?l) (not (d000__p_eaten_by_fox ?e)))
    :effect (and (d000__p_at ?e d000__c_foxhole) (d000__p_eaten_by_fox ?e) (not (d000__p_at ?e ?l)) (not (d000__p_following_fox ?e)))
  )

  (:action d000__a_decide_to_tell_king
    :parameters (?e - d000__t_entity)
    :precondition (and (exists (?inf - d000__t_entity) (d000__p_informed_about_sky_fall ?inf ?e)) (not (d000__p_decided_to_tell_king ?e)))
    :effect (d000__p_decided_to_tell_king ?e)
  )

  (:action d000__a_follow_fox
    :parameters (?e - d000__t_entity)
    :precondition (and (d000__p_decided_to_tell_king ?e) (not (d000__p_following_fox ?e)))
    :effect (d000__p_following_fox ?e)
  )

  (:action d000__a_go_to_wood
    :parameters (?e - d000__t_entity)
    :precondition (and (not (d000__p_at ?e d000__c_wood)) (not (d000__p_going_to_wood ?e)))
    :effect (d000__p_going_to_wood ?e)
  )

  (:action d000__a_inform_about_sky_fall
    :parameters (?informer - d000__t_entity ?listener - d000__t_entity)
    :precondition (and (d000__p_met ?informer ?listener) (d000__p_sky_fell_on_head d000__c_chicken-licken) (not (d000__p_informed_about_sky_fall ?informer ?listener)))
    :effect (d000__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d000__a_meet_character
    :parameters (?e1 - d000__t_entity ?e2 - d000__t_entity ?l - d000__t_location)
    :precondition (and (d000__p_at ?e1 ?l) (d000__p_at ?e2 ?l) (not (d000__p_met ?e1 ?e2)))
    :effect (and (d000__p_met ?e1 ?e2) (d000__p_met ?e2 ?e1))
  )

  (:action d000__a_turn_back
    :parameters (?e - d000__t_entity)
    :precondition (and (d000__p_going_to_wood ?e) (not (d000__p_turned_back ?e)))
    :effect (and (d000__p_turned_back ?e) (not (d000__p_going_to_wood ?e)))
  )

  (:action d001__a_abandon_children_in_forest
    :parameters (?father - d001__t_entity ?g - d001__t_entity ?h - d001__t_entity ?mother - d001__t_entity ?forest - d001__t_location)
    :effect (and (d001__p_at ?h ?forest) (d001__p_at ?g ?forest) (d001__p_lost ?h) (d001__p_lost ?g) (d001__p_bread_given ?h) (d001__p_bread_given ?g) (d001__p_fire_lit ?forest))
  )

  (:action d001__a_call_duck_for_crossing
    :parameters (?duck - d001__t_entity ?g - d001__t_entity ?h - d001__t_entity ?lake - d001__t_location)
    :precondition (and (d001__p_at ?h ?lake) (d001__p_at ?g ?lake) (d001__p_at ?duck ?lake))
    :effect (and (d001__p_duck_helped ?h ?duck) (d001__p_duck_helped ?g ?duck) (d001__p_crossed_lake ?h) (d001__p_crossed_lake ?g))
  )

  (:action d001__a_collect_treasure
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?pearl - d001__t_item ?precious_stone - d001__t_item ?cottage - d001__t_location)
    :precondition (and (d001__p_at ?h ?cottage) (d001__p_at ?g ?cottage))
    :effect (and (d001__p_has ?h ?pearl) (d001__p_has ?g ?precious_stone) (d001__p_collected ?h ?pearl) (d001__p_collected ?g ?precious_stone))
  )

  (:action d001__a_drop_breadcrumb_on_path
    :parameters (?h - d001__t_entity ?crumb - d001__t_item ?path_loc - d001__t_location)
    :precondition (and (d001__p_at ?h ?path_loc) (d001__p_has ?h ?crumb))
    :effect (and (d001__p_crumb_on_path ?path_loc) (not (d001__p_has ?h ?crumb)))
  )

  (:action d001__a_drop_pebble_on_path
    :parameters (?h - d001__t_entity ?peb - d001__t_item ?path_loc - d001__t_location)
    :precondition (and (d001__p_at ?h ?path_loc) (d001__p_has ?h ?peb))
    :effect (and (d001__p_pebble_on_path ?path_loc) (not (d001__p_has ?h ?peb)))
  )

  (:action d001__a_enter_witch_house
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?cottage - d001__t_location)
    :precondition (and (d001__p_at ?h ?cottage) (d001__p_at ?g ?cottage))
    :effect (and (d001__p_has ?h d001__c_cake) (d001__p_has ?g d001__c_sugar_window))
  )

  (:action d001__a_escape_from_stable
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?cottage - d001__t_location ?stable - d001__t_location)
    :precondition (and (d001__p_captured ?h) (d001__p_locked ?stable) (d001__p_at ?g ?cottage) (d001__p_at ?h ?stable))
    :effect (and (d001__p_at ?h ?cottage) (not (d001__p_at ?h ?stable)) (not (d001__p_locked ?stable)) (not (d001__p_captured ?h)))
  )

  (:action d001__a_follow_breadcrumbs_home
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?home - d001__t_location ?path_loc - d001__t_location)
    :precondition (and (d001__p_at ?h ?path_loc) (d001__p_at ?g ?path_loc))
    :effect (when (d001__p_crumb_on_path ?path_loc) (and (d001__p_at ?h ?home) (d001__p_at ?g ?home) (not (d001__p_at ?h ?path_loc)) (not (d001__p_at ?g ?path_loc)) (not (d001__p_lost ?h)) (not (d001__p_lost ?g))))
  )

  (:action d001__a_follow_pebbles_home
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?home - d001__t_location ?path_loc - d001__t_location)
    :precondition (and (d001__p_pebble_on_path ?path_loc) (d001__p_at ?h ?path_loc) (d001__p_at ?g ?path_loc))
    :effect (and (d001__p_at ?h ?home) (d001__p_at ?g ?home) (not (d001__p_at ?h ?path_loc)) (not (d001__p_at ?g ?path_loc)) (not (d001__p_lost ?h)) (not (d001__p_lost ?g)))
  )

  (:action d001__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - d001__t_entity ?g - d001__t_entity ?h - d001__t_entity ?branch - d001__t_location ?cottage - d001__t_location)
    :precondition (and (d001__p_at ?h ?branch) (d001__p_at ?g ?branch) (d001__p_bird_heard ?h ?branch) (d001__p_bird_heard ?g ?branch))
    :effect (and (d001__p_at ?h ?cottage) (d001__p_at ?g ?cottage) (not (d001__p_at ?h ?branch)) (not (d001__p_at ?g ?branch)))
  )

  (:action d001__a_leave_children_at_fire
    :parameters (?father - d001__t_entity ?g - d001__t_entity ?h - d001__t_entity ?mother - d001__t_entity ?forest - d001__t_location)
    :precondition (and (d001__p_at ?h ?forest) (d001__p_at ?g ?forest) (d001__p_fire_lit ?forest) (d001__p_bread_given ?h) (d001__p_bread_given ?g))
    :effect (and (d001__p_lost ?h) (d001__p_lost ?g))
  )

  (:action d001__a_push_witch_into_oven
    :parameters (?g - d001__t_entity ?witch - d001__t_entity ?oven - d001__t_item ?room - d001__t_location)
    :precondition (and (d001__p_at ?g ?room) (d001__p_at ?witch ?room))
    :effect (and (d001__p_dead ?witch) (not (d001__p_at ?witch ?room)))
  )

  (:action d001__a_return_home_and_reunite_with_father
    :parameters (?father - d001__t_entity ?g - d001__t_entity ?h - d001__t_entity ?father_house - d001__t_location)
    :precondition (and (d001__p_crossed_lake ?h) (d001__p_crossed_lake ?g) (d001__p_at ?father ?father_house))
    :effect (and (d001__p_at ?h ?father_house) (d001__p_at ?g ?father_house) (d001__p_reunited_with_father ?h) (d001__p_reunited_with_father ?g) (not (d001__p_lost ?h)) (not (d001__p_lost ?g)))
  )

  (:action d001__a_wander_forest_seeking_way_out
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?forest - d001__t_location)
    :precondition (and (d001__p_at ?h ?forest) (d001__p_at ?g ?forest))
    :effect (and (d001__p_lost ?h) (d001__p_lost ?g))
  )

  (:action d001__a_witch_captures_children
    :parameters (?g - d001__t_entity ?h - d001__t_entity ?witch - d001__t_entity ?cottage - d001__t_location ?stable - d001__t_location)
    :precondition (and (d001__p_at ?h ?cottage) (d001__p_at ?g ?cottage) (not (d001__p_locked ?stable)))
    :effect (and (d001__p_captured ?h) (d001__p_locked ?stable) (d001__p_at ?h ?stable) (not (d001__p_at ?h ?cottage)))
  )
)
