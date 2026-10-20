(define (domain narrative_aligned)
  (:requirements :adl :negative-preconditions :strips :typing)
  (:constants
    d000__c_ass d000__c_bag d000__c_boots d000__c_coachman d000__c_eldest_son d000__c_field_of_corn d000__c_field_of_wheat d000__c_groom d000__c_hare d000__c_jack d000__c_king d000__c_mill d000__c_miller d000__c_ogre d000__c_ogre_castle d000__c_palace d000__c_partridge d000__c_princess d000__c_puss d000__c_rabbit d000__c_river d000__c_royal_wardrobe d000__c_second_son d000__c_suit d000__c_warren - object
  )
  (:predicates
    (d000__p_alive ?a0 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_at_item ?a0 - object ?a1 - object)
    (d000__p_castle_owned_by ?a0 - object ?a1 - object)
    (d000__p_contains ?a0 - object ?a1 - object)
    (d000__p_drowning ?a0 - object)
    (d000__p_gate_open ?a0 - object)
    (d000__p_gift_delivered ?a0 - object ?a1 - object ?a2 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_married ?a0 - object ?a1 - object)
    (d000__p_obedient ?a0 - object)
    (d000__p_promised_to_serve ?a0 - object ?a1 - object)
    (d000__p_rescued_by ?a0 - object ?a1 - object)
    (d000__p_transformed_into ?a0 - object ?a1 - object)
    (d000__p_wearing ?a0 - object ?a1 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_buy_boots
    :parameters (?jack - object ?puss - object ?boots - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_entity ?puss) (typeguard__d000__t_item ?boots) (not (d000__p_has ?puss ?boots)))
    :effect (d000__p_has ?puss ?boots)
  )

  (:action d000__a_cat_call_for_help
    :parameters (?jack - object ?king - object ?puss - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_entity ?king) (typeguard__d000__t_entity ?puss) (d000__p_drowning ?jack))
    :effect (and (d000__p_rescued_by ?jack ?king) (not (d000__p_drowning ?jack)))
  )

  (:action d000__a_cat_catch_rabbits
    :parameters (?puss - object ?bag - object ?rabbit - object ?warren - object)
    :precondition (and (typeguard__d000__t_entity ?puss) (typeguard__d000__t_item ?bag) (typeguard__d000__t_item ?rabbit) (typeguard__d000__t_location ?warren) (and (d000__p_has ?puss ?bag) (d000__p_at_item ?rabbit ?warren) (not (d000__p_contains ?bag ?rabbit))))
    :effect (and (d000__p_contains ?bag ?rabbit) (not (d000__p_at_item ?rabbit ?warren)))
  )

  (:action d000__a_cat_deliver_gifts_to_king
    :parameters (?king - object ?puss - object ?bag - object ?rabbit - object ?palace - object)
    :precondition (and (typeguard__d000__t_entity ?king) (typeguard__d000__t_entity ?puss) (typeguard__d000__t_item ?bag) (typeguard__d000__t_item ?rabbit) (typeguard__d000__t_location ?palace) (and (d000__p_contains ?bag ?rabbit) (d000__p_at ?puss ?palace)))
    :effect (and (d000__p_gift_delivered ?puss ?king ?rabbit) (not (d000__p_contains ?bag ?rabbit)))
  )

  (:action d000__a_cat_disentchant_prisoners
    :parameters (?person - object ?puss - object)
    :precondition (and (typeguard__d000__t_entity ?person) (typeguard__d000__t_entity ?puss) (d000__p_alive ?puss))
    :effect (d000__p_promised_to_serve ?person d000__c_jack)
  )

  (:action d000__a_cat_eat_mouse
    :parameters (?mouse - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d000__t_entity ?mouse) (typeguard__d000__t_entity ?ogre) (typeguard__d000__t_entity ?puss) (d000__p_transformed_into ?ogre ?mouse))
    :effect (not (d000__p_transformed_into ?ogre ?mouse))
  )

  (:action d000__a_cat_ogre_transform_lion
    :parameters (?lion - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d000__t_entity ?lion) (typeguard__d000__t_entity ?ogre) (typeguard__d000__t_entity ?puss) (and (d000__p_at ?puss d000__c_ogre_castle) (d000__p_alive ?ogre)))
    :effect (d000__p_transformed_into ?ogre ?lion)
  )

  (:action d000__a_cat_ogre_transform_mouse
    :parameters (?mouse - object ?ogre - object ?puss - object)
    :precondition (and (typeguard__d000__t_entity ?mouse) (typeguard__d000__t_entity ?ogre) (typeguard__d000__t_entity ?puss) (d000__p_alive ?ogre))
    :effect (d000__p_transformed_into ?ogre ?mouse)
  )

  (:action d000__a_cat_open_castle_gates
    :parameters (?king - object ?puss - object ?castle - object)
    :precondition (and (typeguard__d000__t_entity ?king) (typeguard__d000__t_entity ?puss) (typeguard__d000__t_location ?castle) (d000__p_at ?king ?castle))
    :effect (d000__p_gate_open ?castle)
  )

  (:action d000__a_cat_persuade_master_to_bathe
    :parameters (?jack - object ?puss - object ?river - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_entity ?puss) (typeguard__d000__t_location ?river) (and (d000__p_at ?jack ?river) (d000__p_at ?puss ?river)))
    :effect (d000__p_drowning ?jack)
  )

  (:action d000__a_give_bag_to_cat
    :parameters (?jack - object ?puss - object ?bag - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_entity ?puss) (typeguard__d000__t_item ?bag) (and (d000__p_has ?jack ?bag) (not (d000__p_has ?puss ?bag))))
    :effect (and (d000__p_has ?puss ?bag) (not (d000__p_has ?jack ?bag)))
  )

  (:action d000__a_king_send_groom_fetch_suit
    :parameters (?groom - object ?king - object ?suit - object ?wardrobe - object)
    :precondition (and (typeguard__d000__t_entity ?groom) (typeguard__d000__t_entity ?king) (typeguard__d000__t_item ?suit) (typeguard__d000__t_location ?wardrobe) (d000__p_at_item ?suit ?wardrobe))
    :effect (and (d000__p_has ?groom ?suit) (not (d000__p_at_item ?suit ?wardrobe)))
  )

  (:action d000__a_master_marry_princess
    :parameters (?jack - object ?princess - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_entity ?princess) (and (not (d000__p_married ?jack ?princess)) (d000__p_at ?jack d000__c_palace)))
    :effect (d000__p_married ?jack ?princess)
  )

  (:action d000__a_master_wear_suit
    :parameters (?jack - object ?suit - object)
    :precondition (and (typeguard__d000__t_entity ?jack) (typeguard__d000__t_item ?suit) (d000__p_has ?jack ?suit))
    :effect (and (d000__p_wearing ?jack ?suit) (not (d000__p_has ?jack ?suit)))
  )
)
