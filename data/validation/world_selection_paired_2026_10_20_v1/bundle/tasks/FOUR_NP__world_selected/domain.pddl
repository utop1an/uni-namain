(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_brother_astronomer d000__c_brother_hunter d000__c_brother_tailor d000__c_brother_thief d000__c_chaffinch d000__c_cross_way d000__c_dragon d000__c_eggs d000__c_father d000__c_gun d000__c_house d000__c_king d000__c_kingdom d000__c_mentor_astronomer d000__c_mentor_hunter d000__c_mentor_tailor d000__c_mentor_thief d000__c_needle d000__c_planks d000__c_princess d000__c_rock_sea d000__c_sea d000__c_ship d000__c_sticks d000__c_telescope d000__c_town_gate d000__c_tree - object
  )
  (:predicates
    (d000__p_dragon_dead)
    (d000__p_eggs_fetched ?a0 - object)
    (d000__p_eggs_sewn ?a0 - object)
    (d000__p_eggs_shot ?a0 - object)
    (d000__p_entity_at ?a0 - object ?a1 - object)
    (d000__p_half_kingdom ?a0 - object ?a1 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_is_astronomer ?a0 - object)
    (d000__p_is_hunter ?a0 - object)
    (d000__p_is_tailor ?a0 - object)
    (d000__p_is_thief ?a0 - object)
    (d000__p_item_at ?a0 - object ?a1 - object)
    (d000__p_princess_rescued ?a0 - object)
    (d000__p_reward_received ?a0 - object)
    (d000__p_ship_broken)
    (d000__p_ship_repaired)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_count_eggs
    :parameters (?a - object)
    :precondition (and (typeguard__d000__t_entity ?a) (and (d000__p_is_astronomer ?a) (d000__p_has ?a d000__c_telescope) (d000__p_entity_at ?a d000__c_tree)))
    :effect (d000__p_has ?a d000__c_eggs)
  )

  (:action d000__a_fetch_eggs
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (and (d000__p_is_thief ?t) (d000__p_entity_at ?t d000__c_tree) (d000__p_item_at d000__c_eggs d000__c_tree)))
    :effect (and (d000__p_eggs_fetched ?t) (d000__p_has ?t d000__c_eggs) (not (d000__p_item_at d000__c_eggs d000__c_tree)))
  )

  (:action d000__a_learn_astronomer_trade
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (and (d000__p_is_astronomer ?b) (d000__p_has ?b d000__c_telescope))
  )

  (:action d000__a_learn_hunter_trade
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (and (d000__p_is_hunter ?b) (d000__p_has ?b d000__c_gun))
  )

  (:action d000__a_learn_tailor_trade
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (and (d000__p_is_tailor ?b) (d000__p_has ?b d000__c_needle))
  )

  (:action d000__a_learn_thief_trade
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (d000__p_is_thief ?b)
  )

  (:action d000__a_leave_home
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_house))
    :effect (and (d000__p_entity_at ?b d000__c_town_gate) (not (d000__p_entity_at ?b d000__c_house)))
  )

  (:action d000__a_locate_princess
    :parameters (?a - object)
    :precondition (and (typeguard__d000__t_entity ?a) (and (d000__p_is_astronomer ?a) (d000__p_has ?a d000__c_telescope)))
    :effect (d000__p_entity_at d000__c_princess d000__c_rock_sea)
  )

  (:action d000__a_obtain_ship
    :parameters (?a - object)
    :precondition (and (typeguard__d000__t_entity ?a) (d000__p_is_astronomer ?a))
    :effect (d000__p_has ?a d000__c_ship)
  )

  (:action d000__a_receive_reward
    :parameters (?e - object)
    :precondition (and (typeguard__d000__t_entity ?e) (d000__p_princess_rescued ?e))
    :effect (and (d000__p_reward_received ?e) (d000__p_half_kingdom ?e d000__c_kingdom))
  )

  (:action d000__a_repair_ship
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (and (d000__p_is_tailor ?t) (d000__p_has ?t d000__c_needle) (d000__p_ship_broken)))
    :effect (and (d000__p_ship_repaired) (not (d000__p_ship_broken)))
  )

  (:action d000__a_return_eggs_to_nest
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (and (d000__p_is_thief ?t) (d000__p_eggs_sewn d000__c_brother_tailor) (d000__p_entity_at ?t d000__c_tree) (d000__p_has ?t d000__c_eggs)))
    :effect (and (d000__p_item_at d000__c_eggs d000__c_tree) (not (d000__p_has ?t d000__c_eggs)))
  )

  (:action d000__a_return_home_with_princess
    :parameters (?a - object)
    :precondition (and (typeguard__d000__t_entity ?a) (and (d000__p_ship_repaired) (d000__p_entity_at ?a d000__c_sea)))
    :effect (and (d000__p_entity_at ?a d000__c_house) (d000__p_entity_at d000__c_princess d000__c_house) (not (d000__p_entity_at ?a d000__c_sea)))
  )

  (:action d000__a_reunite_at_crossroads
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (and (d000__p_entity_at ?b d000__c_house) (not (d000__p_entity_at ?b d000__c_cross_way)))
  )

  (:action d000__a_sail_to_rock
    :parameters (?a - object)
    :precondition (and (typeguard__d000__t_entity ?a) (and (d000__p_has ?a d000__c_ship) (d000__p_entity_at ?a d000__c_house)))
    :effect (and (d000__p_entity_at ?a d000__c_rock_sea) (not (d000__p_entity_at ?a d000__c_house)))
  )

  (:action d000__a_separate_at_crossroads
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_entity_at ?b d000__c_cross_way))
    :effect (d000__p_has ?b d000__c_sticks)
  )

  (:action d000__a_sew_eggs
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (and (d000__p_is_tailor ?t) (d000__p_has ?t d000__c_needle) (d000__p_eggs_shot d000__c_brother_hunter)))
    :effect (d000__p_eggs_sewn ?t)
  )

  (:action d000__a_shoot_dragon
    :parameters (?h - object)
    :precondition (and (typeguard__d000__t_entity ?h) (and (d000__p_is_hunter ?h) (d000__p_has ?h d000__c_gun) (d000__p_entity_at d000__c_dragon d000__c_rock_sea)))
    :effect (and (d000__p_dragon_dead) (d000__p_ship_broken) (not (d000__p_entity_at d000__c_dragon d000__c_rock_sea)))
  )

  (:action d000__a_shoot_eggs
    :parameters (?h - object)
    :precondition (and (typeguard__d000__t_entity ?h) (and (d000__p_is_hunter ?h) (d000__p_has ?h d000__c_gun) (d000__p_eggs_fetched d000__c_brother_thief)))
    :effect (d000__p_eggs_shot ?h)
  )

  (:action d000__a_steal_princess
    :parameters (?t - object)
    :precondition (and (typeguard__d000__t_entity ?t) (and (d000__p_is_thief ?t) (d000__p_entity_at ?t d000__c_rock_sea) (d000__p_entity_at d000__c_princess d000__c_rock_sea) (d000__p_entity_at d000__c_dragon d000__c_rock_sea)))
    :effect (and (d000__p_princess_rescued ?t) (d000__p_entity_at d000__c_princess d000__c_sea) (not (d000__p_entity_at d000__c_princess d000__c_rock_sea)))
  )

  (:action d000__a_swim_after_ship_break
    :parameters (?b - object)
    :precondition (and (typeguard__d000__t_entity ?b) (d000__p_ship_broken))
    :effect (d000__p_entity_at ?b d000__c_sea)
  )
)
