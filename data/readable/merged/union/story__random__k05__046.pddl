(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (tiny_stories__story_070_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_clean ?v0 - object)
    (tiny_stories__story_070_p_steal-intention ?v0 - object ?v1 - object)
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_009_p_alive ?v0 - object)
    (writing_prompts__wp_009_p_spirits-present ?v0 - object)
    (writing_prompts__wp_009_p_spirits-gone ?v0 - object)
    (writing_prompts__wp_009_p_weak ?v0 - object)
    (writing_prompts__wp_009_p_love-driven-away ?v0 - object)
    (writing_prompts__wp_009_p_in-asylum ?v0 - object)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (writing_prompts__wp_049_p_needs-walk ?v0 - object)
    (writing_prompts__wp_049_p_in-herenow ?v0 - object)
    (writing_prompts__wp_049_p_ancient-oath ?v0 - object)
    (writing_prompts__wp_049_p_guardian ?v0 - object)
    (writing_prompts__wp_049_p_master ?v0 - object)
    (writing_prompts__wp_049_p_time-of-passing)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_alive ?v0 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
    (writing_prompts__wp_098_active)
    (writing_prompts__wp_098_type_character ?x - object)
    (writing_prompts__wp_098_type_object ?x - object)
    (writing_prompts__wp_098_p_alive ?v0 - object)
    (writing_prompts__wp_098_p_feeling ?v0 - object)
    (writing_prompts__wp_098_p_last-soul ?v0 - object)
    (writing_prompts__wp_098_p_understand ?v0 - object)
    (writing_prompts__wp_098_p_witness ?v0 - object)
    (writing_prompts__wp_098_p_end ?v0 - object)
  )

  (:action tiny_stories__story_070_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?apologizer)
        (tiny_stories__story_070_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (tiny_stories__story_070_p_friends ?apologizer ?apologized))
        )
      )
    :effect
      (tiny_stories__story_070_p_friends ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_070_a_try-steal
    :parameters (?stealer - object ?item - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?stealer)
        (tiny_stories__story_070_type_item ?item)
        (tiny_stories__story_070_type_character ?owner)
        (and
          (not (= ?stealer ?owner))
          (tiny_stories__story_070_p_has ?owner ?item)
          (tiny_stories__story_070_p_steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_070_p_steal-intention ?stealer ?item))
        (not (tiny_stories__story_070_p_friends ?stealer ?owner))
        (tiny_stories__story_070_p_has ?stealer ?item)
        (not (tiny_stories__story_070_p_has ?owner ?item))
      )
    :agents (?stealer)
  )

  (:action tiny_stories__story_070_a_clean-item
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?cleaner)
        (tiny_stories__story_070_type_item ?item)
        (and
          (not (tiny_stories__story_070_p_clean ?item))
          (tiny_stories__story_070_p_has ?cleaner ?item)
        )
      )
    :effect
      (tiny_stories__story_070_p_clean ?item)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_070_a_drop-in-puddle
    :parameters (?dropper - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?dropper)
        (tiny_stories__story_070_type_item ?item)
        (and
          (tiny_stories__story_070_p_has ?dropper ?item)
          (tiny_stories__story_070_p_clean ?item)
        )
      )
    :effect
      (not (tiny_stories__story_070_p_clean ?item))
    :agents (?dropper)
  )

  (:action writing_prompts__wp_009_a_become-weak
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_weak ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_drive-away-love
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_love-driven-away ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_end-up-in-asylum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_in-asylum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_ask-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-present ?character)
        )
      )
    :effect
      (and
        (writing_prompts__wp_009_p_spirits-gone ?character)
        (not (writing_prompts__wp_009_p_spirits-present ?character))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_009_a_regret-asking-spirits-to-leave
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_009_active)
        (writing_prompts__wp_009_type_character ?character)
        (and
          (writing_prompts__wp_009_p_alive ?character)
          (writing_prompts__wp_009_p_spirits-gone ?character)
        )
      )
    :effect
      (writing_prompts__wp_009_p_spirits-present ?character)
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

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (writing_prompts__wp_063_p_alive ?character)
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
        (writing_prompts__wp_063_p_alive ?character)
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
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_alive ?officer)
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
          (writing_prompts__wp_063_p_alive ?character)
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

  (:action writing_prompts__wp_098_a_start-feeling
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_098_active)
        (writing_prompts__wp_098_type_character ?character)
        (and
          (writing_prompts__wp_098_p_alive ?character)
          (not (writing_prompts__wp_098_p_feeling ?character))
        )
      )
    :effect
      (writing_prompts__wp_098_p_feeling ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_098_a_witness-end
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_098_active)
        (writing_prompts__wp_098_type_character ?character)
        (and
          (writing_prompts__wp_098_p_alive ?character)
          (not (writing_prompts__wp_098_p_witness ?character))
        )
      )
    :effect
      (writing_prompts__wp_098_p_witness ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_098_a_understand-end
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_098_active)
        (writing_prompts__wp_098_type_character ?character)
        (and
          (writing_prompts__wp_098_p_alive ?character)
          (writing_prompts__wp_098_p_witness ?character)
          (not (writing_prompts__wp_098_p_understand ?character))
        )
      )
    :effect
      (writing_prompts__wp_098_p_understand ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_098_a_last-soul-fades
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_098_active)
        (writing_prompts__wp_098_type_character ?character)
        (and
          (writing_prompts__wp_098_p_alive ?character)
          (writing_prompts__wp_098_p_last-soul ?character)
          (writing_prompts__wp_098_p_understand ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_098_p_alive ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_098_a_humanity-ends
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_098_active)
        (writing_prompts__wp_098_type_character ?character)
        (and
          (writing_prompts__wp_098_p_alive ?character)
          (writing_prompts__wp_098_p_understand ?character)
          (not (writing_prompts__wp_098_p_end ?character))
        )
      )
    :effect
      (writing_prompts__wp_098_p_end ?character)
    :agents (?character)
  )
)
