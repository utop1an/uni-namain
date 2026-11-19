(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:predicates
    (human_281c51d26d5d4ff3_active)
    (human_281c51d26d5d4ff3_type_allworker ?x - object)
    (human_281c51d26d5d4ff3_type_axe ?x - object)
    (human_281c51d26d5d4ff3_type_beast ?x - object)
    (human_281c51d26d5d4ff3_type_blacksmith ?x - object)
    (human_281c51d26d5d4ff3_type_cake ?x - object)
    (human_281c51d26d5d4ff3_type_character ?x - object)
    (human_281c51d26d5d4ff3_type_fox ?x - object)
    (human_281c51d26d5d4ff3_type_girl ?x - object)
    (human_281c51d26d5d4ff3_type_grandmother ?x - object)
    (human_281c51d26d5d4ff3_type_house ?x - object)
    (human_281c51d26d5d4ff3_type_human ?x - object)
    (human_281c51d26d5d4ff3_type_hunter ?x - object)
    (human_281c51d26d5d4ff3_type_object ?x - object)
    (human_281c51d26d5d4ff3_type_thing ?x - object)
    (human_281c51d26d5d4ff3_type_wolf ?x - object)
    (human_281c51d26d5d4ff3_type_worker ?x - object)
    (human_281c51d26d5d4ff3_p_monster ?v0 - object)
    (human_281c51d26d5d4ff3_p_monster-alive)
    (human_281c51d26d5d4ff3_p_rescuer ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescuer-at ?v0 - object)
    (human_281c51d26d5d4ff3_p_alive ?v0 - object)
    (human_281c51d26d5d4ff3_p_has ?v0 - object ?v1 - object)
    (human_281c51d26d5d4ff3_p_eaten ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescued ?v0 - object)
    (human_281c51d26d5d4ff3_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_025_active)
    (tiny_stories__story_025_type_character ?x - object)
    (tiny_stories__story_025_type_object ?x - object)
    (tiny_stories__story_025_type_place ?x - object)
    (tiny_stories__story_025_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_stuck ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_helped ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_040_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_on-top ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_scared ?v0 - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (tiny_stories__story_086_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_086_p_scared ?v0 - object)
    (tiny_stories__story_086_p_spider-on-wall)
    (tiny_stories__story_086_p_happy ?v0 - object)
    (tiny_stories__story_086_p_cake-made)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
  )

  (:action human_281c51d26d5d4ff3_a_walk
    :parameters (?c - object ?h1 - object ?h2 - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_character ?c)
        (human_281c51d26d5d4ff3_type_house ?h1)
        (human_281c51d26d5d4ff3_type_house ?h2)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (human_281c51d26d5d4ff3_p_at ?c ?h1)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_at ?c ?h1))
        (human_281c51d26d5d4ff3_p_at ?c ?h2)
        (when
          (human_281c51d26d5d4ff3_p_rescuer ?c)
          (and
            (human_281c51d26d5d4ff3_p_rescuer-at ?h2)
            (not (human_281c51d26d5d4ff3_p_rescuer-at ?h1))
          )
        )
      )
  )

  (:action human_281c51d26d5d4ff3_a_eat
    :parameters (?m - object ?c - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?m)
          (human_281c51d26d5d4ff3_p_alive ?c)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
          (human_281c51d26d5d4ff3_p_at ?m ?h)
          (human_281c51d26d5d4ff3_p_at ?c ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
        )
      )
    :effect
      (human_281c51d26d5d4ff3_p_eaten ?c)
  )

  (:action human_281c51d26d5d4ff3_a_kill
    :parameters (?c - object ?m - object ?a - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_worker ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_axe ?a)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (human_281c51d26d5d4ff3_p_alive ?m)
          (human_281c51d26d5d4ff3_p_has ?c ?a)
          (human_281c51d26d5d4ff3_p_at ?c ?h)
          (human_281c51d26d5d4ff3_p_at ?m ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
          (human_281c51d26d5d4ff3_p_monster-alive)
          (human_281c51d26d5d4ff3_p_rescuer ?c)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_alive ?m))
        (not (human_281c51d26d5d4ff3_p_monster-alive))
      )
  )

  (:action human_281c51d26d5d4ff3_a_escape
    :parameters (?c - object ?m - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_eaten ?c)
          (not (human_281c51d26d5d4ff3_p_alive ?m))
          (human_281c51d26d5d4ff3_p_at ?m ?h)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_eaten ?c))
        (human_281c51d26d5d4ff3_p_rescued ?c)
        (human_281c51d26d5d4ff3_p_at ?c ?h)
      )
  )

  (:action human_281c51d26d5d4ff3_a_give
    :parameters (?c1 - object ?c2 - object ?t - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c1)
        (human_281c51d26d5d4ff3_type_human ?c2)
        (human_281c51d26d5d4ff3_type_thing ?t)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (not (human_281c51d26d5d4ff3_p_eaten ?c2))
          (human_281c51d26d5d4ff3_p_alive ?c1)
          (human_281c51d26d5d4ff3_p_alive ?c2)
          (human_281c51d26d5d4ff3_p_has ?c1 ?t)
          (human_281c51d26d5d4ff3_p_at ?c1 ?h)
          (human_281c51d26d5d4ff3_p_at ?c2 ?h)
        )
      )
    :effect
      (and
        (human_281c51d26d5d4ff3_p_has ?c2 ?t)
        (not (human_281c51d26d5d4ff3_p_has ?c1 ?t))
      )
  )

  (:action tiny_stories__story_025_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?from)
        (tiny_stories__story_025_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_025_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_025_p_at ?character ?from))
        (tiny_stories__story_025_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_get-stuck
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character)
        (tiny_stories__story_025_type_place ?place)
        (and
          (tiny_stories__story_025_p_at ?character ?place)
          (not (tiny_stories__story_025_p_stuck ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_025_p_stuck ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_025_a_help
    :parameters (?helper - object ?helpee - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?helper)
        (tiny_stories__story_025_type_character ?helpee)
        (tiny_stories__story_025_type_place ?place)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_025_p_at ?helper ?place)
          (tiny_stories__story_025_p_stuck ?helpee ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_025_p_stuck ?helpee ?place))
        (tiny_stories__story_025_p_helped ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_025_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_025_active)
        (tiny_stories__story_025_type_character ?character1)
        (tiny_stories__story_025_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (tiny_stories__story_025_p_friends ?character1 ?character2))
          (tiny_stories__story_025_p_helped ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_025_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_040_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_place ?from)
        (tiny_stories__story_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_at ?character ?from))
        (tiny_stories__story_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_retrieve-toy
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_toy ?toy)
        (tiny_stories__story_040_type_place ?place)
        (and
          (tiny_stories__story_040_p_at ?character ?place)
          (tiny_stories__story_040_p_on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_on-top ?toy ?place))
        (tiny_stories__story_040_p_has ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character1)
        (tiny_stories__story_040_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_040_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_040_a_overcome-fear
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_040_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?helper)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_086_p_scared ?helpee)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_086_p_scared ?helpee))
        (tiny_stories__story_086_p_happy ?helpee)
        (tiny_stories__story_086_p_helping ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_086_a_make-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_cake-made))
          (tiny_stories__story_086_p_happy ?character)
        )
      )
    :effect
      (tiny_stories__story_086_p_cake-made)
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_see-spider
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_scared ?character))
          (not (tiny_stories__story_086_p_spider-on-wall))
        )
      )
    :effect
      (and
        (tiny_stories__story_086_p_scared ?character)
        (tiny_stories__story_086_p_spider-on-wall)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_remove-spider
    :parameters (?character - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (tiny_stories__story_086_p_spider-on-wall)
          (tiny_stories__story_086_p_helping ?character ?helpee)
        )
      )
    :effect
      (not (tiny_stories__story_086_p_spider-on-wall))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (tiny_stories__story_095_p_at ?character ?place))
      )
    :effect
      (tiny_stories__story_095_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )
)
