(define (domain unified_narrative_domain)
  (:requirements :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    ass brown_hen butcher captain cat cock fairy_maiden giant giant_dog giant_wife hound jack jack_mother man messenger milky_white robber - entity
    axe drinks gold_bag_1 gold_bag_2 golden_harp kettledrums lute magic_beans meat oak_tree_club straw table - item
    beam beanstalk bremen castle_road cottage forest garden giant_castle hearth kettle market oven road_to_bremen robbers_cottage window - location
  )
  (:predicates
    (agreed ?e - entity ?inviter - entity)
    (asleep ?e - entity)
    (at ?e - entity ?l - location)
    (at_item ?i - item ?l - location)
    (ate_all ?e - entity)
    (attacked ?attacker - entity ?target - entity)
    (attempt_light ?messenger - entity)
    (beanstalk_grown)
    (bite ?dog - entity ?target - entity)
    (climbing_down ?e - entity)
    (crowed ?cock - entity)
    (dead ?e - entity)
    (distracted ?e - entity)
    (empty ?i - item)
    (fled ?robber - entity ?loc - location)
    (has ?e - entity ?i - item)
    (has_breakfast ?e - entity)
    (inside ?e - entity ?i - item)
    (intact ?l - location)
    (invited ?inviter - entity ?invitee - entity)
    (kick ?donkey - entity ?target - entity)
    (light_off ?loc - location)
    (light_on ?loc - location)
    (making_noise ?e - entity)
    (moving_towards ?e - entity ?loc - location)
    (offers ?e - entity ?i - item)
    (on ?i - item ?l - location)
    (planted ?i - item)
    (resting ?e - entity)
    (retreated ?robber - entity)
    (sees_light ?e - entity)
    (sleeping_at ?e - entity ?loc - location)
    (stacked_on ?top - entity ?bottom - entity)
    (window_shattered)
  )

  (:action approach_cottage
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage ?forest - location)
    :precondition (and (sees_light ?cock) (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (moving_towards ?donkey ?cottage) (moving_towards ?hound ?cottage) (moving_towards ?cat ?cottage) (moving_towards ?cock ?cottage) (not (at ?donkey ?forest)) (not (at ?hound ?forest)) (not (at ?cat ?forest)) (not (at ?cock ?forest)))
  )

  (:action ask_giant_wife_for_breakfast
    :parameters (?j ?wife - entity)
    :precondition (and (at ?j giant_castle) (at ?wife giant_castle))
    :effect (has_breakfast ?j)
  )

  (:action cat_agrees
    :parameters (?cat ?donkey - entity)
    :precondition (invited ?donkey ?cat)
    :effect (agreed ?cat ?donkey)
  )

  (:action cat_attack_messenger
    :parameters (?cat ?messenger - entity)
    :precondition (and (attempt_light ?messenger) (at ?cat hearth))
    :effect (attacked ?cat ?messenger)
  )

  (:action choose_sleep_spot
    :parameters (?cat ?cock - entity ?beam ?hearth - location)
    :precondition (and (at ?cat ?hearth) (at ?cock ?beam))
    :effect (and (sleeping_at ?cat ?hearth) (sleeping_at ?cock ?beam))
  )

  (:action climb_beanstalk
    :parameters (?j - entity)
    :precondition (and (beanstalk_grown) (at ?j beanstalk))
    :effect (and (at ?j giant_castle) (not (at ?j beanstalk)))
  )

  (:action cock_agrees
    :parameters (?cock ?donkey - entity)
    :precondition (invited ?donkey ?cock)
    :effect (agreed ?cock ?donkey)
  )

  (:action cock_crow_alert
    :parameters (?cock - entity)
    :precondition (at ?cock beam)
    :effect (crowed ?cock)
  )

  (:action cut_beanstalk
    :parameters (?giant ?mother - entity ?axe - item)
    :precondition (and (intact beanstalk) (climbing_down ?giant))
    :effect (and (dead ?giant) (not (intact beanstalk)))
  )

  (:action dog_bite_messenger
    :parameters (?hound ?messenger - entity ?cottage - location)
    :precondition (and (attempt_light ?messenger) (at ?hound ?cottage))
    :effect (bite ?hound ?messenger)
  )

  (:action donkey_kick_messenger
    :parameters (?donkey ?messenger - entity)
    :precondition (attempt_light ?messenger)
    :effect (kick ?donkey ?messenger)
  )

  (:action eat_feast
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage) (window_shattered))
    :effect (and (ate_all ?donkey) (ate_all ?hound) (ate_all ?cat) (ate_all ?cock))
  )

  (:action extinguish_light
    :parameters (?cottage - location)
    :precondition (light_on ?cottage)
    :effect (and (light_off ?cottage) (not (light_on ?cottage)))
  )

  (:action grow_beanstalk
    :parameters (?beans - item)
    :precondition (planted ?beans)
    :effect (and (beanstalk_grown) (intact beanstalk))
  )

  (:action hide_in_kettle
    :parameters (?j - entity ?kettle - item)
    :precondition (and (at ?j giant_castle) (empty ?kettle))
    :effect (and (inside ?j ?kettle) (not (at ?j giant_castle)))
  )

  (:action hide_in_oven
    :parameters (?j - entity ?oven - item)
    :precondition (at ?j giant_castle)
    :effect (and (inside ?j ?oven) (not (at ?j giant_castle)))
  )

  (:action hound_agrees
    :parameters (?donkey ?hound - entity)
    :precondition (invited ?donkey ?hound)
    :effect (agreed ?hound ?donkey)
  )

  (:action invite_cat
    :parameters (?cat ?donkey - entity)
    :effect (invited ?donkey ?cat)
  )

  (:action invite_cock
    :parameters (?cock ?donkey - entity ?loc - location)
    :precondition (and (at ?donkey ?loc) (at ?cock ?loc))
    :effect (invited ?donkey ?cock)
  )

  (:action invite_hound
    :parameters (?donkey ?hound - entity)
    :effect (invited ?donkey ?hound)
  )

  (:action messenger_attempt_light
    :parameters (?messenger - entity ?cottage - location)
    :precondition (light_off ?cottage)
    :effect (attempt_light ?messenger)
  )

  (:action plan_scaring_robbers
    :parameters (?cat ?cock ?donkey ?hound - entity ?cottage - location)
    :precondition (and (at ?donkey ?cottage) (at ?hound ?cottage) (at ?cat ?cottage) (at ?cock ?cottage))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
  )

  (:action plant_beans
    :parameters (?beans - item ?loc - location)
    :precondition (at_item ?beans ?loc)
    :effect (and (planted ?beans) (not (at_item ?beans ?loc)))
  )

  (:action rest_in_forest
    :parameters (?cat ?cock ?donkey ?hound - entity ?forest - location)
    :precondition (and (at ?donkey ?forest) (at ?hound ?forest) (at ?cat ?forest) (at ?cock ?forest))
    :effect (and (resting ?donkey) (resting ?hound) (resting ?cat) (resting ?cock))
  )

  (:action return_down_beanstalk
    :parameters (?j - entity)
    :precondition (at ?j giant_castle)
    :effect (and (at ?j cottage) (not (at ?j giant_castle)))
  )

  (:action robbers_flee
    :parameters (?robber - entity ?cottage ?forest - location)
    :precondition (and (window_shattered) (at ?robber ?cottage))
    :effect (and (fled ?robber ?forest) (not (at ?robber ?cottage)))
  )

  (:action robbers_retreat
    :parameters (?robber - entity ?cottage - location)
    :precondition (at ?robber ?cottage)
    :effect (and (retreated ?robber) (not (at ?robber ?cottage)))
  )

  (:action run_away
    :parameters (?donkey - entity ?from ?to - location)
    :precondition (at ?donkey ?from)
    :effect (and (at ?donkey ?to) (moving_towards ?donkey ?to) (not (at ?donkey ?from)))
  )

  (:action sell_cow_for_beans
    :parameters (?b ?cow ?j - entity ?beans - item ?l - location)
    :precondition (and (at ?j ?l) (at ?cow ?l) (offers ?b ?beans) (at ?b ?l))
    :effect (and (has ?j ?beans) (not (offers ?b ?beans)) (not (at_item ?beans ?l)))
  )

  (:action signal_and_make_noise
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
    :effect (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock) (window_shattered))
  )

  (:action spot_light
    :parameters (?cock - entity ?cottage ?forest - location)
    :precondition (and (at ?cock ?forest) (resting ?cock))
    :effect (and (sees_light ?cock) (moving_towards ?cock ?cottage))
  )

  (:action stack_animals
    :parameters (?cat ?cock ?donkey ?hound - entity)
    :precondition (and (making_noise ?donkey) (making_noise ?hound) (making_noise ?cat) (making_noise ?cock))
    :effect (and (stacked_on ?hound ?donkey) (stacked_on ?cat ?hound) (stacked_on ?cock ?cat))
  )

  (:action steal_gold_bags
    :parameters (?j - entity ?bag1 ?bag2 - item)
    :precondition (and (asleep giant) (at_item ?bag1 giant_castle) (at_item ?bag2 giant_castle))
    :effect (and (has ?j ?bag1) (has ?j ?bag2) (not (at_item ?bag1 giant_castle)) (not (at_item ?bag2 giant_castle)))
  )

  (:action steal_harp
    :parameters (?giant ?j - entity ?harp - item)
    :precondition (and (on ?harp giant_castle) (asleep ?giant))
    :effect (and (has ?j ?harp) (not (on ?harp giant_castle)))
  )

  (:action steal_hen
    :parameters (?giant ?j - entity ?hen - item)
    :precondition (and (on ?hen giant_castle) (distracted ?giant))
    :effect (and (has ?j ?hen) (not (on ?hen giant_castle)))
  )

  (:action travel_together
    :parameters (?cat ?cock ?donkey ?hound - entity ?from ?to - location)
    :precondition (and (at ?donkey ?from) (at ?hound ?from) (at ?cat ?from) (at ?cock ?from) (agreed ?hound ?donkey) (agreed ?cat ?donkey) (agreed ?cock ?donkey))
    :effect (and (at ?donkey ?to) (at ?hound ?to) (at ?cat ?to) (at ?cock ?to) (moving_towards ?donkey ?to) (moving_towards ?hound ?to) (moving_towards ?cat ?to) (moving_towards ?cock ?to) (not (at ?donkey ?from)) (not (at ?hound ?from)) (not (at ?cat ?from)) (not (at ?cock ?from)))
  )
)
