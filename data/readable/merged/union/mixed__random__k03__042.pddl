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
    (human_cf10335d299ae37f_p_alive ?v0 - object)
    (human_cf10335d299ae37f_p_stunned ?v0 - object)
    (human_cf10335d299ae37f_p_habitable ?v0 - object)
    (human_cf10335d299ae37f_p_safe ?v0 - object)
    (human_cf10335d299ae37f_p_erupting ?v0 - object)
    (human_cf10335d299ae37f_p_at ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_fighting ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_friends ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_captain ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_guardian ?v0 - object ?v1 - object)
    (writing_prompts__wp_090_active)
    (writing_prompts__wp_090_type_character ?x - object)
    (writing_prompts__wp_090_type_object ?x - object)
    (writing_prompts__wp_090_p_famous ?v0 - object)
    (writing_prompts__wp_090_p_wears-earmuffs ?v0 - object)
    (writing_prompts__wp_090_p_filled-with-ice ?v0 - object)
    (writing_prompts__wp_090_p_candidate ?v0 - object)
    (writing_prompts__wp_090_p_president ?v0 - object)
    (writing_prompts__wp_090_p_endured-pain ?v0 - object)
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
          (human_cf10335d299ae37f_p_alive ?creature)
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
          (human_cf10335d299ae37f_p_alive ?creature)
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
                (intends ?c (not (human_cf10335d299ae37f_p_alive ?creature)))
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
          (human_cf10335d299ae37f_p_alive ?creature)
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
          (human_cf10335d299ae37f_p_alive ?attacker)
          (not (human_cf10335d299ae37f_p_stunned ?attacker))
          (human_cf10335d299ae37f_p_at ?attacker ?place)
          (human_cf10335d299ae37f_p_alive ?victim)
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
          (human_cf10335d299ae37f_p_alive ?killer)
          (not (human_cf10335d299ae37f_p_stunned ?killer))
          (human_cf10335d299ae37f_p_alive ?victim)
          (or
            (human_cf10335d299ae37f_p_fighting ?killer ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          )
        )
      )
    :effect
      (and
        (not (human_cf10335d299ae37f_p_alive ?victim))
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
          (human_cf10335d299ae37f_p_alive ?stunner)
          (not (human_cf10335d299ae37f_p_stunned ?stunner))
          (human_cf10335d299ae37f_p_alive ?victim)
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
          (human_cf10335d299ae37f_p_alive ?victim)
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
          (human_cf10335d299ae37f_p_alive ?peacemaker)
          (not (human_cf10335d299ae37f_p_stunned ?peacemaker))
          (human_cf10335d299ae37f_p_at ?peacemaker ?place)
          (human_cf10335d299ae37f_p_alive ?creature)
          (human_cf10335d299ae37f_p_at ?creature ?place)
          (not (human_cf10335d299ae37f_p_fighting ?peacemaker ?creature))
          (not (human_cf10335d299ae37f_p_fighting ?creature ?peacemaker))
        )
      )
    :effect
      (and
        (human_cf10335d299ae37f_p_friends ?peacemaker ?creature)
        (human_cf10335d299ae37f_p_friends ?creature ?peacemaker)
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
            (not (human_cf10335d299ae37f_p_alive ?c))
          )
        )
      )
  )

  (:action writing_prompts__wp_090_a_become-famous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (not (writing_prompts__wp_090_p_famous ?character))
      )
    :effect
      (writing_prompts__wp_090_p_famous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_wear-earmuffs
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (not (writing_prompts__wp_090_p_wears-earmuffs ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_wears-earmuffs ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_fill-earmuffs-with-ice
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (writing_prompts__wp_090_p_wears-earmuffs ?character)
          (not (writing_prompts__wp_090_p_filled-with-ice ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_filled-with-ice ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_become-candidate
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (not (writing_prompts__wp_090_p_candidate ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_candidate ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_become-president
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_candidate ?character)
          (not (writing_prompts__wp_090_p_president ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_president ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_090_a_endure-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_090_active)
        (writing_prompts__wp_090_type_character ?character)
        (and
          (writing_prompts__wp_090_p_famous ?character)
          (writing_prompts__wp_090_p_filled-with-ice ?character)
          (not (writing_prompts__wp_090_p_endured-pain ?character))
        )
      )
    :effect
      (writing_prompts__wp_090_p_endured-pain ?character)
    :agents (?character)
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
