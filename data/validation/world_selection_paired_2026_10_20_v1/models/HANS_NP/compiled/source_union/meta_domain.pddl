(define (domain narrative_union)
  (:requirements :conditional-effects :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_bird d000__c_duck d000__c_father d000__c_grettel d000__c_hansel d000__c_mother d000__c_witch - d000__t_entity
    d000__c_apple d000__c_bread_piece d000__c_brushwood d000__c_cake d000__c_crumb d000__c_kettle d000__c_milk d000__c_nut d000__c_oven d000__c_pancake d000__c_pearl d000__c_pebble d000__c_precious_stone d000__c_sugar_window - d000__t_item
    d000__c_branch d000__c_cottage d000__c_dead_tree d000__c_door d000__c_father_house d000__c_forest d000__c_hill d000__c_lake d000__c_path d000__c_roof d000__c_room d000__c_stable_location d000__c_window - d000__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_bird_heard ?c - d000__t_entity ?l - d000__t_location)
    (d000__p_bread_given ?c - d000__t_entity)
    (d000__p_captured ?c - d000__t_entity)
    (d000__p_collected ?c - d000__t_entity ?i - d000__t_item)
    (d000__p_crossed_lake ?c - d000__t_entity)
    (d000__p_crumb_on_path ?l - d000__t_location)
    (d000__p_dead ?e - d000__t_entity)
    (d000__p_duck_helped ?c - d000__t_entity ?d - d000__t_entity)
    (d000__p_fire_lit ?l - d000__t_location)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_locked ?l - d000__t_location)
    (d000__p_lost ?c - d000__t_entity)
    (d000__p_pebble_on_path ?l - d000__t_location)
    (d000__p_reunited_with_father ?c - d000__t_entity)
  )

  (:action d000__a_abandon_children_in_forest
    :parameters (?father - d000__t_entity ?g - d000__t_entity ?h - d000__t_entity ?mother - d000__t_entity ?forest - d000__t_location)
    :effect (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_lost ?h) (d000__p_lost ?g) (d000__p_bread_given ?h) (d000__p_bread_given ?g) (d000__p_fire_lit ?forest))
  )

  (:action d000__a_call_duck_for_crossing
    :parameters (?duck - d000__t_entity ?g - d000__t_entity ?h - d000__t_entity ?lake - d000__t_location)
    :precondition (and (d000__p_at ?h ?lake) (d000__p_at ?g ?lake) (d000__p_at ?duck ?lake))
    :effect (and (d000__p_duck_helped ?h ?duck) (d000__p_duck_helped ?g ?duck) (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g))
  )

  (:action d000__a_collect_treasure
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?pearl - d000__t_item ?precious_stone - d000__t_item ?cottage - d000__t_location)
    :precondition (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage))
    :effect (and (d000__p_has ?h ?pearl) (d000__p_has ?g ?precious_stone) (d000__p_collected ?h ?pearl) (d000__p_collected ?g ?precious_stone))
  )

  (:action d000__a_drop_breadcrumb_on_path
    :parameters (?h - d000__t_entity ?crumb - d000__t_item ?path_loc - d000__t_location)
    :precondition (and (d000__p_at ?h ?path_loc) (d000__p_has ?h ?crumb))
    :effect (and (d000__p_crumb_on_path ?path_loc) (not (d000__p_has ?h ?crumb)))
  )

  (:action d000__a_drop_pebble_on_path
    :parameters (?h - d000__t_entity ?peb - d000__t_item ?path_loc - d000__t_location)
    :precondition (and (d000__p_at ?h ?path_loc) (d000__p_has ?h ?peb))
    :effect (and (d000__p_pebble_on_path ?path_loc) (not (d000__p_has ?h ?peb)))
  )

  (:action d000__a_enter_witch_house
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?cottage - d000__t_location)
    :precondition (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage))
    :effect (and (d000__p_has ?h d000__c_cake) (d000__p_has ?g d000__c_sugar_window))
  )

  (:action d000__a_escape_from_stable
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?cottage - d000__t_location ?stable - d000__t_location)
    :precondition (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?g ?cottage) (d000__p_at ?h ?stable))
    :effect (and (d000__p_at ?h ?cottage) (not (d000__p_at ?h ?stable)) (not (d000__p_locked ?stable)) (not (d000__p_captured ?h)))
  )

  (:action d000__a_follow_breadcrumbs_home
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?home - d000__t_location ?path_loc - d000__t_location)
    :precondition (and (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc))
    :effect (when (d000__p_crumb_on_path ?path_loc) (and (d000__p_at ?h ?home) (d000__p_at ?g ?home) (not (d000__p_at ?h ?path_loc)) (not (d000__p_at ?g ?path_loc)) (not (d000__p_lost ?h)) (not (d000__p_lost ?g))))
  )

  (:action d000__a_follow_pebbles_home
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?home - d000__t_location ?path_loc - d000__t_location)
    :precondition (and (d000__p_pebble_on_path ?path_loc) (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc))
    :effect (and (d000__p_at ?h ?home) (d000__p_at ?g ?home) (not (d000__p_at ?h ?path_loc)) (not (d000__p_at ?g ?path_loc)) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - d000__t_entity ?g - d000__t_entity ?h - d000__t_entity ?branch - d000__t_location ?cottage - d000__t_location)
    :precondition (and (d000__p_at ?h ?branch) (d000__p_at ?g ?branch) (d000__p_bird_heard ?h ?branch) (d000__p_bird_heard ?g ?branch))
    :effect (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_at ?h ?branch)) (not (d000__p_at ?g ?branch)))
  )

  (:action d000__a_leave_children_at_fire
    :parameters (?father - d000__t_entity ?g - d000__t_entity ?h - d000__t_entity ?mother - d000__t_entity ?forest - d000__t_location)
    :precondition (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_fire_lit ?forest) (d000__p_bread_given ?h) (d000__p_bread_given ?g))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_push_witch_into_oven
    :parameters (?g - d000__t_entity ?witch - d000__t_entity ?oven - d000__t_item ?room - d000__t_location)
    :precondition (and (d000__p_at ?g ?room) (d000__p_at ?witch ?room))
    :effect (and (d000__p_dead ?witch) (not (d000__p_at ?witch ?room)))
  )

  (:action d000__a_return_home_and_reunite_with_father
    :parameters (?father - d000__t_entity ?g - d000__t_entity ?h - d000__t_entity ?father_house - d000__t_location)
    :precondition (and (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g) (d000__p_at ?father ?father_house))
    :effect (and (d000__p_at ?h ?father_house) (d000__p_at ?g ?father_house) (d000__p_reunited_with_father ?h) (d000__p_reunited_with_father ?g) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_wander_forest_seeking_way_out
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?forest - d000__t_location)
    :precondition (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_witch_captures_children
    :parameters (?g - d000__t_entity ?h - d000__t_entity ?witch - d000__t_entity ?cottage - d000__t_location ?stable - d000__t_location)
    :precondition (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_locked ?stable)))
    :effect (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?h ?stable) (not (d000__p_at ?h ?cottage)))
  )
)
