(define (domain unified_narrative_domain)
  (:requirements :conditional-effects :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    audience badger bird bitter_woe brother_astronomer brother_hunter brother_tailor brother_thief buff__c_mother buff__c_princess buffoon chaffinch Chicken-licken children Cock-lock countryman dragon Drake-lake dryad duck Duck-luck fairy_queen father four_np__c_king Fox-lox friend Gander-lander gnome Goose-loose grandmother grandmotherkin grettel hans_np__c_father hansel Hen-len King lady_of_court little_pig mentor_astronomer mentor_hunter mentor_tailor mentor_thief mother mothereen nora poor_brother priest prince princess rich_brother rich_nobleman showman tinker Turkey-lurkey wife witch - entity
    Acorn apple boat box bread_piece brushwood cake cattle cloak copecks_25 copper_coins crumb eggs gold_pot gold_star grove gun harrow honey kettle key lantern loaf_bread milk needle nut oven pack pancake pearl pebble pellet planks plow precious_stone ship silver_salver Sky sledge sticks stone sugar_window teakettle telega telescope temple_treasure wine - item
    beech_tree bench big_house branch buff__c_cottage buff__c_door buff__c_forest corridor cottage cross_way dead_tree door fairyland father_house forest FoxHole hill house izba jhosiu kabak kingdom lake large_town morinji new_home palace path platform pond rock_sea roof room sea spring stable_location stairs stream theater tight_rope town_gate treasure_pit tree village well window Wood yard - location
  )
  (:predicates
    (airborne ?i - item)
    (applause_given ?audience - entity ?performer - entity)
    (at ?e - entity ?l - location)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (badger_form ?i - item)
    (banquet_at ?l - location)
    (boat_available ?b - item ?l - location)
    (bread_given ?c - entity)
    (buff__p_captured ?c - entity)
    (captured ?i - item)
    (cloak_shaken ?performer - entity ?cloak - item)
    (concealed ?i - item)
    (contained_in ?i - item ?c - item)
    (corridor_reached ?e - entity)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crossed_lake ?c - entity)
    (crowd_present ?audience - entity ?theater - location)
    (crumb_on_path ?l - location)
    (door_open ?d - location)
    (dragon_dead)
    (duck_helped ?c - entity ?d - entity)
    (eaten_by_fox ?e - entity)
    (eggs_sewn ?e - entity)
    (eggs_shot ?e - entity)
    (employed ?worker - entity ?employer - entity)
    (entity_in_state ?e - entity)
    (fire_lit ?l - location)
    (following_fox ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (going_to_wood ?e - entity)
    (gold_star_on ?e - entity ?s - item)
    (half_kingdom ?e - entity ?k - location)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (has_fatigue ?e - entity)
    (has_strength ?e - entity)
    (held ?e - entity ?i - item)
    (imitates_pig ?performer - entity)
    (in_location ?e - entity ?l - location)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (invitation_offered ?from - entity ?to - entity)
    (invitation_sent ?sender - entity ?receiver - entity)
    (invited ?invitee - entity ?host - entity)
    (is_astronomer ?e - entity)
    (is_hunter ?e - entity)
    (is_tailor ?e - entity)
    (is_thief ?e - entity)
    (item_at ?i - item ?l - location)
    (joyful ?e - entity)
    (kissed_by ?e - entity ?k - entity)
    (located ?obj - object ?loc - location)
    (locked ?l - location)
    (lost ?c - entity)
    (met ?e1 - entity ?e2 - entity)
    (need_help ?e - entity)
    (night)
    (on_platform ?performer - entity ?platform - location)
    (partiality_prevalent)
    (pebble_on_path ?l - location)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (present ?e - entity ?l - location)
    (ready_to_show ?e - entity)
    (reputation_widespread)
    (rescued_princess ?e - entity)
    (reunited_with_father ?c - entity)
    (reward_announced ?nobleman - entity)
    (sad ?e - entity)
    (ship_broken)
    (ship_repaired)
    (sick ?e - entity)
    (singing ?e - entity)
    (sky_fell_on_head ?e - entity)
    (sound_heard ?e - entity ?l - location)
    (stairs_descended ?e - entity)
    (state ?e - entity)
    (state_reached ?e - entity)
    (stone_at ?s - item ?l - location)
    (stone_moved ?s - item)
    (story_shared ?speaker - entity ?listener - entity)
    (theater_opened ?nobleman - entity ?theater - location)
    (trapped ?m - entity)
    (treasured ?i - item)
    (wealthy ?e - entity)
    (woe_on_shoulder ?monster - entity ?carrier - entity)
    (work_done ?worker - entity ?employer - entity)
    (worshipped ?i - item)
  )

  (:action abandon_children_in_forest
    :parameters (?father ?g ?h ?mother - entity ?forest - location)
    :effect (and (at ?h ?forest) (at ?g ?forest) (lost ?h) (lost ?g) (bread_given ?h) (bread_given ?g) (fire_lit ?forest))
  )

  (:action accept_dryad_invitation
    :parameters (?d ?n - entity)
    :precondition (invitation_offered ?d ?n)
    :effect (not (invitation_offered ?d ?n))
  )

  (:action accept_woe_as_burden
    :parameters (?rich ?woe - entity)
    :precondition (woe_on_shoulder ?woe ?rich)
    :effect (has_fatigue ?rich)
  )

  (:action activate_beech
    :parameters (?n - entity ?k - item ?t - location)
    :precondition (and (at ?n ?t) (has ?n ?k))
    :effect (and (door_open door) (in_location dryad ?t) (invitation_offered dryad ?n) (has ?n ?k))
  )

  (:action allow_woe_to_ride_on_shoulder
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc) (has_fatigue ?poor))
    :effect (woe_on_shoulder ?woe ?poor)
  )

  (:action approach_beech_tree
    :parameters (?n - entity ?t - location)
    :precondition (sound_heard ?n ?t)
    :effect (and (at ?n ?t) (not (at ?n bench)))
  )

  (:action attend_banquet
    :parameters (?guest ?host - entity ?loc - location)
    :precondition (and (at ?guest ?loc) (at ?host ?loc) (banquet_at ?loc) (invited ?guest ?host))
    :effect (present ?guest ?loc)
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

  (:action capture_and_destroy
    :parameters (?k - item ?d - entity)
    :precondition (and (airborne ?k) (is_hunter ?d))
    :effect (and (captured ?k) (dragon_dead) (not (airborne ?k)))
  )

  (:action count_eggs
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope) (at ?a tree))
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

  (:action eat_pellet_and_shrink
    :parameters (?n - entity ?p - item)
    :precondition (has ?n ?p)
    :effect (and (entity_in_state ?n) (state ?n) (not (has ?n ?p)))
  )

  (:action encounter_bitter_woe
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action enter_tree_and_descend_stairs
    :parameters (?d ?n - entity ?corridor ?door ?stairs ?t - location)
    :precondition (and (in_location ?n ?t) (in_location ?d ?t) (door_open door))
    :effect (and (stairs_descended ?n) (stairs_descended ?d) (corridor_reached ?n))
  )

  (:action enter_witch_house
    :parameters (?g ?h - entity ?cottage - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage))
    :effect (and (has ?h cake) (has ?g sugar_window))
  )

  (:action escape_from_stable
    :parameters (?g ?h - entity ?cottage ?stable - location)
    :precondition (and (buff__p_captured ?h) (locked ?stable) (at ?g ?cottage) (at ?h ?stable))
    :effect (and (at ?h ?cottage) (not (at ?h ?stable)) (not (locked ?stable)) (not (buff__p_captured ?h)))
  )

  (:action fetch_eggs
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (at ?t tree) (item_at eggs tree))
    :effect (and (entity_in_state ?t) (has ?t eggs) (not (item_at eggs tree)))
  )

  (:action follow_breadcrumbs_home
    :parameters (?g ?h - entity ?home ?path_loc - location)
    :precondition (and (at ?h ?path_loc) (at ?g ?path_loc))
    :effect (when (crumb_on_path ?path_loc) (and (at ?h ?home) (at ?g ?home) (not (at ?h ?path_loc)) (not (at ?g ?path_loc)) (not (lost ?h)) (not (lost ?g))))
  )

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (ready_to_show ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
  )

  (:action follow_stone_home
    :parameters (?s - item ?h - entity ?home - location)
    :precondition (and (stone_at ?s ?home) (state ?h))
    :effect (and (at ?h ?home) (not (stone_at ?s ?home)))
  )

  (:action force_kettle_into_box
    :parameters (?b ?k - item)
    :precondition (captured ?k)
    :effect (contained_in ?k ?b)
  )

  (:action go_and_hear_tapping_on_wood
    :parameters (?n - entity ?t - location)
    :precondition (and (at ?n bench) (not (going_to_wood ?n)))
    :effect (and (going_to_wood ?n) (sound_heard ?n ?t))
  )

  (:action hang_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (has ?pr ?k)
    :effect (hanging ?k)
  )

  (:action hide_woe_under_stone
    :parameters (?poor ?woe - entity ?stone - item ?loc - location)
    :precondition (and (woe_on_shoulder ?woe ?poor) (stone_at ?stone ?loc))
    :effect (and (trapped ?woe) (stone_at ?stone ?loc) (not (woe_on_shoulder ?woe ?poor)) (not (stone_moved ?stone)))
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
  )

  (:action interact
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
  )

  (:action invite_rich_brother_to_feast
    :parameters (?poor ?rich - entity ?loc - location)
    :precondition (at ?poor ?loc)
    :effect (and (invitation_sent ?poor ?rich) (invited ?rich ?poor))
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

  (:action knock_down_kettle
    :parameters (?k - item)
    :precondition (airborne ?k)
    :effect (and (captured ?k) (not (airborne ?k)))
  )

  (:action learn_astronomer_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_astronomer ?b) (has ?b telescope))
  )

  (:action learn_hunter_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_hunter ?b) (has ?b gun))
  )

  (:action learn_tailor_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (and (is_tailor ?b) (has ?b needle))
  )

  (:action learn_thief_trade
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (is_thief ?b)
  )

  (:action locate_princess
    :parameters (?a - entity)
    :precondition (and (is_astronomer ?a) (has ?a telescope))
    :effect (at buff__c_princess rock_sea)
  )

  (:action make_sign_of_cross
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action move_to_destination_and_resolve_state
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (at ?e ?l) (not (lost ?e)))
  )

  (:action move_to_location
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (not (at ?e ?l)))
  )

  (:action observe_and_follow_to_witch_house
    :parameters (?e ?g ?h - entity ?branch ?cottage - location)
    :precondition (and (at ?h ?branch) (at ?g ?branch) (present ?h ?branch) (present ?g ?branch))
    :effect (and (at ?h ?cottage) (at ?g ?cottage) (not (at ?h ?branch)) (not (at ?g ?branch)))
  )

  (:action obtain_ship
    :parameters (?a - entity)
    :precondition (is_astronomer ?a)
    :effect (has ?a ship)
  )

  (:action open_door
    :parameters (?nobleman - entity ?theater - location ?reward - item)
    :precondition (and (state_reached ?nobleman) (theater_opened ?nobleman ?theater) (has ?nobleman ?reward))
    :effect (and (state_reached ?nobleman) (has ?nobleman ?reward))
  )

  (:action perform_and_applaud
    :parameters (?s ?t - entity ?a - entity ?c - item)
    :precondition (and (ready_to_show ?s) (cloak_shaken ?a ?c))
    :effect (and (applause_given ?a ?s))
  )

  (:action perform_pig_imitation_without_apparatus
    :parameters (?performer - entity ?platform - location)
    :precondition (on_platform ?performer ?platform)
    :effect (and (performs_without_apparatus ?performer) (imitates_pig ?performer))
  )

  (:action perform_work_for_rich_brother
    :parameters (?employer ?worker - entity)
    :precondition (and (employed ?worker ?employer) (has_strength ?worker))
    :effect (and (work_done ?worker ?employer) (has_fatigue ?worker))
  )

  (:action prepare_to_show
    :parameters (?t - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?t)) (not (ready_to_show ?t)))
    :effect (ready_to_show ?t)
  )

  (:action push_witch_into_oven
    :parameters (?g ?witch - entity ?oven - item ?room - location)
    :precondition (and (at ?g ?room) (at ?witch ?room))
    :effect (and (sick ?witch) (not (at ?witch ?room)))
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
    :precondition (and (in_location ?n ?t) (in_location ?g ?t))
    :effect (has ?n ?p)
  )

  (:action repair_ship
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (ship_broken))
    :effect (and (ship_repaired) (not (ship_broken)))
  )

  (:action request_help_from_rich_brother
    :parameters (?poor ?rich - entity)
    :precondition (and (need_help ?poor) (state ?rich))
    :effect (and (employed ?poor ?rich) (not (need_help ?poor)))
  )

  (:action return_eggs_to_nest
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (eggs_sewn brother_tailor) (at ?t tree) (has ?t eggs))
    :effect (and (item_at eggs tree) (not (has ?t eggs)))
  )

  (:action return_to_location
    :parameters (?e - entity ?l - location)
    :precondition (and (at ?e ?l))
    :effect (and (at ?e ?l) (not (at ?e palace)))
  )

  (:action seek_way_out_in_forest
    :parameters (?g ?h - entity ?f - location)
    :precondition (and (at ?h ?f) (at ?g ?f))
    :effect (and (lost ?h) (at ?g ?f))
  )

  (:action sell_kettle_to_tinker
    :parameters (?pr ?t - entity ?c ?k - item)
    :precondition (and (has ?pr ?k) (has ?t ?c))
    :effect (and (has ?t ?k) (has ?pr ?c) (not (has ?pr ?k)) (not (has ?t ?c)))
  )

  (:action separate_at_crossroads
    :parameters (?b - entity)
    :precondition (at ?b cross_way)
    :effect (has ?b sticks)
  )

  (:action sew_eggs
    :parameters (?t - entity)
    :precondition (and (is_tailor ?t) (has ?t needle) (eggs_shot brother_hunter))
    :effect (eggs_sewn ?t)
  )

  (:action shoot_eggs
    :parameters (?h - entity)
    :precondition (and (is_hunter ?h) (has ?h gun) (entity_in_state brother_thief))
    :effect (eggs_shot ?h)
  )

  (:action show_kettle_to_friend
    :parameters (?f ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (has ?f ?k)
  )

  (:action sing_cheerful_song
    :parameters (?poor - entity ?loc - location)
    :precondition (at ?poor ?loc)
    :effect (singing ?poor)
  )

  (:action spend_money_on_drink
    :parameters (?poor - entity ?money ?wine - item ?kabak - location)
    :precondition (and (has ?poor ?money) (at ?poor ?kabak))
    :effect (and (has ?poor ?wine) (sad ?poor) (not (has ?poor ?money)))
  )

  (:action steal_princess
    :parameters (?t - entity)
    :precondition (and (is_thief ?t) (at ?t rock_sea) (at buff__c_princess rock_sea) (at dragon rock_sea))
    :effect (and (rescued_princess ?t) (at buff__c_princess sea) (not (at buff__c_princess rock_sea)))
  )

  (:action swim_after_ship_break
    :parameters (?b - entity)
    :precondition (ship_broken)
    :effect (at ?b sea)
  )

  (:action take_item_and_hide
    :parameters (?poor - entity ?item - item ?loc - location)
    :precondition (and (item_at ?item ?loc) (at ?poor ?loc))
    :effect (and (has ?poor ?item) (concealed ?item) (not (item_at ?item ?loc)))
  )

  (:action trade_assets_for_money
    :parameters (?poor - entity ?asset ?money - item)
    :precondition (has ?poor ?asset)
    :effect (and (has ?poor ?money) (not (has ?poor ?asset)))
  )

  (:action transport_item
    :parameters (?item - item ?location - location)
    :precondition (and (stone_at ?item ?location))
    :effect (and (not (stone_at ?item ?location)))
  )

  (:action travel_by_leaf_boat_under_pond
    :parameters (?n - entity ?b - item ?palace ?pond - location)
    :precondition (and (stairs_descended ?n) (boat_available ?b ?pond))
    :effect (at ?n ?palace)
  )

  (:action turn_back
    :parameters (?e - entity)
    :precondition (and (going_to_wood ?e) (not (state_reached ?e)))
    :effect (and (state_reached ?e) (not (going_to_wood ?e)))
  )

  (:action witch_captures_children
    :parameters (?g ?h ?witch - entity ?cottage ?stable - location)
    :precondition (and (at ?h ?cottage) (at ?g ?cottage) (not (locked ?stable)))
    :effect (and (buff__p_captured ?h) (locked ?stable) (at ?h ?stable) (not (at ?h ?cottage)))
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
