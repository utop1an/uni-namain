(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ass audience badger bird brother_astronomer brother_hunter brother_tailor brother_thief brown_hen buffoon butcher captain cat chaffinch Chicken-licken cock Cock-lock countryman dragon Drake-lake dryad duck Duck-luck fairy_maiden fairy_queen father Fox-lox friend Gander-lander giant giant_dog giant_wife gnome Goose-loose grandmother grandmotherkin grettel hansel Hen-len hound jack jack_mother King king lady_of_court little_pig man mentor_astronomer mentor_hunter mentor_tailor mentor_thief messenger milky_white mother mothereen nora priest prince princess rich_nobleman robber showman tinker Turkey-lurkey witch - entity
    Acorn apple axe boat box bread_piece brushwood cake cloak copper_coins crumb drinks eggs gold_bag_1 gold_bag_2 gold_star golden_harp gun kettle kettledrums key lantern lute magic_beans meat milk needle nut oak_tree_club oven pack pancake pearl pebble pellet planks precious_stone ship silver_salver Sky sticks straw sugar_window table teakettle telescope temple_treasure - item
    beam beanstalk beech_tree bench branch bremen castle_road corridor cottage cross_way dead_tree door fairyland father_house forest FoxHole garden giant_castle hearth hill house jack_np_kettle jack_np_oven jhosiu kingdom lake market morinji palace path platform pond road_to_bremen robbers_cottage rock_sea roof room sea spring stable_location stairs stream theater tight_rope town_gate tree window Wood - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (airborne ?i - item)
    (applause_given ?audience - entity ?performer - entity)
    (asleep ?e - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (badger_form ?i - item)
    (beanstalk_grown)
    (bird_heard ?c - entity ?l - location)
    (bite ?dog - entity ?target - entity)
    (boat_available ?b - item ?l - location)
    (bread_given ?c - entity)
    (captured ?i - item)
    (climbing_down ?e - entity)
    (cloak_shaken ?performer - entity ?cloak - item)
    (collected ?c - entity ?i - item)
    (contained_in ?i - item ?c - item)
    (corridor_reached ?e - entity)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crossed_lake ?c - entity)
    (crowd_present ?audience - entity ?theater - location)
    (crowed ?cock - entity)
    (crumb_on_path ?l - location)
    (dead ?e - entity)
    (decided_to_tell_king ?e - entity)
    (distracted ?e - entity)
    (door_open ?d - location)
    (duck_helped ?c - entity ?d - entity)
    (eaten_by_fox ?e - entity)
    (eggs_fetched ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (empty ?i - item)
    (entity_at ?e - entity ?l - location)
    (exhibition_ready ?e - entity)
    (fire_lit ?l - location)
    (fled ?robber - entity ?loc - location)
    (following_fox ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (gloomy ?e - entity)
    (going_to_wood ?e - entity)
    (gold_star_on ?e - entity ?s - item)
    (half_kingdom ?e - entity ?k - location)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (imitates_pig ?performer - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (inside ?e - entity ?l/i - object)
    (intact ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (invited ?inviter - entity ?invitee - entity)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (joyful ?e - entity)
    (kick ?donkey - entity ?target - entity)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (lantern_carried ?e - entity ?l - item)
    (light_off ?loc - location)
    (light_on ?loc - location)
    (located ?obj - object ?loc - location)
    (locked ?l - location)
    (lost ?c - entity)
    (making_noise ?e - entity)
    (met ?e1 - entity ?e2 - entity)
    (moving_towards ?e - entity ?loc - location)
    (night)
    (offers ?e - entity ?i - item)
    (on ?i - item ?l - location)
    (on_platform ?performer - entity ?platform - location)
    (owned_by ?i - item ?e - entity)
    (partiality_prevalent)
    (pebble_on_path ?l - location)
    (pellet_eaten ?e - entity)
    (performing_show ?e - entity)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (planted ?i - item)
    (princess_rescued ?e - entity)
    (reputation_widespread)
    (resting ?e - entity)
    (retreated ?robber - entity)
    (reunited_with_father ?c - entity)
    (reward_announced ?nobleman - entity)
    (reward_received ?e - entity)
    (sees_light ?e - entity)
    (ship_broken)
    (ship_repaired)
    (shrunk ?e - entity)
    (sky_fell_on_head ?e - entity)
    (sleeping_at ?e - entity ?loc - location)
    (sound_heard ?e - entity ?l - location)
    (stacked_on ?top - entity ?bottom - entity)
    (stairs_descended ?e - entity)
    (story_shared ?speaker - entity ?listener - entity)
    (theater_opened ?nobleman - entity ?theater - location)
    (treasured ?i - item)
    (turned_back ?e - entity)
    (wealthy ?e - entity)
    (window_shattered)
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

  (:action approach_beech_tree
    :parameters (?n - entity ?t - location)
    :precondition (sound_heard ?n ?t)
    :effect (and (at ?n ?t) (not (at ?n bench)))
  )

  (:action approach_cottage
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage ?forest - location)
    :precondition (and (sees_light ?cock) (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (moving_towards ?donkey ?cottage) (moving_towards ?hound ?cottage) (moving_towards ?cat ?cottage) (moving_towards ?cock ?cottage) (not (at ?donkey ?forest)) (not (at ?hound ?forest)) (not (at ?cat ?forest)) (not (at ?cock ?forest)))
  )

  (:action arrange_exhibition
    :parameters (?s ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (exhibition_ready ?t)
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

  (:action be_eaten_by_fox
    :parameters (?e - entity ?l - location)
    :precondition (and (following_fox ?e) (at ?e ?l) (not (eaten_by_fox ?e)))
    :effect (and (at ?e FoxHole) (eaten_by_fox ?e) (not (at ?e ?l)) (not (following_fox ?e)))
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

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (at ?cat ?hearth) (at ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
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

  (:action enter_tree_and_descend_stairs
    :parameters (?d ?n - entity ?corridor ?door ?stairs ?t - location)
    :precondition (and (inside ?n ?t) (inside ?d ?t) (door_open door))
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

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
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

  (:action invite_hound
    :parameters (?donkey ?hound - entity)
    :effect (invited ?donkey ?hound)
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

  (:action kill_dragon
    :parameters (?d - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (entity_at dragon rock_sea))
    :effect (and (dead ?d - entity) (ship_broken) (not (entity_at dragon rock_sea)))
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

  (:action push_witch_into_oven
    :parameters (?g ?witch - entity ?oven - item ?room - location)
    :precondition (and (at ?g ?room) (at ?witch ?room))
    :effect (and (dead ?witch) (not (at ?witch ?room)))
  )

  (:action receive_orders_from_nobility
    :parameters (?t - entity)
    :precondition (reputation_widespread)
    :effect (wealthy ?t)
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

  (:action repair_ship
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (ship_broken))
    :effect (and (ship_repaired) (not (ship_broken)))
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

  (:action run_away
    :parameters (?donkey - entity ?from ?to - location)
    :precondition (at ?donkey ?from)
    :effect (and (at ?donkey ?to) (moving_towards ?donkey ?to) (not (at ?donkey ?from)))
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
    :effect (and (door_open door) (inside dryad ?t) (invitation_offered dryad ?n) (has ?n ?k))
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

  (:action worship_kettle_as_saint
    :parameters (?k - item)
    :precondition (treasured ?k)
    :effect (worshipped ?k)
  )
)
