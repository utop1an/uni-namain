(define (domain narrative_aligned)
  (:requirements :adl :existential-preconditions :negative-preconditions :strips :typing)
  (:constants
    d000__c_beech_tree d000__c_bench d000__c_boat d000__c_corridor d000__c_cottage d000__c_door d000__c_dryad d000__c_fairy_queen d000__c_fairyland d000__c_gnome d000__c_gold_star d000__c_grandmother d000__c_grandmotherkin d000__c_key d000__c_lantern d000__c_mother d000__c_mothereen d000__c_nora d000__c_palace d000__c_pellet d000__c_pond d000__c_silver_salver d000__c_spring d000__c_stairs d000__c_stream d001__c_axe d001__c_beanstalk d001__c_brown_hen d001__c_butcher d001__c_castle_road d001__c_cottage d001__c_fairy_maiden d001__c_garden d001__c_giant d001__c_giant_castle d001__c_giant_dog d001__c_giant_wife d001__c_gold_bag_1 d001__c_gold_bag_2 d001__c_golden_harp d001__c_jack d001__c_jack_mother d001__c_kettle d001__c_magic_beans d001__c_market d001__c_milky_white d001__c_oak_tree_club d001__c_oven d001__c_window d002__c_bungo d002__c_chalk d002__c_comet_house d002__c_comet_master d002__c_courtyard d002__c_earth d002__c_gate d002__c_long_tail_45 d002__c_meteor d002__c_meteor_keeper d002__c_no1_express d002__c_short_tail_73 d002__c_slate d002__c_sun d003__c_apple d003__c_brick_house d003__c_bricks d003__c_butter_churn d003__c_chimney d003__c_farmer d003__c_fire d003__c_furze_bundle d003__c_furze_house d003__c_hearth d003__c_hill d003__c_man_bricks d003__c_man_furze d003__c_man_straw d003__c_mortar d003__c_mother_pig d003__c_oak_forest d003__c_pig1 d003__c_pig2 d003__c_pig3 d003__c_pig_home d003__c_pot_of_water d003__c_sack d003__c_squire d003__c_squire_orchard d003__c_straw_bundle d003__c_straw_house d003__c_town_fair d003__c_trowel d003__c_turnip_field d003__c_turnips_load d003__c_wolf d004__c_ass d004__c_bag d004__c_boots d004__c_coachman d004__c_eldest_son d004__c_field_of_corn d004__c_field_of_wheat d004__c_groom d004__c_hare d004__c_jack d004__c_king d004__c_mill d004__c_miller d004__c_ogre d004__c_ogre_castle d004__c_palace d004__c_partridge d004__c_princess d004__c_puss d004__c_rabbit d004__c_river d004__c_royal_wardrobe d004__c_second_son d004__c_suit d004__c_warren d005__c_back_door d005__c_back_stairs d005__c_bag_of_rubies d005__c_bag_of_sapphires d005__c_city d005__c_crown d005__c_father_king d005__c_forest d005__c_impostor_butterman d005__c_king_at_palace d005__c_market_place d005__c_oak_tree d005__c_palace d005__c_princess d005__c_robber_chief d005__c_sceptre d006__c_big_house d006__c_bitter_woe d006__c_cattle d006__c_children d006__c_copecks_25 d006__c_forest d006__c_gold_pot d006__c_grove d006__c_harrow d006__c_honey d006__c_izba d006__c_kabak d006__c_large_town d006__c_loaf_bread d006__c_new_home d006__c_plow d006__c_poor_brother d006__c_rich_brother d006__c_sledge d006__c_stone d006__c_telega d006__c_treasure_pit d006__c_village d006__c_well d006__c_wife d006__c_wine d006__c_yard - object
  )
  (:predicates
    (d000__p_boat_available ?a0 - object ?a1 - object)
    (d000__p_corridor_reached ?a0 - object)
    (d000__p_door_open ?a0 - object)
    (d000__p_gloomy ?a0 - object)
    (d000__p_gold_star_on ?a0 - object ?a1 - object)
    (d000__p_inside ?a0 - object ?a1 - object)
    (d000__p_invitation_offered ?a0 - object ?a1 - object)
    (d000__p_joyful ?a0 - object)
    (d000__p_kissed_by ?a0 - object ?a1 - object)
    (d000__p_knighted ?a0 - object)
    (d000__p_lantern_carried ?a0 - object ?a1 - object)
    (d000__p_pellet_eaten ?a0 - object)
    (d000__p_shrunk ?a0 - object)
    (d000__p_sound_heard ?a0 - object ?a1 - object)
    (d000__p_stairs_descended ?a0 - object)
    (d000__p_story_shared ?a0 - object ?a1 - object)
    (d001__p_asleep ?a0 - object)
    (d001__p_at_item ?a0 - object ?a1 - object)
    (d001__p_beanstalk_grown)
    (d001__p_climbing_down ?a0 - object)
    (d001__p_dead ?a0 - object)
    (d001__p_distracted ?a0 - object)
    (d001__p_empty ?a0 - object)
    (d001__p_has_breakfast ?a0 - object)
    (d001__p_inside ?a0 - object ?a1 - object)
    (d001__p_intact ?a0 - object)
    (d001__p_offers ?a0 - object ?a1 - object)
    (d001__p_on ?a0 - object ?a1 - object)
    (d001__p_planted ?a0 - object)
    (d002__p_arrested ?a0 - object ?a1 - object)
    (d002__p_avoid ?a0 - object ?a1 - object)
    (d002__p_burned ?a0 - object)
    (d002__p_crossed_out ?a0 - object)
    (d002__p_delivered ?a0 - object ?a1 - object)
    (d002__p_detained ?a0 - object)
    (d002__p_gate_open)
    (d002__p_has_mission ?a0 - object)
    (d002__p_left_turn_rule ?a0 - object)
    (d002__p_near ?a0 - object ?a1 - object)
    (d002__p_on_list ?a0 - object)
    (d002__p_prohibit_speak ?a0 - object)
    (d002__p_punished ?a0 - object)
    (d002__p_rule_violation ?a0 - object)
    (d002__p_speaks_to ?a0 - object ?a1 - object)
    (d002__p_summoned ?a0 - object)
    (d002__p_traveling ?a0 - object)
    (d003__p_alive ?a0 - object)
    (d003__p_boiling ?a0 - object)
    (d003__p_dead ?a0 - object)
    (d003__p_door_closed ?a0 - object)
    (d003__p_entry_denied ?a0 - object ?a1 - object)
    (d003__p_entry_requested ?a0 - object ?a1 - object)
    (d003__p_escaped ?a0 - object)
    (d003__p_has_bundle ?a0 - object ?a1 - object)
    (d003__p_house ?a0 - object ?a1 - object)
    (d003__p_house_destroyed ?a0 - object)
    (d003__p_house_intact ?a0 - object)
    (d003__p_huffed ?a0 - object)
    (d003__p_inside ?a0 - object ?a1 - object)
    (d003__p_material_requested ?a0 - object ?a1 - object)
    (d003__p_over ?a0 - object ?a1 - object)
    (d003__p_plan ?a0 - object ?a1 - object)
    (d003__p_puffed ?a0 - object)
    (d003__p_rolling ?a0 - object)
    (d003__p_under ?a0 - object ?a1 - object)
    (d004__p_alive ?a0 - object)
    (d004__p_at_item ?a0 - object ?a1 - object)
    (d004__p_castle_owned_by ?a0 - object ?a1 - object)
    (d004__p_contains ?a0 - object ?a1 - object)
    (d004__p_drowning ?a0 - object)
    (d004__p_gate_open ?a0 - object)
    (d004__p_gift_delivered ?a0 - object ?a1 - object ?a2 - object)
    (d004__p_has ?a0 - object ?a1 - object)
    (d004__p_married ?a0 - object ?a1 - object)
    (d004__p_obedient ?a0 - object)
    (d004__p_promised_to_serve ?a0 - object ?a1 - object)
    (d004__p_rescued_by ?a0 - object ?a1 - object)
    (d004__p_transformed_into ?a0 - object ?a1 - object)
    (d004__p_wearing ?a0 - object ?a1 - object)
    (d005__p_grandmother_mangle_spoken)
    (d005__p_has ?a0 - object ?a1 - object)
    (d005__p_married ?a0 - object ?a1 - object)
    (d005__p_price_of_butter_spoken)
    (d005__p_with_all_my_heart_spoken)
    (d006__p_banquet_at ?a0 - object)
    (d006__p_bowed ?a0 - object ?a1 - object)
    (d006__p_concealed ?a0 - object)
    (d006__p_drunk ?a0 - object)
    (d006__p_employed ?a0 - object ?a1 - object)
    (d006__p_gold_at ?a0 - object ?a1 - object)
    (d006__p_guest_present ?a0 - object ?a1 - object)
    (d006__p_has ?a0 - object ?a1 - object)
    (d006__p_has_fatigue ?a0 - object)
    (d006__p_has_strength ?a0 - object)
    (d006__p_invitation_sent ?a0 - object ?a1 - object)
    (d006__p_invited ?a0 - object ?a1 - object)
    (d006__p_need_help ?a0 - object)
    (d006__p_poor ?a0 - object)
    (d006__p_rich ?a0 - object)
    (d006__p_singing ?a0 - object)
    (d006__p_stone_at ?a0 - object ?a1 - object)
    (d006__p_stone_moved ?a0 - object)
    (d006__p_trapped ?a0 - object)
    (d006__p_woe_on_shoulder ?a0 - object ?a1 - object)
    (d006__p_work_done ?a0 - object ?a1 - object)
    (shared__p_interface_0f71a7a314338daa ?a0 - object ?a1 - object)
    (shared__p_interface_9420e6a250b7a1e0 ?a0 - object ?a1 - object)
    (shared__p_interface_9e2dfe3e7cd5d53e ?a0 - object ?a1 - object)
    (shared__p_interface_b525a0d27c2e45f3 ?a0 - object ?a1 - object)
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
    (typeguard__d003__t_entity ?member - object)
    (typeguard__d003__t_item ?member - object)
    (typeguard__d003__t_location ?member - object)
    (typeguard__d003__t_object ?member - object)
    (typeguard__d004__t_entity ?member - object)
    (typeguard__d004__t_item ?member - object)
    (typeguard__d004__t_location ?member - object)
    (typeguard__d004__t_object ?member - object)
    (typeguard__d005__t_entity ?member - object)
    (typeguard__d005__t_item ?member - object)
    (typeguard__d005__t_location ?member - object)
    (typeguard__d005__t_object ?member - object)
    (typeguard__d006__t_entity ?member - object)
    (typeguard__d006__t_item ?member - object)
    (typeguard__d006__t_location ?member - object)
    (typeguard__d006__t_object ?member - object)
  )

  (:action d000__a_accept_dryad_invitation
    :parameters (?d - object ?n - object)
    :precondition (and (typeguard__d000__t_entity ?d) (typeguard__d000__t_entity ?n) (d000__p_invitation_offered ?d ?n))
    :effect (not (d000__p_invitation_offered ?d ?n))
  )

  (:action d000__a_approach_beech_tree
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?t) (d000__p_sound_heard ?n ?t))
    :effect (and (shared__p_interface_9e2dfe3e7cd5d53e ?n ?t) (not (shared__p_interface_9e2dfe3e7cd5d53e ?n d000__c_bench)))
  )

  (:action d000__a_eat_pellet_and_shrink
    :parameters (?n - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?p) (shared__p_interface_b525a0d27c2e45f3 ?n ?p))
    :effect (and (d000__p_pellet_eaten ?n) (d000__p_shrunk ?n) (not (shared__p_interface_b525a0d27c2e45f3 ?n ?p)))
  )

  (:action d000__a_enter_tree_and_descend_stairs
    :parameters (?d - object ?n - object ?corridor - object ?door - object ?stairs - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?d) (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?corridor) (typeguard__d000__t_location ?door) (typeguard__d000__t_location ?stairs) (typeguard__d000__t_location ?t) (and (d000__p_inside ?n ?t) (d000__p_inside ?d ?t) (d000__p_door_open d000__c_door)))
    :effect (and (d000__p_stairs_descended ?n) (d000__p_stairs_descended ?d) (d000__p_corridor_reached ?n))
  )

  (:action d000__a_hear_tapping_on_beech
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?t) (shared__p_interface_9e2dfe3e7cd5d53e ?n d000__c_bench))
    :effect (d000__p_sound_heard ?n ?t)
  )

  (:action d000__a_receive_pellet_from_gnome
    :parameters (?g - object ?n - object ?p - object ?s - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?p) (typeguard__d000__t_item ?s) (typeguard__d000__t_location ?t) (and (d000__p_inside ?n ?t) (d000__p_inside ?g ?t)))
    :effect (shared__p_interface_b525a0d27c2e45f3 ?n ?p)
  )

  (:action d000__a_receive_queen_kiss
    :parameters (?n - object ?q - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_entity ?q) (shared__p_interface_9e2dfe3e7cd5d53e ?n d000__c_palace))
    :effect (and (d000__p_kissed_by ?n ?q) (d000__p_joyful ?n) (not (d000__p_gloomy ?n)))
  )

  (:action d000__a_return_to_bench_and_share_story
    :parameters (?g - object ?m - object ?n - object ?bench - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?bench) (shared__p_interface_9e2dfe3e7cd5d53e ?n d000__c_palace))
    :effect (and (shared__p_interface_9e2dfe3e7cd5d53e ?n ?bench) (d000__p_story_shared ?n ?m) (d000__p_story_shared ?n ?g) (not (shared__p_interface_9e2dfe3e7cd5d53e ?n d000__c_palace)))
  )

  (:action d000__a_travel_by_leaf_boat_under_pond
    :parameters (?n - object ?b - object ?palace - object ?pond - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?b) (typeguard__d000__t_location ?palace) (typeguard__d000__t_location ?pond) (and (d000__p_stairs_descended ?n) (d000__p_boat_available ?b ?pond)))
    :effect (shared__p_interface_9e2dfe3e7cd5d53e ?n ?palace)
  )

  (:action d000__a_travel_to_trysting_place
    :parameters (?n - object ?b - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?b) (typeguard__d000__t_location ?c) (shared__p_interface_9e2dfe3e7cd5d53e ?n ?c))
    :effect (and (shared__p_interface_9e2dfe3e7cd5d53e ?n ?b) (not (shared__p_interface_9e2dfe3e7cd5d53e ?n ?c)))
  )

  (:action d000__a_turn_key_on_beech
    :parameters (?n - object ?k - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?k) (typeguard__d000__t_location ?t) (shared__p_interface_9e2dfe3e7cd5d53e ?n ?t))
    :effect (and (d000__p_door_open d000__c_door) (d000__p_inside d000__c_dryad ?t) (d000__p_invitation_offered d000__c_dryad ?n) (shared__p_interface_b525a0d27c2e45f3 ?n ?k))
  )

  (:action d000__a_witness_queen_birthday_ceremony
    :parameters (?n - object ?q - object ?palace - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_entity ?q) (typeguard__d000__t_location ?palace) (shared__p_interface_9e2dfe3e7cd5d53e ?n ?palace))
    :effect (and (d000__p_joyful ?n) (d000__p_story_shared ?q ?n))
  )

  (:action d001__a_ask_giant_wife_for_breakfast
    :parameters (?j - object ?wife - object)
    :precondition (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_entity ?wife) (and (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle) (shared__p_interface_9420e6a250b7a1e0 ?wife d001__c_giant_castle)))
    :effect (d001__p_has_breakfast ?j)
  )

  (:action d001__a_climb_beanstalk
    :parameters (?j - object)
    :precondition (and (typeguard__d001__t_entity ?j) (and (d001__p_beanstalk_grown) (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_beanstalk)))
    :effect (and (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle) (not (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_beanstalk)))
  )

  (:action d001__a_cut_beanstalk
    :parameters (?giant - object ?mother - object ?axe - object)
    :precondition (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?mother) (typeguard__d001__t_item ?axe) (and (d001__p_intact d001__c_beanstalk) (d001__p_climbing_down ?giant)))
    :effect (and (d001__p_dead ?giant) (not (d001__p_intact d001__c_beanstalk)))
  )

  (:action d001__a_grow_beanstalk
    :parameters (?beans - object)
    :precondition (and (typeguard__d001__t_item ?beans) (d001__p_planted ?beans))
    :effect (and (d001__p_beanstalk_grown) (d001__p_intact d001__c_beanstalk))
  )

  (:action d001__a_hide_in_kettle
    :parameters (?j - object ?kettle - object)
    :precondition (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?kettle) (and (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle) (d001__p_empty ?kettle)))
    :effect (and (d001__p_inside ?j ?kettle) (not (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle)))
  )

  (:action d001__a_hide_in_oven
    :parameters (?j - object ?oven - object)
    :precondition (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?oven) (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle))
    :effect (and (d001__p_inside ?j ?oven) (not (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle)))
  )

  (:action d001__a_plant_beans
    :parameters (?beans - object ?loc - object)
    :precondition (and (typeguard__d001__t_item ?beans) (typeguard__d001__t_location ?loc) (d001__p_at_item ?beans ?loc))
    :effect (and (d001__p_planted ?beans) (not (d001__p_at_item ?beans ?loc)))
  )

  (:action d001__a_return_down_beanstalk
    :parameters (?j - object)
    :precondition (and (typeguard__d001__t_entity ?j) (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle))
    :effect (and (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_cottage) (not (shared__p_interface_9420e6a250b7a1e0 ?j d001__c_giant_castle)))
  )

  (:action d001__a_sell_cow_for_beans
    :parameters (?b - object ?cow - object ?j - object ?beans - object ?l - object)
    :precondition (and (typeguard__d001__t_entity ?b) (typeguard__d001__t_entity ?cow) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?beans) (typeguard__d001__t_location ?l) (and (shared__p_interface_9420e6a250b7a1e0 ?j ?l) (shared__p_interface_9420e6a250b7a1e0 ?cow ?l) (d001__p_offers ?b ?beans) (shared__p_interface_9420e6a250b7a1e0 ?b ?l)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?j ?beans) (not (d001__p_offers ?b ?beans)) (not (d001__p_at_item ?beans ?l)))
  )

  (:action d001__a_steal_gold_bags
    :parameters (?j - object ?bag1 - object ?bag2 - object)
    :precondition (and (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?bag1) (typeguard__d001__t_item ?bag2) (and (d001__p_asleep d001__c_giant) (d001__p_at_item ?bag1 d001__c_giant_castle) (d001__p_at_item ?bag2 d001__c_giant_castle)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?j ?bag1) (shared__p_interface_b525a0d27c2e45f3 ?j ?bag2) (not (d001__p_at_item ?bag1 d001__c_giant_castle)) (not (d001__p_at_item ?bag2 d001__c_giant_castle)))
  )

  (:action d001__a_steal_harp
    :parameters (?giant - object ?j - object ?harp - object)
    :precondition (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?harp) (and (d001__p_on ?harp d001__c_giant_castle) (d001__p_asleep ?giant)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?j ?harp) (not (d001__p_on ?harp d001__c_giant_castle)))
  )

  (:action d001__a_steal_hen
    :parameters (?giant - object ?j - object ?hen - object)
    :precondition (and (typeguard__d001__t_entity ?giant) (typeguard__d001__t_entity ?j) (typeguard__d001__t_item ?hen) (and (d001__p_on ?hen d001__c_giant_castle) (d001__p_distracted ?giant)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?j ?hen) (not (d001__p_on ?hen d001__c_giant_castle)))
  )

  (:action d002__a_approach_sun
    :parameters (?c - object)
    :precondition (and (typeguard__d002__t_entity ?c) (and (d002__p_traveling ?c) (d002__p_avoid ?c d002__c_sun)))
    :effect (d002__p_near ?c d002__c_sun)
  )

  (:action d002__a_arrest_meteor
    :parameters (?c - object ?m - object)
    :precondition (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?m) (and (d002__p_traveling ?c) (d002__p_near ?c ?m)))
    :effect (and (d002__p_arrested ?c ?m) (d002__p_detained ?m))
  )

  (:action d002__a_avoid_body
    :parameters (?b - object ?c - object)
    :precondition (and (typeguard__d002__t_entity ?b) (typeguard__d002__t_entity ?c) (and (d002__p_traveling ?c) (d002__p_avoid ?c ?b) (d002__p_near ?c ?b)))
    :effect (not (d002__p_near ?c ?b))
  )

  (:action d002__a_burn_up
    :parameters (?c - object)
    :precondition (and (typeguard__d002__t_entity ?c) (d002__p_near ?c d002__c_sun))
    :effect (and (d002__p_burned ?c) (not (d002__p_traveling ?c)) (not (d002__p_has_mission ?c)))
  )

  (:action d002__a_call_comet_forward
    :parameters (?c - object ?master - object)
    :precondition (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?master) (and (shared__p_interface_0f71a7a314338daa ?c d002__c_courtyard) (shared__p_interface_0f71a7a314338daa ?master d002__c_courtyard)))
    :effect (d002__p_summoned ?c)
  )

  (:action d002__a_cross_out_comet
    :parameters (?c - object)
    :precondition (and (typeguard__d002__t_entity ?c) (d002__p_burned ?c))
    :effect (and (d002__p_crossed_out ?c) (not (d002__p_on_list ?c)))
  )

  (:action d002__a_deliver_meteor_to_bungo
    :parameters (?m - object)
    :precondition (and (typeguard__d002__t_entity ?m) (d002__p_detained ?m))
    :effect (d002__p_delivered ?m d002__c_bungo)
  )

  (:action d002__a_give_order
    :parameters (?c - object ?master - object)
    :precondition (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?master) (and (shared__p_interface_0f71a7a314338daa ?c d002__c_courtyard) (shared__p_interface_0f71a7a314338daa ?master d002__c_courtyard) (not (d002__p_has_mission ?c))))
    :effect (and (d002__p_has_mission ?c) (d002__p_left_turn_rule ?c) (d002__p_prohibit_speak ?c) (d002__p_avoid ?c d002__c_sun) (d002__p_avoid ?c d002__c_earth) (d002__p_avoid ?c d002__c_bungo))
  )

  (:action d002__a_prohibit_speaking_to_meteor
    :parameters (?c - object)
    :precondition (and (typeguard__d002__t_entity ?c) (d002__p_has_mission ?c))
    :effect (d002__p_prohibit_speak ?c)
  )

  (:action d002__a_punish_meteor
    :parameters (?m - object)
    :precondition (and (typeguard__d002__t_entity ?m) (d002__p_delivered ?m d002__c_bungo))
    :effect (d002__p_punished ?m)
  )

  (:action d002__a_speak_to_meteor
    :parameters (?c - object ?m - object)
    :precondition (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?m) (and (d002__p_traveling ?c) (d002__p_prohibit_speak ?c) (d002__p_near ?c ?m)))
    :effect (and (d002__p_speaks_to ?c ?m) (d002__p_rule_violation ?c))
  )

  (:action d002__a_start_travel
    :parameters (?c - object)
    :precondition (and (typeguard__d002__t_entity ?c) (and (d002__p_has_mission ?c) (d002__p_gate_open)))
    :effect (and (d002__p_traveling ?c) (not (shared__p_interface_0f71a7a314338daa ?c d002__c_courtyard)))
  )

  (:action d002__a_turn_left_on_meeting
    :parameters (?c - object ?other - object)
    :precondition (and (typeguard__d002__t_entity ?c) (typeguard__d002__t_entity ?other) (and (d002__p_traveling ?c) (d002__p_traveling ?other) (d002__p_left_turn_rule ?c) (d002__p_near ?c ?other)))
    :effect (d002__p_left_turn_rule ?c)
  )

  (:action d003__a_ask_for_material
    :parameters (?m - object ?p - object ?i - object)
    :precondition (and (typeguard__d003__t_entity ?m) (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?i) (and (d003__p_has_bundle ?m ?i) (d003__p_alive ?p) (d003__p_alive ?m)))
    :effect (d003__p_material_requested ?p ?i)
  )

  (:action d003__a_build_house
    :parameters (?p - object ?i - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?i) (typeguard__d003__t_location ?h) (and (shared__p_interface_b525a0d27c2e45f3 ?p ?i) (d003__p_alive ?p) (shared__p_interface_0f71a7a314338daa ?p ?h)))
    :effect (and (d003__p_house ?h ?i) (d003__p_house_intact ?h) (d003__p_door_closed ?h) (not (shared__p_interface_b525a0d27c2e45f3 ?p ?i)))
  )

  (:action d003__a_pig_buys_butter_churn_and_hides
    :parameters (?p - object ?c - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?c) (and (shared__p_interface_0f71a7a314338daa ?p d003__c_town_fair) (d003__p_alive ?p)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?p ?c) (d003__p_inside ?p ?c))
  )

  (:action d003__a_pig_collects_apples_and_escapes
    :parameters (?p - object ?a - object ?l - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?a) (typeguard__d003__t_location ?l) (and (d003__p_plan ?p ?l) (d003__p_alive ?p)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?p ?a) (d003__p_escaped ?p) (not (d003__p_plan ?p ?l)))
  )

  (:action d003__a_pig_collects_turnips
    :parameters (?p - object ?i - object ?l - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?i) (typeguard__d003__t_location ?l) (and (d003__p_plan ?p ?l) (d003__p_alive ?p)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?p ?i) (not (d003__p_plan ?p ?l)))
  )

  (:action d003__a_pig_prepares_boiling_pot_and_fire
    :parameters (?p - object ?fire - object ?pot - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?fire) (typeguard__d003__t_item ?pot) (typeguard__d003__t_location ?h) (and (shared__p_interface_0f71a7a314338daa ?p ?h) (shared__p_interface_b525a0d27c2e45f3 ?p ?pot) (shared__p_interface_b525a0d27c2e45f3 ?p ?fire) (d003__p_alive ?p)))
    :effect (and (d003__p_over ?pot ?fire) (d003__p_under ?pot d003__c_chimney) (d003__p_boiling ?pot))
  )

  (:action d003__a_pig_refuses_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?h) (and (d003__p_entry_requested ?w ?h) (d003__p_alive ?w)))
    :effect (and (d003__p_entry_denied ?w ?h) (not (d003__p_entry_requested ?w ?h)))
  )

  (:action d003__a_pig_rolls_churn_down_hill
    :parameters (?p - object ?c - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?c) (and (d003__p_inside ?p ?c) (d003__p_alive ?p)))
    :effect (and (d003__p_rolling ?c) (not (d003__p_inside ?p ?c)))
  )

  (:action d003__a_receive_material
    :parameters (?m - object ?p - object ?i - object)
    :precondition (and (typeguard__d003__t_entity ?m) (typeguard__d003__t_entity ?p) (typeguard__d003__t_item ?i) (and (d003__p_material_requested ?p ?i) (d003__p_has_bundle ?m ?i) (d003__p_alive ?p) (d003__p_alive ?m)))
    :effect (and (shared__p_interface_b525a0d27c2e45f3 ?p ?i) (not (d003__p_material_requested ?p ?i)) (not (d003__p_has_bundle ?m ?i)))
  )

  (:action d003__a_send_sons_on_journey
    :parameters (?m - object ?p - object ?d - object)
    :precondition (and (typeguard__d003__t_entity ?m) (typeguard__d003__t_entity ?p) (typeguard__d003__t_location ?d) (and (shared__p_interface_0f71a7a314338daa ?m d003__c_pig_home) (shared__p_interface_0f71a7a314338daa ?p d003__c_pig_home) (d003__p_alive ?m) (d003__p_alive ?p)))
    :effect (and (d003__p_plan ?p ?d) (not (shared__p_interface_0f71a7a314338daa ?p d003__c_pig_home)))
  )

  (:action d003__a_wolf_attempts_chimney_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?h) (and (d003__p_house_intact ?h) (d003__p_alive ?w)))
    :effect (d003__p_entry_requested ?w ?h)
  )

  (:action d003__a_wolf_blows_house_down
    :parameters (?w - object ?i - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_item ?i) (typeguard__d003__t_location ?h) (and (d003__p_huffed ?w) (d003__p_puffed ?w) (d003__p_house ?h ?i) (d003__p_door_closed ?h) (d003__p_alive ?w)))
    :effect (and (d003__p_house_destroyed ?h) (not (d003__p_house_intact ?h)) (not (d003__p_door_closed ?h)))
  )

  (:action d003__a_wolf_eats_pig
    :parameters (?p - object ?w - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?h) (and (d003__p_house_destroyed ?h) (shared__p_interface_0f71a7a314338daa ?p ?h) (d003__p_alive ?p) (d003__p_alive ?w)))
    :effect (and (d003__p_dead ?p) (not (d003__p_alive ?p)) (not (shared__p_interface_0f71a7a314338daa ?p ?h)))
  )

  (:action d003__a_wolf_fails_to_blow_house
    :parameters (?w - object ?i - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_item ?i) (typeguard__d003__t_location ?h) (and (d003__p_huffed ?w) (d003__p_puffed ?w) (d003__p_house ?h ?i) (d003__p_alive ?w)))
    :effect (d003__p_house_intact ?h)
  )

  (:action d003__a_wolf_falls_into_pot_and_is_boiled
    :parameters (?w - object ?pot - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_item ?pot) (and (d003__p_boiling ?pot) (d003__p_alive ?w)))
    :effect (and (d003__p_dead ?w) (not (d003__p_alive ?w)))
  )

  (:action d003__a_wolf_flees_from_rolling_object
    :parameters (?w - object ?c - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_item ?c) (and (d003__p_rolling ?c) (d003__p_alive ?w)))
    :effect (d003__p_escaped ?w)
  )

  (:action d003__a_wolf_huff_and_puff
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?h) (and (d003__p_entry_denied ?w ?h) (d003__p_alive ?w)))
    :effect (and (d003__p_huffed ?w) (d003__p_puffed ?w))
  )

  (:action d003__a_wolf_knocks_and_requests_entry
    :parameters (?w - object ?h - object)
    :precondition (and (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?h) (and (shared__p_interface_0f71a7a314338daa ?w ?h) (d003__p_door_closed ?h) (d003__p_alive ?w)))
    :effect (d003__p_entry_requested ?w ?h)
  )

  (:action d003__a_wolf_promises_apple_orchard
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?l) (and (d003__p_alive ?w) (d003__p_alive ?p)))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d003__a_wolf_promises_fair_trip
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?l) (and (d003__p_alive ?w) (d003__p_alive ?p)))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d003__a_wolf_promises_turnip_field
    :parameters (?p - object ?w - object ?l - object)
    :precondition (and (typeguard__d003__t_entity ?p) (typeguard__d003__t_entity ?w) (typeguard__d003__t_location ?l) (and (d003__p_alive ?w) (d003__p_alive ?p)))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d004__a_buy_boots
    :parameters (?jack - object ?puss - object ?boots - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_entity ?puss) (typeguard__d004__t_item ?boots) (not (d004__p_has ?puss ?boots)))
    :effect (d004__p_has ?puss ?boots)
  )

  (:action d004__a_cat_call_for_help
    :parameters (?jack - object ?king - object ?puss - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_entity ?king) (typeguard__d004__t_entity ?puss) (d004__p_drowning ?jack))
    :effect (and (d004__p_rescued_by ?jack ?king) (not (d004__p_drowning ?jack)))
  )

  (:action d004__a_cat_catch_rabbits
    :parameters (?puss - object ?bag - object ?rabbit - object ?warren - object)
    :precondition (and (typeguard__d004__t_entity ?puss) (typeguard__d004__t_item ?bag) (typeguard__d004__t_item ?rabbit) (typeguard__d004__t_location ?warren) (and (d004__p_has ?puss ?bag) (d004__p_at_item ?rabbit ?warren) (not (d004__p_contains ?bag ?rabbit))))
    :effect (and (d004__p_contains ?bag ?rabbit) (not (d004__p_at_item ?rabbit ?warren)))
  )

  (:action d004__a_cat_deliver_gifts_to_king
    :parameters (?king - object ?puss - object ?bag - object ?rabbit - object ?palace - object)
    :precondition (and (typeguard__d004__t_entity ?king) (typeguard__d004__t_entity ?puss) (typeguard__d004__t_item ?bag) (typeguard__d004__t_item ?rabbit) (typeguard__d004__t_location ?palace) (and (d004__p_contains ?bag ?rabbit) (shared__p_interface_9e2dfe3e7cd5d53e ?puss ?palace)))
    :effect (and (d004__p_gift_delivered ?puss ?king ?rabbit) (not (d004__p_contains ?bag ?rabbit)))
  )

  (:action d004__a_cat_disentchant_prisoners
    :parameters (?person - object ?puss - object)
    :precondition (and (typeguard__d004__t_entity ?person) (typeguard__d004__t_entity ?puss) (d004__p_alive ?puss))
    :effect (d004__p_promised_to_serve ?person d004__c_jack)
  )

  (:action d004__a_cat_eat_mouse
    :parameters (?mouse - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d004__t_entity ?mouse) (typeguard__d004__t_entity ?ogre) (typeguard__d004__t_entity ?puss) (d004__p_transformed_into ?ogre ?mouse))
    :effect (not (d004__p_transformed_into ?ogre ?mouse))
  )

  (:action d004__a_cat_ogre_transform_lion
    :parameters (?lion - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d004__t_entity ?lion) (typeguard__d004__t_entity ?ogre) (typeguard__d004__t_entity ?puss) (and (shared__p_interface_9e2dfe3e7cd5d53e ?puss d004__c_ogre_castle) (d004__p_alive ?ogre)))
    :effect (d004__p_transformed_into ?ogre ?lion)
  )

  (:action d004__a_cat_ogre_transform_mouse
    :parameters (?mouse - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d004__t_entity ?mouse) (typeguard__d004__t_entity ?ogre) (typeguard__d004__t_entity ?puss) (d004__p_alive ?ogre))
    :effect (d004__p_transformed_into ?ogre ?mouse)
  )

  (:action d004__a_cat_open_castle_gates
    :parameters (?king - object ?puss - object ?castle - object)
    :precondition (and (typeguard__d004__t_entity ?king) (typeguard__d004__t_entity ?puss) (typeguard__d004__t_location ?castle) (shared__p_interface_9e2dfe3e7cd5d53e ?king ?castle))
    :effect (d004__p_gate_open ?castle)
  )

  (:action d004__a_cat_persuade_master_to_bathe
    :parameters (?jack - object ?puss - object ?river - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_entity ?puss) (typeguard__d004__t_location ?river) (and (shared__p_interface_9e2dfe3e7cd5d53e ?jack ?river) (shared__p_interface_9e2dfe3e7cd5d53e ?puss ?river)))
    :effect (d004__p_drowning ?jack)
  )

  (:action d004__a_give_bag_to_cat
    :parameters (?jack - object ?puss - object ?bag - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_entity ?puss) (typeguard__d004__t_item ?bag) (and (d004__p_has ?jack ?bag) (not (d004__p_has ?puss ?bag))))
    :effect (and (d004__p_has ?puss ?bag) (not (d004__p_has ?jack ?bag)))
  )

  (:action d004__a_king_send_groom_fetch_suit
    :parameters (?groom - object ?king - object ?suit - object ?wardrobe - object)
    :precondition (and (typeguard__d004__t_entity ?groom) (typeguard__d004__t_entity ?king) (typeguard__d004__t_item ?suit) (typeguard__d004__t_location ?wardrobe) (d004__p_at_item ?suit ?wardrobe))
    :effect (and (d004__p_has ?groom ?suit) (not (d004__p_at_item ?suit ?wardrobe)))
  )

  (:action d004__a_master_marry_princess
    :parameters (?jack - object ?princess - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_entity ?princess) (and (not (d004__p_married ?jack ?princess)) (shared__p_interface_9e2dfe3e7cd5d53e ?jack d004__c_palace)))
    :effect (d004__p_married ?jack ?princess)
  )

  (:action d004__a_master_wear_suit
    :parameters (?jack - object ?suit - object)
    :precondition (and (typeguard__d004__t_entity ?jack) (typeguard__d004__t_item ?suit) (d004__p_has ?jack ?suit))
    :effect (and (d004__p_wearing ?jack ?suit) (not (d004__p_has ?jack ?suit)))
  )

  (:action d005__a_arrive_at_marble_palace
    :parameters (?p - object)
    :precondition (and (typeguard__d005__t_entity ?p) (shared__p_interface_0f71a7a314338daa ?p d005__c_oak_tree))
    :effect (and (shared__p_interface_0f71a7a314338daa ?p d005__c_palace) (not (shared__p_interface_0f71a7a314338daa ?p d005__c_oak_tree)))
  )

  (:action d005__a_encounter_impostor_king
    :parameters (?i - object ?p - object)
    :precondition (and (typeguard__d005__t_entity ?i) (typeguard__d005__t_entity ?p) (and (shared__p_interface_0f71a7a314338daa ?p d005__c_city) (shared__p_interface_0f71a7a314338daa ?i d005__c_market_place)))
    :effect (and (shared__p_interface_0f71a7a314338daa ?p d005__c_market_place) (not (shared__p_interface_0f71a7a314338daa ?p d005__c_city)))
  )

  (:action d005__a_encounter_robbers_in_forest
    :parameters (?p - object)
    :precondition (and (typeguard__d005__t_entity ?p) (shared__p_interface_0f71a7a314338daa ?p d005__c_forest))
    :effect (and (shared__p_interface_0f71a7a314338daa ?p d005__c_oak_tree) (not (shared__p_interface_0f71a7a314338daa ?p d005__c_forest)))
  )

  (:action d005__a_king_proposes_marriage
    :parameters (?k - object ?p - object)
    :precondition (and (typeguard__d005__t_entity ?k) (typeguard__d005__t_entity ?p) (and (shared__p_interface_0f71a7a314338daa ?p d005__c_palace) (shared__p_interface_0f71a7a314338daa ?k d005__c_palace)))
    :effect (d005__p_married ?p ?k)
  )

  (:action d005__a_king_requests_information_and_gifts
    :parameters (?k - object ?p - object ?r - object ?s - object)
    :precondition (and (typeguard__d005__t_entity ?k) (typeguard__d005__t_entity ?p) (typeguard__d005__t_item ?r) (typeguard__d005__t_item ?s) (and (shared__p_interface_0f71a7a314338daa ?p d005__c_palace) (d005__p_has ?p ?r) (d005__p_has ?p ?s) (shared__p_interface_0f71a7a314338daa ?k d005__c_palace)))
    :effect (and (d005__p_has ?k ?r) (d005__p_has ?k ?s) (not (d005__p_has ?p ?r)) (not (d005__p_has ?p ?s)))
  )

  (:action d005__a_princess_accepts_with_heart
    :parameters (?k - object ?p - object)
    :precondition (and (typeguard__d005__t_entity ?k) (typeguard__d005__t_entity ?p) (and (d005__p_married ?p ?k) (not (d005__p_with_all_my_heart_spoken))))
    :effect (d005__p_with_all_my_heart_spoken)
  )

  (:action d005__a_receive_rubies_from_impostor
    :parameters (?i - object ?p - object ?r - object)
    :precondition (and (typeguard__d005__t_entity ?i) (typeguard__d005__t_entity ?p) (typeguard__d005__t_item ?r) (and (d005__p_price_of_butter_spoken) (shared__p_interface_0f71a7a314338daa ?p d005__c_market_place) (d005__p_has ?i ?r)))
    :effect (and (d005__p_has ?p ?r) (not (d005__p_has ?i ?r)))
  )

  (:action d005__a_receive_sapphires_from_robber_chief
    :parameters (?c - object ?p - object ?s - object)
    :precondition (and (typeguard__d005__t_entity ?c) (typeguard__d005__t_entity ?p) (typeguard__d005__t_item ?s) (and (d005__p_grandmother_mangle_spoken) (shared__p_interface_0f71a7a314338daa ?p d005__c_oak_tree) (d005__p_has ?c ?s)))
    :effect (and (d005__p_has ?p ?s) (not (d005__p_has ?c ?s)))
  )

  (:action d005__a_run_away_from_palace
    :parameters (?p - object)
    :precondition (and (typeguard__d005__t_entity ?p) (shared__p_interface_0f71a7a314338daa ?p d005__c_back_stairs))
    :effect (and (shared__p_interface_0f71a7a314338daa ?p d005__c_city) (not (shared__p_interface_0f71a7a314338daa ?p d005__c_back_stairs)))
  )

  (:action d005__a_suitors_retire_due_to_phrase
    :parameters (?s - object)
    :precondition (and (typeguard__d005__t_entity ?s) (and (d005__p_grandmother_mangle_spoken) (shared__p_interface_0f71a7a314338daa ?s d005__c_palace)))
    :effect (not (d005__p_married ?s d005__c_princess))
  )

  (:action d005__a_utter_phrase_grandmother_mangle
    :parameters (?p - object)
    :precondition (and (typeguard__d005__t_entity ?p) (and (shared__p_interface_0f71a7a314338daa ?p d005__c_oak_tree) (not (d005__p_grandmother_mangle_spoken))))
    :effect (d005__p_grandmother_mangle_spoken)
  )

  (:action d005__a_utter_phrase_price_of_butter
    :parameters (?p - object)
    :precondition (and (typeguard__d005__t_entity ?p) (and (shared__p_interface_0f71a7a314338daa ?p d005__c_market_place) (not (d005__p_price_of_butter_spoken))))
    :effect (d005__p_price_of_butter_spoken)
  )

  (:action d006__a_accept_woe_as_burden
    :parameters (?rich - object ?woe - object)
    :precondition (and (typeguard__d006__t_entity ?rich) (typeguard__d006__t_entity ?woe) (d006__p_woe_on_shoulder ?woe ?rich))
    :effect (d006__p_has_fatigue ?rich)
  )

  (:action d006__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?woe) (typeguard__d006__t_location ?loc) (and (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc) (shared__p_interface_9420e6a250b7a1e0 ?woe ?loc) (d006__p_has_fatigue ?poor)))
    :effect (d006__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d006__a_bow_to_guests
    :parameters (?poor - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_location ?loc) (and (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc) (exists (?bound_scope_0 - object) (and (typeguard__d006__t_entity ?bound_scope_0) (d006__p_guest_present ?bound_scope_0 ?loc)))))
    :effect (d006__p_bowed ?poor ?loc)
  )

  (:action d006__a_encounter_bitter_woe
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?woe) (typeguard__d006__t_location ?loc) (and (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc) (shared__p_interface_9420e6a250b7a1e0 ?woe ?loc)))
    :effect (d006__p_has_fatigue ?poor)
  )

  (:action d006__a_hide_woe_under_stone
    :parameters (?poor - object ?woe - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?woe) (typeguard__d006__t_item ?stone) (typeguard__d006__t_location ?loc) (and (d006__p_woe_on_shoulder ?woe ?poor) (d006__p_stone_at ?stone ?loc)))
    :effect (and (d006__p_trapped ?woe) (d006__p_stone_at ?stone ?loc) (not (d006__p_woe_on_shoulder ?woe ?poor)) (not (d006__p_stone_moved ?stone)))
  )

  (:action d006__a_invite_rich_brother_to_feast
    :parameters (?poor - object ?rich - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?rich) (typeguard__d006__t_location ?loc) (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc))
    :effect (and (d006__p_invitation_sent ?poor ?rich) (d006__p_invited ?rich ?poor))
  )

  (:action d006__a_make_sign_of_cross
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?woe) (typeguard__d006__t_location ?loc) (and (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc) (shared__p_interface_9420e6a250b7a1e0 ?woe ?loc)))
    :effect (d006__p_has_fatigue ?poor)
  )

  (:action d006__a_move_heavy_stone
    :parameters (?carrier - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?carrier) (typeguard__d006__t_item ?stone) (typeguard__d006__t_location ?loc) (and (d006__p_stone_at ?stone ?loc) (d006__p_has_strength ?carrier)))
    :effect (and (d006__p_stone_moved ?stone) (not (d006__p_stone_at ?stone ?loc)))
  )

  (:action d006__a_perform_work_for_rich_brother
    :parameters (?employer - object ?worker - object)
    :precondition (and (typeguard__d006__t_entity ?employer) (typeguard__d006__t_entity ?worker) (and (d006__p_employed ?worker ?employer) (d006__p_has_strength ?worker)))
    :effect (and (d006__p_work_done ?worker ?employer) (d006__p_has_fatigue ?worker))
  )

  (:action d006__a_receive_payment
    :parameters (?employer - object ?worker - object ?bread - object ?money - object)
    :precondition (and (typeguard__d006__t_entity ?employer) (typeguard__d006__t_entity ?worker) (typeguard__d006__t_item ?bread) (typeguard__d006__t_item ?money) (and (d006__p_work_done ?worker ?employer) (d006__p_has ?employer ?money) (d006__p_has ?employer ?bread)))
    :effect (and (d006__p_has ?worker ?money) (d006__p_has ?worker ?bread) (not (d006__p_has ?employer ?money)) (not (d006__p_has ?employer ?bread)))
  )

  (:action d006__a_request_help_from_rich_brother
    :parameters (?poor - object ?rich - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_entity ?rich) (and (d006__p_need_help ?poor) (d006__p_rich ?rich)))
    :effect (and (d006__p_employed ?poor ?rich) (not (d006__p_need_help ?poor)))
  )

  (:action d006__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?rich) (typeguard__d006__t_item ?stone) (typeguard__d006__t_location ?loc) (and (d006__p_stone_at ?stone ?loc) (d006__p_rich ?rich)))
    :effect (and (d006__p_stone_moved ?stone) (d006__p_woe_on_shoulder d006__c_bitter_woe ?rich) (not (d006__p_stone_at ?stone ?loc)))
  )

  (:action d006__a_sing_cheerful_song
    :parameters (?poor - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_location ?loc) (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc))
    :effect (d006__p_singing ?poor)
  )

  (:action d006__a_spend_money_on_drink
    :parameters (?poor - object ?money - object ?wine - object ?kabak - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_item ?money) (typeguard__d006__t_item ?wine) (typeguard__d006__t_location ?kabak) (and (d006__p_has ?poor ?money) (shared__p_interface_9420e6a250b7a1e0 ?poor ?kabak)))
    :effect (and (d006__p_has ?poor ?wine) (d006__p_drunk ?poor) (not (d006__p_has ?poor ?money)))
  )

  (:action d006__a_stay_for_banquet
    :parameters (?guest - object ?host - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?guest) (typeguard__d006__t_entity ?host) (typeguard__d006__t_location ?loc) (and (shared__p_interface_9420e6a250b7a1e0 ?guest ?loc) (shared__p_interface_9420e6a250b7a1e0 ?host ?loc) (d006__p_banquet_at ?loc) (d006__p_invited ?guest ?host)))
    :effect (d006__p_guest_present ?guest ?loc)
  )

  (:action d006__a_take_gold_pot_and_hide
    :parameters (?poor - object ?gold - object ?loc - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_item ?gold) (typeguard__d006__t_location ?loc) (and (d006__p_gold_at ?gold ?loc) (shared__p_interface_9420e6a250b7a1e0 ?poor ?loc)))
    :effect (and (d006__p_has ?poor ?gold) (d006__p_concealed ?gold) (not (d006__p_gold_at ?gold ?loc)))
  )

  (:action d006__a_trade_assets_for_money
    :parameters (?poor - object ?asset - object ?money - object)
    :precondition (and (typeguard__d006__t_entity ?poor) (typeguard__d006__t_item ?asset) (typeguard__d006__t_item ?money) (d006__p_has ?poor ?asset))
    :effect (and (d006__p_has ?poor ?money) (not (d006__p_has ?poor ?asset)))
  )
)
