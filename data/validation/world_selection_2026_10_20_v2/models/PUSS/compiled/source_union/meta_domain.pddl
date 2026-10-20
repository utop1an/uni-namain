(define (domain narrative_union)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_coachman d000__c_eldest_son d000__c_groom d000__c_jack d000__c_king d000__c_miller d000__c_ogre d000__c_princess d000__c_puss d000__c_second_son - d000__t_entity
    d000__c_ass d000__c_bag d000__c_boots d000__c_hare d000__c_mill d000__c_partridge d000__c_rabbit d000__c_suit - d000__t_item
    d000__c_field_of_corn d000__c_field_of_wheat d000__c_ogre_castle d000__c_palace d000__c_river d000__c_royal_wardrobe d000__c_warren - d000__t_location
  )
  (:predicates
    (d000__p_alive ?x - d000__t_entity)
    (d000__p_at ?x - d000__t_entity ?l - d000__t_location)
    (d000__p_at_item ?i - d000__t_item ?l - d000__t_location)
    (d000__p_castle_owned_by ?castle - d000__t_location ?owner - d000__t_entity)
    (d000__p_contains ?c - d000__t_item ?i - d000__t_item)
    (d000__p_drowning ?e - d000__t_entity)
    (d000__p_gate_open ?castle - d000__t_location)
    (d000__p_gift_delivered ?giver - d000__t_entity ?receiver - d000__t_entity ?item - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_married ?e1 - d000__t_entity ?e2 - d000__t_entity)
    (d000__p_obedient ?e - d000__t_entity)
    (d000__p_promised_to_serve ?servant - d000__t_entity ?master - d000__t_entity)
    (d000__p_rescued_by ?victim - d000__t_entity ?rescuer - d000__t_entity)
    (d000__p_transformed_into ?e - d000__t_entity ?form - d000__t_entity)
    (d000__p_wearing ?e - d000__t_entity ?i - d000__t_item)
  )

  (:action d000__a_buy_boots
    :parameters (?jack - d000__t_entity ?puss - d000__t_entity ?boots - d000__t_item)
    :precondition (not (d000__p_has ?puss ?boots))
    :effect (d000__p_has ?puss ?boots)
  )

  (:action d000__a_cat_call_for_help
    :parameters (?jack - d000__t_entity ?king - d000__t_entity ?puss - d000__t_entity)
    :precondition (d000__p_drowning ?jack)
    :effect (and (d000__p_rescued_by ?jack ?king) (not (d000__p_drowning ?jack)))
  )

  (:action d000__a_cat_catch_rabbits
    :parameters (?puss - d000__t_entity ?bag - d000__t_item ?rabbit - d000__t_item ?warren - d000__t_location)
    :precondition (and (d000__p_has ?puss ?bag) (d000__p_at_item ?rabbit ?warren) (not (d000__p_contains ?bag ?rabbit)))
    :effect (and (d000__p_contains ?bag ?rabbit) (not (d000__p_at_item ?rabbit ?warren)))
  )

  (:action d000__a_cat_deliver_gifts_to_king
    :parameters (?king - d000__t_entity ?puss - d000__t_entity ?bag - d000__t_item ?rabbit - d000__t_item ?palace - d000__t_location)
    :precondition (and (d000__p_contains ?bag ?rabbit) (d000__p_at ?puss ?palace))
    :effect (and (d000__p_gift_delivered ?puss ?king ?rabbit) (not (d000__p_contains ?bag ?rabbit)))
  )

  (:action d000__a_cat_disentchant_prisoners
    :parameters (?person - d000__t_entity ?puss - d000__t_entity)
    :precondition (d000__p_alive ?puss)
    :effect (d000__p_promised_to_serve ?person d000__c_jack)
  )

  (:action d000__a_cat_eat_mouse
    :parameters (?mouse - d000__t_entity ?ogre - d000__t_entity ?puss - d000__t_entity)
    :precondition (d000__p_transformed_into ?ogre ?mouse)
    :effect (not (d000__p_transformed_into ?ogre ?mouse))
  )

  (:action d000__a_cat_ogre_transform_lion
    :parameters (?lion - d000__t_entity ?ogre - d000__t_entity ?puss - d000__t_entity)
    :precondition (and (d000__p_at ?puss d000__c_ogre_castle) (d000__p_alive ?ogre))
    :effect (d000__p_transformed_into ?ogre ?lion)
  )

  (:action d000__a_cat_ogre_transform_mouse
    :parameters (?mouse - d000__t_entity ?ogre - d000__t_entity ?puss - d000__t_entity)
    :precondition (d000__p_alive ?ogre)
    :effect (d000__p_transformed_into ?ogre ?mouse)
  )

  (:action d000__a_cat_open_castle_gates
    :parameters (?king - d000__t_entity ?puss - d000__t_entity ?castle - d000__t_location)
    :precondition (d000__p_at ?king ?castle)
    :effect (d000__p_gate_open ?castle)
  )

  (:action d000__a_cat_persuade_master_to_bathe
    :parameters (?jack - d000__t_entity ?puss - d000__t_entity ?river - d000__t_location)
    :precondition (and (d000__p_at ?jack ?river) (d000__p_at ?puss ?river))
    :effect (d000__p_drowning ?jack)
  )

  (:action d000__a_give_bag_to_cat
    :parameters (?jack - d000__t_entity ?puss - d000__t_entity ?bag - d000__t_item)
    :precondition (and (d000__p_has ?jack ?bag) (not (d000__p_has ?puss ?bag)))
    :effect (and (d000__p_has ?puss ?bag) (not (d000__p_has ?jack ?bag)))
  )

  (:action d000__a_king_send_groom_fetch_suit
    :parameters (?groom - d000__t_entity ?king - d000__t_entity ?suit - d000__t_item ?wardrobe - d000__t_location)
    :precondition (d000__p_at_item ?suit ?wardrobe)
    :effect (and (d000__p_has ?groom ?suit) (not (d000__p_at_item ?suit ?wardrobe)))
  )

  (:action d000__a_master_marry_princess
    :parameters (?jack - d000__t_entity ?princess - d000__t_entity)
    :precondition (and (not (d000__p_married ?jack ?princess)) (d000__p_at ?jack d000__c_palace))
    :effect (d000__p_married ?jack ?princess)
  )

  (:action d000__a_master_wear_suit
    :parameters (?jack - d000__t_entity ?suit - d000__t_item)
    :precondition (d000__p_has ?jack ?suit)
    :effect (and (d000__p_wearing ?jack ?suit) (not (d000__p_has ?jack ?suit)))
  )
)
