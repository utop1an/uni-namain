(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_badger d000__c_friend d000__c_lady_of_court d000__c_priest d000__c_prince d000__c_princess d000__c_showman d000__c_tinker - d000__t_entity
    d000__c_box d000__c_copper_coins d000__c_pack d000__c_teakettle d000__c_temple_treasure - d000__t_item
    d000__c_jhosiu d000__c_morinji d000__c_tight_rope - d000__t_location
  )
  (:predicates
    (d000__p_airborne ?i - d000__t_item)
    (d000__p_badger_form ?i - d000__t_item)
    (d000__p_captured ?i - d000__t_item)
    (d000__p_contained_in ?i - d000__t_item ?c - d000__t_item)
    (d000__p_exhibition_ready ?e - d000__t_entity)
    (d000__p_four_legged ?i - d000__t_item)
    (d000__p_furred ?i - d000__t_item)
    (d000__p_hanging ?i - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_located ?obj - d000__t_object ?loc - d000__t_location)
    (d000__p_night)
    (d000__p_owned_by ?i - d000__t_item ?e - d000__t_entity)
    (d000__p_performing_show ?e - d000__t_entity)
    (d000__p_reputation_widespread)
    (d000__p_treasured ?i - d000__t_item)
    (d000__p_wealthy ?e - d000__t_entity)
    (d000__p_worshipped ?i - d000__t_item)
  )

  (:action d000__a_arrange_exhibition
    :parameters (?s - d000__t_entity ?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_exhibition_ready ?t)
  )

  (:action d000__a_call_novices
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_badger_form ?k)
    :effect (d000__p_located ?k d000__c_morinji)
  )

  (:action d000__a_force_kettle_into_box
    :parameters (?b - d000__t_item ?k - d000__t_item)
    :precondition (d000__p_captured ?k)
    :effect (d000__p_contained_in ?k ?b)
  )

  (:action d000__a_hang_kettle
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?pr ?k)
    :effect (d000__p_hanging ?k)
  )

  (:action d000__a_kettle_jump_and_fly
    :parameters (?k - d000__t_item)
    :precondition (d000__p_badger_form ?k)
    :effect (d000__p_airborne ?k)
  )

  (:action d000__a_kettle_revert_shape
    :parameters (?k - d000__t_item)
    :precondition (and (d000__p_badger_form ?k) (d000__p_furred ?k))
    :effect (and (not (d000__p_badger_form ?k)) (not (d000__p_furred ?k)) (not (d000__p_four_legged ?k)))
  )

  (:action d000__a_kettle_transform_to_badger
    :parameters (?k - d000__t_item)
    :precondition (d000__p_hanging ?k)
    :effect (d000__p_badger_form ?k)
  )

  (:action d000__a_kettle_transform_to_fur_badger
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_night) (d000__p_located ?k d000__c_jhosiu) (d000__p_has ?t ?k))
    :effect (and (d000__p_furred ?k) (d000__p_badger_form ?k) (d000__p_four_legged ?k))
  )

  (:action d000__a_knock_down_kettle
    :parameters (?k - d000__t_item)
    :precondition (d000__p_airborne ?k)
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_perform_show
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_exhibition_ready ?t) (d000__p_has ?t ?k))
    :effect (and (d000__p_performing_show ?t) (d000__p_reputation_widespread))
  )

  (:action d000__a_pursue_kettle
    :parameters (?pr - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_airborne ?k)
    :effect (and (d000__p_captured ?k) (not (d000__p_airborne ?k)))
  )

  (:action d000__a_receive_orders_from_nobility
    :parameters (?t - d000__t_entity)
    :precondition (d000__p_reputation_widespread)
    :effect (d000__p_wealthy ?t)
  )

  (:action d000__a_return_kettle_to_temple
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (and (d000__p_has ?t ?k) (d000__p_wealthy ?t))
    :effect (and (d000__p_located ?k d000__c_morinji) (d000__p_treasured ?k) (not (d000__p_has ?t ?k)))
  )

  (:action d000__a_sell_kettle_to_tinker
    :parameters (?pr - d000__t_entity ?t - d000__t_entity ?c - d000__t_item ?k - d000__t_item)
    :precondition (and (d000__p_has ?pr ?k) (d000__p_has ?t ?c))
    :effect (and (d000__p_has ?t ?k) (d000__p_has ?pr ?c) (not (d000__p_has ?pr ?k)) (not (d000__p_has ?t ?c)))
  )

  (:action d000__a_show_kettle_to_friend
    :parameters (?f - d000__t_entity ?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_has ?f ?k)
  )

  (:action d000__a_tinker_carry_home
    :parameters (?t - d000__t_entity ?k - d000__t_item)
    :precondition (d000__p_has ?t ?k)
    :effect (d000__p_located ?k d000__c_jhosiu)
  )

  (:action d000__a_worship_kettle_as_saint
    :parameters (?k - d000__t_item)
    :precondition (d000__p_treasured ?k)
    :effect (d000__p_worshipped ?k)
  )
)
