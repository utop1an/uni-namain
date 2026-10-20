(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_badger d000__c_box d000__c_copper_coins d000__c_friend d000__c_jhosiu d000__c_lady_of_court d000__c_morinji d000__c_pack d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_teakettle d000__c_temple_treasure d000__c_tight_rope d000__c_tinker - object
  )
  (:predicates
    (d000__p_airborne ?a0 - object)
    (d000__p_badger_form ?a0 - object)
    (d000__p_captured ?a0 - object)
    (d000__p_contained_in ?a0 - object ?a1 - object)
    (d000__p_exhibition_ready ?a0 - object)
    (d000__p_four_legged ?a0 - object)
    (d000__p_furred ?a0 - object)
    (d000__p_hanging ?a0 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_located ?a0 - object ?a1 - object)
    (d000__p_night)
    (d000__p_owned_by ?a0 - object ?a1 - object)
    (d000__p_performing_show ?a0 - object)
    (d000__p_reputation_widespread)
    (d000__p_treasured ?a0 - object)
    (d000__p_wealthy ?a0 - object)
    (d000__p_worshipped ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_arrange_exhibition
    :parameters (?s - object ?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?s) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (d000__p_has ?t ?k))
    :effect (d000__p_exhibition_ready ?t)
  )

  (:action d000__a_call_novices
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (d000__p_badger_form ?k))
    :effect (d000__p_located ?k d000__c_morinji)
  )

  (:action d000__a_force_kettle_into_box
    :parameters (?b - object ?k - object)
    :precondition (and (typeguard__d000__t_item ?b) (typeguard__d000__t_item ?k) (d000__p_captured ?k))
    :effect (d000__p_contained_in ?k ?b)
  )

  (:action d000__a_hang_kettle
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (d000__p_has ?pr ?k))
    :effect (d000__p_hanging ?k)
  )

  (:action d000__a_kettle_jump_and_fly
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_badger_form ?k))
    :effect (d000__p_airborne ?k)
  )

  (:action d000__a_kettle_revert_shape
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (and (d000__p_badger_form ?k) (d000__p_furred ?k)))
    :effect (and (not (d000__p_badger_form ?k)) (not (d000__p_furred ?k)) (not (d000__p_four_legged ?k)))
  )

  (:action d000__a_kettle_transform_to_badger
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_hanging ?k))
    :effect (d000__p_badger_form ?k)
  )

  (:action d000__a_kettle_transform_to_fur_badger
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (d000__p_night) (d000__p_located ?k d000__c_jhosiu) (d000__p_has ?t ?k)))
    :effect (and (d000__p_furred ?k) (d000__p_badger_form ?k) (d000__p_four_legged ?k))
  )

  (:action d000__a_knock_down_kettle
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_airborne ?k))
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_perform_show
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (d000__p_exhibition_ready ?t) (d000__p_has ?t ?k)))
    :effect (and (d000__p_performing_show ?t) (d000__p_reputation_widespread))
  )

  (:action d000__a_pursue_kettle
    :parameters (?pr - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_item ?k) (d000__p_airborne ?k))
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_receive_orders_from_nobility
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (d000__p_reputation_widespread))
    :effect (d000__p_wealthy ?t)
  )

  (:action d000__a_return_kettle_to_temple
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (and (d000__p_has ?t ?k) (d000__p_wealthy ?t)))
    :effect (and (d000__p_located ?k d000__c_morinji) (d000__p_treasured ?k) (not (d000__p_has ?t ?k)))
  )

  (:action d000__a_sell_kettle_to_tinker
    :parameters (?pr - object ?t - object ?c - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?pr) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?c) (typeguard__d000__t_item ?k) (and (d000__p_has ?pr ?k) (d000__p_has ?t ?c)))
    :effect (and (d000__p_has ?t ?k) (d000__p_has ?pr ?c) (not (d000__p_has ?pr ?k)) (not (d000__p_has ?t ?c)))
  )

  (:action d000__a_show_kettle_to_friend
    :parameters (?f - object ?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?f) (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (d000__p_has ?t ?k))
    :effect (d000__p_has ?f ?k)
  )

  (:action d000__a_tinker_carry_home
    :parameters (?t - object ?k - object)
    :precondition (and (typeguard__d000__t_entity ?t) (typeguard__d000__t_item ?k) (d000__p_has ?t ?k))
    :effect (d000__p_located ?k d000__c_jhosiu)
  )

  (:action d000__a_worship_kettle_as_saint
    :parameters (?k - object)
    :precondition (and (typeguard__d000__t_item ?k) (d000__p_treasured ?k))
    :effect (d000__p_worshipped ?k)
  )
)
