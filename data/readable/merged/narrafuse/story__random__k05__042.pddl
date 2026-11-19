(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object)
  (:predicates
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (tiny_stories__story_063_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (tiny_stories__story_066_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_has ?v0 - object ?v1 - object)
    (shared_p_consensus_197ee13883520b85 ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_091_active)
    (tiny_stories__story_091_type_animal ?x - object)
    (tiny_stories__story_091_type_object ?x - object)
    (tiny_stories__story_091_type_plant ?x - object)
    (tiny_stories__story_091_type_sun ?x - object)
    (tiny_stories__story_091_p_awake ?v0 - object)
    (tiny_stories__story_091_p_growing ?v0 - object)
    (tiny_stories__story_091_p_strong ?v0 - object)
    (tiny_stories__story_091_p_provides-shade ?v0 - object)
    (tiny_stories__story_091_p_provides-home ?v0 - object)
    (tiny_stories__story_091_p_generous ?v0 - object)
    (tiny_stories__story_091_p_gives-heat ?v0 - object)
    (writing_prompts__wp_023_active)
    (writing_prompts__wp_023_type_character ?x - object)
    (writing_prompts__wp_023_type_object ?x - object)
    (writing_prompts__wp_023_p_alive ?v0 - object)
    (writing_prompts__wp_023_p_dead ?v0 - object)
    (writing_prompts__wp_023_p_has-plan ?v0 - object)
    (writing_prompts__wp_023_p_has-time ?v0 - object)
    (writing_prompts__wp_023_p_has-idea ?v0 - object)
    (writing_prompts__wp_023_p_has-tv-show-reference ?v0 - object)
    (writing_prompts__wp_023_p_has-creative-plan ?v0 - object)
    (writing_prompts__wp_023_p_has-better-plan ?v0 - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
    (writing_prompts__wp_047_p_at-peace ?v0 - object)
    (writing_prompts__wp_047_p_sharing-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_047_p_advanced-technology ?v0 - object)
    (writing_prompts__wp_047_p_facing-destruction)
  )
  (:axiom :vars (?sun - object) :context (and (tiny_stories__story_091_active) (tiny_stories__story_091_type_sun ?sun) (and (not (tiny_stories__story_091_p_generous ?sun)) (tiny_stories__story_091_p_gives-heat ?sun))) :implies (tiny_stories__story_091_p_generous ?sun))

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (tiny_stories__story_063_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (tiny_stories__story_063_p_helping ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (tiny_stories__story_063_p_helping ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (tiny_stories__story_066_p_at ?character ?place)
          (not (tiny_stories__story_066_p_has ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_066_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (tiny_stories__story_066_p_at ?giver ?place)
          (tiny_stories__story_066_p_has ?giver ?item)
          (tiny_stories__story_066_p_at ?receiver ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_066_p_has ?giver ?item))
        (tiny_stories__story_066_p_has ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (tiny_stories__story_066_p_at ?character ?place)
          (tiny_stories__story_066_p_has ?character ?item)
        )
      )
    :effect
      (shared_p_consensus_197ee13883520b85 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (shared_p_consensus_197ee13883520b85 ?target))
        )
      )
    :effect
      (shared_p_consensus_197ee13883520b85 ?target)
    :agents (?character)
  )

  (:action tiny_stories__story_091_a_wake-up
    :parameters (?sun - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_animal ?animal)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (not (tiny_stories__story_091_p_awake ?animal))
        )
      )
    :effect
      (tiny_stories__story_091_p_awake ?animal)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_make-happy
    :parameters (?sun - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_animal ?animal)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (tiny_stories__story_091_p_awake ?animal)
          (not (shared_p_consensus_197ee13883520b85 ?animal))
        )
      )
    :effect
      (shared_p_consensus_197ee13883520b85 ?animal)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_help-grow
    :parameters (?sun - object ?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_plant ?plant)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (not (tiny_stories__story_091_p_growing ?plant))
        )
      )
    :effect
      (tiny_stories__story_091_p_growing ?plant)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_become-strong
    :parameters (?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_plant ?plant)
        (tiny_stories__story_091_p_growing ?plant)
      )
    :effect
      (tiny_stories__story_091_p_strong ?plant)
  )

  (:action tiny_stories__story_091_a_provide-shade-and-home
    :parameters (?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_plant ?plant)
        (tiny_stories__story_091_p_strong ?plant)
      )
    :effect
      (and
        (tiny_stories__story_091_p_provides-shade ?plant)
        (tiny_stories__story_091_p_provides-home ?plant)
      )
  )

  (:action writing_prompts__wp_023_a_present-plan
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (writing_prompts__wp_023_p_alive ?character)
          (writing_prompts__wp_023_p_has-plan ?character)
        )
      )
    :effect
      (and
        (writing_prompts__wp_023_p_has-idea ?character)
        (when
          (writing_prompts__wp_023_p_has-tv-show-reference ?character)
          (not (writing_prompts__wp_023_p_has-creative-plan ?character))
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_023_a_decide-fate
    :parameters (?council - object ?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?council)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (writing_prompts__wp_023_p_alive ?council)
          (writing_prompts__wp_023_p_alive ?character)
          (writing_prompts__wp_023_p_has-idea ?character)
        )
      )
    :effect
      (when
        (writing_prompts__wp_023_p_has-creative-plan ?character)
        (and
          (writing_prompts__wp_023_p_has-better-plan ?character)
          (writing_prompts__wp_023_p_has-time ?character)
        )
      )
    :agents (?council)
  )

  (:action writing_prompts__wp_023_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_023_active)
        (writing_prompts__wp_023_type_character ?character)
        (and
          (writing_prompts__wp_023_p_alive ?character)
          (not (writing_prompts__wp_023_p_has-time ?character))
        )
      )
    :effect
      (writing_prompts__wp_023_p_dead ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_047_a_unite
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_facing-destruction)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_develop-technology
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_advanced-technology ?nation1)
        (writing_prompts__wp_047_p_advanced-technology ?nation2)
      )
    :agents (?nation1 ?nation2)
  )

  (:action writing_prompts__wp_047_a_avoid-destruction
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (and
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation1)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation2)
          (writing_prompts__wp_047_p_advanced-technology writing_prompts__wp_047_o_nation3)
        )
      )
    :effect
      (not (writing_prompts__wp_047_p_facing-destruction))
  )

  (:action writing_prompts__wp_047_a_maintain-peace
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (writing_prompts__wp_047_type_nation ?nation1)
        (writing_prompts__wp_047_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_047_p_at-peace ?nation1)
          (writing_prompts__wp_047_p_at-peace ?nation2)
          (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (writing_prompts__wp_047_p_at-peace ?nation1)
        (writing_prompts__wp_047_p_at-peace ?nation2)
        (writing_prompts__wp_047_p_sharing-technology ?nation1 ?nation2)
      )
    :agents (?nation1 ?nation2)
  )
)
