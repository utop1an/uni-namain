(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_005_o_tim - object writing_prompts__wp_054_o_crucifix - object writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_005_active)
    (tiny_stories__story_005_type_character ?x - object)
    (tiny_stories__story_005_type_object ?x - object)
    (tiny_stories__story_005_p_alive ?v0 - object)
    (tiny_stories__story_005_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_shaking-tree ?v0 - object)
    (tiny_stories__story_005_p_wind-blows)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_033_type_item ?x - object)
    (writing_prompts__wp_033_type_object ?x - object)
    (writing_prompts__wp_033_type_place ?x - object)
    (writing_prompts__wp_033_type_robot ?x - object)
    (writing_prompts__wp_033_type_weapon ?x - object)
    (writing_prompts__wp_033_p_alive ?v0 - object)
    (writing_prompts__wp_033_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_has-weapon ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_thrown ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_damaged ?v0 - object)
    (writing_prompts__wp_033_p_destroyed ?v0 - object)
    (writing_prompts__wp_033_p_revolution-started)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_alive ?v0 - object)
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_alive ?v0 - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
    (writing_prompts__wp_069_active)
    (writing_prompts__wp_069_type_object ?x - object)
    (writing_prompts__wp_069_type_zone ?x - object)
    (writing_prompts__wp_069_p_habitable ?v0 - object)
    (writing_prompts__wp_069_p_supports-life ?v0 - object)
    (writing_prompts__wp_069_p_hot ?v0 - object)
    (writing_prompts__wp_069_p_cold ?v0 - object)
    (writing_prompts__wp_069_p_gaseous-state ?v0 - object)
    (writing_prompts__wp_069_p_liquid-state ?v0 - object)
    (writing_prompts__wp_069_p_solar-wind ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (writing_prompts__wp_054_p_has ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (writing_prompts__wp_054_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (not (writing_prompts__wp_069_p_supports-life ?zone)) (writing_prompts__wp_069_p_hot ?zone))) :implies (writing_prompts__wp_069_p_supports-life ?zone))
  (:axiom :vars (?zone - object) :context (and (writing_prompts__wp_069_active) (writing_prompts__wp_069_type_zone ?zone) (and (writing_prompts__wp_069_p_supports-life ?zone) (writing_prompts__wp_069_p_cold ?zone))) :implies (not (writing_prompts__wp_069_p_supports-life ?zone)))

  (:action tiny_stories__story_005_a_play
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?object)
        (and
          (tiny_stories__story_005_p_alive ?character)
          (tiny_stories__story_005_p_has ?character ?object)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_shake-tree
    :parameters (?character - object ?tree - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?tree)
        (and
          (tiny_stories__story_005_p_alive ?character)
          (tiny_stories__story_005_p_at ?character ?tree)
        )
      )
    :effect
      (tiny_stories__story_005_p_shaking-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_stop-shaking-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_p_shaking-tree ?character)
      )
    :effect
      (not (tiny_stories__story_005_p_shaking-tree ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_wind-blows-object
    :parameters (?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_object ?object)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_has tiny_stories__story_005_o_tim ?object))
  )

  (:action tiny_stories__story_005_a_start-wind
    :parameters ()
    :precondition
      (tiny_stories__story_005_active)
    :effect
      (tiny_stories__story_005_p_wind-blows)
  )

  (:action tiny_stories__story_005_a_stop-wind
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_wind-blows))
  )

  (:action writing_prompts__wp_033_a_move
    :parameters (?robot - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_type_place ?from)
        (writing_prompts__wp_033_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_033_p_alive ?robot)
          (writing_prompts__wp_033_p_at ?robot ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_at ?robot ?from))
        (writing_prompts__wp_033_p_at ?robot ?to)
      )
    :agents (?robot)
  )

  (:action writing_prompts__wp_033_a_throw-weapon
    :parameters (?thrower - object ?weapon - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?thrower)
        (writing_prompts__wp_033_type_weapon ?weapon)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?thrower)
          (writing_prompts__wp_033_p_has-weapon ?thrower ?weapon)
          (writing_prompts__wp_033_p_alive ?target)
        )
      )
    :effect
      (writing_prompts__wp_033_p_thrown ?weapon ?target)
    :agents (?thrower)
  )

  (:action writing_prompts__wp_033_a_damage
    :parameters (?damager - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?damager)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?damager)
          (writing_prompts__wp_033_p_alive ?target)
          (exists
            (?weapon - object)
            (and
              (writing_prompts__wp_033_type_weapon ?weapon)
              (writing_prompts__wp_033_p_thrown ?weapon ?target)
            )
          )
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_alive ?target))
        (writing_prompts__wp_033_p_damaged ?target)
      )
    :agents (?damager)
  )

  (:action writing_prompts__wp_033_a_destroy
    :parameters (?destroyer - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?destroyer)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?destroyer)
          (writing_prompts__wp_033_p_damaged ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_damaged ?target))
        (writing_prompts__wp_033_p_destroyed ?target)
      )
    :agents (?destroyer)
  )

  (:action writing_prompts__wp_033_a_start-revolution
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_p_alive ?robot)
      )
    :effect
      (writing_prompts__wp_033_p_revolution-started)
    :agents (?robot)
  )

  (:action writing_prompts__wp_040_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?character)
        (writing_prompts__wp_040_type_place ?from)
        (writing_prompts__wp_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_040_p_alive ?character)
          (writing_prompts__wp_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_040_p_at ?character ?from))
        (writing_prompts__wp_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_confront
    :parameters (?confronter - object ?confronted - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?confronter)
        (writing_prompts__wp_040_type_character ?confronted)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?confronter ?confronted))
          (writing_prompts__wp_040_p_alive ?confronter)
          (writing_prompts__wp_040_p_at ?confronter ?place)
          (writing_prompts__wp_040_p_alive ?confronted)
          (writing_prompts__wp_040_p_at ?confronted ?place)
        )
      )
    :agents (?confronter)
  )

  (:action writing_prompts__wp_040_a_defeat
    :parameters (?defeater - object ?defeated - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?defeater)
        (writing_prompts__wp_040_type_character ?defeated)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?defeater ?defeated))
          (writing_prompts__wp_040_p_alive ?defeater)
          (writing_prompts__wp_040_p_at ?defeater ?place)
          (writing_prompts__wp_040_p_alive ?defeated)
          (writing_prompts__wp_040_p_at ?defeated ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_040_p_alive ?defeated))
    :agents (?defeater)
  )

  (:action writing_prompts__wp_040_a_show-mercy
    :parameters (?merciful - object ?recipient - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?merciful)
        (writing_prompts__wp_040_type_character ?recipient)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?merciful ?recipient))
          (writing_prompts__wp_040_p_alive ?merciful)
          (writing_prompts__wp_040_p_at ?merciful ?place)
          (not (writing_prompts__wp_040_p_alive ?recipient))
          (writing_prompts__wp_040_p_at ?recipient ?place)
        )
      )
    :effect
      (writing_prompts__wp_040_p_alive ?recipient)
    :agents (?merciful)
  )

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (writing_prompts__wp_054_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_has ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (writing_prompts__wp_054_p_has ?killer ?weapon)
          (writing_prompts__wp_054_p_alive ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_054_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_at ?character ?from))
        (writing_prompts__wp_054_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_069_a_heat-zone
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_hot ?zone))
          (writing_prompts__wp_069_p_habitable ?zone)
        )
      )
    :effect
      (writing_prompts__wp_069_p_hot ?zone)
  )

  (:action writing_prompts__wp_069_a_cool-zone
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_cold ?zone))
          (not (writing_prompts__wp_069_p_habitable ?zone))
        )
      )
    :effect
      (writing_prompts__wp_069_p_cold ?zone)
  )

  (:action writing_prompts__wp_069_a_gaseous-transition
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_gaseous-state ?zone))
          (writing_prompts__wp_069_p_liquid-state ?zone)
        )
      )
    :effect
      (and
        (writing_prompts__wp_069_p_gaseous-state ?zone)
        (not (writing_prompts__wp_069_p_liquid-state ?zone))
      )
  )

  (:action writing_prompts__wp_069_a_liquid-transition
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_liquid-state ?zone))
          (writing_prompts__wp_069_p_gaseous-state ?zone)
        )
      )
    :effect
      (and
        (writing_prompts__wp_069_p_liquid-state ?zone)
        (not (writing_prompts__wp_069_p_gaseous-state ?zone))
      )
  )

  (:action writing_prompts__wp_069_a_solar-wind-effect
    :parameters (?zone - object)
    :precondition
      (and
        (writing_prompts__wp_069_active)
        (writing_prompts__wp_069_type_zone ?zone)
        (and
          (not (writing_prompts__wp_069_p_solar-wind ?zone))
          (writing_prompts__wp_069_p_gaseous-state ?zone)
        )
      )
    :effect
      (writing_prompts__wp_069_p_solar-wind ?zone)
  )
)
