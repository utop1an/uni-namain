(define (domain unified_narrative_domain)
  (:requirements :disjunctive-preconditions :existential-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ant_queen bitter_woe boar children dove dwarf1 dwarf2 dwarf3 dwarf4 dwarf5 dwarf6 dwarf7 elf_chief first_traveler_mouse fourth_traveler_mouse huntsman jailer jailer_granddaughter king mouse_king oak_dryad old_lady_mouse old_owl owl phantaesus poor_brother prince queen raven rich_brother second_traveler_mouse snow_white third_traveler_mouse watchman wife young_lady_mouse - entity
    apple bed blood_drop boar_heart candle cattle coffin comb copecks_25 crape_skewer fork gold_pot golden_letter grove harrow honey iron_slippers knife lace loaf_bread looking_glass maypole mug needle plate plow red_hot_shoes salt sausage_skewer sledge spoon stone telega violet wine - item
    big_house castle cottage forest izba kabak kitchen large_town library mountain new_home north sea ship treasure_pit village well yard - location
  )
  (:predicates
    (alive ?e - entity)
    (anointed ?i - item)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (awake ?e - entity)
    (banquet_at ?l - location)
    (bowed ?e - entity ?l - location)
    (captured ?e - entity)
    (concealed ?i - item)
    (dead ?e - entity)
    (disguised_as ?e - entity ?d - entity)
    (drunk ?e - entity)
    (employed ?worker - entity ?employer - entity)
    (envious ?e - entity)
    (escaped ?e - entity)
    (fair ?e - entity)
    (fairest ?e - entity)
    (gold_at ?g - item ?l - location)
    (guest_present ?guest - entity ?l - location)
    (has ?e - entity ?i - item)
    (has_fatigue ?e - entity)
    (has_feeling ?e - entity)
    (has_imagination ?e - entity)
    (has_strength ?e - entity)
    (has_understanding ?e - entity)
    (holds ?e - entity ?i - item)
    (in_cage ?e - entity)
    (in_coffin ?e - entity)
    (invitation_sent ?sender - entity ?receiver - entity)
    (invited ?invitee - entity ?host - entity)
    (is_poet ?e - entity)
    (is_queen ?e - entity)
    (king_tail_stirred)
    (laced ?e - entity ?i - item)
    (need_help ?e - entity)
    (poisoned ?i - item)
    (poor ?e - entity)
    (rich ?e - entity)
    (singing ?e - entity)
    (sleeping ?e - entity)
    (soup_effect_created ?e - entity)
    (stone_at ?s - item ?l - location)
    (stone_moved ?s - item)
    (trapped ?m - entity)
    (visited ?e - entity ?l - location)
    (wearing ?e - entity ?i - item)
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

  (:action bow_to_guests
    :parameters (?poor - entity ?loc - location)
    :precondition (and (at ?poor ?loc) (exists (?guest - entity) (guest_present ?guest ?loc)))
    :effect (bowed ?poor ?loc)
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

  (:action dwarfs_remove_comb_rescue_snow_white
    :parameters (?c ?d - entity ?comb - item)
    :precondition (and (dead ?c) (poisoned ?comb) (has ?d ?comb))
    :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?comb)))
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

  (:action escape_jail
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (and (escaped ?m) (not (captured ?m)) (not (in_cage ?m)))
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

  (:action receive_payment
    :parameters (?employer ?worker - entity ?bread ?money - item)
    :precondition (and (work_done ?worker ?employer) (has ?employer ?money) (has ?employer ?bread))
    :effect (and (has ?worker ?money) (has ?worker ?bread) (not (has ?employer ?money)) (not (has ?employer ?bread)))
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

  (:action run_in_cage
    :parameters (?m - entity)
    :precondition (captured ?m)
    :effect (in_cage ?m)
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

  (:action snow_white_flees_into_forest
    :parameters (?c - entity ?f - location)
    :precondition (alive ?c)
    :effect (at ?c ?f)
  )

  (:action snow_white_sleeps_in_seventh_bed
    :parameters (?c - entity ?bed - item)
    :precondition (alive ?c)
    :effect (sleeping ?c)
  )

  (:action spend_money_on_drink
    :parameters (?poor - entity ?money ?wine - item ?kabak - location)
    :precondition (and (has ?poor ?money) (at ?poor ?kabak))
    :effect (and (has ?poor ?wine) (drunk ?poor) (not (has ?poor ?money)))
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

  (:action stepmother_disguises_as_old_woman_and_visits_cottage
    :parameters (?old_woman ?s - entity ?cottage - location)
    :precondition (alive ?s)
    :effect (and (disguised_as ?s ?old_woman) (visited ?s ?cottage))
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

  (:action take_gold_pot_and_hide
    :parameters (?poor - entity ?gold - item ?loc - location)
    :precondition (and (gold_at ?gold ?loc) (at ?poor ?loc))
    :effect (and (has ?poor ?gold) (concealed ?gold) (not (gold_at ?gold ?loc)))
  )

  (:action trade_assets_for_money
    :parameters (?poor - entity ?asset ?money - item)
    :precondition (has ?poor ?asset)
    :effect (and (has ?poor ?money) (not (has ?poor ?asset)))
  )
)
