(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
  (:predicates
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_046_p_impatient ?v0 - object)
    (tiny_stories__story_046_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_046_p_on-table ?v0 - object)
    (tiny_stories__story_046_p_smells-nice ?v0 - object)
    (tiny_stories__story_046_p_playing-with-ball ?v0 - object)
    (tiny_stories__story_091_active)
    (tiny_stories__story_091_type_animal ?x - object)
    (tiny_stories__story_091_type_object ?x - object)
    (tiny_stories__story_091_type_plant ?x - object)
    (tiny_stories__story_091_type_sun ?x - object)
    (tiny_stories__story_091_p_awake ?v0 - object)
    (tiny_stories__story_091_p_happy ?v0 - object)
    (tiny_stories__story_091_p_growing ?v0 - object)
    (tiny_stories__story_091_p_strong ?v0 - object)
    (tiny_stories__story_091_p_provides-shade ?v0 - object)
    (tiny_stories__story_091_p_provides-home ?v0 - object)
    (tiny_stories__story_091_p_generous ?v0 - object)
    (tiny_stories__story_091_p_gives-heat ?v0 - object)
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_alive ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_057_p_liberated ?v0 - object)
    (writing_prompts__wp_057_p_defeated-illuminati)
    (writing_prompts__wp_057_p_alien-exists ?v0 - object)
    (writing_prompts__wp_057_p_alien-gone ?v0 - object)
    (writing_prompts__wp_092_active)
    (writing_prompts__wp_092_type_character ?x - object)
    (writing_prompts__wp_092_type_object ?x - object)
    (writing_prompts__wp_092_type_place ?x - object)
    (writing_prompts__wp_092_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_ready ?v0 - object)
    (writing_prompts__wp_092_p_has-lover ?v0 - object)
    (writing_prompts__wp_092_p_has-child ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_is-grandmother ?v0 - object)
    (writing_prompts__wp_092_p_is-ill ?v0 - object)
  )
  (:axiom :vars (?sun - object) :context (and (tiny_stories__story_091_active) (tiny_stories__story_091_type_sun ?sun) (and (not (tiny_stories__story_091_p_generous ?sun)) (tiny_stories__story_091_p_gives-heat ?sun))) :implies (tiny_stories__story_091_p_generous ?sun))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_alive ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (writing_prompts__wp_048_p_alive ?character))

  (:action tiny_stories__story_046_a_try-get
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_type_object ?object)
        (and
          (tiny_stories__story_046_p_impatient ?character)
          (tiny_stories__story_046_p_on-table ?object)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_046_p_on-table ?object))
        (tiny_stories__story_046_p_has ?character ?object)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_smell-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (tiny_stories__story_046_p_smells-nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_play-with-ball
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (tiny_stories__story_046_p_playing-with-ball ?character)
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
          (not (tiny_stories__story_091_p_happy ?animal))
        )
      )
    :effect
      (tiny_stories__story_091_p_happy ?animal)
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

  (:action writing_prompts__wp_048_a_offer-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (not (writing_prompts__wp_048_p_offered ?character ?trial))
        )
      )
    :effect
      (writing_prompts__wp_048_p_offered ?character ?trial)
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_048_a_choose-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (writing_prompts__wp_048_p_offered ?character ?trial)
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_completed ?character ?trial)
        (not (writing_prompts__wp_048_p_offered ?character ?trial))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_rebirth
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (or
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears)
          )
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_alive ?character)
        (not (writing_prompts__wp_048_p_dead ?character))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears))
      )
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_057_a_liberate
    :parameters (?alien - object ?human - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_type_character ?human)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_liberated ?human))
        )
      )
    :effect
      (writing_prompts__wp_057_p_liberated ?human)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_defeat-illuminati
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_defeated-illuminati))
        )
      )
    :effect
      (writing_prompts__wp_057_p_defeated-illuminati)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_disappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-exists ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-gone ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_reappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-gone ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-exists ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_092_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_type_place ?from)
        (writing_prompts__wp_092_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_092_p_at ?character ?from)
          (writing_prompts__wp_092_p_ready ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_092_p_at ?character ?from))
        (writing_prompts__wp_092_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_get-ready
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_ready ?character))
      )
    :effect
      (writing_prompts__wp_092_p_ready ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-grandmother
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (and
          (not (writing_prompts__wp_092_p_is-grandmother ?character))
          (exists
            (?child - object)
            (and
              (writing_prompts__wp_092_type_character ?child)
              (writing_prompts__wp_092_p_has-child ?character ?child)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_092_p_is-grandmother ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-ill
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_is-ill ?character))
      )
    :effect
      (writing_prompts__wp_092_p_is-ill ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_recover
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_p_is-ill ?character)
      )
    :effect
      (not (writing_prompts__wp_092_p_is-ill ?character))
    :agents (?character)
  )
)
