(define (domain narrative_aligned)
  (:requirements :adl :conditional-effects :negative-preconditions :strips :typing)
  (:constants
    d000__c_apple d000__c_bird d000__c_branch d000__c_bread_piece d000__c_brushwood d000__c_cake d000__c_cottage d000__c_crumb d000__c_dead_tree d000__c_door d000__c_duck d000__c_father d000__c_father_house d000__c_forest d000__c_grettel d000__c_hansel d000__c_hill d000__c_kettle d000__c_lake d000__c_milk d000__c_mother d000__c_nut d000__c_oven d000__c_pancake d000__c_path d000__c_pearl d000__c_pebble d000__c_precious_stone d000__c_roof d000__c_room d000__c_stable_location d000__c_sugar_window d000__c_window d000__c_witch d001__c_axe d001__c_beanstalk d001__c_brown_hen d001__c_butcher d001__c_castle_road d001__c_cottage d001__c_fairy_maiden d001__c_garden d001__c_giant d001__c_giant_castle d001__c_giant_dog d001__c_giant_wife d001__c_gold_bag_1 d001__c_gold_bag_2 d001__c_golden_harp d001__c_jack d001__c_jack_mother d001__c_kettle d001__c_magic_beans d001__c_market d001__c_milky_white d001__c_oak_tree_club d001__c_oven d001__c_window d002__c_apple d002__c_bed d002__c_blood_drop d002__c_boar d002__c_boar_heart d002__c_candle d002__c_coffin d002__c_comb d002__c_cottage d002__c_dove d002__c_dwarf1 d002__c_dwarf2 d002__c_dwarf3 d002__c_dwarf4 d002__c_dwarf5 d002__c_dwarf6 d002__c_dwarf7 d002__c_forest d002__c_fork d002__c_golden_letter d002__c_huntsman d002__c_iron_slippers d002__c_king d002__c_knife d002__c_lace d002__c_looking_glass d002__c_mountain d002__c_mug d002__c_needle d002__c_owl d002__c_plate d002__c_prince d002__c_queen d002__c_raven d002__c_red_hot_shoes d002__c_salt d002__c_snow_white d002__c_spoon - object
  )
  (:predicates
    (case_rescued_with_comb ?x - object)
    (case_role_axe ?x - object)
    (case_role_bird ?x - object)
    (case_role_boar ?x - object)
    (case_role_butcher ?x - object)
    (case_role_comb ?x - object)
    (case_role_companion ?x - object)
    (case_role_cow ?x - object)
    (case_role_cutter ?x - object)
    (case_role_duck ?x - object)
    (case_role_father ?x - object)
    (case_role_gem ?x - object)
    (case_role_giant ?x - object)
    (case_role_giant_wife ?x - object)
    (case_role_huntsman ?x - object)
    (case_role_hut ?x - object)
    (case_role_king ?x - object)
    (case_role_mother ?x - object)
    (case_role_old_woman ?x - object)
    (case_role_place_f ?x - object)
    (case_role_place_l ?x - object)
    (case_role_place_loc ?x - object)
    (case_role_place_mountain ?x - object)
    (case_role_prince ?x - object)
    (case_role_prop_apple ?x - object)
    (case_role_prop_bag1 ?x - object)
    (case_role_prop_bag2 ?x - object)
    (case_role_prop_beans ?x - object)
    (case_role_prop_bed ?x - object)
    (case_role_prop_blood ?x - object)
    (case_role_prop_coffin ?x - object)
    (case_role_prop_crumb ?x - object)
    (case_role_prop_g ?x - object)
    (case_role_prop_harp ?x - object)
    (case_role_prop_heart ?x - object)
    (case_role_prop_hen ?x - object)
    (case_role_prop_kettle ?x - object)
    (case_role_prop_lace ?x - object)
    (case_role_prop_mug ?x - object)
    (case_role_prop_needle ?x - object)
    (case_role_prop_oven ?x - object)
    (case_role_prop_peb ?x - object)
    (case_role_prop_plate ?x - object)
    (case_role_prop_slippers ?x - object)
    (case_role_queen ?x - object)
    (case_role_rescuer ?x - object)
    (case_role_snow_white ?x - object)
    (case_role_witch ?x - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_bird_heard ?a0 - object ?a1 - object)
    (d000__p_bread_given ?a0 - object)
    (d000__p_captured ?a0 - object)
    (d000__p_collected ?a0 - object ?a1 - object)
    (d000__p_crossed_lake ?a0 - object)
    (d000__p_crumb_on_path ?a0 - object)
    (d000__p_duck_helped ?a0 - object ?a1 - object)
    (d000__p_fire_lit ?a0 - object)
    (d000__p_locked ?a0 - object)
    (d000__p_lost ?a0 - object)
    (d000__p_pebble_on_path ?a0 - object)
    (d000__p_reunited_with_father ?a0 - object)
    (d001__p_asleep ?a0 - object)
    (d001__p_at ?a0 - object ?a1 - object)
    (d001__p_at_item ?a0 - object ?a1 - object)
    (d001__p_beanstalk_grown)
    (d001__p_climbing_down ?a0 - object)
    (d001__p_distracted ?a0 - object)
    (d001__p_empty ?a0 - object)
    (d001__p_has ?a0 - object ?a1 - object)
    (d001__p_has_breakfast ?a0 - object)
    (d001__p_inside ?a0 - object ?a1 - object)
    (d001__p_intact ?a0 - object)
    (d001__p_offers ?a0 - object ?a1 - object)
    (d001__p_on ?a0 - object ?a1 - object)
    (d001__p_planted ?a0 - object)
    (d002__p_alive ?a0 - object)
    (d002__p_at ?a0 - object ?a1 - object)
    (d002__p_at_item ?a0 - object ?a1 - object)
    (d002__p_awake ?a0 - object)
    (d002__p_disguised_as ?a0 - object ?a1 - object)
    (d002__p_envious ?a0 - object)
    (d002__p_fair ?a0 - object)
    (d002__p_fairest ?a0 - object)
    (d002__p_in_coffin ?a0 - object)
    (d002__p_laced ?a0 - object ?a1 - object)
    (d002__p_poisoned ?a0 - object)
    (d002__p_sleeping ?a0 - object)
    (d002__p_visited ?a0 - object ?a1 - object)
    (d002__p_wearing ?a0 - object ?a1 - object)
    (shared__p_death ?a0 - object)
    (shared__p_possession ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
    (typeguard__d001__t_entity ?member - object)
    (typeguard__d001__t_item ?member - object)
    (typeguard__d001__t_location ?member - object)
    (typeguard__d001__t_object ?member - object)
    (typeguard__d002__t_entity ?member - object)
    (typeguard__d002__t_item ?member - object)
    (typeguard__d002__t_location ?member - object)
    (typeguard__d002__t_object ?member - object)
  )

  (:action d000__a_abandon_children_in_forest
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?mother) (typeguard__d000__t_location ?forest) (and)) (case_role_father ?father) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_mother ?mother) (case_role_hut ?forest) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_lost ?h) (d000__p_lost ?g) (d000__p_bread_given ?h) (d000__p_bread_given ?g) (d000__p_fire_lit ?forest))
  )

  (:action d000__a_call_duck_for_crossing
    :parameters (?duck - object ?g - object ?h - object ?lake - object)
    :precondition (and (and (typeguard__d000__t_entity ?duck) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?lake) (and (d000__p_at ?h ?lake) (d000__p_at ?g ?lake) (d000__p_at ?duck ?lake))) (case_role_duck ?duck) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?lake) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_duck_helped ?h ?duck) (d000__p_duck_helped ?g ?duck) (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g))
  )

  (:action d000__a_collect_treasure
    :parameters (?g - object ?h - object ?pearl - object ?precious_stone - object ?cottage - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?pearl) (typeguard__d000__t_item ?precious_stone) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_comb ?pearl) (case_role_gem ?precious_stone) (case_role_hut ?cottage) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (shared__p_possession ?h ?pearl) (shared__p_possession ?g ?precious_stone) (d000__p_collected ?h ?pearl) (d000__p_collected ?g ?precious_stone))
  )

  (:action d000__a_drop_breadcrumb_on_path
    :parameters (?h - object ?crumb - object ?path_loc - object)
    :precondition (and (and (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?crumb) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (shared__p_possession ?h ?crumb))) (case_role_rescuer ?h) (case_role_prop_crumb ?crumb) (case_role_hut ?path_loc) (d002__p_alive ?h))
    :effect (and (d000__p_crumb_on_path ?path_loc) (not (shared__p_possession ?h ?crumb)))
  )

  (:action d000__a_drop_pebble_on_path
    :parameters (?h - object ?peb - object ?path_loc - object)
    :precondition (and (and (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?peb) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (shared__p_possession ?h ?peb))) (case_role_rescuer ?h) (case_role_prop_peb ?peb) (case_role_hut ?path_loc) (d002__p_alive ?h))
    :effect (and (d000__p_pebble_on_path ?path_loc) (not (shared__p_possession ?h ?peb)))
  )

  (:action d000__a_enter_witch_house
    :parameters (?g - object ?h - object ?cottage - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?cottage) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (shared__p_possession ?h d000__c_cake) (shared__p_possession ?g d000__c_sugar_window))
  )

  (:action d000__a_escape_from_stable
    :parameters (?g - object ?h - object ?cottage - object ?stable - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?stable) (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?g ?cottage) (d000__p_at ?h ?stable))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?cottage) (case_role_hut ?stable) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_at ?h ?cottage) (not (d000__p_at ?h ?stable)) (not (d000__p_locked ?stable)) (not (d000__p_captured ?h)))
  )

  (:action d000__a_follow_breadcrumbs_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?home) (typeguard__d000__t_location ?path_loc) (and (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?home) (case_role_hut ?path_loc) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (when (and (d000__p_crumb_on_path ?path_loc)) (d000__p_at ?h ?home)) (when (and (d000__p_crumb_on_path ?path_loc)) (d000__p_at ?g ?home)) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_at ?h ?path_loc))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_at ?g ?path_loc))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_lost ?h))) (when (and (d000__p_crumb_on_path ?path_loc)) (not (d000__p_lost ?g))))
  )

  (:action d000__a_follow_pebbles_home
    :parameters (?g - object ?h - object ?home - object ?path_loc - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?home) (typeguard__d000__t_location ?path_loc) (and (d000__p_pebble_on_path ?path_loc) (d000__p_at ?h ?path_loc) (d000__p_at ?g ?path_loc))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?home) (case_role_hut ?path_loc) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_at ?h ?home) (d000__p_at ?g ?home) (not (d000__p_at ?h ?path_loc)) (not (d000__p_at ?g ?path_loc)) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - object ?g - object ?h - object ?branch - object ?cottage - object)
    :precondition (and (and (typeguard__d000__t_entity ?bird) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?branch) (typeguard__d000__t_location ?cottage) (and (d000__p_at ?h ?branch) (d000__p_at ?g ?branch) (d000__p_bird_heard ?h ?branch) (d000__p_bird_heard ?g ?branch))) (case_role_bird ?bird) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?branch) (case_role_hut ?cottage) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_at ?h ?branch)) (not (d000__p_at ?g ?branch)))
  )

  (:action d000__a_leave_children_at_fire
    :parameters (?father - object ?g - object ?h - object ?mother - object ?forest - object)
    :precondition (and (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?mother) (typeguard__d000__t_location ?forest) (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest) (d000__p_fire_lit ?forest) (d000__p_bread_given ?h) (d000__p_bread_given ?g))) (case_role_father ?father) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_mother ?mother) (case_role_hut ?forest) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_push_witch_into_oven
    :parameters (?g - object ?witch - object ?oven - object ?room - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?witch) (typeguard__d000__t_item ?oven) (typeguard__d000__t_location ?room) (and (d000__p_at ?g ?room) (d000__p_at ?witch ?room))) (case_role_companion ?g) (case_role_witch ?witch) (case_role_prop_oven ?oven) (case_role_hut ?room) (d002__p_alive ?g))
    :effect (and (and (shared__p_death ?witch) (not (d002__p_alive ?witch))) (not (d000__p_at ?witch ?room)))
  )

  (:action d000__a_return_home_and_reunite_with_father
    :parameters (?father - object ?g - object ?h - object ?father_house - object)
    :precondition (and (and (typeguard__d000__t_entity ?father) (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?father_house) (and (d000__p_crossed_lake ?h) (d000__p_crossed_lake ?g) (d000__p_at ?father ?father_house))) (case_role_father ?father) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?father_house) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_at ?h ?father_house) (d000__p_at ?g ?father_house) (d000__p_reunited_with_father ?h) (d000__p_reunited_with_father ?g) (not (d000__p_lost ?h)) (not (d000__p_lost ?g)))
  )

  (:action d000__a_wander_forest_seeking_way_out
    :parameters (?g - object ?h - object ?forest - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_location ?forest) (and (d000__p_at ?h ?forest) (d000__p_at ?g ?forest))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_hut ?forest) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_lost ?h) (d000__p_lost ?g))
  )

  (:action d000__a_witch_captures_children
    :parameters (?g - object ?h - object ?witch - object ?cottage - object ?stable - object)
    :precondition (and (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?witch) (typeguard__d000__t_location ?cottage) (typeguard__d000__t_location ?stable) (and (d000__p_at ?h ?cottage) (d000__p_at ?g ?cottage) (not (d000__p_locked ?stable)))) (case_role_companion ?g) (case_role_rescuer ?h) (case_role_witch ?witch) (case_role_hut ?cottage) (case_role_hut ?stable) (d002__p_alive ?g) (d002__p_alive ?h))
    :effect (and (d000__p_captured ?h) (d000__p_locked ?stable) (d000__p_at ?h ?stable) (not (d000__p_at ?h ?cottage)))
  )

  (:action d001__a_ask_giant_wife_for_breakfast
    :parameters (?j - object ?wife - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_entity ?wife) (and (d001__p_at ?j d001__c_giant_castle) (d001__p_at ?wife d001__c_giant_castle))) (case_role_cutter ?j) (case_role_giant_wife ?wife) (d002__p_alive ?j))
    :effect (d001__p_has_breakfast ?j)
  )

  (:action d001__a_climb_beanstalk
    :parameters (?j - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (and (d001__p_beanstalk_grown) (d001__p_at ?j d001__c_beanstalk))) (case_role_cutter ?j) (d002__p_alive ?j))
    :effect (and (d001__p_at ?j d001__c_giant_castle) (not (d001__p_at ?j d001__c_beanstalk)))
  )

  (:action d001__a_cut_beanstalk
    :parameters (?giant - object ?mother - object ?axe - object)
    :precondition (and (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?mother) (typeguard__d001__t_item ?axe) (and (d001__p_intact d001__c_beanstalk) (d001__p_climbing_down ?giant))) (case_role_giant ?giant) (case_role_cutter ?mother) (case_role_axe ?axe) (d002__p_alive ?mother))
    :effect (and (and (and (shared__p_death ?giant) (not (d002__p_alive ?giant))) (not (d001__p_intact d001__c_beanstalk))) (not (d001__p_climbing_down ?giant)))
  )

  (:action d001__a_grow_beanstalk
    :parameters (?beans - object)
    :precondition (and (and (typeguard__d001__t_item ?beans) (d001__p_planted ?beans)) (case_role_prop_beans ?beans))
    :effect (and (d001__p_beanstalk_grown) (d001__p_intact d001__c_beanstalk))
  )

  (:action d001__a_hide_in_kettle
    :parameters (?j - object ?kettle - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?kettle) (and (d001__p_at ?j d001__c_giant_castle) (d001__p_empty ?kettle))) (case_role_cutter ?j) (case_role_prop_kettle ?kettle) (d002__p_alive ?j))
    :effect (and (d001__p_inside ?j ?kettle) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_hide_in_oven
    :parameters (?j - object ?oven - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?oven) (d001__p_at ?j d001__c_giant_castle)) (case_role_cutter ?j) (case_role_prop_oven ?oven) (d002__p_alive ?j))
    :effect (and (d001__p_inside ?j ?oven) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_plant_beans
    :parameters (?beans - object ?loc - object)
    :precondition (and (and (typeguard__d001__t_item ?beans) (typeguard__d001__t_location ?loc) (d001__p_at_item ?beans ?loc)) (case_role_prop_beans ?beans) (case_role_place_loc ?loc))
    :effect (and (d001__p_planted ?beans) (not (d001__p_at_item ?beans ?loc)))
  )

  (:action d001__a_return_down_beanstalk
    :parameters (?j - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (d001__p_at ?j d001__c_giant_castle)) (case_role_cutter ?j) (d002__p_alive ?j))
    :effect (and (d001__p_at ?j d001__c_cottage) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_sell_cow_for_beans
    :parameters (?b - object ?cow - object ?j - object ?beans - object ?l - object)
    :precondition (and (and (typeguard__d001__t_entity ?b) (typeguard__d001__t_entity ?cow) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?beans) (typeguard__d001__t_location ?l) (and (d001__p_at ?j ?l) (d001__p_at ?cow ?l) (d001__p_offers ?b ?beans) (d001__p_at ?b ?l))) (case_role_butcher ?b) (case_role_cow ?cow) (case_role_cutter ?j) (case_role_prop_beans ?beans) (case_role_place_l ?l) (d002__p_alive ?j))
    :effect (and (d001__p_has ?j ?beans) (not (d001__p_offers ?b ?beans)) (not (d001__p_at_item ?beans ?l)))
  )

  (:action d001__a_steal_gold_bags
    :parameters (?j - object ?bag1 - object ?bag2 - object)
    :precondition (and (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?bag1) (typeguard__d001__t_item ?bag2) (and (d001__p_asleep d001__c_giant) (d001__p_at_item ?bag1 d001__c_giant_castle) (d001__p_at_item ?bag2 d001__c_giant_castle))) (case_role_cutter ?j) (case_role_prop_bag1 ?bag1) (case_role_prop_bag2 ?bag2) (d002__p_alive ?j))
    :effect (and (d001__p_has ?j ?bag1) (d001__p_has ?j ?bag2) (not (d001__p_at_item ?bag1 d001__c_giant_castle)) (not (d001__p_at_item ?bag2 d001__c_giant_castle)))
  )

  (:action d001__a_steal_harp
    :parameters (?giant - object ?j - object ?harp - object)
    :precondition (and (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?harp) (and (d001__p_on ?harp d001__c_giant_castle) (d001__p_asleep ?giant))) (case_role_giant ?giant) (case_role_cutter ?j) (case_role_prop_harp ?harp) (d002__p_alive ?j))
    :effect (and (d001__p_has ?j ?harp) (not (d001__p_on ?harp d001__c_giant_castle)))
  )

  (:action d001__a_steal_hen
    :parameters (?giant - object ?j - object ?hen - object)
    :precondition (and (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?hen) (and (d001__p_on ?hen d001__c_giant_castle) (d001__p_distracted ?giant))) (case_role_giant ?giant) (case_role_cutter ?j) (case_role_prop_hen ?hen) (d002__p_alive ?j))
    :effect (and (d001__p_has ?j ?hen) (not (d001__p_on ?hen d001__c_giant_castle)))
  )

  (:action d002__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - object ?apple - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_item ?apple) (and (shared__p_death ?c) (d002__p_poisoned ?apple))) (case_role_snow_white ?c) (case_role_prop_apple ?apple))
    :effect (and (d002__p_alive ?c) (not (shared__p_death ?c)) (not (d002__p_poisoned ?apple)))
  )

  (:action d002__a_child_is_born_and_queen_dies
    :parameters (?c - object ?q - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?q) (and (not (d002__p_alive ?c)) (d002__p_alive ?q))) (case_role_snow_white ?c) (case_role_queen ?q))
    :effect (and (d002__p_alive ?c) (and (shared__p_death ?q) (not (d002__p_alive ?q))) (not (d002__p_alive ?q)))
  )

  (:action d002__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - object ?d - object ?lace - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?d) (typeguard__d002__t_item ?lace) (and (d002__p_laced ?c ?lace) (shared__p_death ?c))) (case_role_snow_white ?c) (case_role_rescuer ?d) (case_role_prop_lace ?lace) (d002__p_alive ?d))
    :effect (and (d002__p_alive ?c) (d002__p_awake ?c) (not (d002__p_laced ?c ?lace)) (not (shared__p_death ?c)))
  )

  (:action d002__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - object ?d - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?d) (and (d002__p_alive ?d) (d002__p_alive ?c) (d002__p_sleeping ?c))) (case_role_snow_white ?c) (case_role_rescuer ?d) (d002__p_alive ?d))
    :effect (and (d002__p_awake ?c) (not (d002__p_sleeping ?c)))
  )

  (:action d002__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - object ?d - object ?coffin - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?d) (typeguard__d002__t_item ?coffin) (shared__p_death ?c)) (case_role_snow_white ?c) (case_role_rescuer ?d) (case_role_prop_coffin ?coffin) (d002__p_alive ?d))
    :effect (and (d002__p_in_coffin ?c) (shared__p_possession ?d ?coffin))
  )

  (:action d002__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - object ?d - object ?comb - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?d) (typeguard__d002__t_item ?comb) (and (shared__p_death ?c) (d002__p_poisoned ?comb) (shared__p_possession ?d ?comb))) (case_role_snow_white ?c) (case_role_rescuer ?d) (case_role_comb ?comb) (d002__p_alive ?d))
    :effect (and (and (d002__p_alive ?c) (not (shared__p_death ?c)) (not (d002__p_poisoned ?comb))) (case_rescued_with_comb ?c))
  )

  (:action d002__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - object ?d - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?d) (and (d002__p_alive ?d) (d002__p_sleeping ?c))) (case_role_snow_white ?c) (case_role_rescuer ?d) (d002__p_alive ?d))
    :effect (d002__p_awake ?d)
  )

  (:action d002__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - object ?c - object ?h - object ?heart - object)
    :precondition (and (and (typeguard__d002__t_entity ?b) (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?h) (typeguard__d002__t_item ?heart) (and (d002__p_alive ?h) (d002__p_alive ?c) (d002__p_alive ?b))) (case_role_boar ?b) (case_role_snow_white ?c) (case_role_huntsman ?h) (case_role_prop_heart ?heart))
    :effect (and (shared__p_possession ?h ?heart) (and (shared__p_death ?b) (not (d002__p_alive ?b))))
  )

  (:action d002__a_king_marries_stepmother
    :parameters (?k - object ?s - object)
    :precondition (and (and (typeguard__d002__t_entity ?k) (typeguard__d002__t_entity ?s) (and (d002__p_alive ?k) (d002__p_alive ?s))) (case_role_king ?k) (case_role_witch ?s))
    :effect (d002__p_fair ?s)
  )

  (:action d002__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - object ?p - object ?coffin - object ?mountain - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?p) (typeguard__d002__t_item ?coffin) (typeguard__d002__t_location ?mountain) (and (d002__p_in_coffin ?c) (d002__p_alive ?p))) (case_role_snow_white ?c) (case_role_prince ?p) (case_role_prop_coffin ?coffin) (case_role_place_mountain ?mountain))
    :effect (d002__p_at_item ?coffin ?mountain)
  )

  (:action d002__a_prince_marries_snow_white
    :parameters (?c - object ?p - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?p) (and (d002__p_alive ?p) (d002__p_alive ?c))) (case_role_snow_white ?c) (case_role_prince ?p))
    :effect (d002__p_fair ?p)
  )

  (:action d002__a_queen_pricks_finger
    :parameters (?q - object ?blood - object ?needle - object)
    :precondition (and (and (typeguard__d002__t_entity ?q) (typeguard__d002__t_item ?blood) (typeguard__d002__t_item ?needle) (and (d002__p_alive ?q) (shared__p_possession ?q ?needle))) (case_role_queen ?q) (case_role_prop_blood ?blood) (case_role_prop_needle ?needle))
    :effect (shared__p_possession ?q ?blood)
  )

  (:action d002__a_queen_sews_at_window
    :parameters (?q - object ?l - object)
    :precondition (and (and (typeguard__d002__t_entity ?q) (typeguard__d002__t_location ?l) (and (d002__p_alive ?q) (d002__p_at ?q ?l))) (case_role_queen ?q) (case_role_place_l ?l))
    :effect (shared__p_possession ?q d002__c_needle)
  )

  (:action d002__a_queen_wishes_child_white_red_black
    :parameters (?c - object ?q - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?q) (d002__p_alive ?q)) (case_role_snow_white ?c) (case_role_queen ?q))
    :effect (d002__p_fair ?c)
  )

  (:action d002__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - object ?apple - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_item ?apple) (and (d002__p_poisoned ?apple) (d002__p_alive ?c))) (case_role_snow_white ?c) (case_role_prop_apple ?apple))
    :effect (and (and (shared__p_death ?c) (not (d002__p_alive ?c))) (not (d002__p_alive ?c)))
  )

  (:action d002__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - object ?mug - object ?plate - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_item ?mug) (typeguard__d002__t_item ?plate) (d002__p_alive ?c)) (case_role_snow_white ?c) (case_role_prop_mug ?mug) (case_role_prop_plate ?plate))
    :effect (and (shared__p_possession ?c ?plate) (shared__p_possession ?c ?mug))
  )

  (:action d002__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - object ?cottage - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_location ?cottage) (d002__p_alive ?c)) (case_role_snow_white ?c) (case_role_hut ?cottage))
    :effect (d002__p_at ?c ?cottage)
  )

  (:action d002__a_snow_white_flees_into_forest
    :parameters (?c - object ?f - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_location ?f) (d002__p_alive ?c)) (case_role_snow_white ?c) (case_role_place_f ?f))
    :effect (d002__p_at ?c ?f)
  )

  (:action d002__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - object ?bed - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_item ?bed) (d002__p_alive ?c)) (case_role_snow_white ?c) (case_role_prop_bed ?bed))
    :effect (d002__p_sleeping ?c)
  )

  (:action d002__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - object ?g - object)
    :precondition (and (and (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?g) (and (d002__p_alive ?s) (shared__p_possession ?s ?g))) (case_role_witch ?s) (case_role_prop_g ?g))
    :effect (d002__p_fairest ?s)
  )

  (:action d002__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - object ?slippers - object)
    :precondition (and (and (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?slippers) (d002__p_alive ?s)) (case_role_witch ?s) (case_role_prop_slippers ?slippers))
    :effect (and (d002__p_wearing ?s ?slippers) (and (shared__p_death ?s) (not (d002__p_alive ?s))) (not (d002__p_alive ?s)))
  )

  (:action d002__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - object ?s - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?s) (and (d002__p_fairest ?c) (d002__p_fair ?c) (d002__p_alive ?s))) (case_role_snow_white ?c) (case_role_witch ?s))
    :effect (d002__p_envious ?s)
  )

  (:action d002__a_stepmother_comb_poison_snow_white
    :parameters (?c - object ?s - object ?comb - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?comb) (and (shared__p_possession ?s ?comb) (d002__p_poisoned ?comb) (d002__p_alive ?c))) (case_role_snow_white ?c) (case_role_witch ?s) (case_role_comb ?comb))
    :effect (and (and (shared__p_death ?c) (not (d002__p_alive ?c))) (not (d002__p_alive ?c)))
  )

  (:action d002__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - object ?s - object ?cottage - object)
    :precondition (and (and (typeguard__d002__t_entity ?old_woman) (typeguard__d002__t_entity ?s) (typeguard__d002__t_location ?cottage) (d002__p_alive ?s)) (case_role_old_woman ?old_woman) (case_role_witch ?s) (case_role_hut ?cottage))
    :effect (and (d002__p_disguised_as ?s ?old_woman) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - object ?heart - object)
    :precondition (and (and (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?heart) (shared__p_possession ?s ?heart)) (case_role_witch ?s) (case_role_prop_heart ?heart))
    :effect (not (shared__p_possession ?s ?heart))
  )

  (:action d002__a_stepmother_laces_snow_white_tightly
    :parameters (?c - object ?s - object ?lace - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?lace) (and (d002__p_alive ?c) (shared__p_possession ?c ?lace))) (case_role_snow_white ?c) (case_role_witch ?s) (case_role_prop_lace ?lace))
    :effect (and (d002__p_laced ?c ?lace) (and (shared__p_death ?c) (not (d002__p_alive ?c))) (not (d002__p_alive ?c)) (not (d002__p_sleeping ?c)))
  )

  (:action d002__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - object ?apple - object ?cottage - object)
    :precondition (and (and (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?apple) (typeguard__d002__t_location ?cottage) (d002__p_alive ?s)) (case_role_witch ?s) (case_role_prop_apple ?apple) (case_role_hut ?cottage))
    :effect (and (d002__p_poisoned ?apple) (shared__p_possession ?s ?apple) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - object ?comb - object ?cottage - object)
    :precondition (and (and (typeguard__d002__t_entity ?s) (typeguard__d002__t_item ?comb) (typeguard__d002__t_location ?cottage) (d002__p_alive ?s)) (case_role_witch ?s) (case_role_comb ?comb) (case_role_hut ?cottage))
    :effect (and (d002__p_poisoned ?comb) (shared__p_possession ?s ?comb) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - object ?h - object ?s - object)
    :precondition (and (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?h) (typeguard__d002__t_entity ?s) (and (d002__p_envious ?s) (d002__p_alive ?h) (d002__p_alive ?c))) (case_role_snow_white ?c) (case_role_huntsman ?h) (case_role_witch ?s))
    :effect (d002__p_fair ?s)
  )
)
