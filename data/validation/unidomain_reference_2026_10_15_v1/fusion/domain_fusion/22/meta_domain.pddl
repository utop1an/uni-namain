(define (domain unified_narrative_domain)
  (:requirements :existential-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    badger bitter_woe children dryad fairy_queen friend gnome grandmother grandmotherkin lady_of_court mother mothereen nora poor_brother priest prince princess rich_brother showman tinker wife - entity
    boat box cattle copecks_25 copper_coins gold_pot gold_star grove harrow honey key lantern loaf_bread pack pellet plow silver_salver sledge stone teakettle telega temple_treasure wine - item
    beech_tree bench big_house corridor cottage door fairyland forest izba jhosiu kabak large_town morinji new_home palace pond spring stairs stream tight_rope treasure_pit village well yard - location
  )
  (:predicates
    (airborne ?i - item)
    (at ?e - entity ?l - location)
    (badger_form ?i - item)
    (banquet_at ?l - location)
    (boat_available ?b - item ?l - location)
    (captured ?i - item)
    (carried_item ?e - entity ?l - item)
    (concealed ?i - item)
    (contained_in ?i - item ?c - item)
    (corridor_reached ?e - entity)
    (door_open ?d - location)
    (employed ?worker - entity ?employer - entity)
    (exhibition_ready ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (gold_at ?g - item ?l - location)
    (gold_star_on ?e - entity ?s - item)
    (guest_present ?guest - entity ?l - location)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (has_fatigue ?e - entity)
    (has_strength ?e - entity)
    (in_location ?e - entity ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (invitation_sent ?sender - entity ?receiver - entity)
    (invited ?invitee - entity ?host - entity)
    (joyful ?e - entity)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (located ?obj - object ?loc - location)
    (need_help ?e - entity)
    (night)
    (pellet_eaten ?e - entity)
    (poor ?e - entity)
    (reputation_widespread)
    (sad ?e - entity)
    (singing ?e - entity)
    (sound_heard ?e - entity ?l - location)
    (stairs_descended ?e - entity)
    (state ?e - entity)
    (stone_at ?s - item ?l - location)
    (stone_moved ?s - item)
    (story_shared ?speaker - entity ?listener - entity)
    (trapped ?m - entity)
    (treasured ?i - item)
    (wealthy ?e - entity)
    (woe_on_shoulder ?monster - entity ?carrier - entity)
    (work_done ?worker - entity ?employer - entity)
    (worshipped ?i - item)
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

  (:action arrange_exhibition
    :parameters (?s ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (exhibition_ready ?t)
  )

  (:action bow_to_guests
    :parameters (?poor - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (exists (?guest - entity) (guest_present ?guest ?loc)))
    :effect (in_location ?poor ?loc)
  )

  (:action call_novices
    :parameters (?pr - entity ?k - item)
    :precondition (badger_form ?k)
    :effect (located ?k morinji)
  )

  (:action eat_pellet_and_shrink
    :parameters (?n - entity ?p - item)
    :precondition (has ?n ?p)
    :effect (and (pellet_eaten ?n) (state ?n) (not (has ?n ?p)))
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

  (:action force_kettle_into_box
    :parameters (?b ?k - item)
    :precondition (captured ?k)
    :effect (contained_in ?k ?b)
  )

  (:action hang_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (has ?pr ?k)
    :effect (hanging ?k)
  )

  (:action hear_tapping_on_beech
    :parameters (?n - entity ?t - location)
    :precondition (at ?n bench)
    :effect (sound_heard ?n ?t)
  )

  (:action hide_woe_under_stone
    :parameters (?poor ?woe - entity ?stone - item ?loc - location)
    :precondition (and (woe_on_shoulder ?woe ?poor) (stone_at ?stone ?loc))
    :effect (and (trapped ?woe) (stone_at ?stone ?loc) (not (woe_on_shoulder ?woe ?poor)) (not (stone_moved ?stone)))
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

  (:action make_sign_of_cross
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action perform_show
    :parameters (?t - entity ?k - item)
    :precondition (and (exhibition_ready ?t) (has ?t ?k))
    :effect (and (state ?t) (reputation_widespread))
  )

  (:action perform_work_for_rich_brother
    :parameters (?employer ?worker - entity)
    :precondition (and (employed ?worker ?employer) (has_strength ?worker))
    :effect (and (work_done ?worker ?employer) (has_fatigue ?worker))
  )

  (:action pursue_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (airborne ?k)
    :effect (and (captured ?k) (not (airborne ?k)))
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

  (:action receive_queen_kiss
    :parameters (?n ?q - entity)
    :precondition (at ?n palace)
    :effect (and (kissed_by ?n ?q) (joyful ?n) (not (sad ?n)))
  )

  (:action request_help_from_rich_brother
    :parameters (?poor ?rich - entity)
    :precondition (and (need_help ?poor) (state ?rich))
    :effect (and (employed ?poor ?rich) (not (need_help ?poor)))
  )

  (:action return_to_bench_and_share_story
    :parameters (?g ?m ?n - entity ?bench - location)
    :precondition (at ?n palace)
    :effect (and (at ?n ?bench) (story_shared ?n ?m) (story_shared ?n ?g) (not (at ?n palace)))
  )

  (:action rich_brother_attempt_to_move_stone
    :parameters (?rich - entity ?stone - item ?loc - location)
    :precondition (and (stone_at ?stone ?loc) (state ?rich))
    :effect (and (stone_moved ?stone) (woe_on_shoulder bitter_woe ?rich) (not (stone_at ?stone ?loc)))
  )

  (:action sell_kettle_to_tinker
    :parameters (?pr ?t - entity ?c ?k - item)
    :precondition (and (has ?pr ?k) (has ?t ?c))
    :effect (and (has ?t ?k) (has ?pr ?c) (not (has ?pr ?k)) (not (has ?t ?c)))
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

  (:action stay_for_banquet
    :parameters (?guest ?host - entity ?loc - location)
    :precondition (and (at ?guest ?loc) (at ?host ?loc) (banquet_at ?loc) (invited ?guest ?host))
    :effect (guest_present ?guest ?loc)
  )

  (:action take_gold_pot_and_hide
    :parameters (?poor - entity ?gold - item ?loc - location)
    :precondition (and (gold_at ?gold ?loc) (at ?poor ?loc))
    :effect (and (has ?poor ?gold) (concealed ?gold) (not (gold_at ?gold ?loc)))
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

  (:action travel_to_trysting_place
    :parameters (?n - entity ?b ?c - location)
    :precondition (at ?n ?c)
    :effect (and (at ?n ?b) (not (at ?n ?c)))
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
