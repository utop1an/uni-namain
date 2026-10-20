(define (domain The_Accomplished_And_Lucky_Teakettle)
  (:requirements :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    badger friend lady_of_court priest prince princess showman tinker - entity
    box copper_coins pack teakettle temple_treasure - item
    jhosiu morinji tight_rope - location
  )
  (:predicates
    (airborne ?i - item)
    (badger_form ?i - item)
    (captured ?i - item)
    (contained_in ?i - item ?c - item)
    (exhibition_ready ?e - entity)
    (four_legged ?i - item)
    (furred ?i - item)
    (hanging ?i - item)
    (has ?e - entity ?i - item)
    (located ?obj - object ?loc - location)
    (night)
    (owned_by ?i - item ?e - entity)
    (performing_show ?e - entity)
    (reputation_widespread)
    (treasured ?i - item)
    (wealthy ?e - entity)
    (worshipped ?i - item)
  )

  (:action arrange_exhibition
    :parameters (?s ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (exhibition_ready ?t)
  )

  (:action call_novices
    :parameters (?pr - entity ?k - item)
    :precondition (badger_form ?k)
    :effect (located ?k morinji)
  )

  (:action force_kettle_into_box
    :parameters (?b ?k - item)
    :precondition (captured ?k)
    :effect (contained_in ?k ?b)
  )

  (:action hang_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (has ?pr ?k)
    :effect (hanging ?k)
  )

  (:action kettle_jump_and_fly
    :parameters (?k - item)
    :precondition (badger_form ?k)
    :effect (airborne ?k)
  )

  (:action kettle_revert_shape
    :parameters (?k - item)
    :precondition (and (badger_form ?k) (furred ?k))
    :effect (and (not (badger_form ?k)) (not (furred ?k)) (not (four_legged ?k)))
  )

  (:action kettle_transform_to_badger
    :parameters (?k - item)
    :precondition (hanging ?k)
    :effect (badger_form ?k)
  )

  (:action kettle_transform_to_fur_badger
    :parameters (?t - entity ?k - item)
    :precondition (and (night) (located ?k jhosiu) (has ?t ?k))
    :effect (and (furred ?k) (badger_form ?k) (four_legged ?k))
  )

  (:action knock_down_kettle
    :parameters (?k - item)
    :precondition (airborne ?k)
    :effect (and (captured ?k) (not (airborne ?k)))
  )

  (:action perform_show
    :parameters (?t - entity ?k - item)
    :precondition (and (exhibition_ready ?t) (has ?t ?k))
    :effect (and (performing_show ?t) (reputation_widespread))
  )

  (:action pursue_kettle
    :parameters (?pr - entity ?k - item)
    :precondition (airborne ?k)
    :effect (and (captured ?k) (not (airborne ?k)))
  )

  (:action receive_orders_from_nobility
    :parameters (?t - entity)
    :precondition (reputation_widespread)
    :effect (wealthy ?t)
  )

  (:action return_kettle_to_temple
    :parameters (?t - entity ?k - item)
    :precondition (and (has ?t ?k) (wealthy ?t))
    :effect (and (located ?k morinji) (treasured ?k) (not (has ?t ?k)))
  )

  (:action sell_kettle_to_tinker
    :parameters (?pr ?t - entity ?c ?k - item)
    :precondition (and (has ?pr ?k) (has ?t ?c))
    :effect (and (has ?t ?k) (has ?pr ?c) (not (has ?pr ?k)) (not (has ?t ?c)))
  )

  (:action show_kettle_to_friend
    :parameters (?f ?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (has ?f ?k)
  )

  (:action tinker_carry_home
    :parameters (?t - entity ?k - item)
    :precondition (has ?t ?k)
    :effect (located ?k jhosiu)
  )

  (:action worship_kettle_as_saint
    :parameters (?k - item)
    :precondition (treasured ?k)
    :effect (worshipped ?k)
  )
)
