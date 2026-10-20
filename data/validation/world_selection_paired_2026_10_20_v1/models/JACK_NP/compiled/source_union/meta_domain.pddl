(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_entity d000__t_item d000__t_location - d000__t_object
    d000__t_object - object
  )
  (:constants
    d000__c_brown_hen d000__c_butcher d000__c_fairy_maiden d000__c_giant d000__c_giant_dog d000__c_giant_wife d000__c_jack d000__c_jack_mother d000__c_milky_white - d000__t_entity
    d000__c_axe d000__c_gold_bag_1 d000__c_gold_bag_2 d000__c_golden_harp d000__c_magic_beans d000__c_oak_tree_club - d000__t_item
    d000__c_beanstalk d000__c_castle_road d000__c_cottage d000__c_garden d000__c_giant_castle d000__c_kettle d000__c_market d000__c_oven d000__c_window - d000__t_location
  )
  (:predicates
    (d000__p_asleep ?e - d000__t_entity)
    (d000__p_at ?e - d000__t_entity ?l - d000__t_location)
    (d000__p_at_item ?i - d000__t_item ?l - d000__t_location)
    (d000__p_beanstalk_grown)
    (d000__p_climbing_down ?e - d000__t_entity)
    (d000__p_dead ?e - d000__t_entity)
    (d000__p_distracted ?e - d000__t_entity)
    (d000__p_empty ?i - d000__t_item)
    (d000__p_has ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_has_breakfast ?e - d000__t_entity)
    (d000__p_inside ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_intact ?l - d000__t_location)
    (d000__p_offers ?e - d000__t_entity ?i - d000__t_item)
    (d000__p_on ?i - d000__t_item ?l - d000__t_location)
    (d000__p_planted ?i - d000__t_item)
  )

  (:action d000__a_ask_giant_wife_for_breakfast
    :parameters (?j - d000__t_entity ?wife - d000__t_entity)
    :precondition (and (d000__p_at ?j d000__c_giant_castle) (d000__p_at ?wife d000__c_giant_castle))
    :effect (d000__p_has_breakfast ?j)
  )

  (:action d000__a_climb_beanstalk
    :parameters (?j - d000__t_entity)
    :precondition (and (d000__p_beanstalk_grown) (d000__p_at ?j d000__c_beanstalk))
    :effect (and (d000__p_at ?j d000__c_giant_castle) (not (d000__p_at ?j d000__c_beanstalk)))
  )

  (:action d000__a_cut_beanstalk
    :parameters (?giant - d000__t_entity ?mother - d000__t_entity ?axe - d000__t_item)
    :precondition (and (d000__p_intact d000__c_beanstalk) (d000__p_climbing_down ?giant))
    :effect (and (d000__p_dead ?giant) (not (d000__p_intact d000__c_beanstalk)))
  )

  (:action d000__a_grow_beanstalk
    :parameters (?beans - d000__t_item)
    :precondition (d000__p_planted ?beans)
    :effect (and (d000__p_beanstalk_grown) (d000__p_intact d000__c_beanstalk))
  )

  (:action d000__a_hide_in_kettle
    :parameters (?j - d000__t_entity ?kettle - d000__t_item)
    :precondition (and (d000__p_at ?j d000__c_giant_castle) (d000__p_empty ?kettle))
    :effect (and (d000__p_inside ?j ?kettle) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_hide_in_oven
    :parameters (?j - d000__t_entity ?oven - d000__t_item)
    :precondition (d000__p_at ?j d000__c_giant_castle)
    :effect (and (d000__p_inside ?j ?oven) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_plant_beans
    :parameters (?beans - d000__t_item ?loc - d000__t_location)
    :precondition (d000__p_at_item ?beans ?loc)
    :effect (and (d000__p_planted ?beans) (not (d000__p_at_item ?beans ?loc)))
  )

  (:action d000__a_return_down_beanstalk
    :parameters (?j - d000__t_entity)
    :precondition (d000__p_at ?j d000__c_giant_castle)
    :effect (and (d000__p_at ?j d000__c_cottage) (not (d000__p_at ?j d000__c_giant_castle)))
  )

  (:action d000__a_sell_cow_for_beans
    :parameters (?b - d000__t_entity ?cow - d000__t_entity ?j - d000__t_entity ?beans - d000__t_item ?l - d000__t_location)
    :precondition (and (d000__p_at ?j ?l) (d000__p_at ?cow ?l) (d000__p_offers ?b ?beans) (d000__p_at ?b ?l))
    :effect (and (d000__p_has ?j ?beans) (not (d000__p_offers ?b ?beans)) (not (d000__p_at_item ?beans ?l)))
  )

  (:action d000__a_steal_gold_bags
    :parameters (?j - d000__t_entity ?bag1 - d000__t_item ?bag2 - d000__t_item)
    :precondition (and (d000__p_asleep d000__c_giant) (d000__p_at_item ?bag1 d000__c_giant_castle) (d000__p_at_item ?bag2 d000__c_giant_castle))
    :effect (and (d000__p_has ?j ?bag1) (d000__p_has ?j ?bag2) (not (d000__p_at_item ?bag1 d000__c_giant_castle)) (not (d000__p_at_item ?bag2 d000__c_giant_castle)))
  )

  (:action d000__a_steal_harp
    :parameters (?giant - d000__t_entity ?j - d000__t_entity ?harp - d000__t_item)
    :precondition (and (d000__p_on ?harp d000__c_giant_castle) (d000__p_asleep ?giant))
    :effect (and (d000__p_has ?j ?harp) (not (d000__p_on ?harp d000__c_giant_castle)))
  )

  (:action d000__a_steal_hen
    :parameters (?giant - d000__t_entity ?j - d000__t_entity ?hen - d000__t_item)
    :precondition (and (d000__p_on ?hen d000__c_giant_castle) (d000__p_distracted ?giant))
    :effect (and (d000__p_has ?j ?hen) (not (d000__p_on ?hen d000__c_giant_castle)))
  )
)
