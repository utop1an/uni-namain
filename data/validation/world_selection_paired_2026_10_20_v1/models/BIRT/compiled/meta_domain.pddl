(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_beech_tree d000__c_bench d000__c_boat d000__c_corridor d000__c_cottage d000__c_door d000__c_dryad d000__c_fairy_queen d000__c_fairyland d000__c_gnome d000__c_gold_star d000__c_grandmother d000__c_grandmotherkin d000__c_key d000__c_lantern d000__c_mother d000__c_mothereen d000__c_nora d000__c_palace d000__c_pellet d000__c_pond d000__c_silver_salver d000__c_spring d000__c_stairs d000__c_stream - object
  )
  (:predicates
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_boat_available ?a0 - object ?a1 - object)
    (d000__p_corridor_reached ?a0 - object)
    (d000__p_door_open ?a0 - object)
    (d000__p_gloomy ?a0 - object)
    (d000__p_gold_star_on ?a0 - object ?a1 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_inside ?a0 - object ?a1 - object)
    (d000__p_invitation_offered ?a0 - object ?a1 - object)
    (d000__p_joyful ?a0 - object)
    (d000__p_kissed_by ?a0 - object ?a1 - object)
    (d000__p_knighted ?a0 - object)
    (d000__p_lantern_carried ?a0 - object ?a1 - object)
    (d000__p_pellet_eaten ?a0 - object)
    (d000__p_shrunk ?a0 - object)
    (d000__p_sound_heard ?a0 - object ?a1 - object)
    (d000__p_stairs_descended ?a0 - object)
    (d000__p_story_shared ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_accept_dryad_invitation
    :parameters (?d - object ?n - object)
    :precondition (and (typeguard__d000__t_entity ?d) (typeguard__d000__t_entity ?n) (d000__p_invitation_offered ?d ?n))
    :effect (not (d000__p_invitation_offered ?d ?n))
  )

  (:action d000__a_approach_beech_tree
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?t) (d000__p_sound_heard ?n ?t))
    :effect (and (d000__p_at ?n ?t) (not (d000__p_at ?n d000__c_bench)))
  )

  (:action d000__a_eat_pellet_and_shrink
    :parameters (?n - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?p) (d000__p_has ?n ?p))
    :effect (and (d000__p_pellet_eaten ?n) (d000__p_shrunk ?n) (not (d000__p_has ?n ?p)))
  )

  (:action d000__a_enter_tree_and_descend_stairs
    :parameters (?d - object ?n - object ?corridor - object ?door - object ?stairs - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?d) (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?corridor) (typeguard__d000__t_location ?door) (typeguard__d000__t_location ?stairs) (typeguard__d000__t_location ?t) (and (d000__p_inside ?n ?t) (d000__p_inside ?d ?t) (d000__p_door_open d000__c_door)))
    :effect (and (d000__p_stairs_descended ?n) (d000__p_stairs_descended ?d) (d000__p_corridor_reached ?n))
  )

  (:action d000__a_hear_tapping_on_beech
    :parameters (?n - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?t) (d000__p_at ?n d000__c_bench))
    :effect (d000__p_sound_heard ?n ?t)
  )

  (:action d000__a_receive_pellet_from_gnome
    :parameters (?g - object ?n - object ?p - object ?s - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?p) (typeguard__d000__t_item ?s) (typeguard__d000__t_location ?t) (and (d000__p_inside ?n ?t) (d000__p_inside ?g ?t)))
    :effect (d000__p_has ?n ?p)
  )

  (:action d000__a_receive_queen_kiss
    :parameters (?n - object ?q - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_entity ?q) (d000__p_at ?n d000__c_palace))
    :effect (and (d000__p_kissed_by ?n ?q) (d000__p_joyful ?n) (not (d000__p_gloomy ?n)))
  )

  (:action d000__a_return_to_bench_and_share_story
    :parameters (?g - object ?m - object ?n - object ?bench - object)
    :precondition (and (typeguard__d000__t_entity ?g) (typeguard__d000__t_entity ?m) (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?bench) (d000__p_at ?n d000__c_palace))
    :effect (and (d000__p_at ?n ?bench) (d000__p_story_shared ?n ?m) (d000__p_story_shared ?n ?g) (not (d000__p_at ?n d000__c_palace)))
  )

  (:action d000__a_travel_by_leaf_boat_under_pond
    :parameters (?n - object ?b - object ?palace - object ?pond - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?b) (typeguard__d000__t_location ?palace) (typeguard__d000__t_location ?pond) (and (d000__p_stairs_descended ?n) (d000__p_boat_available ?b ?pond)))
    :effect (d000__p_at ?n ?palace)
  )

  (:action d000__a_travel_to_trysting_place
    :parameters (?n - object ?b - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_location ?b) (typeguard__d000__t_location ?c) (d000__p_at ?n ?c))
    :effect (and (d000__p_at ?n ?b) (not (d000__p_at ?n ?c)))
  )

  (:action d000__a_turn_key_on_beech
    :parameters (?n - object ?k - object ?t - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_item ?k) (typeguard__d000__t_location ?t) (d000__p_at ?n ?t))
    :effect (and (d000__p_door_open d000__c_door) (d000__p_inside d000__c_dryad ?t) (d000__p_invitation_offered d000__c_dryad ?n) (d000__p_has ?n ?k))
  )

  (:action d000__a_witness_queen_birthday_ceremony
    :parameters (?n - object ?q - object ?palace - object)
    :precondition (and (typeguard__d000__t_entity ?n) (typeguard__d000__t_entity ?q) (typeguard__d000__t_location ?palace) (d000__p_at ?n ?palace))
    :effect (and (d000__p_joyful ?n) (d000__p_story_shared ?q ?n))
  )
)
