(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_014_p_at-park ?v0 - object)
    (tiny_stories__story_014_p_on-swing ?v0 - object)
    (tiny_stories__story_014_p_swinging ?v0 - object)
    (tiny_stories__story_014_p_sharing ?v0 - object ?v1 - object)
    (tiny_stories__story_014_p_happy ?v0 - object)
    (tiny_stories__story_025_active)
    (tiny_stories__story_025_type_character ?x - object)
    (tiny_stories__story_025_type_object ?x - object)
    (tiny_stories__story_025_type_place ?x - object)
    (shared_p_consensus_1d9bb33a44568263 ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_stuck ?v0 - object ?v1 - object)
    (tiny_stories__story_025_p_helped ?v0 - object ?v1 - object)
    (shared_p_consensus_4851cbc501810b5e ?v0 - object ?v1 - object)
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_030_p_hungry ?v0 - object)
    (shared_p_consensus_d0a073c87f5d361c ?v0 - object)
    (tiny_stories__story_030_p_food-available)
    (writing_prompts__wp_065_active)
    (writing_prompts__wp_065_type_bunker ?x - object)
    (writing_prompts__wp_065_type_character ?x - object)
    (writing_prompts__wp_065_type_god ?x - object)
    (writing_prompts__wp_065_type_object ?x - object)
    (writing_prompts__wp_065_type_place ?x - object)
    (writing_prompts__wp_065_p_in-bunker ?v0 - object ?v1 - object)
    (writing_prompts__wp_065_p_has-followers ?v0 - object)
    (writing_prompts__wp_065_p_launching-bombs ?v0 - object)
    (writing_prompts__wp_065_p_disease-spreading)
    (writing_prompts__wp_065_p_bombs-launched)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_has-device ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
  )
  (:axiom :vars (?character - object ?bunker - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (writing_prompts__wp_065_type_bunker ?bunker) (and (writing_prompts__wp_065_p_in-bunker ?character ?bunker) (writing_prompts__wp_065_p_disease-spreading))) :implies (not (shared_p_consensus_d0a073c87f5d361c ?character)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (and (writing_prompts__wp_065_p_bombs-launched) (forall (?bunker - object) (or (not (writing_prompts__wp_065_type_bunker ?bunker)) (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker)))))) :implies (not (shared_p_consensus_d0a073c87f5d361c ?character)))

  (:action tiny_stories__story_014_a_go-to-park
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (not (tiny_stories__story_014_p_at-park ?character))
      )
    :effect
      (tiny_stories__story_014_p_at-park ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_get-on-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_at-park ?character)
          (not (tiny_stories__story_014_p_on-swing ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_on-swing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_start-swinging
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (not (tiny_stories__story_014_p_swinging ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_swinging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_share-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_swinging ?character1)
          (tiny_stories__story_014_p_swinging ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_sharing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_014_a_get-off-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (tiny_stories__story_014_p_swinging ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_014_p_on-swing ?character))
        (not (tiny_stories__story_014_p_swinging ?character))
        (tiny_stories__story_014_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_thank
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_sharing ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_happy ?character1)
    :agents (?character1 ?character2)
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
          (shared_p_consensus_1d9bb33a44568263 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1d9bb33a44568263 ?character ?from))
        (shared_p_consensus_1d9bb33a44568263 ?character ?to)
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
          (shared_p_consensus_1d9bb33a44568263 ?character ?place)
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
          (shared_p_consensus_1d9bb33a44568263 ?helper ?place)
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
          (not (shared_p_consensus_4851cbc501810b5e ?character1 ?character2))
          (tiny_stories__story_025_p_helped ?character1 ?character2)
        )
      )
    :effect
      (shared_p_consensus_4851cbc501810b5e ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_030_a_ask-to-be-friends
    :parameters (?asker - object ?askee - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?asker)
        (tiny_stories__story_030_type_character ?askee)
        (and
          (shared_p_consensus_d0a073c87f5d361c ?asker)
          (shared_p_consensus_d0a073c87f5d361c ?askee)
          (not (shared_p_consensus_4851cbc501810b5e ?asker ?askee))
        )
      )
    :effect
      (shared_p_consensus_4851cbc501810b5e ?asker ?askee)
    :agents (?asker)
  )

  (:action tiny_stories__story_030_a_search-for-food
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?character)
        (shared_p_consensus_d0a073c87f5d361c ?character)
      )
    :effect
      (tiny_stories__story_030_p_food-available)
    :agents (?character)
  )

  (:action tiny_stories__story_030_a_feed
    :parameters (?feeder - object ?eater - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?feeder)
        (tiny_stories__story_030_type_character ?eater)
        (and
          (shared_p_consensus_d0a073c87f5d361c ?feeder)
          (shared_p_consensus_d0a073c87f5d361c ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (tiny_stories__story_030_p_food-available)
        )
      )
    :effect
      (not (tiny_stories__story_030_p_hungry ?eater))
    :agents (?feeder)
  )

  (:action tiny_stories__story_030_a_eat
    :parameters (?eater - object ?eaten - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?eater)
        (tiny_stories__story_030_type_character ?eaten)
        (and
          (shared_p_consensus_d0a073c87f5d361c ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (shared_p_consensus_d0a073c87f5d361c ?eaten)
        )
      )
    :effect
      (not (shared_p_consensus_d0a073c87f5d361c ?eaten))
    :agents (?eater)
  )

  (:action writing_prompts__wp_065_a_enter-bunker
    :parameters (?character - object ?bunker - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (writing_prompts__wp_065_type_bunker ?bunker)
        (and
          (shared_p_consensus_d0a073c87f5d361c ?character)
          (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker))
        )
      )
    :effect
      (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_launch-bombs
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (and
          (shared_p_consensus_d0a073c87f5d361c ?character)
          (exists
            (?bunker - object)
            (and
              (writing_prompts__wp_065_type_bunker ?bunker)
              (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_launching-bombs ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_spread-disease
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (not (writing_prompts__wp_065_p_disease-spreading))
      )
    :effect
      (writing_prompts__wp_065_p_disease-spreading)
  )

  (:action writing_prompts__wp_065_a_bombs-launched
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (exists
          (?character - object)
          (and
            (writing_prompts__wp_065_type_character ?character)
            (writing_prompts__wp_065_p_launching-bombs ?character)
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_bombs-launched)
  )

  (:action writing_prompts__wp_085_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (not (writing_prompts__wp_085_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_085_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_put-on-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (not (writing_prompts__wp_085_p_wearing-clothes ?character))
        )
      )
    :effect
      (writing_prompts__wp_085_p_wearing-clothes ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_turn-on-device
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_has-device ?character ?device)
          (not (writing_prompts__wp_085_p_device-on ?device))
        )
      )
    :effect
      (writing_prompts__wp_085_p_device-on ?device)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_check-connectivity
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_device-on ?device)
          (writing_prompts__wp_085_p_has-device ?character ?device)
        )
      )
    :effect
      (when
        (writing_prompts__wp_085_p_device-connected ?device)
        (writing_prompts__wp_085_p_working ?device)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_go-outside
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_place ?place)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_wearing-clothes ?character)
          (shared_p_consensus_1d9bb33a44568263 ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_1d9bb33a44568263 ?character ?place))
        (shared_p_consensus_1d9bb33a44568263 ?character writing_prompts__wp_085_o_outside)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_talk
    :parameters (?speaker - object ?listener - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?speaker)
        (writing_prompts__wp_085_type_character ?listener)
        (and
          (writing_prompts__wp_085_p_awake ?speaker)
          (writing_prompts__wp_085_p_awake ?listener)
          (shared_p_consensus_1d9bb33a44568263 ?speaker writing_prompts__wp_085_o_outside)
          (shared_p_consensus_1d9bb33a44568263 ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :agents (?speaker ?listener)
  )

  (:action writing_prompts__wp_085_a_cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (writing_prompts__wp_085_p_school-canceled))
      )
    :effect
      (writing_prompts__wp_085_p_school-canceled)
  )
)
