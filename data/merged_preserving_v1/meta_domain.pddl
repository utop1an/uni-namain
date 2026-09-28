(define (domain narrative_union)
  (:requirements :conditional-effects :disjunctive-preconditions :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location d001__t_entity d001__t_item d001__t_location d002__t_entity d002__t_item d002__t_location d003__t_entity d003__t_item d003__t_location d004__t_entity d004__t_item d004__t_location d005__t_entity d005__t_item d005__t_location d006__t_entity d006__t_item d006__t_location d007__t_entity d007__t_item d007__t_location d008__t_entity d008__t_item d008__t_location d009__t_entity d009__t_item d009__t_location d010__t_entity d010__t_item d010__t_location d011__t_entity d011__t_item d011__t_location d012__t_entity d012__t_item d012__t_location d013__t_entity d013__t_item d013__t_location d014__t_entity d014__t_item d014__t_location - object
  )
  (:constants
    d000__c_badger d000__c_friend d000__c_lady_of_court d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_tinker - d000__t_entity
    d000__c_box d000__c_copper_coins d000__c_pack d000__c_teakettle d000__c_temple_treasure - d000__t_item
    d000__c_jhosiu d000__c_morinji d000__c_tight_rope - d000__t_location
    d001__c_dryad d001__c_fairy_queen d001__c_gnome d001__c_grandmother d001__c_grandmotherkin d001__c_mother d001__c_mothereen d001__c_nora - d001__t_entity
    d001__c_boat d001__c_gold_star d001__c_key d001__c_lantern d001__c_pellet d001__c_silver_salver - d001__t_item
    d001__c_beech_tree d001__c_bench d001__c_corridor d001__c_cottage d001__c_door d001__c_fairyland d001__c_palace d001__c_pond d001__c_spring d001__c_stairs d001__c_stream - d001__t_location
    d002__c_audience d002__c_buffoon d002__c_countryman d002__c_little_pig d002__c_rich_nobleman - d002__t_entity
    d002__c_cloak - d002__t_item
    d002__c_platform d002__c_theater - d002__t_location
    d003__c_chicken-licken d003__c_cock-lock d003__c_drake-lake d003__c_duck-luck d003__c_fox-lox d003__c_gander-lander d003__c_goose-loose d003__c_hen-len d003__c_king d003__c_turkey-lurkey - d003__t_entity
    d003__c_acorn d003__c_sky - d003__t_item
    d003__c_foxhole d003__c_wood - d003__t_location
    d004__c_brother_astronomer d004__c_brother_hunter d004__c_brother_tailor d004__c_brother_thief d004__c_chaffinch d004__c_dragon d004__c_father d004__c_king d004__c_mentor_astronomer d004__c_mentor_hunter d004__c_mentor_tailor d004__c_mentor_thief d004__c_princess - d004__t_entity
    d004__c_eggs d004__c_gun d004__c_needle d004__c_planks d004__c_ship d004__c_sticks d004__c_telescope - d004__t_item
    d004__c_cross_way d004__c_house d004__c_kingdom d004__c_rock_sea d004__c_sea d004__c_town_gate d004__c_tree - d004__t_location
    d005__c_bird d005__c_duck d005__c_father d005__c_grettel d005__c_hansel d005__c_mother d005__c_witch - d005__t_entity
    d005__c_apple d005__c_bread_piece d005__c_brushwood d005__c_cake d005__c_crumb d005__c_kettle d005__c_milk d005__c_nut d005__c_oven d005__c_pancake d005__c_pearl d005__c_pebble d005__c_precious_stone d005__c_sugar_window - d005__t_item
    d005__c_branch d005__c_cottage d005__c_dead_tree d005__c_door d005__c_father_house d005__c_forest d005__c_hill d005__c_lake d005__c_path d005__c_roof d005__c_room d005__c_stable_location d005__c_window - d005__t_location
    d006__c_brown_hen d006__c_butcher d006__c_fairy_maiden d006__c_giant d006__c_giant_dog d006__c_giant_wife d006__c_jack d006__c_jack_mother d006__c_milky_white - d006__t_entity
    d006__c_axe d006__c_gold_bag_1 d006__c_gold_bag_2 d006__c_golden_harp d006__c_magic_beans d006__c_oak_tree_club - d006__t_item
    d006__c_beanstalk d006__c_castle_road d006__c_cottage d006__c_garden d006__c_giant_castle d006__c_kettle d006__c_market d006__c_oven d006__c_window - d006__t_location
    d007__c_ass d007__c_captain d007__c_cat d007__c_cock d007__c_hound d007__c_man d007__c_messenger d007__c_robber - d007__t_entity
    d007__c_drinks d007__c_kettledrums d007__c_lute d007__c_meat d007__c_straw d007__c_table - d007__t_item
    d007__c_beam d007__c_bremen d007__c_forest d007__c_hearth d007__c_road_to_bremen d007__c_robbers_cottage d007__c_window - d007__t_location
    d008__c_bungo d008__c_comet_master d008__c_earth d008__c_long_tail_45 d008__c_meteor d008__c_meteor_keeper d008__c_no1_express d008__c_short_tail_73 d008__c_sun - d008__t_entity
    d008__c_chalk d008__c_slate - d008__t_item
    d008__c_comet_house d008__c_courtyard d008__c_gate - d008__t_location
    d009__c_farmer d009__c_man_bricks d009__c_man_furze d009__c_man_straw d009__c_mother_pig d009__c_pig1 d009__c_pig2 d009__c_pig3 d009__c_squire d009__c_wolf - d009__t_entity
    d009__c_apple d009__c_bricks d009__c_butter_churn d009__c_fire d009__c_furze_bundle d009__c_mortar d009__c_pot_of_water d009__c_sack d009__c_straw_bundle d009__c_trowel d009__c_turnips_load - d009__t_item
    d009__c_brick_house d009__c_chimney d009__c_furze_house d009__c_hearth d009__c_hill d009__c_oak_forest d009__c_pig_home d009__c_squire_orchard d009__c_straw_house d009__c_town_fair d009__c_turnip_field - d009__t_location
    d010__c_coachman d010__c_eldest_son d010__c_groom d010__c_jack d010__c_king d010__c_miller d010__c_ogre d010__c_princess d010__c_puss d010__c_second_son - d010__t_entity
    d010__c_ass d010__c_bag d010__c_boots d010__c_hare d010__c_mill d010__c_partridge d010__c_rabbit d010__c_suit - d010__t_item
    d010__c_field_of_corn d010__c_field_of_wheat d010__c_ogre_castle d010__c_palace d010__c_river d010__c_royal_wardrobe d010__c_warren - d010__t_location
    d011__c_father_king d011__c_impostor_butterman d011__c_king_at_palace d011__c_princess d011__c_robber_chief - d011__t_entity
    d011__c_bag_of_rubies d011__c_bag_of_sapphires d011__c_crown d011__c_sceptre - d011__t_item
    d011__c_back_door d011__c_back_stairs d011__c_city d011__c_forest d011__c_market_place d011__c_oak_tree d011__c_palace - d011__t_location
    d012__c_boar d012__c_dove d012__c_dwarf1 d012__c_dwarf2 d012__c_dwarf3 d012__c_dwarf4 d012__c_dwarf5 d012__c_dwarf6 d012__c_dwarf7 d012__c_huntsman d012__c_king d012__c_owl d012__c_prince d012__c_queen d012__c_raven d012__c_snow_white - d012__t_entity
    d012__c_apple d012__c_bed d012__c_blood_drop d012__c_boar_heart d012__c_candle d012__c_coffin d012__c_comb d012__c_fork d012__c_golden_letter d012__c_iron_slippers d012__c_knife d012__c_lace d012__c_looking_glass d012__c_mug d012__c_needle d012__c_plate d012__c_red_hot_shoes d012__c_salt d012__c_spoon - d012__t_item
    d012__c_cottage d012__c_forest d012__c_mountain - d012__t_location
    d013__c_ant_queen d013__c_elf_chief d013__c_first_traveler_mouse d013__c_fourth_traveler_mouse d013__c_jailer d013__c_jailer_granddaughter d013__c_mouse_king d013__c_oak_dryad d013__c_old_lady_mouse d013__c_old_owl d013__c_phantaesus d013__c_second_traveler_mouse d013__c_third_traveler_mouse d013__c_watchman d013__c_young_lady_mouse - d013__t_entity
    d013__c_crape_skewer d013__c_maypole d013__c_sausage_skewer d013__c_violet - d013__t_item
    d013__c_castle d013__c_forest d013__c_kitchen d013__c_library d013__c_north d013__c_sea d013__c_ship - d013__t_location
    d014__c_bitter_woe d014__c_children d014__c_poor_brother d014__c_rich_brother d014__c_wife - d014__t_entity
    d014__c_cattle d014__c_copecks_25 d014__c_gold_pot d014__c_grove d014__c_harrow d014__c_honey d014__c_loaf_bread d014__c_plow d014__c_sledge d014__c_stone d014__c_telega d014__c_wine - d014__t_item
    d014__c_big_house d014__c_forest d014__c_izba d014__c_kabak d014__c_large_town d014__c_new_home d014__c_treasure_pit d014__c_village d014__c_well d014__c_yard - d014__t_location
  )
  (:predicates
    (d000__p_airborne ?i - d000__t_item)
    (d000__p_badger_form ?i - d000__t_item)
    (d000__p_captured ?i - d000__t_item)
    (d000__p_contained_in ?i - d000__t_item ?c - d000__t_item)
    (d000__p_exhibition_ready ?e - d000__t_entity)
    (d000__p_four_legged ?i - d000__t_item)
    (d000__p_furred ?i - d000__t_item)
    (d000__p_hanging ?i - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_located ?obj - object ?loc - d000__t_location)
    (d000__p_night)
    (d000__p_owned_by ?i - d000__t_item ?e - d000__t_entity)
    (d000__p_performing_show ?e - d000__t_entity)
    (d000__p_reputation_widespread)
    (d000__p_treasured ?i - d000__t_item)
    (d000__p_wealthy ?e - d000__t_entity)
    (d000__p_worshipped ?i - d000__t_item)
    (d001__p_at ?e - d001__t_entity ?l - d001__t_location)
    (d001__p_boat_available ?b - d001__t_item ?l - d001__t_location)
    (d001__p_corridor_reached ?e - d001__t_entity)
    (d001__p_door_open ?d - d001__t_location)
    (d001__p_gloomy ?e - d001__t_entity)
    (d001__p_gold_star_on ?e - d001__t_entity ?s - d001__t_item)
    (d001__p_has ?e - d001__t_entity ?i - d001__t_item)
    (d001__p_inside ?e - d001__t_entity ?l - d001__t_location)
    (d001__p_invitation_offered ?from - d001__t_entity ?to - d001__t_entity)
    (d001__p_joyful ?e - d001__t_entity)
    (d001__p_kissed_by ?e - d001__t_entity ?k - d001__t_entity)
    (d001__p_knighted ?e - d001__t_entity)
    (d001__p_lantern_carried ?e - d001__t_entity ?l - d001__t_item)
    (d001__p_pellet_eaten ?e - d001__t_entity)
    (d001__p_shrunk ?e - d001__t_entity)
    (d001__p_sound_heard ?e - d001__t_entity ?l - d001__t_location)
    (d001__p_stairs_descended ?e - d001__t_entity)
    (d001__p_story_shared ?speaker - d001__t_entity ?listener - d001__t_entity)
    (d002__p_applause_given ?audience - d002__t_entity ?performer - d002__t_entity)
    (d002__p_audience_calls_for_kickout ?audience - d002__t_entity ?countryman - d002__t_entity)
    (d002__p_audience_demands_shake_cloak ?audience - d002__t_entity ?performer - d002__t_entity ?cloak - d002__t_item)
    (d002__p_cloak_shaken ?performer - d002__t_entity ?cloak - d002__t_item)
    (d002__p_countryman_declares_intent ?countryman - d002__t_entity)
    (d002__p_countryman_performs_with_real_pig ?countryman - d002__t_entity ?pig - d002__t_entity)
    (d002__p_crowd_present ?audience - d002__t_entity ?theater - d002__t_location)
    (d002__p_imitates_pig ?performer - d002__t_entity)
    (d002__p_on_platform ?performer - d002__t_entity ?platform - d002__t_location)
    (d002__p_partiality_prevalent)
    (d002__p_performs_without_apparatus ?performer - d002__t_entity)
    (d002__p_pig_found ?performer - d002__t_entity ?pig - d002__t_entity)
    (d002__p_pig_revealed ?countryman - d002__t_entity ?pig - d002__t_entity)
    (d002__p_reward_announced ?nobleman - d002__t_entity)
    (d002__p_theater_opened ?nobleman - d002__t_entity ?theater - d002__t_location)
    (d003__p_at ?e - d003__t_entity ?l - d003__t_location)
    (d003__p_decided_to_tell_king ?e - d003__t_entity)
    (d003__p_eaten_by_fox ?e - d003__t_entity)
    (d003__p_following_fox ?e - d003__t_entity)
    (d003__p_going_to_wood ?e - d003__t_entity)
    (d003__p_informed_about_sky_fall ?informer - d003__t_entity ?listener - d003__t_entity)
    (d003__p_met ?e1 - d003__t_entity ?e2 - d003__t_entity)
    (d003__p_sky_fell_on_head ?e - d003__t_entity)
    (d003__p_turned_back ?e - d003__t_entity)
    (d004__p_dragon_dead)
    (d004__p_eggs_fetched ?e - d004__t_entity)
    (d004__p_eggs_sewn ?e - d004__t_entity)
    (d004__p_eggs_shot ?e - d004__t_entity)
    (d004__p_entity_at ?e - d004__t_entity ?l - d004__t_location)
    (d004__p_half_kingdom ?e - d004__t_entity ?k - d004__t_location)
    (d004__p_has ?e - d004__t_entity ?i - d004__t_item)
    (d004__p_is_astronomer ?e - d004__t_entity)
    (d004__p_is_hunter ?e - d004__t_entity)
    (d004__p_is_tailor ?e - d004__t_entity)
    (d004__p_is_thief ?e - d004__t_entity)
    (d004__p_item_at ?i - d004__t_item ?l - d004__t_location)
    (d004__p_princess_rescued ?e - d004__t_entity)
    (d004__p_reward_received ?e - d004__t_entity)
    (d004__p_ship_broken)
    (d004__p_ship_repaired)
    (d005__p_at ?e - d005__t_entity ?l - d005__t_location)
    (d005__p_bird_heard ?c - d005__t_entity ?l - d005__t_location)
    (d005__p_bread_given ?c - d005__t_entity)
    (d005__p_captured ?c - d005__t_entity)
    (d005__p_collected ?c - d005__t_entity ?i - d005__t_item)
    (d005__p_crossed_lake ?c - d005__t_entity)
    (d005__p_crumb_on_path ?l - d005__t_location)
    (d005__p_dead ?e - d005__t_entity)
    (d005__p_duck_helped ?c - d005__t_entity ?d - d005__t_entity)
    (d005__p_fire_lit ?l - d005__t_location)
    (d005__p_has ?e - d005__t_entity ?i - d005__t_item)
    (d005__p_locked ?l - d005__t_location)
    (d005__p_lost ?c - d005__t_entity)
    (d005__p_pebble_on_path ?l - d005__t_location)
    (d005__p_reunited_with_father ?c - d005__t_entity)
    (d006__p_asleep ?e - d006__t_entity)
    (d006__p_at ?e - d006__t_entity ?l - d006__t_location)
    (d006__p_at_item ?i - d006__t_item ?l - d006__t_location)
    (d006__p_beanstalk_grown)
    (d006__p_climbing_down ?e - d006__t_entity)
    (d006__p_dead ?e - d006__t_entity)
    (d006__p_distracted ?e - d006__t_entity)
    (d006__p_empty ?i - d006__t_item)
    (d006__p_has ?e - d006__t_entity ?i - d006__t_item)
    (d006__p_has_breakfast ?e - d006__t_entity)
    (d006__p_inside ?e - d006__t_entity ?i - d006__t_item)
    (d006__p_intact ?l - d006__t_location)
    (d006__p_offers ?e - d006__t_entity ?i - d006__t_item)
    (d006__p_on ?i - d006__t_item ?l - d006__t_location)
    (d006__p_planted ?i - d006__t_item)
    (d007__p_agreed ?e - d007__t_entity ?inviter - d007__t_entity)
    (d007__p_at ?e - d007__t_entity ?l - d007__t_location)
    (d007__p_ate_all ?e - d007__t_entity)
    (d007__p_attacked ?attacker - d007__t_entity ?target - d007__t_entity)
    (d007__p_attempt_light ?messenger - d007__t_entity)
    (d007__p_bite ?dog - d007__t_entity ?target - d007__t_entity)
    (d007__p_crowed ?cock - d007__t_entity)
    (d007__p_fled ?robber - d007__t_entity ?loc - d007__t_location)
    (d007__p_invited ?inviter - d007__t_entity ?invitee - d007__t_entity)
    (d007__p_kick ?donkey - d007__t_entity ?target - d007__t_entity)
    (d007__p_light_off ?loc - d007__t_location)
    (d007__p_light_on ?loc - d007__t_location)
    (d007__p_making_noise ?e - d007__t_entity)
    (d007__p_moving_towards ?e - d007__t_entity ?loc - d007__t_location)
    (d007__p_resting ?e - d007__t_entity)
    (d007__p_retreated ?robber - d007__t_entity)
    (d007__p_sees_light ?e - d007__t_entity)
    (d007__p_sleeping_at ?e - d007__t_entity ?loc - d007__t_location)
    (d007__p_stacked_on ?top - d007__t_entity ?bottom - d007__t_entity)
    (d007__p_window_shattered)
    (d008__p_arrested ?c - d008__t_entity ?m - d008__t_entity)
    (d008__p_at ?e - d008__t_entity ?l - d008__t_location)
    (d008__p_avoid ?c - d008__t_entity ?b - d008__t_entity)
    (d008__p_burned ?c - d008__t_entity)
    (d008__p_crossed_out ?c - d008__t_entity)
    (d008__p_delivered ?m - d008__t_entity ?p - d008__t_entity)
    (d008__p_detained ?m - d008__t_entity)
    (d008__p_gate_open)
    (d008__p_has_mission ?c - d008__t_entity)
    (d008__p_left_turn_rule ?c - d008__t_entity)
    (d008__p_near ?c - d008__t_entity ?b - d008__t_entity)
    (d008__p_on_list ?c - d008__t_entity)
    (d008__p_prohibit_speak ?c - d008__t_entity)
    (d008__p_punished ?m - d008__t_entity)
    (d008__p_rule_violation ?c - d008__t_entity)
    (d008__p_speaks_to ?c - d008__t_entity ?m - d008__t_entity)
    (d008__p_summoned ?c - d008__t_entity)
    (d008__p_traveling ?c - d008__t_entity)
    (d009__p_alive ?e - d009__t_entity)
    (d009__p_at ?e - d009__t_entity ?l - d009__t_location)
    (d009__p_boiling ?i - d009__t_item)
    (d009__p_dead ?e - d009__t_entity)
    (d009__p_door_closed ?h - d009__t_location)
    (d009__p_entry_denied ?w - d009__t_entity ?h - d009__t_location)
    (d009__p_entry_requested ?w - d009__t_entity ?h - d009__t_location)
    (d009__p_escaped ?e - d009__t_entity)
    (d009__p_has ?e - d009__t_entity ?i - d009__t_item)
    (d009__p_has_bundle ?m - d009__t_entity ?i - d009__t_item)
    (d009__p_house ?h - d009__t_location ?m - d009__t_item)
    (d009__p_house_destroyed ?h - d009__t_location)
    (d009__p_house_intact ?h - d009__t_location)
    (d009__p_huffed ?w - d009__t_entity)
    (d009__p_inside ?e - d009__t_entity ?c - d009__t_item)
    (d009__p_material_requested ?p - d009__t_entity ?i - d009__t_item)
    (d009__p_over ?i1 - d009__t_item ?i2 - d009__t_item)
    (d009__p_plan ?e - d009__t_entity ?l - d009__t_location)
    (d009__p_puffed ?w - d009__t_entity)
    (d009__p_rolling ?i - d009__t_item)
    (d009__p_under ?i - d009__t_item ?l - d009__t_location)
    (d010__p_alive ?x - d010__t_entity)
    (d010__p_at ?x - d010__t_entity ?l - d010__t_location)
    (d010__p_at_item ?i - d010__t_item ?l - d010__t_location)
    (d010__p_castle_owned_by ?castle - d010__t_location ?owner - d010__t_entity)
    (d010__p_contains ?c - d010__t_item ?i - d010__t_item)
    (d010__p_drowning ?e - d010__t_entity)
    (d010__p_gate_open ?castle - d010__t_location)
    (d010__p_gift_delivered ?giver - d010__t_entity ?receiver - d010__t_entity ?item - d010__t_item)
    (d010__p_has ?e - d010__t_entity ?i - d010__t_item)
    (d010__p_married ?e1 - d010__t_entity ?e2 - d010__t_entity)
    (d010__p_obedient ?e - d010__t_entity)
    (d010__p_promised_to_serve ?servant - d010__t_entity ?master - d010__t_entity)
    (d010__p_rescued_by ?victim - d010__t_entity ?rescuer - d010__t_entity)
    (d010__p_transformed_into ?e - d010__t_entity ?form - d010__t_entity)
    (d010__p_wearing ?e - d010__t_entity ?i - d010__t_item)
    (d011__p_at ?e - d011__t_entity ?l - d011__t_location)
    (d011__p_grandmother_mangle_spoken)
    (d011__p_has ?e - d011__t_entity ?i - d011__t_item)
    (d011__p_married ?p1 - d011__t_entity ?p2 - d011__t_entity)
    (d011__p_price_of_butter_spoken)
    (d011__p_with_all_my_heart_spoken)
    (d012__p_alive ?e - d012__t_entity)
    (d012__p_at ?e - d012__t_entity ?l - d012__t_location)
    (d012__p_at_item ?i - d012__t_item ?l - d012__t_location)
    (d012__p_awake ?e - d012__t_entity)
    (d012__p_dead ?e - d012__t_entity)
    (d012__p_disguised_as ?e - d012__t_entity ?d - d012__t_entity)
    (d012__p_envious ?e - d012__t_entity)
    (d012__p_fair ?e - d012__t_entity)
    (d012__p_fairest ?e - d012__t_entity)
    (d012__p_has ?e - d012__t_entity ?i - d012__t_item)
    (d012__p_in_coffin ?e - d012__t_entity)
    (d012__p_laced ?e - d012__t_entity ?i - d012__t_item)
    (d012__p_poisoned ?i - d012__t_item)
    (d012__p_sleeping ?e - d012__t_entity)
    (d012__p_visited ?e - d012__t_entity ?l - d012__t_location)
    (d012__p_wearing ?e - d012__t_entity ?i - d012__t_item)
    (d013__p_anointed ?i - d013__t_item)
    (d013__p_at ?e - d013__t_entity ?l - d013__t_location)
    (d013__p_captured ?e - d013__t_entity)
    (d013__p_escaped ?e - d013__t_entity)
    (d013__p_has_feeling ?e - d013__t_entity)
    (d013__p_has_imagination ?e - d013__t_entity)
    (d013__p_has_understanding ?e - d013__t_entity)
    (d013__p_holds ?e - d013__t_entity ?i - d013__t_item)
    (d013__p_in_cage ?e - d013__t_entity)
    (d013__p_is_poet ?e - d013__t_entity)
    (d013__p_is_queen ?e - d013__t_entity)
    (d013__p_king_tail_stirred)
    (d013__p_soup_effect_created ?e - d013__t_entity)
    (d014__p_at ?e - d014__t_entity ?l - d014__t_location)
    (d014__p_banquet_at ?l - d014__t_location)
    (d014__p_bowed ?e - d014__t_entity ?l - d014__t_location)
    (d014__p_concealed ?i - d014__t_item)
    (d014__p_drunk ?e - d014__t_entity)
    (d014__p_employed ?worker - d014__t_entity ?employer - d014__t_entity)
    (d014__p_gold_at ?g - d014__t_item ?l - d014__t_location)
    (d014__p_guest_present ?guest - d014__t_entity ?l - d014__t_location)
    (d014__p_has ?e - d014__t_entity ?i - d014__t_item)
    (d014__p_has_fatigue ?e - d014__t_entity)
    (d014__p_has_strength ?e - d014__t_entity)
    (d014__p_invitation_sent ?sender - d014__t_entity ?receiver - d014__t_entity)
    (d014__p_invited ?invitee - d014__t_entity ?host - d014__t_entity)
    (d014__p_need_help ?e - d014__t_entity)
    (d014__p_poor ?e - d014__t_entity)
    (d014__p_rich ?e - d014__t_entity)
    (d014__p_singing ?e - d014__t_entity)
    (d014__p_stone_at ?s - d014__t_item ?l - d014__t_location)
    (d014__p_stone_moved ?s - d014__t_item)
    (d014__p_trapped ?m - d014__t_entity)
    (d014__p_woe_on_shoulder ?monster - d014__t_entity ?carrier - d014__t_entity)
    (d014__p_work_done ?worker - d014__t_entity ?employer - d014__t_entity)
  )

  (:action d000__a_arrange_exhibition
    :parameters (?s - d000__t_entity ?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_exhibition_ready ?t)
  )

  (:action d000__a_call_novices
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_badger_form ?k)
    :effect (d000__p_located ?k d000__c_morinji)
  )

  (:action d000__a_force_kettle_into_box
    :parameters (?b - d000__t_item ?k - d000__t_item)
    :precondition (d000__p_captured ?k)
    :effect (d000__p_contained_in ?k ?b)
  )

  (:action d000__a_hang_kettle
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?pr ?k)
    :effect (d000__p_hanging ?k)
  )

  (:action d000__a_kettle_jump_and_fly
    :parameters (?k - d000__t_item)
    :precondition (d000__p_badger_form ?k)
    :effect (d000__p_airborne ?k)
  )

  (:action d000__a_kettle_revert_shape
    :parameters (?k - d000__t_item)
    :precondition (and (d000__p_badger_form ?k) (d000__p_furred ?k))
    :effect (and (not (d000__p_badger_form ?k)) (not (d000__p_furred ?k)) (not (d000__p_four_legged ?k)))
  )

  (:action d000__a_kettle_transform_to_badger
    :parameters (?k - d000__t_item)
    :precondition (d000__p_hanging ?k)
    :effect (d000__p_badger_form ?k)
  )

  (:action d000__a_kettle_transform_to_fur_badger
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_night) (d000__p_located ?k d000__c_jhosiu) (d000__p_has ?t ?k))
    :effect (and (d000__p_furred ?k) (d000__p_badger_form ?k) (d000__p_four_legged ?k))
  )

  (:action d000__a_knock_down_kettle
    :parameters (?k - d000__t_item)
    :precondition (d000__p_airborne ?k)
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_perform_show
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_exhibition_ready ?t) (d000__p_has ?t ?k))
    :effect (and (d000__p_performing_show ?t) (d000__p_reputation_widespread))
  )

  (:action d000__a_pursue_kettle
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_airborne ?k)
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_receive_orders_from_nobility
    :parameters (?t - d000__t_entity)
    :precondition (d000__p_reputation_widespread)
    :effect (d000__p_wealthy ?t)
  )

  (:action d000__a_return_kettle_to_temple
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_has ?t ?k) (d000__p_wealthy ?t))
    :effect (and (d000__p_located ?k d000__c_morinji) (d000__p_treasured ?k) (not (d000__p_has ?t ?k)))
  )

  (:action d000__a_sell_kettle_to_tinker
    :parameters (?pr - d000__t_entity ?t - d000__t_entity ?c - d000__t_item ?k - d000__t_item)
    :precondition (and (d000__p_has ?pr ?k) (d000__p_has ?t ?c))
    :effect (and (d000__p_has ?t ?k) (d000__p_has ?pr ?c) (not (d000__p_has ?pr ?k)) (not (d000__p_has ?t ?c)))
  )

  (:action d000__a_show_kettle_to_friend
    :parameters (?f - d000__t_entity ?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_has ?f ?k)
  )

  (:action d000__a_tinker_carry_home
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_located ?k d000__c_jhosiu)
  )

  (:action d000__a_worship_kettle_as_saint
    :parameters (?k - d000__t_item)
    :precondition (d000__p_treasured ?k)
    :effect (d000__p_worshipped ?k)
  )

  (:action d001__a_accept_dryad_invitation
    :parameters (?d - d001__t_entity ?n - d001__t_entity)
    :precondition (d001__p_invitation_offered ?d ?n)
    :effect (not (d001__p_invitation_offered ?d ?n))
  )

  (:action d001__a_approach_beech_tree
    :parameters (?n - d001__t_entity ?t - d001__t_location)
    :precondition (d001__p_sound_heard ?n ?t)
    :effect (and (d001__p_at ?n ?t) (not (d001__p_at ?n d001__c_bench)))
  )

  (:action d001__a_eat_pellet_and_shrink
    :parameters (?n - d001__t_entity ?p - d001__t_item)
    :precondition (d001__p_has ?n ?p)
    :effect (and (d001__p_pellet_eaten ?n) (d001__p_shrunk ?n) (not (d001__p_has ?n ?p)))
  )

  (:action d001__a_enter_tree_and_descend_stairs
    :parameters (?d - d001__t_entity ?n - d001__t_entity ?corridor - d001__t_location ?door - d001__t_location ?stairs - d001__t_location ?t - d001__t_location)
    :precondition (and (d001__p_inside ?n ?t) (d001__p_inside ?d ?t) (d001__p_door_open d001__c_door))
    :effect (and (d001__p_stairs_descended ?n) (d001__p_stairs_descended ?d) (d001__p_corridor_reached ?n))
  )

  (:action d001__a_hear_tapping_on_beech
    :parameters (?n - d001__t_entity ?t - d001__t_location)
    :precondition (d001__p_at ?n d001__c_bench)
    :effect (d001__p_sound_heard ?n ?t)
  )

  (:action d001__a_receive_pellet_from_gnome
    :parameters (?g - d001__t_entity ?n - d001__t_entity ?p - d001__t_item ?s - d001__t_item ?t - d001__t_location)
    :precondition (and (d001__p_inside ?n ?t) (d001__p_inside ?g ?t))
    :effect (d001__p_has ?n ?p)
  )

  (:action d001__a_receive_queen_kiss
    :parameters (?n - d001__t_entity ?q - d001__t_entity)
    :precondition (d001__p_at ?n d001__c_palace)
    :effect (and (d001__p_kissed_by ?n ?q) (d001__p_joyful ?n) (not (d001__p_gloomy ?n)))
  )

  (:action d001__a_return_to_bench_and_share_story
    :parameters (?g - d001__t_entity ?m - d001__t_entity ?n - d001__t_entity ?bench - d001__t_location)
    :precondition (d001__p_at ?n d001__c_palace)
    :effect (and (d001__p_at ?n ?bench) (d001__p_story_shared ?n ?m) (d001__p_story_shared ?n ?g) (not (d001__p_at ?n d001__c_palace)))
  )

  (:action d001__a_travel_by_leaf_boat_under_pond
    :parameters (?n - d001__t_entity ?b - d001__t_item ?palace - d001__t_location ?pond - d001__t_location)
    :precondition (and (d001__p_stairs_descended ?n) (d001__p_boat_available ?b ?pond))
    :effect (d001__p_at ?n ?palace)
  )

  (:action d001__a_travel_to_trysting_place
    :parameters (?n - d001__t_entity ?b - d001__t_location ?c - d001__t_location)
    :precondition (d001__p_at ?n ?c)
    :effect (and (d001__p_at ?n ?b) (not (d001__p_at ?n ?c)))
  )

  (:action d001__a_turn_key_on_beech
    :parameters (?n - d001__t_entity ?k - d001__t_item ?t - d001__t_location)
    :precondition (d001__p_at ?n ?t)
    :effect (and (d001__p_door_open d001__c_door) (d001__p_inside d001__c_dryad ?t) (d001__p_invitation_offered d001__c_dryad ?n) (d001__p_has ?n ?k))
  )

  (:action d001__a_witness_queen_birthday_ceremony
    :parameters (?n - d001__t_entity ?q - d001__t_entity ?palace - d001__t_location)
    :precondition (d001__p_at ?n ?palace)
    :effect (and (d001__p_joyful ?n) (d001__p_story_shared ?q ?n))
  )

  (:action d002__a_audience_applaud_performance
    :parameters (?audience - d002__t_entity ?performer - d002__t_entity ?pig - d002__t_entity ?cloak - d002__t_item)
    :precondition (and (d002__p_cloak_shaken ?performer ?cloak) (not (d002__p_pig_found ?performer ?pig)))
    :effect (d002__p_applause_given ?audience ?performer)
  )

  (:action d002__a_audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience - d002__t_entity ?countryman - d002__t_entity ?pig - d002__t_entity)
    :precondition (d002__p_countryman_performs_with_real_pig ?countryman ?pig)
    :effect (d002__p_audience_calls_for_kickout ?audience ?countryman)
  )

  (:action d002__a_audience_demand_shake_cloak_for_pig
    :parameters (?audience - d002__t_entity ?performer - d002__t_entity ?cloak - d002__t_item)
    :effect (d002__p_audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action d002__a_countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - d002__t_entity)
    :effect (d002__p_countryman_declares_intent ?countryman)
  )

  (:action d002__a_countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman - d002__t_entity ?pig - d002__t_entity ?platform - d002__t_location)
    :precondition (and (d002__p_countryman_declares_intent ?countryman) (d002__p_on_platform ?countryman ?platform))
    :effect (d002__p_countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action d002__a_countryman_reveal_real_pig
    :parameters (?audience - d002__t_entity ?countryman - d002__t_entity ?pig - d002__t_entity)
    :precondition (d002__p_audience_calls_for_kickout ?audience ?countryman)
    :effect (d002__p_pig_revealed ?countryman ?pig)
  )

  (:action d002__a_open_theater_and_announce_reward
    :parameters (?nobleman - d002__t_entity ?theater - d002__t_location)
    :effect (and (d002__p_theater_opened ?nobleman ?theater) (d002__p_reward_announced ?nobleman))
  )

  (:action d002__a_perform_pig_imitation_without_apparatus
    :parameters (?performer - d002__t_entity ?platform - d002__t_location)
    :precondition (d002__p_on_platform ?performer ?platform)
    :effect (and (d002__p_performs_without_apparatus ?performer) (d002__p_imitates_pig ?performer))
  )

  (:action d003__a_be_eaten_by_fox
    :parameters (?e - d003__t_entity ?l - d003__t_location)
    :precondition (and (d003__p_following_fox ?e) (d003__p_at ?e ?l) (not (d003__p_eaten_by_fox ?e)))
    :effect (and (d003__p_at ?e d003__c_foxhole) (d003__p_eaten_by_fox ?e) (not (d003__p_at ?e ?l)) (not (d003__p_following_fox ?e)))
  )

  (:action d003__a_decide_to_tell_king
    :parameters (?e - d003__t_entity)
    :precondition (and (exists (?inf - d003__t_entity) (d003__p_informed_about_sky_fall ?inf ?e)) (not (d003__p_decided_to_tell_king ?e)))
    :effect (d003__p_decided_to_tell_king ?e)
  )

  (:action d003__a_follow_fox
    :parameters (?e - d003__t_entity)
    :precondition (and (d003__p_decided_to_tell_king ?e) (not (d003__p_following_fox ?e)))
    :effect (d003__p_following_fox ?e)
  )

  (:action d003__a_go_to_wood
    :parameters (?e - d003__t_entity)
    :precondition (and (not (d003__p_at ?e d003__c_wood)) (not (d003__p_going_to_wood ?e)))
    :effect (d003__p_going_to_wood ?e)
  )

  (:action d003__a_inform_about_sky_fall
    :parameters (?informer - d003__t_entity ?listener - d003__t_entity)
    :precondition (and (d003__p_met ?informer ?listener) (d003__p_sky_fell_on_head d003__c_chicken-licken) (not (d003__p_informed_about_sky_fall ?informer ?listener)))
    :effect (d003__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d003__a_meet_character
    :parameters (?e1 - d003__t_entity ?e2 - d003__t_entity ?l - d003__t_location)
    :precondition (and (d003__p_at ?e1 ?l) (d003__p_at ?e2 ?l) (not (d003__p_met ?e1 ?e2)))
    :effect (and (d003__p_met ?e1 ?e2) (d003__p_met ?e2 ?e1))
  )

  (:action d003__a_turn_back
    :parameters (?e - d003__t_entity)
    :precondition (and (d003__p_going_to_wood ?e) (not (d003__p_turned_back ?e)))
    :effect (and (d003__p_turned_back ?e) (not (d003__p_going_to_wood ?e)))
  )

  (:action d004__a_count_eggs
    :parameters (?a - d004__t_entity)
    :precondition (and (d004__p_is_astronomer ?a) (d004__p_has ?a d004__c_telescope) (d004__p_entity_at ?a d004__c_tree))
    :effect (d004__p_has ?a d004__c_eggs)
  )

  (:action d004__a_fetch_eggs
    :parameters (?t - d004__t_entity)
    :precondition (and (d004__p_is_thief ?t) (d004__p_entity_at ?t d004__c_tree) (d004__p_item_at d004__c_eggs d004__c_tree))
    :effect (and (d004__p_eggs_fetched ?t) (d004__p_has ?t d004__c_eggs) (not (d004__p_item_at d004__c_eggs d004__c_tree)))
  )

  (:action d004__a_learn_astronomer_trade
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (and (d004__p_is_astronomer ?b) (d004__p_has ?b d004__c_telescope))
  )

  (:action d004__a_learn_hunter_trade
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (and (d004__p_is_hunter ?b) (d004__p_has ?b d004__c_gun))
  )

  (:action d004__a_learn_tailor_trade
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (and (d004__p_is_tailor ?b) (d004__p_has ?b d004__c_needle))
  )

  (:action d004__a_learn_thief_trade
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (d004__p_is_thief ?b)
  )

  (:action d004__a_leave_home
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_house)
    :effect (and (d004__p_entity_at ?b d004__c_town_gate) (not (d004__p_entity_at ?b d004__c_house)))
  )

  (:action d004__a_locate_princess
    :parameters (?a - d004__t_entity)
    :precondition (and (d004__p_is_astronomer ?a) (d004__p_has ?a d004__c_telescope))
    :effect (d004__p_entity_at d004__c_princess d004__c_rock_sea)
  )

  (:action d004__a_obtain_ship
    :parameters (?a - d004__t_entity)
    :precondition (d004__p_is_astronomer ?a)
    :effect (d004__p_has ?a d004__c_ship)
  )

  (:action d004__a_receive_reward
    :parameters (?e - d004__t_entity)
    :precondition (d004__p_princess_rescued ?e)
    :effect (and (d004__p_reward_received ?e) (d004__p_half_kingdom ?e d004__c_kingdom))
  )

  (:action d004__a_repair_ship
    :parameters (?t - d004__t_entity)
    :precondition (and (d004__p_is_tailor ?t) (d004__p_has ?t d004__c_needle) (d004__p_ship_broken))
    :effect (and (d004__p_ship_repaired) (not (d004__p_ship_broken)))
  )

  (:action d004__a_return_eggs_to_nest
    :parameters (?t - d004__t_entity)
    :precondition (and (d004__p_is_thief ?t) (d004__p_eggs_sewn d004__c_brother_tailor) (d004__p_entity_at ?t d004__c_tree) (d004__p_has ?t d004__c_eggs))
    :effect (and (d004__p_item_at d004__c_eggs d004__c_tree) (not (d004__p_has ?t d004__c_eggs)))
  )

  (:action d004__a_return_home_with_princess
    :parameters (?a - d004__t_entity)
    :precondition (and (d004__p_ship_repaired) (d004__p_entity_at ?a d004__c_sea))
    :effect (and (d004__p_entity_at ?a d004__c_house) (d004__p_entity_at d004__c_princess d004__c_house) (not (d004__p_entity_at ?a d004__c_sea)))
  )

  (:action d004__a_reunite_at_crossroads
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (and (d004__p_entity_at ?b d004__c_house) (not (d004__p_entity_at ?b d004__c_cross_way)))
  )

  (:action d004__a_sail_to_rock
    :parameters (?a - d004__t_entity)
    :precondition (and (d004__p_has ?a d004__c_ship) (d004__p_entity_at ?a d004__c_house))
    :effect (and (d004__p_entity_at ?a d004__c_rock_sea) (not (d004__p_entity_at ?a d004__c_house)))
  )

  (:action d004__a_separate_at_crossroads
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_entity_at ?b d004__c_cross_way)
    :effect (d004__p_has ?b d004__c_sticks)
  )

  (:action d004__a_sew_eggs
    :parameters (?t - d004__t_entity)
    :precondition (and (d004__p_is_tailor ?t) (d004__p_has ?t d004__c_needle) (d004__p_eggs_shot d004__c_brother_hunter))
    :effect (d004__p_eggs_sewn ?t)
  )

  (:action d004__a_shoot_dragon
    :parameters (?h - d004__t_entity)
    :precondition (and (d004__p_is_hunter ?h) (d004__p_has ?h d004__c_gun) (d004__p_entity_at d004__c_dragon d004__c_rock_sea))
    :effect (and (d004__p_dragon_dead) (d004__p_ship_broken) (not (d004__p_entity_at d004__c_dragon d004__c_rock_sea)))
  )

  (:action d004__a_shoot_eggs
    :parameters (?h - d004__t_entity)
    :precondition (and (d004__p_is_hunter ?h) (d004__p_has ?h d004__c_gun) (d004__p_eggs_fetched d004__c_brother_thief))
    :effect (d004__p_eggs_shot ?h)
  )

  (:action d004__a_steal_princess
    :parameters (?t - d004__t_entity)
    :precondition (and (d004__p_is_thief ?t) (d004__p_entity_at ?t d004__c_rock_sea) (d004__p_entity_at d004__c_princess d004__c_rock_sea) (d004__p_entity_at d004__c_dragon d004__c_rock_sea))
    :effect (and (d004__p_princess_rescued ?t) (d004__p_entity_at d004__c_princess d004__c_sea) (not (d004__p_entity_at d004__c_princess d004__c_rock_sea)))
  )

  (:action d004__a_swim_after_ship_break
    :parameters (?b - d004__t_entity)
    :precondition (d004__p_ship_broken)
    :effect (d004__p_entity_at ?b d004__c_sea)
  )

  (:action d005__a_abandon_children_in_forest
    :parameters (?father - d005__t_entity ?g - d005__t_entity ?h - d005__t_entity ?mother - d005__t_entity ?forest - d005__t_location)
    :effect (and (d005__p_at ?h ?forest) (d005__p_at ?g ?forest) (d005__p_lost ?h) (d005__p_lost ?g) (d005__p_bread_given ?h) (d005__p_bread_given ?g) (d005__p_fire_lit ?forest))
  )

  (:action d005__a_call_duck_for_crossing
    :parameters (?duck - d005__t_entity ?g - d005__t_entity ?h - d005__t_entity ?lake - d005__t_location)
    :precondition (and (d005__p_at ?h ?lake) (d005__p_at ?g ?lake) (d005__p_at ?duck ?lake))
    :effect (and (d005__p_duck_helped ?h ?duck) (d005__p_duck_helped ?g ?duck) (d005__p_crossed_lake ?h) (d005__p_crossed_lake ?g))
  )

  (:action d005__a_collect_treasure
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?pearl - d005__t_item ?precious_stone - d005__t_item ?cottage - d005__t_location)
    :precondition (and (d005__p_at ?h ?cottage) (d005__p_at ?g ?cottage))
    :effect (and (d005__p_has ?h ?pearl) (d005__p_has ?g ?precious_stone) (d005__p_collected ?h ?pearl) (d005__p_collected ?g ?precious_stone))
  )

  (:action d005__a_drop_breadcrumb_on_path
    :parameters (?h - d005__t_entity ?crumb - d005__t_item ?path_loc - d005__t_location)
    :precondition (and (d005__p_at ?h ?path_loc) (d005__p_has ?h ?crumb))
    :effect (and (d005__p_crumb_on_path ?path_loc) (not (d005__p_has ?h ?crumb)))
  )

  (:action d005__a_drop_pebble_on_path
    :parameters (?h - d005__t_entity ?peb - d005__t_item ?path_loc - d005__t_location)
    :precondition (and (d005__p_at ?h ?path_loc) (d005__p_has ?h ?peb))
    :effect (and (d005__p_pebble_on_path ?path_loc) (not (d005__p_has ?h ?peb)))
  )

  (:action d005__a_enter_witch_house
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?cottage - d005__t_location)
    :precondition (and (d005__p_at ?h ?cottage) (d005__p_at ?g ?cottage))
    :effect (and (d005__p_has ?h d005__c_cake) (d005__p_has ?g d005__c_sugar_window))
  )

  (:action d005__a_escape_from_stable
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?cottage - d005__t_location ?stable - d005__t_location)
    :precondition (and (d005__p_captured ?h) (d005__p_locked ?stable) (d005__p_at ?g ?cottage) (d005__p_at ?h ?stable))
    :effect (and (d005__p_at ?h ?cottage) (not (d005__p_at ?h ?stable)) (not (d005__p_locked ?stable)) (not (d005__p_captured ?h)))
  )

  (:action d005__a_follow_breadcrumbs_home
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?home - d005__t_location ?path_loc - d005__t_location)
    :precondition (and (d005__p_at ?h ?path_loc) (d005__p_at ?g ?path_loc))
    :effect (when (d005__p_crumb_on_path ?path_loc) (and (d005__p_at ?h ?home) (d005__p_at ?g ?home) (not (d005__p_at ?h ?path_loc)) (not (d005__p_at ?g ?path_loc)) (not (d005__p_lost ?h)) (not (d005__p_lost ?g))))
  )

  (:action d005__a_follow_pebbles_home
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?home - d005__t_location ?path_loc - d005__t_location)
    :precondition (and (d005__p_pebble_on_path ?path_loc) (d005__p_at ?h ?path_loc) (d005__p_at ?g ?path_loc))
    :effect (and (d005__p_at ?h ?home) (d005__p_at ?g ?home) (not (d005__p_at ?h ?path_loc)) (not (d005__p_at ?g ?path_loc)) (not (d005__p_lost ?h)) (not (d005__p_lost ?g)))
  )

  (:action d005__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - d005__t_entity ?g - d005__t_entity ?h - d005__t_entity ?branch - d005__t_location ?cottage - d005__t_location)
    :precondition (and (d005__p_at ?h ?branch) (d005__p_at ?g ?branch) (d005__p_bird_heard ?h ?branch) (d005__p_bird_heard ?g ?branch))
    :effect (and (d005__p_at ?h ?cottage) (d005__p_at ?g ?cottage) (not (d005__p_at ?h ?branch)) (not (d005__p_at ?g ?branch)))
  )

  (:action d005__a_leave_children_at_fire
    :parameters (?father - d005__t_entity ?g - d005__t_entity ?h - d005__t_entity ?mother - d005__t_entity ?forest - d005__t_location)
    :precondition (and (d005__p_at ?h ?forest) (d005__p_at ?g ?forest) (d005__p_fire_lit ?forest) (d005__p_bread_given ?h) (d005__p_bread_given ?g))
    :effect (and (d005__p_lost ?h) (d005__p_lost ?g))
  )

  (:action d005__a_push_witch_into_oven
    :parameters (?g - d005__t_entity ?witch - d005__t_entity ?oven - d005__t_item ?room - d005__t_location)
    :precondition (and (d005__p_at ?g ?room) (d005__p_at ?witch ?room))
    :effect (and (d005__p_dead ?witch) (not (d005__p_at ?witch ?room)))
  )

  (:action d005__a_return_home_and_reunite_with_father
    :parameters (?father - d005__t_entity ?g - d005__t_entity ?h - d005__t_entity ?father_house - d005__t_location)
    :precondition (and (d005__p_crossed_lake ?h) (d005__p_crossed_lake ?g) (d005__p_at ?father ?father_house))
    :effect (and (d005__p_at ?h ?father_house) (d005__p_at ?g ?father_house) (d005__p_reunited_with_father ?h) (d005__p_reunited_with_father ?g) (not (d005__p_lost ?h)) (not (d005__p_lost ?g)))
  )

  (:action d005__a_wander_forest_seeking_way_out
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?forest - d005__t_location)
    :precondition (and (d005__p_at ?h ?forest) (d005__p_at ?g ?forest))
    :effect (and (d005__p_lost ?h) (d005__p_lost ?g))
  )

  (:action d005__a_witch_captures_children
    :parameters (?g - d005__t_entity ?h - d005__t_entity ?witch - d005__t_entity ?cottage - d005__t_location ?stable - d005__t_location)
    :precondition (and (d005__p_at ?h ?cottage) (d005__p_at ?g ?cottage) (not (d005__p_locked ?stable)))
    :effect (and (d005__p_captured ?h) (d005__p_locked ?stable) (d005__p_at ?h ?stable) (not (d005__p_at ?h ?cottage)))
  )

  (:action d006__a_ask_giant_wife_for_breakfast
    :parameters (?j - d006__t_entity ?wife - d006__t_entity)
    :precondition (and (d006__p_at ?j d006__c_giant_castle) (d006__p_at ?wife d006__c_giant_castle))
    :effect (d006__p_has_breakfast ?j)
  )

  (:action d006__a_climb_beanstalk
    :parameters (?j - d006__t_entity)
    :precondition (and (d006__p_beanstalk_grown) (d006__p_at ?j d006__c_beanstalk))
    :effect (and (d006__p_at ?j d006__c_giant_castle) (not (d006__p_at ?j d006__c_beanstalk)))
  )

  (:action d006__a_cut_beanstalk
    :parameters (?giant - d006__t_entity ?mother - d006__t_entity ?axe - d006__t_item)
    :precondition (and (d006__p_intact d006__c_beanstalk) (d006__p_climbing_down ?giant))
    :effect (and (d006__p_dead ?giant) (not (d006__p_intact d006__c_beanstalk)))
  )

  (:action d006__a_grow_beanstalk
    :parameters (?beans - d006__t_item)
    :precondition (d006__p_planted ?beans)
    :effect (and (d006__p_beanstalk_grown) (d006__p_intact d006__c_beanstalk))
  )

  (:action d006__a_hide_in_kettle
    :parameters (?j - d006__t_entity ?kettle - d006__t_item)
    :precondition (and (d006__p_at ?j d006__c_giant_castle) (d006__p_empty ?kettle))
    :effect (and (d006__p_inside ?j ?kettle) (not (d006__p_at ?j d006__c_giant_castle)))
  )

  (:action d006__a_hide_in_oven
    :parameters (?j - d006__t_entity ?oven - d006__t_item)
    :precondition (d006__p_at ?j d006__c_giant_castle)
    :effect (and (d006__p_inside ?j ?oven) (not (d006__p_at ?j d006__c_giant_castle)))
  )

  (:action d006__a_plant_beans
    :parameters (?beans - d006__t_item ?loc - d006__t_location)
    :precondition (d006__p_at_item ?beans ?loc)
    :effect (and (d006__p_planted ?beans) (not (d006__p_at_item ?beans ?loc)))
  )

  (:action d006__a_return_down_beanstalk
    :parameters (?j - d006__t_entity)
    :precondition (d006__p_at ?j d006__c_giant_castle)
    :effect (and (d006__p_at ?j d006__c_cottage) (not (d006__p_at ?j d006__c_giant_castle)))
  )

  (:action d006__a_sell_cow_for_beans
    :parameters (?b - d006__t_entity ?cow - d006__t_entity ?j - d006__t_entity ?beans - d006__t_item ?l - d006__t_location)
    :precondition (and (d006__p_at ?j ?l) (d006__p_at ?cow ?l) (d006__p_offers ?b ?beans) (d006__p_at ?b ?l))
    :effect (and (d006__p_has ?j ?beans) (not (d006__p_offers ?b ?beans)) (not (d006__p_at_item ?beans ?l)))
  )

  (:action d006__a_steal_gold_bags
    :parameters (?j - d006__t_entity ?bag1 - d006__t_item ?bag2 - d006__t_item)
    :precondition (and (d006__p_asleep d006__c_giant) (d006__p_at_item ?bag1 d006__c_giant_castle) (d006__p_at_item ?bag2 d006__c_giant_castle))
    :effect (and (d006__p_has ?j ?bag1) (d006__p_has ?j ?bag2) (not (d006__p_at_item ?bag1 d006__c_giant_castle)) (not (d006__p_at_item ?bag2 d006__c_giant_castle)))
  )

  (:action d006__a_steal_harp
    :parameters (?giant - d006__t_entity ?j - d006__t_entity ?harp - d006__t_item)
    :precondition (and (d006__p_on ?harp d006__c_giant_castle) (d006__p_asleep ?giant))
    :effect (and (d006__p_has ?j ?harp) (not (d006__p_on ?harp d006__c_giant_castle)))
  )

  (:action d006__a_steal_hen
    :parameters (?giant - d006__t_entity ?j - d006__t_entity ?hen - d006__t_item)
    :precondition (and (d006__p_on ?hen d006__c_giant_castle) (d006__p_distracted ?giant))
    :effect (and (d006__p_has ?j ?hen) (not (d006__p_on ?hen d006__c_giant_castle)))
  )

  (:action d007__a_approach_cottage
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity ?cottage - d007__t_location ?forest - d007__t_location)
    :precondition (and (d007__p_sees_light ?cock) (d007__p_at ?donkey ?forest) (d007__p_at ?hound ?forest) (d007__p_at ?cat ?forest) (d007__p_at ?cock ?forest))
    :effect (and (d007__p_at ?donkey ?cottage) (d007__p_at ?hound ?cottage) (d007__p_at ?cat ?cottage) (d007__p_at ?cock ?cottage) (d007__p_moving_towards ?donkey ?cottage) (d007__p_moving_towards ?hound ?cottage) (d007__p_moving_towards ?cat ?cottage) (d007__p_moving_towards ?cock ?cottage) (not (d007__p_at ?donkey ?forest)) (not (d007__p_at ?hound ?forest)) (not (d007__p_at ?cat ?forest)) (not (d007__p_at ?cock ?forest)))
  )

  (:action d007__a_cat_agrees
    :parameters (?cat - d007__t_entity ?donkey - d007__t_entity)
    :precondition (d007__p_invited ?donkey ?cat)
    :effect (d007__p_agreed ?cat ?donkey)
  )

  (:action d007__a_cat_attack_messenger
    :parameters (?cat - d007__t_entity ?messenger - d007__t_entity)
    :precondition (and (d007__p_attempt_light ?messenger) (d007__p_at ?cat d007__c_hearth))
    :effect (d007__p_attacked ?cat ?messenger)
  )

  (:action d007__a_choose_sleep_spot
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?beam - d007__t_location ?hearth - d007__t_location)
    :precondition (and (d007__p_at ?cat ?hearth) (d007__p_at ?cock ?beam))
    :effect (and (d007__p_sleeping_at ?cat ?hearth) (d007__p_sleeping_at ?cock ?beam))
  )

  (:action d007__a_cock_agrees
    :parameters (?cock - d007__t_entity ?donkey - d007__t_entity)
    :precondition (d007__p_invited ?donkey ?cock)
    :effect (d007__p_agreed ?cock ?donkey)
  )

  (:action d007__a_cock_crow_alert
    :parameters (?cock - d007__t_entity)
    :precondition (d007__p_at ?cock d007__c_beam)
    :effect (d007__p_crowed ?cock)
  )

  (:action d007__a_dog_bite_messenger
    :parameters (?hound - d007__t_entity ?messenger - d007__t_entity ?cottage - d007__t_location)
    :precondition (and (d007__p_attempt_light ?messenger) (d007__p_at ?hound ?cottage))
    :effect (d007__p_bite ?hound ?messenger)
  )

  (:action d007__a_donkey_kick_messenger
    :parameters (?donkey - d007__t_entity ?messenger - d007__t_entity)
    :precondition (d007__p_attempt_light ?messenger)
    :effect (d007__p_kick ?donkey ?messenger)
  )

  (:action d007__a_eat_feast
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity ?cottage - d007__t_location)
    :precondition (and (d007__p_at ?donkey ?cottage) (d007__p_at ?hound ?cottage) (d007__p_at ?cat ?cottage) (d007__p_at ?cock ?cottage) (d007__p_window_shattered))
    :effect (and (d007__p_ate_all ?donkey) (d007__p_ate_all ?hound) (d007__p_ate_all ?cat) (d007__p_ate_all ?cock))
  )

  (:action d007__a_extinguish_light
    :parameters (?cottage - d007__t_location)
    :precondition (d007__p_light_on ?cottage)
    :effect (and (d007__p_light_off ?cottage) (not (d007__p_light_on ?cottage)))
  )

  (:action d007__a_hound_agrees
    :parameters (?donkey - d007__t_entity ?hound - d007__t_entity)
    :precondition (d007__p_invited ?donkey ?hound)
    :effect (d007__p_agreed ?hound ?donkey)
  )

  (:action d007__a_invite_cat
    :parameters (?cat - d007__t_entity ?donkey - d007__t_entity)
    :effect (d007__p_invited ?donkey ?cat)
  )

  (:action d007__a_invite_cock
    :parameters (?cock - d007__t_entity ?donkey - d007__t_entity ?loc - d007__t_location)
    :precondition (and (d007__p_at ?donkey ?loc) (d007__p_at ?cock ?loc))
    :effect (d007__p_invited ?donkey ?cock)
  )

  (:action d007__a_invite_hound
    :parameters (?donkey - d007__t_entity ?hound - d007__t_entity)
    :effect (d007__p_invited ?donkey ?hound)
  )

  (:action d007__a_messenger_attempt_light
    :parameters (?messenger - d007__t_entity ?cottage - d007__t_location)
    :precondition (d007__p_light_off ?cottage)
    :effect (d007__p_attempt_light ?messenger)
  )

  (:action d007__a_plan_scaring_robbers
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity ?cottage - d007__t_location)
    :precondition (and (d007__p_at ?donkey ?cottage) (d007__p_at ?hound ?cottage) (d007__p_at ?cat ?cottage) (d007__p_at ?cock ?cottage))
    :effect (and (d007__p_making_noise ?donkey) (d007__p_making_noise ?hound) (d007__p_making_noise ?cat) (d007__p_making_noise ?cock))
  )

  (:action d007__a_rest_in_forest
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity ?forest - d007__t_location)
    :precondition (and (d007__p_at ?donkey ?forest) (d007__p_at ?hound ?forest) (d007__p_at ?cat ?forest) (d007__p_at ?cock ?forest))
    :effect (and (d007__p_resting ?donkey) (d007__p_resting ?hound) (d007__p_resting ?cat) (d007__p_resting ?cock))
  )

  (:action d007__a_robbers_flee
    :parameters (?robber - d007__t_entity ?cottage - d007__t_location ?forest - d007__t_location)
    :precondition (and (d007__p_window_shattered) (d007__p_at ?robber ?cottage))
    :effect (and (d007__p_fled ?robber ?forest) (not (d007__p_at ?robber ?cottage)))
  )

  (:action d007__a_robbers_retreat
    :parameters (?robber - d007__t_entity ?cottage - d007__t_location)
    :precondition (d007__p_at ?robber ?cottage)
    :effect (and (d007__p_retreated ?robber) (not (d007__p_at ?robber ?cottage)))
  )

  (:action d007__a_run_away
    :parameters (?donkey - d007__t_entity ?from - d007__t_location ?to - d007__t_location)
    :precondition (d007__p_at ?donkey ?from)
    :effect (and (d007__p_at ?donkey ?to) (d007__p_moving_towards ?donkey ?to) (not (d007__p_at ?donkey ?from)))
  )

  (:action d007__a_signal_and_make_noise
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity)
    :precondition (and (d007__p_stacked_on ?hound ?donkey) (d007__p_stacked_on ?cat ?hound) (d007__p_stacked_on ?cock ?cat))
    :effect (and (d007__p_making_noise ?donkey) (d007__p_making_noise ?hound) (d007__p_making_noise ?cat) (d007__p_making_noise ?cock) (d007__p_window_shattered))
  )

  (:action d007__a_spot_light
    :parameters (?cock - d007__t_entity ?cottage - d007__t_location ?forest - d007__t_location)
    :precondition (and (d007__p_at ?cock ?forest) (d007__p_resting ?cock))
    :effect (and (d007__p_sees_light ?cock) (d007__p_moving_towards ?cock ?cottage))
  )

  (:action d007__a_stack_animals
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity)
    :precondition (and (d007__p_making_noise ?donkey) (d007__p_making_noise ?hound) (d007__p_making_noise ?cat) (d007__p_making_noise ?cock))
    :effect (and (d007__p_stacked_on ?hound ?donkey) (d007__p_stacked_on ?cat ?hound) (d007__p_stacked_on ?cock ?cat))
  )

  (:action d007__a_travel_together
    :parameters (?cat - d007__t_entity ?cock - d007__t_entity ?donkey - d007__t_entity ?hound - d007__t_entity ?from - d007__t_location ?to - d007__t_location)
    :precondition (and (d007__p_at ?donkey ?from) (d007__p_at ?hound ?from) (d007__p_at ?cat ?from) (d007__p_at ?cock ?from) (d007__p_agreed ?hound ?donkey) (d007__p_agreed ?cat ?donkey) (d007__p_agreed ?cock ?donkey))
    :effect (and (d007__p_at ?donkey ?to) (d007__p_at ?hound ?to) (d007__p_at ?cat ?to) (d007__p_at ?cock ?to) (d007__p_moving_towards ?donkey ?to) (d007__p_moving_towards ?hound ?to) (d007__p_moving_towards ?cat ?to) (d007__p_moving_towards ?cock ?to) (not (d007__p_at ?donkey ?from)) (not (d007__p_at ?hound ?from)) (not (d007__p_at ?cat ?from)) (not (d007__p_at ?cock ?from)))
  )

  (:action d008__a_approach_sun
    :parameters (?c - d008__t_entity)
    :precondition (and (d008__p_traveling ?c) (d008__p_avoid ?c d008__c_sun))
    :effect (d008__p_near ?c d008__c_sun)
  )

  (:action d008__a_arrest_meteor
    :parameters (?c - d008__t_entity ?m - d008__t_entity)
    :precondition (and (d008__p_traveling ?c) (d008__p_near ?c ?m))
    :effect (and (d008__p_arrested ?c ?m) (d008__p_detained ?m))
  )

  (:action d008__a_avoid_body
    :parameters (?b - d008__t_entity ?c - d008__t_entity)
    :precondition (and (d008__p_traveling ?c) (d008__p_avoid ?c ?b) (d008__p_near ?c ?b))
    :effect (not (d008__p_near ?c ?b))
  )

  (:action d008__a_burn_up
    :parameters (?c - d008__t_entity)
    :precondition (d008__p_near ?c d008__c_sun)
    :effect (and (d008__p_burned ?c) (not (d008__p_traveling ?c)) (not (d008__p_has_mission ?c)))
  )

  (:action d008__a_call_comet_forward
    :parameters (?c - d008__t_entity ?master - d008__t_entity)
    :precondition (and (d008__p_at ?c d008__c_courtyard) (d008__p_at ?master d008__c_courtyard))
    :effect (d008__p_summoned ?c)
  )

  (:action d008__a_cross_out_comet
    :parameters (?c - d008__t_entity)
    :precondition (d008__p_burned ?c)
    :effect (and (d008__p_crossed_out ?c) (not (d008__p_on_list ?c)))
  )

  (:action d008__a_deliver_meteor_to_bungo
    :parameters (?m - d008__t_entity)
    :precondition (d008__p_detained ?m)
    :effect (d008__p_delivered ?m d008__c_bungo)
  )

  (:action d008__a_give_order
    :parameters (?c - d008__t_entity ?master - d008__t_entity)
    :precondition (and (d008__p_at ?c d008__c_courtyard) (d008__p_at ?master d008__c_courtyard) (not (d008__p_has_mission ?c)))
    :effect (and (d008__p_has_mission ?c) (d008__p_left_turn_rule ?c) (d008__p_prohibit_speak ?c) (d008__p_avoid ?c d008__c_sun) (d008__p_avoid ?c d008__c_earth) (d008__p_avoid ?c d008__c_bungo))
  )

  (:action d008__a_prohibit_speaking_to_meteor
    :parameters (?c - d008__t_entity)
    :precondition (d008__p_has_mission ?c)
    :effect (d008__p_prohibit_speak ?c)
  )

  (:action d008__a_punish_meteor
    :parameters (?m - d008__t_entity)
    :precondition (d008__p_delivered ?m d008__c_bungo)
    :effect (d008__p_punished ?m)
  )

  (:action d008__a_speak_to_meteor
    :parameters (?c - d008__t_entity ?m - d008__t_entity)
    :precondition (and (d008__p_traveling ?c) (d008__p_prohibit_speak ?c) (d008__p_near ?c ?m))
    :effect (and (d008__p_speaks_to ?c ?m) (d008__p_rule_violation ?c))
  )

  (:action d008__a_start_travel
    :parameters (?c - d008__t_entity)
    :precondition (and (d008__p_has_mission ?c) (d008__p_gate_open))
    :effect (and (d008__p_traveling ?c) (not (d008__p_at ?c d008__c_courtyard)))
  )

  (:action d008__a_turn_left_on_meeting
    :parameters (?c - d008__t_entity ?other - d008__t_entity)
    :precondition (and (d008__p_traveling ?c) (d008__p_traveling ?other) (d008__p_left_turn_rule ?c) (d008__p_near ?c ?other))
    :effect (d008__p_left_turn_rule ?c)
  )

  (:action d009__a_ask_for_material
    :parameters (?m - d009__t_entity ?p - d009__t_entity ?i - d009__t_item)
    :precondition (and (d009__p_has_bundle ?m ?i) (d009__p_alive ?p) (d009__p_alive ?m))
    :effect (d009__p_material_requested ?p ?i)
  )

  (:action d009__a_build_house
    :parameters (?p - d009__t_entity ?i - d009__t_item ?h - d009__t_location)
    :precondition (and (d009__p_has ?p ?i) (d009__p_alive ?p) (d009__p_at ?p ?h))
    :effect (and (d009__p_house ?h ?i) (d009__p_house_intact ?h) (d009__p_door_closed ?h) (not (d009__p_has ?p ?i)))
  )

  (:action d009__a_pig_buys_butter_churn_and_hides
    :parameters (?p - d009__t_entity ?c - d009__t_item)
    :precondition (and (d009__p_at ?p d009__c_town_fair) (d009__p_alive ?p))
    :effect (and (d009__p_has ?p ?c) (d009__p_inside ?p ?c))
  )

  (:action d009__a_pig_collects_apples_and_escapes
    :parameters (?p - d009__t_entity ?a - d009__t_item ?l - d009__t_location)
    :precondition (and (d009__p_plan ?p ?l) (d009__p_alive ?p))
    :effect (and (d009__p_has ?p ?a) (d009__p_escaped ?p) (not (d009__p_plan ?p ?l)))
  )

  (:action d009__a_pig_collects_turnips
    :parameters (?p - d009__t_entity ?i - d009__t_item ?l - d009__t_location)
    :precondition (and (d009__p_plan ?p ?l) (d009__p_alive ?p))
    :effect (and (d009__p_has ?p ?i) (not (d009__p_plan ?p ?l)))
  )

  (:action d009__a_pig_prepares_boiling_pot_and_fire
    :parameters (?p - d009__t_entity ?fire - d009__t_item ?pot - d009__t_item ?h - d009__t_location)
    :precondition (and (d009__p_at ?p ?h) (d009__p_has ?p ?pot) (d009__p_has ?p ?fire) (d009__p_alive ?p))
    :effect (and (d009__p_over ?pot ?fire) (d009__p_under ?pot d009__c_chimney) (d009__p_boiling ?pot))
  )

  (:action d009__a_pig_refuses_entry
    :parameters (?w - d009__t_entity ?h - d009__t_location)
    :precondition (and (d009__p_entry_requested ?w ?h) (d009__p_alive ?w))
    :effect (and (d009__p_entry_denied ?w ?h) (not (d009__p_entry_requested ?w ?h)))
  )

  (:action d009__a_pig_rolls_churn_down_hill
    :parameters (?p - d009__t_entity ?c - d009__t_item)
    :precondition (and (d009__p_inside ?p ?c) (d009__p_alive ?p))
    :effect (and (d009__p_rolling ?c) (not (d009__p_inside ?p ?c)))
  )

  (:action d009__a_receive_material
    :parameters (?m - d009__t_entity ?p - d009__t_entity ?i - d009__t_item)
    :precondition (and (d009__p_material_requested ?p ?i) (d009__p_has_bundle ?m ?i) (d009__p_alive ?p) (d009__p_alive ?m))
    :effect (and (d009__p_has ?p ?i) (not (d009__p_material_requested ?p ?i)) (not (d009__p_has_bundle ?m ?i)))
  )

  (:action d009__a_send_sons_on_journey
    :parameters (?m - d009__t_entity ?p - d009__t_entity ?d - d009__t_location)
    :precondition (and (d009__p_at ?m d009__c_pig_home) (d009__p_at ?p d009__c_pig_home) (d009__p_alive ?m) (d009__p_alive ?p))
    :effect (and (d009__p_plan ?p ?d) (not (d009__p_at ?p d009__c_pig_home)))
  )

  (:action d009__a_wolf_attempts_chimney_entry
    :parameters (?w - d009__t_entity ?h - d009__t_location)
    :precondition (and (d009__p_house_intact ?h) (d009__p_alive ?w))
    :effect (d009__p_entry_requested ?w ?h)
  )

  (:action d009__a_wolf_blows_house_down
    :parameters (?w - d009__t_entity ?i - d009__t_item ?h - d009__t_location)
    :precondition (and (d009__p_huffed ?w) (d009__p_puffed ?w) (d009__p_house ?h ?i) (d009__p_door_closed ?h) (d009__p_alive ?w))
    :effect (and (d009__p_house_destroyed ?h) (not (d009__p_house_intact ?h)) (not (d009__p_door_closed ?h)))
  )

  (:action d009__a_wolf_eats_pig
    :parameters (?p - d009__t_entity ?w - d009__t_entity ?h - d009__t_location)
    :precondition (and (d009__p_house_destroyed ?h) (d009__p_at ?p ?h) (d009__p_alive ?p) (d009__p_alive ?w))
    :effect (and (d009__p_dead ?p) (not (d009__p_alive ?p)) (not (d009__p_at ?p ?h)))
  )

  (:action d009__a_wolf_fails_to_blow_house
    :parameters (?w - d009__t_entity ?i - d009__t_item ?h - d009__t_location)
    :precondition (and (d009__p_huffed ?w) (d009__p_puffed ?w) (d009__p_house ?h ?i) (d009__p_alive ?w))
    :effect (d009__p_house_intact ?h)
  )

  (:action d009__a_wolf_falls_into_pot_and_is_boiled
    :parameters (?w - d009__t_entity ?pot - d009__t_item)
    :precondition (and (d009__p_boiling ?pot) (d009__p_alive ?w))
    :effect (and (d009__p_dead ?w) (not (d009__p_alive ?w)))
  )

  (:action d009__a_wolf_flees_from_rolling_object
    :parameters (?w - d009__t_entity ?c - d009__t_item)
    :precondition (and (d009__p_rolling ?c) (d009__p_alive ?w))
    :effect (d009__p_escaped ?w)
  )

  (:action d009__a_wolf_huff_and_puff
    :parameters (?w - d009__t_entity ?h - d009__t_location)
    :precondition (and (d009__p_entry_denied ?w ?h) (d009__p_alive ?w))
    :effect (and (d009__p_huffed ?w) (d009__p_puffed ?w))
  )

  (:action d009__a_wolf_knocks_and_requests_entry
    :parameters (?w - d009__t_entity ?h - d009__t_location)
    :precondition (and (d009__p_at ?w ?h) (d009__p_door_closed ?h) (d009__p_alive ?w))
    :effect (d009__p_entry_requested ?w ?h)
  )

  (:action d009__a_wolf_promises_apple_orchard
    :parameters (?p - d009__t_entity ?w - d009__t_entity ?l - d009__t_location)
    :precondition (and (d009__p_alive ?w) (d009__p_alive ?p))
    :effect (d009__p_plan ?p ?l)
  )

  (:action d009__a_wolf_promises_fair_trip
    :parameters (?p - d009__t_entity ?w - d009__t_entity ?l - d009__t_location)
    :precondition (and (d009__p_alive ?w) (d009__p_alive ?p))
    :effect (d009__p_plan ?p ?l)
  )

  (:action d009__a_wolf_promises_turnip_field
    :parameters (?p - d009__t_entity ?w - d009__t_entity ?l - d009__t_location)
    :precondition (and (d009__p_alive ?w) (d009__p_alive ?p))
    :effect (d009__p_plan ?p ?l)
  )

  (:action d010__a_buy_boots
    :parameters (?jack - d010__t_entity ?puss - d010__t_entity ?boots - d010__t_item)
    :precondition (not (d010__p_has ?puss ?boots))
    :effect (d010__p_has ?puss ?boots)
  )

  (:action d010__a_cat_call_for_help
    :parameters (?jack - d010__t_entity ?king - d010__t_entity ?puss - d010__t_entity)
    :precondition (d010__p_drowning ?jack)
    :effect (and (d010__p_rescued_by ?jack ?king) (not (d010__p_drowning ?jack)))
  )

  (:action d010__a_cat_catch_rabbits
    :parameters (?puss - d010__t_entity ?bag - d010__t_item ?rabbit - d010__t_item ?warren - d010__t_location)
    :precondition (and (d010__p_has ?puss ?bag) (d010__p_at_item ?rabbit ?warren) (not (d010__p_contains ?bag ?rabbit)))
    :effect (and (d010__p_contains ?bag ?rabbit) (not (d010__p_at_item ?rabbit ?warren)))
  )

  (:action d010__a_cat_deliver_gifts_to_king
    :parameters (?king - d010__t_entity ?puss - d010__t_entity ?bag - d010__t_item ?rabbit - d010__t_item ?palace - d010__t_location)
    :precondition (and (d010__p_contains ?bag ?rabbit) (d010__p_at ?puss ?palace))
    :effect (and (d010__p_gift_delivered ?puss ?king ?rabbit) (not (d010__p_contains ?bag ?rabbit)))
  )

  (:action d010__a_cat_disentchant_prisoners
    :parameters (?person - d010__t_entity ?puss - d010__t_entity)
    :precondition (d010__p_alive ?puss)
    :effect (d010__p_promised_to_serve ?person d010__c_jack)
  )

  (:action d010__a_cat_eat_mouse
    :parameters (?mouse - d010__t_entity ?ogre - d010__t_entity ?puss - d010__t_entity)
    :precondition (d010__p_transformed_into ?ogre ?mouse)
    :effect (not (d010__p_transformed_into ?ogre ?mouse))
  )

  (:action d010__a_cat_ogre_transform_lion
    :parameters (?lion - d010__t_entity ?ogre - d010__t_entity ?puss - d010__t_entity)
    :precondition (and (d010__p_at ?puss d010__c_ogre_castle) (d010__p_alive ?ogre))
    :effect (d010__p_transformed_into ?ogre ?lion)
  )

  (:action d010__a_cat_ogre_transform_mouse
    :parameters (?mouse - d010__t_entity ?ogre - d010__t_entity ?puss - d010__t_entity)
    :precondition (d010__p_alive ?ogre)
    :effect (d010__p_transformed_into ?ogre ?mouse)
  )

  (:action d010__a_cat_open_castle_gates
    :parameters (?king - d010__t_entity ?puss - d010__t_entity ?castle - d010__t_location)
    :precondition (d010__p_at ?king ?castle)
    :effect (d010__p_gate_open ?castle)
  )

  (:action d010__a_cat_persuade_master_to_bathe
    :parameters (?jack - d010__t_entity ?puss - d010__t_entity ?river - d010__t_location)
    :precondition (and (d010__p_at ?jack ?river) (d010__p_at ?puss ?river))
    :effect (d010__p_drowning ?jack)
  )

  (:action d010__a_give_bag_to_cat
    :parameters (?jack - d010__t_entity ?puss - d010__t_entity ?bag - d010__t_item)
    :precondition (and (d010__p_has ?jack ?bag) (not (d010__p_has ?puss ?bag)))
    :effect (and (d010__p_has ?puss ?bag) (not (d010__p_has ?jack ?bag)))
  )

  (:action d010__a_king_send_groom_fetch_suit
    :parameters (?groom - d010__t_entity ?king - d010__t_entity ?suit - d010__t_item ?wardrobe - d010__t_location)
    :precondition (d010__p_at_item ?suit ?wardrobe)
    :effect (and (d010__p_has ?groom ?suit) (not (d010__p_at_item ?suit ?wardrobe)))
  )

  (:action d010__a_master_marry_princess
    :parameters (?jack - d010__t_entity ?princess - d010__t_entity)
    :precondition (and (not (d010__p_married ?jack ?princess)) (d010__p_at ?jack d010__c_palace))
    :effect (d010__p_married ?jack ?princess)
  )

  (:action d010__a_master_wear_suit
    :parameters (?jack - d010__t_entity ?suit - d010__t_item)
    :precondition (d010__p_has ?jack ?suit)
    :effect (and (d010__p_wearing ?jack ?suit) (not (d010__p_has ?jack ?suit)))
  )

  (:action d011__a_arrive_at_marble_palace
    :parameters (?p - d011__t_entity)
    :precondition (d011__p_at ?p d011__c_oak_tree)
    :effect (and (d011__p_at ?p d011__c_palace) (not (d011__p_at ?p d011__c_oak_tree)))
  )

  (:action d011__a_encounter_impostor_king
    :parameters (?i - d011__t_entity ?p - d011__t_entity)
    :precondition (and (d011__p_at ?p d011__c_city) (d011__p_at ?i d011__c_market_place))
    :effect (and (d011__p_at ?p d011__c_market_place) (not (d011__p_at ?p d011__c_city)))
  )

  (:action d011__a_encounter_robbers_in_forest
    :parameters (?p - d011__t_entity)
    :precondition (d011__p_at ?p d011__c_forest)
    :effect (and (d011__p_at ?p d011__c_oak_tree) (not (d011__p_at ?p d011__c_forest)))
  )

  (:action d011__a_king_proposes_marriage
    :parameters (?k - d011__t_entity ?p - d011__t_entity)
    :precondition (and (d011__p_at ?p d011__c_palace) (d011__p_at ?k d011__c_palace))
    :effect (d011__p_married ?p ?k)
  )

  (:action d011__a_king_requests_information_and_gifts
    :parameters (?k - d011__t_entity ?p - d011__t_entity ?r - d011__t_item ?s - d011__t_item)
    :precondition (and (d011__p_at ?p d011__c_palace) (d011__p_has ?p ?r) (d011__p_has ?p ?s) (d011__p_at ?k d011__c_palace))
    :effect (and (d011__p_has ?k ?r) (d011__p_has ?k ?s) (not (d011__p_has ?p ?r)) (not (d011__p_has ?p ?s)))
  )

  (:action d011__a_princess_accepts_with_heart
    :parameters (?k - d011__t_entity ?p - d011__t_entity)
    :precondition (and (d011__p_married ?p ?k) (not (d011__p_with_all_my_heart_spoken)))
    :effect (d011__p_with_all_my_heart_spoken)
  )

  (:action d011__a_receive_rubies_from_impostor
    :parameters (?i - d011__t_entity ?p - d011__t_entity ?r - d011__t_item)
    :precondition (and (d011__p_price_of_butter_spoken) (d011__p_at ?p d011__c_market_place) (d011__p_has ?i ?r))
    :effect (and (d011__p_has ?p ?r) (not (d011__p_has ?i ?r)))
  )

  (:action d011__a_receive_sapphires_from_robber_chief
    :parameters (?c - d011__t_entity ?p - d011__t_entity ?s - d011__t_item)
    :precondition (and (d011__p_grandmother_mangle_spoken) (d011__p_at ?p d011__c_oak_tree) (d011__p_has ?c ?s))
    :effect (and (d011__p_has ?p ?s) (not (d011__p_has ?c ?s)))
  )

  (:action d011__a_run_away_from_palace
    :parameters (?p - d011__t_entity)
    :precondition (d011__p_at ?p d011__c_back_stairs)
    :effect (and (d011__p_at ?p d011__c_city) (not (d011__p_at ?p d011__c_back_stairs)))
  )

  (:action d011__a_suitors_retire_due_to_phrase
    :parameters (?s - d011__t_entity)
    :precondition (and (d011__p_grandmother_mangle_spoken) (d011__p_at ?s d011__c_palace))
    :effect (not (d011__p_married ?s d011__c_princess))
  )

  (:action d011__a_utter_phrase_grandmother_mangle
    :parameters (?p - d011__t_entity)
    :precondition (and (d011__p_at ?p d011__c_oak_tree) (not (d011__p_grandmother_mangle_spoken)))
    :effect (d011__p_grandmother_mangle_spoken)
  )

  (:action d011__a_utter_phrase_price_of_butter
    :parameters (?p - d011__t_entity)
    :precondition (and (d011__p_at ?p d011__c_market_place) (not (d011__p_price_of_butter_spoken)))
    :effect (d011__p_price_of_butter_spoken)
  )

  (:action d012__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - d012__t_entity ?apple - d012__t_item)
    :precondition (and (d012__p_dead ?c) (d012__p_poisoned ?apple))
    :effect (and (d012__p_alive ?c) (not (d012__p_dead ?c)) (not (d012__p_poisoned ?apple)))
  )

  (:action d012__a_child_is_born_and_queen_dies
    :parameters (?c - d012__t_entity ?q - d012__t_entity)
    :precondition (and (not (d012__p_alive ?c)) (d012__p_alive ?q))
    :effect (and (d012__p_alive ?c) (d012__p_dead ?q) (not (d012__p_alive ?q)))
  )

  (:action d012__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - d012__t_entity ?d - d012__t_entity ?lace - d012__t_item)
    :precondition (and (d012__p_laced ?c ?lace) (d012__p_dead ?c))
    :effect (and (d012__p_alive ?c) (d012__p_awake ?c) (not (d012__p_laced ?c ?lace)) (not (d012__p_dead ?c)))
  )

  (:action d012__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - d012__t_entity ?d - d012__t_entity)
    :precondition (and (d012__p_alive ?d) (d012__p_alive ?c) (d012__p_sleeping ?c))
    :effect (and (d012__p_awake ?c) (not (d012__p_sleeping ?c)))
  )

  (:action d012__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - d012__t_entity ?d - d012__t_entity ?coffin - d012__t_item)
    :precondition (d012__p_dead ?c)
    :effect (and (d012__p_in_coffin ?c) (d012__p_has ?d ?coffin))
  )

  (:action d012__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - d012__t_entity ?d - d012__t_entity ?comb - d012__t_item)
    :precondition (and (d012__p_dead ?c) (d012__p_poisoned ?comb) (d012__p_has ?d ?comb))
    :effect (and (d012__p_alive ?c) (not (d012__p_dead ?c)) (not (d012__p_poisoned ?comb)))
  )

  (:action d012__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - d012__t_entity ?d - d012__t_entity)
    :precondition (and (d012__p_alive ?d) (d012__p_sleeping ?c))
    :effect (d012__p_awake ?d)
  )

  (:action d012__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - d012__t_entity ?c - d012__t_entity ?h - d012__t_entity ?heart - d012__t_item)
    :precondition (and (d012__p_alive ?h) (d012__p_alive ?c) (d012__p_alive ?b))
    :effect (and (d012__p_has ?h ?heart) (d012__p_dead ?b))
  )

  (:action d012__a_king_marries_stepmother
    :parameters (?k - d012__t_entity ?s - d012__t_entity)
    :precondition (and (d012__p_alive ?k) (d012__p_alive ?s))
    :effect (d012__p_fair ?s)
  )

  (:action d012__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - d012__t_entity ?p - d012__t_entity ?coffin - d012__t_item ?mountain - d012__t_location)
    :precondition (and (d012__p_in_coffin ?c) (d012__p_alive ?p))
    :effect (d012__p_at_item ?coffin ?mountain)
  )

  (:action d012__a_prince_marries_snow_white
    :parameters (?c - d012__t_entity ?p - d012__t_entity)
    :precondition (and (d012__p_alive ?p) (d012__p_alive ?c))
    :effect (d012__p_fair ?p)
  )

  (:action d012__a_queen_pricks_finger
    :parameters (?q - d012__t_entity ?blood - d012__t_item ?needle - d012__t_item)
    :precondition (and (d012__p_alive ?q) (d012__p_has ?q ?needle))
    :effect (d012__p_has ?q ?blood)
  )

  (:action d012__a_queen_sews_at_window
    :parameters (?q - d012__t_entity ?l - d012__t_location)
    :precondition (and (d012__p_alive ?q) (d012__p_at ?q ?l))
    :effect (d012__p_has ?q d012__c_needle)
  )

  (:action d012__a_queen_wishes_child_white_red_black
    :parameters (?c - d012__t_entity ?q - d012__t_entity)
    :precondition (d012__p_alive ?q)
    :effect (d012__p_fair ?c)
  )

  (:action d012__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - d012__t_entity ?apple - d012__t_item)
    :precondition (and (d012__p_poisoned ?apple) (d012__p_alive ?c))
    :effect (and (d012__p_dead ?c) (not (d012__p_alive ?c)))
  )

  (:action d012__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - d012__t_entity ?mug - d012__t_item ?plate - d012__t_item)
    :precondition (d012__p_alive ?c)
    :effect (and (d012__p_has ?c ?plate) (d012__p_has ?c ?mug))
  )

  (:action d012__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - d012__t_entity ?cottage - d012__t_location)
    :precondition (d012__p_alive ?c)
    :effect (d012__p_at ?c ?cottage)
  )

  (:action d012__a_snow_white_flees_into_forest
    :parameters (?c - d012__t_entity ?f - d012__t_location)
    :precondition (d012__p_alive ?c)
    :effect (d012__p_at ?c ?f)
  )

  (:action d012__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - d012__t_entity ?bed - d012__t_item)
    :precondition (d012__p_alive ?c)
    :effect (d012__p_sleeping ?c)
  )

  (:action d012__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - d012__t_entity ?g - d012__t_item)
    :precondition (and (d012__p_alive ?s) (d012__p_has ?s ?g))
    :effect (d012__p_fairest ?s)
  )

  (:action d012__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - d012__t_entity ?slippers - d012__t_item)
    :precondition (d012__p_alive ?s)
    :effect (and (d012__p_wearing ?s ?slippers) (d012__p_dead ?s) (not (d012__p_alive ?s)))
  )

  (:action d012__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - d012__t_entity ?s - d012__t_entity)
    :precondition (and (d012__p_fairest ?c) (d012__p_fair ?c) (d012__p_alive ?s))
    :effect (d012__p_envious ?s)
  )

  (:action d012__a_stepmother_comb_poison_snow_white
    :parameters (?c - d012__t_entity ?s - d012__t_entity ?comb - d012__t_item)
    :precondition (and (d012__p_has ?s ?comb) (d012__p_poisoned ?comb) (d012__p_alive ?c))
    :effect (and (d012__p_dead ?c) (not (d012__p_alive ?c)))
  )

  (:action d012__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - d012__t_entity ?s - d012__t_entity ?cottage - d012__t_location)
    :precondition (d012__p_alive ?s)
    :effect (and (d012__p_disguised_as ?s ?old_woman) (d012__p_visited ?s ?cottage))
  )

  (:action d012__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - d012__t_entity ?heart - d012__t_item)
    :precondition (d012__p_has ?s ?heart)
    :effect (not (d012__p_has ?s ?heart))
  )

  (:action d012__a_stepmother_laces_snow_white_tightly
    :parameters (?c - d012__t_entity ?s - d012__t_entity ?lace - d012__t_item)
    :precondition (and (d012__p_alive ?c) (d012__p_has ?c ?lace))
    :effect (and (d012__p_laced ?c ?lace) (d012__p_dead ?c) (not (d012__p_alive ?c)) (not (d012__p_sleeping ?c)))
  )

  (:action d012__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - d012__t_entity ?apple - d012__t_item ?cottage - d012__t_location)
    :precondition (d012__p_alive ?s)
    :effect (and (d012__p_poisoned ?apple) (d012__p_has ?s ?apple) (d012__p_visited ?s ?cottage))
  )

  (:action d012__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - d012__t_entity ?comb - d012__t_item ?cottage - d012__t_location)
    :precondition (d012__p_alive ?s)
    :effect (and (d012__p_poisoned ?comb) (d012__p_has ?s ?comb) (d012__p_visited ?s ?cottage))
  )

  (:action d012__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - d012__t_entity ?h - d012__t_entity ?s - d012__t_entity)
    :precondition (and (d012__p_envious ?s) (d012__p_alive ?h) (d012__p_alive ?c))
    :effect (d012__p_fair ?s)
  )

  (:action d013__a_claim_queenhood
    :parameters (?m - d013__t_entity)
    :precondition (or (d013__p_soup_effect_created ?m) (d013__p_king_tail_stirred))
    :effect (d013__p_is_queen ?m)
  )

  (:action d013__a_escape_jail
    :parameters (?m - d013__t_entity)
    :precondition (d013__p_captured ?m)
    :effect (and (d013__p_escaped ?m) (not (d013__p_captured ?m)) (not (d013__p_in_cage ?m)))
  )

  (:action d013__a_give_skewer_to_elves
    :parameters (?elf - d013__t_entity ?m - d013__t_entity)
    :precondition (d013__p_holds ?m d013__c_sausage_skewer)
    :effect (and (d013__p_holds ?elf d013__c_sausage_skewer) (not (d013__p_holds ?m d013__c_sausage_skewer)))
  )

  (:action d013__a_learn_wisdom_from_ants
    :parameters (?m - d013__t_entity ?ant_loc - d013__t_location)
    :precondition (d013__p_at ?m ?ant_loc)
    :effect (d013__p_has_understanding ?m)
  )

  (:action d013__a_prepare_soup_by_elf_effect
    :parameters (?m - d013__t_entity)
    :precondition (and (d013__p_holds ?m d013__c_sausage_skewer) (d013__p_anointed d013__c_sausage_skewer) (d013__p_at ?m d013__c_kitchen))
    :effect (d013__p_soup_effect_created ?m)
  )

  (:action d013__a_prepare_soup_by_king_tail
    :parameters (?k - d013__t_entity)
    :precondition (d013__p_at d013__c_mouse_king d013__c_kitchen)
    :effect (d013__p_king_tail_stirred)
  )

  (:action d013__a_prepare_soup_by_poet_imagination
    :parameters (?m - d013__t_entity)
    :precondition (and (d013__p_has_understanding ?m) (d013__p_has_imagination ?m) (d013__p_has_feeling ?m))
    :effect (and (d013__p_soup_effect_created ?m) (d013__p_is_poet ?m))
  )

  (:action d013__a_read_and_digest_books
    :parameters (?m - d013__t_entity ?lib - d013__t_location)
    :precondition (d013__p_at ?m d013__c_library)
    :effect (d013__p_has_feeling ?m)
  )

  (:action d013__a_receive_anointed_skewer
    :parameters (?elf - d013__t_entity ?m - d013__t_entity ?v - d013__t_item)
    :precondition (and (d013__p_holds ?m d013__c_sausage_skewer) (d013__p_holds ?elf d013__c_violet))
    :effect (d013__p_anointed d013__c_sausage_skewer)
  )

  (:action d013__a_receive_feather
    :parameters (?dryad - d013__t_entity ?m - d013__t_entity ?ph - d013__t_entity ?feather - d013__t_item ?loc - d013__t_location)
    :precondition (and (d013__p_at ?m ?loc) (d013__p_at ?dryad ?loc) (d013__p_at ?ph ?loc) (d013__p_holds ?dryad ?feather))
    :effect (and (d013__p_holds ?m ?feather) (d013__p_has_imagination ?m))
  )

  (:action d013__a_run_in_cage
    :parameters (?m - d013__t_entity)
    :precondition (d013__p_captured ?m)
    :effect (d013__p_in_cage ?m)
  )

  (:action d013__a_travel_to
    :parameters (?m - d013__t_entity ?dest - d013__t_location ?orig - d013__t_location)
    :precondition (and (d013__p_at ?m ?orig) (d013__p_holds ?m d013__c_sausage_skewer))
    :effect (and (d013__p_at ?m ?dest) (not (d013__p_at ?m ?orig)))
  )

  (:action d014__a_accept_woe_as_burden
    :parameters (?rich - d014__t_entity ?woe - d014__t_entity)
    :precondition (d014__p_woe_on_shoulder ?woe ?rich)
    :effect (d014__p_has_fatigue ?rich)
  )

  (:action d014__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - d014__t_entity ?woe - d014__t_entity ?loc - d014__t_location)
    :precondition (and (d014__p_at ?poor ?loc) (d014__p_at ?woe ?loc) (d014__p_has_fatigue ?poor))
    :effect (d014__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d014__a_bow_to_guests
    :parameters (?poor - d014__t_entity ?loc - d014__t_location)
    :precondition (and (d014__p_at ?poor ?loc) (exists (?guest - d014__t_entity) (d014__p_guest_present ?guest ?loc)))
    :effect (d014__p_bowed ?poor ?loc)
  )

  (:action d014__a_encounter_bitter_woe
    :parameters (?poor - d014__t_entity ?woe - d014__t_entity ?loc - d014__t_location)
    :precondition (and (d014__p_at ?poor ?loc) (d014__p_at ?woe ?loc))
    :effect (d014__p_has_fatigue ?poor)
  )

  (:action d014__a_hide_woe_under_stone
    :parameters (?poor - d014__t_entity ?woe - d014__t_entity ?stone - d014__t_item ?loc - d014__t_location)
    :precondition (and (d014__p_woe_on_shoulder ?woe ?poor) (d014__p_stone_at ?stone ?loc))
    :effect (and (d014__p_trapped ?woe) (d014__p_stone_at ?stone ?loc) (not (d014__p_woe_on_shoulder ?woe ?poor)) (not (d014__p_stone_moved ?stone)))
  )

  (:action d014__a_invite_rich_brother_to_feast
    :parameters (?poor - d014__t_entity ?rich - d014__t_entity ?loc - d014__t_location)
    :precondition (d014__p_at ?poor ?loc)
    :effect (and (d014__p_invitation_sent ?poor ?rich) (d014__p_invited ?rich ?poor))
  )

  (:action d014__a_make_sign_of_cross
    :parameters (?poor - d014__t_entity ?woe - d014__t_entity ?loc - d014__t_location)
    :precondition (and (d014__p_at ?poor ?loc) (d014__p_at ?woe ?loc))
    :effect (d014__p_has_fatigue ?poor)
  )

  (:action d014__a_move_heavy_stone
    :parameters (?carrier - d014__t_entity ?stone - d014__t_item ?loc - d014__t_location)
    :precondition (and (d014__p_stone_at ?stone ?loc) (d014__p_has_strength ?carrier))
    :effect (and (d014__p_stone_moved ?stone) (not (d014__p_stone_at ?stone ?loc)))
  )

  (:action d014__a_perform_work_for_rich_brother
    :parameters (?employer - d014__t_entity ?worker - d014__t_entity)
    :precondition (and (d014__p_employed ?worker ?employer) (d014__p_has_strength ?worker))
    :effect (and (d014__p_work_done ?worker ?employer) (d014__p_has_fatigue ?worker))
  )

  (:action d014__a_receive_payment
    :parameters (?employer - d014__t_entity ?worker - d014__t_entity ?bread - d014__t_item ?money - d014__t_item)
    :precondition (and (d014__p_work_done ?worker ?employer) (d014__p_has ?employer ?money) (d014__p_has ?employer ?bread))
    :effect (and (d014__p_has ?worker ?money) (d014__p_has ?worker ?bread) (not (d014__p_has ?employer ?money)) (not (d014__p_has ?employer ?bread)))
  )

  (:action d014__a_request_help_from_rich_brother
    :parameters (?poor - d014__t_entity ?rich - d014__t_entity)
    :precondition (and (d014__p_need_help ?poor) (d014__p_rich ?rich))
    :effect (and (d014__p_employed ?poor ?rich) (not (d014__p_need_help ?poor)))
  )

  (:action d014__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - d014__t_entity ?stone - d014__t_item ?loc - d014__t_location)
    :precondition (and (d014__p_stone_at ?stone ?loc) (d014__p_rich ?rich))
    :effect (and (d014__p_stone_moved ?stone) (d014__p_woe_on_shoulder d014__c_bitter_woe ?rich) (not (d014__p_stone_at ?stone ?loc)))
  )

  (:action d014__a_sing_cheerful_song
    :parameters (?poor - d014__t_entity ?loc - d014__t_location)
    :precondition (d014__p_at ?poor ?loc)
    :effect (d014__p_singing ?poor)
  )

  (:action d014__a_spend_money_on_drink
    :parameters (?poor - d014__t_entity ?money - d014__t_item ?wine - d014__t_item ?kabak - d014__t_location)
    :precondition (and (d014__p_has ?poor ?money) (d014__p_at ?poor ?kabak))
    :effect (and (d014__p_has ?poor ?wine) (d014__p_drunk ?poor) (not (d014__p_has ?poor ?money)))
  )

  (:action d014__a_stay_for_banquet
    :parameters (?guest - d014__t_entity ?host - d014__t_entity ?loc - d014__t_location)
    :precondition (and (d014__p_at ?guest ?loc) (d014__p_at ?host ?loc) (d014__p_banquet_at ?loc) (d014__p_invited ?guest ?host))
    :effect (d014__p_guest_present ?guest ?loc)
  )

  (:action d014__a_take_gold_pot_and_hide
    :parameters (?poor - d014__t_entity ?gold - d014__t_item ?loc - d014__t_location)
    :precondition (and (d014__p_gold_at ?gold ?loc) (d014__p_at ?poor ?loc))
    :effect (and (d014__p_has ?poor ?gold) (d014__p_concealed ?gold) (not (d014__p_gold_at ?gold ?loc)))
  )

  (:action d014__a_trade_assets_for_money
    :parameters (?poor - d014__t_entity ?asset - d014__t_item ?money - d014__t_item)
    :precondition (d014__p_has ?poor ?asset)
    :effect (and (d014__p_has ?poor ?money) (not (d014__p_has ?poor ?asset)))
  )
)
