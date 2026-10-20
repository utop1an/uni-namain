(define (domain narrative_union)
  (:requirements :strips :typing)
  (:types
    d000__t_object - object
  )
  (:predicates
    (d000__p_at ?b - d000__t_object ?r - d000__t_object)
    (d000__p_at-robby ?r - d000__t_object)
    (d000__p_ball ?b - d000__t_object)
    (d000__p_carry ?o - d000__t_object ?g - d000__t_object)
    (d000__p_free ?g - d000__t_object)
    (d000__p_gripper ?g - d000__t_object)
    (d000__p_room ?r - d000__t_object)
  )

  (:action d000__a_drop
    :parameters (?obj - d000__t_object ?room - d000__t_object ?gripper - d000__t_object)
    :precondition (and (d000__p_ball ?obj) (d000__p_room ?room) (d000__p_gripper ?gripper) (d000__p_carry ?obj ?gripper) (d000__p_at-robby ?room))
    :effect (and (d000__p_at ?obj ?room) (d000__p_free ?gripper) (not (d000__p_carry ?obj ?gripper)))
  )

  (:action d000__a_move
    :parameters (?from - d000__t_object ?to - d000__t_object)
    :precondition (and (d000__p_room ?from) (d000__p_room ?to) (d000__p_at-robby ?from))
    :effect (and (d000__p_at-robby ?to) (not (d000__p_at-robby ?from)))
  )

  (:action d000__a_pick
    :parameters (?obj - d000__t_object ?room - d000__t_object ?gripper - d000__t_object)
    :precondition (and (d000__p_ball ?obj) (d000__p_room ?room) (d000__p_gripper ?gripper) (d000__p_at ?obj ?room) (d000__p_at-robby ?room) (d000__p_free ?gripper))
    :effect (and (d000__p_carry ?obj ?gripper) (not (d000__p_at ?obj ?room)) (not (d000__p_free ?gripper)))
  )
)
