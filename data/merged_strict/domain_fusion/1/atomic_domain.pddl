(define (domain The_Birthday_Honors_Of_The_Fairy_Queen)
  (:requirements :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    dryad fairy_queen gnome grandmother grandmotherkin mother mothereen nora - entity
    boat gold_star key lantern pellet silver_salver - item
    beech_tree bench corridor cottage door fairyland palace pond spring stairs stream - location
  )
  (:predicates
    (at ?e - entity ?l - location)
    (boat_available ?b - item ?l - location)
    (corridor_reached ?e - entity)
    (door_open ?d - location)
    (gloomy ?e - entity)
    (gold_star_on ?e - entity ?s - item)
    (has ?e - entity ?i - item)
    (inside ?e - entity ?l - location)
    (invitation_offered ?from - entity ?to - entity)
    (joyful ?e - entity)
    (kissed_by ?e - entity ?k - entity)
    (knighted ?e - entity)
    (lantern_carried ?e - entity ?l - item)
    (pellet_eaten ?e - entity)
    (shrunk ?e - entity)
    (sound_heard ?e - entity ?l - location)
    (stairs_descended ?e - entity)
    (story_shared ?speaker - entity ?listener - entity)
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

  (:action hear_tapping_on_beech
    :parameters (?n - entity ?t - location)
    :precondition (at ?n bench)
    :effect (sound_heard ?n ?t)
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

  (:action return_to_bench_and_share_story
    :parameters (?g ?m ?n - entity ?bench - location)
    :precondition (at ?n palace)
    :effect (and (at ?n ?bench) (story_shared ?n ?m) (story_shared ?n ?g) (not (at ?n palace)))
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
)
