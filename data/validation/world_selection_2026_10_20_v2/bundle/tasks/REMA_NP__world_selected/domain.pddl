(define (domain narrative_aligned)
  (:requirements :adl :negative-preconditions :strips :typing)
  (:constants
    d000__c_back_door d000__c_back_stairs d000__c_bag_of_rubies d000__c_bag_of_sapphires d000__c_city d000__c_crown d000__c_father_king d000__c_forest d000__c_impostor_butterman d000__c_king_at_palace d000__c_market_place d000__c_oak_tree d000__c_palace d000__c_princess d000__c_robber_chief d000__c_sceptre - object
  )
  (:predicates
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_grandmother_mangle_spoken)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_married ?a0 - object ?a1 - object)
    (d000__p_price_of_butter_spoken)
    (d000__p_with_all_my_heart_spoken)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_arrive_at_marble_palace
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_entity ?p) (d000__p_at ?p d000__c_oak_tree))
    :effect (and (d000__p_at ?p d000__c_palace) (not (d000__p_at ?p d000__c_oak_tree)))
  )

  (:action d000__a_encounter_impostor_king
    :parameters (?i - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?i) (typeguard__d000__t_entity ?p) (and (d000__p_at ?p d000__c_city) (d000__p_at ?i d000__c_market_place)))
    :effect (and (d000__p_at ?p d000__c_market_place) (not (d000__p_at ?p d000__c_city)))
  )

  (:action d000__a_encounter_robbers_in_forest
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_entity ?p) (d000__p_at ?p d000__c_forest))
    :effect (and (d000__p_at ?p d000__c_oak_tree) (not (d000__p_at ?p d000__c_forest)))
  )

  (:action d000__a_king_proposes_marriage
    :parameters (?k - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?k) (typeguard__d000__t_entity ?p) (and (d000__p_at ?p d000__c_palace) (d000__p_at ?k d000__c_palace)))
    :effect (d000__p_married ?p ?k)
  )

  (:action d000__a_king_requests_information_and_gifts
    :parameters (?k - object ?p - object ?r - object ?s - object)
    :precondition (and (typeguard__d000__t_entity ?k) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?r) (typeguard__d000__t_item ?s) (and (d000__p_at ?p d000__c_palace) (d000__p_has ?p ?r) (d000__p_has ?p ?s) (d000__p_at ?k d000__c_palace)))
    :effect (and (d000__p_has ?k ?r) (d000__p_has ?k ?s) (not (d000__p_has ?p ?r)) (not (d000__p_has ?p ?s)))
  )

  (:action d000__a_princess_accepts_with_heart
    :parameters (?k - object ?p - object)
    :precondition (and (typeguard__d000__t_entity ?k) (typeguard__d000__t_entity ?p) (and (d000__p_married ?p ?k) (not (d000__p_with_all_my_heart_spoken))))
    :effect (d000__p_with_all_my_heart_spoken)
  )

  (:action d000__a_receive_rubies_from_impostor
    :parameters (?i - object ?p - object ?r - object)
    :precondition (and (typeguard__d000__t_entity ?i) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?r) (and (d000__p_price_of_butter_spoken) (d000__p_at ?p d000__c_market_place) (d000__p_has ?i ?r)))
    :effect (and (d000__p_has ?p ?r) (not (d000__p_has ?i ?r)))
  )

  (:action d000__a_receive_sapphires_from_robber_chief
    :parameters (?c - object ?p - object ?s - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?p) (typeguard__d000__t_item ?s) (and (d000__p_grandmother_mangle_spoken) (d000__p_at ?p d000__c_oak_tree) (d000__p_has ?c ?s)))
    :effect (and (d000__p_has ?p ?s) (not (d000__p_has ?c ?s)))
  )

  (:action d000__a_run_away_from_palace
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_entity ?p) (d000__p_at ?p d000__c_back_stairs))
    :effect (and (d000__p_at ?p d000__c_city) (not (d000__p_at ?p d000__c_back_stairs)))
  )

  (:action d000__a_suitors_retire_due_to_phrase
    :parameters (?s - object)
    :precondition (and (typeguard__d000__t_entity ?s) (and (d000__p_grandmother_mangle_spoken) (d000__p_at ?s d000__c_palace)))
    :effect (not (d000__p_married ?s d000__c_princess))
  )

  (:action d000__a_utter_phrase_grandmother_mangle
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_entity ?p) (and (d000__p_at ?p d000__c_oak_tree) (not (d000__p_grandmother_mangle_spoken))))
    :effect (d000__p_grandmother_mangle_spoken)
  )

  (:action d000__a_utter_phrase_price_of_butter
    :parameters (?p - object)
    :precondition (and (typeguard__d000__t_entity ?p) (and (d000__p_at ?p d000__c_market_place) (not (d000__p_price_of_butter_spoken))))
    :effect (d000__p_price_of_butter_spoken)
  )
)
