(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_boar d000__c_dove d000__c_dwarf1 d000__c_dwarf2 d000__c_dwarf3 d000__c_dwarf4 d000__c_dwarf5 d000__c_dwarf6 d000__c_dwarf7 d000__c_huntsman d000__c_king d000__c_owl d000__c_prince d000__c_queen d000__c_raven d000__c_snow_white - d000__t_entity
    d000__c_apple d000__c_bed d000__c_blood_drop d000__c_boar_heart d000__c_candle d000__c_coffin d000__c_comb d000__c_fork d000__c_golden_letter d000__c_iron_slippers d000__c_knife d000__c_lace d000__c_looking_glass d000__c_mug d000__c_needle d000__c_plate d000__c_red_hot_shoes d000__c_salt d000__c_spoon - d000__t_item
    d000__c_cottage d000__c_forest d000__c_mountain - d000__t_location
  )
  (:predicates
    (d000__p_alive ?e - d000__t_entity)
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_at_item ?i - d000__t_item ?l - d000__t_location)
    (d000__p_awake ?e - d000__t_entity)
    (d000__p_dead ?e - d000__t_entity)
    (d000__p_disguised_as ?e - d000__t_entity ?d - d000__t_entity)
    (d000__p_envious ?e - d000__t_entity)
    (d000__p_fair ?e - d000__t_entity)
    (d000__p_fairest ?e - d000__t_entity)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_in_coffin ?e - d000__t_entity)
    (d000__p_laced ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_poisoned ?i - d000__t_item)
    (d000__p_sleeping ?e - d000__t_entity)
    (d000__p_visited ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_wearing ?e - d000__t_entity ?i - d000__t_item)
  )

  (:action d000__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - d000__t_entity ?apple - d000__t_item)
    :precondition (and (d000__p_dead ?c) (d000__p_poisoned ?apple))
    :effect (and (d000__p_alive ?c) (not (d000__p_dead ?c)) (not (d000__p_poisoned ?apple)))
  )

  (:action d000__a_child_is_born_and_queen_dies
    :parameters (?c - d000__t_entity ?q - d000__t_entity)
    :precondition (and (not (d000__p_alive ?c)) (d000__p_alive ?q))
    :effect (and (d000__p_alive ?c) (d000__p_dead ?q) (not (d000__p_alive ?q)))
  )

  (:action d000__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - d000__t_entity ?d - d000__t_entity ?lace - d000__t_item)
    :precondition (and (d000__p_laced ?c ?lace) (d000__p_dead ?c))
    :effect (and (d000__p_alive ?c) (d000__p_awake ?c) (not (d000__p_laced ?c ?lace)) (not (d000__p_dead ?c)))
  )

  (:action d000__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - d000__t_entity ?d - d000__t_entity)
    :precondition (and (d000__p_alive ?d) (d000__p_alive ?c) (d000__p_sleeping ?c))
    :effect (and (d000__p_awake ?c) (not (d000__p_sleeping ?c)))
  )

  (:action d000__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - d000__t_entity ?d - d000__t_entity ?coffin - d000__t_item)
    :precondition (d000__p_dead ?c)
    :effect (and (d000__p_in_coffin ?c) (d000__p_has ?d ?coffin))
  )

  (:action d000__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - d000__t_entity ?d - d000__t_entity ?comb - d000__t_item)
    :precondition (and (d000__p_dead ?c) (d000__p_poisoned ?comb) (d000__p_has ?d ?comb))
    :effect (and (d000__p_alive ?c) (not (d000__p_dead ?c)) (not (d000__p_poisoned ?comb)))
  )

  (:action d000__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - d000__t_entity ?d - d000__t_entity)
    :precondition (and (d000__p_alive ?d) (d000__p_sleeping ?c))
    :effect (d000__p_awake ?d)
  )

  (:action d000__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - d000__t_entity ?c - d000__t_entity ?h - d000__t_entity ?heart - d000__t_item)
    :precondition (and (d000__p_alive ?h) (d000__p_alive ?c) (d000__p_alive ?b))
    :effect (and (d000__p_has ?h ?heart) (d000__p_dead ?b))
  )

  (:action d000__a_king_marries_stepmother
    :parameters (?k - d000__t_entity ?s - d000__t_entity)
    :precondition (and (d000__p_alive ?k) (d000__p_alive ?s))
    :effect (d000__p_fair ?s)
  )

  (:action d000__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - d000__t_entity ?p - d000__t_entity ?coffin - d000__t_item ?mountain - d000__t_location)
    :precondition (and (d000__p_in_coffin ?c) (d000__p_alive ?p))
    :effect (d000__p_at_item ?coffin ?mountain)
  )

  (:action d000__a_prince_marries_snow_white
    :parameters (?c - d000__t_entity ?p - d000__t_entity)
    :precondition (and (d000__p_alive ?p) (d000__p_alive ?c))
    :effect (d000__p_fair ?p)
  )

  (:action d000__a_queen_pricks_finger
    :parameters (?q - d000__t_entity ?blood - d000__t_item ?needle - d000__t_item)
    :precondition (and (d000__p_alive ?q) (d000__p_has ?q ?needle))
    :effect (d000__p_has ?q ?blood)
  )

  (:action d000__a_queen_sews_at_window
    :parameters (?q - d000__t_entity ?l - d000__t_location)
    :precondition (and (d000__p_alive ?q) (d000__p_at ?q ?l))
    :effect (d000__p_has ?q d000__c_needle)
  )

  (:action d000__a_queen_wishes_child_white_red_black
    :parameters (?c - d000__t_entity ?q - d000__t_entity)
    :precondition (d000__p_alive ?q)
    :effect (d000__p_fair ?c)
  )

  (:action d000__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - d000__t_entity ?apple - d000__t_item)
    :precondition (and (d000__p_poisoned ?apple) (d000__p_alive ?c))
    :effect (and (d000__p_dead ?c) (not (d000__p_alive ?c)))
  )

  (:action d000__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - d000__t_entity ?mug - d000__t_item ?plate - d000__t_item)
    :precondition (d000__p_alive ?c)
    :effect (and (d000__p_has ?c ?plate) (d000__p_has ?c ?mug))
  )

  (:action d000__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - d000__t_entity ?cottage - d000__t_location)
    :precondition (d000__p_alive ?c)
    :effect (d000__p_at ?c ?cottage)
  )

  (:action d000__a_snow_white_flees_into_forest
    :parameters (?c - d000__t_entity ?f - d000__t_location)
    :precondition (d000__p_alive ?c)
    :effect (d000__p_at ?c ?f)
  )

  (:action d000__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - d000__t_entity ?bed - d000__t_item)
    :precondition (d000__p_alive ?c)
    :effect (d000__p_sleeping ?c)
  )

  (:action d000__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - d000__t_entity ?g - d000__t_item)
    :precondition (and (d000__p_alive ?s) (d000__p_has ?s ?g))
    :effect (d000__p_fairest ?s)
  )

  (:action d000__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - d000__t_entity ?slippers - d000__t_item)
    :precondition (d000__p_alive ?s)
    :effect (and (d000__p_wearing ?s ?slippers) (d000__p_dead ?s) (not (d000__p_alive ?s)))
  )

  (:action d000__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - d000__t_entity ?s - d000__t_entity)
    :precondition (and (d000__p_fairest ?c) (d000__p_fair ?c) (d000__p_alive ?s))
    :effect (d000__p_envious ?s)
  )

  (:action d000__a_stepmother_comb_poison_snow_white
    :parameters (?c - d000__t_entity ?s - d000__t_entity ?comb - d000__t_item)
    :precondition (and (d000__p_has ?s ?comb) (d000__p_poisoned ?comb) (d000__p_alive ?c))
    :effect (and (d000__p_dead ?c) (not (d000__p_alive ?c)))
  )

  (:action d000__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - d000__t_entity ?s - d000__t_entity ?cottage - d000__t_location)
    :precondition (d000__p_alive ?s)
    :effect (and (d000__p_disguised_as ?s ?old_woman) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - d000__t_entity ?heart - d000__t_item)
    :precondition (d000__p_has ?s ?heart)
    :effect (not (d000__p_has ?s ?heart))
  )

  (:action d000__a_stepmother_laces_snow_white_tightly
    :parameters (?c - d000__t_entity ?s - d000__t_entity ?lace - d000__t_item)
    :precondition (and (d000__p_alive ?c) (d000__p_has ?c ?lace))
    :effect (and (d000__p_laced ?c ?lace) (d000__p_dead ?c) (not (d000__p_alive ?c)) (not (d000__p_sleeping ?c)))
  )

  (:action d000__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - d000__t_entity ?apple - d000__t_item ?cottage - d000__t_location)
    :precondition (d000__p_alive ?s)
    :effect (and (d000__p_poisoned ?apple) (d000__p_has ?s ?apple) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - d000__t_entity ?comb - d000__t_item ?cottage - d000__t_location)
    :precondition (d000__p_alive ?s)
    :effect (and (d000__p_poisoned ?comb) (d000__p_has ?s ?comb) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - d000__t_entity ?h - d000__t_entity ?s - d000__t_entity)
    :precondition (and (d000__p_envious ?s) (d000__p_alive ?h) (d000__p_alive ?c))
    :effect (d000__p_fair ?s)
  )
)
