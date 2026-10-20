(define (domain narrative_aligned)
  (:requirements :adl :existential-preconditions :strips :typing)
  (:constants
    d000__c_big_house d000__c_bitter_woe d000__c_cattle d000__c_children d000__c_copecks_25 d000__c_forest d000__c_gold_pot d000__c_grove d000__c_harrow d000__c_honey d000__c_izba d000__c_kabak d000__c_large_town d000__c_loaf_bread d000__c_new_home d000__c_plow d000__c_poor_brother d000__c_rich_brother d000__c_sledge d000__c_stone d000__c_telega d000__c_treasure_pit d000__c_village d000__c_well d000__c_wife d000__c_wine d000__c_yard - object
  )
  (:predicates
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_banquet_at ?a0 - object)
    (d000__p_bowed ?a0 - object ?a1 - object)
    (d000__p_concealed ?a0 - object)
    (d000__p_drunk ?a0 - object)
    (d000__p_employed ?a0 - object ?a1 - object)
    (d000__p_gold_at ?a0 - object ?a1 - object)
    (d000__p_guest_present ?a0 - object ?a1 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_has_fatigue ?a0 - object)
    (d000__p_has_strength ?a0 - object)
    (d000__p_invitation_sent ?a0 - object ?a1 - object)
    (d000__p_invited ?a0 - object ?a1 - object)
    (d000__p_need_help ?a0 - object)
    (d000__p_poor ?a0 - object)
    (d000__p_rich ?a0 - object)
    (d000__p_singing ?a0 - object)
    (d000__p_stone_at ?a0 - object ?a1 - object)
    (d000__p_stone_moved ?a0 - object)
    (d000__p_trapped ?a0 - object)
    (d000__p_woe_on_shoulder ?a0 - object ?a1 - object)
    (d000__p_work_done ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_accept_woe_as_burden
    :parameters (?rich - object ?woe - object)
    :precondition (and (typeguard__d000__t_entity ?rich) (typeguard__d000__t_entity ?woe) (d000__p_woe_on_shoulder ?woe ?rich))
    :effect (d000__p_has_fatigue ?rich)
  )

  (:action d000__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?woe) (typeguard__d000__t_location ?loc) (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc) (d000__p_has_fatigue ?poor)))
    :effect (d000__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d000__a_bow_to_guests
    :parameters (?poor - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_location ?loc) (and (d000__p_at ?poor ?loc) (exists (?bound_scope_0 - object) (and (typeguard__d000__t_entity ?bound_scope_0) (d000__p_guest_present ?bound_scope_0 ?loc)))))
    :effect (d000__p_bowed ?poor ?loc)
  )

  (:action d000__a_encounter_bitter_woe
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?woe) (typeguard__d000__t_location ?loc) (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc)))
    :effect (d000__p_has_fatigue ?poor)
  )

  (:action d000__a_hide_woe_under_stone
    :parameters (?poor - object ?woe - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?woe) (typeguard__d000__t_item ?stone) (typeguard__d000__t_location ?loc) (and (d000__p_woe_on_shoulder ?woe ?poor) (d000__p_stone_at ?stone ?loc)))
    :effect (and (d000__p_trapped ?woe) (d000__p_stone_at ?stone ?loc) (not (d000__p_woe_on_shoulder ?woe ?poor)) (not (d000__p_stone_moved ?stone)))
  )

  (:action d000__a_invite_rich_brother_to_feast
    :parameters (?poor - object ?rich - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?rich) (typeguard__d000__t_location ?loc) (d000__p_at ?poor ?loc))
    :effect (and (d000__p_invitation_sent ?poor ?rich) (d000__p_invited ?rich ?poor))
  )

  (:action d000__a_make_sign_of_cross
    :parameters (?poor - object ?woe - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?woe) (typeguard__d000__t_location ?loc) (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc)))
    :effect (d000__p_has_fatigue ?poor)
  )

  (:action d000__a_move_heavy_stone
    :parameters (?carrier - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?carrier) (typeguard__d000__t_item ?stone) (typeguard__d000__t_location ?loc) (and (d000__p_stone_at ?stone ?loc) (d000__p_has_strength ?carrier)))
    :effect (and (d000__p_stone_moved ?stone) (not (d000__p_stone_at ?stone ?loc)))
  )

  (:action d000__a_perform_work_for_rich_brother
    :parameters (?employer - object ?worker - object)
    :precondition (and (typeguard__d000__t_entity ?employer) (typeguard__d000__t_entity ?worker) (and (d000__p_employed ?worker ?employer) (d000__p_has_strength ?worker)))
    :effect (and (d000__p_work_done ?worker ?employer) (d000__p_has_fatigue ?worker))
  )

  (:action d000__a_receive_payment
    :parameters (?employer - object ?worker - object ?bread - object ?money - object)
    :precondition (and (typeguard__d000__t_entity ?employer) (typeguard__d000__t_entity ?worker) (typeguard__d000__t_item ?bread) (typeguard__d000__t_item ?money) (and (d000__p_work_done ?worker ?employer) (d000__p_has ?employer ?money) (d000__p_has ?employer ?bread)))
    :effect (and (d000__p_has ?worker ?money) (d000__p_has ?worker ?bread) (not (d000__p_has ?employer ?money)) (not (d000__p_has ?employer ?bread)))
  )

  (:action d000__a_request_help_from_rich_brother
    :parameters (?poor - object ?rich - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_entity ?rich) (and (d000__p_need_help ?poor) (d000__p_rich ?rich)))
    :effect (and (d000__p_employed ?poor ?rich) (not (d000__p_need_help ?poor)))
  )

  (:action d000__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - object ?stone - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?rich) (typeguard__d000__t_item ?stone) (typeguard__d000__t_location ?loc) (and (d000__p_stone_at ?stone ?loc) (d000__p_rich ?rich)))
    :effect (and (d000__p_stone_moved ?stone) (d000__p_woe_on_shoulder d000__c_bitter_woe ?rich) (not (d000__p_stone_at ?stone ?loc)))
  )

  (:action d000__a_sing_cheerful_song
    :parameters (?poor - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_location ?loc) (d000__p_at ?poor ?loc))
    :effect (d000__p_singing ?poor)
  )

  (:action d000__a_spend_money_on_drink
    :parameters (?poor - object ?money - object ?wine - object ?kabak - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_item ?money) (typeguard__d000__t_item ?wine) (typeguard__d000__t_location ?kabak) (and (d000__p_has ?poor ?money) (d000__p_at ?poor ?kabak)))
    :effect (and (d000__p_has ?poor ?wine) (d000__p_drunk ?poor) (not (d000__p_has ?poor ?money)))
  )

  (:action d000__a_stay_for_banquet
    :parameters (?guest - object ?host - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?guest) (typeguard__d000__t_entity ?host) (typeguard__d000__t_location ?loc) (and (d000__p_at ?guest ?loc) (d000__p_at ?host ?loc) (d000__p_banquet_at ?loc) (d000__p_invited ?guest ?host)))
    :effect (d000__p_guest_present ?guest ?loc)
  )

  (:action d000__a_take_gold_pot_and_hide
    :parameters (?poor - object ?gold - object ?loc - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_item ?gold) (typeguard__d000__t_location ?loc) (and (d000__p_gold_at ?gold ?loc) (d000__p_at ?poor ?loc)))
    :effect (and (d000__p_has ?poor ?gold) (d000__p_concealed ?gold) (not (d000__p_gold_at ?gold ?loc)))
  )

  (:action d000__a_trade_assets_for_money
    :parameters (?poor - object ?asset - object ?money - object)
    :precondition (and (typeguard__d000__t_entity ?poor) (typeguard__d000__t_item ?asset) (typeguard__d000__t_item ?money) (d000__p_has ?poor ?asset))
    :effect (and (d000__p_has ?poor ?money) (not (d000__p_has ?poor ?asset)))
  )
)
