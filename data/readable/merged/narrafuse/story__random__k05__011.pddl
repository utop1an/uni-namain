(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_005_o_tim - object writing_prompts__wp_054_o_crucifix - object writing_prompts__wp_069_o_inner-zone - object writing_prompts__wp_069_o_outer-zone - object writing_prompts__wp_069_o_edge-zone - object)
  (:predicates
    (tiny_stories__story_005_active)
    (tiny_stories__story_005_type_character ?x - object)
    (tiny_stories__story_005_type_object ?x - object)
    (shared_p_consensus_e98c544e20b33c2d ?v0 - object)
    (shared_p_consensus_ffe3d9c6abe68bda ?v0 - object ?v1 - object)
    (shared_p_consensus_838f30a577c782d4 ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_shaking-tree ?v0 - object)
    (tiny_stories__story_005_p_wind-blows)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_033_type_item ?x - object)
    (writing_prompts__wp_033_type_object ?x - object)
    (writing_prompts__wp_033_type_place ?x - object)
    (writing_prompts__wp_033_type_robot ?x - object)
    (writing_prompts__wp_033_type_weapon ?x - object)
    (shared_p_consensus_2f904422ecebbae5 ?v0 - object)
    (shared_p_consensus_962e699341b9f4c2 ?v0 - object ?v1 - object)
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
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_ffe3d9c6abe68bda ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_ffe3d9c6abe68bda ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))
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
          (shared_p_consensus_e98c544e20b33c2d ?character)
          (shared_p_consensus_ffe3d9c6abe68bda ?character ?object)
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
          (shared_p_consensus_e98c544e20b33c2d ?character)
          (shared_p_consensus_838f30a577c782d4 ?character ?tree)
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
      (not (shared_p_consensus_ffe3d9c6abe68bda tiny_stories__story_005_o_tim ?object))
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
          (shared_p_consensus_2f904422ecebbae5 ?robot)
          (shared_p_consensus_962e699341b9f4c2 ?robot ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_962e699341b9f4c2 ?robot ?from))
        (shared_p_consensus_962e699341b9f4c2 ?robot ?to)
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
          (shared_p_consensus_2f904422ecebbae5 ?thrower)
          (writing_prompts__wp_033_p_has-weapon ?thrower ?weapon)
          (shared_p_consensus_2f904422ecebbae5 ?target)
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
          (shared_p_consensus_2f904422ecebbae5 ?damager)
          (shared_p_consensus_2f904422ecebbae5 ?target)
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
        (not (shared_p_consensus_2f904422ecebbae5 ?target))
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
          (shared_p_consensus_2f904422ecebbae5 ?destroyer)
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
        (shared_p_consensus_2f904422ecebbae5 ?robot)
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
          (shared_p_consensus_2f904422ecebbae5 ?character)
          (shared_p_consensus_962e699341b9f4c2 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_962e699341b9f4c2 ?character ?from))
        (shared_p_consensus_962e699341b9f4c2 ?character ?to)
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
          (shared_p_consensus_2f904422ecebbae5 ?confronter)
          (shared_p_consensus_962e699341b9f4c2 ?confronter ?place)
          (shared_p_consensus_2f904422ecebbae5 ?confronted)
          (shared_p_consensus_962e699341b9f4c2 ?confronted ?place)
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
          (shared_p_consensus_2f904422ecebbae5 ?defeater)
          (shared_p_consensus_962e699341b9f4c2 ?defeater ?place)
          (shared_p_consensus_2f904422ecebbae5 ?defeated)
          (shared_p_consensus_962e699341b9f4c2 ?defeated ?place)
        )
      )
    :effect
      (not (shared_p_consensus_2f904422ecebbae5 ?defeated))
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
          (shared_p_consensus_2f904422ecebbae5 ?merciful)
          (shared_p_consensus_962e699341b9f4c2 ?merciful ?place)
          (not (shared_p_consensus_2f904422ecebbae5 ?recipient))
          (shared_p_consensus_962e699341b9f4c2 ?recipient ?place)
        )
      )
    :effect
      (shared_p_consensus_2f904422ecebbae5 ?recipient)
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
          (shared_p_consensus_e98c544e20b33c2d ?character)
          (shared_p_consensus_838f30a577c782d4 ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_ffe3d9c6abe68bda ?character ?item)
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
          (shared_p_consensus_e98c544e20b33c2d ?character)
          (shared_p_consensus_838f30a577c782d4 ?character ?place)
          (shared_p_consensus_ffe3d9c6abe68bda ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ffe3d9c6abe68bda ?character ?item))
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
          (shared_p_consensus_e98c544e20b33c2d ?killer)
          (shared_p_consensus_838f30a577c782d4 ?killer ?place)
          (shared_p_consensus_ffe3d9c6abe68bda ?killer ?weapon)
          (shared_p_consensus_e98c544e20b33c2d ?victim)
          (shared_p_consensus_838f30a577c782d4 ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_e98c544e20b33c2d ?victim))
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
          (shared_p_consensus_e98c544e20b33c2d ?character)
          (shared_p_consensus_838f30a577c782d4 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_838f30a577c782d4 ?character ?from))
        (shared_p_consensus_838f30a577c782d4 ?character ?to)
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
