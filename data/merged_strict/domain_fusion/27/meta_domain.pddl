(define (domain unified_narrative_domain)
  (:requirements :disjunctive-preconditions :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ant_queen bitter_woe boar bungo children coachman comet_master dove dwarf1 dwarf2 dwarf3 dwarf4 dwarf5 dwarf6 dwarf7 earth eldest_son elf_chief farmer father_king first_traveler_mouse fourth_traveler_mouse groom huntsman impostor_butterman jack jailer jailer_granddaughter king king_at_palace long_tail_45 man_bricks man_furze man_straw meteor meteor_keeper miller mother_pig mouse_king no1_express oak_dryad ogre old_lady_mouse old_owl owl phantaesus pig1 pig2 pig3 poor_brother prince princess puss queen raven rich_brother robber_chief second_son second_traveler_mouse short_tail_73 snow_white squire sun third_traveler_mouse watchman wife wolf young_lady_mouse - entity
    apple ass bag bag_of_rubies bag_of_sapphires bed blood_drop boar_heart boots bricks butter_churn candle cattle chalk coffin comb copecks_25 crape_skewer crown fire fork furze_bundle gold_pot golden_letter grove hare harrow honey iron_slippers knife lace loaf_bread looking_glass maypole mill mortar mug needle partridge plate plow pot_of_water rabbit red_hot_shoes sack salt sausage_skewer sceptre slate sledge spoon stone straw_bundle suit telega trowel turnips_load violet wine - item
    back_door back_stairs big_house brick_house castle chimney city comet_house cottage courtyard field_of_corn field_of_wheat forest furze_house gate hearth hill izba kabak kitchen large_town library market_place mountain new_home north oak_forest oak_tree ogre_castle palace pig_home river royal_wardrobe sea ship squire_orchard straw_house town_fair treasure_pit turnip_field village warren well yard - location
  )
  (:predicates
    (alive ?e - entity)
    (anointed ?i - item)
    (arrested ?c - entity ?m - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (avoid ?c - entity ?b - entity)
    (awake ?e - entity)
    (banquet_at ?l - location)
    (boiling ?i - item)
    (bowed ?e - entity ?l - location)
    (burned ?c - entity)
    (captured ?e - entity)
    (castle_owned_by ?castle - location ?owner - entity)
    (concealed ?i - item)
    (contains ?c - item ?i - item)
    (crossed_out ?c - entity)
    (dead ?e - entity)
    (delivered ?m - entity ?p - entity)
    (detained ?m - entity)
    (disguised_as ?e - entity ?d - entity)
    (door_closed ?h - location)
    (drowning ?e - entity)
    (drunk ?e - entity)
    (employed ?worker - entity ?employer - entity)
    (entry_denied ?w - entity ?h - location)
    (entry_requested ?w - entity ?h - location)
    (envious ?e - entity)
    (escaped ?e - entity)
    (fair ?e - entity)
    (fairest ?e - entity)
    (gate_open)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (gold_at ?g - item ?l - location)
    (grandmother_mangle_spoken)
    (guest_present ?guest - entity ?l - location)
    (has ?e - entity ?i - item)
    (has_bundle ?m - entity ?i - item)
    (has_fatigue ?e - entity)
    (has_feeling ?e - entity)
    (has_imagination ?e - entity)
    (has_mission ?c - entity)
    (has_strength ?e - entity)
    (has_understanding ?e - entity)
    (holds ?e - entity ?i - item)
    (house ?h - location ?m - item)
    (house_destroyed ?h - location)
    (house_intact ?h - location)
    (huffed ?w - entity)
    (in_cage ?e - entity)
    (in_coffin ?e - entity)
    (inside ?e - entity ?c - item)
    (invitation_sent ?sender - entity ?receiver - entity)
    (invited ?invitee - entity ?host - entity)
    (is_poet ?e - entity)
    (is_queen ?e - entity)
    (king_tail_stirred)
    (laced ?e - entity ?i - item)
    (left_turn_rule ?c - entity)
    (married ?e1 - entity ?e2 - entity)
    (material_requested ?p - entity ?i - item)
    (near ?c - entity ?b - entity)
    (need_help ?e - entity)
    (obedient ?e - entity)
    (on_list ?c - entity)
    (over ?i1 - item ?i2 - item)
    (plan ?e - entity ?l - location)
    (poisoned ?i - item)
    (poor ?e - entity)
    (price_of_butter_spoken)
    (prohibit_speak ?c - entity)
    (promised_to_serve ?servant - entity ?master - entity)
    (puffed ?w - entity)
    (punished ?m - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (rich ?e - entity)
    (rolling ?i - item)
    (rule_violation ?c - entity)
    (singing ?e - entity)
    (sleeping ?e - entity)
    (soup_effect_created ?e - entity)
    (speaks_to ?c - entity ?m - entity)
    (stone_at ?s - item ?l - location)
    (stone_moved ?s - item)
    (summoned ?c - entity)
    (transformed_into ?e - entity ?form - entity)
    (trapped ?m - entity)
    (traveling ?c - entity)
    (under ?i - item ?l - location)
    (visited ?e - entity ?l - location)
    (wearing ?e - entity ?i - item)
    (with_all_my_heart_spoken)
    (woe_on_shoulder ?monster - entity ?carrier - entity)
    (work_done ?worker - entity ?employer - entity)
  )

  (:action accept_woe_as_burden
    :parameters (?rich ?woe - entity)
    :precondition (woe_on_shoulder ?woe ?rich)
    :effect (has_fatigue ?rich)
  )

  (:action allow_woe_to_ride_on_shoulder
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc) (has_fatigue ?poor))
    :effect (woe_on_shoulder ?woe ?poor)
  )

  (:action apple_piece_falls_out_reviving_snow_white
    :parameters (?c - entity ?apple - item)
    :precondition (and (dead ?c) (poisoned ?apple))
    :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?apple)))
  )

  (:action approach_sun
    :parameters (?c - entity)
    :precondition (and (traveling ?c) (avoid ?c sun))
    :effect (near ?c sun)
  )

  (:action arrest_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (near ?c ?m))
    :effect (and (arrested ?c ?m) (detained ?m))
  )

  (:action arrive_at_marble_palace
    :parameters (?p - entity)
    :precondition (at ?p oak_tree)
    :effect (and (at ?p palace) (not (at ?p oak_tree)))
  )

  (:action ask_for_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (material_requested ?p ?i)
  )

  (:action avoid_body
    :parameters (?b ?c - entity)
    :precondition (and (traveling ?c) (avoid ?c ?b) (near ?c ?b))
    :effect (not (near ?c ?b))
  )

  (:action bow_to_guests
    :parameters (?poor - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (exists (?guest - entity) (guest_present ?guest ?loc)))
    :effect (bowed ?poor ?loc)
  )

  (:action build_house
    :parameters (?p - entity ?i - item ?h - location)
    :precondition (and (has ?p ?i) (alive ?p) (at ?p ?h))
    :effect (and (house ?h ?i) (house_intact ?h) (door_closed ?h) (not (has ?p ?i)))
  )

  (:action burn_up
    :parameters (?c - entity)
    :precondition (near ?c sun)
    :effect (and (burned ?c) (not (traveling ?c)) (not (has_mission ?c)))
  )

  (:action buy_boots
    :parameters (?jack ?puss - entity ?boots - item)
    :precondition (not (has ?puss ?boots))
    :effect (has ?puss ?boots)
  )

  (:action call_comet_forward
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard))
    :effect (summoned ?c)
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

  (:action cat_eat_mouse
    :parameters (?mouse ?ogre ?puss - entity)
    :precondition (transformed_into ?ogre ?mouse)
    :effect (not (transformed_into ?ogre ?mouse))
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
    :effect (gate_open)
  )

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
  )

  (:action child_is_born_and_queen_dies
    :parameters (?c ?q - entity)
    :precondition (and (not (alive ?c)) (alive ?q))
    :effect (and (alive ?c) (dead ?q) (not (alive ?q)))
  )

  (:action claim_queenhood
    :parameters (?m - entity)
    :precondition (or (soup_effect_created ?m) (king_tail_stirred))
    :effect (is_queen ?m)
  )

  (:action deliver_meteor_to_bungo
    :parameters (?m - entity)
    :precondition (detained ?m)
    :effect (delivered ?m bungo)
  )

  (:action dwarfs_cut_laces_rescue_snow_white
    :parameters (?c ?d - entity ?lace - item)
    :precondition (and (laced ?c ?lace) (dead ?c))
    :effect (and (alive ?c) (awake ?c) (not (laced ?c ?lace)) (not (dead ?c)))
  )

  (:action dwarfs_offer_snow_white_to_maintain_house
    :parameters (?c ?d - entity)
    :precondition (and (alive ?d) (alive ?c) (sleeping ?c))
    :effect (and (awake ?c) (not (sleeping ?c)))
  )

  (:action dwarfs_prepare_glass_coffin_for_snow_white
    :parameters (?c ?d - entity ?coffin - item)
    :precondition (dead ?c)
    :effect (and (in_coffin ?c) (has ?d ?coffin))
  )

  (:action dwarfs_return_and_discover_snow_white
    :parameters (?c ?d - entity)
    :precondition (and (alive ?d) (sleeping ?c))
    :effect (awake ?d)
  )

  (:action encounter_bitter_woe
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action encounter_impostor_king
    :parameters (?i ?p - entity)
    :precondition (and (at ?p city) (at ?i market_place))
    :effect (and (at ?p market_place) (not (at ?p city)))
  )

  (:action encounter_robbers_in_forest
    :parameters (?p - entity)
    :precondition (at ?p forest)
    :effect (and (at ?p oak_tree) (not (at ?p forest)))
  )

  (:action entity_flees
    :parameters (?e - entity ?l - location)
    :precondition (alive ?e)
    :effect (at ?e ?l)
  )

  (:action escape_jail
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (and (escaped ?m) (not (captured ?m)) (not (in_cage ?m)))
  )

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
  )

  (:action give_order
    :parameters (?c ?master - entity)
    :precondition (and (at ?c courtyard) (at ?master courtyard) (not (has_mission ?c)))
    :effect (and (has_mission ?c) (left_turn_rule ?c) (prohibit_speak ?c) (avoid ?c sun) (avoid ?c earth) (avoid ?c bungo))
  )

  (:action give_skewer_to_elves
    :parameters (?elf ?m - entity)
    :precondition (holds ?m sausage_skewer)
    :effect (and (holds ?elf sausage_skewer) (not (holds ?m sausage_skewer)))
  )

  (:action hide_woe_under_stone
    :parameters (?poor ?woe - entity ?stone - item ?loc - location)
    :precondition (and (woe_on_shoulder ?woe ?poor) (stone_at ?stone ?loc))
    :effect (and (trapped ?woe) (stone_at ?stone ?loc) (not (woe_on_shoulder ?woe ?poor)) (not (stone_moved ?stone)))
  )

  (:action huntsman_spares_snow_white_and_brings_boar_heart
    :parameters (?b ?c ?h - entity ?heart - item)
    :precondition (and (alive ?h) (alive ?c) (alive ?b))
    :effect (and (has ?h ?heart) (dead ?b))
  )

  (:action invite_rich_brother_to_feast
    :parameters (?poor ?rich - entity ?loc - location)
    :precondition (at ?poor ?loc)
    :effect (and (invitation_sent ?poor ?rich) (invited ?rich ?poor))
  )

  (:action king_marries_stepmother
    :parameters (?k ?s - entity)
    :precondition (and (alive ?k) (alive ?s))
    :effect (fair ?s)
  )

  (:action king_requests_information_and_gifts
    :parameters (?k ?p - entity ?r ?s - item)
    :precondition (and (at ?p palace) (has ?p ?r) (has ?p ?s) (at ?k palace))
    :effect (and (has ?k ?r) (has ?k ?s) (not (has ?p ?r)) (not (has ?p ?s)))
  )

  (:action king_send_groom_fetch_suit
    :parameters (?groom ?king - entity ?suit - item ?wardrobe - location)
    :precondition (at_item ?suit ?wardrobe)
    :effect (and (has ?groom ?suit) (not (at_item ?suit ?wardrobe)))
  )

  (:action learn_wisdom_from_ants
    :parameters (?m - entity ?ant_loc - location)
    :precondition (at ?m ?ant_loc)
    :effect (has_understanding ?m)
  )

  (:action make_sign_of_cross
    :parameters (?poor ?woe - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (at ?woe ?loc))
    :effect (has_fatigue ?poor)
  )

  (:action master_wear_suit
    :parameters (?jack - entity ?suit - item)
    :precondition (has ?jack ?suit)
    :effect (and (wearing ?jack ?suit) (not (has ?jack ?suit)))
  )

  (:action move_item
    :parameters (?item - entity ?destination - location ?origin - location)
    :precondition (and (at ?item ?origin) (holds ?item sausage_skewer))
    :effect (and (at ?item ?destination) (not (at ?item ?origin)))
  )

  (:action perform_work_for_rich_brother
    :parameters (?employer ?worker - entity)
    :precondition (and (employed ?worker ?employer) (has_strength ?worker))
    :effect (and (work_done ?worker ?employer) (has_fatigue ?worker))
  )

  (:action pig_buys_butter_churn_and_hides
    :parameters (?p - entity ?c - item)
    :precondition (and (at ?p town_fair) (alive ?p))
    :effect (and (has ?p ?c) (inside ?p ?c))
  )

  (:action pig_collects_apples_and_escapes
    :parameters (?p - entity ?a - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?a) (escaped ?p) (not (plan ?p ?l)))
  )

  (:action pig_collects_turnips
    :parameters (?p - entity ?i - item ?l - location)
    :precondition (and (plan ?p ?l) (alive ?p))
    :effect (and (has ?p ?i) (not (plan ?p ?l)))
  )

  (:action pig_prepares_boiling_pot_and_fire
    :parameters (?p - entity ?fire ?pot - item ?h - location)
    :precondition (and (at ?p ?h) (has ?p ?pot) (has ?p ?fire) (alive ?p))
    :effect (and (over ?pot ?fire) (under ?pot chimney) (boiling ?pot))
  )

  (:action pig_refuses_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_requested ?w ?h) (alive ?w))
    :effect (and (entry_denied ?w ?h) (not (entry_requested ?w ?h)))
  )

  (:action pig_rolls_churn_down_hill
    :parameters (?p - entity ?c - item)
    :precondition (and (inside ?p ?c) (alive ?p))
    :effect (and (rolling ?c) (not (inside ?p ?c)))
  )

  (:action prepare_soup_by_elf_effect
    :parameters (?m - entity)
    :precondition (and (holds ?m sausage_skewer) (anointed sausage_skewer) (at ?m kitchen))
    :effect (soup_effect_created ?m)
  )

  (:action prepare_soup_by_king_tail
    :parameters (?k - entity)
    :precondition (at mouse_king kitchen)
    :effect (king_tail_stirred)
  )

  (:action prepare_soup_by_poet_imagination
    :parameters (?m - entity)
    :precondition (and (has_understanding ?m) (has_imagination ?m) (has_feeling ?m))
    :effect (and (soup_effect_created ?m) (is_poet ?m))
  )

  (:action prince_discovers_coffin_and_moves_it
    :parameters (?c ?p - entity ?coffin - item ?mountain - location)
    :precondition (and (in_coffin ?c) (alive ?p))
    :effect (at_item ?coffin ?mountain)
  )

  (:action prince_marries_snow_white
    :parameters (?c ?p - entity)
    :precondition (and (alive ?p) (alive ?c))
    :effect (fair ?p)
  )

  (:action princess_accepts_with_heart
    :parameters (?k ?p - entity)
    :precondition (and (married ?p ?k) (not (with_all_my_heart_spoken)))
    :effect (with_all_my_heart_spoken)
  )

  (:action prohibit_speaking_to_meteor
    :parameters (?c - entity)
    :precondition (has_mission ?c)
    :effect (prohibit_speak ?c)
  )

  (:action propose_marriage
    :parameters (?k ?p - entity)
    :precondition (and (at ?p palace) (at ?k palace))
    :effect (married ?p ?k)
  )

  (:action punish_meteor
    :parameters (?m - entity)
    :precondition (delivered ?m bungo)
    :effect (punished ?m)
  )

  (:action queen_pricks_finger
    :parameters (?q - entity ?blood ?needle - item)
    :precondition (and (alive ?q) (has ?q ?needle))
    :effect (has ?q ?blood)
  )

  (:action queen_sews_at_window
    :parameters (?q - entity ?l - location)
    :precondition (and (alive ?q) (at ?q ?l))
    :effect (has ?q needle)
  )

  (:action queen_wishes_child_white_red_black
    :parameters (?c ?q - entity)
    :precondition (alive ?q)
    :effect (fair ?c)
  )

  (:action read_and_digest_books
    :parameters (?m - entity ?lib - location)
    :precondition (at ?m library)
    :effect (has_feeling ?m)
  )

  (:action receive_anointed_skewer
    :parameters (?elf ?m - entity ?v - item)
    :precondition (and (holds ?m sausage_skewer) (holds ?elf violet))
    :effect (anointed sausage_skewer)
  )

  (:action receive_feather
    :parameters (?dryad ?m ?ph - entity ?feather - item ?loc - location)
    :precondition (and (at ?m ?loc) (at ?dryad ?loc) (at ?ph ?loc) (holds ?dryad ?feather))
    :effect (and (holds ?m ?feather) (has_imagination ?m))
  )

  (:action receive_gold_pot_and_hide
    :parameters (?poor - entity ?gold - item ?loc - location)
    :precondition (and (gold_at ?gold ?loc) (at ?poor ?loc))
    :effect (and (has ?poor ?gold) (not (gold_at ?gold ?loc)))
  )

  (:action receive_material
    :parameters (?m ?p - entity ?i - item)
    :precondition (and (material_requested ?p ?i) (has_bundle ?m ?i) (alive ?p) (alive ?m))
    :effect (and (has ?p ?i) (not (material_requested ?p ?i)) (not (has_bundle ?m ?i)))
  )

  (:action receive_payment
    :parameters (?employer ?worker - entity ?bread ?money - item)
    :precondition (and (work_done ?worker ?employer) (has ?employer ?money) (has ?employer ?bread))
    :effect (and (has ?worker ?money) (has ?worker ?bread) (not (has ?employer ?money)) (not (has ?employer ?bread)))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (at ?p oak_tree) (has ?c ?s))
    :effect (and (has ?p ?s) (not (has ?c ?s)))
  )

  (:action remove_poisoned_comet
    :parameters (?c - entity ?comb - item)
    :precondition (and (dead ?c) (poisoned ?comb) (has ?d ?comb))
    :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?comb)) (crossed_out ?c) (not (on_list ?c)))
  )

  (:action request_help_from_rich_brother
    :parameters (?poor ?rich - entity)
    :precondition (and (need_help ?poor) (rich ?rich))
    :effect (and (employed ?poor ?rich) (not (need_help ?poor)))
  )

  (:action rich_brother_attempt_to_move_stone
    :parameters (?rich - entity ?stone - item ?loc - location)
    :precondition (and (stone_at ?stone ?loc) (rich ?rich))
    :effect (and (stone_moved ?stone) (woe_on_shoulder bitter_woe ?rich) (not (stone_at ?stone ?loc)))
  )

  (:action run_away_from_palace
    :parameters (?p - entity)
    :precondition (at ?p back_stairs)
    :effect (and (at ?p city) (not (at ?p back_stairs)))
  )

  (:action run_in_cage
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (in_cage ?m)
  )

  (:action send_sons_on_journey
    :parameters (?m ?p - entity ?d - location)
    :precondition (and (at ?m pig_home) (at ?p pig_home) (alive ?m) (alive ?p))
    :effect (and (plan ?p ?d) (not (at ?p pig_home)))
  )

  (:action sing_cheerful_song
    :parameters (?poor - entity ?loc - location)
    :precondition (at ?poor ?loc)
    :effect (singing ?poor)
  )

  (:action snow_white_eats_poisoned_apple_and_dies
    :parameters (?c - entity ?apple - item)
    :precondition (and (poisoned ?apple) (alive ?c))
    :effect (and (dead ?c) (not (alive ?c)))
  )

  (:action snow_white_eats_vegetables_and_bread_and_drinks_wine
    :parameters (?c - entity ?mug ?plate - item)
    :precondition (alive ?c)
    :effect (and (has ?c ?plate) (has ?c ?mug))
  )

  (:action snow_white_finds_dwarfs_cottage
    :parameters (?c - entity ?cottage - location)
    :precondition (alive ?c)
    :effect (at ?c ?cottage)
  )

  (:action snow_white_sleeps_in_seventh_bed
    :parameters (?c - entity ?bed - item)
    :precondition (alive ?c)
    :effect (sleeping ?c)
  )

  (:action speak_to_meteor
    :parameters (?c ?m - entity)
    :precondition (and (traveling ?c) (prohibit_speak ?c) (near ?c ?m))
    :effect (and (speaks_to ?c ?m) (rule_violation ?c))
  )

  (:action spend_money_on_drink
    :parameters (?poor - entity ?money ?wine - item ?kabak - location)
    :precondition (and (has ?poor ?money) (at ?poor ?kabak))
    :effect (and (has ?poor ?wine) (drunk ?poor) (not (has ?poor ?money)))
  )

  (:action start_travel
    :parameters (?c - entity)
    :precondition (and (has_mission ?c) (gate_open))
    :effect (and (traveling ?c) (not (at ?c courtyard)))
  )

  (:action stay_for_banquet
    :parameters (?guest ?host - entity ?loc - location)
    :precondition (and (at ?guest ?loc) (at ?host ?loc) (banquet_at ?loc) (invited ?guest ?host))
    :effect (guest_present ?guest ?loc)
  )

  (:action stepmother_asks_looking_glass_fairest
    :parameters (?s - entity ?g - item)
    :precondition (and (alive ?s) (has ?s ?g))
    :effect (fairest ?s)
  )

  (:action stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
    :parameters (?s - entity ?slippers - item)
    :precondition (alive ?s)
    :effect (and (wearing ?s ?slippers) (dead ?s) (not (alive ?s)))
  )

  (:action stepmother_becomes_envious_of_snow_white
    :parameters (?c ?s - entity)
    :precondition (and (fairest ?c) (fair ?c) (alive ?s))
    :effect (envious ?s)
  )

  (:action stepmother_comb_poison_snow_white
    :parameters (?c ?s - entity ?comb - item)
    :precondition (and (has ?s ?comb) (poisoned ?comb) (alive ?c))
    :effect (and (dead ?c) (not (alive ?c)))
  )

  (:action stepmother_disguises_and_visits
    :parameters (?old_woman ?s - entity ?cottage - location)
    :precondition (and (alive ?s) (not (grandmother_mangle_spoken)))
    :effect (and (disguised_as ?s ?old_woman) (visited ?s ?cottage) (grandmother_mangle_spoken))
  )

  (:action stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
    :parameters (?s - entity ?heart - item)
    :precondition (has ?s ?heart)
    :effect (not (has ?s ?heart))
  )

  (:action stepmother_laces_snow_white_tightly
    :parameters (?c ?s - entity ?lace - item)
    :precondition (and (alive ?c) (has ?c ?lace))
    :effect (and (laced ?c ?lace) (dead ?c) (not (alive ?c)) (not (sleeping ?c)))
  )

  (:action stepmother_makes_poisonous_apple_and_visits_cottage
    :parameters (?s - entity ?apple - item ?cottage - location)
    :precondition (alive ?s)
    :effect (and (poisoned ?apple) (has ?s ?apple) (visited ?s ?cottage))
  )

  (:action stepmother_makes_poisonous_comb_and_visits_cottage
    :parameters (?s - entity ?comb - item ?cottage - location)
    :precondition (alive ?s)
    :effect (and (poisoned ?comb) (has ?s ?comb) (visited ?s ?cottage))
  )

  (:action stepmother_orders_huntsman_to_kill_snow_white
    :parameters (?c ?h ?s - entity)
    :precondition (and (envious ?s) (alive ?h) (alive ?c))
    :effect (fair ?s)
  )

  (:action suitors_retire_due_to_phrase
    :parameters (?s - entity)
    :precondition (and (grandmother_mangle_spoken) (at ?s palace))
    :effect (not (married ?s princess))
  )

  (:action trade_assets_for_money
    :parameters (?poor - entity ?asset ?money - item)
    :precondition (has ?poor ?asset)
    :effect (and (has ?poor ?money) (not (has ?poor ?asset)))
  )

  (:action turn_left_on_meeting
    :parameters (?c ?other - entity)
    :precondition (and (traveling ?c) (traveling ?other) (left_turn_rule ?c) (near ?c ?other))
    :effect (left_turn_rule ?c)
  )

  (:action utter_phrase_price_of_butter
    :parameters (?p - entity)
    :precondition (and (at ?p market_place) (not (price_of_butter_spoken)))
    :effect (price_of_butter_spoken)
  )

  (:action wolf_attempts_chimney_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (house_intact ?h) (alive ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action wolf_blows_house_down
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (door_closed ?h) (alive ?w))
    :effect (and (house_destroyed ?h) (not (house_intact ?h)) (not (door_closed ?h)))
  )

  (:action wolf_eats_pig
    :parameters (?p ?w - entity ?h - location)
    :precondition (and (house_destroyed ?h) (at ?p ?h) (alive ?p) (alive ?w))
    :effect (and (dead ?p) (not (alive ?p)) (not (at ?p ?h)))
  )

  (:action wolf_fails_to_blow_house
    :parameters (?w - entity ?i - item ?h - location)
    :precondition (and (huffed ?w) (puffed ?w) (house ?h ?i) (alive ?w))
    :effect (house_intact ?h)
  )

  (:action wolf_falls_into_pot_and_is_boiled
    :parameters (?w - entity ?pot - item)
    :precondition (and (boiling ?pot) (alive ?w))
    :effect (and (dead ?w) (not (alive ?w)))
  )

  (:action wolf_huff_and_puff
    :parameters (?w - entity ?h - location)
    :precondition (and (entry_denied ?w ?h) (alive ?w))
    :effect (and (huffed ?w) (puffed ?w))
  )

  (:action wolf_knocks_and_requests_entry
    :parameters (?w - entity ?h - location)
    :precondition (and (at ?w ?h) (door_closed ?h) (alive ?w))
    :effect (entry_requested ?w ?h)
  )

  (:action wolf_promises_apple_orchard
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_fair_trip
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )

  (:action wolf_promises_turnip_field
    :parameters (?p ?w - entity ?l - location)
    :precondition (and (alive ?w) (alive ?p))
    :effect (plan ?p ?l)
  )
)
