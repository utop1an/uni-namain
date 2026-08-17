(define (domain Puss_In_Boots)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    coachman eldest_son groom jack king miller ogre princess puss second_son - entity
    ass bag boots hare mill partridge rabbit suit - item
    field_of_corn field_of_wheat ogre_castle palace river royal_wardrobe warren - location
  )
  (:predicates
    (alive ?x - entity)
    (at ?x - entity ?l - location)
    (at_item ?i - item ?l - location)
    (castle_owned_by ?castle - location ?owner - entity)
    (contains ?c - item ?i - item)
    (drowning ?e - entity)
    (gate_open ?castle - location)
    (gift_delivered ?giver - entity ?receiver - entity ?item - item)
    (has ?e - entity ?i - item)
    (married ?e1 - entity ?e2 - entity)
    (obedient ?e - entity)
    (promised_to_serve ?servant - entity ?master - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (transformed_into ?e - entity ?form - entity)
    (wearing ?e - entity ?i - item)
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
    :effect (gate_open ?castle)
  )

  (:action cat_persuade_master_to_bathe
    :parameters (?jack ?puss - entity ?river - location)
    :precondition (and (at ?jack ?river) (at ?puss ?river))
    :effect (drowning ?jack)
  )

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
  )

  (:action king_send_groom_fetch_suit
    :parameters (?groom ?king - entity ?suit - item ?wardrobe - location)
    :precondition (at_item ?suit ?wardrobe)
    :effect (and (has ?groom ?suit) (not (at_item ?suit ?wardrobe)))
  )

  (:action master_marry_princess
    :parameters (?jack ?princess - entity)
    :precondition (and (not (married ?jack ?princess)) (at ?jack palace))
    :effect (married ?jack ?princess)
  )

  (:action master_wear_suit
    :parameters (?jack - entity ?suit - item)
    :precondition (has ?jack ?suit)
    :effect (and (wearing ?jack ?suit) (not (has ?jack ?suit)))
  )
)
