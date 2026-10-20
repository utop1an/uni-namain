(define (domain unified_narrative_domain)
  (:requirements :disjunctive-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ant_queen ass boar brown_hen bungo butcher captain cat coachman cock comet_master dove dwarf1 dwarf2 dwarf3 dwarf4 dwarf5 dwarf6 dwarf7 earth eldest_son elf_chief fairy_maiden farmer father_king first_traveler_mouse fourth_traveler_mouse giant giant_dog giant_wife groom hound huntsman impostor_butterman jack jack_mother jailer jailer_granddaughter king king_at_palace long_tail_45 man man_bricks man_furze man_straw messenger meteor meteor_keeper milky_white miller mother_pig mouse_king no1_express oak_dryad ogre old_lady_mouse old_owl owl phantaesus pig1 pig2 pig3 prince princess puss puss__c_jack queen raven rema_np__c_princess robber robber_chief second_son second_traveler_mouse short_tail_73 snow__c_king snow_white squire sun third_traveler_mouse watchman wolf young_lady_mouse - entity
    apple axe bag bag_of_rubies bag_of_sapphires bed blood_drop boar_heart boots bricks butter_churn candle chalk coffin comb crape_skewer crown drinks fire fork furze_bundle gold_bag_1 gold_bag_2 golden_harp golden_letter hare iron_slippers kettledrums knife lace looking_glass lute magic_beans maypole meat mill mortar mug needle oak_tree_club partridge plate pot_of_water puss__c_apple puss__c_ass rabbit red_hot_shoes sack salt sausage_skewer sceptre slate spoon straw straw_bundle suit table trowel turnips_load violet - item
    back_door back_stairs beam beanstalk bremen brick_house castle castle_road chimney city comet_house cottage courtyard field_of_corn field_of_wheat forest furze_house garden gate giant_castle hearth hill kettle kitchen library market market_place mountain musi__c_window naug__c_hearth north oak_forest oak_tree ogre_castle oven palace pig_home puss__c_cottage puss__c_forest rema_np__c_palace river road_to_bremen robbers_cottage royal_wardrobe sea ship snow__c_forest soup__c_forest squire_orchard straw_house town_fair turnip_field warren window - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (alive ?x - entity)
    (anointed ?i - item)
    (arrested ?c - entity ?m - entity)
    (at ?x - entity ?l - location)
    (at_item ?i - item ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (avoid ?c - entity ?b - entity)
    (awake ?e - entity)
    (bad ?e - entity)
    (beanstalk_grown)
    (bite ?dog - entity ?target - entity)
    (boiling ?i - item)
    (burned ?c - entity)
    (captured ?e - entity)
    (castle_owned_by ?castle - location ?owner - entity)
    (climbing_down ?e - entity)
    (contains ?c - item ?i - item)
    (crowed ?cock - entity)
    (dead ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (disguised_as ?e - entity ?d - entity)
    (door_closed ?h - location)
    (drowning ?e - entity)
    (empty ?i - item)
    (entity ?e - entity)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (envious ?e - entity)
    (escaped ?e - entity)
    (fair ?e - entity)
    (fairest ?e - entity)
    (fled ?robber - entity ?loc - location)
    (gate_open)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (grandmother_mangle_spoken)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (has_bundle ?m - entity ?i - item)
    (has_imagination ?e - entity)
    (has_mission ?c - entity)
    (has_understanding ?e - entity)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (in_cage ?e - entity)
    (in_coffin ?e - entity)
    (inside ?e - entity ?i - item)
    (intact ?l - location)
    (invited ?inviter - entity ?invitee - entity)
    (is_poet ?e - entity)
    (is_queen ?e - entity)
    (kick ?donkey - entity ?target - entity)
    (king_tail_stirred)
    (laced ?e - entity ?i - item)
    (left_turn_rule ?c - entity)
    (light_off ?loc - location)
    (light_or_gate_open ?loc - location)
    (located ?i - item ?l - location)
    (location ?e - entity ?l - location)
    (making_noise ?e - entity)
    (married ?e1 - entity ?e2 - entity)
    (material_requested ?p - entity ?i - item)
    (moving_towards ?e - entity ?loc - location)
    (naug__p_inside ?e - entity ?c - item)
    (near ?c - entity ?b - entity)
    (obedient ?e - entity)
    (on_list ?c - entity)
    (over ?i1 - item ?i2 - item)
    (plan ?e - entity ?l - location)
    (planted ?i - item)
    (poisoned ?i - item)
    (possesses ?e - entity ?i - item)
    (price_of_butter_spoken)
    (prohibit_speak ?c - entity)
    (promised_to_serve ?servant - entity ?master - entity)
    (puffed ?w - entity)
    (rema_np__p_at ?e - entity ?l - location)
    (rema_np__p_married ?p1 - entity ?p2 - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (retreated ?robber - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (sees_light ?e - entity)
    (sleeping ?e - entity)
    (sleeping_at ?e - entity ?loc - location)
    (snow__p_alive ?e - entity)
    (snow__p_at ?e - entity ?l - location)
    (soup_effect_created ?e - entity)
    (speaks_to ?c - entity ?m - entity)
    (stacked_on ?top - entity ?bottom - entity)
    (state ?e - entity)
    (summoned ?c - entity)
    (transformed_into ?e - entity ?form - entity)
    (traveling ?c - entity)
    (wearing ?e - entity ?i - item)
    (window_shattered)
    (with_all_my_heart_spoken)
  )

  (:action apple_piece_falls_out_reviving_snow_white
    :parameters (?c - entity ?apple - item)
    :precondition (and (state ?c) (poisoned ?apple))
    :effect (and (snow__p_alive ?c) (not (state ?c)) (not (poisoned ?apple)))
  )

  (:action apply_item_to_entity
    :parameters (?e - entity ?i - item)
    :precondition (and (possesses ?e ?i))
    :effect (and (and (wearing ?e ?i) (laced ?e ?i) (state ?e) (not (possesses ?e ?i))))
  )

  (:action approach_location
    :parameters (?j - entity ?l - location)
    :precondition (and (location ?j beanstalk) (beanstalk_grown) (location ?j ?l))
    :effect (and (location ?j ?l) (moving_towards ?j ?l))
  )

  (:action arrest_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (near ?c ?m))
    :effect (and (arrested ?c ?m) (detained ?m))
  )

  (:action ask_for_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (has_bundle ?m ?i) (in_cage ?p) (in_cage ?m))
    :effect (material_requested ?p ?i)
  )

  (:action ask_giant_wife_for_breakfast
    :parameters (?j ?wife - entity)
    :precondition (and (location ?j giant_castle) (location ?wife giant_castle))
    :effect (has_breakfast ?j)
  )

  (:action attempt_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (in_cage ?w) (house_intact ?h))
    :effect (and (entry_requested ?w ?h) (light_off ?h))
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action build_house
    :parameters (?p - entity ?i - item ?h - location)
    :precondition (and (has ?p ?i) (in_cage ?p) (location ?p ?h))
    :effect (and (house ?h ?i) (house_intact ?h) (door_closed ?h) (not (has ?p ?i)))
  )

  (:action buy_boots
    :parameters (?jack ?puss - entity ?boots - item)
    :precondition (not (possesses ?puss ?boots))
    :effect (possesses ?puss ?boots)
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (location ?c courtyard) (location ?master courtyard))
    :effect (summoned ?c)
  )

  (:action call_for_help_and_disturb
    :parameters (?jack ?king ?puss - entity)
    :precondition (drowning ?jack)
    :effect (and (rescued_by ?jack ?king) (making_noise ?jack) (making_noise ?king) (making_noise ?puss))
  )

  (:action cat_attack_messenger
    :parameters (?cat ?messenger - entity)
    :precondition (and (attempt_light ?messenger) (location ?cat hearth))
    :effect (attacked ?cat ?messenger)
  )

  (:action cat_catch_rabbits
    :parameters (?puss - entity ?bag ?rabbit - item ?warren - location)
    :precondition (and (possesses ?puss ?bag) (at_item ?rabbit ?warren) (not (contains ?bag ?rabbit)))
    :effect (and (contains ?bag ?rabbit) (not (at_item ?rabbit ?warren)))
  )

  (:action cat_deliver_gifts_to_king
    :parameters (?king ?puss - entity ?bag ?rabbit - item ?palace - location)
    :precondition (and (contains ?bag ?rabbit) (at ?puss ?palace))
    :effect (and (gift_delivered ?puss ?king ?rabbit) (not (contains ?bag ?rabbit)))
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

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
  )

  (:action cat_promises
    :parameters (?cat ?person - entity)
    :precondition (and (invited ?person ?cat) (alive ?person))
    :effect (and (promised_to_serve ?person ?cat))
  )

  (:action cause_bad
    :parameters (?e - entity)
    :precondition (and (attempt_light ?e))
    :effect (and (bad ?e))
  )

  (:action child_is_born_and_queen_dies
    :parameters (?c ?q - entity)
    :precondition (and (not (snow__p_alive ?c)) (snow__p_alive ?q))
    :effect (and (snow__p_alive ?c) (state ?q) (not (snow__p_alive ?q)))
  )

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (location ?cat ?hearth) (location ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
  )

  (:action cock_agrees
    :parameters (?cock ?donkey - entity)
    :precondition (invited ?donkey ?cock)
    :effect (agreed ?cock ?donkey)
  )

  (:action collect_item_from_location
    :parameters (?p - entity ?i - item ?l - location)
    :precondition (and (in_cage ?p) (located ?i ?l))
    :effect (and (has ?p ?i) (not (located ?i ?l)))
  )

  (:action cut_beanstalk
    :parameters (?giant ?mother - entity ?axe - item)
    :precondition (and (intact beanstalk) (climbing_down ?giant))
    :effect (and (dead ?giant) (not (intact beanstalk)))
  )

  (:action declare_fairest
    :parameters (?s - entity ?g - item)
    :precondition (and (snow__p_alive ?s) (possesses ?s ?g))
    :effect (fairest ?s)
  )

  (:action deliver_meteor_to_bungo
    :parameters (?m - entity)
    :precondition (detained ?m)
    :effect (delivered ?m bungo)
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
    :effect (and (in_coffin ?c) (possesses ?d ?coffin))
  )

  (:action dwarfs_remove_comb_rescue_snow_white
    :parameters (?c ?d - entity ?comb - item)
    :precondition (and (state ?c) (poisoned ?comb) (possesses ?d ?comb))
    :effect (and (snow__p_alive ?c) (not (state ?c)) (not (poisoned ?comb)))
  )

  (:action dwarfs_return_and_discover_snow_white
    :parameters (?c ?d - entity)
    :precondition (and (snow__p_alive ?d) (sleeping ?c))
    :effect (awake ?d)
  )

  (:action eat_feast
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (location ?donkey ?cottage) (location ?hound ?cottage) (location ?cat ?cottage) (location ?cock ?cottage) (window_shattered))
    :effect (and (ate_all ?donkey) (ate_all ?hound) (ate_all ?cat) (ate_all ?cock))
  )

  (:action encounter_impostor_king
    :parameters (?i ?p - entity)
    :precondition (and (rema_np__p_at ?p city) (rema_np__p_at ?i market_place))
    :effect (and (rema_np__p_at ?p market_place) (not (rema_np__p_at ?p city)))
  )

  (:action encounter_robbers_in_forest
    :parameters (?p - entity)
    :precondition (rema_np__p_at ?p puss__c_forest)
    :effect (and (rema_np__p_at ?p oak_tree) (not (rema_np__p_at ?p puss__c_forest)))
  )

  (:action escape_from_confinement
    :parameters (?e - entity ?l - location)
    :precondition (and (in_cage ?e) (not (entry_denied ?e ?l)))
    :effect (and (fled ?e ?l) (not (in_cage ?e)) (not (captured ?e)))
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (location ?c courtyard) (location ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action give_skewer_to_elves
    :parameters (?elf ?m - entity)
    :precondition (possesses ?m sausage_skewer)
    :effect (and (possesses ?elf sausage_skewer) (not (possesses ?m sausage_skewer)))
  )

  (:action grow_beanstalk
    :parameters (?beans - item)
    :precondition (planted ?beans)
    :effect (and (beanstalk_grown) (intact beanstalk))
  )

  (:action hide_item
    :parameters (?e - entity ?i - item)
    :precondition (and (location ?e giant_castle) (empty ?i) (in_cage ?e))
    :effect (and (inside ?e ?i) (not (location ?e giant_castle)))
  )

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
  )

  (:action huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b ?c ?h - entity ?heart - item)
    :precondition (and (snow__p_alive ?h) (snow__p_alive ?c) (snow__p_alive ?b))
    :effect (and (possesses ?h ?heart) (state ?b))
  )

  (:action interact_with_entity
    :parameters (?m ?t - entity)
    :precondition (and (attempt_light ?m) (near ?m ?t))
    :effect (and (speaks_to ?m ?t) (bite ?m ?t))
  )

  (:action invite_cock
    :parameters (?cock ?donkey - entity ?loc - location)
    :precondition (and (location ?donkey ?loc) (location ?cock ?loc))
    :effect (invited ?donkey ?cock)
  )

  (:action invite_hound
    :parameters (?donkey ?hound - entity)
    :effect (invited ?donkey ?hound)
  )

  (:action king_marries_stepmother
    :parameters (?k ?s - entity)
    :precondition (and (snow__p_alive ?k) (snow__p_alive ?s))
    :effect (fair ?s)
  )

  (:action king_requests_information_and_gifts
    :parameters (?k ?p - entity ?r ?s - item)
    :precondition (and (rema_np__p_at ?p rema_np__c_palace) (possesses ?p ?r) (possesses ?p ?s) (rema_np__p_at ?k rema_np__c_palace))
    :effect (and (possesses ?k ?r) (possesses ?k ?s) (not (possesses ?p ?r)) (not (possesses ?p ?s)))
  )

  (:action learn_wisdom_from_ants
    :parameters (?m - entity ?ant_loc - location)
    :precondition (snow__p_at ?m ?ant_loc)
    :effect (has_understanding ?m)
  )

  (:action mark_as_crossed_out
    :parameters (?e - entity)
    :precondition (burned ?e)
    :effect (and (entity ?e) (not (on_list ?e)))
  )

  (:action master_marry_princess
    :parameters (?jack ?princess - entity)
    :precondition (and (not (married ?jack ?princess)) (at ?jack palace))
    :effect (married ?jack ?princess)
  )

  (:action messenger_attempt_light
    :parameters (?messenger - entity ?cottage - location)
    :precondition (light_off ?cottage)
    :effect (attempt_light ?messenger)
  )

  (:action move_to_location
    :parameters (?e - entity ?l - location)
    :precondition (location ?e ?l)
    :effect (and (not (location ?e ?l)) (at ?e ?l))
  )

  (:action move_towards_location
    :parameters (?e - entity ?l - location)
    :precondition (and (location ?e ?l))
    :effect (and (moving_towards ?e ?l))
  )

  (:action open_location_gate
    :parameters (?w - entity ?h - location)
    :precondition (and (at ?w ?h) (door_closed ?h) (in_cage ?w))
    :effect (and (light_or_gate_open ?h) (entry_requested ?w ?h))
  )

  (:action pig_collects_apples_and_escapes
    :parameters (?p - entity ?a - item ?l - location)
    :precondition (and (plan ?p ?l) (in_cage ?p))
    :effect (and (has ?p ?a) (escaped ?p) (not (plan ?p ?l)))
  )

  (:action pig_refuses_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_requested ?w ?h) (in_cage ?w))
    :effect (and (entry_denied ?w ?h) (not (entry_requested ?w ?h)))
  )

  (:action pig_rolls_churn_down_hill
    :parameters (?p - entity ?c - item)
    :precondition (and (naug__p_inside ?p ?c) (in_cage ?p))
    :effect (and (rolling ?c) (not (naug__p_inside ?p ?c)))
  )

  (:action place_at_location
    :parameters (?e - entity ?l - location)
    :precondition (and (rema_np__p_at ?e ?l))
    :effect (and (snow__p_at ?e ?l))
  )

  (:action plant_beans
    :parameters (?beans - item ?loc - location)
    :precondition (located ?beans ?loc)
    :effect (and (planted ?beans) (not (located ?beans ?loc)))
  )

  (:action prepare_boiling_pot_and_fire
    :parameters (?p - entity ?fire ?pot - item ?h - location)
    :precondition (and (location ?p ?h) (has ?p ?pot) (has ?p ?fire) (in_cage ?p))
    :effect (and (over ?pot ?fire) (located ?pot chimney) (boiling ?pot) (burned ?p))
  )

  (:action prepare_soup_by_elf_effect
    :parameters (?m - entity)
    :precondition (and (possesses ?m sausage_skewer) (anointed sausage_skewer) (snow__p_at ?m kitchen))
    :effect (soup_effect_created ?m)
  )

  (:action prepare_soup_by_king_tail
    :parameters (?k - entity)
    :precondition (snow__p_at mouse_king kitchen)
    :effect (king_tail_stirred)
  )

  (:action prepare_soup_by_poet_imagination
    :parameters (?m - entity)
    :precondition (and (has_understanding ?m) (has_imagination ?m) (entity ?m))
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

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action queen_ascend_to_throne
    :parameters (?q - entity ?l - location)
    :precondition (and (snow__p_alive ?q) (snow__p_at ?q ?l) (or (soup_effect_created ?q) (king_tail_stirred)))
    :effect (is_queen ?q)
  )

  (:action queen_pricks_finger
    :parameters (?q - entity ?blood ?needle - item)
    :precondition (and (snow__p_alive ?q) (possesses ?q ?needle))
    :effect (possesses ?q ?blood)
  )

  (:action queen_wishes_child_white_red_black
    :parameters (?c ?q - entity)
    :precondition (snow__p_alive ?q)
    :effect (fair ?c)
  )

  (:action read_and_digest_books
    :parameters (?m - entity ?lib - location)
    :precondition (snow__p_at ?m library)
    :effect (entity ?m)
  )

  (:action receive_anointed_skewer
    :parameters (?elf ?m - entity ?v - item)
    :precondition (and (possesses ?m sausage_skewer) (possesses ?elf violet))
    :effect (anointed sausage_skewer)
  )

  (:action receive_feather
    :parameters (?dryad ?m ?ph - entity ?feather - item ?loc - location)
    :precondition (and (snow__p_at ?m ?loc) (snow__p_at ?dryad ?loc) (snow__p_at ?ph ?loc) (possesses ?dryad ?feather))
    :effect (and (possesses ?m ?feather) (has_imagination ?m))
  )

  (:action receive_item
    :parameters (?i ?p - entity ?r - item)
    :precondition (and (material_requested ?i ?r) (has_bundle ?p ?r) (in_cage ?i) (in_cage ?p) (price_of_butter_spoken) (rema_np__p_at ?p market_place) (possesses ?i ?r))
    :effect (and (has ?i ?r) (not (material_requested ?i ?r)) (not (has_bundle ?p ?r)) (possesses ?p ?r) (not (possesses ?i ?r)))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (rema_np__p_at ?p oak_tree) (possesses ?c ?s))
    :effect (and (possesses ?p ?s) (not (possesses ?c ?s)))
  )

  (:action rest_in_forest
    :parameters (?cat ?cock ?donkey ?hound - entity ?forest - location)
    :precondition (and (location ?donkey ?forest) (location ?hound ?forest) (location ?cat ?forest) (location ?cock ?forest))
    :effect (and (in_cage ?donkey) (in_cage ?hound) (in_cage ?cat) (in_cage ?cock))
  )

  (:action return_down_beanstalk
    :parameters (?j - entity)
    :precondition (location ?j giant_castle)
    :effect (and (location ?j cottage) (not (location ?j giant_castle)))
  )

  (:action sell_cow_for_beans
    :parameters (?b ?cow ?j - entity ?beans - item ?l - location)
    :precondition (and (location ?j ?l) (location ?cow ?l) (possesses ?b ?beans) (location ?b ?l))
    :effect (and (has ?j ?beans) (not (possesses ?b ?beans)) (not (located ?beans ?l)))
  )

  (:action send_sons_on_journey
    :parameters (?m ?p - entity ?d - location)
    :precondition (and (location ?m pig_home) (location ?p pig_home) (in_cage ?m) (in_cage ?p))
    :effect (and (plan ?p ?d) (not (location ?p pig_home)))
  )

  (:action signal_and_make_noise
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock) (window_shattered))
  )

  (:action snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - entity ?apple - item)
    :precondition (and (poisoned ?apple) (snow__p_alive ?c))
    :effect (and (state ?c) (not (snow__p_alive ?c)))
  )

  (:action snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - entity ?mug ?plate - item)
    :precondition (snow__p_alive ?c)
    :effect (and (possesses ?c ?plate) (possesses ?c ?mug))
  )

  (:action snow_white_sleeps_in_seventh_bed
    :parameters (?c - entity ?bed - item)
    :precondition (snow__p_alive ?c)
    :effect (sleeping ?c)
  )

  (:action stack_animals
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
    :effect (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
  )

  (:action steal_harp
    :parameters (?giant ?j - entity ?harp - item)
    :precondition (and (at_item ?harp giant_castle) (sleeping ?giant))
    :effect (and (has ?j ?harp) (not (at_item ?harp giant_castle)))
  )

  (:action steal_hen
    :parameters (?giant ?j - entity ?hen - item)
    :precondition (and (at_item ?hen giant_castle) (captured ?giant))
    :effect (and (has ?j ?hen) (not (at_item ?hen giant_castle)))
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
    :precondition (and (possesses ?s ?comb) (poisoned ?comb) (snow__p_alive ?c))
    :effect (and (state ?c) (not (snow__p_alive ?c)))
  )

  (:action stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman ?s - entity ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (disguised_as ?s ?old_woman) (location ?s ?cottage))
  )

  (:action stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - entity ?heart - item)
    :precondition (possesses ?s ?heart)
    :effect (not (possesses ?s ?heart))
  )

  (:action stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - entity ?apple - item ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (poisoned ?apple) (possesses ?s ?apple) (location ?s ?cottage))
  )

  (:action stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - entity ?comb - item ?cottage - location)
    :precondition (snow__p_alive ?s)
    :effect (and (poisoned ?comb) (possesses ?s ?comb) (location ?s ?cottage))
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

  (:action transfer_item_to_cat
    :parameters (?giver ?receiver - entity ?item - item)
    :precondition (and (possesses ?giver ?item) (not (possesses ?receiver ?item)))
  )

  (:action travel
    :parameters (?e - entity ?l1 - location ?l2 - location)
    :precondition (and (location ?e ?l1) (not (location ?e ?l2)))
    :effect (and (location ?e ?l2) (not (location ?e ?l1)))
  )

  (:action travel_together_with_promise
    :parameters (?cat ?cock ?donkey ?hound ?p - entity ?from ?to - location)
    :precondition (and (location ?donkey ?from) (location ?hound ?from) (location ?cat ?from) (location ?cock ?from) (location ?p ?from) (agreed ?hound ?donkey) (agreed ?cat ?donkey) (agreed ?cock ?donkey))
    :effect (and (location ?donkey ?to) (location ?hound ?to) (location ?cat ?to) (location ?cock ?to) (moving_towards ?donkey ?to) (moving_towards ?hound ?to) (moving_towards ?cat ?to) (moving_towards ?cock ?to) (not (location ?donkey ?from)) (not (location ?hound ?from)) (not (location ?cat ?from)) (not (location ?cock ?from)))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
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

  (:action wolf_blows_house_down
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (door_closed ?h) (in_cage ?w))
    :effect (and (house_destroyed ?h) (not (house_intact ?h)) (not (door_closed ?h)))
  )

  (:action wolf_eats_pig
    :parameters (?p ?w - entity ?h - location)
    :precondition (and (house_destroyed ?h) (location ?p ?h) (in_cage ?p) (in_cage ?w))
    :effect (and (bad ?p) (not (in_cage ?p)) (not (location ?p ?h)))
  )

  (:action wolf_fails_to_blow_house
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (in_cage ?w))
    :effect (house_intact ?h)
  )

  (:action wolf_falls_into_pot_and_is_boiled
    :parameters (?w - entity ?pot - item)
    :precondition (and (boiling ?pot) (in_cage ?w))
    :effect (and (bad ?w) (not (in_cage ?w)))
  )

  (:action wolf_flees_from_rolling_object
    :parameters (?w - entity ?c - item)
    :precondition (and (rolling ?c) (in_cage ?w))
    :effect (escaped ?w)
  )

  (:action wolf_promises_apple_orchard
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (in_cage ?w) (in_cage ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_turnip_field
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (in_cage ?w) (in_cage ?p))
    :effect (plan ?p ?l)
  )
)
