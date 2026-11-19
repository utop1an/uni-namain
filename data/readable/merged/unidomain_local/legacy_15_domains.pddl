(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :disjunctive-preconditions :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ant_queen ass audience badger bird bitter_woe boar brother_astronomer brother_hunter brother_tailor brother_thief brown_hen buffoon bungo butcher captain cat chaffinch Chicken-licken children coachman cock Cock-lock comet_master countryman dove dragon Drake-lake dryad duck Duck-luck dwarf1 dwarf2 dwarf3 dwarf4 dwarf5 dwarf6 dwarf7 earth eldest_son elf_chief fairy_maiden fairy_queen farmer father father_king first_traveler_mouse fourth_traveler_mouse Fox-lox friend Gander-lander giant giant_dog giant_wife gnome Goose-loose grandmother grandmotherkin grettel groom hansel Hen-len hound huntsman impostor_butterman jack jack_mother jailer jailer_granddaughter King king king_at_palace lady_of_court little_pig long_tail_45 man man_bricks man_furze man_straw mentor_astronomer mentor_hunter mentor_tailor mentor_thief messenger meteor meteor_keeper milky_white miller mother mother_pig mothereen mouse_king no1_express nora oak_dryad ogre old_lady_mouse old_owl owl phantaesus pig1 pig2 pig3 poor_brother priest prince princess puss queen raven rich_brother rich_nobleman robber robber_chief second_son second_traveler_mouse short_tail_73 showman snow_white squire sun third_traveler_mouse tinker Turkey-lurkey watchman wife witch wolf young_lady_mouse - entity
    Acorn apple axe bag bag_of_rubies bag_of_sapphires bed blood_drop boar_heart boat boots box bread_piece bricks brushwood butter_churn cake candle cattle chalk cloak coffin comb copecks_25 copper_coins crape_skewer crown crumb drinks eggs fire fork furze_bundle gold_bag_1 gold_bag_2 gold_pot gold_star golden_harp golden_letter grove gun hare harrow honey iron_slippers kettle kettledrums key knife lace lantern loaf_bread looking_glass lute magic_beans maypole meat milk mill mortar mug naug_ass needle nut oak_tree_club oven pack pancake partridge pearl pebble pellet planks plate plow pot_of_water precious_stone rabbit red_hot_shoes sack salt sausage_skewer sceptre ship silver_salver Sky slate sledge spoon sticks stone straw straw_bundle sugar_window suit table teakettle telega telescope temple_treasure trowel turnips_load violet wine - item
    back_door back_stairs beam beanstalk beech_tree bench big_house branch bremen brick_house castle castle_road chimney city comet_house corridor cottage courtyard cross_way dead_tree door fairyland father_house field_of_corn field_of_wheat forest FoxHole furze_house garden gate giant_castle hearth hill house izba jack_np_kettle jack_np_oven jhosiu kabak kingdom kitchen lake large_town library market market_place morinji mountain naug_ship new_home north oak_forest oak_tree ogre_castle palace path pig_home platform pond river road_to_bremen robbers_cottage rock_sea roof room royal_wardrobe sea spring squire_orchard stable_location stairs straw_house stream theater tight_rope town_fair town_gate treasure_pit tree turnip_field village warren well window Wood yard - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (airborne ?i - item)
    (alive ?e - entity)
    (anointed ?i - item)
    (applause_given ?audience - entity ?performer - entity)
    (arrested ?c - entity ?m - entity)
    (asleep ?e - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (avoid ?c - entity ?b - entity)
    (awake ?e - entity)
    (badger_form ?i - item)
    (banquet_at ?l - location)
    (beanstalk_grown)
    (bird_heard ?c - entity ?l - location)
    (bite ?dog - entity ?target - entity)
    (boat_available ?b - item ?l - location)
    (boiling ?i - item)
    (bowed ?e - entity ?l - location)
    (bread_given ?c - entity)
    (burned ?c - entity)
    (captured ?e - entity)
    (castle_owned_by ?castle - location ?owner - entity)
    (climbing_down ?e - entity)
    (cloak_shaken ?performer - entity ?cloak - item)
    (collected ?c - entity ?i - item)
    (concealed ?i - item)
    (contained_in ?i - item ?c - item)
    (contains ?c - item ?i - item)
    (corridor_reached ?e - entity)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crossed_lake ?c - entity)
    (crossed_out ?c - entity)
    (crowd_present ?audience - entity ?theater - location)
    (crowed ?cock - entity)
    (crumb_on_path ?l - location)
    (dead ?e - entity)
    (decided_to_tell_king ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (disguised_as ?e - entity ?d - entity)
    (distracted ?e - entity)
    (door_state ?d - location)
    (drowning ?e - entity)
    (drunk ?e - entity)
    (duck_helped ?c - entity ?d - entity)
    (eaten_by_fox ?e - entity)
    (eggs_fetched ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (employed ?worker - entity ?employer - entity)
    (empty ?i - item)
    (entity_at ?e - entity ?l - location)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (envious ?e - entity)
    (escaped ?e - entity)
    (exhibition_ready ?e - entity)
    (fair ?e - entity)
    (fairest ?e - entity)
    (fire_lit ?l - location)
    (fled ?robber - entity ?loc - location)
    (following_fox ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (gate_open)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (gloomy ?e - entity)
    (going_to_wood ?e - entity)
    (gold_at ?g - item ?l - location)
    (gold_star_on ?e - entity ?s - item)
    (grandmother_mangle_spoken)
    (guest_present ?guest - entity ?l - location)
    (half_kingdom ?e - entity ?k - location)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (has_bundle ?m - entity ?i - item)
    (has_fatigue ?e - entity)
    (has_feeling ?e - entity)
    (has_imagination ?e - entity)
    (has_mission ?c - entity)
    (has_strength ?e - entity)
    (has_understanding ?e - entity)
    (holds ?e - entity ?i - item)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (imitates_pig ?performer - entity)
    (in_cage ?e - entity)
    (in_coffin ?e - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (inside ?e - entity ?a - object)
    (intact ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (invitation_sent ?sender - entity ?receiver - entity)
    (invited ?inviter - entity ?invitee - entity)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_poet ?e - entity)
    (is_queen ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (joyful ?e - entity)
    (kick ?donkey - entity ?target - entity)
    (king_tail_stirred)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (laced ?e - entity ?i - item)
    (lantern_carried ?e - entity ?l - item)
    (left_turn_rule ?c - entity)
    (light_off ?loc - location)
    (light_on ?loc - location)
    (located ?obj - object ?loc - location)
    (locked ?l - location)
    (lost ?c - entity)
    (making_noise ?e - entity)
    (married ?e1 - entity ?e2 - entity)
    (material_requested ?p - entity ?i - item)
    (met ?e1 - entity ?e2 - entity)
    (moving_towards ?e - entity ?loc - location)
    (near ?c - entity ?b - entity)
    (need_help ?e - entity)
    (night)
    (obedient ?e - entity)
    (offers ?e - entity ?i - item)
    (on ?i - item ?l - location)
    (on_list ?c - entity)
    (on_platform ?performer - entity ?platform - location)
    (over ?i1 - item ?i2 - item)
    (owned_by ?i - item ?e - entity)
    (partiality_prevalent)
    (pebble_on_path ?l - location)
    (pellet_eaten ?e - entity)
    (performing_show ?e - entity)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (plan ?e - entity ?l - location)
    (planted ?i - item)
    (poisoned ?i - item)
    (poor ?e - entity)
    (price_of_butter_spoken)
    (princess_rescued ?e - entity)
    (prohibit_speak ?c - entity)
    (promised_to_serve ?servant - entity ?master - entity)
    (puffed ?w - entity)
    (punished ?m - entity)
    (reputation_widespread)
    (rescued_by ?victim - entity ?rescuer - entity)
    (resting ?e - entity)
    (retreated ?robber - entity)
    (reunited_with_father ?c - entity)
    (reward_announced ?nobleman - entity)
    (reward_received ?e - entity)
    (rich ?e - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (sees_light ?e - entity)
    (ship_broken)
    (ship_repaired)
    (shrunk ?e - entity)
    (singing ?e - entity)
    (sky_fell_on_head ?e - entity)
    (sleeping ?e - entity)
    (sleeping_at ?e - entity ?loc - location)
    (sound_heard ?e - entity ?l - location)
    (soup_effect_created ?e - entity)
    (speaks_to ?c - entity ?m - entity)
    (stacked_on ?top - entity ?bottom - entity)
    (stairs_descended ?e - entity)
    (stone_at ?s - item ?l - location)
    (stone_moved ?s - item)
    (story_shared ?speaker - entity ?listener - entity)
    (summoned ?c - entity)
    (theater_opened ?nobleman - entity ?theater - location)
    (transformed_into ?e - entity ?form - entity)
    (trapped ?m - entity)
    (traveling ?c - entity)
    (treasured ?i - item)
    (turned_back ?e - entity)
    (under ?i - item ?l - location)
    (visited ?e - entity ?l - location)
    (wealthy ?e - entity)
    (wearing ?e - entity ?i - item)
    (window_shattered)
    (with_all_my_heart_spoken)
    (woe_on_shoulder ?monster - entity ?carrier - entity)
    (work_done ?worker - entity ?employer - entity)
    (worshipped ?i - item)
  )

  (:action abandon_children_in_forest
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :effect (and (at ?h ?forest) (at ?g ?forest) (lost ?h) (lost ?g) (bread_given ?h) (bread_given ?g) (fire_lit ?forest))
  )

  (:action accept_messenger_attack
    :parameters (?d ?n - entity)
    :precondition (and (attempt_light ?n) (at ?d hearth))
    :effect (attacked ?d ?n)
  )

  (:action accept_woe_as_burden
    :parameters (?rich ?woe - entity)
    :precondition (woe_on_shoulder ?woe ?rich)
    :effect (has_fatigue ?rich)
  )

  (:action allow_woe_to_ride_on_shoulder
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc) (has_fatigue ?poor))
    :effect (woe_on_shoulder ?woe ?poor)
  )

  (:action apple_piece_falls_out_reviving_snow_white
    :parameters (?c - entity ?apple - item)
    :precondition (and (dead ?c) (poisoned ?apple))
    :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?apple)))
  )

  (:action approach_beech_tree
    :parameters (?n - entity ?t - location)
    :precondition (sound_heard ?n ?t)
    :effect (and (at ?n ?t) (not (at ?n bench)))
  )

  (:action approach_location
    :parameters (?loc - location ?e - entity)
    :precondition (and (at ?e ?loc))
    :effect (and (at ?e ?loc) (moving_towards ?e ?loc))
  )

  (:action approach_sun
    :parameters (?c - entity)
    :precondition (and (traveling ?c) (avoid ?c sun))
    :effect (near ?c sun)
  )

  (:action arrange_exhibition
    :parameters (?s ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (exhibition_ready ?t)
  )

  (:action arrest_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (near ?c ?m))
    :effect (and (arrested ?c ?m) (detained ?m))
  )

  (:action arrive_at_marble_palace
    :parameters (?p - entity)
    :precondition (at ?p oak_tree)
    :effect (and (at ?p palace) (not (at ?p oak_tree)))
  )

  (:action ask_for_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (material_requested ?p ?i)
  )

  (:action ask_giant_wife_for_breakfast
    :parameters (?j ?wife - entity)
    :precondition (and (at ?j giant_castle) (at ?wife giant_castle))
    :effect (has_breakfast ?j)
  )

  (:action audience_applaud_performance
    :parameters (?audience ?performer ?pig - entity ?cloak - item)
    :precondition (and (cloak_shaken ?performer ?cloak) (not (pig_found ?performer ?pig)))
    :effect (applause_given ?audience ?performer)
  )

  (:action audience_criticize_countryman_and_call_for_kickout
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (countryman_performs_with_real_pig ?countryman ?pig)
    :effect (audience_calls_for_kickout ?audience ?countryman)
  )

  (:action audience_demand_shake_cloak_for_pig
    :parameters (?audience ?performer - entity ?cloak - item)
    :effect (audience_demands_shake_cloak ?audience ?performer ?cloak)
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action be_eaten_by_fox
    :parameters (?e - entity ?l - location)
    :precondition (and (following_fox ?e) (at ?e ?l) (not (eaten_by_fox ?e)))
    :effect (and (at ?e FoxHole) (eaten_by_fox ?e) (not (at ?e ?l)) (not (following_fox ?e)))
  )

  (:action bow_to_guests
    :parameters (?poor - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (exists (?guest - entity) (guest_present ?guest ?loc)))
    :effect (bowed ?poor ?loc)
  )

  (:action build_house
    :parameters (?p - entity ?i - item ?h - location)
    :precondition (and (has ?p ?i) (alive ?p) (at ?p ?h))
    :effect (and (house ?h ?i) (house_intact ?h) (door_state ?h) (not (has ?p ?i)))
  )

  (:action burn_up
    :parameters (?c - entity)
    :precondition (near ?c sun)
    :effect (and (burned ?c) (not (traveling ?c)) (not (has_mission ?c)))
  )

  (:action buy_boots
    :parameters (?jack ?puss - entity ?boots - item)
    :precondition (not (has ?puss ?boots))
    :effect (has ?puss ?boots)
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard))
    :effect (summoned ?c)
  )

  (:action call_duck_for_crossing
    :parameters (?duck ?g ?h - entity ?lake - location)
    :precondition (and (at ?h ?lake) (at ?g ?lake) (at ?duck ?lake))
    :effect (and (duck_helped ?h ?duck) (duck_helped ?g ?duck) (crossed_lake ?h) (crossed_lake ?g))
  )

  (:action call_novices
    :parameters (?pr - entity ?k - item)
    :precondition (badger_form ?k)
    :effect (located ?k morinji)
  )

  (:action cat_agrees
    :parameters (?cat ?donkey - entity)
    :precondition (invited ?donkey ?cat)
    :effect (agreed ?cat ?donkey)
  )

  (:action cat_call_for_help
    :parameters (?jack ?king ?puss - entity)
    :precondition (drowning ?jack)
    :effect (and (rescued_by ?jack ?king) (not (drowning ?jack)))
  )

  (:action cat_catch_rabbits
    :parameters (?puss - entity ?bag ?rabbit - item ?warren - location)
    :precondition (and (has ?puss ?bag) (item_at ?rabbit ?warren) (not (contains ?bag ?rabbit)))
    :effect (and (contains ?bag ?rabbit) (not (item_at ?rabbit ?warren)))
  )

  (:action cat_deliver_gifts_to_king
    :parameters (?king ?puss - entity ?bag ?rabbit - item ?palace - location)
    :precondition (and (contains ?bag ?rabbit) (at ?puss ?palace))
    :effect (and (gift_delivered ?puss ?king ?rabbit) (not (contains ?bag ?rabbit)))
  )

  (:action cat_disentchant_prisoners
    :parameters (?person ?puss - entity)
    :precondition (alive ?puss)
    :effect (promised_to_serve ?person jack)
  )

  (:action cat_eat_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (transformed_into ?ogre ?mouse)
    :effect (not (transformed_into ?ogre ?mouse))
  )

  (:action cat_ogre_transform_lion
    :parameters (?lion ?ogre ?puss - entity)
    :precondition (and (at ?puss ogre_castle) (alive ?ogre))
    :effect (transformed_into ?ogre ?lion)
  )

  (:action cat_ogre_transform_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (alive ?ogre)
    :effect (transformed_into ?ogre ?mouse)
  )

  (:action cat_open_castle_gates
    :parameters (?king ?puss - entity ?castle - location)
    :precondition (at ?king ?castle)
    :effect (gate_open)
  )

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
  )

  (:action child_is_born_and_queen_dies
    :parameters (?c ?q - entity)
    :precondition (and (not (alive ?c)) (alive ?q))
    :effect (and (alive ?c) (dead ?q) (not (alive ?q)))
  )

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (at ?cat ?hearth) (at ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
  )

  (:action claim_queenhood
    :parameters (?m - entity)
    :precondition (or (soup_effect_created ?m) (king_tail_stirred))
    :effect (is_queen ?m)
  )

  (:action climb_beanstalk
    :parameters (?j - entity)
    :precondition (and (beanstalk_grown) (at ?j beanstalk))
    :effect (and (at ?j giant_castle) (not (at ?j beanstalk)))
  )

  (:action cock_agrees
    :parameters (?cock ?donkey - entity)
    :precondition (invited ?donkey ?cock)
    :effect (agreed ?cock ?donkey)
  )

  (:action cock_crow_alert
    :parameters (?cock - entity)
    :precondition (at ?cock beam)
    :effect (crowed ?cock)
  )

  (:action collect_treasure
    :parameters (?g ?h - entity ?pearl ?precious_stone - item ?cottage - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage))
    :effect (and (has ?h ?pearl) (has ?g ?precious_stone) (collected ?h ?pearl) (collected ?g ?precious_stone))
  )

  (:action count_eggs
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope) (entity_at ?a tree))
    :effect (has ?a eggs)
  )

  (:action countryman_declare_intent_to_repeat_trick
    :parameters (?countryman - entity)
    :effect (countryman_declares_intent ?countryman)
  )

  (:action countryman_perform_pig_imitation_with_real_pig
    :parameters (?countryman ?pig - entity ?platform - location)
    :precondition (and (countryman_declares_intent ?countryman) (on_platform ?countryman ?platform))
    :effect (countryman_performs_with_real_pig ?countryman ?pig)
  )

  (:action countryman_reveal_real_pig
    :parameters (?audience ?countryman ?pig - entity)
    :precondition (audience_calls_for_kickout ?audience ?countryman)
    :effect (pig_revealed ?countryman ?pig)
  )

  (:action cut_beanstalk
    :parameters (?giant ?mother - entity ?axe - item)
    :precondition (and (intact beanstalk) (climbing_down ?giant))
    :effect (and (dead ?giant) (not (intact beanstalk)))
  )

  (:action decide_to_tell_king
    :parameters (?e - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?e)) (not (decided_to_tell_king ?e)))
    :effect (decided_to_tell_king ?e)
  )

  (:action deliver_meteor_to_bungo
    :parameters (?m - entity)
    :precondition (detained ?m)
    :effect (delivered ?m bungo)
  )

  (:action dog_bite_messenger
    :parameters (?hound ?messenger - entity ?cottage - location)
    :precondition (and (attempt_light ?messenger) (at ?hound ?cottage))
    :effect (bite ?hound ?messenger)
  )

  (:action donkey_kick_messenger
    :parameters (?donkey ?messenger - entity)
    :precondition (attempt_light ?messenger)
    :effect (kick ?donkey ?messenger)
  )

  (:action drop_breadcrumb_on_path
    :parameters (?h - entity ?crumb - item ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (has ?h ?crumb))
    :effect (and (crumb_on_path ?path_loc) (not (has ?h ?crumb)))
  )

  (:action drop_pebble_on_path
    :parameters (?h - entity ?peb - item ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (has ?h ?peb))
    :effect (and (pebble_on_path ?path_loc) (not (has ?h ?peb)))
  )

  (:action dwarfs_cut_laces_rescue_snow_white
    :parameters (?c ?d - entity ?lace - item)
    :precondition (and (laced ?c ?lace) (dead ?c))
    :effect (and (alive ?c) (awake ?c) (not (laced ?c ?lace)) (not (dead ?c)))
  )

  (:action dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c ?d - entity)
    :precondition (and (alive ?d) (alive ?c) (sleeping ?c))
    :effect (and (awake ?c) (not (sleeping ?c)))
  )

  (:action dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c ?d - entity ?coffin - item)
    :precondition (dead ?c)
    :effect (and (in_coffin ?c) (has ?d ?coffin))
  )

  (:action dwarfs_return_and_discover_snow_white
    :parameters (?c ?d - entity)
    :precondition (and (alive ?d) (sleeping ?c))
    :effect (awake ?d)
  )

  (:action eat_dragon
    :parameters (?d - entity ?l - location)
    :precondition (and (is_hunter ?h) (has ?h gun) (entity_at dragon rock_sea) (house_destroyed ?l))
    :effect (and (dead ?d - entity) (not (alive ?d)) (not (entity_at dragon rock_sea)))
  )

  (:action eat_feast
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (window_shattered))
    :effect (and (ate_all ?donkey) (ate_all ?hound) (ate_all ?cat) (ate_all ?cock))
  )

  (:action eat_pellet_and_shrink
    :parameters (?n - entity ?p - item)
    :precondition (has ?n ?p)
    :effect (and (pellet_eaten ?n) (shrunk ?n) (not (has ?n ?p)))
  )

  (:action encounter_bitter_woe
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action encounter_impostor_king
    :parameters (?i ?p - entity)
    :precondition (and (at ?p city) (at ?i market_place))
    :effect (and (at ?p market_place) (not (at ?p city)))
  )

  (:action encounter_robbers_in_forest
    :parameters (?p - entity)
    :precondition (at ?p forest)
    :effect (and (at ?p oak_tree) (not (at ?p forest)))
  )

  (:action enter_tree_and_descend_stairs
    :parameters (?d ?n - entity ?corridor ?door ?stairs ?t - location)
    :precondition (and (inside ?n ?t) (inside ?d ?t) (door_state door))
    :effect (and (stairs_descended ?n) (stairs_descended ?d) (corridor_reached ?n))
  )

  (:action enter_witch_house
    :parameters (?g ?h - entity ?cottage - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage))
    :effect (and (has ?h cake) (has ?g sugar_window))
  )

  (:action escape_from_stable
    :parameters (?g ?h - entity ?cottage ?stable - location)
    :precondition (and (captured ?h) (locked ?stable) (at ?g ?cottage) (at ?h ?stable))
    :effect (and (at ?h ?cottage) (not (at ?h ?stable)) (not (locked ?stable)) (not (captured ?h)))
  )

  (:action escape_jail
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (and (escaped ?m) (not (captured ?m)) (not (in_cage ?m)))
  )

  (:action extinguish_light
    :parameters (?cottage - location)
    :precondition (light_on ?cottage)
    :effect (and (light_off ?cottage) (not (light_on ?cottage)))
  )

  (:action fetch_eggs
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (entity_at ?t tree) (item_at eggs tree))
    :effect (and (eggs_fetched ?t) (has ?t eggs) (not (item_at eggs tree)))
  )

  (:action follow_breadcrumbs_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (when (crumb_on_path ?path_loc) (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g))))
  )

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (decided_to_tell_king ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
  )

  (:action follow_pebbles_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (pebble_on_path ?path_loc) (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g)))
  )

  (:action force_kettle_into_box
    :parameters (?b ?k - item)
    :precondition (captured ?k)
    :effect (contained_in ?k ?b)
  )

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action give_skewer_to_elves
    :parameters (?elf ?m - entity)
    :precondition (holds ?m sausage_skewer)
    :effect (and (holds ?elf sausage_skewer) (not (holds ?m sausage_skewer)))
  )

  (:action go_to_wood
    :parameters (?e - entity)
    :precondition (and (not (at ?e Wood)) (not (going_to_wood ?e)))
    :effect (going_to_wood ?e)
  )

  (:action grow_beanstalk
    :parameters (?beans - item)
    :precondition (planted ?beans)
    :effect (and (beanstalk_grown) (intact beanstalk))
  )

  (:action hang_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (has ?pr ?k)
    :effect (hanging ?k)
  )

  (:action hear_bird_and_follow_to_witch_house
    :parameters (?bird ?g ?h - entity ?branch ?cottage - location)
    :precondition (and (at ?h ?branch) (at ?g ?branch) (bird_heard ?h ?branch) (bird_heard ?g ?branch))
    :effect (and (at ?h ?cottage) (at ?g ?cottage) (not (at ?h ?branch)) (not (at ?g ?branch)))
  )

  (:action hear_tapping_on_beech
    :parameters (?n - entity ?t - location)
    :precondition (at ?n bench)
    :effect (sound_heard ?n ?t)
  )

  (:action hide_in_kettle
    :parameters (?j - entity ?kettle - item)
    :precondition (and (at ?j giant_castle) (empty ?kettle))
    :effect (and (inside ?j ?kettle) (not (at ?j giant_castle)))
  )

  (:action hide_in_oven
    :parameters (?j - entity ?oven - item)
    :precondition (at ?j giant_castle)
    :effect (and (inside ?j ?oven) (not (at ?j giant_castle)))
  )

  (:action hide_woe_under_stone
    :parameters (?poor ?woe - entity ?stone - item ?loc - location)
    :precondition (and (woe_on_shoulder ?woe ?poor) (stone_at ?stone ?loc))
    :effect (and (trapped ?woe) (stone_at ?stone ?loc) (not (woe_on_shoulder ?woe ?poor)) (not (stone_moved ?stone)))
  )

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
  )

  (:action huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b ?c ?h - entity ?heart - item)
    :precondition (and (alive ?h) (alive ?c) (alive ?b))
    :effect (and (has ?h ?heart) (dead ?b))
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
  )

  (:action invite
    :parameters (?donkey ?hound)
    :precondition (and (invited ?donkey ?hound))
    :effect (invited ?donkey ?hound)
  )

  (:action invite_cat
    :parameters (?cat ?donkey - entity)
    :effect (invited ?donkey ?cat)
  )

  (:action invite_cock
    :parameters (?cock ?donkey - entity ?loc - location)
    :precondition (and (at ?donkey ?loc) (at ?cock ?loc))
    :effect (invited ?donkey ?cock)
  )

  (:action kettle_jump_and_fly
    :parameters (?k - item)
    :precondition (badger_form ?k)
    :effect (airborne ?k)
  )

  (:action kettle_revert_shape
    :parameters (?k - item)
    :precondition (and (badger_form ?k) (furred ?k))
    :effect (and (not (badger_form ?k)) (not (furred ?k)) (not (four_legged ?k)))
  )

  (:action kettle_transform_to_badger
    :parameters (?k - item)
    :precondition (hanging ?k)
    :effect (badger_form ?k)
  )

  (:action kettle_transform_to_fur_badger
    :parameters (?t - entity ?k - item)
    :precondition (and (night) (located ?k jhosiu) (has ?t ?k))
    :effect (and (furred ?k) (badger_form ?k) (four_legged ?k))
  )

  (:action king_marries_stepmother
    :parameters (?k ?s - entity)
    :precondition (and (alive ?k) (alive ?s))
    :effect (fair ?s)
  )

  (:action king_requests_information_and_gifts
    :parameters (?k ?p - entity ?r ?s - item)
    :precondition (and (at ?p palace) (has ?p ?r) (has ?p ?s) (at ?k palace))
    :effect (and (has ?k ?r) (has ?k ?s) (not (has ?p ?r)) (not (has ?p ?s)))
  )

  (:action king_send_groom_fetch_suit
    :parameters (?groom ?king - entity ?suit - item ?wardrobe - location)
    :precondition (item_at ?suit ?wardrobe)
    :effect (and (has ?groom ?suit) (not (item_at ?suit ?wardrobe)))
  )

  (:action knock_down_kettle
    :parameters (?k - item)
    :precondition (airborne ?k)
    :effect (and (captured ?k) (not (airborne ?k)))
  )

  (:action learn_astronomer_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_astronomer ?b) (has ?b telescope))
  )

  (:action learn_hunter_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_hunter ?b) (has ?b gun))
  )

  (:action learn_tailor_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (is_tailor ?b) (has ?b needle))
  )

  (:action learn_thief_trade
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (is_thief ?b)
  )

  (:action learn_wisdom_from_ants
    :parameters (?m - entity ?ant_loc - location)
    :precondition (at ?m ?ant_loc)
    :effect (has_understanding ?m)
  )

  (:action leave_children_at_fire
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :precondition (and (at ?h ?forest) (at ?g ?forest) (fire_lit ?forest) (bread_given ?h) (bread_given ?g))
    :effect (and (lost ?h) (lost ?g))
  )

  (:action leave_home
    :parameters (?b - entity)
    :precondition (entity_at ?b house)
    :effect (and (entity_at ?b town_gate) (not (entity_at ?b house)))
  )

  (:action locate_princess
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope))
    :effect (entity_at princess rock_sea)
  )

  (:action make_sign_of_cross
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action master_wear_suit
    :parameters (?jack - entity ?suit - item)
    :precondition (has ?jack ?suit)
    :effect (and (wearing ?jack ?suit) (not (has ?jack ?suit)))
  )

  (:action meet_character
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l) (not (met ?e1 ?e2)))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
  )

  (:action messenger_attempt_light
    :parameters (?messenger - entity ?cottage - location)
    :precondition (light_off ?cottage)
    :effect (attempt_light ?messenger)
  )

  (:action move_away
    :parameters (?e - entity ?l - location)
    :precondition (alive ?e)
    :effect (at ?e ?l)
  )

  (:action move_item
    :parameters (?item - entity ?destination - location ?origin - location)
    :precondition (and (at ?item ?origin) (holds ?item sausage_skewer))
    :effect (and (at ?item ?destination) (not (at ?item ?origin)))
  )

  (:action obtain_ship
    :parameters (?a - entity)
    :precondition (is_astronomer ?a)
    :effect (has ?a ship)
  )

  (:action open_theater_and_announce_reward
    :parameters (?nobleman - entity ?theater - location)
    :effect (and (theater_opened ?nobleman ?theater) (reward_announced ?nobleman))
  )

  (:action perform_pig_imitation_without_apparatus
    :parameters (?performer - entity ?platform - location)
    :precondition (on_platform ?performer ?platform)
    :effect (and (performs_without_apparatus ?performer) (imitates_pig ?performer))
  )

  (:action perform_show
    :parameters (?t - entity ?k - item)
    :precondition (and (exhibition_ready ?t) (has ?t ?k))
    :effect (and (performing_show ?t) (reputation_widespread))
  )

  (:action perform_work_for_rich_brother
    :parameters (?employer ?worker - entity)
    :precondition (and (employed ?worker ?employer) (has_strength ?worker))
    :effect (and (work_done ?worker ?employer) (has_fatigue ?worker))
  )

  (:action pig_buys_butter_churn_and_hides
    :parameters (?p - entity ?c - item)
    :precondition (and (at ?p town_fair) (alive ?p))
    :effect (and (has ?p ?c) (inside ?p ?c))
  )

  (:action pig_collects_apples_and_escapes
    :parameters (?p - entity ?a - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?a) (escaped ?p) (not (plan ?p ?l)))
  )

  (:action pig_collects_turnips
    :parameters (?p - entity ?i - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?i) (not (plan ?p ?l)))
  )

  (:action pig_prepares_boiling_pot_and_fire
    :parameters (?p - entity ?fire ?pot - item ?h - location)
    :precondition (and (at ?p ?h) (has ?p ?pot) (has ?p ?fire) (alive ?p))
    :effect (and (over ?pot ?fire) (under ?pot chimney) (boiling ?pot))
  )

  (:action pig_refuses_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_requested ?w ?h) (alive ?w))
    :effect (and (entry_denied ?w ?h) (not (entry_requested ?w ?h)))
  )

  (:action pig_rolls_churn_down_hill
    :parameters (?p - entity ?c - item)
    :precondition (and (inside ?p ?c) (alive ?p))
    :effect (and (rolling ?c) (not (inside ?p ?c)))
  )

  (:action plan_scaring_robbers
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
  )

  (:action plant_beans
    :parameters (?beans - item ?loc - location)
    :precondition (at_item ?beans ?loc)
    :effect (and (planted ?beans) (not (at_item ?beans ?loc)))
  )

  (:action prepare_soup_by_elf_effect
    :parameters (?m - entity)
    :precondition (and (holds ?m sausage_skewer) (anointed sausage_skewer) (at ?m kitchen))
    :effect (soup_effect_created ?m)
  )

  (:action prepare_soup_by_king_tail
    :parameters (?k - entity)
    :precondition (at mouse_king kitchen)
    :effect (king_tail_stirred)
  )

  (:action prepare_soup_by_poet_imagination
    :parameters (?m - entity)
    :precondition (and (has_understanding ?m) (has_imagination ?m) (has_feeling ?m))
    :effect (and (soup_effect_created ?m) (is_poet ?m))
  )

  (:action prince_discovers_coffin_and_moves_it
    :parameters (?c ?p - entity ?coffin - item ?mountain - location)
    :precondition (and (in_coffin ?c) (alive ?p))
    :effect (item_at ?coffin ?mountain)
  )

  (:action prince_marries_snow_white
    :parameters (?c ?p - entity)
    :precondition (and (alive ?p) (alive ?c))
    :effect (fair ?p)
  )

  (:action princess_accepts_with_heart
    :parameters (?k ?p - entity)
    :precondition (and (married ?p ?k) (not (with_all_my_heart_spoken)))
    :effect (with_all_my_heart_spoken)
  )

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action propose_marriage
    :parameters (?k ?p - entity)
    :precondition (and (at ?p palace) (at ?k palace))
    :effect (married ?p ?k)
  )

  (:action punish_meteor
    :parameters (?m - entity)
    :precondition (delivered ?m bungo)
    :effect (punished ?m)
  )

  (:action push_witch_into_oven
    :parameters (?g ?witch - entity ?oven - item ?room - location)
    :precondition (and (at ?g ?room) (at ?witch ?room))
    :effect (and (dead ?witch) (not (at ?witch ?room)))
  )

  (:action queen_pricks_finger
    :parameters (?q - entity ?blood ?needle - item)
    :precondition (and (alive ?q) (has ?q ?needle))
    :effect (has ?q ?blood)
  )

  (:action queen_sews_at_window
    :parameters (?q - entity ?l - location)
    :precondition (and (alive ?q) (at ?q ?l))
    :effect (has ?q needle)
  )

  (:action queen_wishes_child_white_red_black
    :parameters (?c ?q - entity)
    :precondition (alive ?q)
    :effect (fair ?c)
  )

  (:action read_and_digest_books
    :parameters (?m - entity ?lib - location)
    :precondition (at ?m library)
    :effect (has_feeling ?m)
  )

  (:action receive_anointed_skewer
    :parameters (?elf ?m - entity ?v - item)
    :precondition (and (holds ?m sausage_skewer) (holds ?elf violet))
    :effect (anointed sausage_skewer)
  )

  (:action receive_feather
    :parameters (?dryad ?m ?ph - entity ?feather - item ?loc - location)
    :precondition (and (at ?m ?loc) (at ?dryad ?loc) (at ?ph ?loc) (holds ?dryad ?feather))
    :effect (and (holds ?m ?feather) (has_imagination ?m))
  )

  (:action receive_gold_pot_and_hide
    :parameters (?poor - entity ?gold - item ?loc - location)
    :precondition (and (gold_at ?gold ?loc) (at ?poor ?loc))
    :effect (and (has ?poor ?gold) (not (gold_at ?gold ?loc)))
  )

  (:action receive_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (material_requested ?p ?i) (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (and (has ?p ?i) (not (material_requested ?p ?i)) (not (has_bundle ?m ?i)))
  )

  (:action receive_orders_from_nobility
    :parameters (?t - entity)
    :precondition (reputation_widespread)
    :effect (wealthy ?t)
  )

  (:action receive_payment
    :parameters (?employer ?worker - entity ?bread ?money - item)
    :precondition (and (work_done ?worker ?employer) (has ?employer ?money) (has ?employer ?bread))
    :effect (and (has ?worker ?money) (has ?worker ?bread) (not (has ?employer ?money)) (not (has ?employer ?bread)))
  )

  (:action receive_pellet_from_gnome
    :parameters (?g ?n - entity ?p ?s - item ?t - location)
    :precondition (and (inside ?n ?t) (inside ?g ?t))
    :effect (has ?n ?p)
  )

  (:action receive_queen_kiss
    :parameters (?n ?q - entity)
    :precondition (at ?n palace)
    :effect (and (kissed_by ?n ?q) (joyful ?n) (not (gloomy ?n)))
  )

  (:action receive_reward
    :parameters (?e - entity)
    :precondition (princess_rescued ?e)
    :effect (and (reward_received ?e) (half_kingdom ?e kingdom))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (at ?p oak_tree) (has ?c ?s))
    :effect (and (has ?p ?s) (not (has ?c ?s)))
  )

  (:action remove_poisoned_comet
    :parameters (?c - entity ?comb - item)
    :precondition (and (dead ?c) (poisoned ?comb) (has ?d ?comb))
    :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?comb)) (crossed_out ?c) (not (on_list ?c)))
  )

  (:action repair_ship
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (ship_broken))
    :effect (and (ship_repaired) (not (ship_broken)))
  )

  (:action request_help_from_rich_brother
    :parameters (?poor ?rich - entity)
    :precondition (and (need_help ?poor) (rich ?rich))
    :effect (and (employed ?poor ?rich) (not (need_help ?poor)))
  )

  (:action rest_in_forest
    :parameters (?cat ?cock ?donkey ?hound - entity ?forest - location)
    :precondition (and (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (resting ?donkey) (resting ?hound) (resting ?cat) (resting ?cock))
  )

  (:action return_down_beanstalk
    :parameters (?j - entity)
    :precondition (at ?j giant_castle)
    :effect (and (at ?j cottage) (not (at ?j giant_castle)))
  )

  (:action return_eggs_to_nest
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (eggs_sewn brother_tailor) (entity_at ?t tree) (has ?t eggs))
    :effect (and (item_at eggs tree) (not (has ?t eggs)))
  )

  (:action return_home_with_princess
    :parameters (?a - entity)
    :precondition (and (ship_repaired) (entity_at ?a sea))
    :effect (and (entity_at ?a house) (entity_at princess house) (not (entity_at ?a sea)))
  )

  (:action return_kettle_to_temple
    :parameters (?t - entity ?k - item)
    :precondition (and (has ?t ?k) (wealthy ?t))
    :effect (and (located ?k morinji) (treasured ?k) (not (has ?t ?k)))
  )

  (:action return_to_bench_and_share_story
    :parameters (?g ?m ?n - entity ?bench - location)
    :precondition (at ?n palace)
    :effect (and (at ?n ?bench) (story_shared ?n ?m) (story_shared ?n ?g) (not (at ?n palace)))
  )

  (:action reunite_at_crossroads
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (and (entity_at ?b house) (not (entity_at ?b cross_way)))
  )

  (:action reverse_direction
    :parameters (?e - entity)
    :precondition (and (at ?e wood) (not (at ?e father_house)))
    :effect (and (at ?e father_house) (not (at ?e wood)))
  )

  (:action rich_brother_attempt_to_move_stone
    :parameters (?rich - entity ?stone - item ?loc - location)
    :precondition (and (stone_at ?stone ?loc) (rich ?rich))
    :effect (and (stone_moved ?stone) (woe_on_shoulder bitter_woe ?rich) (not (stone_at ?stone ?loc)))
  )

  (:action robbers_flee
    :parameters (?robber - entity ?cottage ?forest - location)
    :precondition (and (window_shattered) (at ?robber ?cottage))
    :effect (and (fled ?robber ?forest) (not (at ?robber ?cottage)))
  )

  (:action robbers_retreat
    :parameters (?robber - entity ?cottage - location)
    :precondition (at ?robber ?cottage)
    :effect (and (retreated ?robber) (not (at ?robber ?cottage)))
  )

  (:action run_away_from_palace
    :parameters (?p - entity)
    :precondition (at ?p back_stairs)
    :effect (and (at ?p city) (not (at ?p back_stairs)))
  )

  (:action run_in_cage
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (in_cage ?m)
  )

  (:action sail_to_rock
    :parameters (?a - entity)
    :precondition (and (has ?a ship) (entity_at ?a house))
    :effect (and (entity_at ?a rock_sea) (not (entity_at ?a house)))
  )

  (:action sell_cow_for_beans
    :parameters (?b ?cow ?j - entity ?beans - item ?l - location)
    :precondition (and (at ?j ?l) (at ?cow ?l) (offers ?b ?beans) (at ?b ?l))
    :effect (and (has ?j ?beans) (not (offers ?b ?beans)) (not (at_item ?beans ?l)))
  )

  (:action sell_kettle_to_tinker
    :parameters (?pr ?t - entity ?c ?k - item)
    :precondition (and (has ?pr ?k) (has ?t ?c))
    :effect (and (has ?t ?k) (has ?pr ?c) (not (has ?pr ?k)) (not (has ?t ?c)))
  )

  (:action send_sons_on_journey
    :parameters (?m ?p - entity ?d - location)
    :precondition (and (at ?m pig_home) (at ?p pig_home) (alive ?m) (alive ?p))
    :effect (and (plan ?p ?d) (not (at ?p pig_home)))
  )

  (:action separate_at_crossroads
    :parameters (?b - entity)
    :precondition (entity_at ?b cross_way)
    :effect (has ?b sticks)
  )

  (:action sew_eggs
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (eggs_shot brother_hunter))
    :effect (eggs_sewn ?t)
  )

  (:action shoot_eggs
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (eggs_fetched brother_thief))
    :effect (eggs_shot ?h)
  )

  (:action show_kettle_to_friend
    :parameters (?f ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (has ?f ?k)
  )

  (:action signal_and_make_noise
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock) (window_shattered))
  )

  (:action sing_cheerful_song
    :parameters (?poor - entity ?loc - location)
    :precondition (at ?poor ?loc)
    :effect (singing ?poor)
  )

  (:action snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - entity ?apple - item)
    :precondition (and (poisoned ?apple) (alive ?c))
    :effect (and (dead ?c) (not (alive ?c)))
  )

  (:action snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - entity ?mug ?plate - item)
    :precondition (alive ?c)
    :effect (and (has ?c ?plate) (has ?c ?mug))
  )

  (:action snow_white_finds_dwarfs_cottage
    :parameters (?c - entity ?cottage - location)
    :precondition (alive ?c)
    :effect (at ?c ?cottage)
  )

  (:action snow_white_sleeps_in_seventh_bed
    :parameters (?c - entity ?bed - item)
    :precondition (alive ?c)
    :effect (sleeping ?c)
  )

  (:action speak_to_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (prohibit_speak ?c) (near ?c ?m))
    :effect (and (speaks_to ?c ?m) (rule_violation ?c))
  )

  (:action spend_money_on_drink
    :parameters (?poor - entity ?money ?wine - item ?kabak - location)
    :precondition (and (has ?poor ?money) (at ?poor ?kabak))
    :effect (and (has ?poor ?wine) (drunk ?poor) (not (has ?poor ?money)))
  )

  (:action spot_light
    :parameters (?cock - entity ?cottage ?forest - location)
    :precondition (and (at ?cock ?forest) (resting ?cock))
    :effect (and (sees_light ?cock) (moving_towards ?cock ?cottage))
  )

  (:action stack_animals
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
    :effect (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
  )

  (:action start_travel
    :parameters (?c - entity)
    :precondition (and (has_mission ?c) (gate_open))
    :effect (and (traveling ?c) (not (at ?c courtyard)))
  )

  (:action stay_for_banquet
    :parameters (?guest ?host - entity ?loc - location)
    :precondition (and (at ?guest ?loc) (at ?host ?loc) (banquet_at ?loc) (invited ?guest ?host))
    :effect (guest_present ?guest ?loc)
  )

  (:action steal_gold_bags
    :parameters (?j - entity ?bag1 ?bag2 - item)
    :precondition (and (asleep giant) (at_item ?bag1 giant_castle) (at_item ?bag2 giant_castle))
    :effect (and (has ?j ?bag1) (has ?j ?bag2) (not (at_item ?bag1 giant_castle)) (not (at_item ?bag2 giant_castle)))
  )

  (:action steal_harp
    :parameters (?giant ?j - entity ?harp - item)
    :precondition (and (on ?harp giant_castle) (asleep ?giant))
    :effect (and (has ?j ?harp) (not (on ?harp giant_castle)))
  )

  (:action steal_hen
    :parameters (?giant ?j - entity ?hen - item)
    :precondition (and (on ?hen giant_castle) (distracted ?giant))
    :effect (and (has ?j ?hen) (not (on ?hen giant_castle)))
  )

  (:action steal_princess
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (entity_at ?t rock_sea) (entity_at princess rock_sea) (entity_at dragon rock_sea))
    :effect (and (princess_rescued ?t) (entity_at princess sea) (not (entity_at princess rock_sea)))
  )

  (:action stepmother_asks_looking_glass_fairest
    :parameters (?s - entity ?g - item)
    :precondition (and (alive ?s) (has ?s ?g))
    :effect (fairest ?s)
  )

  (:action stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - entity ?slippers - item)
    :precondition (alive ?s)
    :effect (and (wearing ?s ?slippers) (dead ?s) (not (alive ?s)))
  )

  (:action stepmother_becomes_envious_of_snow_white
    :parameters (?c ?s - entity)
    :precondition (and (fairest ?c) (fair ?c) (alive ?s))
    :effect (envious ?s)
  )

  (:action stepmother_comb_poison_snow_white
    :parameters (?c ?s - entity ?comb - item)
    :precondition (and (has ?s ?comb) (poisoned ?comb) (alive ?c))
    :effect (and (dead ?c) (not (alive ?c)))
  )

  (:action stepmother_disguises_and_visits
    :parameters (?old_woman ?s - entity ?cottage - location)
    :precondition (and (alive ?s) (not (grandmother_mangle_spoken)))
    :effect (and (disguised_as ?s ?old_woman) (visited ?s ?cottage) (grandmother_mangle_spoken))
  )

  (:action stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - entity ?heart - item)
    :precondition (has ?s ?heart)
    :effect (not (has ?s ?heart))
  )

  (:action stepmother_laces_snow_white_tightly
    :parameters (?c ?s - entity ?lace - item)
    :precondition (and (alive ?c) (has ?c ?lace))
    :effect (and (laced ?c ?lace) (dead ?c) (not (alive ?c)) (not (sleeping ?c)))
  )

  (:action stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - entity ?apple - item ?cottage - location)
    :precondition (alive ?s)
    :effect (and (poisoned ?apple) (has ?s ?apple) (visited ?s ?cottage))
  )

  (:action stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - entity ?comb - item ?cottage - location)
    :precondition (alive ?s)
    :effect (and (poisoned ?comb) (has ?s ?comb) (visited ?s ?cottage))
  )

  (:action stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c ?h ?s - entity)
    :precondition (and (envious ?s) (alive ?h) (alive ?c))
    :effect (fair ?s)
  )

  (:action suitors_retire_due_to_phrase
    :parameters (?s - entity)
    :precondition (and (grandmother_mangle_spoken) (at ?s palace))
    :effect (not (married ?s princess))
  )

  (:action swim_after_ship_break
    :parameters (?b - entity)
    :precondition (ship_broken)
    :effect (entity_at ?b sea)
  )

  (:action tinker_carry_home
    :parameters (?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (located ?k jhosiu)
  )

  (:action trade_assets_for_money
    :parameters (?poor - entity ?asset ?money - item)
    :precondition (has ?poor ?asset)
    :effect (and (has ?poor ?money) (not (has ?poor ?asset)))
  )

  (:action travel_by_leaf_boat_under_pond
    :parameters (?n - entity ?b - item ?palace ?pond - location)
    :precondition (and (stairs_descended ?n) (boat_available ?b ?pond))
    :effect (at ?n ?palace)
  )

  (:action travel_to_trysting_place
    :parameters (?n - entity ?b ?c - location)
    :precondition (at ?n ?c)
    :effect (and (at ?n ?b) (not (at ?n ?c)))
  )

  (:action travel_together
    :parameters (?cat ?cock ?donkey ?hound - entity ?from ?to - location)
    :precondition (and (at ?donkey ?from) (at ?hound ?from) (at ?cat ?from) (at ?cock ?from) (agreed ?hound ?donkey) (agreed ?cat ?donkey) (agreed ?cock ?donkey))
    :effect (and (at ?donkey ?to) (at ?hound ?to) (at ?cat ?to) (at ?cock ?to) (moving_towards ?donkey ?to) (moving_towards ?hound ?to) (moving_towards ?cat ?to) (moving_towards ?cock ?to) (not (at ?donkey ?from)) (not (at ?hound ?from)) (not (at ?cat ?from)) (not (at ?cock ?from)))
  )

  (:action turn_key_on_beech
    :parameters (?n - entity ?k - item ?t - location)
    :precondition (at ?n ?t)
    :effect (and (door_state door) (inside dryad ?t) (invitation_offered dryad ?n) (has ?n ?k))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
  )

  (:action utter_phrase_price_of_butter
    :parameters (?p - entity)
    :precondition (and (at ?p market_place) (not (price_of_butter_spoken)))
    :effect (price_of_butter_spoken)
  )

  (:action wander_forest_seeking_way_out
    :parameters (?g ?h - entity ?forest - location)
    :precondition (and (at ?h ?forest) (at ?g ?forest))
    :effect (and (lost ?h) (lost ?g))
  )

  (:action witch_captures_children
    :parameters (?g ?h ?witch - entity ?cottage ?stable - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage) (not (locked ?stable)))
    :effect (and (captured ?h) (locked ?stable) (at ?h ?stable) (not (at ?h ?cottage)))
  )

  (:action witness_queen_birthday_ceremony
    :parameters (?n ?q - entity ?palace - location)
    :precondition (at ?n ?palace)
    :effect (and (joyful ?n) (story_shared ?q ?n))
  )

  (:action wolf_attempts_chimney_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (house_intact ?h) (alive ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action wolf_blows_house_down
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (door_state ?h) (alive ?w))
    :effect (and (house_destroyed ?h) (not (house_intact ?h)) (not (door_state ?h)))
  )

  (:action wolf_fails_to_blow_house
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (alive ?w))
    :effect (house_intact ?h)
  )

  (:action wolf_falls_into_pot_and_is_boiled
    :parameters (?w - entity ?pot - item)
    :precondition (and (boiling ?pot) (alive ?w))
    :effect (and (dead ?w) (not (alive ?w)))
  )

  (:action wolf_huff_and_puff
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_denied ?w ?h) (alive ?w))
    :effect (and (huffed ?w) (puffed ?w))
  )

  (:action wolf_promises_apple_orchard
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_fair_trip
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_turnip_field
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action worship_kettle_as_saint
    :parameters (?k - item)
    :precondition (treasured ?k)
    :effect (worshipped ?k)
  )
)
