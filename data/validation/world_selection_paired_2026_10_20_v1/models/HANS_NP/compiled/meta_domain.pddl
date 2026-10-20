(define (domain narrative_aligned)
  (:requirements :adl :conditional-effects :negative-preconditions :strips :typing)
  (:constants
    d000__c_apple d000__c_bird d000__c_branch d000__c_bread_piece d000__c_brushwood d000__c_cake d000__c_cottage d000__c_crumb d000__c_dead_tree d000__c_door d000__c_duck d000__c_father d000__c_father_house d000__c_forest d000__c_grettel d000__c_hansel d000__c_hill d000__c_kettle d000__c_lake d000__c_milk d000__c_mother d000__c_nut d000__c_oven d000__c_pancake d000__c_path d000__c_pearl d000__c_pebble d000__c_precious_stone d000__c_roof d000__c_room d000__c_stable_location d000__c_sugar_window d000__c_window d000__c_witch - object
  )
  (:predicates
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_bird_heard ?a0 - object ?a1 - object)
    (d000__p_bread_given ?a0 - object)
    (d000__p_captured ?a0 - object)
    (d000__p_collected ?a0 - object ?a1 - object)
    (d000__p_crossed_lake ?a0 - object)
    (d000__p_crumb_on_path ?a0 - object)
    (d000__p_dead ?a0 - object)
    (d000__p_duck_helped ?a0 - object ?a1 - object)
    (d000__p_fire_lit ?a0 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_locked ?a0 - object)
    (d000__p_lost ?a0 - object)
    (d000__p_pebble_on_path ?a0 - object)
    (d000__p_reunited_with_father ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_abandon_children_in_forest
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?mother) (typeguard__d000__t_location ?forest) (and))
    :effect (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_lost ?h) (d000__p_lost ?g) (d000__p_bread_given ?h) (d000__p_bread_given ?g) (d000__p_fire_lit ?forest))
  )

  (:action d000__a_call_duck_for_crossing
    :parameters (?duck - object ?g - object ?h - object ?lake - object)
    :precondition (and (typeguard__d000__t_entity ?duck) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?lake) (and (d000__p_at ?h ?lake) (d000__p_at ?g ?lake) (d000__p_at ?duck ?lake)))
    :effect (and (d000__p_duck_helped ?h ?duck) (d000__p_duck_helped ?g ?duck) (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g))
  )

  (:action d000__a_collect_treasure
    :parameters (?g - object ?h - object ?pearl - object ?precious_stone - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?pearl) (typeguard__d000__t_item ?precious_stone) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage)))
    :effect (and (d000__p_has ?h ?pearl) (d000__p_has ?g ?precious_stone) (d000__p_collected ?h ?pearl) (d000__p_collected ?g ?precious_stone))
  )

  (:action d000__a_drop_breadcrumb_on_path
    :parameters (?h - object ?crumb - object ?path_loc - object)
    :precondition (and (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?crumb) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (d000__p_has ?h ?crumb)))
    :effect (and (d000__p_crumb_on_path ?path_loc) (not (d000__p_has ?h ?crumb)))
  )

  (:action d000__a_drop_pebble_on_path
    :parameters (?h - object ?peb - object ?path_loc - object)
    :precondition (and (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?peb) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (d000__p_has ?h ?peb)))
    :effect (and (d000__p_pebble_on_path ?path_loc) (not (d000__p_has ?h ?peb)))
  )

  (:action d000__a_enter_witch_house
    :parameters (?g - object ?h - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage)))
    :effect (and (d000__p_has ?h d000__c_cake) (d000__p_has ?g d000__c_sugar_window))
  )

  (:action d000__a_escape_from_stable
    :parameters (?g - object ?h - object ?cottage - object ?stable - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?stable) (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?g ?cottage) (d000__p_at ?h ?stable)))
    :effect (and (d000__p_at ?h ?cottage) (not (d000__p_at ?h ?stable)) (not (d000__p_locked ?stable)) (not (d000__p_captured ?h)))
  )

  (:action d000__a_follow_breadcrumbs_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?home) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc)))
    :effect (and (when (and (d000__p_crumb_on_path ?path_loc)) (d000__p_at ?h ?home)) (when (and (d000__p_crumb_on_path ?path_loc)) (d000__p_at ?g ?home)) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_at ?h ?path_loc))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_at ?g ?path_loc))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_lost ?h))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_lost ?g))))
  )

  (:action d000__a_follow_pebbles_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?home) (typeguard__d000__t_location ?path_loc) (and (d000__p_pebble_on_path ?path_loc) (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc)))
    :effect (and (d000__p_at ?h ?home) (d000__p_at ?g ?home) (not (d000__p_at ?h ?path_loc)) (not (d000__p_at ?g ?path_loc)) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - object ?g - object ?h - object ?branch - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?bird) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?branch) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?branch) (d000__p_at ?g ?branch) (d000__p_bird_heard ?h ?branch) (d000__p_bird_heard ?g ?branch)))
    :effect (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_at ?h ?branch)) (not (d000__p_at ?g ?branch)))
  )

  (:action d000__a_leave_children_at_fire
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?mother) (typeguard__d000__t_location ?forest) (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_fire_lit ?forest) (d000__p_bread_given ?h) (d000__p_bread_given ?g)))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_push_witch_into_oven
    :parameters (?g - object ?witch - object ?oven - object ?room - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?witch) (typeguard__d000__t_item ?oven) (typeguard__d000__t_location ?room) (and (d000__p_at ?g ?room) (d000__p_at ?witch ?room)))
    :effect (and (d000__p_dead ?witch) (not (d000__p_at ?witch ?room)))
  )

  (:action d000__a_return_home_and_reunite_with_father
    :parameters (?father - object ?g - object ?h - object ?father_house - object)
    :precondition (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?father_house) (and (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g) (d000__p_at ?father ?father_house)))
    :effect (and (d000__p_at ?h ?father_house) (d000__p_at ?g ?father_house) (d000__p_reunited_with_father ?h) (d000__p_reunited_with_father ?g) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_wander_forest_seeking_way_out
    :parameters (?g - object ?h - object ?forest - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?forest) (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest)))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_witch_captures_children
    :parameters (?g - object ?h - object ?witch - object ?cottage - object ?stable - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?witch) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?stable) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_locked ?stable))))
    :effect (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?h ?stable) (not (d000__p_at ?h ?cottage)))
  )
)
