(define (domain unified_narrative_domain)
  (:requirements :disjunctive-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ant_queen boar coachman dove dwarf1 dwarf2 dwarf3 dwarf4 dwarf5 dwarf6 dwarf7 eldest_son elf_chief father_king first_traveler_mouse fourth_traveler_mouse groom huntsman impostor_butterman jack jailer jailer_granddaughter king king_at_palace miller mouse_king oak_dryad ogre old_lady_mouse old_owl owl phantaesus prince princess puss queen raven rema_np__c_princess robber_chief second_son second_traveler_mouse snow__c_king snow_white third_traveler_mouse watchman young_lady_mouse - entity
    apple ass bag bag_of_rubies bag_of_sapphires bed blood_drop boar_heart boots candle coffin comb crape_skewer crown fork golden_letter hare iron_slippers knife lace looking_glass maypole mill mug needle partridge plate rabbit red_hot_shoes salt sausage_skewer sceptre spoon suit violet - item
    back_door back_stairs castle city cottage field_of_corn field_of_wheat forest kitchen library market_place mountain north oak_tree ogre_castle palace rema_np__c_palace river royal_wardrobe sea ship snow__c_forest soup__c_forest warren - location
  )
  (:predicates
    (alive ?x - entity)
    (anointed ?i - item)
    (at ?x - entity ?l - location)
    (at_item ?i - item ?l - location)
    (awake ?e - entity)
    (captured ?e - entity)
    (castle_owned_by ?castle - location ?owner - entity)
    (contains ?c - item ?i - item)
    (disguised_as ?e - entity ?d - entity)
    (drowning ?e - entity)
    (envious ?e - entity)
    (fair ?e - entity)
    (fairest ?e - entity)
    (gate_open ?castle - location)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (grandmother_mangle_spoken)
    (has ?e - entity ?i - item)
    (has_feeling ?e - entity)
    (has_imagination ?e - entity)
    (has_understanding ?e - entity)
    (in_cage ?e - entity)
    (in_coffin ?e - entity)
    (is_poet ?e - entity)
    (is_queen ?e - entity)
    (king_tail_stirred)
    (laced ?e - entity ?i - item)
    (married ?e1 - entity ?e2 - entity)
    (obedient ?e - entity)
    (poisoned ?i - item)
    (price_of_butter_spoken)
    (promised_to_serve ?servant - entity ?master - entity)
    (rema_np__p_at ?e - entity ?l - location)
    (rema_np__p_married ?p1 - entity ?p2 - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (sleeping ?e - entity)
    (snow__p_alive ?e - entity)
    (snow__p_at ?e - entity ?l - location)
    (soup_effect_created ?e - entity)
    (state ?e - entity)
    (transformed_into ?e - entity ?form - entity)
    (visited ?e - entity ?l - location)
    (wearing ?e - entity ?i - item)
    (with_all_my_heart_spoken)
  )

  (:action apple_piece_falls_out_reviving_snow_white
    :parameters (?c - entity ?apple - item)
    :precondition (and (state ?c) (poisoned ?apple))
    :effect (and (snow__p_alive ?c) (not (state ?c)) (not (poisoned ?apple)))
  )

  (:action apply_item_to_entity
    :parameters (?e - entity ?i - item)
    :precondition (and (has ?e ?i))
    :effect (and (and (wearing ?e ?i) (laced ?e ?i) (state ?e) (not (has ?e ?i))))
  )

  (:action buy_boots
    :parameters (?jack ?puss - entity ?boots - item)
    :precondition (not (has ?puss ?boots))
    :effect (has ?puss ?boots)
  )

  (:action cat_call_for_help
    :parameters (?jack ?king ?puss - entity)
    :precondition (drowning ?jack)
    :effect (and (rescued_by ?jack ?king) (not (drowning ?jack)))
  )

  (:action cat_catch_rabbits
    :parameters (?puss - entity ?bag ?rabbit - item ?warren - location)
    :precondition (and (has ?puss ?bag) (at_item ?rabbit ?warren) (not (contains ?bag ?rabbit)))
    :effect (and (contains ?bag ?rabbit) (not (at_item ?rabbit ?warren)))
  )

  (:action cat_deliver_gifts_to_king
    :parameters (?king ?puss - entity ?bag ?rabbit - item ?palace - location)
    :precondition (and (contains ?bag ?rabbit) (at ?puss ?palace))
    :effect (and (gift_delivered ?puss ?king ?rabbit) (not (contains ?bag ?rabbit)))
  )

  (:action cat_disentchant_prisoners
    :parameters (?person ?puss - entity)
    :precondition (alive ?puss)
    :effect (promised_to_serve ?person jack)
  )

  (:action cat_eat_captured_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (and (captured ?mouse) (transformed_into ?ogre ?mouse))
    :effect (and (not (transformed_into ?ogre ?mouse)) (not (captured ?mouse)))
  )

  (:action cat_ogre_transform_lion
    :parameters (?lion ?ogre ?puss - entity)
    :precondition (and (at ?puss ogre_castle) (alive ?ogre))
    :effect (transformed_into ?ogre ?lion)
  )

  (:action cat_ogre_transform_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (alive ?ogre)
    :effect (transformed_into ?ogre ?mouse)
  )

  (:action cat_open_castle_gates
    :parameters (?king ?puss - entity ?castle - location)
    :precondition (at ?king ?castle)
    :effect (gate_open ?castle)
  )

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
  )

  (:action child_is_born_and_queen_dies
    :parameters (?c ?q - entity)
    :precondition (and (not (snow__p_alive ?c)) (snow__p_alive ?q))
    :effect (and (snow__p_alive ?c) (state ?q) (not (snow__p_alive ?q)))
  )

  (:action declare_fairest
    :parameters (?s - entity ?g - item)
    :precondition (and (snow__p_alive ?s) (has ?s ?g))
    :effect (fairest ?s)
  )

  (:action dwarfs_cut_laces_rescue_snow_white
    :parameters (?c ?d - entity ?lace - item)
    :precondition (and (laced ?c ?lace) (state ?c))
    :effect (and (snow__p_alive ?c) (awake ?c) (not (laced ?c ?lace)) (not (state ?c)))
  )

  (:action dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c ?d - entity)
    :precondition (and (snow__p_alive ?d) (snow__p_alive ?c) (sleeping ?c))
    :effect (and (awake ?c) (not (sleeping ?c)))
  )

  (:action dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c ?d - entity ?coffin - item)
    :precondition (state ?c)
    :effect (and (in_coffin ?c) (has ?d ?coffin))
  )

  (:action dwarfs_remove_comb_rescue_snow_white
    :parameters (?c ?d - entity ?comb - item)
    :precondition (and (state ?c) (poisoned ?comb) (has ?d ?comb))
    :effect (and (snow__p_alive ?c) (not (state ?c)) (not (poisoned ?comb)))
  )

  (:action dwarfs_return_and_discover_snow_white
    :parameters (?c ?d - entity)
    :precondition (and (snow__p_alive ?d) (sleeping ?c))
    :effect (awake ?d)
  )

  (:action encounter_impostor_king
    :parameters (?i ?p - entity)
    :precondition (and (rema_np__p_at ?p city) (rema_np__p_at ?i market_place))
    :effect (and (rema_np__p_at ?p market_place) (not (rema_np__p_at ?p city)))
  )

  (:action encounter_robbers_in_forest
    :parameters (?p - entity)
    :precondition (rema_np__p_at ?p forest)
    :effect (and (rema_np__p_at ?p oak_tree) (not (rema_np__p_at ?p forest)))
  )

  (:action escape_jail
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (and (state ?m) (not (captured ?m)) (not (in_cage ?m)))
  )

  (:action flee_to_location
    :parameters (?e - entity ?l - location)
    :precondition (and (snow__p_alive ?e))
    :effect (and (not (rema_np__p_at ?e back_stairs)) (snow__p_at ?e ?l))
  )

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
  )

  (:action give_skewer_to_elves
    :parameters (?elf ?m - entity)
    :precondition (has ?m sausage_skewer)
    :effect (and (has ?elf sausage_skewer) (not (has ?m sausage_skewer)))
  )

  (:action huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b ?c ?h - entity ?heart - item)
    :precondition (and (snow__p_alive ?h) (snow__p_alive ?c) (snow__p_alive ?b))
    :effect (and (has ?h ?heart) (state ?b))
  )

  (:action king_marries_stepmother
    :parameters (?k ?s - entity)
    :precondition (and (snow__p_alive ?k) (snow__p_alive ?s))
    :effect (fair ?s)
  )

  (:action king_requests_information_and_gifts
    :parameters (?k ?p - entity ?r ?s - item)
    :precondition (and (rema_np__p_at ?p rema_np__c_palace) (has ?p ?r) (has ?p ?s) (rema_np__p_at ?k rema_np__c_palace))
    :effect (and (has ?k ?r) (has ?k ?s) (not (has ?p ?r)) (not (has ?p ?s)))
  )

  (:action learn_wisdom_from_ants
    :parameters (?m - entity ?ant_loc - location)
    :precondition (snow__p_at ?m ?ant_loc)
    :effect (has_understanding ?m)
  )

  (:action master_marry_princess
    :parameters (?jack ?princess - entity)
    :precondition (and (not (married ?jack ?princess)) (at ?jack palace))
    :effect (married ?jack ?princess)
  )

  (:action place_at_location
    :parameters (?e - entity ?l - location)
    :precondition (and (rema_np__p_at ?e ?l))
    :effect (and (snow__p_at ?e ?l))
  )

  (:action prepare_soup_by_elf_effect
    :parameters (?m - entity)
    :precondition (and (has ?m sausage_skewer) (anointed sausage_skewer) (snow__p_at ?m kitchen))
    :effect (soup_effect_created ?m)
  )

  (:action prepare_soup_by_king_tail
    :parameters (?k - entity)
    :precondition (snow__p_at mouse_king kitchen)
    :effect (king_tail_stirred)
  )

  (:action prepare_soup_by_poet_imagination
    :parameters (?m - entity)
    :precondition (and (has_understanding ?m) (has_imagination ?m) (has_feeling ?m))
    :effect (and (soup_effect_created ?m) (is_poet ?m))
  )

  (:action prince_discovers_coffin_and_moves_it
    :parameters (?c ?p - entity ?coffin - item ?mountain - location)
    :precondition (and (in_coffin ?c) (snow__p_alive ?p))
    :effect (at_item ?coffin ?mountain)
  )

  (:action prince_marries_snow_white
    :parameters (?c ?p - entity)
    :precondition (and (snow__p_alive ?p) (snow__p_alive ?c))
    :effect (fair ?p)
  )

  (:action princess_accepts_with_heart
    :parameters (?k ?p - entity)
    :precondition (and (rema_np__p_married ?p ?k) (not (with_all_my_heart_spoken)))
    :effect (with_all_my_heart_spoken)
  )

  (:action queen_ascend_to_throne
    :parameters (?q - entity ?l - location)
    :precondition (and (snow__p_alive ?q) (snow__p_at ?q ?l) (or (soup_effect_created ?q) (king_tail_stirred)))
    :effect (is_queen ?q)
  )

  (:action queen_pricks_finger
    :parameters (?q - entity ?blood ?needle - item)
    :precondition (and (snow__p_alive ?q) (has ?q ?needle))
    :effect (has ?q ?blood)
  )

  (:action queen_wishes_child_white_red_black
    :parameters (?c ?q - entity)
    :precondition (snow__p_alive ?q)
    :effect (fair ?c)
  )

  (:action read_and_digest_books
    :parameters (?m - entity ?lib - location)
    :precondition (snow__p_at ?m library)
    :effect (has_feeling ?m)
  )

  (:action receive_anointed_skewer
    :parameters (?elf ?m - entity ?v - item)
    :precondition (and (has ?m sausage_skewer) (has ?elf violet))
    :effect (anointed sausage_skewer)
  )

  (:action receive_feather
    :parameters (?dryad ?m ?ph - entity ?feather - item ?loc - location)
    :precondition (and (snow__p_at ?m ?loc) (snow__p_at ?dryad ?loc) (snow__p_at ?ph ?loc) (has ?dryad ?feather))
    :effect (and (has ?m ?feather) (has_imagination ?m))
  )

  (:action receive_rubies_from_impostor
    :parameters (?i ?p - entity ?r - item)
    :precondition (and (price_of_butter_spoken) (rema_np__p_at ?p market_place) (has ?i ?r))
    :effect (and (has ?p ?r) (not (has ?i ?r)))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (rema_np__p_at ?p oak_tree) (has ?c ?s))
    :effect (and (has ?p ?s) (not (has ?c ?s)))
  )

  (:action snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - entity ?apple - item)
    :precondition (and (poisoned ?apple) (snow__p_alive ?c))
    :effect (and (state ?c) (not (snow__p_alive ?c)))
  )

  (:action snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - entity ?mug ?plate - item)
    :precondition (snow__p_alive ?c)
    :effect (and (has ?c ?plate) (has ?c ?mug))
  )

  (:action snow_white_sleeps_in_seventh_bed
    :parameters (?c - entity ?bed - item)
    :precondition (snow__p_alive ?c)
    :effect (sleeping ?c)
  )

  (:action stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - entity ?slippers - item)
    :precondition (snow__p_alive ?s)
    :effect (and (wearing ?s ?slippers) (state ?s) (not (snow__p_alive ?s)))
  )

  (:action stepmother_becomes_envious_of_snow_white
    :parameters (?c ?s - entity)
    :precondition (and (fairest ?c) (fair ?c) (snow__p_alive ?s))
    :effect (envious ?s)
  )

  (:action stepmother_comb_poison_snow_white
    :parameters (?c ?s - entity ?comb - item)
    :precondition (and (has ?s ?comb) (poisoned ?comb) (snow__p_alive ?c))
    :effect (and (state ?c) (not (snow__p_alive ?c)))
  )

  (:action stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman ?s - entity ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (disguised_as ?s ?old_woman) (visited ?s ?cottage))
  )

  (:action stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - entity ?heart - item)
    :precondition (has ?s ?heart)
    :effect (not (has ?s ?heart))
  )

  (:action stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - entity ?apple - item ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (poisoned ?apple) (has ?s ?apple) (visited ?s ?cottage))
  )

  (:action stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - entity ?comb - item ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (poisoned ?comb) (has ?s ?comb) (visited ?s ?cottage))
  )

  (:action stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c ?h ?s - entity)
    :precondition (and (envious ?s) (snow__p_alive ?h) (snow__p_alive ?c))
    :effect (fair ?s)
  )

  (:action suitors_retire_due_to_phrase
    :parameters (?s - entity)
    :precondition (and (grandmother_mangle_spoken) (rema_np__p_at ?s rema_np__c_palace))
    :effect (not (rema_np__p_married ?s rema_np__c_princess))
  )

  (:action travel_to
    :parameters (?m - entity ?dest ?orig - location)
    :precondition (and (snow__p_at ?m ?orig) (has ?m sausage_skewer))
    :effect (and (snow__p_at ?m ?dest) (not (snow__p_at ?m ?orig)))
  )

  (:action utter_phrase_grandmother_mangle
    :parameters (?p - entity)
    :precondition (and (rema_np__p_at ?p oak_tree) (not (grandmother_mangle_spoken)))
    :effect (grandmother_mangle_spoken)
  )

  (:action utter_phrase_price_of_butter
    :parameters (?p - entity)
    :precondition (and (rema_np__p_at ?p market_place) (not (price_of_butter_spoken)))
    :effect (price_of_butter_spoken)
  )
)
