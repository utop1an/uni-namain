(define (domain narrative_aligned)
  (:requirements :adl :conditional-effects :existential-preconditions :negative-preconditions :strips :typing)
  (:constants
    d000__c_acorn d000__c_chicken-licken d000__c_cock-lock d000__c_drake-lake d000__c_duck-luck d000__c_fox-lox d000__c_foxhole d000__c_gander-lander d000__c_goose-loose d000__c_hen-len d000__c_king d000__c_sky d000__c_turkey-lurkey d000__c_wood d001__c_apple d001__c_bird d001__c_branch d001__c_bread_piece d001__c_brushwood d001__c_cake d001__c_cottage d001__c_crumb d001__c_dead_tree d001__c_door d001__c_duck d001__c_father d001__c_father_house d001__c_forest d001__c_grettel d001__c_hansel d001__c_hill d001__c_kettle d001__c_lake d001__c_milk d001__c_mother d001__c_nut d001__c_oven d001__c_pancake d001__c_path d001__c_pearl d001__c_pebble d001__c_precious_stone d001__c_roof d001__c_room d001__c_stable_location d001__c_sugar_window d001__c_window d001__c_witch - object
  )
  (:predicates
    (d000__p_decided_to_tell_king ?a0 - object)
    (d000__p_eaten_by_fox ?a0 - object)
    (d000__p_following_fox ?a0 - object)
    (d000__p_going_to_wood ?a0 - object)
    (d000__p_informed_about_sky_fall ?a0 - object ?a1 - object)
    (d000__p_met ?a0 - object ?a1 - object)
    (d000__p_sky_fell_on_head ?a0 - object)
    (d000__p_turned_back ?a0 - object)
    (d001__p_bird_heard ?a0 - object ?a1 - object)
    (d001__p_bread_given ?a0 - object)
    (d001__p_captured ?a0 - object)
    (d001__p_collected ?a0 - object ?a1 - object)
    (d001__p_crossed_lake ?a0 - object)
    (d001__p_crumb_on_path ?a0 - object)
    (d001__p_dead ?a0 - object)
    (d001__p_duck_helped ?a0 - object ?a1 - object)
    (d001__p_fire_lit ?a0 - object)
    (d001__p_has ?a0 - object ?a1 - object)
    (d001__p_locked ?a0 - object)
    (d001__p_lost ?a0 - object)
    (d001__p_pebble_on_path ?a0 - object)
    (d001__p_reunited_with_father ?a0 - object)
    (shared__p_interface_82f1308fd516317a ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
    (typeguard__d001__t_entity ?member - object)
    (typeguard__d001__t_item ?member - object)
    (typeguard__d001__t_location ?member - object)
    (typeguard__d001__t_object ?member - object)
  )

  (:action d000__a_be_eaten_by_fox
    :parameters (?e - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?e) (typeguard__d000__t_location ?l) (and (d000__p_following_fox ?e) (shared__p_interface_82f1308fd516317a ?e ?l) (not (d000__p_eaten_by_fox ?e))))
    :effect (and (shared__p_interface_82f1308fd516317a ?e d000__c_foxhole) (d000__p_eaten_by_fox ?e) (not (shared__p_interface_82f1308fd516317a ?e ?l)) (not (d000__p_following_fox ?e)))
  )

  (:action d000__a_decide_to_tell_king
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (exists (?bound_scope_0 - object) (and (typeguard__d000__t_entity ?bound_scope_0) (d000__p_informed_about_sky_fall ?bound_scope_0 ?e))) (not (d000__p_decided_to_tell_king ?e))))
    :effect (d000__p_decided_to_tell_king ?e)
  )

  (:action d000__a_follow_fox
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (d000__p_decided_to_tell_king ?e) (not (d000__p_following_fox ?e))))
    :effect (d000__p_following_fox ?e)
  )

  (:action d000__a_go_to_wood
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (not (shared__p_interface_82f1308fd516317a ?e d000__c_wood)) (not (d000__p_going_to_wood ?e))))
    :effect (d000__p_going_to_wood ?e)
  )

  (:action d000__a_inform_about_sky_fall
    :parameters (?informer - object ?listener - object)
    :precondition (and (typeguard__d000__t_entity ?informer) (typeguard__d000__t_entity ?listener) (and (d000__p_met ?informer ?listener) (d000__p_sky_fell_on_head d000__c_chicken-licken) (not (d000__p_informed_about_sky_fall ?informer ?listener))))
    :effect (d000__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d000__a_meet_character
    :parameters (?e1 - object ?e2 - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?e1) (typeguard__d000__t_entity ?e2) (typeguard__d000__t_location ?l) (and (shared__p_interface_82f1308fd516317a ?e1 ?l) (shared__p_interface_82f1308fd516317a ?e2 ?l) (not (d000__p_met ?e1 ?e2))))
    :effect (and (d000__p_met ?e1 ?e2) (d000__p_met ?e2 ?e1))
  )

  (:action d000__a_turn_back
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (and (d000__p_going_to_wood ?e) (not (d000__p_turned_back ?e))))
    :effect (and (d000__p_turned_back ?e) (not (d000__p_going_to_wood ?e)))
  )

  (:action d001__a_abandon_children_in_forest
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (typeguard__d001__t_entity ?father) (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_entity ?mother) (typeguard__d001__t_location ?forest) (and))
    :effect (and (shared__p_interface_82f1308fd516317a ?h ?forest) (shared__p_interface_82f1308fd516317a ?g ?forest) (d001__p_lost ?h) (d001__p_lost ?g) (d001__p_bread_given ?h) (d001__p_bread_given ?g) (d001__p_fire_lit ?forest))
  )

  (:action d001__a_call_duck_for_crossing
    :parameters (?duck - object ?g - object ?h - object ?lake - object)
    :precondition (and (typeguard__d001__t_entity ?duck) (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?lake) (and (shared__p_interface_82f1308fd516317a ?h ?lake) (shared__p_interface_82f1308fd516317a ?g ?lake) (shared__p_interface_82f1308fd516317a ?duck ?lake)))
    :effect (and (d001__p_duck_helped ?h ?duck) (d001__p_duck_helped ?g ?duck) (d001__p_crossed_lake ?h) (d001__p_crossed_lake ?g))
  )

  (:action d001__a_collect_treasure
    :parameters (?g - object ?h - object ?pearl - object ?precious_stone - object ?cottage - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_item ?pearl) (typeguard__d001__t_item ?precious_stone) (typeguard__d001__t_location ?cottage) (and (shared__p_interface_82f1308fd516317a ?h ?cottage) (shared__p_interface_82f1308fd516317a ?g ?cottage)))
    :effect (and (d001__p_has ?h ?pearl) (d001__p_has ?g ?precious_stone) (d001__p_collected ?h ?pearl) (d001__p_collected ?g ?precious_stone))
  )

  (:action d001__a_drop_breadcrumb_on_path
    :parameters (?h - object ?crumb - object ?path_loc - object)
    :precondition (and (typeguard__d001__t_entity ?h) (typeguard__d001__t_item ?crumb) (typeguard__d001__t_location ?path_loc) (and (shared__p_interface_82f1308fd516317a ?h ?path_loc) (d001__p_has ?h ?crumb)))
    :effect (and (d001__p_crumb_on_path ?path_loc) (not (d001__p_has ?h ?crumb)))
  )

  (:action d001__a_drop_pebble_on_path
    :parameters (?h - object ?peb - object ?path_loc - object)
    :precondition (and (typeguard__d001__t_entity ?h) (typeguard__d001__t_item ?peb) (typeguard__d001__t_location ?path_loc) (and (shared__p_interface_82f1308fd516317a ?h ?path_loc) (d001__p_has ?h ?peb)))
    :effect (and (d001__p_pebble_on_path ?path_loc) (not (d001__p_has ?h ?peb)))
  )

  (:action d001__a_enter_witch_house
    :parameters (?g - object ?h - object ?cottage - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?cottage) (and (shared__p_interface_82f1308fd516317a ?h ?cottage) (shared__p_interface_82f1308fd516317a ?g ?cottage)))
    :effect (and (d001__p_has ?h d001__c_cake) (d001__p_has ?g d001__c_sugar_window))
  )

  (:action d001__a_escape_from_stable
    :parameters (?g - object ?h - object ?cottage - object ?stable - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?cottage) (typeguard__d001__t_location ?stable) (and (d001__p_captured ?h) (d001__p_locked ?stable) (shared__p_interface_82f1308fd516317a ?g ?cottage) (shared__p_interface_82f1308fd516317a ?h ?stable)))
    :effect (and (shared__p_interface_82f1308fd516317a ?h ?cottage) (not (shared__p_interface_82f1308fd516317a ?h ?stable)) (not (d001__p_locked ?stable)) (not (d001__p_captured ?h)))
  )

  (:action d001__a_follow_breadcrumbs_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?home) (typeguard__d001__t_location ?path_loc) (and (shared__p_interface_82f1308fd516317a ?h ?path_loc) (shared__p_interface_82f1308fd516317a ?g ?path_loc)))
    :effect (and (when (and (d001__p_crumb_on_path ?path_loc)) (shared__p_interface_82f1308fd516317a ?h ?home)) (when (and (d001__p_crumb_on_path ?path_loc)) (shared__p_interface_82f1308fd516317a ?g ?home)) (when (and (d001__p_crumb_on_path ?path_loc)) (not (shared__p_interface_82f1308fd516317a ?h ?path_loc))) (when (and (d001__p_crumb_on_path ?path_loc)) (not (shared__p_interface_82f1308fd516317a ?g ?path_loc))) (when (and (d001__p_crumb_on_path ?path_loc)) (not (d001__p_lost ?h))) (when (and (d001__p_crumb_on_path ?path_loc)) (not (d001__p_lost ?g))))
  )

  (:action d001__a_follow_pebbles_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?home) (typeguard__d001__t_location ?path_loc) (and (d001__p_pebble_on_path ?path_loc) (shared__p_interface_82f1308fd516317a ?h ?path_loc) (shared__p_interface_82f1308fd516317a ?g ?path_loc)))
    :effect (and (shared__p_interface_82f1308fd516317a ?h ?home) (shared__p_interface_82f1308fd516317a ?g ?home) (not (shared__p_interface_82f1308fd516317a ?h ?path_loc)) (not (shared__p_interface_82f1308fd516317a ?g ?path_loc)) (not (d001__p_lost ?h)) (not (d001__p_lost ?g)))
  )

  (:action d001__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - object ?g - object ?h - object ?branch - object ?cottage - object)
    :precondition (and (typeguard__d001__t_entity ?bird) (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?branch) (typeguard__d001__t_location ?cottage) (and (shared__p_interface_82f1308fd516317a ?h ?branch) (shared__p_interface_82f1308fd516317a ?g ?branch) (d001__p_bird_heard ?h ?branch) (d001__p_bird_heard ?g ?branch)))
    :effect (and (shared__p_interface_82f1308fd516317a ?h ?cottage) (shared__p_interface_82f1308fd516317a ?g ?cottage) (not (shared__p_interface_82f1308fd516317a ?h ?branch)) (not (shared__p_interface_82f1308fd516317a ?g ?branch)))
  )

  (:action d001__a_leave_children_at_fire
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (typeguard__d001__t_entity ?father) (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_entity ?mother) (typeguard__d001__t_location ?forest) (and (shared__p_interface_82f1308fd516317a ?h ?forest) (shared__p_interface_82f1308fd516317a ?g ?forest) (d001__p_fire_lit ?forest) (d001__p_bread_given ?h) (d001__p_bread_given ?g)))
    :effect (and (d001__p_lost ?h) (d001__p_lost ?g))
  )

  (:action d001__a_push_witch_into_oven
    :parameters (?g - object ?witch - object ?oven - object ?room - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?witch) (typeguard__d001__t_item ?oven) (typeguard__d001__t_location ?room) (and (shared__p_interface_82f1308fd516317a ?g ?room) (shared__p_interface_82f1308fd516317a ?witch ?room)))
    :effect (and (d001__p_dead ?witch) (not (shared__p_interface_82f1308fd516317a ?witch ?room)))
  )

  (:action d001__a_return_home_and_reunite_with_father
    :parameters (?father - object ?g - object ?h - object ?father_house - object)
    :precondition (and (typeguard__d001__t_entity ?father) (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?father_house) (and (d001__p_crossed_lake ?h) (d001__p_crossed_lake ?g) (shared__p_interface_82f1308fd516317a ?father ?father_house)))
    :effect (and (shared__p_interface_82f1308fd516317a ?h ?father_house) (shared__p_interface_82f1308fd516317a ?g ?father_house) (d001__p_reunited_with_father ?h) (d001__p_reunited_with_father ?g) (not (d001__p_lost ?h)) (not (d001__p_lost ?g)))
  )

  (:action d001__a_wander_forest_seeking_way_out
    :parameters (?g - object ?h - object ?forest - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_location ?forest) (and (shared__p_interface_82f1308fd516317a ?h ?forest) (shared__p_interface_82f1308fd516317a ?g ?forest)))
    :effect (and (d001__p_lost ?h) (d001__p_lost ?g))
  )

  (:action d001__a_witch_captures_children
    :parameters (?g - object ?h - object ?witch - object ?cottage - object ?stable - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?h) (typeguard__d001__t_entity ?witch) (typeguard__d001__t_location ?cottage) (typeguard__d001__t_location ?stable) (and (shared__p_interface_82f1308fd516317a ?h ?cottage) (shared__p_interface_82f1308fd516317a ?g ?cottage) (not (d001__p_locked ?stable))))
    :effect (and (d001__p_captured ?h) (d001__p_locked ?stable) (shared__p_interface_82f1308fd516317a ?h ?stable) (not (shared__p_interface_82f1308fd516317a ?h ?cottage)))
  )
)
