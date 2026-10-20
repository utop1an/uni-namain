(define (domain narrative_aligned)
  (:requirements :adl :strips :typing)
  (:constants
    d000__c_axe d000__c_beanstalk d000__c_brown_hen d000__c_butcher d000__c_castle_road d000__c_cottage d000__c_fairy_maiden d000__c_garden d000__c_giant d000__c_giant_castle d000__c_giant_dog d000__c_giant_wife d000__c_gold_bag_1 d000__c_gold_bag_2 d000__c_golden_harp d000__c_jack d000__c_jack_mother d000__c_kettle d000__c_magic_beans d000__c_market d000__c_milky_white d000__c_oak_tree_club d000__c_oven d000__c_window - object
  )
  (:predicates
    (d000__p_asleep ?a0 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_at_item ?a0 - object ?a1 - object)
    (d000__p_beanstalk_grown)
    (d000__p_climbing_down ?a0 - object)
    (d000__p_dead ?a0 - object)
    (d000__p_distracted ?a0 - object)
    (d000__p_empty ?a0 - object)
    (d000__p_has ?a0 - object ?a1 - object)
    (d000__p_has_breakfast ?a0 - object)
    (d000__p_inside ?a0 - object ?a1 - object)
    (d000__p_intact ?a0 - object)
    (d000__p_offers ?a0 - object ?a1 - object)
    (d000__p_on ?a0 - object ?a1 - object)
    (d000__p_planted ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_ask_giant_wife_for_breakfast
    :parameters (?j - object ?wife - object)
    :precondition (and (typeguard__d000__t_entity ?j) (typeguard__d000__t_entity ?wife) (and (d000__p_at ?j d000__c_giant_castle) (d000__p_at ?wife d000__c_giant_castle)))
    :effect (d000__p_has_breakfast ?j)
  )

  (:action d000__a_climb_beanstalk
    :parameters (?j - object)
    :precondition (and (typeguard__d000__t_entity ?j) (and (d000__p_beanstalk_grown) (d000__p_at ?j d000__c_beanstalk)))
    :effect (and (d000__p_at ?j d000__c_giant_castle) (not (d000__p_at ?j d000__c_beanstalk)))
  )

  (:action d000__a_cut_beanstalk
    :parameters (?giant - object ?mother - object ?axe - object)
    :precondition (and (typeguard__d000__t_entity ?giant) (typeguard__d000__t_entity ?mother) (typeguard__d000__t_item ?axe) (and (d000__p_intact d000__c_beanstalk) (d000__p_climbing_down ?giant)))
    :effect (and (d000__p_dead ?giant) (not (d000__p_intact d000__c_beanstalk)))
  )

  (:action d000__a_grow_beanstalk
    :parameters (?beans - object)
    :precondition (and (typeguard__d000__t_item ?beans) (d000__p_planted ?beans))
    :effect (and (d000__p_beanstalk_grown) (d000__p_intact d000__c_beanstalk))
  )

  (:action d000__a_hide_in_kettle
    :parameters (?j - object ?kettle - object)
    :precondition (and (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?kettle) (and (d000__p_at ?j d000__c_giant_castle) (d000__p_empty ?kettle)))
    :effect (and (d000__p_inside ?j ?kettle) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_hide_in_oven
    :parameters (?j - object ?oven - object)
    :precondition (and (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?oven) (d000__p_at ?j d000__c_giant_castle))
    :effect (and (d000__p_inside ?j ?oven) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_plant_beans
    :parameters (?beans - object ?loc - object)
    :precondition (and (typeguard__d000__t_item ?beans) (typeguard__d000__t_location ?loc) (d000__p_at_item ?beans ?loc))
    :effect (and (d000__p_planted ?beans) (not (d000__p_at_item ?beans ?loc)))
  )

  (:action d000__a_return_down_beanstalk
    :parameters (?j - object)
    :precondition (and (typeguard__d000__t_entity ?j) (d000__p_at ?j d000__c_giant_castle))
    :effect (and (d000__p_at ?j d000__c_cottage) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_sell_cow_for_beans
    :parameters (?b - object ?cow - object ?j - object ?beans - object ?l - object)
    :precondition (and (typeguard__d000__t_entity ?b) (typeguard__d000__t_entity ?cow) (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?beans) (typeguard__d000__t_location ?l) (and (d000__p_at ?j ?l) (d000__p_at ?cow ?l) (d000__p_offers ?b ?beans) (d000__p_at ?b ?l)))
    :effect (and (d000__p_has ?j ?beans) (not (d000__p_offers ?b ?beans)) (not (d000__p_at_item ?beans ?l)))
  )

  (:action d000__a_steal_gold_bags
    :parameters (?j - object ?bag1 - object ?bag2 - object)
    :precondition (and (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?bag1) (typeguard__d000__t_item ?bag2) (and (d000__p_asleep d000__c_giant) (d000__p_at_item ?bag1 d000__c_giant_castle) (d000__p_at_item ?bag2 d000__c_giant_castle)))
    :effect (and (d000__p_has ?j ?bag1) (d000__p_has ?j ?bag2) (not (d000__p_at_item ?bag1 d000__c_giant_castle)) (not (d000__p_at_item ?bag2 d000__c_giant_castle)))
  )

  (:action d000__a_steal_harp
    :parameters (?giant - object ?j - object ?harp - object)
    :precondition (and (typeguard__d000__t_entity ?giant) (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?harp) (and (d000__p_on ?harp d000__c_giant_castle) (d000__p_asleep ?giant)))
    :effect (and (d000__p_has ?j ?harp) (not (d000__p_on ?harp d000__c_giant_castle)))
  )

  (:action d000__a_steal_hen
    :parameters (?giant - object ?j - object ?hen - object)
    :precondition (and (typeguard__d000__t_entity ?giant) (typeguard__d000__t_entity ?j) (typeguard__d000__t_item ?hen) (and (d000__p_on ?hen d000__c_giant_castle) (d000__p_distracted ?giant)))
    :effect (and (d000__p_has ?j ?hen) (not (d000__p_on ?hen d000__c_giant_castle)))
  )
)
