(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_067_o_factory - object)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (shared_p_consensus_0d4e1847137e47fb ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_a9b1306c6a0c5a9e ?v0 - object ?v1 - object)
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_040_p_on-top ?v0 - object ?v1 - object)
    (shared_p_consensus_7b94a6fd58bc8083 ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_scared ?v0 - object)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (tiny_stories__story_067_p_worker ?v0 - object)
    (tiny_stories__story_067_p_clean ?v0 - object)
    (tiny_stories__story_067_p_makes-toys ?v0 - object)
    (tiny_stories__story_067_p_nervous ?v0 - object)
    (shared_p_consensus_c1d2817ac124a1c5 ?v0 - object)
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
  )
  (:axiom :vars (?sun - object) :context (and (tiny_stories__story_091_active) (tiny_stories__story_091_type_sun ?sun) (and (not (tiny_stories__story_091_p_generous ?sun)) (tiny_stories__story_091_p_gives-heat ?sun))) :implies (tiny_stories__story_091_p_generous ?sun))

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_0d4e1847137e47fb ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0d4e1847137e47fb ?character ?roomfrom))
        (shared_p_consensus_0d4e1847137e47fb ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_0d4e1847137e47fb ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_a9b1306c6a0c5a9e ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (shared_p_consensus_a9b1306c6a0c5a9e ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
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
          (shared_p_consensus_0d4e1847137e47fb ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0d4e1847137e47fb ?character ?from))
        (shared_p_consensus_0d4e1847137e47fb ?character ?to)
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
          (shared_p_consensus_0d4e1847137e47fb ?character ?place)
          (tiny_stories__story_040_p_on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_on-top ?toy ?place))
        (shared_p_consensus_a9b1306c6a0c5a9e ?character ?toy)
      )
    :agents (?character)
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

  (:action tiny_stories__story_067_a_start-working
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
      )
    :effect
      (tiny_stories__story_067_p_worker ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_clean-factory
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_clean tiny_stories__story_067_o_factory)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_make-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_makes-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (shared_p_consensus_c1d2817ac124a1c5 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-less-nervous
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (and
          (tiny_stories__story_067_p_worker ?character)
          (tiny_stories__story_067_p_nervous ?character)
        )
      )
    :effect
      (not (tiny_stories__story_067_p_nervous ?character))
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
          (not (shared_p_consensus_c1d2817ac124a1c5 ?animal))
        )
      )
    :effect
      (shared_p_consensus_c1d2817ac124a1c5 ?animal)
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

  (:action fused_a_consensus_a3a6d2c223247a3b
    :parameters (?m0 - object ?m1 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_040_active)
          (tiny_stories__story_040_type_character ?m0)
          (tiny_stories__story_040_type_character ?m1)
          (not (= ?m0 ?m1))
        )
        (and
          (tiny_stories__story_067_active)
          (tiny_stories__story_067_type_character ?m0)
          (tiny_stories__story_067_type_character ?m1)
          (and
            (tiny_stories__story_067_p_worker ?m0)
            (tiny_stories__story_067_p_worker ?m1)
            (not (= ?m0 ?m1))
          )
        )
      )
    :effect
      (shared_p_consensus_7b94a6fd58bc8083 ?m0 ?m1)
    :agents (?m0 ?m1)
  )
)
