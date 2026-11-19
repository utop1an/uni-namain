(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:constants tiny_stories__story_084_o_rocket - object)
  (:predicates
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (shared_p_consensus_35c1093897693616 ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (shared_p_consensus_d34aa1043f65bf30 ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (shared_p_consensus_8508b0234fe71287 ?v0 - object ?v1 - object)
    (shared_p_consensus_1f68415a91c8269a ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (shared_p_consensus_58f47a7c156eb357 ?v0 - object ?v1 - object)
    (tiny_stories__story_084_active)
    (tiny_stories__story_084_type_character ?x - object)
    (tiny_stories__story_084_type_item ?x - object)
    (tiny_stories__story_084_type_object ?x - object)
    (tiny_stories__story_084_type_place ?x - object)
    (tiny_stories__story_084_type_toy ?x - object)
    (tiny_stories__story_084_p_played-with ?v0 - object ?v1 - object)
    (tiny_stories__story_084_p_happy ?v0 - object)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_alive ?v0 - object)
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (shared_p_consensus_35c1093897693616 ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_35c1093897693616 ?character ?from))
        (shared_p_consensus_35c1093897693616 ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (shared_p_consensus_35c1093897693616 ?interrogator ?location)
          (shared_p_consensus_35c1093897693616 ?interrogated ?location)
          (human_87bbd0acdf4611c5_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_87bbd0acdf4611c5_p_knows ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (human_87bbd0acdf4611c5_p_henchman ?placer)
          (human_87bbd0acdf4611c5_p_has ?placer ?victim)
          (shared_p_consensus_35c1093897693616 ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (shared_p_consensus_35c1093897693616 ?victim ?placed)
        (human_87bbd0acdf4611c5_p_captured ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (shared_p_consensus_35c1093897693616 ?saver ?location)
          (shared_p_consensus_35c1093897693616 ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (shared_p_consensus_35c1093897693616 ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (shared_p_consensus_d34aa1043f65bf30 ?notsaved))
      )
  )

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (shared_p_consensus_8508b0234fe71287 ?character ?place)
          (tiny_stories__story_039_p_lost ?character ?cap)
        )
      )
    :effect
      (tiny_stories__story_039_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_find
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (and
          (tiny_stories__story_039_p_lost ?character ?cap)
          (forall
            (?place - object)
            (or
              (not (tiny_stories__story_039_type_place ?place))
              (tiny_stories__story_039_p_searched ?character ?place)
            )
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_58f47a7c156eb357 ?character ?cap)
        (not (tiny_stories__story_039_p_lost ?character ?cap))
        (shared_p_consensus_1f68415a91c8269a ?character ?cap)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_lose
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (shared_p_consensus_1f68415a91c8269a ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (shared_p_consensus_1f68415a91c8269a ?character ?cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_replace
    :parameters (?character - object ?old-cap - object ?new-cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?old-cap)
        (tiny_stories__story_039_type_cap ?new-cap)
        (and
          (shared_p_consensus_58f47a7c156eb357 ?character ?old-cap)
          (not (shared_p_consensus_1f68415a91c8269a ?character ?old-cap))
          (shared_p_consensus_1f68415a91c8269a ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_58f47a7c156eb357 ?character ?old-cap))
        (shared_p_consensus_1f68415a91c8269a ?character ?old-cap)
        (not (shared_p_consensus_1f68415a91c8269a ?character ?new-cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (shared_p_consensus_35c1093897693616 ?character ?place)
          (not (shared_p_consensus_58f47a7c156eb357 ?character ?item))
        )
      )
    :effect
      (and
        (shared_p_consensus_58f47a7c156eb357 ?character ?item)
        (shared_p_consensus_1f68415a91c8269a ?character ?item)
        (tiny_stories__story_084_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_084_a_show
    :parameters (?shower - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?shower)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_character ?receiver)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?shower ?receiver))
          (shared_p_consensus_35c1093897693616 ?shower ?place)
          (shared_p_consensus_1f68415a91c8269a ?shower ?item)
          (shared_p_consensus_35c1093897693616 ?receiver ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_happy ?receiver)
    :agents (?shower ?receiver)
  )

  (:action tiny_stories__story_084_a_play
    :parameters (?character1 - object ?character2 - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character1)
        (tiny_stories__story_084_type_character ?character2)
        (tiny_stories__story_084_type_item ?item)
        (tiny_stories__story_084_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_35c1093897693616 ?character1 ?place)
          (shared_p_consensus_1f68415a91c8269a ?character1 ?item)
          (shared_p_consensus_35c1093897693616 ?character2 ?place)
        )
      )
    :effect
      (tiny_stories__story_084_p_played-with ?character1 ?item)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_084_a_fly-high
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_084_active)
        (tiny_stories__story_084_type_character ?character)
        (tiny_stories__story_084_p_played-with ?character tiny_stories__story_084_o_rocket)
      )
    :effect
      (tiny_stories__story_084_p_happy ?character)
    :agents (?character)
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
          (shared_p_consensus_8508b0234fe71287 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8508b0234fe71287 ?character ?from))
        (shared_p_consensus_8508b0234fe71287 ?character ?to)
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
          (shared_p_consensus_8508b0234fe71287 ?confronter ?place)
          (writing_prompts__wp_040_p_alive ?confronted)
          (shared_p_consensus_8508b0234fe71287 ?confronted ?place)
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
          (shared_p_consensus_8508b0234fe71287 ?defeater ?place)
          (writing_prompts__wp_040_p_alive ?defeated)
          (shared_p_consensus_8508b0234fe71287 ?defeated ?place)
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
          (shared_p_consensus_8508b0234fe71287 ?merciful ?place)
          (not (writing_prompts__wp_040_p_alive ?recipient))
          (shared_p_consensus_8508b0234fe71287 ?recipient ?place)
        )
      )
    :effect
      (writing_prompts__wp_040_p_alive ?recipient)
    :agents (?merciful)
  )

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (shared_p_consensus_d34aa1043f65bf30 ?character)
          (not (writing_prompts__wp_063_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_063_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_call-police
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (shared_p_consensus_d34aa1043f65bf30 ?character)
      )
    :effect
      (writing_prompts__wp_063_p_called-police ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_follow-officer
    :parameters (?character - object ?officer - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_character ?officer)
        (and
          (shared_p_consensus_d34aa1043f65bf30 ?character)
          (shared_p_consensus_d34aa1043f65bf30 ?officer)
        )
      )
    :effect
      (writing_prompts__wp_063_p_follows ?character ?officer)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_avert-death
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (and
          (shared_p_consensus_d34aa1043f65bf30 ?character)
          (writing_prompts__wp_063_p_called-police ?character)
          (exists
            (?officer - object)
            (and
              (writing_prompts__wp_063_type_character ?officer)
              (writing_prompts__wp_063_p_follows ?character ?officer)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_063_p_death-averted ?character)
    :agents (?character)
  )
)
