(define (domain unified_narrative_domain)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    coachman eldest_son father_king groom impostor_butterman jack king king_at_palace miller ogre princess puss robber_chief second_son - entity
    ass bag bag_of_rubies bag_of_sapphires boots crown hare mill partridge rabbit sceptre suit - item
    back_door back_stairs city field_of_corn field_of_wheat forest market_place oak_tree ogre_castle palace river royal_wardrobe warren - location
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
    (grandmother_mangle_spoken)
    (has ?e - entity ?i - item)
    (married ?e1 - entity ?e2 - entity)
    (obedient ?e - entity)
    (price_of_butter_spoken)
    (promised_to_serve ?servant - entity ?master - entity)
    (rescued_by ?victim - entity ?rescuer - entity)
    (transformed_into ?e - entity ?form - entity)
    (wearing ?e - entity ?i - item)
    (with_all_my_heart_spoken)
  )

  (:action arrive_at_marble_palace
    :parameters (?p - entity)
    :precondition (at ?p oak_tree)
    :effect (and (at ?p palace) (not (at ?p oak_tree)))
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

  (:action give_bag_to_cat
    :parameters (?jack ?puss - entity ?bag - item)
    :precondition (and (has ?jack ?bag) (not (has ?puss ?bag)))
    :effect (and (has ?puss ?bag) (not (has ?jack ?bag)))
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

  (:action master_wear_suit
    :parameters (?jack - entity ?suit - item)
    :precondition (has ?jack ?suit)
    :effect (and (wearing ?jack ?suit) (not (has ?jack ?suit)))
  )

  (:action princess_accepts_with_heart
    :parameters (?k ?p - entity)
    :precondition (and (married ?p ?k) (not (with_all_my_heart_spoken)))
    :effect (with_all_my_heart_spoken)
  )

  (:action propose_marriage
    :parameters (?k ?p - entity)
    :precondition (and (at ?p palace) (at ?k palace))
    :effect (married ?p ?k)
  )

  (:action receive_rubies_from_impostor
    :parameters (?i ?p - entity ?r - item)
    :precondition (and (price_of_butter_spoken) (at ?p market_place) (has ?i ?r))
    :effect (and (has ?p ?r) (not (has ?i ?r)))
  )

  (:action receive_sapphires_from_robber_chief
    :parameters (?c ?p - entity ?s - item)
    :precondition (and (grandmother_mangle_spoken) (at ?p oak_tree) (has ?c ?s))
    :effect (and (has ?p ?s) (not (has ?c ?s)))
  )

  (:action run_away_from_palace
    :parameters (?p - entity)
    :precondition (at ?p back_stairs)
    :effect (and (at ?p city) (not (at ?p back_stairs)))
  )

  (:action suitors_retire_due_to_phrase
    :parameters (?s - entity)
    :precondition (and (grandmother_mangle_spoken) (at ?s palace))
    :effect (not (married ?s princess))
  )

  (:action utter_phrase_grandmother_mangle
    :parameters (?p - entity)
    :precondition (and (at ?p oak_tree) (not (grandmother_mangle_spoken)))
    :effect (grandmother_mangle_spoken)
  )

  (:action utter_phrase_price_of_butter
    :parameters (?p - entity)
    :precondition (and (at ?p market_place) (not (price_of_butter_spoken)))
    :effect (price_of_butter_spoken)
  )
)
