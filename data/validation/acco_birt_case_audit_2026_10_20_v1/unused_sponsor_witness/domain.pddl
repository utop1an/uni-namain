(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_badger d000__c_box d000__c_copper_coins d000__c_friend d000__c_jhosiu d000__c_lady_of_court d000__c_morinji d000__c_pack d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_teakettle d000__c_temple_treasure d000__c_tight_rope d000__c_tinker d001__c_beech_tree d001__c_bench d001__c_boat d001__c_corridor d001__c_cottage d001__c_door d001__c_dryad d001__c_fairy_queen d001__c_fairyland d001__c_gnome d001__c_gold_star d001__c_grandmother d001__c_grandmotherkin d001__c_key d001__c_lantern d001__c_mother d001__c_mothereen d001__c_nora d001__c_palace d001__c_pellet d001__c_pond d001__c_silver_salver d001__c_spring d001__c_stairs d001__c_stream - object
  )
  (:predicates
    (d000__p_airborne ?a0 - object)
    (d000__p_badger_form ?a0 - object)
    (d000__p_captured ?a0 - object)
    (d000__p_contained_in ?a0 - object ?a1 - object)
    (d000__p_exhibition_ready ?a0 - object)
    (d000__p_four_legged ?a0 - object)
    (d000__p_furred ?a0 - object)
    (d000__p_hanging ?a0 - object)
    (d000__p_located ?a0 - object ?a1 - object)
    (d000__p_night)
    (d000__p_owned_by ?a0 - object ?a1 - object)
    (d000__p_performing_show ?a0 - object)
    (d000__p_reputation_widespread)
    (d000__p_treasured ?a0 - object)
    (d000__p_wealthy ?a0 - object)
    (d000__p_worshipped ?a0 - object)
    (d001__p_at ?a0 - object ?a1 - object)
    (d001__p_boat_available ?a0 - object ?a1 - object)
    (d001__p_corridor_reached ?a0 - object)
    (d001__p_door_open ?a0 - object)
    (d001__p_gloomy ?a0 - object)
    (d001__p_gold_star_on ?a0 - object ?a1 - object)
    (d001__p_inside ?a0 - object ?a1 - object)
    (d001__p_invitation_offered ?a0 - object ?a1 - object)
    (d001__p_joyful ?a0 - object)
    (d001__p_kissed_by ?a0 - object ?a1 - object)
    (d001__p_knighted ?a0 - object)
    (d001__p_lantern_carried ?a0 - object ?a1 - object)
    (d001__p_pellet_eaten ?a0 - object)
    (d001__p_shrunk ?a0 - object)
    (d001__p_sound_heard ?a0 - object ?a1 - object)
    (d001__p_stairs_descended ?a0 - object)
    (d001__p_story_shared ?a0 - object ?a1 - object)
    (shared__p_possession ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
    (typeguard__d001__t_entity ?member - object)
    (typeguard__d001__t_item ?member - object)
    (typeguard__d001__t_location ?member - object)
    (typeguard__d001__t_object ?member - object)
  )

  (:action d000__a_arrange_exhibition
    :parameters (?s - object ?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (shared__p_possession ?t ?k))
    :effect (d000__p_exhibition_ready ?t)
  )

  (:action d000__a_call_novices
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (d000__p_badger_form ?k))
    :effect (d000__p_located ?k d000__c_morinji)
  )

  (:action d000__a_force_kettle_into_box
    :parameters (?b - object ?k - object)
    :precondition (and (typeguard__d000__t_item ?b) (typeguard__d000__t_item ?k) (d000__p_captured ?k))
    :effect (d000__p_contained_in ?k ?b)
  )

  (:action d000__a_hang_kettle
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (shared__p_possession ?pr ?k))
    :effect (d000__p_hanging ?k)
  )

  (:action d000__a_kettle_jump_and_fly
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_badger_form ?k))
    :effect (d000__p_airborne ?k)
  )

  (:action d000__a_kettle_revert_shape
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (and (d000__p_badger_form ?k) (d000__p_furred ?k)))
    :effect (and (not (d000__p_badger_form ?k)) (not (d000__p_furred ?k)) (not (d000__p_four_legged ?k)))
  )

  (:action d000__a_kettle_transform_to_badger
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_hanging ?k))
    :effect (d000__p_badger_form ?k)
  )

  (:action d000__a_kettle_transform_to_fur_badger
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (d000__p_night) (d000__p_located ?k d000__c_jhosiu) (shared__p_possession ?t ?k)))
    :effect (and (d000__p_furred ?k) (d000__p_badger_form ?k) (d000__p_four_legged ?k))
  )

  (:action d000__a_knock_down_kettle
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_airborne ?k))
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_perform_show
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (d000__p_exhibition_ready ?t) (shared__p_possession ?t ?k)))
    :effect (and (d000__p_performing_show ?t) (d000__p_reputation_widespread))
  )

  (:action d000__a_pursue_kettle
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (d000__p_airborne ?k))
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_receive_orders_from_nobility
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (d000__p_reputation_widespread))
    :effect (d000__p_wealthy ?t)
  )

  (:action d000__a_return_kettle_to_temple
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (shared__p_possession ?t ?k) (d000__p_wealthy ?t)))
    :effect (and (d000__p_located ?k d000__c_morinji) (d000__p_treasured ?k) (not (shared__p_possession ?t ?k)))
  )

  (:action d000__a_sell_kettle_to_tinker
    :parameters (?pr - object ?t - object ?c - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?c) (typeguard__d000__t_item ?k) (and (shared__p_possession ?pr ?k) (shared__p_possession ?t ?c)))
    :effect (and (shared__p_possession ?t ?k) (shared__p_possession ?pr ?c) (not (shared__p_possession ?pr ?k)) (not (shared__p_possession ?t ?c)))
  )

  (:action d000__a_show_kettle_to_friend
    :parameters (?f - object ?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?f) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (shared__p_possession ?t ?k))
    :effect (shared__p_possession ?f ?k)
  )

  (:action d000__a_tinker_carry_home
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (shared__p_possession ?t ?k))
    :effect (d000__p_located ?k d000__c_jhosiu)
  )

  (:action d000__a_worship_kettle_as_saint
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_treasured ?k))
    :effect (d000__p_worshipped ?k)
  )

  (:action d001__a_accept_dryad_invitation
    :parameters (?d - object ?n - object)
    :precondition (and (typeguard__d001__t_entity ?d) (typeguard__d001__t_entity ?n) (d001__p_invitation_offered ?d ?n))
    :effect (not (d001__p_invitation_offered ?d ?n))
  )

  (:action d001__a_approach_beech_tree
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_location ?t) (d001__p_sound_heard ?n ?t))
    :effect (and (d001__p_at ?n ?t) (not (d001__p_at ?n d001__c_bench)))
  )

  (:action d001__a_eat_pellet_and_shrink
    :parameters (?n - object ?p - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_item ?p) (shared__p_possession ?n ?p))
    :effect (and (d001__p_pellet_eaten ?n) (d001__p_shrunk ?n) (not (shared__p_possession ?n ?p)))
  )

  (:action d001__a_enter_tree_and_descend_stairs
    :parameters (?d - object ?n - object ?corridor - object ?door - object ?stairs - object ?t - object)
    :precondition (and (typeguard__d001__t_entity ?d) (typeguard__d001__t_entity ?n) (typeguard__d001__t_location ?corridor) (typeguard__d001__t_location ?door) (typeguard__d001__t_location ?stairs) (typeguard__d001__t_location ?t) (and (d001__p_inside ?n ?t) (d001__p_inside ?d ?t) (d001__p_door_open d001__c_door)))
    :effect (and (d001__p_stairs_descended ?n) (d001__p_stairs_descended ?d) (d001__p_corridor_reached ?n))
  )

  (:action d001__a_hear_tapping_on_beech
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_location ?t) (d001__p_at ?n d001__c_bench))
    :effect (d001__p_sound_heard ?n ?t)
  )

  (:action d001__a_receive_pellet_from_gnome
    :parameters (?g - object ?n - object ?p - object ?s - object ?t - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?n) (typeguard__d001__t_item ?p) (typeguard__d001__t_item ?s) (typeguard__d001__t_location ?t) (and (d001__p_inside ?n ?t) (d001__p_inside ?g ?t)))
    :effect (shared__p_possession ?n ?p)
  )

  (:action d001__a_receive_queen_kiss
    :parameters (?n - object ?q - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_entity ?q) (d001__p_at ?n d001__c_palace))
    :effect (and (d001__p_kissed_by ?n ?q) (d001__p_joyful ?n) (not (d001__p_gloomy ?n)))
  )

  (:action d001__a_return_to_bench_and_share_story
    :parameters (?g - object ?m - object ?n - object ?bench - object)
    :precondition (and (typeguard__d001__t_entity ?g) (typeguard__d001__t_entity ?m) (typeguard__d001__t_entity ?n) (typeguard__d001__t_location ?bench) (d001__p_at ?n d001__c_palace))
    :effect (and (d001__p_at ?n ?bench) (d001__p_story_shared ?n ?m) (d001__p_story_shared ?n ?g) (not (d001__p_at ?n d001__c_palace)))
  )

  (:action d001__a_travel_by_leaf_boat_under_pond
    :parameters (?n - object ?b - object ?palace - object ?pond - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_item ?b) (typeguard__d001__t_location ?palace) (typeguard__d001__t_location ?pond) (and (d001__p_stairs_descended ?n) (d001__p_boat_available ?b ?pond)))
    :effect (d001__p_at ?n ?palace)
  )

  (:action d001__a_travel_to_trysting_place
    :parameters (?n - object ?b - object ?c - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_location ?b) (typeguard__d001__t_location ?c) (d001__p_at ?n ?c))
    :effect (and (d001__p_at ?n ?b) (not (d001__p_at ?n ?c)))
  )

  (:action d001__a_turn_key_on_beech
    :parameters (?n - object ?k - object ?t - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_item ?k) (typeguard__d001__t_location ?t) (d001__p_at ?n ?t))
    :effect (and (d001__p_door_open d001__c_door) (d001__p_inside d001__c_dryad ?t) (d001__p_invitation_offered d001__c_dryad ?n) (shared__p_possession ?n ?k))
  )

  (:action d001__a_witness_queen_birthday_ceremony
    :parameters (?n - object ?q - object ?palace - object)
    :precondition (and (typeguard__d001__t_entity ?n) (typeguard__d001__t_entity ?q) (typeguard__d001__t_location ?palace) (d001__p_at ?n ?palace))
    :effect (and (d001__p_joyful ?n) (d001__p_story_shared ?q ?n))
  )
)
