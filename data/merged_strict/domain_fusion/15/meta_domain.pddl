(define (domain unified_narrative_domain)
  (:requirements :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    badger dryad fairy_queen friend gnome grandmother grandmotherkin lady_of_court mother mothereen nora priest prince princess showman tinker - entity
    boat box copper_coins gold_star key lantern pack pellet silver_salver teakettle temple_treasure - item
    beech_tree bench corridor cottage door fairyland jhosiu morinji palace pond spring stairs stream tight_rope - location
  )
  (:predicates
    (airborne ?i - item)
    (at ?e - entity ?l - location)
    (badger_form ?i - item)
    (boat_available ?b - item ?l - location)
    (captured ?i - item)
    (contained_in ?i - item ?c - item)
    (corridor_reached ?e - entity)
    (door_open ?d - location)
    (exhibition_ready ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (gloomy ?e - entity)
    (gold_star_on ?e - entity ?s - item)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (inside ?e - entity ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (joyful ?e - entity)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (lantern_carried ?e - entity ?l - item)
    (located ?obj - object ?loc - location)
    (night)
    (owned_by ?i - item ?e - entity)
    (pellet_eaten ?e - entity)
    (performing_show ?e - entity)
    (reputation_widespread)
    (shrunk ?e - entity)
    (sound_heard ?e - entity ?l - location)
    (stairs_descended ?e - entity)
    (story_shared ?speaker - entity ?listener - entity)
    (treasured ?i - item)
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

  (:action call_novices
    :parameters (?pr - entity ?k - item)
    :precondition (badger_form ?k)
    :effect (located ?k morinji)
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

  (:action perform_show
    :parameters (?t - entity ?k - item)
    :precondition (and (exhibition_ready ?t) (has ?t ?k))
    :effect (and (performing_show ?t) (reputation_widespread))
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
