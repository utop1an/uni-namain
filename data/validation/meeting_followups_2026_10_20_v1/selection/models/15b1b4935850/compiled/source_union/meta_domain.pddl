(define (domain narrative_union)
  (:requirements :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d001__t_entity d001__t_item d001__t_location - d001__t_object
    d002__t_entity d002__t_item d002__t_location - d002__t_object
    d003__t_entity d003__t_item d003__t_location - d003__t_object
    d004__t_entity d004__t_item d004__t_location - d004__t_object
    d005__t_entity d005__t_item d005__t_location - d005__t_object
    d006__t_entity d006__t_item d006__t_location - d006__t_object
    d000__t_object d001__t_object d002__t_object d003__t_object d004__t_object d005__t_object d006__t_object - object
  )
  (:constants
    d000__c_dryad d000__c_fairy_queen d000__c_gnome d000__c_grandmother d000__c_grandmotherkin d000__c_mother d000__c_mothereen d000__c_nora - d000__t_entity
    d000__c_boat d000__c_gold_star d000__c_key d000__c_lantern d000__c_pellet d000__c_silver_salver - d000__t_item
    d000__c_beech_tree d000__c_bench d000__c_corridor d000__c_cottage d000__c_door d000__c_fairyland d000__c_palace d000__c_pond d000__c_spring d000__c_stairs d000__c_stream - d000__t_location
    d001__c_brown_hen d001__c_butcher d001__c_fairy_maiden d001__c_giant d001__c_giant_dog d001__c_giant_wife d001__c_jack d001__c_jack_mother d001__c_milky_white - d001__t_entity
    d001__c_axe d001__c_gold_bag_1 d001__c_gold_bag_2 d001__c_golden_harp d001__c_magic_beans d001__c_oak_tree_club - d001__t_item
    d001__c_beanstalk d001__c_castle_road d001__c_cottage d001__c_garden d001__c_giant_castle d001__c_kettle d001__c_market d001__c_oven d001__c_window - d001__t_location
    d002__c_bungo d002__c_comet_master d002__c_earth d002__c_long_tail_45 d002__c_meteor d002__c_meteor_keeper d002__c_no1_express d002__c_short_tail_73 d002__c_sun - d002__t_entity
    d002__c_chalk d002__c_slate - d002__t_item
    d002__c_comet_house d002__c_courtyard d002__c_gate - d002__t_location
    d003__c_farmer d003__c_man_bricks d003__c_man_furze d003__c_man_straw d003__c_mother_pig d003__c_pig1 d003__c_pig2 d003__c_pig3 d003__c_squire d003__c_wolf - d003__t_entity
    d003__c_apple d003__c_bricks d003__c_butter_churn d003__c_fire d003__c_furze_bundle d003__c_mortar d003__c_pot_of_water d003__c_sack d003__c_straw_bundle d003__c_trowel d003__c_turnips_load - d003__t_item
    d003__c_brick_house d003__c_chimney d003__c_furze_house d003__c_hearth d003__c_hill d003__c_oak_forest d003__c_pig_home d003__c_squire_orchard d003__c_straw_house d003__c_town_fair d003__c_turnip_field - d003__t_location
    d004__c_coachman d004__c_eldest_son d004__c_groom d004__c_jack d004__c_king d004__c_miller d004__c_ogre d004__c_princess d004__c_puss d004__c_second_son - d004__t_entity
    d004__c_ass d004__c_bag d004__c_boots d004__c_hare d004__c_mill d004__c_partridge d004__c_rabbit d004__c_suit - d004__t_item
    d004__c_field_of_corn d004__c_field_of_wheat d004__c_ogre_castle d004__c_palace d004__c_river d004__c_royal_wardrobe d004__c_warren - d004__t_location
    d005__c_father_king d005__c_impostor_butterman d005__c_king_at_palace d005__c_princess d005__c_robber_chief - d005__t_entity
    d005__c_bag_of_rubies d005__c_bag_of_sapphires d005__c_crown d005__c_sceptre - d005__t_item
    d005__c_back_door d005__c_back_stairs d005__c_city d005__c_forest d005__c_market_place d005__c_oak_tree d005__c_palace - d005__t_location
    d006__c_bitter_woe d006__c_children d006__c_poor_brother d006__c_rich_brother d006__c_wife - d006__t_entity
    d006__c_cattle d006__c_copecks_25 d006__c_gold_pot d006__c_grove d006__c_harrow d006__c_honey d006__c_loaf_bread d006__c_plow d006__c_sledge d006__c_stone d006__c_telega d006__c_wine - d006__t_item
    d006__c_big_house d006__c_forest d006__c_izba d006__c_kabak d006__c_large_town d006__c_new_home d006__c_treasure_pit d006__c_village d006__c_well d006__c_yard - d006__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_boat_available ?b - d000__t_item ?l - d000__t_location)
    (d000__p_corridor_reached ?e - d000__t_entity)
    (d000__p_door_open ?d - d000__t_location)
    (d000__p_gloomy ?e - d000__t_entity)
    (d000__p_gold_star_on ?e - d000__t_entity ?s - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_inside ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_invitation_offered ?from - d000__t_entity ?to - d000__t_entity)
    (d000__p_joyful ?e - d000__t_entity)
    (d000__p_kissed_by ?e - d000__t_entity ?k - d000__t_entity)
    (d000__p_knighted ?e - d000__t_entity)
    (d000__p_lantern_carried ?e - d000__t_entity ?l - d000__t_item)
    (d000__p_pellet_eaten ?e - d000__t_entity)
    (d000__p_shrunk ?e - d000__t_entity)
    (d000__p_sound_heard ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_stairs_descended ?e - d000__t_entity)
    (d000__p_story_shared ?speaker - d000__t_entity ?listener - d000__t_entity)
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
    (d002__p_arrested ?c - d002__t_entity ?m - d002__t_entity)
    (d002__p_at ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_avoid ?c - d002__t_entity ?b - d002__t_entity)
    (d002__p_burned ?c - d002__t_entity)
    (d002__p_crossed_out ?c - d002__t_entity)
    (d002__p_delivered ?m - d002__t_entity ?p - d002__t_entity)
    (d002__p_detained ?m - d002__t_entity)
    (d002__p_gate_open)
    (d002__p_has_mission ?c - d002__t_entity)
    (d002__p_left_turn_rule ?c - d002__t_entity)
    (d002__p_near ?c - d002__t_entity ?b - d002__t_entity)
    (d002__p_on_list ?c - d002__t_entity)
    (d002__p_prohibit_speak ?c - d002__t_entity)
    (d002__p_punished ?m - d002__t_entity)
    (d002__p_rule_violation ?c - d002__t_entity)
    (d002__p_speaks_to ?c - d002__t_entity ?m - d002__t_entity)
    (d002__p_summoned ?c - d002__t_entity)
    (d002__p_traveling ?c - d002__t_entity)
    (d003__p_alive ?e - d003__t_entity)
    (d003__p_at ?e - d003__t_entity ?l - d003__t_location)
    (d003__p_boiling ?i - d003__t_item)
    (d003__p_dead ?e - d003__t_entity)
    (d003__p_door_closed ?h - d003__t_location)
    (d003__p_entry_denied ?w - d003__t_entity ?h - d003__t_location)
    (d003__p_entry_requested ?w - d003__t_entity ?h - d003__t_location)
    (d003__p_escaped ?e - d003__t_entity)
    (d003__p_has ?e - d003__t_entity ?i - d003__t_item)
    (d003__p_has_bundle ?m - d003__t_entity ?i - d003__t_item)
    (d003__p_house ?h - d003__t_location ?m - d003__t_item)
    (d003__p_house_destroyed ?h - d003__t_location)
    (d003__p_house_intact ?h - d003__t_location)
    (d003__p_huffed ?w - d003__t_entity)
    (d003__p_inside ?e - d003__t_entity ?c - d003__t_item)
    (d003__p_material_requested ?p - d003__t_entity ?i - d003__t_item)
    (d003__p_over ?i1 - d003__t_item ?i2 - d003__t_item)
    (d003__p_plan ?e - d003__t_entity ?l - d003__t_location)
    (d003__p_puffed ?w - d003__t_entity)
    (d003__p_rolling ?i - d003__t_item)
    (d003__p_under ?i - d003__t_item ?l - d003__t_location)
    (d004__p_alive ?x - d004__t_entity)
    (d004__p_at ?x - d004__t_entity ?l - d004__t_location)
    (d004__p_at_item ?i - d004__t_item ?l - d004__t_location)
    (d004__p_castle_owned_by ?castle - d004__t_location ?owner - d004__t_entity)
    (d004__p_contains ?c - d004__t_item ?i - d004__t_item)
    (d004__p_drowning ?e - d004__t_entity)
    (d004__p_gate_open ?castle - d004__t_location)
    (d004__p_gift_delivered ?giver - d004__t_entity ?receiver - d004__t_entity ?item - d004__t_item)
    (d004__p_has ?e - d004__t_entity ?i - d004__t_item)
    (d004__p_married ?e1 - d004__t_entity ?e2 - d004__t_entity)
    (d004__p_obedient ?e - d004__t_entity)
    (d004__p_promised_to_serve ?servant - d004__t_entity ?master - d004__t_entity)
    (d004__p_rescued_by ?victim - d004__t_entity ?rescuer - d004__t_entity)
    (d004__p_transformed_into ?e - d004__t_entity ?form - d004__t_entity)
    (d004__p_wearing ?e - d004__t_entity ?i - d004__t_item)
    (d005__p_at ?e - d005__t_entity ?l - d005__t_location)
    (d005__p_grandmother_mangle_spoken)
    (d005__p_has ?e - d005__t_entity ?i - d005__t_item)
    (d005__p_married ?p1 - d005__t_entity ?p2 - d005__t_entity)
    (d005__p_price_of_butter_spoken)
    (d005__p_with_all_my_heart_spoken)
    (d006__p_at ?e - d006__t_entity ?l - d006__t_location)
    (d006__p_banquet_at ?l - d006__t_location)
    (d006__p_bowed ?e - d006__t_entity ?l - d006__t_location)
    (d006__p_concealed ?i - d006__t_item)
    (d006__p_drunk ?e - d006__t_entity)
    (d006__p_employed ?worker - d006__t_entity ?employer - d006__t_entity)
    (d006__p_gold_at ?g - d006__t_item ?l - d006__t_location)
    (d006__p_guest_present ?guest - d006__t_entity ?l - d006__t_location)
    (d006__p_has ?e - d006__t_entity ?i - d006__t_item)
    (d006__p_has_fatigue ?e - d006__t_entity)
    (d006__p_has_strength ?e - d006__t_entity)
    (d006__p_invitation_sent ?sender - d006__t_entity ?receiver - d006__t_entity)
    (d006__p_invited ?invitee - d006__t_entity ?host - d006__t_entity)
    (d006__p_need_help ?e - d006__t_entity)
    (d006__p_poor ?e - d006__t_entity)
    (d006__p_rich ?e - d006__t_entity)
    (d006__p_singing ?e - d006__t_entity)
    (d006__p_stone_at ?s - d006__t_item ?l - d006__t_location)
    (d006__p_stone_moved ?s - d006__t_item)
    (d006__p_trapped ?m - d006__t_entity)
    (d006__p_woe_on_shoulder ?monster - d006__t_entity ?carrier - d006__t_entity)
    (d006__p_work_done ?worker - d006__t_entity ?employer - d006__t_entity)
  )

  (:action d000__a_accept_dryad_invitation
    :parameters (?d - d000__t_entity ?n - d000__t_entity)
    :precondition (d000__p_invitation_offered ?d ?n)
    :effect (not (d000__p_invitation_offered ?d ?n))
  )

  (:action d000__a_approach_beech_tree
    :parameters (?n - d000__t_entity ?t - d000__t_location)
    :precondition (d000__p_sound_heard ?n ?t)
    :effect (and (d000__p_at ?n ?t) (not (d000__p_at ?n d000__c_bench)))
  )

  (:action d000__a_eat_pellet_and_shrink
    :parameters (?n - d000__t_entity ?p - d000__t_item)
    :precondition (d000__p_has ?n ?p)
    :effect (and (d000__p_pellet_eaten ?n) (d000__p_shrunk ?n) (not (d000__p_has ?n ?p)))
  )

  (:action d000__a_enter_tree_and_descend_stairs
    :parameters (?d - d000__t_entity ?n - d000__t_entity ?corridor - d000__t_location ?door - d000__t_location ?stairs - d000__t_location ?t - d000__t_location)
    :precondition (and (d000__p_inside ?n ?t) (d000__p_inside ?d ?t) (d000__p_door_open d000__c_door))
    :effect (and (d000__p_stairs_descended ?n) (d000__p_stairs_descended ?d) (d000__p_corridor_reached ?n))
  )

  (:action d000__a_hear_tapping_on_beech
    :parameters (?n - d000__t_entity ?t - d000__t_location)
    :precondition (d000__p_at ?n d000__c_bench)
    :effect (d000__p_sound_heard ?n ?t)
  )

  (:action d000__a_receive_pellet_from_gnome
    :parameters (?g - d000__t_entity ?n - d000__t_entity ?p - d000__t_item ?s - d000__t_item ?t - d000__t_location)
    :precondition (and (d000__p_inside ?n ?t) (d000__p_inside ?g ?t))
    :effect (d000__p_has ?n ?p)
  )

  (:action d000__a_receive_queen_kiss
    :parameters (?n - d000__t_entity ?q - d000__t_entity)
    :precondition (d000__p_at ?n d000__c_palace)
    :effect (and (d000__p_kissed_by ?n ?q) (d000__p_joyful ?n) (not (d000__p_gloomy ?n)))
  )

  (:action d000__a_return_to_bench_and_share_story
    :parameters (?g - d000__t_entity ?m - d000__t_entity ?n - d000__t_entity ?bench - d000__t_location)
    :precondition (d000__p_at ?n d000__c_palace)
    :effect (and (d000__p_at ?n ?bench) (d000__p_story_shared ?n ?m) (d000__p_story_shared ?n ?g) (not (d000__p_at ?n d000__c_palace)))
  )

  (:action d000__a_travel_by_leaf_boat_under_pond
    :parameters (?n - d000__t_entity ?b - d000__t_item ?palace - d000__t_location ?pond - d000__t_location)
    :precondition (and (d000__p_stairs_descended ?n) (d000__p_boat_available ?b ?pond))
    :effect (d000__p_at ?n ?palace)
  )

  (:action d000__a_travel_to_trysting_place
    :parameters (?n - d000__t_entity ?b - d000__t_location ?c - d000__t_location)
    :precondition (d000__p_at ?n ?c)
    :effect (and (d000__p_at ?n ?b) (not (d000__p_at ?n ?c)))
  )

  (:action d000__a_turn_key_on_beech
    :parameters (?n - d000__t_entity ?k - d000__t_item ?t - d000__t_location)
    :precondition (d000__p_at ?n ?t)
    :effect (and (d000__p_door_open d000__c_door) (d000__p_inside d000__c_dryad ?t) (d000__p_invitation_offered d000__c_dryad ?n) (d000__p_has ?n ?k))
  )

  (:action d000__a_witness_queen_birthday_ceremony
    :parameters (?n - d000__t_entity ?q - d000__t_entity ?palace - d000__t_location)
    :precondition (d000__p_at ?n ?palace)
    :effect (and (d000__p_joyful ?n) (d000__p_story_shared ?q ?n))
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

  (:action d002__a_approach_sun
    :parameters (?c - d002__t_entity)
    :precondition (and (d002__p_traveling ?c) (d002__p_avoid ?c d002__c_sun))
    :effect (d002__p_near ?c d002__c_sun)
  )

  (:action d002__a_arrest_meteor
    :parameters (?c - d002__t_entity ?m - d002__t_entity)
    :precondition (and (d002__p_traveling ?c) (d002__p_near ?c ?m))
    :effect (and (d002__p_arrested ?c ?m) (d002__p_detained ?m))
  )

  (:action d002__a_avoid_body
    :parameters (?b - d002__t_entity ?c - d002__t_entity)
    :precondition (and (d002__p_traveling ?c) (d002__p_avoid ?c ?b) (d002__p_near ?c ?b))
    :effect (not (d002__p_near ?c ?b))
  )

  (:action d002__a_burn_up
    :parameters (?c - d002__t_entity)
    :precondition (d002__p_near ?c d002__c_sun)
    :effect (and (d002__p_burned ?c) (not (d002__p_traveling ?c)) (not (d002__p_has_mission ?c)))
  )

  (:action d002__a_call_comet_forward
    :parameters (?c - d002__t_entity ?master - d002__t_entity)
    :precondition (and (d002__p_at ?c d002__c_courtyard) (d002__p_at ?master d002__c_courtyard))
    :effect (d002__p_summoned ?c)
  )

  (:action d002__a_cross_out_comet
    :parameters (?c - d002__t_entity)
    :precondition (d002__p_burned ?c)
    :effect (and (d002__p_crossed_out ?c) (not (d002__p_on_list ?c)))
  )

  (:action d002__a_deliver_meteor_to_bungo
    :parameters (?m - d002__t_entity)
    :precondition (d002__p_detained ?m)
    :effect (d002__p_delivered ?m d002__c_bungo)
  )

  (:action d002__a_give_order
    :parameters (?c - d002__t_entity ?master - d002__t_entity)
    :precondition (and (d002__p_at ?c d002__c_courtyard) (d002__p_at ?master d002__c_courtyard) (not (d002__p_has_mission ?c)))
    :effect (and (d002__p_has_mission ?c) (d002__p_left_turn_rule ?c) (d002__p_prohibit_speak ?c) (d002__p_avoid ?c d002__c_sun) (d002__p_avoid ?c d002__c_earth) (d002__p_avoid ?c d002__c_bungo))
  )

  (:action d002__a_prohibit_speaking_to_meteor
    :parameters (?c - d002__t_entity)
    :precondition (d002__p_has_mission ?c)
    :effect (d002__p_prohibit_speak ?c)
  )

  (:action d002__a_punish_meteor
    :parameters (?m - d002__t_entity)
    :precondition (d002__p_delivered ?m d002__c_bungo)
    :effect (d002__p_punished ?m)
  )

  (:action d002__a_speak_to_meteor
    :parameters (?c - d002__t_entity ?m - d002__t_entity)
    :precondition (and (d002__p_traveling ?c) (d002__p_prohibit_speak ?c) (d002__p_near ?c ?m))
    :effect (and (d002__p_speaks_to ?c ?m) (d002__p_rule_violation ?c))
  )

  (:action d002__a_start_travel
    :parameters (?c - d002__t_entity)
    :precondition (and (d002__p_has_mission ?c) (d002__p_gate_open))
    :effect (and (d002__p_traveling ?c) (not (d002__p_at ?c d002__c_courtyard)))
  )

  (:action d002__a_turn_left_on_meeting
    :parameters (?c - d002__t_entity ?other - d002__t_entity)
    :precondition (and (d002__p_traveling ?c) (d002__p_traveling ?other) (d002__p_left_turn_rule ?c) (d002__p_near ?c ?other))
    :effect (d002__p_left_turn_rule ?c)
  )

  (:action d003__a_ask_for_material
    :parameters (?m - d003__t_entity ?p - d003__t_entity ?i - d003__t_item)
    :precondition (and (d003__p_has_bundle ?m ?i) (d003__p_alive ?p) (d003__p_alive ?m))
    :effect (d003__p_material_requested ?p ?i)
  )

  (:action d003__a_build_house
    :parameters (?p - d003__t_entity ?i - d003__t_item ?h - d003__t_location)
    :precondition (and (d003__p_has ?p ?i) (d003__p_alive ?p) (d003__p_at ?p ?h))
    :effect (and (d003__p_house ?h ?i) (d003__p_house_intact ?h) (d003__p_door_closed ?h) (not (d003__p_has ?p ?i)))
  )

  (:action d003__a_pig_buys_butter_churn_and_hides
    :parameters (?p - d003__t_entity ?c - d003__t_item)
    :precondition (and (d003__p_at ?p d003__c_town_fair) (d003__p_alive ?p))
    :effect (and (d003__p_has ?p ?c) (d003__p_inside ?p ?c))
  )

  (:action d003__a_pig_collects_apples_and_escapes
    :parameters (?p - d003__t_entity ?a - d003__t_item ?l - d003__t_location)
    :precondition (and (d003__p_plan ?p ?l) (d003__p_alive ?p))
    :effect (and (d003__p_has ?p ?a) (d003__p_escaped ?p) (not (d003__p_plan ?p ?l)))
  )

  (:action d003__a_pig_collects_turnips
    :parameters (?p - d003__t_entity ?i - d003__t_item ?l - d003__t_location)
    :precondition (and (d003__p_plan ?p ?l) (d003__p_alive ?p))
    :effect (and (d003__p_has ?p ?i) (not (d003__p_plan ?p ?l)))
  )

  (:action d003__a_pig_prepares_boiling_pot_and_fire
    :parameters (?p - d003__t_entity ?fire - d003__t_item ?pot - d003__t_item ?h - d003__t_location)
    :precondition (and (d003__p_at ?p ?h) (d003__p_has ?p ?pot) (d003__p_has ?p ?fire) (d003__p_alive ?p))
    :effect (and (d003__p_over ?pot ?fire) (d003__p_under ?pot d003__c_chimney) (d003__p_boiling ?pot))
  )

  (:action d003__a_pig_refuses_entry
    :parameters (?w - d003__t_entity ?h - d003__t_location)
    :precondition (and (d003__p_entry_requested ?w ?h) (d003__p_alive ?w))
    :effect (and (d003__p_entry_denied ?w ?h) (not (d003__p_entry_requested ?w ?h)))
  )

  (:action d003__a_pig_rolls_churn_down_hill
    :parameters (?p - d003__t_entity ?c - d003__t_item)
    :precondition (and (d003__p_inside ?p ?c) (d003__p_alive ?p))
    :effect (and (d003__p_rolling ?c) (not (d003__p_inside ?p ?c)))
  )

  (:action d003__a_receive_material
    :parameters (?m - d003__t_entity ?p - d003__t_entity ?i - d003__t_item)
    :precondition (and (d003__p_material_requested ?p ?i) (d003__p_has_bundle ?m ?i) (d003__p_alive ?p) (d003__p_alive ?m))
    :effect (and (d003__p_has ?p ?i) (not (d003__p_material_requested ?p ?i)) (not (d003__p_has_bundle ?m ?i)))
  )

  (:action d003__a_send_sons_on_journey
    :parameters (?m - d003__t_entity ?p - d003__t_entity ?d - d003__t_location)
    :precondition (and (d003__p_at ?m d003__c_pig_home) (d003__p_at ?p d003__c_pig_home) (d003__p_alive ?m) (d003__p_alive ?p))
    :effect (and (d003__p_plan ?p ?d) (not (d003__p_at ?p d003__c_pig_home)))
  )

  (:action d003__a_wolf_attempts_chimney_entry
    :parameters (?w - d003__t_entity ?h - d003__t_location)
    :precondition (and (d003__p_house_intact ?h) (d003__p_alive ?w))
    :effect (d003__p_entry_requested ?w ?h)
  )

  (:action d003__a_wolf_blows_house_down
    :parameters (?w - d003__t_entity ?i - d003__t_item ?h - d003__t_location)
    :precondition (and (d003__p_huffed ?w) (d003__p_puffed ?w) (d003__p_house ?h ?i) (d003__p_door_closed ?h) (d003__p_alive ?w))
    :effect (and (d003__p_house_destroyed ?h) (not (d003__p_house_intact ?h)) (not (d003__p_door_closed ?h)))
  )

  (:action d003__a_wolf_eats_pig
    :parameters (?p - d003__t_entity ?w - d003__t_entity ?h - d003__t_location)
    :precondition (and (d003__p_house_destroyed ?h) (d003__p_at ?p ?h) (d003__p_alive ?p) (d003__p_alive ?w))
    :effect (and (d003__p_dead ?p) (not (d003__p_alive ?p)) (not (d003__p_at ?p ?h)))
  )

  (:action d003__a_wolf_fails_to_blow_house
    :parameters (?w - d003__t_entity ?i - d003__t_item ?h - d003__t_location)
    :precondition (and (d003__p_huffed ?w) (d003__p_puffed ?w) (d003__p_house ?h ?i) (d003__p_alive ?w))
    :effect (d003__p_house_intact ?h)
  )

  (:action d003__a_wolf_falls_into_pot_and_is_boiled
    :parameters (?w - d003__t_entity ?pot - d003__t_item)
    :precondition (and (d003__p_boiling ?pot) (d003__p_alive ?w))
    :effect (and (d003__p_dead ?w) (not (d003__p_alive ?w)))
  )

  (:action d003__a_wolf_flees_from_rolling_object
    :parameters (?w - d003__t_entity ?c - d003__t_item)
    :precondition (and (d003__p_rolling ?c) (d003__p_alive ?w))
    :effect (d003__p_escaped ?w)
  )

  (:action d003__a_wolf_huff_and_puff
    :parameters (?w - d003__t_entity ?h - d003__t_location)
    :precondition (and (d003__p_entry_denied ?w ?h) (d003__p_alive ?w))
    :effect (and (d003__p_huffed ?w) (d003__p_puffed ?w))
  )

  (:action d003__a_wolf_knocks_and_requests_entry
    :parameters (?w - d003__t_entity ?h - d003__t_location)
    :precondition (and (d003__p_at ?w ?h) (d003__p_door_closed ?h) (d003__p_alive ?w))
    :effect (d003__p_entry_requested ?w ?h)
  )

  (:action d003__a_wolf_promises_apple_orchard
    :parameters (?p - d003__t_entity ?w - d003__t_entity ?l - d003__t_location)
    :precondition (and (d003__p_alive ?w) (d003__p_alive ?p))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d003__a_wolf_promises_fair_trip
    :parameters (?p - d003__t_entity ?w - d003__t_entity ?l - d003__t_location)
    :precondition (and (d003__p_alive ?w) (d003__p_alive ?p))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d003__a_wolf_promises_turnip_field
    :parameters (?p - d003__t_entity ?w - d003__t_entity ?l - d003__t_location)
    :precondition (and (d003__p_alive ?w) (d003__p_alive ?p))
    :effect (d003__p_plan ?p ?l)
  )

  (:action d004__a_buy_boots
    :parameters (?jack - d004__t_entity ?puss - d004__t_entity ?boots - d004__t_item)
    :precondition (not (d004__p_has ?puss ?boots))
    :effect (d004__p_has ?puss ?boots)
  )

  (:action d004__a_cat_call_for_help
    :parameters (?jack - d004__t_entity ?king - d004__t_entity ?puss - d004__t_entity)
    :precondition (d004__p_drowning ?jack)
    :effect (and (d004__p_rescued_by ?jack ?king) (not (d004__p_drowning ?jack)))
  )

  (:action d004__a_cat_catch_rabbits
    :parameters (?puss - d004__t_entity ?bag - d004__t_item ?rabbit - d004__t_item ?warren - d004__t_location)
    :precondition (and (d004__p_has ?puss ?bag) (d004__p_at_item ?rabbit ?warren) (not (d004__p_contains ?bag ?rabbit)))
    :effect (and (d004__p_contains ?bag ?rabbit) (not (d004__p_at_item ?rabbit ?warren)))
  )

  (:action d004__a_cat_deliver_gifts_to_king
    :parameters (?king - d004__t_entity ?puss - d004__t_entity ?bag - d004__t_item ?rabbit - d004__t_item ?palace - d004__t_location)
    :precondition (and (d004__p_contains ?bag ?rabbit) (d004__p_at ?puss ?palace))
    :effect (and (d004__p_gift_delivered ?puss ?king ?rabbit) (not (d004__p_contains ?bag ?rabbit)))
  )

  (:action d004__a_cat_disentchant_prisoners
    :parameters (?person - d004__t_entity ?puss - d004__t_entity)
    :precondition (d004__p_alive ?puss)
    :effect (d004__p_promised_to_serve ?person d004__c_jack)
  )

  (:action d004__a_cat_eat_mouse
    :parameters (?mouse - d004__t_entity ?ogre - d004__t_entity ?puss - d004__t_entity)
    :precondition (d004__p_transformed_into ?ogre ?mouse)
    :effect (not (d004__p_transformed_into ?ogre ?mouse))
  )

  (:action d004__a_cat_ogre_transform_lion
    :parameters (?lion - d004__t_entity ?ogre - d004__t_entity ?puss - d004__t_entity)
    :precondition (and (d004__p_at ?puss d004__c_ogre_castle) (d004__p_alive ?ogre))
    :effect (d004__p_transformed_into ?ogre ?lion)
  )

  (:action d004__a_cat_ogre_transform_mouse
    :parameters (?mouse - d004__t_entity ?ogre - d004__t_entity ?puss - d004__t_entity)
    :precondition (d004__p_alive ?ogre)
    :effect (d004__p_transformed_into ?ogre ?mouse)
  )

  (:action d004__a_cat_open_castle_gates
    :parameters (?king - d004__t_entity ?puss - d004__t_entity ?castle - d004__t_location)
    :precondition (d004__p_at ?king ?castle)
    :effect (d004__p_gate_open ?castle)
  )

  (:action d004__a_cat_persuade_master_to_bathe
    :parameters (?jack - d004__t_entity ?puss - d004__t_entity ?river - d004__t_location)
    :precondition (and (d004__p_at ?jack ?river) (d004__p_at ?puss ?river))
    :effect (d004__p_drowning ?jack)
  )

  (:action d004__a_give_bag_to_cat
    :parameters (?jack - d004__t_entity ?puss - d004__t_entity ?bag - d004__t_item)
    :precondition (and (d004__p_has ?jack ?bag) (not (d004__p_has ?puss ?bag)))
    :effect (and (d004__p_has ?puss ?bag) (not (d004__p_has ?jack ?bag)))
  )

  (:action d004__a_king_send_groom_fetch_suit
    :parameters (?groom - d004__t_entity ?king - d004__t_entity ?suit - d004__t_item ?wardrobe - d004__t_location)
    :precondition (d004__p_at_item ?suit ?wardrobe)
    :effect (and (d004__p_has ?groom ?suit) (not (d004__p_at_item ?suit ?wardrobe)))
  )

  (:action d004__a_master_marry_princess
    :parameters (?jack - d004__t_entity ?princess - d004__t_entity)
    :precondition (and (not (d004__p_married ?jack ?princess)) (d004__p_at ?jack d004__c_palace))
    :effect (d004__p_married ?jack ?princess)
  )

  (:action d004__a_master_wear_suit
    :parameters (?jack - d004__t_entity ?suit - d004__t_item)
    :precondition (d004__p_has ?jack ?suit)
    :effect (and (d004__p_wearing ?jack ?suit) (not (d004__p_has ?jack ?suit)))
  )

  (:action d005__a_arrive_at_marble_palace
    :parameters (?p - d005__t_entity)
    :precondition (d005__p_at ?p d005__c_oak_tree)
    :effect (and (d005__p_at ?p d005__c_palace) (not (d005__p_at ?p d005__c_oak_tree)))
  )

  (:action d005__a_encounter_impostor_king
    :parameters (?i - d005__t_entity ?p - d005__t_entity)
    :precondition (and (d005__p_at ?p d005__c_city) (d005__p_at ?i d005__c_market_place))
    :effect (and (d005__p_at ?p d005__c_market_place) (not (d005__p_at ?p d005__c_city)))
  )

  (:action d005__a_encounter_robbers_in_forest
    :parameters (?p - d005__t_entity)
    :precondition (d005__p_at ?p d005__c_forest)
    :effect (and (d005__p_at ?p d005__c_oak_tree) (not (d005__p_at ?p d005__c_forest)))
  )

  (:action d005__a_king_proposes_marriage
    :parameters (?k - d005__t_entity ?p - d005__t_entity)
    :precondition (and (d005__p_at ?p d005__c_palace) (d005__p_at ?k d005__c_palace))
    :effect (d005__p_married ?p ?k)
  )

  (:action d005__a_king_requests_information_and_gifts
    :parameters (?k - d005__t_entity ?p - d005__t_entity ?r - d005__t_item ?s - d005__t_item)
    :precondition (and (d005__p_at ?p d005__c_palace) (d005__p_has ?p ?r) (d005__p_has ?p ?s) (d005__p_at ?k d005__c_palace))
    :effect (and (d005__p_has ?k ?r) (d005__p_has ?k ?s) (not (d005__p_has ?p ?r)) (not (d005__p_has ?p ?s)))
  )

  (:action d005__a_princess_accepts_with_heart
    :parameters (?k - d005__t_entity ?p - d005__t_entity)
    :precondition (and (d005__p_married ?p ?k) (not (d005__p_with_all_my_heart_spoken)))
    :effect (d005__p_with_all_my_heart_spoken)
  )

  (:action d005__a_receive_rubies_from_impostor
    :parameters (?i - d005__t_entity ?p - d005__t_entity ?r - d005__t_item)
    :precondition (and (d005__p_price_of_butter_spoken) (d005__p_at ?p d005__c_market_place) (d005__p_has ?i ?r))
    :effect (and (d005__p_has ?p ?r) (not (d005__p_has ?i ?r)))
  )

  (:action d005__a_receive_sapphires_from_robber_chief
    :parameters (?c - d005__t_entity ?p - d005__t_entity ?s - d005__t_item)
    :precondition (and (d005__p_grandmother_mangle_spoken) (d005__p_at ?p d005__c_oak_tree) (d005__p_has ?c ?s))
    :effect (and (d005__p_has ?p ?s) (not (d005__p_has ?c ?s)))
  )

  (:action d005__a_run_away_from_palace
    :parameters (?p - d005__t_entity)
    :precondition (d005__p_at ?p d005__c_back_stairs)
    :effect (and (d005__p_at ?p d005__c_city) (not (d005__p_at ?p d005__c_back_stairs)))
  )

  (:action d005__a_suitors_retire_due_to_phrase
    :parameters (?s - d005__t_entity)
    :precondition (and (d005__p_grandmother_mangle_spoken) (d005__p_at ?s d005__c_palace))
    :effect (not (d005__p_married ?s d005__c_princess))
  )

  (:action d005__a_utter_phrase_grandmother_mangle
    :parameters (?p - d005__t_entity)
    :precondition (and (d005__p_at ?p d005__c_oak_tree) (not (d005__p_grandmother_mangle_spoken)))
    :effect (d005__p_grandmother_mangle_spoken)
  )

  (:action d005__a_utter_phrase_price_of_butter
    :parameters (?p - d005__t_entity)
    :precondition (and (d005__p_at ?p d005__c_market_place) (not (d005__p_price_of_butter_spoken)))
    :effect (d005__p_price_of_butter_spoken)
  )

  (:action d006__a_accept_woe_as_burden
    :parameters (?rich - d006__t_entity ?woe - d006__t_entity)
    :precondition (d006__p_woe_on_shoulder ?woe ?rich)
    :effect (d006__p_has_fatigue ?rich)
  )

  (:action d006__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - d006__t_entity ?woe - d006__t_entity ?loc - d006__t_location)
    :precondition (and (d006__p_at ?poor ?loc) (d006__p_at ?woe ?loc) (d006__p_has_fatigue ?poor))
    :effect (d006__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d006__a_bow_to_guests
    :parameters (?poor - d006__t_entity ?loc - d006__t_location)
    :precondition (and (d006__p_at ?poor ?loc) (exists (?guest - d006__t_entity) (d006__p_guest_present ?guest ?loc)))
    :effect (d006__p_bowed ?poor ?loc)
  )

  (:action d006__a_encounter_bitter_woe
    :parameters (?poor - d006__t_entity ?woe - d006__t_entity ?loc - d006__t_location)
    :precondition (and (d006__p_at ?poor ?loc) (d006__p_at ?woe ?loc))
    :effect (d006__p_has_fatigue ?poor)
  )

  (:action d006__a_hide_woe_under_stone
    :parameters (?poor - d006__t_entity ?woe - d006__t_entity ?stone - d006__t_item ?loc - d006__t_location)
    :precondition (and (d006__p_woe_on_shoulder ?woe ?poor) (d006__p_stone_at ?stone ?loc))
    :effect (and (d006__p_trapped ?woe) (d006__p_stone_at ?stone ?loc) (not (d006__p_woe_on_shoulder ?woe ?poor)) (not (d006__p_stone_moved ?stone)))
  )

  (:action d006__a_invite_rich_brother_to_feast
    :parameters (?poor - d006__t_entity ?rich - d006__t_entity ?loc - d006__t_location)
    :precondition (d006__p_at ?poor ?loc)
    :effect (and (d006__p_invitation_sent ?poor ?rich) (d006__p_invited ?rich ?poor))
  )

  (:action d006__a_make_sign_of_cross
    :parameters (?poor - d006__t_entity ?woe - d006__t_entity ?loc - d006__t_location)
    :precondition (and (d006__p_at ?poor ?loc) (d006__p_at ?woe ?loc))
    :effect (d006__p_has_fatigue ?poor)
  )

  (:action d006__a_move_heavy_stone
    :parameters (?carrier - d006__t_entity ?stone - d006__t_item ?loc - d006__t_location)
    :precondition (and (d006__p_stone_at ?stone ?loc) (d006__p_has_strength ?carrier))
    :effect (and (d006__p_stone_moved ?stone) (not (d006__p_stone_at ?stone ?loc)))
  )

  (:action d006__a_perform_work_for_rich_brother
    :parameters (?employer - d006__t_entity ?worker - d006__t_entity)
    :precondition (and (d006__p_employed ?worker ?employer) (d006__p_has_strength ?worker))
    :effect (and (d006__p_work_done ?worker ?employer) (d006__p_has_fatigue ?worker))
  )

  (:action d006__a_receive_payment
    :parameters (?employer - d006__t_entity ?worker - d006__t_entity ?bread - d006__t_item ?money - d006__t_item)
    :precondition (and (d006__p_work_done ?worker ?employer) (d006__p_has ?employer ?money) (d006__p_has ?employer ?bread))
    :effect (and (d006__p_has ?worker ?money) (d006__p_has ?worker ?bread) (not (d006__p_has ?employer ?money)) (not (d006__p_has ?employer ?bread)))
  )

  (:action d006__a_request_help_from_rich_brother
    :parameters (?poor - d006__t_entity ?rich - d006__t_entity)
    :precondition (and (d006__p_need_help ?poor) (d006__p_rich ?rich))
    :effect (and (d006__p_employed ?poor ?rich) (not (d006__p_need_help ?poor)))
  )

  (:action d006__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - d006__t_entity ?stone - d006__t_item ?loc - d006__t_location)
    :precondition (and (d006__p_stone_at ?stone ?loc) (d006__p_rich ?rich))
    :effect (and (d006__p_stone_moved ?stone) (d006__p_woe_on_shoulder d006__c_bitter_woe ?rich) (not (d006__p_stone_at ?stone ?loc)))
  )

  (:action d006__a_sing_cheerful_song
    :parameters (?poor - d006__t_entity ?loc - d006__t_location)
    :precondition (d006__p_at ?poor ?loc)
    :effect (d006__p_singing ?poor)
  )

  (:action d006__a_spend_money_on_drink
    :parameters (?poor - d006__t_entity ?money - d006__t_item ?wine - d006__t_item ?kabak - d006__t_location)
    :precondition (and (d006__p_has ?poor ?money) (d006__p_at ?poor ?kabak))
    :effect (and (d006__p_has ?poor ?wine) (d006__p_drunk ?poor) (not (d006__p_has ?poor ?money)))
  )

  (:action d006__a_stay_for_banquet
    :parameters (?guest - d006__t_entity ?host - d006__t_entity ?loc - d006__t_location)
    :precondition (and (d006__p_at ?guest ?loc) (d006__p_at ?host ?loc) (d006__p_banquet_at ?loc) (d006__p_invited ?guest ?host))
    :effect (d006__p_guest_present ?guest ?loc)
  )

  (:action d006__a_take_gold_pot_and_hide
    :parameters (?poor - d006__t_entity ?gold - d006__t_item ?loc - d006__t_location)
    :precondition (and (d006__p_gold_at ?gold ?loc) (d006__p_at ?poor ?loc))
    :effect (and (d006__p_has ?poor ?gold) (d006__p_concealed ?gold) (not (d006__p_gold_at ?gold ?loc)))
  )

  (:action d006__a_trade_assets_for_money
    :parameters (?poor - d006__t_entity ?asset - d006__t_item ?money - d006__t_item)
    :precondition (d006__p_has ?poor ?asset)
    :effect (and (d006__p_has ?poor ?money) (not (d006__p_has ?poor ?asset)))
  )
)
