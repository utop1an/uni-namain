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
    (shared_p_consensus_f0498816f7b11827 ?v0 - object)
    (human_cf10335d299ae37f_p_stunned ?v0 - object)
    (human_cf10335d299ae37f_p_habitable ?v0 - object)
    (human_cf10335d299ae37f_p_safe ?v0 - object)
    (human_cf10335d299ae37f_p_erupting ?v0 - object)
    (shared_p_consensus_de4e7bc9da9bdbf4 ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_fighting ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_friends ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_captain ?v0 - object ?v1 - object)
    (human_cf10335d299ae37f_p_guardian ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_active)
    (writing_prompts__wp_006_type_character ?x - object)
    (writing_prompts__wp_006_type_object ?x - object)
    (writing_prompts__wp_006_type_place ?x - object)
    (writing_prompts__wp_006_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_accepts-past ?v0 - object ?v1 - object)
    (writing_prompts__wp_006_p_knows-self ?v0 - object)
    (writing_prompts__wp_006_p_sings ?v0 - object)
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
          (shared_p_consensus_f0498816f7b11827 ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from)
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
        (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?to)
        (not (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from))
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
          (shared_p_consensus_f0498816f7b11827 ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?from)
        )
      )
    :effect
      (and
        (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?to)
        (not (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from))
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
                (intends ?c (not (shared_p_consensus_f0498816f7b11827 ?creature)))
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
          (shared_p_consensus_f0498816f7b11827 ?creature)
          (not (human_cf10335d299ae37f_p_stunned ?creature))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from)
          (human_cf10335d299ae37f_p_habitable ?to)
          (human_cf10335d299ae37f_p_safe ?to)
          (human_cf10335d299ae37f_p_captain ?creature ?to)
        )
      )
    :effect
      (and
        (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?to)
        (not (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?from))
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
          (shared_p_consensus_f0498816f7b11827 ?attacker)
          (not (human_cf10335d299ae37f_p_stunned ?attacker))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?attacker ?place)
          (shared_p_consensus_f0498816f7b11827 ?victim)
          (not (human_cf10335d299ae37f_p_stunned ?victim))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?victim ?place)
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
          (shared_p_consensus_f0498816f7b11827 ?killer)
          (not (human_cf10335d299ae37f_p_stunned ?killer))
          (shared_p_consensus_f0498816f7b11827 ?victim)
          (or
            (human_cf10335d299ae37f_p_fighting ?killer ?victim)
            (human_cf10335d299ae37f_p_fighting ?victim ?killer)
          )
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f0498816f7b11827 ?victim))
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
          (shared_p_consensus_f0498816f7b11827 ?stunner)
          (not (human_cf10335d299ae37f_p_stunned ?stunner))
          (shared_p_consensus_f0498816f7b11827 ?victim)
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
          (shared_p_consensus_f0498816f7b11827 ?victim)
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
          (shared_p_consensus_f0498816f7b11827 ?peacemaker)
          (not (human_cf10335d299ae37f_p_stunned ?peacemaker))
          (shared_p_consensus_de4e7bc9da9bdbf4 ?peacemaker ?place)
          (shared_p_consensus_f0498816f7b11827 ?creature)
          (shared_p_consensus_de4e7bc9da9bdbf4 ?creature ?place)
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
              (shared_p_consensus_de4e7bc9da9bdbf4 ?c ?landform)
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
              (shared_p_consensus_de4e7bc9da9bdbf4 ?c ?landform)
            )
            (not (shared_p_consensus_f0498816f7b11827 ?c))
          )
        )
      )
  )

  (:action writing_prompts__wp_006_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (writing_prompts__wp_006_type_place ?from)
        (writing_prompts__wp_006_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_f0498816f7b11827 ?character)
          (shared_p_consensus_de4e7bc9da9bdbf4 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_de4e7bc9da9bdbf4 ?character ?from))
        (shared_p_consensus_de4e7bc9da9bdbf4 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (shared_p_consensus_f0498816f7b11827 ?character)
      )
    :effect
      (writing_prompts__wp_006_p_sings ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_006_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_f0498816f7b11827 ?character1)
          (shared_p_consensus_f0498816f7b11827 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_accept-past
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character1)
        (writing_prompts__wp_006_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_f0498816f7b11827 ?character1)
          (shared_p_consensus_f0498816f7b11827 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_006_p_accepts-past ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_006_a_know-self
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_006_active)
        (writing_prompts__wp_006_type_character ?character)
        (shared_p_consensus_f0498816f7b11827 ?character)
      )
    :effect
      (writing_prompts__wp_006_p_knows-self ?character)
    :agents (?character)
  )
)
