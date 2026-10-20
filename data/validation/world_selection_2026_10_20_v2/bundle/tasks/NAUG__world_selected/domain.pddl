(define (domain narrative_aligned)
  (:requirements :adl :negative-preconditions :strips :typing)
  (:constants
    d000__c_bungo d000__c_chalk d000__c_comet_house d000__c_comet_master d000__c_courtyard d000__c_earth d000__c_gate d000__c_long_tail_45 d000__c_meteor d000__c_meteor_keeper d000__c_no1_express d000__c_short_tail_73 d000__c_slate d000__c_sun - object
  )
  (:predicates
    (d000__p_arrested ?a0 - object ?a1 - object)
    (d000__p_at ?a0 - object ?a1 - object)
    (d000__p_avoid ?a0 - object ?a1 - object)
    (d000__p_burned ?a0 - object)
    (d000__p_crossed_out ?a0 - object)
    (d000__p_delivered ?a0 - object ?a1 - object)
    (d000__p_detained ?a0 - object)
    (d000__p_gate_open)
    (d000__p_has_mission ?a0 - object)
    (d000__p_left_turn_rule ?a0 - object)
    (d000__p_near ?a0 - object ?a1 - object)
    (d000__p_on_list ?a0 - object)
    (d000__p_prohibit_speak ?a0 - object)
    (d000__p_punished ?a0 - object)
    (d000__p_rule_violation ?a0 - object)
    (d000__p_speaks_to ?a0 - object ?a1 - object)
    (d000__p_summoned ?a0 - object)
    (d000__p_traveling ?a0 - object)
    (typeguard__d000__t_entity ?member - object)
    (typeguard__d000__t_item ?member - object)
    (typeguard__d000__t_location ?member - object)
    (typeguard__d000__t_object ?member - object)
  )

  (:action d000__a_approach_sun
    :parameters (?c - object)
    :precondition (and (typeguard__d000__t_entity ?c) (and (d000__p_traveling ?c) (d000__p_avoid ?c d000__c_sun)))
    :effect (d000__p_near ?c d000__c_sun)
  )

  (:action d000__a_arrest_meteor
    :parameters (?c - object ?m - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?m) (and (d000__p_traveling ?c) (d000__p_near ?c ?m)))
    :effect (and (d000__p_arrested ?c ?m) (d000__p_detained ?m))
  )

  (:action d000__a_avoid_body
    :parameters (?b - object ?c - object)
    :precondition (and (typeguard__d000__t_entity ?b) (typeguard__d000__t_entity ?c) (and (d000__p_traveling ?c) (d000__p_avoid ?c ?b) (d000__p_near ?c ?b)))
    :effect (not (d000__p_near ?c ?b))
  )

  (:action d000__a_burn_up
    :parameters (?c - object)
    :precondition (and (typeguard__d000__t_entity ?c) (d000__p_near ?c d000__c_sun))
    :effect (and (d000__p_burned ?c) (not (d000__p_traveling ?c)) (not (d000__p_has_mission ?c)))
  )

  (:action d000__a_call_comet_forward
    :parameters (?c - object ?master - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?master) (and (d000__p_at ?c d000__c_courtyard) (d000__p_at ?master d000__c_courtyard)))
    :effect (d000__p_summoned ?c)
  )

  (:action d000__a_cross_out_comet
    :parameters (?c - object)
    :precondition (and (typeguard__d000__t_entity ?c) (d000__p_burned ?c))
    :effect (and (d000__p_crossed_out ?c) (not (d000__p_on_list ?c)))
  )

  (:action d000__a_deliver_meteor_to_bungo
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (d000__p_detained ?m))
    :effect (d000__p_delivered ?m d000__c_bungo)
  )

  (:action d000__a_give_order
    :parameters (?c - object ?master - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?master) (and (d000__p_at ?c d000__c_courtyard) (d000__p_at ?master d000__c_courtyard) (not (d000__p_has_mission ?c))))
    :effect (and (d000__p_has_mission ?c) (d000__p_left_turn_rule ?c) (d000__p_prohibit_speak ?c) (d000__p_avoid ?c d000__c_sun) (d000__p_avoid ?c d000__c_earth) (d000__p_avoid ?c d000__c_bungo))
  )

  (:action d000__a_prohibit_speaking_to_meteor
    :parameters (?c - object)
    :precondition (and (typeguard__d000__t_entity ?c) (d000__p_has_mission ?c))
    :effect (d000__p_prohibit_speak ?c)
  )

  (:action d000__a_punish_meteor
    :parameters (?m - object)
    :precondition (and (typeguard__d000__t_entity ?m) (d000__p_delivered ?m d000__c_bungo))
    :effect (d000__p_punished ?m)
  )

  (:action d000__a_speak_to_meteor
    :parameters (?c - object ?m - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?m) (and (d000__p_traveling ?c) (d000__p_prohibit_speak ?c) (d000__p_near ?c ?m)))
    :effect (and (d000__p_speaks_to ?c ?m) (d000__p_rule_violation ?c))
  )

  (:action d000__a_start_travel
    :parameters (?c - object)
    :precondition (and (typeguard__d000__t_entity ?c) (and (d000__p_has_mission ?c) (d000__p_gate_open)))
    :effect (and (d000__p_traveling ?c) (not (d000__p_at ?c d000__c_courtyard)))
  )

  (:action d000__a_turn_left_on_meeting
    :parameters (?c - object ?other - object)
    :precondition (and (typeguard__d000__t_entity ?c) (typeguard__d000__t_entity ?other) (and (d000__p_traveling ?c) (d000__p_traveling ?other) (d000__p_left_turn_rule ?c) (d000__p_near ?c ?other)))
    :effect (d000__p_left_turn_rule ?c)
  )
)
