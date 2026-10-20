(define (domain narrative_union)
  (:requirements :adl :conditional-effects :disjunctive-preconditions :equality :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d001__t_allpolice d001__t_citizen d001__t_police d001__t_trafficcop - d001__t_actor
    d001__t_vehicle - d001__t_item
    d001__t_actor d001__t_crime d001__t_item d001__t_place - d001__t_object
    d001__t_detective d001__t_inspector - d001__t_police
    d001__t_car d001__t_motorbike - d001__t_vehicle
    d002__t_entity d002__t_item d002__t_location - d002__t_object
    d003__t_entity d003__t_item d003__t_location - d003__t_object
    d004__t_entity d004__t_item d004__t_location - d004__t_object
    d005__t_entity d005__t_item d005__t_location - d005__t_object
    d006__t_entity d006__t_item d006__t_location - d006__t_object
    d007__t_entity d007__t_item d007__t_location - d007__t_object
    d008__t_entity d008__t_item d008__t_location - d008__t_object
    d009__t_entity d009__t_item d009__t_location - d009__t_object
    d010__t_entity d010__t_item d010__t_location - d010__t_object
    d011__t_entity d011__t_item d011__t_location - d011__t_object
    d012__t_entity d012__t_item d012__t_location - d012__t_object
    d013__t_entity d013__t_item d013__t_location - d013__t_object
    d014__t_entity d014__t_item d014__t_location - d014__t_object
    d015__t_entity d015__t_item d015__t_location - d015__t_object
    d000__t_object d001__t_object d002__t_object d003__t_object d004__t_object d005__t_object d006__t_object d007__t_object d008__t_object d009__t_object d010__t_object d011__t_object d012__t_object d013__t_object d014__t_object d015__t_object - object
  )
  (:constants
    d000__c_badger d000__c_friend d000__c_lady_of_court d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_tinker - d000__t_entity
    d000__c_box d000__c_copper_coins d000__c_pack d000__c_teakettle d000__c_temple_treasure - d000__t_item
    d000__c_jhosiu d000__c_morinji d000__c_tight_rope - d000__t_location
    d002__c_dryad d002__c_fairy_queen d002__c_gnome d002__c_grandmother d002__c_grandmotherkin d002__c_mother d002__c_mothereen d002__c_nora - d002__t_entity
    d002__c_boat d002__c_gold_star d002__c_key d002__c_lantern d002__c_pellet d002__c_silver_salver - d002__t_item
    d002__c_beech_tree d002__c_bench d002__c_corridor d002__c_cottage d002__c_door d002__c_fairyland d002__c_palace d002__c_pond d002__c_spring d002__c_stairs d002__c_stream - d002__t_location
    d003__c_audience d003__c_buffoon d003__c_countryman d003__c_little_pig d003__c_rich_nobleman - d003__t_entity
    d003__c_cloak - d003__t_item
    d003__c_platform d003__c_theater - d003__t_location
    d004__c_chicken-licken d004__c_cock-lock d004__c_drake-lake d004__c_duck-luck d004__c_fox-lox d004__c_gander-lander d004__c_goose-loose d004__c_hen-len d004__c_king d004__c_turkey-lurkey - d004__t_entity
    d004__c_acorn d004__c_sky - d004__t_item
    d004__c_foxhole d004__c_wood - d004__t_location
    d005__c_brother_astronomer d005__c_brother_hunter d005__c_brother_tailor d005__c_brother_thief d005__c_chaffinch d005__c_dragon d005__c_father d005__c_king d005__c_mentor_astronomer d005__c_mentor_hunter d005__c_mentor_tailor d005__c_mentor_thief d005__c_princess - d005__t_entity
    d005__c_eggs d005__c_gun d005__c_needle d005__c_planks d005__c_ship d005__c_sticks d005__c_telescope - d005__t_item
    d005__c_cross_way d005__c_house d005__c_kingdom d005__c_rock_sea d005__c_sea d005__c_town_gate d005__c_tree - d005__t_location
    d006__c_bird d006__c_duck d006__c_father d006__c_grettel d006__c_hansel d006__c_mother d006__c_witch - d006__t_entity
    d006__c_apple d006__c_bread_piece d006__c_brushwood d006__c_cake d006__c_crumb d006__c_kettle d006__c_milk d006__c_nut d006__c_oven d006__c_pancake d006__c_pearl d006__c_pebble d006__c_precious_stone d006__c_sugar_window - d006__t_item
    d006__c_branch d006__c_cottage d006__c_dead_tree d006__c_door d006__c_father_house d006__c_forest d006__c_hill d006__c_lake d006__c_path d006__c_roof d006__c_room d006__c_stable_location d006__c_window - d006__t_location
    d007__c_brown_hen d007__c_butcher d007__c_fairy_maiden d007__c_giant d007__c_giant_dog d007__c_giant_wife d007__c_jack d007__c_jack_mother d007__c_milky_white - d007__t_entity
    d007__c_axe d007__c_gold_bag_1 d007__c_gold_bag_2 d007__c_golden_harp d007__c_magic_beans d007__c_oak_tree_club - d007__t_item
    d007__c_beanstalk d007__c_castle_road d007__c_cottage d007__c_garden d007__c_giant_castle d007__c_kettle d007__c_market d007__c_oven d007__c_window - d007__t_location
    d008__c_ass d008__c_captain d008__c_cat d008__c_cock d008__c_hound d008__c_man d008__c_messenger d008__c_robber - d008__t_entity
    d008__c_drinks d008__c_kettledrums d008__c_lute d008__c_meat d008__c_straw d008__c_table - d008__t_item
    d008__c_beam d008__c_bremen d008__c_forest d008__c_hearth d008__c_road_to_bremen d008__c_robbers_cottage d008__c_window - d008__t_location
    d009__c_bungo d009__c_comet_master d009__c_earth d009__c_long_tail_45 d009__c_meteor d009__c_meteor_keeper d009__c_no1_express d009__c_short_tail_73 d009__c_sun - d009__t_entity
    d009__c_chalk d009__c_slate - d009__t_item
    d009__c_comet_house d009__c_courtyard d009__c_gate - d009__t_location
    d010__c_farmer d010__c_man_bricks d010__c_man_furze d010__c_man_straw d010__c_mother_pig d010__c_pig1 d010__c_pig2 d010__c_pig3 d010__c_squire d010__c_wolf - d010__t_entity
    d010__c_apple d010__c_bricks d010__c_butter_churn d010__c_fire d010__c_furze_bundle d010__c_mortar d010__c_pot_of_water d010__c_sack d010__c_straw_bundle d010__c_trowel d010__c_turnips_load - d010__t_item
    d010__c_brick_house d010__c_chimney d010__c_furze_house d010__c_hearth d010__c_hill d010__c_oak_forest d010__c_pig_home d010__c_squire_orchard d010__c_straw_house d010__c_town_fair d010__c_turnip_field - d010__t_location
    d011__c_coachman d011__c_eldest_son d011__c_groom d011__c_jack d011__c_king d011__c_miller d011__c_ogre d011__c_princess d011__c_puss d011__c_second_son - d011__t_entity
    d011__c_ass d011__c_bag d011__c_boots d011__c_hare d011__c_mill d011__c_partridge d011__c_rabbit d011__c_suit - d011__t_item
    d011__c_field_of_corn d011__c_field_of_wheat d011__c_ogre_castle d011__c_palace d011__c_river d011__c_royal_wardrobe d011__c_warren - d011__t_location
    d012__c_father_king d012__c_impostor_butterman d012__c_king_at_palace d012__c_princess d012__c_robber_chief - d012__t_entity
    d012__c_bag_of_rubies d012__c_bag_of_sapphires d012__c_crown d012__c_sceptre - d012__t_item
    d012__c_back_door d012__c_back_stairs d012__c_city d012__c_forest d012__c_market_place d012__c_oak_tree d012__c_palace - d012__t_location
    d013__c_boar d013__c_dove d013__c_dwarf1 d013__c_dwarf2 d013__c_dwarf3 d013__c_dwarf4 d013__c_dwarf5 d013__c_dwarf6 d013__c_dwarf7 d013__c_huntsman d013__c_king d013__c_owl d013__c_prince d013__c_queen d013__c_raven d013__c_snow_white - d013__t_entity
    d013__c_apple d013__c_bed d013__c_blood_drop d013__c_boar_heart d013__c_candle d013__c_coffin d013__c_comb d013__c_fork d013__c_golden_letter d013__c_iron_slippers d013__c_knife d013__c_lace d013__c_looking_glass d013__c_mug d013__c_needle d013__c_plate d013__c_red_hot_shoes d013__c_salt d013__c_spoon - d013__t_item
    d013__c_cottage d013__c_forest d013__c_mountain - d013__t_location
    d014__c_ant_queen d014__c_elf_chief d014__c_first_traveler_mouse d014__c_fourth_traveler_mouse d014__c_jailer d014__c_jailer_granddaughter d014__c_mouse_king d014__c_oak_dryad d014__c_old_lady_mouse d014__c_old_owl d014__c_phantaesus d014__c_second_traveler_mouse d014__c_third_traveler_mouse d014__c_watchman d014__c_young_lady_mouse - d014__t_entity
    d014__c_crape_skewer d014__c_maypole d014__c_sausage_skewer d014__c_violet - d014__t_item
    d014__c_castle d014__c_forest d014__c_kitchen d014__c_library d014__c_north d014__c_sea d014__c_ship - d014__t_location
    d015__c_bitter_woe d015__c_children d015__c_poor_brother d015__c_rich_brother d015__c_wife - d015__t_entity
    d015__c_cattle d015__c_copecks_25 d015__c_gold_pot d015__c_grove d015__c_harrow d015__c_honey d015__c_loaf_bread d015__c_plow d015__c_sledge d015__c_stone d015__c_telega d015__c_wine - d015__t_item
    d015__c_big_house d015__c_forest d015__c_izba d015__c_kabak d015__c_large_town d015__c_new_home d015__c_treasure_pit d015__c_village d015__c_well d015__c_yard - d015__t_location
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
    (d000__p_located ?obj - d000__t_object ?loc - d000__t_location)
    (d000__p_night)
    (d000__p_owned_by ?i - d000__t_item ?e - d000__t_entity)
    (d000__p_performing_show ?e - d000__t_entity)
    (d000__p_reputation_widespread)
    (d000__p_treasured ?i - d000__t_item)
    (d000__p_wealthy ?e - d000__t_entity)
    (d000__p_worshipped ?i - d000__t_item)
    (d001__p_alive ?a - d001__t_actor)
    (d001__p_angry ?a - d001__t_actor)
    (d001__p_arrester ?p - d001__t_actor)
    (d001__p_arrester-at ?p - d001__t_place)
    (d001__p_at ?c - d001__t_actor ?p - d001__t_place)
    (d001__p_clue ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    (d001__p_has ?c - d001__t_actor ?t - d001__t_item)
    (d001__p_has-car ?a - d001__t_actor ?c - d001__t_vehicle)
    (d001__p_is-arrest-place ?p - d001__t_place)
    (d001__p_is-basketball-place ?p - d001__t_place)
    (d001__p_is-murder ?c - d001__t_crime)
    (d001__p_is-theft ?c - d001__t_crime)
    (d001__p_knows-clue ?p - d001__t_police ?c - d001__t_crime ?i - d001__t_item)
    (d001__p_murder-clue ?i - d001__t_item)
    (d001__p_suspect ?a - d001__t_actor ?c - d001__t_crime)
    (d001__p_under-arrest ?a - d001__t_actor)
    (d001__p_working ?c - d001__t_vehicle)
    (d002__p_at ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_boat_available ?b - d002__t_item ?l - d002__t_location)
    (d002__p_corridor_reached ?e - d002__t_entity)
    (d002__p_door_open ?d - d002__t_location)
    (d002__p_gloomy ?e - d002__t_entity)
    (d002__p_gold_star_on ?e - d002__t_entity ?s - d002__t_item)
    (d002__p_has ?e - d002__t_entity ?i - d002__t_item)
    (d002__p_inside ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_invitation_offered ?from - d002__t_entity ?to - d002__t_entity)
    (d002__p_joyful ?e - d002__t_entity)
    (d002__p_kissed_by ?e - d002__t_entity ?k - d002__t_entity)
    (d002__p_knighted ?e - d002__t_entity)
    (d002__p_lantern_carried ?e - d002__t_entity ?l - d002__t_item)
    (d002__p_pellet_eaten ?e - d002__t_entity)
    (d002__p_shrunk ?e - d002__t_entity)
    (d002__p_sound_heard ?e - d002__t_entity ?l - d002__t_location)
    (d002__p_stairs_descended ?e - d002__t_entity)
    (d002__p_story_shared ?speaker - d002__t_entity ?listener - d002__t_entity)
    (d003__p_applause_given ?audience - d003__t_entity ?performer - d003__t_entity)
    (d003__p_audience_calls_for_kickout ?audience - d003__t_entity ?countryman - d003__t_entity)
    (d003__p_audience_demands_shake_cloak ?audience - d003__t_entity ?performer - d003__t_entity ?cloak - d003__t_item)
    (d003__p_cloak_shaken ?performer - d003__t_entity ?cloak - d003__t_item)
    (d003__p_countryman_declares_intent ?countryman - d003__t_entity)
    (d003__p_countryman_performs_with_real_pig ?countryman - d003__t_entity ?pig - d003__t_entity)
    (d003__p_crowd_present ?audience - d003__t_entity ?theater - d003__t_location)
    (d003__p_imitates_pig ?performer - d003__t_entity)
    (d003__p_on_platform ?performer - d003__t_entity ?platform - d003__t_location)
    (d003__p_partiality_prevalent)
    (d003__p_performs_without_apparatus ?performer - d003__t_entity)
    (d003__p_pig_found ?performer - d003__t_entity ?pig - d003__t_entity)
    (d003__p_pig_revealed ?countryman - d003__t_entity ?pig - d003__t_entity)
    (d003__p_reward_announced ?nobleman - d003__t_entity)
    (d003__p_theater_opened ?nobleman - d003__t_entity ?theater - d003__t_location)
    (d004__p_at ?e - d004__t_entity ?l - d004__t_location)
    (d004__p_decided_to_tell_king ?e - d004__t_entity)
    (d004__p_eaten_by_fox ?e - d004__t_entity)
    (d004__p_following_fox ?e - d004__t_entity)
    (d004__p_going_to_wood ?e - d004__t_entity)
    (d004__p_informed_about_sky_fall ?informer - d004__t_entity ?listener - d004__t_entity)
    (d004__p_met ?e1 - d004__t_entity ?e2 - d004__t_entity)
    (d004__p_sky_fell_on_head ?e - d004__t_entity)
    (d004__p_turned_back ?e - d004__t_entity)
    (d005__p_dragon_dead)
    (d005__p_eggs_fetched ?e - d005__t_entity)
    (d005__p_eggs_sewn ?e - d005__t_entity)
    (d005__p_eggs_shot ?e - d005__t_entity)
    (d005__p_entity_at ?e - d005__t_entity ?l - d005__t_location)
    (d005__p_half_kingdom ?e - d005__t_entity ?k - d005__t_location)
    (d005__p_has ?e - d005__t_entity ?i - d005__t_item)
    (d005__p_is_astronomer ?e - d005__t_entity)
    (d005__p_is_hunter ?e - d005__t_entity)
    (d005__p_is_tailor ?e - d005__t_entity)
    (d005__p_is_thief ?e - d005__t_entity)
    (d005__p_item_at ?i - d005__t_item ?l - d005__t_location)
    (d005__p_princess_rescued ?e - d005__t_entity)
    (d005__p_reward_received ?e - d005__t_entity)
    (d005__p_ship_broken)
    (d005__p_ship_repaired)
    (d006__p_at ?e - d006__t_entity ?l - d006__t_location)
    (d006__p_bird_heard ?c - d006__t_entity ?l - d006__t_location)
    (d006__p_bread_given ?c - d006__t_entity)
    (d006__p_captured ?c - d006__t_entity)
    (d006__p_collected ?c - d006__t_entity ?i - d006__t_item)
    (d006__p_crossed_lake ?c - d006__t_entity)
    (d006__p_crumb_on_path ?l - d006__t_location)
    (d006__p_dead ?e - d006__t_entity)
    (d006__p_duck_helped ?c - d006__t_entity ?d - d006__t_entity)
    (d006__p_fire_lit ?l - d006__t_location)
    (d006__p_has ?e - d006__t_entity ?i - d006__t_item)
    (d006__p_locked ?l - d006__t_location)
    (d006__p_lost ?c - d006__t_entity)
    (d006__p_pebble_on_path ?l - d006__t_location)
    (d006__p_reunited_with_father ?c - d006__t_entity)
    (d007__p_asleep ?e - d007__t_entity)
    (d007__p_at ?e - d007__t_entity ?l - d007__t_location)
    (d007__p_at_item ?i - d007__t_item ?l - d007__t_location)
    (d007__p_beanstalk_grown)
    (d007__p_climbing_down ?e - d007__t_entity)
    (d007__p_dead ?e - d007__t_entity)
    (d007__p_distracted ?e - d007__t_entity)
    (d007__p_empty ?i - d007__t_item)
    (d007__p_has ?e - d007__t_entity ?i - d007__t_item)
    (d007__p_has_breakfast ?e - d007__t_entity)
    (d007__p_inside ?e - d007__t_entity ?i - d007__t_item)
    (d007__p_intact ?l - d007__t_location)
    (d007__p_offers ?e - d007__t_entity ?i - d007__t_item)
    (d007__p_on ?i - d007__t_item ?l - d007__t_location)
    (d007__p_planted ?i - d007__t_item)
    (d008__p_agreed ?e - d008__t_entity ?inviter - d008__t_entity)
    (d008__p_at ?e - d008__t_entity ?l - d008__t_location)
    (d008__p_ate_all ?e - d008__t_entity)
    (d008__p_attacked ?attacker - d008__t_entity ?target - d008__t_entity)
    (d008__p_attempt_light ?messenger - d008__t_entity)
    (d008__p_bite ?dog - d008__t_entity ?target - d008__t_entity)
    (d008__p_crowed ?cock - d008__t_entity)
    (d008__p_fled ?robber - d008__t_entity ?loc - d008__t_location)
    (d008__p_invited ?inviter - d008__t_entity ?invitee - d008__t_entity)
    (d008__p_kick ?donkey - d008__t_entity ?target - d008__t_entity)
    (d008__p_light_off ?loc - d008__t_location)
    (d008__p_light_on ?loc - d008__t_location)
    (d008__p_making_noise ?e - d008__t_entity)
    (d008__p_moving_towards ?e - d008__t_entity ?loc - d008__t_location)
    (d008__p_resting ?e - d008__t_entity)
    (d008__p_retreated ?robber - d008__t_entity)
    (d008__p_sees_light ?e - d008__t_entity)
    (d008__p_sleeping_at ?e - d008__t_entity ?loc - d008__t_location)
    (d008__p_stacked_on ?top - d008__t_entity ?bottom - d008__t_entity)
    (d008__p_window_shattered)
    (d009__p_arrested ?c - d009__t_entity ?m - d009__t_entity)
    (d009__p_at ?e - d009__t_entity ?l - d009__t_location)
    (d009__p_avoid ?c - d009__t_entity ?b - d009__t_entity)
    (d009__p_burned ?c - d009__t_entity)
    (d009__p_crossed_out ?c - d009__t_entity)
    (d009__p_delivered ?m - d009__t_entity ?p - d009__t_entity)
    (d009__p_detained ?m - d009__t_entity)
    (d009__p_gate_open)
    (d009__p_has_mission ?c - d009__t_entity)
    (d009__p_left_turn_rule ?c - d009__t_entity)
    (d009__p_near ?c - d009__t_entity ?b - d009__t_entity)
    (d009__p_on_list ?c - d009__t_entity)
    (d009__p_prohibit_speak ?c - d009__t_entity)
    (d009__p_punished ?m - d009__t_entity)
    (d009__p_rule_violation ?c - d009__t_entity)
    (d009__p_speaks_to ?c - d009__t_entity ?m - d009__t_entity)
    (d009__p_summoned ?c - d009__t_entity)
    (d009__p_traveling ?c - d009__t_entity)
    (d010__p_alive ?e - d010__t_entity)
    (d010__p_at ?e - d010__t_entity ?l - d010__t_location)
    (d010__p_boiling ?i - d010__t_item)
    (d010__p_dead ?e - d010__t_entity)
    (d010__p_door_closed ?h - d010__t_location)
    (d010__p_entry_denied ?w - d010__t_entity ?h - d010__t_location)
    (d010__p_entry_requested ?w - d010__t_entity ?h - d010__t_location)
    (d010__p_escaped ?e - d010__t_entity)
    (d010__p_has ?e - d010__t_entity ?i - d010__t_item)
    (d010__p_has_bundle ?m - d010__t_entity ?i - d010__t_item)
    (d010__p_house ?h - d010__t_location ?m - d010__t_item)
    (d010__p_house_destroyed ?h - d010__t_location)
    (d010__p_house_intact ?h - d010__t_location)
    (d010__p_huffed ?w - d010__t_entity)
    (d010__p_inside ?e - d010__t_entity ?c - d010__t_item)
    (d010__p_material_requested ?p - d010__t_entity ?i - d010__t_item)
    (d010__p_over ?i1 - d010__t_item ?i2 - d010__t_item)
    (d010__p_plan ?e - d010__t_entity ?l - d010__t_location)
    (d010__p_puffed ?w - d010__t_entity)
    (d010__p_rolling ?i - d010__t_item)
    (d010__p_under ?i - d010__t_item ?l - d010__t_location)
    (d011__p_alive ?x - d011__t_entity)
    (d011__p_at ?x - d011__t_entity ?l - d011__t_location)
    (d011__p_at_item ?i - d011__t_item ?l - d011__t_location)
    (d011__p_castle_owned_by ?castle - d011__t_location ?owner - d011__t_entity)
    (d011__p_contains ?c - d011__t_item ?i - d011__t_item)
    (d011__p_drowning ?e - d011__t_entity)
    (d011__p_gate_open ?castle - d011__t_location)
    (d011__p_gift_delivered ?giver - d011__t_entity ?receiver - d011__t_entity ?item - d011__t_item)
    (d011__p_has ?e - d011__t_entity ?i - d011__t_item)
    (d011__p_married ?e1 - d011__t_entity ?e2 - d011__t_entity)
    (d011__p_obedient ?e - d011__t_entity)
    (d011__p_promised_to_serve ?servant - d011__t_entity ?master - d011__t_entity)
    (d011__p_rescued_by ?victim - d011__t_entity ?rescuer - d011__t_entity)
    (d011__p_transformed_into ?e - d011__t_entity ?form - d011__t_entity)
    (d011__p_wearing ?e - d011__t_entity ?i - d011__t_item)
    (d012__p_at ?e - d012__t_entity ?l - d012__t_location)
    (d012__p_grandmother_mangle_spoken)
    (d012__p_has ?e - d012__t_entity ?i - d012__t_item)
    (d012__p_married ?p1 - d012__t_entity ?p2 - d012__t_entity)
    (d012__p_price_of_butter_spoken)
    (d012__p_with_all_my_heart_spoken)
    (d013__p_alive ?e - d013__t_entity)
    (d013__p_at ?e - d013__t_entity ?l - d013__t_location)
    (d013__p_at_item ?i - d013__t_item ?l - d013__t_location)
    (d013__p_awake ?e - d013__t_entity)
    (d013__p_dead ?e - d013__t_entity)
    (d013__p_disguised_as ?e - d013__t_entity ?d - d013__t_entity)
    (d013__p_envious ?e - d013__t_entity)
    (d013__p_fair ?e - d013__t_entity)
    (d013__p_fairest ?e - d013__t_entity)
    (d013__p_has ?e - d013__t_entity ?i - d013__t_item)
    (d013__p_in_coffin ?e - d013__t_entity)
    (d013__p_laced ?e - d013__t_entity ?i - d013__t_item)
    (d013__p_poisoned ?i - d013__t_item)
    (d013__p_sleeping ?e - d013__t_entity)
    (d013__p_visited ?e - d013__t_entity ?l - d013__t_location)
    (d013__p_wearing ?e - d013__t_entity ?i - d013__t_item)
    (d014__p_anointed ?i - d014__t_item)
    (d014__p_at ?e - d014__t_entity ?l - d014__t_location)
    (d014__p_captured ?e - d014__t_entity)
    (d014__p_escaped ?e - d014__t_entity)
    (d014__p_has_feeling ?e - d014__t_entity)
    (d014__p_has_imagination ?e - d014__t_entity)
    (d014__p_has_understanding ?e - d014__t_entity)
    (d014__p_holds ?e - d014__t_entity ?i - d014__t_item)
    (d014__p_in_cage ?e - d014__t_entity)
    (d014__p_is_poet ?e - d014__t_entity)
    (d014__p_is_queen ?e - d014__t_entity)
    (d014__p_king_tail_stirred)
    (d014__p_soup_effect_created ?e - d014__t_entity)
    (d015__p_at ?e - d015__t_entity ?l - d015__t_location)
    (d015__p_banquet_at ?l - d015__t_location)
    (d015__p_bowed ?e - d015__t_entity ?l - d015__t_location)
    (d015__p_concealed ?i - d015__t_item)
    (d015__p_drunk ?e - d015__t_entity)
    (d015__p_employed ?worker - d015__t_entity ?employer - d015__t_entity)
    (d015__p_gold_at ?g - d015__t_item ?l - d015__t_location)
    (d015__p_guest_present ?guest - d015__t_entity ?l - d015__t_location)
    (d015__p_has ?e - d015__t_entity ?i - d015__t_item)
    (d015__p_has_fatigue ?e - d015__t_entity)
    (d015__p_has_strength ?e - d015__t_entity)
    (d015__p_invitation_sent ?sender - d015__t_entity ?receiver - d015__t_entity)
    (d015__p_invited ?invitee - d015__t_entity ?host - d015__t_entity)
    (d015__p_need_help ?e - d015__t_entity)
    (d015__p_poor ?e - d015__t_entity)
    (d015__p_rich ?e - d015__t_entity)
    (d015__p_singing ?e - d015__t_entity)
    (d015__p_stone_at ?s - d015__t_item ?l - d015__t_location)
    (d015__p_stone_moved ?s - d015__t_item)
    (d015__p_trapped ?m - d015__t_entity)
    (d015__p_woe_on_shoulder ?monster - d015__t_entity ?carrier - d015__t_entity)
    (d015__p_work_done ?worker - d015__t_entity ?employer - d015__t_entity)
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

  (:action d001__a_arrest
    :parameters (?p - d001__t_police ?a - d001__t_actor ?p1 - d001__t_place ?p2 - d001__t_place ?c - d001__t_crime)
    :precondition (and (d001__p_at ?p ?p1) (d001__p_at ?a ?p1) (not (= ?p1 ?p2)) (d001__p_is-arrest-place ?p2) (d001__p_alive ?p) (d001__p_alive ?a) (d001__p_suspect ?a ?c) (d001__p_arrester ?p))
    :effect (and (d001__p_at ?a ?p2) (not (d001__p_at ?a ?p1)) (d001__p_at ?p ?p2) (not (d001__p_at ?p ?p1)) (d001__p_under-arrest ?a))
  )

  (:action d001__a_findclues
    :parameters (?a - d001__t_police ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    :precondition (and (d001__p_at ?a ?p) (d001__p_alive ?a) (d001__p_clue ?c ?i ?p))
    :effect (and (d001__p_knows-clue ?a ?c ?i))
  )

  (:action d001__a_kill
    :parameters (?a - d001__t_citizen ?b - d001__t_citizen ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    :precondition (and (d001__p_at ?a ?p) (d001__p_at ?b ?p) (d001__p_alive ?a) (d001__p_alive ?b) (not (= ?a ?b)) (d001__p_has ?a ?i) (d001__p_is-murder ?c) (not (d001__p_under-arrest ?a)))
    :effect (and (not (d001__p_alive ?b)) (d001__p_clue ?c ?i ?p))
  )

  (:action d001__a_play-basketball
    :parameters (?a - d001__t_citizen ?b - d001__t_citizen ?p - d001__t_place)
    :precondition (and (d001__p_is-basketball-place ?p) (d001__p_at ?a ?p) (d001__p_alive ?a) (d001__p_at ?b ?p) (d001__p_alive ?b) (not (= ?a ?b)))
    :effect (and (not (d001__p_angry ?a)) (not (d001__p_angry ?b)))
  )

  (:action d001__a_shareclues
    :parameters (?a - d001__t_police ?b - d001__t_police ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    :precondition (and (d001__p_at ?a ?p) (d001__p_alive ?a) (d001__p_at ?b ?p) (d001__p_alive ?b) (d001__p_clue ?c ?i ?p) (d001__p_knows-clue ?a ?c ?i))
    :effect (and (d001__p_knows-clue ?b ?c ?i))
  )

  (:action d001__a_steal
    :parameters (?a - d001__t_citizen ?b - d001__t_citizen ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    :precondition (and (d001__p_at ?a ?p) (d001__p_at ?b ?p) (d001__p_has ?b ?i) (not (= ?a ?b)) (d001__p_alive ?a) (d001__p_is-theft ?c))
    :effect (and (d001__p_has ?a ?i) (not (d001__p_has ?b ?i)) (d001__p_angry ?b) (d001__p_clue ?c ?i ?p))
  )

  (:action d001__a_suspect-of-crime
    :parameters (?a - d001__t_police ?b - d001__t_citizen ?c - d001__t_crime ?i - d001__t_item ?p - d001__t_place)
    :precondition (and (d001__p_at ?a ?p) (d001__p_alive ?a) (d001__p_at ?b ?p) (d001__p_alive ?b) (d001__p_knows-clue ?a ?c ?i) (d001__p_has ?b ?i))
    :effect (and (d001__p_suspect ?b ?c))
  )

  (:action d001__a_travel
    :parameters (?a - d001__t_actor ?c - d001__t_car ?p1 - d001__t_place ?p2 - d001__t_place)
    :precondition (and (d001__p_working ?c) (d001__p_at ?a ?p1) (d001__p_alive ?a) (d001__p_has-car ?a ?c))
    :effect (and (d001__p_at ?a ?p2) (not (d001__p_at ?a ?p1)) (when (and (d001__p_arrester ?a)) (and (d001__p_arrester-at ?p2) (not (d001__p_arrester-at ?p1)))))
  )

  (:action d002__a_accept_dryad_invitation
    :parameters (?d - d002__t_entity ?n - d002__t_entity)
    :precondition (d002__p_invitation_offered ?d ?n)
    :effect (not (d002__p_invitation_offered ?d ?n))
  )

  (:action d002__a_approach_beech_tree
    :parameters (?n - d002__t_entity ?t - d002__t_location)
    :precondition (d002__p_sound_heard ?n ?t)
    :effect (and (d002__p_at ?n ?t) (not (d002__p_at ?n d002__c_bench)))
  )

  (:action d002__a_eat_pellet_and_shrink
    :parameters (?n - d002__t_entity ?p - d002__t_item)
    :precondition (d002__p_has ?n ?p)
    :effect (and (d002__p_pellet_eaten ?n) (d002__p_shrunk ?n) (not (d002__p_has ?n ?p)))
  )

  (:action d002__a_enter_tree_and_descend_stairs
    :parameters (?d - d002__t_entity ?n - d002__t_entity ?corridor - d002__t_location ?door - d002__t_location ?stairs - d002__t_location ?t - d002__t_location)
    :precondition (and (d002__p_inside ?n ?t) (d002__p_inside ?d ?t) (d002__p_door_open d002__c_door))
    :effect (and (d002__p_stairs_descended ?n) (d002__p_stairs_descended ?d) (d002__p_corridor_reached ?n))
  )

  (:action d002__a_hear_tapping_on_beech
    :parameters (?n - d002__t_entity ?t - d002__t_location)
    :precondition (d002__p_at ?n d002__c_bench)
    :effect (d002__p_sound_heard ?n ?t)
  )

  (:action d002__a_receive_pellet_from_gnome
    :parameters (?g - d002__t_entity ?n - d002__t_entity ?p - d002__t_item ?s - d002__t_item ?t - d002__t_location)
    :precondition (and (d002__p_inside ?n ?t) (d002__p_inside ?g ?t))
    :effect (d002__p_has ?n ?p)
  )

  (:action d002__a_receive_queen_kiss
    :parameters (?n - d002__t_entity ?q - d002__t_entity)
    :precondition (d002__p_at ?n d002__c_palace)
    :effect (and (d002__p_kissed_by ?n ?q) (d002__p_joyful ?n) (not (d002__p_gloomy ?n)))
  )

  (:action d002__a_return_to_bench_and_share_story
    :parameters (?g - d002__t_entity ?m - d002__t_entity ?n - d002__t_entity ?bench - d002__t_location)
    :precondition (d002__p_at ?n d002__c_palace)
    :effect (and (d002__p_at ?n ?bench) (d002__p_story_shared ?n ?m) (d002__p_story_shared ?n ?g) (not (d002__p_at ?n d002__c_palace)))
  )

  (:action d002__a_travel_by_leaf_boat_under_pond
    :parameters (?n - d002__t_entity ?b - d002__t_item ?palace - d002__t_location ?pond - d002__t_location)
    :precondition (and (d002__p_stairs_descended ?n) (d002__p_boat_available ?b ?pond))
    :effect (d002__p_at ?n ?palace)
  )

  (:action d002__a_travel_to_trysting_place
    :parameters (?n - d002__t_entity ?b - d002__t_location ?c - d002__t_location)
    :precondition (d002__p_at ?n ?c)
    :effect (and (d002__p_at ?n ?b) (not (d002__p_at ?n ?c)))
  )

  (:action d002__a_turn_key_on_beech
    :parameters (?n - d002__t_entity ?k - d002__t_item ?t - d002__t_location)
    :precondition (d002__p_at ?n ?t)
    :effect (and (d002__p_door_open d002__c_door) (d002__p_inside d002__c_dryad ?t) (d002__p_invitation_offered d002__c_dryad ?n) (d002__p_has ?n ?k))
  )

  (:action d002__a_witness_queen_birthday_ceremony
    :parameters (?n - d002__t_entity ?q - d002__t_entity ?palace - d002__t_location)
    :precondition (d002__p_at ?n ?palace)
    :effect (and (d002__p_joyful ?n) (d002__p_story_shared ?q ?n))
  )

  (:action d003__a_audience_applaud_performance
    :parameters (?audience - d003__t_entity ?performer - d003__t_entity ?pig - d003__t_entity ?cloak - d003__t_item)
    :precondition (and (d003__p_cloak_shaken ?performer ?cloak) (not (d003__p_pig_found ?performer ?pig)))
    :effect (d003__p_applause_given ?audience ?performer)
  )

  (:action d003__a_audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience - d003__t_entity ?countryman - d003__t_entity ?pig - d003__t_entity)
    :precondition (d003__p_countryman_performs_with_real_pig ?countryman ?pig)
    :effect (d003__p_audience_calls_for_kickout ?audience ?countryman)
  )

  (:action d003__a_audience_demand_shake_cloak_for_pig
    :parameters (?audience - d003__t_entity ?performer - d003__t_entity ?cloak - d003__t_item)
    :effect (d003__p_audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action d003__a_countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - d003__t_entity)
    :effect (d003__p_countryman_declares_intent ?countryman)
  )

  (:action d003__a_countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman - d003__t_entity ?pig - d003__t_entity ?platform - d003__t_location)
    :precondition (and (d003__p_countryman_declares_intent ?countryman) (d003__p_on_platform ?countryman ?platform))
    :effect (d003__p_countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action d003__a_countryman_reveal_real_pig
    :parameters (?audience - d003__t_entity ?countryman - d003__t_entity ?pig - d003__t_entity)
    :precondition (d003__p_audience_calls_for_kickout ?audience ?countryman)
    :effect (d003__p_pig_revealed ?countryman ?pig)
  )

  (:action d003__a_open_theater_and_announce_reward
    :parameters (?nobleman - d003__t_entity ?theater - d003__t_location)
    :effect (and (d003__p_theater_opened ?nobleman ?theater) (d003__p_reward_announced ?nobleman))
  )

  (:action d003__a_perform_pig_imitation_without_apparatus
    :parameters (?performer - d003__t_entity ?platform - d003__t_location)
    :precondition (d003__p_on_platform ?performer ?platform)
    :effect (and (d003__p_performs_without_apparatus ?performer) (d003__p_imitates_pig ?performer))
  )

  (:action d004__a_be_eaten_by_fox
    :parameters (?e - d004__t_entity ?l - d004__t_location)
    :precondition (and (d004__p_following_fox ?e) (d004__p_at ?e ?l) (not (d004__p_eaten_by_fox ?e)))
    :effect (and (d004__p_at ?e d004__c_foxhole) (d004__p_eaten_by_fox ?e) (not (d004__p_at ?e ?l)) (not (d004__p_following_fox ?e)))
  )

  (:action d004__a_decide_to_tell_king
    :parameters (?e - d004__t_entity)
    :precondition (and (exists (?inf - d004__t_entity) (d004__p_informed_about_sky_fall ?inf ?e)) (not (d004__p_decided_to_tell_king ?e)))
    :effect (d004__p_decided_to_tell_king ?e)
  )

  (:action d004__a_follow_fox
    :parameters (?e - d004__t_entity)
    :precondition (and (d004__p_decided_to_tell_king ?e) (not (d004__p_following_fox ?e)))
    :effect (d004__p_following_fox ?e)
  )

  (:action d004__a_go_to_wood
    :parameters (?e - d004__t_entity)
    :precondition (and (not (d004__p_at ?e d004__c_wood)) (not (d004__p_going_to_wood ?e)))
    :effect (d004__p_going_to_wood ?e)
  )

  (:action d004__a_inform_about_sky_fall
    :parameters (?informer - d004__t_entity ?listener - d004__t_entity)
    :precondition (and (d004__p_met ?informer ?listener) (d004__p_sky_fell_on_head d004__c_chicken-licken) (not (d004__p_informed_about_sky_fall ?informer ?listener)))
    :effect (d004__p_informed_about_sky_fall ?informer ?listener)
  )

  (:action d004__a_meet_character
    :parameters (?e1 - d004__t_entity ?e2 - d004__t_entity ?l - d004__t_location)
    :precondition (and (d004__p_at ?e1 ?l) (d004__p_at ?e2 ?l) (not (d004__p_met ?e1 ?e2)))
    :effect (and (d004__p_met ?e1 ?e2) (d004__p_met ?e2 ?e1))
  )

  (:action d004__a_turn_back
    :parameters (?e - d004__t_entity)
    :precondition (and (d004__p_going_to_wood ?e) (not (d004__p_turned_back ?e)))
    :effect (and (d004__p_turned_back ?e) (not (d004__p_going_to_wood ?e)))
  )

  (:action d005__a_count_eggs
    :parameters (?a - d005__t_entity)
    :precondition (and (d005__p_is_astronomer ?a) (d005__p_has ?a d005__c_telescope) (d005__p_entity_at ?a d005__c_tree))
    :effect (d005__p_has ?a d005__c_eggs)
  )

  (:action d005__a_fetch_eggs
    :parameters (?t - d005__t_entity)
    :precondition (and (d005__p_is_thief ?t) (d005__p_entity_at ?t d005__c_tree) (d005__p_item_at d005__c_eggs d005__c_tree))
    :effect (and (d005__p_eggs_fetched ?t) (d005__p_has ?t d005__c_eggs) (not (d005__p_item_at d005__c_eggs d005__c_tree)))
  )

  (:action d005__a_learn_astronomer_trade
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (and (d005__p_is_astronomer ?b) (d005__p_has ?b d005__c_telescope))
  )

  (:action d005__a_learn_hunter_trade
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (and (d005__p_is_hunter ?b) (d005__p_has ?b d005__c_gun))
  )

  (:action d005__a_learn_tailor_trade
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (and (d005__p_is_tailor ?b) (d005__p_has ?b d005__c_needle))
  )

  (:action d005__a_learn_thief_trade
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (d005__p_is_thief ?b)
  )

  (:action d005__a_leave_home
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_house)
    :effect (and (d005__p_entity_at ?b d005__c_town_gate) (not (d005__p_entity_at ?b d005__c_house)))
  )

  (:action d005__a_locate_princess
    :parameters (?a - d005__t_entity)
    :precondition (and (d005__p_is_astronomer ?a) (d005__p_has ?a d005__c_telescope))
    :effect (d005__p_entity_at d005__c_princess d005__c_rock_sea)
  )

  (:action d005__a_obtain_ship
    :parameters (?a - d005__t_entity)
    :precondition (d005__p_is_astronomer ?a)
    :effect (d005__p_has ?a d005__c_ship)
  )

  (:action d005__a_receive_reward
    :parameters (?e - d005__t_entity)
    :precondition (d005__p_princess_rescued ?e)
    :effect (and (d005__p_reward_received ?e) (d005__p_half_kingdom ?e d005__c_kingdom))
  )

  (:action d005__a_repair_ship
    :parameters (?t - d005__t_entity)
    :precondition (and (d005__p_is_tailor ?t) (d005__p_has ?t d005__c_needle) (d005__p_ship_broken))
    :effect (and (d005__p_ship_repaired) (not (d005__p_ship_broken)))
  )

  (:action d005__a_return_eggs_to_nest
    :parameters (?t - d005__t_entity)
    :precondition (and (d005__p_is_thief ?t) (d005__p_eggs_sewn d005__c_brother_tailor) (d005__p_entity_at ?t d005__c_tree) (d005__p_has ?t d005__c_eggs))
    :effect (and (d005__p_item_at d005__c_eggs d005__c_tree) (not (d005__p_has ?t d005__c_eggs)))
  )

  (:action d005__a_return_home_with_princess
    :parameters (?a - d005__t_entity)
    :precondition (and (d005__p_ship_repaired) (d005__p_entity_at ?a d005__c_sea))
    :effect (and (d005__p_entity_at ?a d005__c_house) (d005__p_entity_at d005__c_princess d005__c_house) (not (d005__p_entity_at ?a d005__c_sea)))
  )

  (:action d005__a_reunite_at_crossroads
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (and (d005__p_entity_at ?b d005__c_house) (not (d005__p_entity_at ?b d005__c_cross_way)))
  )

  (:action d005__a_sail_to_rock
    :parameters (?a - d005__t_entity)
    :precondition (and (d005__p_has ?a d005__c_ship) (d005__p_entity_at ?a d005__c_house))
    :effect (and (d005__p_entity_at ?a d005__c_rock_sea) (not (d005__p_entity_at ?a d005__c_house)))
  )

  (:action d005__a_separate_at_crossroads
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_entity_at ?b d005__c_cross_way)
    :effect (d005__p_has ?b d005__c_sticks)
  )

  (:action d005__a_sew_eggs
    :parameters (?t - d005__t_entity)
    :precondition (and (d005__p_is_tailor ?t) (d005__p_has ?t d005__c_needle) (d005__p_eggs_shot d005__c_brother_hunter))
    :effect (d005__p_eggs_sewn ?t)
  )

  (:action d005__a_shoot_dragon
    :parameters (?h - d005__t_entity)
    :precondition (and (d005__p_is_hunter ?h) (d005__p_has ?h d005__c_gun) (d005__p_entity_at d005__c_dragon d005__c_rock_sea))
    :effect (and (d005__p_dragon_dead) (d005__p_ship_broken) (not (d005__p_entity_at d005__c_dragon d005__c_rock_sea)))
  )

  (:action d005__a_shoot_eggs
    :parameters (?h - d005__t_entity)
    :precondition (and (d005__p_is_hunter ?h) (d005__p_has ?h d005__c_gun) (d005__p_eggs_fetched d005__c_brother_thief))
    :effect (d005__p_eggs_shot ?h)
  )

  (:action d005__a_steal_princess
    :parameters (?t - d005__t_entity)
    :precondition (and (d005__p_is_thief ?t) (d005__p_entity_at ?t d005__c_rock_sea) (d005__p_entity_at d005__c_princess d005__c_rock_sea) (d005__p_entity_at d005__c_dragon d005__c_rock_sea))
    :effect (and (d005__p_princess_rescued ?t) (d005__p_entity_at d005__c_princess d005__c_sea) (not (d005__p_entity_at d005__c_princess d005__c_rock_sea)))
  )

  (:action d005__a_swim_after_ship_break
    :parameters (?b - d005__t_entity)
    :precondition (d005__p_ship_broken)
    :effect (d005__p_entity_at ?b d005__c_sea)
  )

  (:action d006__a_abandon_children_in_forest
    :parameters (?father - d006__t_entity ?g - d006__t_entity ?h - d006__t_entity ?mother - d006__t_entity ?forest - d006__t_location)
    :effect (and (d006__p_at ?h ?forest) (d006__p_at ?g ?forest) (d006__p_lost ?h) (d006__p_lost ?g) (d006__p_bread_given ?h) (d006__p_bread_given ?g) (d006__p_fire_lit ?forest))
  )

  (:action d006__a_call_duck_for_crossing
    :parameters (?duck - d006__t_entity ?g - d006__t_entity ?h - d006__t_entity ?lake - d006__t_location)
    :precondition (and (d006__p_at ?h ?lake) (d006__p_at ?g ?lake) (d006__p_at ?duck ?lake))
    :effect (and (d006__p_duck_helped ?h ?duck) (d006__p_duck_helped ?g ?duck) (d006__p_crossed_lake ?h) (d006__p_crossed_lake ?g))
  )

  (:action d006__a_collect_treasure
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?pearl - d006__t_item ?precious_stone - d006__t_item ?cottage - d006__t_location)
    :precondition (and (d006__p_at ?h ?cottage) (d006__p_at ?g ?cottage))
    :effect (and (d006__p_has ?h ?pearl) (d006__p_has ?g ?precious_stone) (d006__p_collected ?h ?pearl) (d006__p_collected ?g ?precious_stone))
  )

  (:action d006__a_drop_breadcrumb_on_path
    :parameters (?h - d006__t_entity ?crumb - d006__t_item ?path_loc - d006__t_location)
    :precondition (and (d006__p_at ?h ?path_loc) (d006__p_has ?h ?crumb))
    :effect (and (d006__p_crumb_on_path ?path_loc) (not (d006__p_has ?h ?crumb)))
  )

  (:action d006__a_drop_pebble_on_path
    :parameters (?h - d006__t_entity ?peb - d006__t_item ?path_loc - d006__t_location)
    :precondition (and (d006__p_at ?h ?path_loc) (d006__p_has ?h ?peb))
    :effect (and (d006__p_pebble_on_path ?path_loc) (not (d006__p_has ?h ?peb)))
  )

  (:action d006__a_enter_witch_house
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?cottage - d006__t_location)
    :precondition (and (d006__p_at ?h ?cottage) (d006__p_at ?g ?cottage))
    :effect (and (d006__p_has ?h d006__c_cake) (d006__p_has ?g d006__c_sugar_window))
  )

  (:action d006__a_escape_from_stable
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?cottage - d006__t_location ?stable - d006__t_location)
    :precondition (and (d006__p_captured ?h) (d006__p_locked ?stable) (d006__p_at ?g ?cottage) (d006__p_at ?h ?stable))
    :effect (and (d006__p_at ?h ?cottage) (not (d006__p_at ?h ?stable)) (not (d006__p_locked ?stable)) (not (d006__p_captured ?h)))
  )

  (:action d006__a_follow_breadcrumbs_home
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?home - d006__t_location ?path_loc - d006__t_location)
    :precondition (and (d006__p_at ?h ?path_loc) (d006__p_at ?g ?path_loc))
    :effect (when (d006__p_crumb_on_path ?path_loc) (and (d006__p_at ?h ?home) (d006__p_at ?g ?home) (not (d006__p_at ?h ?path_loc)) (not (d006__p_at ?g ?path_loc)) (not (d006__p_lost ?h)) (not (d006__p_lost ?g))))
  )

  (:action d006__a_follow_pebbles_home
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?home - d006__t_location ?path_loc - d006__t_location)
    :precondition (and (d006__p_pebble_on_path ?path_loc) (d006__p_at ?h ?path_loc) (d006__p_at ?g ?path_loc))
    :effect (and (d006__p_at ?h ?home) (d006__p_at ?g ?home) (not (d006__p_at ?h ?path_loc)) (not (d006__p_at ?g ?path_loc)) (not (d006__p_lost ?h)) (not (d006__p_lost ?g)))
  )

  (:action d006__a_hear_bird_and_follow_to_witch_house
    :parameters (?bird - d006__t_entity ?g - d006__t_entity ?h - d006__t_entity ?branch - d006__t_location ?cottage - d006__t_location)
    :precondition (and (d006__p_at ?h ?branch) (d006__p_at ?g ?branch) (d006__p_bird_heard ?h ?branch) (d006__p_bird_heard ?g ?branch))
    :effect (and (d006__p_at ?h ?cottage) (d006__p_at ?g ?cottage) (not (d006__p_at ?h ?branch)) (not (d006__p_at ?g ?branch)))
  )

  (:action d006__a_leave_children_at_fire
    :parameters (?father - d006__t_entity ?g - d006__t_entity ?h - d006__t_entity ?mother - d006__t_entity ?forest - d006__t_location)
    :precondition (and (d006__p_at ?h ?forest) (d006__p_at ?g ?forest) (d006__p_fire_lit ?forest) (d006__p_bread_given ?h) (d006__p_bread_given ?g))
    :effect (and (d006__p_lost ?h) (d006__p_lost ?g))
  )

  (:action d006__a_push_witch_into_oven
    :parameters (?g - d006__t_entity ?witch - d006__t_entity ?oven - d006__t_item ?room - d006__t_location)
    :precondition (and (d006__p_at ?g ?room) (d006__p_at ?witch ?room))
    :effect (and (d006__p_dead ?witch) (not (d006__p_at ?witch ?room)))
  )

  (:action d006__a_return_home_and_reunite_with_father
    :parameters (?father - d006__t_entity ?g - d006__t_entity ?h - d006__t_entity ?father_house - d006__t_location)
    :precondition (and (d006__p_crossed_lake ?h) (d006__p_crossed_lake ?g) (d006__p_at ?father ?father_house))
    :effect (and (d006__p_at ?h ?father_house) (d006__p_at ?g ?father_house) (d006__p_reunited_with_father ?h) (d006__p_reunited_with_father ?g) (not (d006__p_lost ?h)) (not (d006__p_lost ?g)))
  )

  (:action d006__a_wander_forest_seeking_way_out
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?forest - d006__t_location)
    :precondition (and (d006__p_at ?h ?forest) (d006__p_at ?g ?forest))
    :effect (and (d006__p_lost ?h) (d006__p_lost ?g))
  )

  (:action d006__a_witch_captures_children
    :parameters (?g - d006__t_entity ?h - d006__t_entity ?witch - d006__t_entity ?cottage - d006__t_location ?stable - d006__t_location)
    :precondition (and (d006__p_at ?h ?cottage) (d006__p_at ?g ?cottage) (not (d006__p_locked ?stable)))
    :effect (and (d006__p_captured ?h) (d006__p_locked ?stable) (d006__p_at ?h ?stable) (not (d006__p_at ?h ?cottage)))
  )

  (:action d007__a_ask_giant_wife_for_breakfast
    :parameters (?j - d007__t_entity ?wife - d007__t_entity)
    :precondition (and (d007__p_at ?j d007__c_giant_castle) (d007__p_at ?wife d007__c_giant_castle))
    :effect (d007__p_has_breakfast ?j)
  )

  (:action d007__a_climb_beanstalk
    :parameters (?j - d007__t_entity)
    :precondition (and (d007__p_beanstalk_grown) (d007__p_at ?j d007__c_beanstalk))
    :effect (and (d007__p_at ?j d007__c_giant_castle) (not (d007__p_at ?j d007__c_beanstalk)))
  )

  (:action d007__a_cut_beanstalk
    :parameters (?giant - d007__t_entity ?mother - d007__t_entity ?axe - d007__t_item)
    :precondition (and (d007__p_intact d007__c_beanstalk) (d007__p_climbing_down ?giant))
    :effect (and (d007__p_dead ?giant) (not (d007__p_intact d007__c_beanstalk)))
  )

  (:action d007__a_grow_beanstalk
    :parameters (?beans - d007__t_item)
    :precondition (d007__p_planted ?beans)
    :effect (and (d007__p_beanstalk_grown) (d007__p_intact d007__c_beanstalk))
  )

  (:action d007__a_hide_in_kettle
    :parameters (?j - d007__t_entity ?kettle - d007__t_item)
    :precondition (and (d007__p_at ?j d007__c_giant_castle) (d007__p_empty ?kettle))
    :effect (and (d007__p_inside ?j ?kettle) (not (d007__p_at ?j d007__c_giant_castle)))
  )

  (:action d007__a_hide_in_oven
    :parameters (?j - d007__t_entity ?oven - d007__t_item)
    :precondition (d007__p_at ?j d007__c_giant_castle)
    :effect (and (d007__p_inside ?j ?oven) (not (d007__p_at ?j d007__c_giant_castle)))
  )

  (:action d007__a_plant_beans
    :parameters (?beans - d007__t_item ?loc - d007__t_location)
    :precondition (d007__p_at_item ?beans ?loc)
    :effect (and (d007__p_planted ?beans) (not (d007__p_at_item ?beans ?loc)))
  )

  (:action d007__a_return_down_beanstalk
    :parameters (?j - d007__t_entity)
    :precondition (d007__p_at ?j d007__c_giant_castle)
    :effect (and (d007__p_at ?j d007__c_cottage) (not (d007__p_at ?j d007__c_giant_castle)))
  )

  (:action d007__a_sell_cow_for_beans
    :parameters (?b - d007__t_entity ?cow - d007__t_entity ?j - d007__t_entity ?beans - d007__t_item ?l - d007__t_location)
    :precondition (and (d007__p_at ?j ?l) (d007__p_at ?cow ?l) (d007__p_offers ?b ?beans) (d007__p_at ?b ?l))
    :effect (and (d007__p_has ?j ?beans) (not (d007__p_offers ?b ?beans)) (not (d007__p_at_item ?beans ?l)))
  )

  (:action d007__a_steal_gold_bags
    :parameters (?j - d007__t_entity ?bag1 - d007__t_item ?bag2 - d007__t_item)
    :precondition (and (d007__p_asleep d007__c_giant) (d007__p_at_item ?bag1 d007__c_giant_castle) (d007__p_at_item ?bag2 d007__c_giant_castle))
    :effect (and (d007__p_has ?j ?bag1) (d007__p_has ?j ?bag2) (not (d007__p_at_item ?bag1 d007__c_giant_castle)) (not (d007__p_at_item ?bag2 d007__c_giant_castle)))
  )

  (:action d007__a_steal_harp
    :parameters (?giant - d007__t_entity ?j - d007__t_entity ?harp - d007__t_item)
    :precondition (and (d007__p_on ?harp d007__c_giant_castle) (d007__p_asleep ?giant))
    :effect (and (d007__p_has ?j ?harp) (not (d007__p_on ?harp d007__c_giant_castle)))
  )

  (:action d007__a_steal_hen
    :parameters (?giant - d007__t_entity ?j - d007__t_entity ?hen - d007__t_item)
    :precondition (and (d007__p_on ?hen d007__c_giant_castle) (d007__p_distracted ?giant))
    :effect (and (d007__p_has ?j ?hen) (not (d007__p_on ?hen d007__c_giant_castle)))
  )

  (:action d008__a_approach_cottage
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity ?cottage - d008__t_location ?forest - d008__t_location)
    :precondition (and (d008__p_sees_light ?cock) (d008__p_at ?donkey ?forest) (d008__p_at ?hound ?forest) (d008__p_at ?cat ?forest) (d008__p_at ?cock ?forest))
    :effect (and (d008__p_at ?donkey ?cottage) (d008__p_at ?hound ?cottage) (d008__p_at ?cat ?cottage) (d008__p_at ?cock ?cottage) (d008__p_moving_towards ?donkey ?cottage) (d008__p_moving_towards ?hound ?cottage) (d008__p_moving_towards ?cat ?cottage) (d008__p_moving_towards ?cock ?cottage) (not (d008__p_at ?donkey ?forest)) (not (d008__p_at ?hound ?forest)) (not (d008__p_at ?cat ?forest)) (not (d008__p_at ?cock ?forest)))
  )

  (:action d008__a_cat_agrees
    :parameters (?cat - d008__t_entity ?donkey - d008__t_entity)
    :precondition (d008__p_invited ?donkey ?cat)
    :effect (d008__p_agreed ?cat ?donkey)
  )

  (:action d008__a_cat_attack_messenger
    :parameters (?cat - d008__t_entity ?messenger - d008__t_entity)
    :precondition (and (d008__p_attempt_light ?messenger) (d008__p_at ?cat d008__c_hearth))
    :effect (d008__p_attacked ?cat ?messenger)
  )

  (:action d008__a_choose_sleep_spot
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?beam - d008__t_location ?hearth - d008__t_location)
    :precondition (and (d008__p_at ?cat ?hearth) (d008__p_at ?cock ?beam))
    :effect (and (d008__p_sleeping_at ?cat ?hearth) (d008__p_sleeping_at ?cock ?beam))
  )

  (:action d008__a_cock_agrees
    :parameters (?cock - d008__t_entity ?donkey - d008__t_entity)
    :precondition (d008__p_invited ?donkey ?cock)
    :effect (d008__p_agreed ?cock ?donkey)
  )

  (:action d008__a_cock_crow_alert
    :parameters (?cock - d008__t_entity)
    :precondition (d008__p_at ?cock d008__c_beam)
    :effect (d008__p_crowed ?cock)
  )

  (:action d008__a_dog_bite_messenger
    :parameters (?hound - d008__t_entity ?messenger - d008__t_entity ?cottage - d008__t_location)
    :precondition (and (d008__p_attempt_light ?messenger) (d008__p_at ?hound ?cottage))
    :effect (d008__p_bite ?hound ?messenger)
  )

  (:action d008__a_donkey_kick_messenger
    :parameters (?donkey - d008__t_entity ?messenger - d008__t_entity)
    :precondition (d008__p_attempt_light ?messenger)
    :effect (d008__p_kick ?donkey ?messenger)
  )

  (:action d008__a_eat_feast
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity ?cottage - d008__t_location)
    :precondition (and (d008__p_at ?donkey ?cottage) (d008__p_at ?hound ?cottage) (d008__p_at ?cat ?cottage) (d008__p_at ?cock ?cottage) (d008__p_window_shattered))
    :effect (and (d008__p_ate_all ?donkey) (d008__p_ate_all ?hound) (d008__p_ate_all ?cat) (d008__p_ate_all ?cock))
  )

  (:action d008__a_extinguish_light
    :parameters (?cottage - d008__t_location)
    :precondition (d008__p_light_on ?cottage)
    :effect (and (d008__p_light_off ?cottage) (not (d008__p_light_on ?cottage)))
  )

  (:action d008__a_hound_agrees
    :parameters (?donkey - d008__t_entity ?hound - d008__t_entity)
    :precondition (d008__p_invited ?donkey ?hound)
    :effect (d008__p_agreed ?hound ?donkey)
  )

  (:action d008__a_invite_cat
    :parameters (?cat - d008__t_entity ?donkey - d008__t_entity)
    :effect (d008__p_invited ?donkey ?cat)
  )

  (:action d008__a_invite_cock
    :parameters (?cock - d008__t_entity ?donkey - d008__t_entity ?loc - d008__t_location)
    :precondition (and (d008__p_at ?donkey ?loc) (d008__p_at ?cock ?loc))
    :effect (d008__p_invited ?donkey ?cock)
  )

  (:action d008__a_invite_hound
    :parameters (?donkey - d008__t_entity ?hound - d008__t_entity)
    :effect (d008__p_invited ?donkey ?hound)
  )

  (:action d008__a_messenger_attempt_light
    :parameters (?messenger - d008__t_entity ?cottage - d008__t_location)
    :precondition (d008__p_light_off ?cottage)
    :effect (d008__p_attempt_light ?messenger)
  )

  (:action d008__a_plan_scaring_robbers
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity ?cottage - d008__t_location)
    :precondition (and (d008__p_at ?donkey ?cottage) (d008__p_at ?hound ?cottage) (d008__p_at ?cat ?cottage) (d008__p_at ?cock ?cottage))
    :effect (and (d008__p_making_noise ?donkey) (d008__p_making_noise ?hound) (d008__p_making_noise ?cat) (d008__p_making_noise ?cock))
  )

  (:action d008__a_rest_in_forest
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity ?forest - d008__t_location)
    :precondition (and (d008__p_at ?donkey ?forest) (d008__p_at ?hound ?forest) (d008__p_at ?cat ?forest) (d008__p_at ?cock ?forest))
    :effect (and (d008__p_resting ?donkey) (d008__p_resting ?hound) (d008__p_resting ?cat) (d008__p_resting ?cock))
  )

  (:action d008__a_robbers_flee
    :parameters (?robber - d008__t_entity ?cottage - d008__t_location ?forest - d008__t_location)
    :precondition (and (d008__p_window_shattered) (d008__p_at ?robber ?cottage))
    :effect (and (d008__p_fled ?robber ?forest) (not (d008__p_at ?robber ?cottage)))
  )

  (:action d008__a_robbers_retreat
    :parameters (?robber - d008__t_entity ?cottage - d008__t_location)
    :precondition (d008__p_at ?robber ?cottage)
    :effect (and (d008__p_retreated ?robber) (not (d008__p_at ?robber ?cottage)))
  )

  (:action d008__a_run_away
    :parameters (?donkey - d008__t_entity ?from - d008__t_location ?to - d008__t_location)
    :precondition (d008__p_at ?donkey ?from)
    :effect (and (d008__p_at ?donkey ?to) (d008__p_moving_towards ?donkey ?to) (not (d008__p_at ?donkey ?from)))
  )

  (:action d008__a_signal_and_make_noise
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity)
    :precondition (and (d008__p_stacked_on ?hound ?donkey) (d008__p_stacked_on ?cat ?hound) (d008__p_stacked_on ?cock ?cat))
    :effect (and (d008__p_making_noise ?donkey) (d008__p_making_noise ?hound) (d008__p_making_noise ?cat) (d008__p_making_noise ?cock) (d008__p_window_shattered))
  )

  (:action d008__a_spot_light
    :parameters (?cock - d008__t_entity ?cottage - d008__t_location ?forest - d008__t_location)
    :precondition (and (d008__p_at ?cock ?forest) (d008__p_resting ?cock))
    :effect (and (d008__p_sees_light ?cock) (d008__p_moving_towards ?cock ?cottage))
  )

  (:action d008__a_stack_animals
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity)
    :precondition (and (d008__p_making_noise ?donkey) (d008__p_making_noise ?hound) (d008__p_making_noise ?cat) (d008__p_making_noise ?cock))
    :effect (and (d008__p_stacked_on ?hound ?donkey) (d008__p_stacked_on ?cat ?hound) (d008__p_stacked_on ?cock ?cat))
  )

  (:action d008__a_travel_together
    :parameters (?cat - d008__t_entity ?cock - d008__t_entity ?donkey - d008__t_entity ?hound - d008__t_entity ?from - d008__t_location ?to - d008__t_location)
    :precondition (and (d008__p_at ?donkey ?from) (d008__p_at ?hound ?from) (d008__p_at ?cat ?from) (d008__p_at ?cock ?from) (d008__p_agreed ?hound ?donkey) (d008__p_agreed ?cat ?donkey) (d008__p_agreed ?cock ?donkey))
    :effect (and (d008__p_at ?donkey ?to) (d008__p_at ?hound ?to) (d008__p_at ?cat ?to) (d008__p_at ?cock ?to) (d008__p_moving_towards ?donkey ?to) (d008__p_moving_towards ?hound ?to) (d008__p_moving_towards ?cat ?to) (d008__p_moving_towards ?cock ?to) (not (d008__p_at ?donkey ?from)) (not (d008__p_at ?hound ?from)) (not (d008__p_at ?cat ?from)) (not (d008__p_at ?cock ?from)))
  )

  (:action d009__a_approach_sun
    :parameters (?c - d009__t_entity)
    :precondition (and (d009__p_traveling ?c) (d009__p_avoid ?c d009__c_sun))
    :effect (d009__p_near ?c d009__c_sun)
  )

  (:action d009__a_arrest_meteor
    :parameters (?c - d009__t_entity ?m - d009__t_entity)
    :precondition (and (d009__p_traveling ?c) (d009__p_near ?c ?m))
    :effect (and (d009__p_arrested ?c ?m) (d009__p_detained ?m))
  )

  (:action d009__a_avoid_body
    :parameters (?b - d009__t_entity ?c - d009__t_entity)
    :precondition (and (d009__p_traveling ?c) (d009__p_avoid ?c ?b) (d009__p_near ?c ?b))
    :effect (not (d009__p_near ?c ?b))
  )

  (:action d009__a_burn_up
    :parameters (?c - d009__t_entity)
    :precondition (d009__p_near ?c d009__c_sun)
    :effect (and (d009__p_burned ?c) (not (d009__p_traveling ?c)) (not (d009__p_has_mission ?c)))
  )

  (:action d009__a_call_comet_forward
    :parameters (?c - d009__t_entity ?master - d009__t_entity)
    :precondition (and (d009__p_at ?c d009__c_courtyard) (d009__p_at ?master d009__c_courtyard))
    :effect (d009__p_summoned ?c)
  )

  (:action d009__a_cross_out_comet
    :parameters (?c - d009__t_entity)
    :precondition (d009__p_burned ?c)
    :effect (and (d009__p_crossed_out ?c) (not (d009__p_on_list ?c)))
  )

  (:action d009__a_deliver_meteor_to_bungo
    :parameters (?m - d009__t_entity)
    :precondition (d009__p_detained ?m)
    :effect (d009__p_delivered ?m d009__c_bungo)
  )

  (:action d009__a_give_order
    :parameters (?c - d009__t_entity ?master - d009__t_entity)
    :precondition (and (d009__p_at ?c d009__c_courtyard) (d009__p_at ?master d009__c_courtyard) (not (d009__p_has_mission ?c)))
    :effect (and (d009__p_has_mission ?c) (d009__p_left_turn_rule ?c) (d009__p_prohibit_speak ?c) (d009__p_avoid ?c d009__c_sun) (d009__p_avoid ?c d009__c_earth) (d009__p_avoid ?c d009__c_bungo))
  )

  (:action d009__a_prohibit_speaking_to_meteor
    :parameters (?c - d009__t_entity)
    :precondition (d009__p_has_mission ?c)
    :effect (d009__p_prohibit_speak ?c)
  )

  (:action d009__a_punish_meteor
    :parameters (?m - d009__t_entity)
    :precondition (d009__p_delivered ?m d009__c_bungo)
    :effect (d009__p_punished ?m)
  )

  (:action d009__a_speak_to_meteor
    :parameters (?c - d009__t_entity ?m - d009__t_entity)
    :precondition (and (d009__p_traveling ?c) (d009__p_prohibit_speak ?c) (d009__p_near ?c ?m))
    :effect (and (d009__p_speaks_to ?c ?m) (d009__p_rule_violation ?c))
  )

  (:action d009__a_start_travel
    :parameters (?c - d009__t_entity)
    :precondition (and (d009__p_has_mission ?c) (d009__p_gate_open))
    :effect (and (d009__p_traveling ?c) (not (d009__p_at ?c d009__c_courtyard)))
  )

  (:action d009__a_turn_left_on_meeting
    :parameters (?c - d009__t_entity ?other - d009__t_entity)
    :precondition (and (d009__p_traveling ?c) (d009__p_traveling ?other) (d009__p_left_turn_rule ?c) (d009__p_near ?c ?other))
    :effect (d009__p_left_turn_rule ?c)
  )

  (:action d010__a_ask_for_material
    :parameters (?m - d010__t_entity ?p - d010__t_entity ?i - d010__t_item)
    :precondition (and (d010__p_has_bundle ?m ?i) (d010__p_alive ?p) (d010__p_alive ?m))
    :effect (d010__p_material_requested ?p ?i)
  )

  (:action d010__a_build_house
    :parameters (?p - d010__t_entity ?i - d010__t_item ?h - d010__t_location)
    :precondition (and (d010__p_has ?p ?i) (d010__p_alive ?p) (d010__p_at ?p ?h))
    :effect (and (d010__p_house ?h ?i) (d010__p_house_intact ?h) (d010__p_door_closed ?h) (not (d010__p_has ?p ?i)))
  )

  (:action d010__a_pig_buys_butter_churn_and_hides
    :parameters (?p - d010__t_entity ?c - d010__t_item)
    :precondition (and (d010__p_at ?p d010__c_town_fair) (d010__p_alive ?p))
    :effect (and (d010__p_has ?p ?c) (d010__p_inside ?p ?c))
  )

  (:action d010__a_pig_collects_apples_and_escapes
    :parameters (?p - d010__t_entity ?a - d010__t_item ?l - d010__t_location)
    :precondition (and (d010__p_plan ?p ?l) (d010__p_alive ?p))
    :effect (and (d010__p_has ?p ?a) (d010__p_escaped ?p) (not (d010__p_plan ?p ?l)))
  )

  (:action d010__a_pig_collects_turnips
    :parameters (?p - d010__t_entity ?i - d010__t_item ?l - d010__t_location)
    :precondition (and (d010__p_plan ?p ?l) (d010__p_alive ?p))
    :effect (and (d010__p_has ?p ?i) (not (d010__p_plan ?p ?l)))
  )

  (:action d010__a_pig_prepares_boiling_pot_and_fire
    :parameters (?p - d010__t_entity ?fire - d010__t_item ?pot - d010__t_item ?h - d010__t_location)
    :precondition (and (d010__p_at ?p ?h) (d010__p_has ?p ?pot) (d010__p_has ?p ?fire) (d010__p_alive ?p))
    :effect (and (d010__p_over ?pot ?fire) (d010__p_under ?pot d010__c_chimney) (d010__p_boiling ?pot))
  )

  (:action d010__a_pig_refuses_entry
    :parameters (?w - d010__t_entity ?h - d010__t_location)
    :precondition (and (d010__p_entry_requested ?w ?h) (d010__p_alive ?w))
    :effect (and (d010__p_entry_denied ?w ?h) (not (d010__p_entry_requested ?w ?h)))
  )

  (:action d010__a_pig_rolls_churn_down_hill
    :parameters (?p - d010__t_entity ?c - d010__t_item)
    :precondition (and (d010__p_inside ?p ?c) (d010__p_alive ?p))
    :effect (and (d010__p_rolling ?c) (not (d010__p_inside ?p ?c)))
  )

  (:action d010__a_receive_material
    :parameters (?m - d010__t_entity ?p - d010__t_entity ?i - d010__t_item)
    :precondition (and (d010__p_material_requested ?p ?i) (d010__p_has_bundle ?m ?i) (d010__p_alive ?p) (d010__p_alive ?m))
    :effect (and (d010__p_has ?p ?i) (not (d010__p_material_requested ?p ?i)) (not (d010__p_has_bundle ?m ?i)))
  )

  (:action d010__a_send_sons_on_journey
    :parameters (?m - d010__t_entity ?p - d010__t_entity ?d - d010__t_location)
    :precondition (and (d010__p_at ?m d010__c_pig_home) (d010__p_at ?p d010__c_pig_home) (d010__p_alive ?m) (d010__p_alive ?p))
    :effect (and (d010__p_plan ?p ?d) (not (d010__p_at ?p d010__c_pig_home)))
  )

  (:action d010__a_wolf_attempts_chimney_entry
    :parameters (?w - d010__t_entity ?h - d010__t_location)
    :precondition (and (d010__p_house_intact ?h) (d010__p_alive ?w))
    :effect (d010__p_entry_requested ?w ?h)
  )

  (:action d010__a_wolf_blows_house_down
    :parameters (?w - d010__t_entity ?i - d010__t_item ?h - d010__t_location)
    :precondition (and (d010__p_huffed ?w) (d010__p_puffed ?w) (d010__p_house ?h ?i) (d010__p_door_closed ?h) (d010__p_alive ?w))
    :effect (and (d010__p_house_destroyed ?h) (not (d010__p_house_intact ?h)) (not (d010__p_door_closed ?h)))
  )

  (:action d010__a_wolf_eats_pig
    :parameters (?p - d010__t_entity ?w - d010__t_entity ?h - d010__t_location)
    :precondition (and (d010__p_house_destroyed ?h) (d010__p_at ?p ?h) (d010__p_alive ?p) (d010__p_alive ?w))
    :effect (and (d010__p_dead ?p) (not (d010__p_alive ?p)) (not (d010__p_at ?p ?h)))
  )

  (:action d010__a_wolf_fails_to_blow_house
    :parameters (?w - d010__t_entity ?i - d010__t_item ?h - d010__t_location)
    :precondition (and (d010__p_huffed ?w) (d010__p_puffed ?w) (d010__p_house ?h ?i) (d010__p_alive ?w))
    :effect (d010__p_house_intact ?h)
  )

  (:action d010__a_wolf_falls_into_pot_and_is_boiled
    :parameters (?w - d010__t_entity ?pot - d010__t_item)
    :precondition (and (d010__p_boiling ?pot) (d010__p_alive ?w))
    :effect (and (d010__p_dead ?w) (not (d010__p_alive ?w)))
  )

  (:action d010__a_wolf_flees_from_rolling_object
    :parameters (?w - d010__t_entity ?c - d010__t_item)
    :precondition (and (d010__p_rolling ?c) (d010__p_alive ?w))
    :effect (d010__p_escaped ?w)
  )

  (:action d010__a_wolf_huff_and_puff
    :parameters (?w - d010__t_entity ?h - d010__t_location)
    :precondition (and (d010__p_entry_denied ?w ?h) (d010__p_alive ?w))
    :effect (and (d010__p_huffed ?w) (d010__p_puffed ?w))
  )

  (:action d010__a_wolf_knocks_and_requests_entry
    :parameters (?w - d010__t_entity ?h - d010__t_location)
    :precondition (and (d010__p_at ?w ?h) (d010__p_door_closed ?h) (d010__p_alive ?w))
    :effect (d010__p_entry_requested ?w ?h)
  )

  (:action d010__a_wolf_promises_apple_orchard
    :parameters (?p - d010__t_entity ?w - d010__t_entity ?l - d010__t_location)
    :precondition (and (d010__p_alive ?w) (d010__p_alive ?p))
    :effect (d010__p_plan ?p ?l)
  )

  (:action d010__a_wolf_promises_fair_trip
    :parameters (?p - d010__t_entity ?w - d010__t_entity ?l - d010__t_location)
    :precondition (and (d010__p_alive ?w) (d010__p_alive ?p))
    :effect (d010__p_plan ?p ?l)
  )

  (:action d010__a_wolf_promises_turnip_field
    :parameters (?p - d010__t_entity ?w - d010__t_entity ?l - d010__t_location)
    :precondition (and (d010__p_alive ?w) (d010__p_alive ?p))
    :effect (d010__p_plan ?p ?l)
  )

  (:action d011__a_buy_boots
    :parameters (?jack - d011__t_entity ?puss - d011__t_entity ?boots - d011__t_item)
    :precondition (not (d011__p_has ?puss ?boots))
    :effect (d011__p_has ?puss ?boots)
  )

  (:action d011__a_cat_call_for_help
    :parameters (?jack - d011__t_entity ?king - d011__t_entity ?puss - d011__t_entity)
    :precondition (d011__p_drowning ?jack)
    :effect (and (d011__p_rescued_by ?jack ?king) (not (d011__p_drowning ?jack)))
  )

  (:action d011__a_cat_catch_rabbits
    :parameters (?puss - d011__t_entity ?bag - d011__t_item ?rabbit - d011__t_item ?warren - d011__t_location)
    :precondition (and (d011__p_has ?puss ?bag) (d011__p_at_item ?rabbit ?warren) (not (d011__p_contains ?bag ?rabbit)))
    :effect (and (d011__p_contains ?bag ?rabbit) (not (d011__p_at_item ?rabbit ?warren)))
  )

  (:action d011__a_cat_deliver_gifts_to_king
    :parameters (?king - d011__t_entity ?puss - d011__t_entity ?bag - d011__t_item ?rabbit - d011__t_item ?palace - d011__t_location)
    :precondition (and (d011__p_contains ?bag ?rabbit) (d011__p_at ?puss ?palace))
    :effect (and (d011__p_gift_delivered ?puss ?king ?rabbit) (not (d011__p_contains ?bag ?rabbit)))
  )

  (:action d011__a_cat_disentchant_prisoners
    :parameters (?person - d011__t_entity ?puss - d011__t_entity)
    :precondition (d011__p_alive ?puss)
    :effect (d011__p_promised_to_serve ?person d011__c_jack)
  )

  (:action d011__a_cat_eat_mouse
    :parameters (?mouse - d011__t_entity ?ogre - d011__t_entity ?puss - d011__t_entity)
    :precondition (d011__p_transformed_into ?ogre ?mouse)
    :effect (not (d011__p_transformed_into ?ogre ?mouse))
  )

  (:action d011__a_cat_ogre_transform_lion
    :parameters (?lion - d011__t_entity ?ogre - d011__t_entity ?puss - d011__t_entity)
    :precondition (and (d011__p_at ?puss d011__c_ogre_castle) (d011__p_alive ?ogre))
    :effect (d011__p_transformed_into ?ogre ?lion)
  )

  (:action d011__a_cat_ogre_transform_mouse
    :parameters (?mouse - d011__t_entity ?ogre - d011__t_entity ?puss - d011__t_entity)
    :precondition (d011__p_alive ?ogre)
    :effect (d011__p_transformed_into ?ogre ?mouse)
  )

  (:action d011__a_cat_open_castle_gates
    :parameters (?king - d011__t_entity ?puss - d011__t_entity ?castle - d011__t_location)
    :precondition (d011__p_at ?king ?castle)
    :effect (d011__p_gate_open ?castle)
  )

  (:action d011__a_cat_persuade_master_to_bathe
    :parameters (?jack - d011__t_entity ?puss - d011__t_entity ?river - d011__t_location)
    :precondition (and (d011__p_at ?jack ?river) (d011__p_at ?puss ?river))
    :effect (d011__p_drowning ?jack)
  )

  (:action d011__a_give_bag_to_cat
    :parameters (?jack - d011__t_entity ?puss - d011__t_entity ?bag - d011__t_item)
    :precondition (and (d011__p_has ?jack ?bag) (not (d011__p_has ?puss ?bag)))
    :effect (and (d011__p_has ?puss ?bag) (not (d011__p_has ?jack ?bag)))
  )

  (:action d011__a_king_send_groom_fetch_suit
    :parameters (?groom - d011__t_entity ?king - d011__t_entity ?suit - d011__t_item ?wardrobe - d011__t_location)
    :precondition (d011__p_at_item ?suit ?wardrobe)
    :effect (and (d011__p_has ?groom ?suit) (not (d011__p_at_item ?suit ?wardrobe)))
  )

  (:action d011__a_master_marry_princess
    :parameters (?jack - d011__t_entity ?princess - d011__t_entity)
    :precondition (and (not (d011__p_married ?jack ?princess)) (d011__p_at ?jack d011__c_palace))
    :effect (d011__p_married ?jack ?princess)
  )

  (:action d011__a_master_wear_suit
    :parameters (?jack - d011__t_entity ?suit - d011__t_item)
    :precondition (d011__p_has ?jack ?suit)
    :effect (and (d011__p_wearing ?jack ?suit) (not (d011__p_has ?jack ?suit)))
  )

  (:action d012__a_arrive_at_marble_palace
    :parameters (?p - d012__t_entity)
    :precondition (d012__p_at ?p d012__c_oak_tree)
    :effect (and (d012__p_at ?p d012__c_palace) (not (d012__p_at ?p d012__c_oak_tree)))
  )

  (:action d012__a_encounter_impostor_king
    :parameters (?i - d012__t_entity ?p - d012__t_entity)
    :precondition (and (d012__p_at ?p d012__c_city) (d012__p_at ?i d012__c_market_place))
    :effect (and (d012__p_at ?p d012__c_market_place) (not (d012__p_at ?p d012__c_city)))
  )

  (:action d012__a_encounter_robbers_in_forest
    :parameters (?p - d012__t_entity)
    :precondition (d012__p_at ?p d012__c_forest)
    :effect (and (d012__p_at ?p d012__c_oak_tree) (not (d012__p_at ?p d012__c_forest)))
  )

  (:action d012__a_king_proposes_marriage
    :parameters (?k - d012__t_entity ?p - d012__t_entity)
    :precondition (and (d012__p_at ?p d012__c_palace) (d012__p_at ?k d012__c_palace))
    :effect (d012__p_married ?p ?k)
  )

  (:action d012__a_king_requests_information_and_gifts
    :parameters (?k - d012__t_entity ?p - d012__t_entity ?r - d012__t_item ?s - d012__t_item)
    :precondition (and (d012__p_at ?p d012__c_palace) (d012__p_has ?p ?r) (d012__p_has ?p ?s) (d012__p_at ?k d012__c_palace))
    :effect (and (d012__p_has ?k ?r) (d012__p_has ?k ?s) (not (d012__p_has ?p ?r)) (not (d012__p_has ?p ?s)))
  )

  (:action d012__a_princess_accepts_with_heart
    :parameters (?k - d012__t_entity ?p - d012__t_entity)
    :precondition (and (d012__p_married ?p ?k) (not (d012__p_with_all_my_heart_spoken)))
    :effect (d012__p_with_all_my_heart_spoken)
  )

  (:action d012__a_receive_rubies_from_impostor
    :parameters (?i - d012__t_entity ?p - d012__t_entity ?r - d012__t_item)
    :precondition (and (d012__p_price_of_butter_spoken) (d012__p_at ?p d012__c_market_place) (d012__p_has ?i ?r))
    :effect (and (d012__p_has ?p ?r) (not (d012__p_has ?i ?r)))
  )

  (:action d012__a_receive_sapphires_from_robber_chief
    :parameters (?c - d012__t_entity ?p - d012__t_entity ?s - d012__t_item)
    :precondition (and (d012__p_grandmother_mangle_spoken) (d012__p_at ?p d012__c_oak_tree) (d012__p_has ?c ?s))
    :effect (and (d012__p_has ?p ?s) (not (d012__p_has ?c ?s)))
  )

  (:action d012__a_run_away_from_palace
    :parameters (?p - d012__t_entity)
    :precondition (d012__p_at ?p d012__c_back_stairs)
    :effect (and (d012__p_at ?p d012__c_city) (not (d012__p_at ?p d012__c_back_stairs)))
  )

  (:action d012__a_suitors_retire_due_to_phrase
    :parameters (?s - d012__t_entity)
    :precondition (and (d012__p_grandmother_mangle_spoken) (d012__p_at ?s d012__c_palace))
    :effect (not (d012__p_married ?s d012__c_princess))
  )

  (:action d012__a_utter_phrase_grandmother_mangle
    :parameters (?p - d012__t_entity)
    :precondition (and (d012__p_at ?p d012__c_oak_tree) (not (d012__p_grandmother_mangle_spoken)))
    :effect (d012__p_grandmother_mangle_spoken)
  )

  (:action d012__a_utter_phrase_price_of_butter
    :parameters (?p - d012__t_entity)
    :precondition (and (d012__p_at ?p d012__c_market_place) (not (d012__p_price_of_butter_spoken)))
    :effect (d012__p_price_of_butter_spoken)
  )

  (:action d013__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - d013__t_entity ?apple - d013__t_item)
    :precondition (and (d013__p_dead ?c) (d013__p_poisoned ?apple))
    :effect (and (d013__p_alive ?c) (not (d013__p_dead ?c)) (not (d013__p_poisoned ?apple)))
  )

  (:action d013__a_child_is_born_and_queen_dies
    :parameters (?c - d013__t_entity ?q - d013__t_entity)
    :precondition (and (not (d013__p_alive ?c)) (d013__p_alive ?q))
    :effect (and (d013__p_alive ?c) (d013__p_dead ?q) (not (d013__p_alive ?q)))
  )

  (:action d013__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - d013__t_entity ?d - d013__t_entity ?lace - d013__t_item)
    :precondition (and (d013__p_laced ?c ?lace) (d013__p_dead ?c))
    :effect (and (d013__p_alive ?c) (d013__p_awake ?c) (not (d013__p_laced ?c ?lace)) (not (d013__p_dead ?c)))
  )

  (:action d013__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - d013__t_entity ?d - d013__t_entity)
    :precondition (and (d013__p_alive ?d) (d013__p_alive ?c) (d013__p_sleeping ?c))
    :effect (and (d013__p_awake ?c) (not (d013__p_sleeping ?c)))
  )

  (:action d013__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - d013__t_entity ?d - d013__t_entity ?coffin - d013__t_item)
    :precondition (d013__p_dead ?c)
    :effect (and (d013__p_in_coffin ?c) (d013__p_has ?d ?coffin))
  )

  (:action d013__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - d013__t_entity ?d - d013__t_entity ?comb - d013__t_item)
    :precondition (and (d013__p_dead ?c) (d013__p_poisoned ?comb) (d013__p_has ?d ?comb))
    :effect (and (d013__p_alive ?c) (not (d013__p_dead ?c)) (not (d013__p_poisoned ?comb)))
  )

  (:action d013__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - d013__t_entity ?d - d013__t_entity)
    :precondition (and (d013__p_alive ?d) (d013__p_sleeping ?c))
    :effect (d013__p_awake ?d)
  )

  (:action d013__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - d013__t_entity ?c - d013__t_entity ?h - d013__t_entity ?heart - d013__t_item)
    :precondition (and (d013__p_alive ?h) (d013__p_alive ?c) (d013__p_alive ?b))
    :effect (and (d013__p_has ?h ?heart) (d013__p_dead ?b))
  )

  (:action d013__a_king_marries_stepmother
    :parameters (?k - d013__t_entity ?s - d013__t_entity)
    :precondition (and (d013__p_alive ?k) (d013__p_alive ?s))
    :effect (d013__p_fair ?s)
  )

  (:action d013__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - d013__t_entity ?p - d013__t_entity ?coffin - d013__t_item ?mountain - d013__t_location)
    :precondition (and (d013__p_in_coffin ?c) (d013__p_alive ?p))
    :effect (d013__p_at_item ?coffin ?mountain)
  )

  (:action d013__a_prince_marries_snow_white
    :parameters (?c - d013__t_entity ?p - d013__t_entity)
    :precondition (and (d013__p_alive ?p) (d013__p_alive ?c))
    :effect (d013__p_fair ?p)
  )

  (:action d013__a_queen_pricks_finger
    :parameters (?q - d013__t_entity ?blood - d013__t_item ?needle - d013__t_item)
    :precondition (and (d013__p_alive ?q) (d013__p_has ?q ?needle))
    :effect (d013__p_has ?q ?blood)
  )

  (:action d013__a_queen_sews_at_window
    :parameters (?q - d013__t_entity ?l - d013__t_location)
    :precondition (and (d013__p_alive ?q) (d013__p_at ?q ?l))
    :effect (d013__p_has ?q d013__c_needle)
  )

  (:action d013__a_queen_wishes_child_white_red_black
    :parameters (?c - d013__t_entity ?q - d013__t_entity)
    :precondition (d013__p_alive ?q)
    :effect (d013__p_fair ?c)
  )

  (:action d013__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - d013__t_entity ?apple - d013__t_item)
    :precondition (and (d013__p_poisoned ?apple) (d013__p_alive ?c))
    :effect (and (d013__p_dead ?c) (not (d013__p_alive ?c)))
  )

  (:action d013__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - d013__t_entity ?mug - d013__t_item ?plate - d013__t_item)
    :precondition (d013__p_alive ?c)
    :effect (and (d013__p_has ?c ?plate) (d013__p_has ?c ?mug))
  )

  (:action d013__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - d013__t_entity ?cottage - d013__t_location)
    :precondition (d013__p_alive ?c)
    :effect (d013__p_at ?c ?cottage)
  )

  (:action d013__a_snow_white_flees_into_forest
    :parameters (?c - d013__t_entity ?f - d013__t_location)
    :precondition (d013__p_alive ?c)
    :effect (d013__p_at ?c ?f)
  )

  (:action d013__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - d013__t_entity ?bed - d013__t_item)
    :precondition (d013__p_alive ?c)
    :effect (d013__p_sleeping ?c)
  )

  (:action d013__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - d013__t_entity ?g - d013__t_item)
    :precondition (and (d013__p_alive ?s) (d013__p_has ?s ?g))
    :effect (d013__p_fairest ?s)
  )

  (:action d013__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - d013__t_entity ?slippers - d013__t_item)
    :precondition (d013__p_alive ?s)
    :effect (and (d013__p_wearing ?s ?slippers) (d013__p_dead ?s) (not (d013__p_alive ?s)))
  )

  (:action d013__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - d013__t_entity ?s - d013__t_entity)
    :precondition (and (d013__p_fairest ?c) (d013__p_fair ?c) (d013__p_alive ?s))
    :effect (d013__p_envious ?s)
  )

  (:action d013__a_stepmother_comb_poison_snow_white
    :parameters (?c - d013__t_entity ?s - d013__t_entity ?comb - d013__t_item)
    :precondition (and (d013__p_has ?s ?comb) (d013__p_poisoned ?comb) (d013__p_alive ?c))
    :effect (and (d013__p_dead ?c) (not (d013__p_alive ?c)))
  )

  (:action d013__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - d013__t_entity ?s - d013__t_entity ?cottage - d013__t_location)
    :precondition (d013__p_alive ?s)
    :effect (and (d013__p_disguised_as ?s ?old_woman) (d013__p_visited ?s ?cottage))
  )

  (:action d013__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - d013__t_entity ?heart - d013__t_item)
    :precondition (d013__p_has ?s ?heart)
    :effect (not (d013__p_has ?s ?heart))
  )

  (:action d013__a_stepmother_laces_snow_white_tightly
    :parameters (?c - d013__t_entity ?s - d013__t_entity ?lace - d013__t_item)
    :precondition (and (d013__p_alive ?c) (d013__p_has ?c ?lace))
    :effect (and (d013__p_laced ?c ?lace) (d013__p_dead ?c) (not (d013__p_alive ?c)) (not (d013__p_sleeping ?c)))
  )

  (:action d013__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - d013__t_entity ?apple - d013__t_item ?cottage - d013__t_location)
    :precondition (d013__p_alive ?s)
    :effect (and (d013__p_poisoned ?apple) (d013__p_has ?s ?apple) (d013__p_visited ?s ?cottage))
  )

  (:action d013__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - d013__t_entity ?comb - d013__t_item ?cottage - d013__t_location)
    :precondition (d013__p_alive ?s)
    :effect (and (d013__p_poisoned ?comb) (d013__p_has ?s ?comb) (d013__p_visited ?s ?cottage))
  )

  (:action d013__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - d013__t_entity ?h - d013__t_entity ?s - d013__t_entity)
    :precondition (and (d013__p_envious ?s) (d013__p_alive ?h) (d013__p_alive ?c))
    :effect (d013__p_fair ?s)
  )

  (:action d014__a_claim_queenhood
    :parameters (?m - d014__t_entity)
    :precondition (or (d014__p_soup_effect_created ?m) (d014__p_king_tail_stirred))
    :effect (d014__p_is_queen ?m)
  )

  (:action d014__a_escape_jail
    :parameters (?m - d014__t_entity)
    :precondition (d014__p_captured ?m)
    :effect (and (d014__p_escaped ?m) (not (d014__p_captured ?m)) (not (d014__p_in_cage ?m)))
  )

  (:action d014__a_give_skewer_to_elves
    :parameters (?elf - d014__t_entity ?m - d014__t_entity)
    :precondition (d014__p_holds ?m d014__c_sausage_skewer)
    :effect (and (d014__p_holds ?elf d014__c_sausage_skewer) (not (d014__p_holds ?m d014__c_sausage_skewer)))
  )

  (:action d014__a_learn_wisdom_from_ants
    :parameters (?m - d014__t_entity ?ant_loc - d014__t_location)
    :precondition (d014__p_at ?m ?ant_loc)
    :effect (d014__p_has_understanding ?m)
  )

  (:action d014__a_prepare_soup_by_elf_effect
    :parameters (?m - d014__t_entity)
    :precondition (and (d014__p_holds ?m d014__c_sausage_skewer) (d014__p_anointed d014__c_sausage_skewer) (d014__p_at ?m d014__c_kitchen))
    :effect (d014__p_soup_effect_created ?m)
  )

  (:action d014__a_prepare_soup_by_king_tail
    :parameters (?k - d014__t_entity)
    :precondition (d014__p_at d014__c_mouse_king d014__c_kitchen)
    :effect (d014__p_king_tail_stirred)
  )

  (:action d014__a_prepare_soup_by_poet_imagination
    :parameters (?m - d014__t_entity)
    :precondition (and (d014__p_has_understanding ?m) (d014__p_has_imagination ?m) (d014__p_has_feeling ?m))
    :effect (and (d014__p_soup_effect_created ?m) (d014__p_is_poet ?m))
  )

  (:action d014__a_read_and_digest_books
    :parameters (?m - d014__t_entity ?lib - d014__t_location)
    :precondition (d014__p_at ?m d014__c_library)
    :effect (d014__p_has_feeling ?m)
  )

  (:action d014__a_receive_anointed_skewer
    :parameters (?elf - d014__t_entity ?m - d014__t_entity ?v - d014__t_item)
    :precondition (and (d014__p_holds ?m d014__c_sausage_skewer) (d014__p_holds ?elf d014__c_violet))
    :effect (d014__p_anointed d014__c_sausage_skewer)
  )

  (:action d014__a_receive_feather
    :parameters (?dryad - d014__t_entity ?m - d014__t_entity ?ph - d014__t_entity ?feather - d014__t_item ?loc - d014__t_location)
    :precondition (and (d014__p_at ?m ?loc) (d014__p_at ?dryad ?loc) (d014__p_at ?ph ?loc) (d014__p_holds ?dryad ?feather))
    :effect (and (d014__p_holds ?m ?feather) (d014__p_has_imagination ?m))
  )

  (:action d014__a_run_in_cage
    :parameters (?m - d014__t_entity)
    :precondition (d014__p_captured ?m)
    :effect (d014__p_in_cage ?m)
  )

  (:action d014__a_travel_to
    :parameters (?m - d014__t_entity ?dest - d014__t_location ?orig - d014__t_location)
    :precondition (and (d014__p_at ?m ?orig) (d014__p_holds ?m d014__c_sausage_skewer))
    :effect (and (d014__p_at ?m ?dest) (not (d014__p_at ?m ?orig)))
  )

  (:action d015__a_accept_woe_as_burden
    :parameters (?rich - d015__t_entity ?woe - d015__t_entity)
    :precondition (d015__p_woe_on_shoulder ?woe ?rich)
    :effect (d015__p_has_fatigue ?rich)
  )

  (:action d015__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - d015__t_entity ?woe - d015__t_entity ?loc - d015__t_location)
    :precondition (and (d015__p_at ?poor ?loc) (d015__p_at ?woe ?loc) (d015__p_has_fatigue ?poor))
    :effect (d015__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d015__a_bow_to_guests
    :parameters (?poor - d015__t_entity ?loc - d015__t_location)
    :precondition (and (d015__p_at ?poor ?loc) (exists (?guest - d015__t_entity) (d015__p_guest_present ?guest ?loc)))
    :effect (d015__p_bowed ?poor ?loc)
  )

  (:action d015__a_encounter_bitter_woe
    :parameters (?poor - d015__t_entity ?woe - d015__t_entity ?loc - d015__t_location)
    :precondition (and (d015__p_at ?poor ?loc) (d015__p_at ?woe ?loc))
    :effect (d015__p_has_fatigue ?poor)
  )

  (:action d015__a_hide_woe_under_stone
    :parameters (?poor - d015__t_entity ?woe - d015__t_entity ?stone - d015__t_item ?loc - d015__t_location)
    :precondition (and (d015__p_woe_on_shoulder ?woe ?poor) (d015__p_stone_at ?stone ?loc))
    :effect (and (d015__p_trapped ?woe) (d015__p_stone_at ?stone ?loc) (not (d015__p_woe_on_shoulder ?woe ?poor)) (not (d015__p_stone_moved ?stone)))
  )

  (:action d015__a_invite_rich_brother_to_feast
    :parameters (?poor - d015__t_entity ?rich - d015__t_entity ?loc - d015__t_location)
    :precondition (d015__p_at ?poor ?loc)
    :effect (and (d015__p_invitation_sent ?poor ?rich) (d015__p_invited ?rich ?poor))
  )

  (:action d015__a_make_sign_of_cross
    :parameters (?poor - d015__t_entity ?woe - d015__t_entity ?loc - d015__t_location)
    :precondition (and (d015__p_at ?poor ?loc) (d015__p_at ?woe ?loc))
    :effect (d015__p_has_fatigue ?poor)
  )

  (:action d015__a_move_heavy_stone
    :parameters (?carrier - d015__t_entity ?stone - d015__t_item ?loc - d015__t_location)
    :precondition (and (d015__p_stone_at ?stone ?loc) (d015__p_has_strength ?carrier))
    :effect (and (d015__p_stone_moved ?stone) (not (d015__p_stone_at ?stone ?loc)))
  )

  (:action d015__a_perform_work_for_rich_brother
    :parameters (?employer - d015__t_entity ?worker - d015__t_entity)
    :precondition (and (d015__p_employed ?worker ?employer) (d015__p_has_strength ?worker))
    :effect (and (d015__p_work_done ?worker ?employer) (d015__p_has_fatigue ?worker))
  )

  (:action d015__a_receive_payment
    :parameters (?employer - d015__t_entity ?worker - d015__t_entity ?bread - d015__t_item ?money - d015__t_item)
    :precondition (and (d015__p_work_done ?worker ?employer) (d015__p_has ?employer ?money) (d015__p_has ?employer ?bread))
    :effect (and (d015__p_has ?worker ?money) (d015__p_has ?worker ?bread) (not (d015__p_has ?employer ?money)) (not (d015__p_has ?employer ?bread)))
  )

  (:action d015__a_request_help_from_rich_brother
    :parameters (?poor - d015__t_entity ?rich - d015__t_entity)
    :precondition (and (d015__p_need_help ?poor) (d015__p_rich ?rich))
    :effect (and (d015__p_employed ?poor ?rich) (not (d015__p_need_help ?poor)))
  )

  (:action d015__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - d015__t_entity ?stone - d015__t_item ?loc - d015__t_location)
    :precondition (and (d015__p_stone_at ?stone ?loc) (d015__p_rich ?rich))
    :effect (and (d015__p_stone_moved ?stone) (d015__p_woe_on_shoulder d015__c_bitter_woe ?rich) (not (d015__p_stone_at ?stone ?loc)))
  )

  (:action d015__a_sing_cheerful_song
    :parameters (?poor - d015__t_entity ?loc - d015__t_location)
    :precondition (d015__p_at ?poor ?loc)
    :effect (d015__p_singing ?poor)
  )

  (:action d015__a_spend_money_on_drink
    :parameters (?poor - d015__t_entity ?money - d015__t_item ?wine - d015__t_item ?kabak - d015__t_location)
    :precondition (and (d015__p_has ?poor ?money) (d015__p_at ?poor ?kabak))
    :effect (and (d015__p_has ?poor ?wine) (d015__p_drunk ?poor) (not (d015__p_has ?poor ?money)))
  )

  (:action d015__a_stay_for_banquet
    :parameters (?guest - d015__t_entity ?host - d015__t_entity ?loc - d015__t_location)
    :precondition (and (d015__p_at ?guest ?loc) (d015__p_at ?host ?loc) (d015__p_banquet_at ?loc) (d015__p_invited ?guest ?host))
    :effect (d015__p_guest_present ?guest ?loc)
  )

  (:action d015__a_take_gold_pot_and_hide
    :parameters (?poor - d015__t_entity ?gold - d015__t_item ?loc - d015__t_location)
    :precondition (and (d015__p_gold_at ?gold ?loc) (d015__p_at ?poor ?loc))
    :effect (and (d015__p_has ?poor ?gold) (d015__p_concealed ?gold) (not (d015__p_gold_at ?gold ?loc)))
  )

  (:action d015__a_trade_assets_for_money
    :parameters (?poor - d015__t_entity ?asset - d015__t_item ?money - d015__t_item)
    :precondition (d015__p_has ?poor ?asset)
    :effect (and (d015__p_has ?poor ?money) (not (d015__p_has ?poor ?asset)))
  )
)
