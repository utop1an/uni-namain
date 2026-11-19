(define (domain revised_merged)
  (:requirements :adl :typing :equality)
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
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (monster ?p0)
    (monster-alive)
    (rescuer ?p0)
    (rescuer-at ?p0)
    (alive ?p0)
    (has ?p0 ?p1)
    (eaten ?p0)
    (rescued ?p0)
    (at ?p0 ?p1)
    (in-drawer ?p0)
    (friends ?p0 ?p1)
    (wants-to-take ?p0 ?p1)
    (brave ?p0)
  )

  (:action walk
    :parameters (?c ?h1 ?h2)
    :precondition
      (and
        (and
          (human_281c51d26d5d4ff3_active)
          (human_281c51d26d5d4ff3_type_character ?c)
          (human_281c51d26d5d4ff3_type_house ?h1)
          (human_281c51d26d5d4ff3_type_house ?h2)
          (human_281c51d26d5d4ff3_type_character ?c)
          (human_281c51d26d5d4ff3_type_house ?h1)
          (human_281c51d26d5d4ff3_type_house ?h2)
        )
        (and
          (alive ?c)
          (at ?c ?h1)
          (not (eaten ?c))
        )
      )
    :effect
      (and
        (not (at ?c ?h1))
        (at ?c ?h2)
        (when
          (rescuer ?c)
          (and
            (rescuer-at ?h2)
            (not (rescuer-at ?h1))
          )
        )
      )
  )

  (:action eat
    :parameters (?m ?c ?h)
    :precondition
      (and
        (and
          (human_281c51d26d5d4ff3_active)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_human ?c)
          (human_281c51d26d5d4ff3_type_house ?h)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_human ?c)
          (human_281c51d26d5d4ff3_type_house ?h)
        )
        (and
          (alive ?m)
          (alive ?c)
          (not (eaten ?c))
          (at ?m ?h)
          (at ?c ?h)
          (monster ?m)
        )
      )
    :effect
      (eaten ?c)
  )

  (:action kill
    :parameters (?c ?m ?a ?h)
    :precondition
      (and
        (and
          (human_281c51d26d5d4ff3_active)
          (human_281c51d26d5d4ff3_type_worker ?c)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_axe ?a)
          (human_281c51d26d5d4ff3_type_house ?h)
          (human_281c51d26d5d4ff3_type_worker ?c)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_axe ?a)
          (human_281c51d26d5d4ff3_type_house ?h)
        )
        (and
          (alive ?c)
          (alive ?m)
          (has ?c ?a)
          (at ?c ?h)
          (at ?m ?h)
          (monster ?m)
          (monster-alive)
          (rescuer ?c)
        )
      )
    :effect
      (and
        (not (alive ?m))
        (not (monster-alive))
      )
  )

  (:action escape
    :parameters (?c ?m ?h)
    :precondition
      (and
        (and
          (human_281c51d26d5d4ff3_active)
          (human_281c51d26d5d4ff3_type_human ?c)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_house ?h)
          (human_281c51d26d5d4ff3_type_human ?c)
          (human_281c51d26d5d4ff3_type_wolf ?m)
          (human_281c51d26d5d4ff3_type_house ?h)
        )
        (and
          (eaten ?c)
          (not (alive ?m))
          (at ?m ?h)
        )
      )
    :effect
      (and
        (not (eaten ?c))
        (rescued ?c)
        (at ?c ?h)
      )
  )

  (:action give
    :parameters (?c1 ?c2 ?t ?h)
    :precondition
      (and
        (and
          (human_281c51d26d5d4ff3_active)
          (human_281c51d26d5d4ff3_type_human ?c1)
          (human_281c51d26d5d4ff3_type_human ?c2)
          (human_281c51d26d5d4ff3_type_thing ?t)
          (human_281c51d26d5d4ff3_type_house ?h)
          (human_281c51d26d5d4ff3_type_human ?c1)
          (human_281c51d26d5d4ff3_type_human ?c2)
          (human_281c51d26d5d4ff3_type_thing ?t)
          (human_281c51d26d5d4ff3_type_house ?h)
        )
        (and
          (not (eaten ?c2))
          (alive ?c1)
          (alive ?c2)
          (has ?c1 ?t)
          (at ?c1 ?h)
          (at ?c2 ?h)
        )
      )
    :effect
      (and
        (has ?c2 ?t)
        (not (has ?c1 ?t))
      )
  )

  (:action find-toy
    :parameters (?character ?toy)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?character)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?character)
          (tiny_stories__story_090_type_toy ?toy)
        )
        (in-drawer ?toy)
      )
    :effect
      (and
        (not (in-drawer ?toy))
        (friends ?character ?toy)
      )
  )

  (:action want-to-take
    :parameters (?taker ?toy ?owner)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?owner)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?owner)
        )
        (and
          (not (= ?taker ?owner))
          (friends ?owner ?toy)
        )
      )
    :effect
      (wants-to-take ?taker ?toy)
  )

  (:action stand-up
    :parameters (?defender ?taker ?toy)
    :precondition
      (and
        (and
          (tiny_stories__story_090_active)
          (tiny_stories__story_090_type_character ?defender)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
          (tiny_stories__story_090_type_character ?defender)
          (tiny_stories__story_090_type_character ?taker)
          (tiny_stories__story_090_type_toy ?toy)
        )
        (and
          (not (= ?defender ?taker))
          (wants-to-take ?taker ?toy)
          (friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (wants-to-take ?taker ?toy))
        (brave ?defender)
      )
  )
)
