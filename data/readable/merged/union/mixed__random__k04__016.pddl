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
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_003_p_broken-pedal ?v0 - object)
    (tiny_stories__story_003_p_fixed-pedal ?v0 - object)
    (tiny_stories__story_003_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_003_p_at-shop ?v0 - object)
    (tiny_stories__story_003_p_happy ?v0 - object)
    (tiny_stories__story_003_p_flying ?v0 - object)
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_028_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (tiny_stories__story_028_p_happy ?v0 - object)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (writing_prompts__wp_049_p_needs-walk ?v0 - object)
    (writing_prompts__wp_049_p_in-herenow ?v0 - object)
    (writing_prompts__wp_049_p_ancient-oath ?v0 - object)
    (writing_prompts__wp_049_p_guardian ?v0 - object)
    (writing_prompts__wp_049_p_master ?v0 - object)
    (writing_prompts__wp_049_p_time-of-passing)
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

  (:action tiny_stories__story_003_a_go-to-shop
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_at-shop ?character))
      )
    :effect
      (tiny_stories__story_003_p_at-shop ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_fix-pedal
    :parameters (?character - object ?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_at-shop ?character)
          (tiny_stories__story_003_p_has ?character ?bike)
          (tiny_stories__story_003_p_broken-pedal ?bike)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_003_p_broken-pedal ?bike))
        (tiny_stories__story_003_p_fixed-pedal ?bike)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_happy ?character))
      )
    :effect
      (tiny_stories__story_003_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_start-flying
    :parameters (?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_fixed-pedal ?bike)
          (not (tiny_stories__story_003_p_flying ?bike))
        )
      )
    :effect
      (tiny_stories__story_003_p_flying ?bike)
  )

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (tiny_stories__story_028_p_has ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (tiny_stories__story_028_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_put-on-shelf
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (tiny_stories__story_028_type_place ?place)
        (and
          (tiny_stories__story_028_p_has ?character ?item)
          (tiny_stories__story_028_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_028_p_has ?character ?item))
        (tiny_stories__story_028_p_on-shelf ?item)
        (tiny_stories__story_028_p_organized ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_read
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_p_reads ?character)
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_smell-soap
    :parameters (?character - object ?soap - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?soap)
        (and
          (tiny_stories__story_028_p_on-shelf ?soap)
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_049_a_remind-ancient-oath
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_ancient-oath ?dog)
        )
      )
    :effect
      (writing_prompts__wp_049_p_needs-walk ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_bring-to-herenow
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (not (writing_prompts__wp_049_p_in-herenow ?master))
        )
      )
    :effect
      (writing_prompts__wp_049_p_in-herenow ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_walk
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_needs-walk ?master)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_049_p_needs-walk ?master))
        (writing_prompts__wp_049_p_in-herenow ?master)
      )
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_time-of-passing
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (not (writing_prompts__wp_049_p_time-of-passing))
      )
    :effect
      (writing_prompts__wp_049_p_time-of-passing)
  )
)
