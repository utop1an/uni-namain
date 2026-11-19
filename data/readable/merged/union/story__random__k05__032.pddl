(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_035_o_tim - object writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
  (:predicates
    (tiny_stories__story_035_active)
    (tiny_stories__story_035_type_character ?x - object)
    (tiny_stories__story_035_type_object ?x - object)
    (tiny_stories__story_035_p_birthday ?v0 - object)
    (tiny_stories__story_035_p_box-closed)
    (tiny_stories__story_035_p_box-open)
    (tiny_stories__story_035_p_cake-spoiled)
    (tiny_stories__story_035_p_cake-good)
    (tiny_stories__story_035_p_listened-to-mom ?v0 - object)
    (tiny_stories__story_035_p_waited-for-birthday ?v0 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
    (writing_prompts__wp_043_active)
    (writing_prompts__wp_043_type_character ?x - object)
    (writing_prompts__wp_043_type_object ?x - object)
    (writing_prompts__wp_043_type_place ?x - object)
    (writing_prompts__wp_043_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_043_p_alive ?v0 - object)
    (writing_prompts__wp_043_p_discovered ?v0 - object)
    (writing_prompts__wp_043_p_knows-about ?v0 - object ?v1 - object)
    (writing_prompts__wp_043_p_is-ceo ?v0 - object)
    (writing_prompts__wp_043_p_is-alien ?v0 - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
    (writing_prompts__wp_047_p_at-peace ?v0 - object)
    (writing_prompts__wp_047_p_sharing-technology ?v0 - object ?v1 - object)
    (writing_prompts__wp_047_p_advanced-technology ?v0 - object)
    (writing_prompts__wp_047_p_facing-destruction)
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_alive ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_alive ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (writing_prompts__wp_048_p_alive ?character))

  (:action tiny_stories__story_035_a_wait-for-birthday
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_birthday ?character))
          (not (tiny_stories__story_035_p_waited-for-birthday ?character))
        )
      )
    :effect
      (tiny_stories__story_035_p_waited-for-birthday ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_listen-to-mom
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_listened-to-mom ?character))
          (tiny_stories__story_035_p_waited-for-birthday ?character)
        )
      )
    :effect
      (tiny_stories__story_035_p_listened-to-mom ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_open-box
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (tiny_stories__story_035_p_box-closed)
          (tiny_stories__story_035_p_birthday ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_box-closed))
        (tiny_stories__story_035_p_box-open)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_spoil-cake
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (not (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim))
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_cake-good))
        (tiny_stories__story_035_p_cake-spoiled)
      )
  )

  (:action tiny_stories__story_035_a_keep-cake-good
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim)
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (tiny_stories__story_035_p_cake-good)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )

  (:action writing_prompts__wp_043_a_discover
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?character)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?character)
          (writing_prompts__wp_043_p_at ?character ?place)
          (not (writing_prompts__wp_043_p_discovered ?place))
        )
      )
    :effect
      (writing_prompts__wp_043_p_discovered ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_043_a_learn
    :parameters (?learner - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?learner)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?learner)
          (writing_prompts__wp_043_p_discovered ?place)
        )
      )
    :effect
      (writing_prompts__wp_043_p_knows-about ?learner ?place)
    :agents (?learner)
  )

  (:action writing_prompts__wp_043_a_hold-press-conference
    :parameters (?speaker - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?speaker)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?speaker)
          (writing_prompts__wp_043_p_is-ceo ?speaker)
          (writing_prompts__wp_043_p_knows-about ?speaker ?place)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?place)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_043_a_reveal
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?alien)
        (and
          (writing_prompts__wp_043_p_alive ?alien)
          (writing_prompts__wp_043_p_is-alien ?alien)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?alien)
        )
      )
    :agents (?alien)
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
)
