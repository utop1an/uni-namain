(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d001__t_entity d001__t_item d001__t_location - d001__t_object
    d000__t_object d001__t_object - object
  )
  (:constants
    d000__c_badger d000__c_friend d000__c_lady_of_court d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_tinker - d000__t_entity
    d000__c_box d000__c_copper_coins d000__c_pack d000__c_teakettle d000__c_temple_treasure - d000__t_item
    d000__c_jhosiu d000__c_morinji d000__c_tight_rope - d000__t_location
    d001__c_dryad d001__c_fairy_queen d001__c_gnome d001__c_grandmother d001__c_grandmotherkin d001__c_mother d001__c_mothereen d001__c_nora - d001__t_entity
    d001__c_boat d001__c_gold_star d001__c_key d001__c_lantern d001__c_pellet d001__c_silver_salver - d001__t_item
    d001__c_beech_tree d001__c_bench d001__c_corridor d001__c_cottage d001__c_door d001__c_fairyland d001__c_palace d001__c_pond d001__c_spring d001__c_stairs d001__c_stream - d001__t_location
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
)
