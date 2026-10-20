(define (domain narrative_union)
  (:requirements :conditional-effects :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d001__t_entity d001__t_item d001__t_location - d001__t_object
    d002__t_entity d002__t_item d002__t_location - d002__t_object
    d000__t_object d001__t_object d002__t_object - object
  )
  (:constants
    d000__c_bird d000__c_duck d000__c_father d000__c_grettel d000__c_hansel d000__c_mother d000__c_witch - d000__t_entity
    d000__c_apple d000__c_bread_piece d000__c_brushwood d000__c_cake d000__c_crumb d000__c_kettle d000__c_milk d000__c_nut d000__c_oven d000__c_pancake d000__c_pearl d000__c_pebble d000__c_precious_stone d000__c_sugar_window - d000__t_item
    d000__c_branch d000__c_cottage d000__c_dead_tree d000__c_door d000__c_father_house d000__c_forest d000__c_hill d000__c_lake d000__c_path d000__c_roof d000__c_room d000__c_stable_location d000__c_window - d000__t_location
    d001__c_brown_hen d001__c_butcher d001__c_fairy_maiden d001__c_giant d001__c_giant_dog d001__c_giant_wife d001__c_jack d001__c_jack_mother d001__c_milky_white - d001__t_entity
    d001__c_axe d001__c_gold_bag_1 d001__c_gold_bag_2 d001__c_golden_harp d001__c_magic_beans d001__c_oak_tree_club - d001__t_item
    d001__c_beanstalk d001__c_castle_road d001__c_cottage d001__c_garden d001__c_giant_castle d001__c_kettle d001__c_market d001__c_oven d001__c_window - d001__t_location
    d002__c_boar d002__c_dove d002__c_dwarf1 d002__c_dwarf2 d002__c_dwarf3 d002__c_dwarf4 d002__c_dwarf5 d002__c_dwarf6 d002__c_dwarf7 d002__c_huntsman d002__c_king d002__c_owl d002__c_prince d002__c_queen d002__c_raven d002__c_snow_white - d002__t_entity
    d002__c_apple d002__c_bed d002__c_blood_drop d002__c_boar_heart d002__c_candle d002__c_coffin d002__c_comb d002__c_fork d002__c_golden_letter d002__c_iron_slippers d002__c_knife d002__c_lace d002__c_looking_glass d002__c_mug d002__c_needle d002__c_plate d002__c_red_hot_shoes d002__c_salt d002__c_spoon - d002__t_item
    d002__c_cottage d002__c_forest d002__c_mountain - d002__t_location
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
    (d001__p_asleep ?e - d001__t_entity)
    (d001__p_at ?e - d001__t_entity ?l - d001__t_location)
    (d001__p_at_item ?i - d001__t_item ?l - d001__t_location)
    (d001__p_beanstalk_grown)
    (d001__p_climbing_down ?e - d001__t_entity)
    (d001__p_dead ?e - d001__t_entity)
    (d001__p_distracted ?e - d001__t_entity)
    (d001__p_empty ?i - d001__t_item)
    (d001__p_has ?e - d001__t_entity ?i - d001__t_item)
    (d001__p_has_breakfast ?e - d001__t_entity)
    (d001__p_inside ?e - d001__t_entity ?i - d001__t_item)
    (d001__p_intact ?l - d001__t_location)
    (d001__p_offers ?e - d001__t_entity ?i - d001__t_item)
    (d001__p_on ?i - d001__t_item ?l - d001__t_location)
    (d001__p_planted ?i - d001__t_item)
    (d002__p_alive ?e - d002__t_entity)
    (d002__p_at ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_at_item ?i - d002__t_item ?l - d002__t_location)
    (d002__p_awake ?e - d002__t_entity)
    (d002__p_dead ?e - d002__t_entity)
    (d002__p_disguised_as ?e - d002__t_entity ?d - d002__t_entity)
    (d002__p_envious ?e - d002__t_entity)
    (d002__p_fair ?e - d002__t_entity)
    (d002__p_fairest ?e - d002__t_entity)
    (d002__p_has ?e - d002__t_entity ?i - d002__t_item)
    (d002__p_in_coffin ?e - d002__t_entity)
    (d002__p_laced ?e - d002__t_entity ?i - d002__t_item)
    (d002__p_poisoned ?i - d002__t_item)
    (d002__p_sleeping ?e - d002__t_entity)
    (d002__p_visited ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_wearing ?e - d002__t_entity ?i - d002__t_item)
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

  (:action d001__a_ask_giant_wife_for_breakfast
    :parameters (?j - d001__t_entity ?wife - d001__t_entity)
    :precondition (and (d001__p_at ?j d001__c_giant_castle) (d001__p_at ?wife d001__c_giant_castle))
    :effect (d001__p_has_breakfast ?j)
  )

  (:action d001__a_climb_beanstalk
    :parameters (?j - d001__t_entity)
    :precondition (and (d001__p_beanstalk_grown) (d001__p_at ?j d001__c_beanstalk))
    :effect (and (d001__p_at ?j d001__c_giant_castle) (not (d001__p_at ?j d001__c_beanstalk)))
  )

  (:action d001__a_cut_beanstalk
    :parameters (?giant - d001__t_entity ?mother - d001__t_entity ?axe - d001__t_item)
    :precondition (and (d001__p_intact d001__c_beanstalk) (d001__p_climbing_down ?giant))
    :effect (and (d001__p_dead ?giant) (not (d001__p_intact d001__c_beanstalk)))
  )

  (:action d001__a_grow_beanstalk
    :parameters (?beans - d001__t_item)
    :precondition (d001__p_planted ?beans)
    :effect (and (d001__p_beanstalk_grown) (d001__p_intact d001__c_beanstalk))
  )

  (:action d001__a_hide_in_kettle
    :parameters (?j - d001__t_entity ?kettle - d001__t_item)
    :precondition (and (d001__p_at ?j d001__c_giant_castle) (d001__p_empty ?kettle))
    :effect (and (d001__p_inside ?j ?kettle) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_hide_in_oven
    :parameters (?j - d001__t_entity ?oven - d001__t_item)
    :precondition (d001__p_at ?j d001__c_giant_castle)
    :effect (and (d001__p_inside ?j ?oven) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_plant_beans
    :parameters (?beans - d001__t_item ?loc - d001__t_location)
    :precondition (d001__p_at_item ?beans ?loc)
    :effect (and (d001__p_planted ?beans) (not (d001__p_at_item ?beans ?loc)))
  )

  (:action d001__a_return_down_beanstalk
    :parameters (?j - d001__t_entity)
    :precondition (d001__p_at ?j d001__c_giant_castle)
    :effect (and (d001__p_at ?j d001__c_cottage) (not (d001__p_at ?j d001__c_giant_castle)))
  )

  (:action d001__a_sell_cow_for_beans
    :parameters (?b - d001__t_entity ?cow - d001__t_entity ?j - d001__t_entity ?beans - d001__t_item ?l - d001__t_location)
    :precondition (and (d001__p_at ?j ?l) (d001__p_at ?cow ?l) (d001__p_offers ?b ?beans) (d001__p_at ?b ?l))
    :effect (and (d001__p_has ?j ?beans) (not (d001__p_offers ?b ?beans)) (not (d001__p_at_item ?beans ?l)))
  )

  (:action d001__a_steal_gold_bags
    :parameters (?j - d001__t_entity ?bag1 - d001__t_item ?bag2 - d001__t_item)
    :precondition (and (d001__p_asleep d001__c_giant) (d001__p_at_item ?bag1 d001__c_giant_castle) (d001__p_at_item ?bag2 d001__c_giant_castle))
    :effect (and (d001__p_has ?j ?bag1) (d001__p_has ?j ?bag2) (not (d001__p_at_item ?bag1 d001__c_giant_castle)) (not (d001__p_at_item ?bag2 d001__c_giant_castle)))
  )

  (:action d001__a_steal_harp
    :parameters (?giant - d001__t_entity ?j - d001__t_entity ?harp - d001__t_item)
    :precondition (and (d001__p_on ?harp d001__c_giant_castle) (d001__p_asleep ?giant))
    :effect (and (d001__p_has ?j ?harp) (not (d001__p_on ?harp d001__c_giant_castle)))
  )

  (:action d001__a_steal_hen
    :parameters (?giant - d001__t_entity ?j - d001__t_entity ?hen - d001__t_item)
    :precondition (and (d001__p_on ?hen d001__c_giant_castle) (d001__p_distracted ?giant))
    :effect (and (d001__p_has ?j ?hen) (not (d001__p_on ?hen d001__c_giant_castle)))
  )

  (:action d002__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - d002__t_entity ?apple - d002__t_item)
    :precondition (and (d002__p_dead ?c) (d002__p_poisoned ?apple))
    :effect (and (d002__p_alive ?c) (not (d002__p_dead ?c)) (not (d002__p_poisoned ?apple)))
  )

  (:action d002__a_child_is_born_and_queen_dies
    :parameters (?c - d002__t_entity ?q - d002__t_entity)
    :precondition (and (not (d002__p_alive ?c)) (d002__p_alive ?q))
    :effect (and (d002__p_alive ?c) (d002__p_dead ?q) (not (d002__p_alive ?q)))
  )

  (:action d002__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - d002__t_entity ?d - d002__t_entity ?lace - d002__t_item)
    :precondition (and (d002__p_laced ?c ?lace) (d002__p_dead ?c))
    :effect (and (d002__p_alive ?c) (d002__p_awake ?c) (not (d002__p_laced ?c ?lace)) (not (d002__p_dead ?c)))
  )

  (:action d002__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - d002__t_entity ?d - d002__t_entity)
    :precondition (and (d002__p_alive ?d) (d002__p_alive ?c) (d002__p_sleeping ?c))
    :effect (and (d002__p_awake ?c) (not (d002__p_sleeping ?c)))
  )

  (:action d002__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - d002__t_entity ?d - d002__t_entity ?coffin - d002__t_item)
    :precondition (d002__p_dead ?c)
    :effect (and (d002__p_in_coffin ?c) (d002__p_has ?d ?coffin))
  )

  (:action d002__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - d002__t_entity ?d - d002__t_entity ?comb - d002__t_item)
    :precondition (and (d002__p_dead ?c) (d002__p_poisoned ?comb) (d002__p_has ?d ?comb))
    :effect (and (d002__p_alive ?c) (not (d002__p_dead ?c)) (not (d002__p_poisoned ?comb)))
  )

  (:action d002__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - d002__t_entity ?d - d002__t_entity)
    :precondition (and (d002__p_alive ?d) (d002__p_sleeping ?c))
    :effect (d002__p_awake ?d)
  )

  (:action d002__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - d002__t_entity ?c - d002__t_entity ?h - d002__t_entity ?heart - d002__t_item)
    :precondition (and (d002__p_alive ?h) (d002__p_alive ?c) (d002__p_alive ?b))
    :effect (and (d002__p_has ?h ?heart) (d002__p_dead ?b))
  )

  (:action d002__a_king_marries_stepmother
    :parameters (?k - d002__t_entity ?s - d002__t_entity)
    :precondition (and (d002__p_alive ?k) (d002__p_alive ?s))
    :effect (d002__p_fair ?s)
  )

  (:action d002__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - d002__t_entity ?p - d002__t_entity ?coffin - d002__t_item ?mountain - d002__t_location)
    :precondition (and (d002__p_in_coffin ?c) (d002__p_alive ?p))
    :effect (d002__p_at_item ?coffin ?mountain)
  )

  (:action d002__a_prince_marries_snow_white
    :parameters (?c - d002__t_entity ?p - d002__t_entity)
    :precondition (and (d002__p_alive ?p) (d002__p_alive ?c))
    :effect (d002__p_fair ?p)
  )

  (:action d002__a_queen_pricks_finger
    :parameters (?q - d002__t_entity ?blood - d002__t_item ?needle - d002__t_item)
    :precondition (and (d002__p_alive ?q) (d002__p_has ?q ?needle))
    :effect (d002__p_has ?q ?blood)
  )

  (:action d002__a_queen_sews_at_window
    :parameters (?q - d002__t_entity ?l - d002__t_location)
    :precondition (and (d002__p_alive ?q) (d002__p_at ?q ?l))
    :effect (d002__p_has ?q d002__c_needle)
  )

  (:action d002__a_queen_wishes_child_white_red_black
    :parameters (?c - d002__t_entity ?q - d002__t_entity)
    :precondition (d002__p_alive ?q)
    :effect (d002__p_fair ?c)
  )

  (:action d002__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - d002__t_entity ?apple - d002__t_item)
    :precondition (and (d002__p_poisoned ?apple) (d002__p_alive ?c))
    :effect (and (d002__p_dead ?c) (not (d002__p_alive ?c)))
  )

  (:action d002__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - d002__t_entity ?mug - d002__t_item ?plate - d002__t_item)
    :precondition (d002__p_alive ?c)
    :effect (and (d002__p_has ?c ?plate) (d002__p_has ?c ?mug))
  )

  (:action d002__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - d002__t_entity ?cottage - d002__t_location)
    :precondition (d002__p_alive ?c)
    :effect (d002__p_at ?c ?cottage)
  )

  (:action d002__a_snow_white_flees_into_forest
    :parameters (?c - d002__t_entity ?f - d002__t_location)
    :precondition (d002__p_alive ?c)
    :effect (d002__p_at ?c ?f)
  )

  (:action d002__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - d002__t_entity ?bed - d002__t_item)
    :precondition (d002__p_alive ?c)
    :effect (d002__p_sleeping ?c)
  )

  (:action d002__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - d002__t_entity ?g - d002__t_item)
    :precondition (and (d002__p_alive ?s) (d002__p_has ?s ?g))
    :effect (d002__p_fairest ?s)
  )

  (:action d002__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - d002__t_entity ?slippers - d002__t_item)
    :precondition (d002__p_alive ?s)
    :effect (and (d002__p_wearing ?s ?slippers) (d002__p_dead ?s) (not (d002__p_alive ?s)))
  )

  (:action d002__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - d002__t_entity ?s - d002__t_entity)
    :precondition (and (d002__p_fairest ?c) (d002__p_fair ?c) (d002__p_alive ?s))
    :effect (d002__p_envious ?s)
  )

  (:action d002__a_stepmother_comb_poison_snow_white
    :parameters (?c - d002__t_entity ?s - d002__t_entity ?comb - d002__t_item)
    :precondition (and (d002__p_has ?s ?comb) (d002__p_poisoned ?comb) (d002__p_alive ?c))
    :effect (and (d002__p_dead ?c) (not (d002__p_alive ?c)))
  )

  (:action d002__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - d002__t_entity ?s - d002__t_entity ?cottage - d002__t_location)
    :precondition (d002__p_alive ?s)
    :effect (and (d002__p_disguised_as ?s ?old_woman) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - d002__t_entity ?heart - d002__t_item)
    :precondition (d002__p_has ?s ?heart)
    :effect (not (d002__p_has ?s ?heart))
  )

  (:action d002__a_stepmother_laces_snow_white_tightly
    :parameters (?c - d002__t_entity ?s - d002__t_entity ?lace - d002__t_item)
    :precondition (and (d002__p_alive ?c) (d002__p_has ?c ?lace))
    :effect (and (d002__p_laced ?c ?lace) (d002__p_dead ?c) (not (d002__p_alive ?c)) (not (d002__p_sleeping ?c)))
  )

  (:action d002__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - d002__t_entity ?apple - d002__t_item ?cottage - d002__t_location)
    :precondition (d002__p_alive ?s)
    :effect (and (d002__p_poisoned ?apple) (d002__p_has ?s ?apple) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - d002__t_entity ?comb - d002__t_item ?cottage - d002__t_location)
    :precondition (d002__p_alive ?s)
    :effect (and (d002__p_poisoned ?comb) (d002__p_has ?s ?comb) (d002__p_visited ?s ?cottage))
  )

  (:action d002__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - d002__t_entity ?h - d002__t_entity ?s - d002__t_entity)
    :precondition (and (d002__p_envious ?s) (d002__p_alive ?h) (d002__p_alive ?c))
    :effect (d002__p_fair ?s)
  )
)
