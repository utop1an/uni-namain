(define (domain unified_narrative_domain)
  (:requirements :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    audience badger buffoon Chicken-licken Cock-lock countryman Drake-lake dryad Duck-luck fairy_queen Fox-lox friend Gander-lander gnome Goose-loose grandmother grandmotherkin Hen-len King lady_of_court little_pig mother mothereen nora priest prince princess rich_nobleman showman tinker Turkey-lurkey - entity
    Acorn boat box cloak copper_coins gold_star key lantern pack pellet silver_salver Sky teakettle temple_treasure - item
    beech_tree bench corridor cottage door fairyland FoxHole jhosiu morinji palace platform pond spring stairs stream theater tight_rope Wood - location
  )
  (:predicates
    (airborne ?i - item)
    (applause_given ?audience - entity ?performer - entity)
    (at ?e - entity ?l - location)
    (audience_calls_for_kickout ?audience - entity ?countryman - entity)
    (audience_demands_shake_cloak ?audience - entity ?performer - entity ?cloak - item)
    (badger_form ?i - item)
    (boat_available ?b - item ?l - location)
    (captured ?i - item)
    (cloak_shaken ?performer - entity ?cloak - item)
    (contained_in ?i - item ?c - item)
    (corridor_reached ?e - entity)
    (countryman_declares_intent ?countryman - entity)
    (countryman_performs_with_real_pig ?countryman - entity ?pig - entity)
    (crowd_present ?audience - entity ?theater - location)
    (decided_to_tell_king ?e - entity)
    (door_open ?d - location)
    (eaten_by_fox ?e - entity)
    (exhibition_ready ?e - entity)
    (following_fox ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (gloomy ?e - entity)
    (going_to_wood ?e - entity)
    (gold_star_on ?e - entity ?s - item)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (imitates_pig ?performer - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (inside ?e - entity ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (joyful ?e - entity)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (lantern_carried ?e - entity ?l - item)
    (located ?obj - object ?loc - location)
    (met ?e1 - entity ?e2 - entity)
    (night)
    (on_platform ?performer - entity ?platform - location)
    (owned_by ?i - item ?e - entity)
    (partiality_prevalent)
    (pellet_eaten ?e - entity)
    (performing_show ?e - entity)
    (performs_without_apparatus ?performer - entity)
    (pig_found ?performer - entity ?pig - entity)
    (pig_revealed ?countryman - entity ?pig - entity)
    (reputation_widespread)
    (reward_announced ?nobleman - entity)
    (shrunk ?e - entity)
    (sky_fell_on_head ?e - entity)
    (sound_heard ?e - entity ?l - location)
    (stairs_descended ?e - entity)
    (story_shared ?speaker - entity ?listener - entity)
    (theater_opened ?nobleman - entity ?theater - location)
    (treasured ?i - item)
    (turned_back ?e - entity)
    (wealthy ?e - entity)
    (worshipped ?i - item)
  )

  (:action accept_dryad_invitation
    :parameters (?d ?n - entity)
    :precondition (invitation_offered ?d ?n)
    :effect (not (invitation_offered ?d ?n))
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

  (:action call_novices
    :parameters (?pr - entity ?k - item)
    :precondition (badger_form ?k)
    :effect (located ?k morinji)
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

  (:action decide_to_tell_king
    :parameters (?e - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?e)) (not (decided_to_tell_king ?e)))
    :effect (decided_to_tell_king ?e)
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

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (decided_to_tell_king ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
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

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
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

  (:action meet_character
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l) (not (met ?e1 ?e2)))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
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

  (:action turn_back
    :parameters (?e - entity)
    :precondition (and (going_to_wood ?e) (not (turned_back ?e)))
    :effect (and (turned_back ?e) (not (going_to_wood ?e)))
  )

  (:action turn_key_on_beech
    :parameters (?n - entity ?k - item ?t - location)
    :precondition (at ?n ?t)
    :effect (and (door_open door) (inside dryad ?t) (invitation_offered dryad ?n) (has ?n ?k))
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
