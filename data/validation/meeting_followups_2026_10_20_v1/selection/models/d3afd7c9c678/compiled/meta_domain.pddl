(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_apple d000__c_bed d000__c_blood_drop d000__c_boar d000__c_boar_heart d000__c_candle d000__c_coffin d000__c_comb d000__c_cottage d000__c_dove d000__c_dwarf1 d000__c_dwarf2 d000__c_dwarf3 d000__c_dwarf4 d000__c_dwarf5 d000__c_dwarf6 d000__c_dwarf7 d000__c_forest d000__c_fork d000__c_golden_letter d000__c_huntsman d000__c_iron_slippers d000__c_king d000__c_knife d000__c_lace d000__c_looking_glass d000__c_mountain d000__c_mug d000__c_needle d000__c_owl d000__c_plate d000__c_prince d000__c_queen d000__c_raven d000__c_red_hot_shoes d000__c_salt d000__c_snow_white d000__c_spoon - object
  )
  (:predicates
    (d000__p_alive ?a0 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_at_item ?a0 - object ?a1 - object)
    (d000__p_awake ?a0 - object)
    (d000__p_dead ?a0 - object)
    (d000__p_disguised_as ?a0 - object ?a1 - object)
    (d000__p_envious ?a0 - object)
    (d000__p_fair ?a0 - object)
    (d000__p_fairest ?a0 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_in_coffin ?a0 - object)
    (d000__p_laced ?a0 - object ?a1 - object)
    (d000__p_poisoned ?a0 - object)
    (d000__p_sleeping ?a0 - object)
    (d000__p_visited ?a0 - object ?a1 - object)
    (d000__p_wearing ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_apple_piece_falls_out_reviving_snow_white
    :parameters (?c - object ?apple - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_item ?apple) (and (d000__p_dead ?c) (d000__p_poisoned ?apple)))
    :effect (and (d000__p_alive ?c) (not (d000__p_dead ?c)) (not (d000__p_poisoned ?apple)))
  )

  (:action d000__a_child_is_born_and_queen_dies
    :parameters (?c - object ?q - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?q) (and (not (d000__p_alive ?c)) (d000__p_alive ?q)))
    :effect (and (d000__p_alive ?c) (d000__p_dead ?q) (not (d000__p_alive ?q)))
  )

  (:action d000__a_dwarfs_cut_laces_rescue_snow_white
    :parameters (?c - object ?d - object ?lace - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?d) (typeguard__d000__t_item ?lace) (and (d000__p_laced ?c ?lace) (d000__p_dead ?c)))
    :effect (and (d000__p_alive ?c) (d000__p_awake ?c) (not (d000__p_laced ?c ?lace)) (not (d000__p_dead ?c)))
  )

  (:action d000__a_dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c - object ?d - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?d) (and (d000__p_alive ?d) (d000__p_alive ?c) (d000__p_sleeping ?c)))
    :effect (and (d000__p_awake ?c) (not (d000__p_sleeping ?c)))
  )

  (:action d000__a_dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c - object ?d - object ?coffin - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?d) (typeguard__d000__t_item ?coffin) (d000__p_dead ?c))
    :effect (and (d000__p_in_coffin ?c) (d000__p_has ?d ?coffin))
  )

  (:action d000__a_dwarfs_remove_comb_rescue_snow_white
    :parameters (?c - object ?d - object ?comb - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?d) (typeguard__d000__t_item ?comb) (and (d000__p_dead ?c) (d000__p_poisoned ?comb) (d000__p_has ?d ?comb)))
    :effect (and (d000__p_alive ?c) (not (d000__p_dead ?c)) (not (d000__p_poisoned ?comb)))
  )

  (:action d000__a_dwarfs_return_and_discover_snow_white
    :parameters (?c - object ?d - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?d) (and (d000__p_alive ?d) (d000__p_sleeping ?c)))
    :effect (d000__p_awake ?d)
  )

  (:action d000__a_huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b - object ?c - object ?h - object ?heart - object)
    :precondition (and (typeguard__d000__t_entity ?b) (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?h) (typeguard__d000__t_item ?heart) (and (d000__p_alive ?h) (d000__p_alive ?c) (d000__p_alive ?b)))
    :effect (and (d000__p_has ?h ?heart) (d000__p_dead ?b))
  )

  (:action d000__a_king_marries_stepmother
    :parameters (?k - object ?s - object)
    :precondition (and (typeguard__d000__t_entity ?k) (typeguard__d000__t_entity ?s) (and (d000__p_alive ?k) (d000__p_alive ?s)))
    :effect (d000__p_fair ?s)
  )

  (:action d000__a_prince_discovers_coffin_and_moves_it
    :parameters (?c - object ?p - object ?coffin - object ?mountain - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?coffin) (typeguard__d000__t_location ?mountain) (and (d000__p_in_coffin ?c) (d000__p_alive ?p)))
    :effect (d000__p_at_item ?coffin ?mountain)
  )

  (:action d000__a_prince_marries_snow_white
    :parameters (?c - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?p) (and (d000__p_alive ?p) (d000__p_alive ?c)))
    :effect (d000__p_fair ?p)
  )

  (:action d000__a_queen_pricks_finger
    :parameters (?q - object ?blood - object ?needle - object)
    :precondition (and (typeguard__d000__t_entity ?q) (typeguard__d000__t_item ?blood) (typeguard__d000__t_item ?needle) (and (d000__p_alive ?q) (d000__p_has ?q ?needle)))
    :effect (d000__p_has ?q ?blood)
  )

  (:action d000__a_queen_sews_at_window
    :parameters (?q - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?q) (typeguard__d000__t_location ?l) (and (d000__p_alive ?q) (d000__p_at ?q ?l)))
    :effect (d000__p_has ?q d000__c_needle)
  )

  (:action d000__a_queen_wishes_child_white_red_black
    :parameters (?c - object ?q - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?q) (d000__p_alive ?q))
    :effect (d000__p_fair ?c)
  )

  (:action d000__a_snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - object ?apple - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_item ?apple) (and (d000__p_poisoned ?apple) (d000__p_alive ?c)))
    :effect (and (d000__p_dead ?c) (not (d000__p_alive ?c)))
  )

  (:action d000__a_snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - object ?mug - object ?plate - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_item ?mug) (typeguard__d000__t_item ?plate) (d000__p_alive ?c))
    :effect (and (d000__p_has ?c ?plate) (d000__p_has ?c ?mug))
  )

  (:action d000__a_snow_white_finds_dwarfs_cottage
    :parameters (?c - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_location ?cottage) (d000__p_alive ?c))
    :effect (d000__p_at ?c ?cottage)
  )

  (:action d000__a_snow_white_flees_into_forest
    :parameters (?c - object ?f - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_location ?f) (d000__p_alive ?c))
    :effect (d000__p_at ?c ?f)
  )

  (:action d000__a_snow_white_sleeps_in_seventh_bed
    :parameters (?c - object ?bed - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_item ?bed) (d000__p_alive ?c))
    :effect (d000__p_sleeping ?c)
  )

  (:action d000__a_stepmother_asks_looking_glass_fairest
    :parameters (?s - object ?g - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?g) (and (d000__p_alive ?s) (d000__p_has ?s ?g)))
    :effect (d000__p_fairest ?s)
  )

  (:action d000__a_stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - object ?slippers - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?slippers) (d000__p_alive ?s))
    :effect (and (d000__p_wearing ?s ?slippers) (d000__p_dead ?s) (not (d000__p_alive ?s)))
  )

  (:action d000__a_stepmother_becomes_envious_of_snow_white
    :parameters (?c - object ?s - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?s) (and (d000__p_fairest ?c) (d000__p_fair ?c) (d000__p_alive ?s)))
    :effect (d000__p_envious ?s)
  )

  (:action d000__a_stepmother_comb_poison_snow_white
    :parameters (?c - object ?s - object ?comb - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?comb) (and (d000__p_has ?s ?comb) (d000__p_poisoned ?comb) (d000__p_alive ?c)))
    :effect (and (d000__p_dead ?c) (not (d000__p_alive ?c)))
  )

  (:action d000__a_stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman - object ?s - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?old_woman) (typeguard__d000__t_entity ?s) (typeguard__d000__t_location ?cottage) (d000__p_alive ?s))
    :effect (and (d000__p_disguised_as ?s ?old_woman) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - object ?heart - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?heart) (d000__p_has ?s ?heart))
    :effect (not (d000__p_has ?s ?heart))
  )

  (:action d000__a_stepmother_laces_snow_white_tightly
    :parameters (?c - object ?s - object ?lace - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?lace) (and (d000__p_alive ?c) (d000__p_has ?c ?lace)))
    :effect (and (d000__p_laced ?c ?lace) (d000__p_dead ?c) (not (d000__p_alive ?c)) (not (d000__p_sleeping ?c)))
  )

  (:action d000__a_stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - object ?apple - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?apple) (typeguard__d000__t_location ?cottage) (d000__p_alive ?s))
    :effect (and (d000__p_poisoned ?apple) (d000__p_has ?s ?apple) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - object ?comb - object ?cottage - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_item ?comb) (typeguard__d000__t_location ?cottage) (d000__p_alive ?s))
    :effect (and (d000__p_poisoned ?comb) (d000__p_has ?s ?comb) (d000__p_visited ?s ?cottage))
  )

  (:action d000__a_stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c - object ?h - object ?s - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?h) (typeguard__d000__t_entity ?s) (and (d000__p_envious ?s) (d000__p_alive ?h) (d000__p_alive ?c)))
    :effect (d000__p_fair ?s)
  )
)
