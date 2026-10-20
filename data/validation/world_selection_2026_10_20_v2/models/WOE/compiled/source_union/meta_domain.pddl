(define (domain narrative_union)
  (:requirements :existential-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_bitter_woe d000__c_children d000__c_poor_brother d000__c_rich_brother d000__c_wife - d000__t_entity
    d000__c_cattle d000__c_copecks_25 d000__c_gold_pot d000__c_grove d000__c_harrow d000__c_honey d000__c_loaf_bread d000__c_plow d000__c_sledge d000__c_stone d000__c_telega d000__c_wine - d000__t_item
    d000__c_big_house d000__c_forest d000__c_izba d000__c_kabak d000__c_large_town d000__c_new_home d000__c_treasure_pit d000__c_village d000__c_well d000__c_yard - d000__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_banquet_at ?l - d000__t_location)
    (d000__p_bowed ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_concealed ?i - d000__t_item)
    (d000__p_drunk ?e - d000__t_entity)
    (d000__p_employed ?worker - d000__t_entity ?employer - d000__t_entity)
    (d000__p_gold_at ?g - d000__t_item ?l - d000__t_location)
    (d000__p_guest_present ?guest - d000__t_entity ?l - d000__t_location)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_has_fatigue ?e - d000__t_entity)
    (d000__p_has_strength ?e - d000__t_entity)
    (d000__p_invitation_sent ?sender - d000__t_entity ?receiver - d000__t_entity)
    (d000__p_invited ?invitee - d000__t_entity ?host - d000__t_entity)
    (d000__p_need_help ?e - d000__t_entity)
    (d000__p_poor ?e - d000__t_entity)
    (d000__p_rich ?e - d000__t_entity)
    (d000__p_singing ?e - d000__t_entity)
    (d000__p_stone_at ?s - d000__t_item ?l - d000__t_location)
    (d000__p_stone_moved ?s - d000__t_item)
    (d000__p_trapped ?m - d000__t_entity)
    (d000__p_woe_on_shoulder ?monster - d000__t_entity ?carrier - d000__t_entity)
    (d000__p_work_done ?worker - d000__t_entity ?employer - d000__t_entity)
  )

  (:action d000__a_accept_woe_as_burden
    :parameters (?rich - d000__t_entity ?woe - d000__t_entity)
    :precondition (d000__p_woe_on_shoulder ?woe ?rich)
    :effect (d000__p_has_fatigue ?rich)
  )

  (:action d000__a_allow_woe_to_ride_on_shoulder
    :parameters (?poor - d000__t_entity ?woe - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc) (d000__p_has_fatigue ?poor))
    :effect (d000__p_woe_on_shoulder ?woe ?poor)
  )

  (:action d000__a_bow_to_guests
    :parameters (?poor - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?poor ?loc) (exists (?guest - d000__t_entity) (d000__p_guest_present ?guest ?loc)))
    :effect (d000__p_bowed ?poor ?loc)
  )

  (:action d000__a_encounter_bitter_woe
    :parameters (?poor - d000__t_entity ?woe - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc))
    :effect (d000__p_has_fatigue ?poor)
  )

  (:action d000__a_hide_woe_under_stone
    :parameters (?poor - d000__t_entity ?woe - d000__t_entity ?stone - d000__t_item ?loc - d000__t_location)
    :precondition (and (d000__p_woe_on_shoulder ?woe ?poor) (d000__p_stone_at ?stone ?loc))
    :effect (and (d000__p_trapped ?woe) (d000__p_stone_at ?stone ?loc) (not (d000__p_woe_on_shoulder ?woe ?poor)) (not (d000__p_stone_moved ?stone)))
  )

  (:action d000__a_invite_rich_brother_to_feast
    :parameters (?poor - d000__t_entity ?rich - d000__t_entity ?loc - d000__t_location)
    :precondition (d000__p_at ?poor ?loc)
    :effect (and (d000__p_invitation_sent ?poor ?rich) (d000__p_invited ?rich ?poor))
  )

  (:action d000__a_make_sign_of_cross
    :parameters (?poor - d000__t_entity ?woe - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?poor ?loc) (d000__p_at ?woe ?loc))
    :effect (d000__p_has_fatigue ?poor)
  )

  (:action d000__a_move_heavy_stone
    :parameters (?carrier - d000__t_entity ?stone - d000__t_item ?loc - d000__t_location)
    :precondition (and (d000__p_stone_at ?stone ?loc) (d000__p_has_strength ?carrier))
    :effect (and (d000__p_stone_moved ?stone) (not (d000__p_stone_at ?stone ?loc)))
  )

  (:action d000__a_perform_work_for_rich_brother
    :parameters (?employer - d000__t_entity ?worker - d000__t_entity)
    :precondition (and (d000__p_employed ?worker ?employer) (d000__p_has_strength ?worker))
    :effect (and (d000__p_work_done ?worker ?employer) (d000__p_has_fatigue ?worker))
  )

  (:action d000__a_receive_payment
    :parameters (?employer - d000__t_entity ?worker - d000__t_entity ?bread - d000__t_item ?money - d000__t_item)
    :precondition (and (d000__p_work_done ?worker ?employer) (d000__p_has ?employer ?money) (d000__p_has ?employer ?bread))
    :effect (and (d000__p_has ?worker ?money) (d000__p_has ?worker ?bread) (not (d000__p_has ?employer ?money)) (not (d000__p_has ?employer ?bread)))
  )

  (:action d000__a_request_help_from_rich_brother
    :parameters (?poor - d000__t_entity ?rich - d000__t_entity)
    :precondition (and (d000__p_need_help ?poor) (d000__p_rich ?rich))
    :effect (and (d000__p_employed ?poor ?rich) (not (d000__p_need_help ?poor)))
  )

  (:action d000__a_rich_brother_attempt_to_move_stone
    :parameters (?rich - d000__t_entity ?stone - d000__t_item ?loc - d000__t_location)
    :precondition (and (d000__p_stone_at ?stone ?loc) (d000__p_rich ?rich))
    :effect (and (d000__p_stone_moved ?stone) (d000__p_woe_on_shoulder d000__c_bitter_woe ?rich) (not (d000__p_stone_at ?stone ?loc)))
  )

  (:action d000__a_sing_cheerful_song
    :parameters (?poor - d000__t_entity ?loc - d000__t_location)
    :precondition (d000__p_at ?poor ?loc)
    :effect (d000__p_singing ?poor)
  )

  (:action d000__a_spend_money_on_drink
    :parameters (?poor - d000__t_entity ?money - d000__t_item ?wine - d000__t_item ?kabak - d000__t_location)
    :precondition (and (d000__p_has ?poor ?money) (d000__p_at ?poor ?kabak))
    :effect (and (d000__p_has ?poor ?wine) (d000__p_drunk ?poor) (not (d000__p_has ?poor ?money)))
  )

  (:action d000__a_stay_for_banquet
    :parameters (?guest - d000__t_entity ?host - d000__t_entity ?loc - d000__t_location)
    :precondition (and (d000__p_at ?guest ?loc) (d000__p_at ?host ?loc) (d000__p_banquet_at ?loc) (d000__p_invited ?guest ?host))
    :effect (d000__p_guest_present ?guest ?loc)
  )

  (:action d000__a_take_gold_pot_and_hide
    :parameters (?poor - d000__t_entity ?gold - d000__t_item ?loc - d000__t_location)
    :precondition (and (d000__p_gold_at ?gold ?loc) (d000__p_at ?poor ?loc))
    :effect (and (d000__p_has ?poor ?gold) (d000__p_concealed ?gold) (not (d000__p_gold_at ?gold ?loc)))
  )

  (:action d000__a_trade_assets_for_money
    :parameters (?poor - d000__t_entity ?asset - d000__t_item ?money - d000__t_item)
    :precondition (d000__p_has ?poor ?asset)
    :effect (and (d000__p_has ?poor ?money) (not (d000__p_has ?poor ?asset)))
  )
)
