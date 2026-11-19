(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_cf10335d299ae37f_active)
    (human_cf10335d299ae37f_type_creature ?x - object)
    (human_cf10335d299ae37f_type_landform ?x - object)
    (human_cf10335d299ae37f_type_object ?x - object)
    (human_cf10335d299ae37f_type_place ?x - object)
    (human_cf10335d299ae37f_type_ship ?x - object)
    (shared_p_consensus_20665fb5d4fc017c ?v0 - object)
    (human_cf10335d299ae37f_p_stunned ?v0 - object)
    (human_cf10335d299ae37f_p_habitable ?v0 - object)
    (human_cf10335d299ae37f_p_safe ?v0 - object)
    (human_cf10335d299ae37f_p_erupting ?v0 - object)
    (human_cf10335d299ae37f_p_at ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_fighting ?v0 - object ?v1 - object)
    (shared_p_consensus_be15e3ae7b5e8f5b ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_captain ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_guardian ?v0 - object ?v1 - object)
    (tiny_stories__story_036_active)
    (tiny_stories__story_036_type_box ?x - object)
    (tiny_stories__story_036_type_character ?x - object)
    (tiny_stories__story_036_type_item ?x - object)
    (tiny_stories__story_036_type_object ?x - object)
    (tiny_stories__story_036_type_pin ?x - object)
    (tiny_stories__story_036_p_in ?v0 - object ?v1 - object)
    (tiny_stories__story_036_p_tidy ?v0 - object)
    (tiny_stories__story_036_p_on-floor ?v0 - object)
    (tiny_stories__story_036_p_scared ?v0 - object)
    (tiny_stories__story_036_p_alive ?v0 - object)
    (tiny_stories__story_036_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_036_p_fairy ?v0 - object)
    (tiny_stories__story_041_active)
    (tiny_stories__story_041_type_character ?x - object)
    (tiny_stories__story_041_type_object ?x - object)
    (tiny_stories__story_041_p_kind ?v0 - object)
    (tiny_stories__story_041_p_knows-wisdom ?v0 - object)
    (tiny_stories__story_041_p_lost ?v0 - object)
    (tiny_stories__story_041_p_found ?v0 - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (writing_prompts__wp_044_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_p_imprisoned ?v0 - object)
    (writing_prompts__wp_044_p_served-sentence ?v0 - object)
    (writing_prompts__wp_044_p_has-serum ?v0 - object)
    (writing_prompts__wp_044_p_religious ?v0 - object)
    (writing_prompts__wp_074_active)
    (writing_prompts__wp_074_type_character ?x - object)
    (writing_prompts__wp_074_type_object ?x - object)
    (writing_prompts__wp_074_p_influenced ?v0 - object)
    (writing_prompts__wp_074_p_isolated ?v0 - object)
    (writing_prompts__wp_074_p_hates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_manipulates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_despises ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_apologized ?v0 - object ?v1 - object)
  )

  (:action human_cf10335d299ae37f_a_walk
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_landform ?from)
        (human_cf10335d299ae37f_type_landform ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_20665fb5d4fc017c ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (forall
            (?c - object)
            (or
              (not (human_cf10335d299ae37f_type_creature ?c))
              (and
                (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
                (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              )
            )
          )
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-from-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_ship ?from)
        (human_cf10335d299ae37f_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_20665fb5d4fc017c ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?from)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
              (when
                (human_cf10335d299ae37f_p_guardian ?c ?to)
                (intends ?c (not (shared_p_consensus_20665fb5d4fc017c ?creature)))
              )
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_teleport-to-ship
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?from)
        (human_cf10335d299ae37f_type_ship ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_20665fb5d4fc017c ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (human_cf10335d299ae37f_p_at ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?to)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_at ?creature ?to)
        (not (human_cf10335d299ae37f_p_at ?creature ?from))
        (when
          (not (human_cf10335d299ae37f_p_safe ?creature))
          (human_cf10335d299ae37f_p_safe ?creature)
        )
        (forall
          (?c - object)
          (when
            (human_cf10335d299ae37f_type_creature ?c)
            (and
              (not (human_cf10335d299ae37f_p_fighting ?creature ?c))
              (not (human_cf10335d299ae37f_p_fighting ?c ?creature))
            )
          )
        )
      )
    :agents (?creature)
  )

  (:action human_cf10335d299ae37f_a_attack
    :parameters (?attacker - object ?victim - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?attacker)
        (human_cf10335d299ae37f_type_creature ?victim)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?attacker)
          (not (human_cf10335d299ae37f_p_stunned ?attacker))
          (human_cf10335d299ae37f_p_at ?attacker ?place)
          (shared_p_consensus_20665fb5d4fc017c ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (human_cf10335d299ae37f_p_at ?victim ?place)
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_fighting ?attacker ?victim)
        (intends ?victim (not (human_cf10335d299ae37f_p_fighting ?attacker ?victim)))
      )
    :agents (?attacker)
  )

  (:action human_cf10335d299ae37f_a_kill
    :parameters (?killer - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?killer)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?killer)
          (not (human_cf10335d299ae37f_p_stunned ?killer))
          (shared_p_consensus_20665fb5d4fc017c ?victim)
          (or
            (human_cf10335d299ae37f_p_fighting ?killer ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_20665fb5d4fc017c ?victim))
        (when
          (human_cf10335d299ae37f_p_fighting ?killer ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?killer ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?killer))
        )
      )
    :agents (?killer)
  )

  (:action human_cf10335d299ae37f_a_stun
    :parameters (?stunner - object ?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?stunner)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?stunner)
          (not (human_cf10335d299ae37f_p_stunned ?stunner))
          (shared_p_consensus_20665fb5d4fc017c ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (or
            (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          )
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_stunned ?victim)
        (when
          (human_cf10335d299ae37f_p_fighting ?stunner ?victim)
          (not (human_cf10335d299ae37f_p_fighting ?stunner ?victim))
        )
        (when
          (human_cf10335d299ae37f_p_fighting ?victim ?stunner)
          (not (human_cf10335d299ae37f_p_fighting ?victim ?stunner))
        )
      )
    :agents (?stunner)
  )

  (:action human_cf10335d299ae37f_a_break-free
    :parameters (?victim - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?victim)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?victim)
          (human_cf10335d299ae37f_p_stunned ?victim)
        )
      )
    :effect
      (not (human_cf10335d299ae37f_p_stunned ?victim))
    :agents (?victim)
  )

  (:action human_cf10335d299ae37f_a_make-peace
    :parameters (?peacemaker - object ?creature - object ?place - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_creature ?peacemaker)
        (human_cf10335d299ae37f_type_creature ?creature)
        (human_cf10335d299ae37f_type_place ?place)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?peacemaker)
          (not (human_cf10335d299ae37f_p_stunned ?peacemaker))
          (human_cf10335d299ae37f_p_at ?peacemaker ?place)
          (shared_p_consensus_20665fb5d4fc017c ?creature)
          (human_cf10335d299ae37f_p_at ?creature ?place)
          (not (human_cf10335d299ae37f_p_fighting ?peacemaker ?creature))
          (not (human_cf10335d299ae37f_p_fighting ?creature ?peacemaker))
        )
      )
    :effect
      (and
        (shared_p_consensus_be15e3ae7b5e8f5b ?peacemaker ?creature)
        (shared_p_consensus_be15e3ae7b5e8f5b ?creature ?peacemaker)
      )
    :agents (?peacemaker)
  )

  (:action human_cf10335d299ae37f_a_begin-erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_erupting ?landform)
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (human_cf10335d299ae37f_p_at ?c ?landform)
            )
            (and
              (not (human_cf10335d299ae37f_p_safe ?c))
              (intends ?c (human_cf10335d299ae37f_p_safe ?c))
            )
          )
        )
      )
  )

  (:action human_cf10335d299ae37f_a_erupt
    :parameters (?landform - object)
    :precondition
      (and
        (human_cf10335d299ae37f_active)
        (human_cf10335d299ae37f_type_landform ?landform)
        (human_cf10335d299ae37f_p_erupting ?landform)
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_habitable ?landform))
        (not (human_cf10335d299ae37f_p_erupting ?landform))
        (forall
          (?c - object)
          (when
            (and
              (human_cf10335d299ae37f_type_creature ?c)
              (human_cf10335d299ae37f_p_at ?c ?landform)
            )
            (not (shared_p_consensus_20665fb5d4fc017c ?c))
          )
        )
      )
  )

  (:action tiny_stories__story_036_a_pick-up-pin
    :parameters (?character - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?character)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_at ?character ?box)
          (tiny_stories__story_036_p_on-floor ?pin)
          (tiny_stories__story_036_p_tidy ?box)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_036_p_on-floor ?pin))
        (tiny_stories__story_036_p_in ?pin ?box)
        (not (tiny_stories__story_036_p_scared ?pin))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_036_a_open-box
    :parameters (?character - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?character)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_at ?character ?box)
          (tiny_stories__story_036_p_tidy ?box)
        )
      )
    :effect
      (forall
        (?pin - object)
        (when
          (tiny_stories__story_036_type_pin ?pin)
          (and
            (not (tiny_stories__story_036_p_in ?pin ?box))
            (tiny_stories__story_036_p_on-floor ?pin)
            (tiny_stories__story_036_p_scared ?pin)
          )
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_036_a_bring-to-life
    :parameters (?fairy - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?fairy)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_fairy ?fairy)
          (tiny_stories__story_036_p_in ?pin ?box)
        )
      )
    :effect
      (tiny_stories__story_036_p_alive ?pin)
    :agents (?fairy)
  )

  (:action tiny_stories__story_036_a_become-friends
    :parameters (?fairy - object ?pin - object ?box - object)
    :precondition
      (and
        (tiny_stories__story_036_active)
        (tiny_stories__story_036_type_character ?fairy)
        (tiny_stories__story_036_type_pin ?pin)
        (tiny_stories__story_036_type_box ?box)
        (and
          (tiny_stories__story_036_p_fairy ?fairy)
          (tiny_stories__story_036_p_alive ?pin)
        )
      )
    :effect
      (intends ?fairy (tiny_stories__story_036_p_alive ?pin))
    :agents (?fairy)
  )

  (:action tiny_stories__story_041_a_become-kind
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?character)
        (not (tiny_stories__story_041_p_kind ?character))
      )
    :effect
      (tiny_stories__story_041_p_kind ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_041_a_learn-wisdom
    :parameters (?learner - object ?teacher - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?learner)
        (tiny_stories__story_041_type_character ?teacher)
        (and
          (not (tiny_stories__story_041_p_knows-wisdom ?learner))
          (tiny_stories__story_041_p_knows-wisdom ?teacher)
        )
      )
    :effect
      (tiny_stories__story_041_p_knows-wisdom ?learner)
    :agents (?learner ?teacher)
  )

  (:action tiny_stories__story_041_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?helper)
        (tiny_stories__story_041_type_character ?helpee)
        (and
          (tiny_stories__story_041_p_kind ?helper)
          (tiny_stories__story_041_p_lost ?helpee)
        )
      )
    :effect
      (tiny_stories__story_041_p_found ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_041_a_become-friends
    :parameters (?c1 - object ?c2 - object)
    :precondition
      (and
        (tiny_stories__story_041_active)
        (tiny_stories__story_041_type_character ?c1)
        (tiny_stories__story_041_type_character ?c2)
        (and
          (not (shared_p_consensus_be15e3ae7b5e8f5b ?c1 ?c2))
          (not (= ?c1 ?c2))
        )
      )
    :effect
      (shared_p_consensus_be15e3ae7b5e8f5b ?c1 ?c2)
    :agents (?c1 ?c2)
  )

  (:action writing_prompts__wp_044_a_take-serum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?character)
          (not (writing_prompts__wp_044_p_has-serum ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_has-serum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_serve-sentence
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (not (writing_prompts__wp_044_p_served-sentence ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_served-sentence ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_release
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (writing_prompts__wp_044_p_served-sentence ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_imprisoned ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_convert
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?character)
          (not (writing_prompts__wp_044_p_religious ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_religious ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_abandon-religion
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_20665fb5d4fc017c ?character)
          (writing_prompts__wp_044_p_religious ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_religious ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_074_a_influence
    :parameters (?influencer - object ?influenced - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?influencer)
        (writing_prompts__wp_074_type_character ?influenced)
        (and
          (not (= ?influencer ?influenced))
          (not (writing_prompts__wp_074_p_influenced ?influenced))
        )
      )
    :effect
      (writing_prompts__wp_074_p_influenced ?influenced)
    :agents (?influencer)
  )

  (:action writing_prompts__wp_074_a_isolate
    :parameters (?isolator - object ?isolated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?isolator)
        (writing_prompts__wp_074_type_character ?isolated)
        (and
          (not (= ?isolator ?isolated))
          (not (writing_prompts__wp_074_p_isolated ?isolated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_isolated ?isolated)
    :agents (?isolator)
  )

  (:action writing_prompts__wp_074_a_manipulate
    :parameters (?manipulator - object ?manipulated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?manipulator)
        (writing_prompts__wp_074_type_character ?manipulated)
        (and
          (not (= ?manipulator ?manipulated))
          (not (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated)
    :agents (?manipulator)
  )

  (:action writing_prompts__wp_074_a_hate
    :parameters (?hater - object ?hated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?hater)
        (writing_prompts__wp_074_type_character ?hated)
        (and
          (not (= ?hater ?hated))
          (not (writing_prompts__wp_074_p_hates ?hater ?hated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_hates ?hater ?hated)
    :agents (?hater)
  )

  (:action writing_prompts__wp_074_a_despise
    :parameters (?despiser - object ?despised - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?despiser)
        (writing_prompts__wp_074_type_character ?despised)
        (and
          (not (= ?despiser ?despised))
          (not (writing_prompts__wp_074_p_despises ?despiser ?despised))
        )
      )
    :effect
      (writing_prompts__wp_074_p_despises ?despiser ?despised)
    :agents (?despiser)
  )

  (:action writing_prompts__wp_074_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?apologizer)
        (writing_prompts__wp_074_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (writing_prompts__wp_074_p_apologized ?apologizer ?apologized))
        )
      )
    :effect
      (writing_prompts__wp_074_p_apologized ?apologizer ?apologized)
    :agents (?apologizer)
  )
)
