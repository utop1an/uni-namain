(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_dryad d000__c_fairy_queen d000__c_gnome d000__c_grandmother d000__c_grandmotherkin d000__c_mother d000__c_mothereen d000__c_nora - d000__t_entity
    d000__c_boat d000__c_gold_star d000__c_key d000__c_lantern d000__c_pellet d000__c_silver_salver - d000__t_item
    d000__c_beech_tree d000__c_bench d000__c_corridor d000__c_cottage d000__c_door d000__c_fairyland d000__c_palace d000__c_pond d000__c_spring d000__c_stairs d000__c_stream - d000__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_boat_available ?b - d000__t_item ?l - d000__t_location)
    (d000__p_corridor_reached ?e - d000__t_entity)
    (d000__p_door_open ?d - d000__t_location)
    (d000__p_gloomy ?e - d000__t_entity)
    (d000__p_gold_star_on ?e - d000__t_entity ?s - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_inside ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_invitation_offered ?from - d000__t_entity ?to - d000__t_entity)
    (d000__p_joyful ?e - d000__t_entity)
    (d000__p_kissed_by ?e - d000__t_entity ?k - d000__t_entity)
    (d000__p_knighted ?e - d000__t_entity)
    (d000__p_lantern_carried ?e - d000__t_entity ?l - d000__t_item)
    (d000__p_pellet_eaten ?e - d000__t_entity)
    (d000__p_shrunk ?e - d000__t_entity)
    (d000__p_sound_heard ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_stairs_descended ?e - d000__t_entity)
    (d000__p_story_shared ?speaker - d000__t_entity ?listener - d000__t_entity)
  )

  (:action d000__a_accept_dryad_invitation
    :parameters (?d - d000__t_entity ?n - d000__t_entity)
    :precondition (d000__p_invitation_offered ?d ?n)
    :effect (not (d000__p_invitation_offered ?d ?n))
  )

  (:action d000__a_approach_beech_tree
    :parameters (?n - d000__t_entity ?t - d000__t_location)
    :precondition (d000__p_sound_heard ?n ?t)
    :effect (and (d000__p_at ?n ?t) (not (d000__p_at ?n d000__c_bench)))
  )

  (:action d000__a_eat_pellet_and_shrink
    :parameters (?n - d000__t_entity ?p - d000__t_item)
    :precondition (d000__p_has ?n ?p)
    :effect (and (d000__p_pellet_eaten ?n) (d000__p_shrunk ?n) (not (d000__p_has ?n ?p)))
  )

  (:action d000__a_enter_tree_and_descend_stairs
    :parameters (?d - d000__t_entity ?n - d000__t_entity ?corridor - d000__t_location ?door - d000__t_location ?stairs - d000__t_location ?t - d000__t_location)
    :precondition (and (d000__p_inside ?n ?t) (d000__p_inside ?d ?t) (d000__p_door_open d000__c_door))
    :effect (and (d000__p_stairs_descended ?n) (d000__p_stairs_descended ?d) (d000__p_corridor_reached ?n))
  )

  (:action d000__a_hear_tapping_on_beech
    :parameters (?n - d000__t_entity ?t - d000__t_location)
    :precondition (d000__p_at ?n d000__c_bench)
    :effect (d000__p_sound_heard ?n ?t)
  )

  (:action d000__a_receive_pellet_from_gnome
    :parameters (?g - d000__t_entity ?n - d000__t_entity ?p - d000__t_item ?s - d000__t_item ?t - d000__t_location)
    :precondition (and (d000__p_inside ?n ?t) (d000__p_inside ?g ?t))
    :effect (d000__p_has ?n ?p)
  )

  (:action d000__a_receive_queen_kiss
    :parameters (?n - d000__t_entity ?q - d000__t_entity)
    :precondition (d000__p_at ?n d000__c_palace)
    :effect (and (d000__p_kissed_by ?n ?q) (d000__p_joyful ?n) (not (d000__p_gloomy ?n)))
  )

  (:action d000__a_return_to_bench_and_share_story
    :parameters (?g - d000__t_entity ?m - d000__t_entity ?n - d000__t_entity ?bench - d000__t_location)
    :precondition (d000__p_at ?n d000__c_palace)
    :effect (and (d000__p_at ?n ?bench) (d000__p_story_shared ?n ?m) (d000__p_story_shared ?n ?g) (not (d000__p_at ?n d000__c_palace)))
  )

  (:action d000__a_travel_by_leaf_boat_under_pond
    :parameters (?n - d000__t_entity ?b - d000__t_item ?palace - d000__t_location ?pond - d000__t_location)
    :precondition (and (d000__p_stairs_descended ?n) (d000__p_boat_available ?b ?pond))
    :effect (d000__p_at ?n ?palace)
  )

  (:action d000__a_travel_to_trysting_place
    :parameters (?n - d000__t_entity ?b - d000__t_location ?c - d000__t_location)
    :precondition (d000__p_at ?n ?c)
    :effect (and (d000__p_at ?n ?b) (not (d000__p_at ?n ?c)))
  )

  (:action d000__a_turn_key_on_beech
    :parameters (?n - d000__t_entity ?k - d000__t_item ?t - d000__t_location)
    :precondition (d000__p_at ?n ?t)
    :effect (and (d000__p_door_open d000__c_door) (d000__p_inside d000__c_dryad ?t) (d000__p_invitation_offered d000__c_dryad ?n) (d000__p_has ?n ?k))
  )

  (:action d000__a_witness_queen_birthday_ceremony
    :parameters (?n - d000__t_entity ?q - d000__t_entity ?palace - d000__t_location)
    :precondition (d000__p_at ?n ?palace)
    :effect (and (d000__p_joyful ?n) (d000__p_story_shared ?q ?n))
  )
)
