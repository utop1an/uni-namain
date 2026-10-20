(define (domain narrative_union)
  (:requirements :negative-preconditions :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_father_king d000__c_impostor_butterman d000__c_king_at_palace d000__c_princess d000__c_robber_chief - d000__t_entity
    d000__c_bag_of_rubies d000__c_bag_of_sapphires d000__c_crown d000__c_sceptre - d000__t_item
    d000__c_back_door d000__c_back_stairs d000__c_city d000__c_forest d000__c_market_place d000__c_oak_tree d000__c_palace - d000__t_location
  )
  (:predicates
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_grandmother_mangle_spoken)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_married ?p1 - d000__t_entity ?p2 - d000__t_entity)
    (d000__p_price_of_butter_spoken)
    (d000__p_with_all_my_heart_spoken)
  )

  (:action d000__a_arrive_at_marble_palace
    :parameters (?p - d000__t_entity)
    :precondition (d000__p_at ?p d000__c_oak_tree)
    :effect (and (d000__p_at ?p d000__c_palace) (not (d000__p_at ?p d000__c_oak_tree)))
  )

  (:action d000__a_encounter_impostor_king
    :parameters (?i - d000__t_entity ?p - d000__t_entity)
    :precondition (and (d000__p_at ?p d000__c_city) (d000__p_at ?i d000__c_market_place))
    :effect (and (d000__p_at ?p d000__c_market_place) (not (d000__p_at ?p d000__c_city)))
  )

  (:action d000__a_encounter_robbers_in_forest
    :parameters (?p - d000__t_entity)
    :precondition (d000__p_at ?p d000__c_forest)
    :effect (and (d000__p_at ?p d000__c_oak_tree) (not (d000__p_at ?p d000__c_forest)))
  )

  (:action d000__a_king_proposes_marriage
    :parameters (?k - d000__t_entity ?p - d000__t_entity)
    :precondition (and (d000__p_at ?p d000__c_palace) (d000__p_at ?k d000__c_palace))
    :effect (d000__p_married ?p ?k)
  )

  (:action d000__a_king_requests_information_and_gifts
    :parameters (?k - d000__t_entity ?p - d000__t_entity ?r - d000__t_item ?s - d000__t_item)
    :precondition (and (d000__p_at ?p d000__c_palace) (d000__p_has ?p ?r) (d000__p_has ?p ?s) (d000__p_at ?k d000__c_palace))
    :effect (and (d000__p_has ?k ?r) (d000__p_has ?k ?s) (not (d000__p_has ?p ?r)) (not (d000__p_has ?p ?s)))
  )

  (:action d000__a_princess_accepts_with_heart
    :parameters (?k - d000__t_entity ?p - d000__t_entity)
    :precondition (and (d000__p_married ?p ?k) (not (d000__p_with_all_my_heart_spoken)))
    :effect (d000__p_with_all_my_heart_spoken)
  )

  (:action d000__a_receive_rubies_from_impostor
    :parameters (?i - d000__t_entity ?p - d000__t_entity ?r - d000__t_item)
    :precondition (and (d000__p_price_of_butter_spoken) (d000__p_at ?p d000__c_market_place) (d000__p_has ?i ?r))
    :effect (and (d000__p_has ?p ?r) (not (d000__p_has ?i ?r)))
  )

  (:action d000__a_receive_sapphires_from_robber_chief
    :parameters (?c - d000__t_entity ?p - d000__t_entity ?s - d000__t_item)
    :precondition (and (d000__p_grandmother_mangle_spoken) (d000__p_at ?p d000__c_oak_tree) (d000__p_has ?c ?s))
    :effect (and (d000__p_has ?p ?s) (not (d000__p_has ?c ?s)))
  )

  (:action d000__a_run_away_from_palace
    :parameters (?p - d000__t_entity)
    :precondition (d000__p_at ?p d000__c_back_stairs)
    :effect (and (d000__p_at ?p d000__c_city) (not (d000__p_at ?p d000__c_back_stairs)))
  )

  (:action d000__a_suitors_retire_due_to_phrase
    :parameters (?s - d000__t_entity)
    :precondition (and (d000__p_grandmother_mangle_spoken) (d000__p_at ?s d000__c_palace))
    :effect (not (d000__p_married ?s d000__c_princess))
  )

  (:action d000__a_utter_phrase_grandmother_mangle
    :parameters (?p - d000__t_entity)
    :precondition (and (d000__p_at ?p d000__c_oak_tree) (not (d000__p_grandmother_mangle_spoken)))
    :effect (d000__p_grandmother_mangle_spoken)
  )

  (:action d000__a_utter_phrase_price_of_butter
    :parameters (?p - d000__t_entity)
    :precondition (and (d000__p_at ?p d000__c_market_place) (not (d000__p_price_of_butter_spoken)))
    :effect (d000__p_price_of_butter_spoken)
  )
)
