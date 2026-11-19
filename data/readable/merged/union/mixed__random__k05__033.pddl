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
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_003_p_broken-pedal ?v0 - object)
    (tiny_stories__story_003_p_fixed-pedal ?v0 - object)
    (tiny_stories__story_003_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_003_p_at-shop ?v0 - object)
    (tiny_stories__story_003_p_happy ?v0 - object)
    (tiny_stories__story_003_p_flying ?v0 - object)
    (writing_prompts__wp_009_active)
    (writing_prompts__wp_009_type_character ?x - object)
    (writing_prompts__wp_009_type_object ?x - object)
    (writing_prompts__wp_009_p_alive ?v0 - object)
    (writing_prompts__wp_009_p_spirits-present ?v0 - object)
    (writing_prompts__wp_009_p_spirits-gone ?v0 - object)
    (writing_prompts__wp_009_p_weak ?v0 - object)
    (writing_prompts__wp_009_p_love-driven-away ?v0 - object)
    (writing_prompts__wp_009_p_in-asylum ?v0 - object)
    (writing_prompts__wp_077_active)
    (writing_prompts__wp_077_type_object ?x - object)
    (writing_prompts__wp_077_type_poem ?x - object)
    (writing_prompts__wp_077_type_reader ?x - object)
    (writing_prompts__wp_077_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_077_p_alive ?v0 - object)
    (writing_prompts__wp_077_p_dead ?v0 - object)
    (writing_prompts__wp_077_p_echo ?v0 - object ?v1 - object)
    (writing_prompts__wp_091_active)
    (writing_prompts__wp_091_type_character ?x - object)
    (writing_prompts__wp_091_type_object ?x - object)
    (writing_prompts__wp_091_p_feels-awful ?v0 - object)
    (writing_prompts__wp_091_p_thinks-about-breakup ?v0 - object)
    (writing_prompts__wp_091_p_heartbroken ?v0 - object)
    (writing_prompts__wp_091_p_forgiven ?v0 - object)
    (writing_prompts__wp_091_p_learned ?v0 - object)
    (writing_prompts__wp_091_p_moved-on ?v0 - object)
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

  (:action tiny_stories__story_003_a_go-to-shop
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_at-shop ?character))
      )
    :effect
      (tiny_stories__story_003_p_at-shop ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_fix-pedal
    :parameters (?character - object ?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_at-shop ?character)
          (tiny_stories__story_003_p_has ?character ?bike)
          (tiny_stories__story_003_p_broken-pedal ?bike)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_003_p_broken-pedal ?bike))
        (tiny_stories__story_003_p_fixed-pedal ?bike)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_character ?character)
        (not (tiny_stories__story_003_p_happy ?character))
      )
    :effect
      (tiny_stories__story_003_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_003_a_start-flying
    :parameters (?bike - object)
    :precondition
      (and
        (tiny_stories__story_003_active)
        (tiny_stories__story_003_type_object ?bike)
        (and
          (tiny_stories__story_003_p_fixed-pedal ?bike)
          (not (tiny_stories__story_003_p_flying ?bike))
        )
      )
    :effect
      (tiny_stories__story_003_p_flying ?bike)
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

  (:action writing_prompts__wp_077_a_read-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (not (writing_prompts__wp_077_p_read ?reader ?poem))
          (writing_prompts__wp_077_p_alive ?poem)
        )
      )
    :effect
      (and
        (writing_prompts__wp_077_p_read ?reader ?poem)
        (writing_prompts__wp_077_p_echo ?reader ?poem)
      )
    :agents (?reader)
  )

  (:action writing_prompts__wp_077_a_poem-dies
    :parameters (?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_poem ?poem)
        (writing_prompts__wp_077_p_alive ?poem)
      )
    :effect
      (and
        (not (writing_prompts__wp_077_p_alive ?poem))
        (writing_prompts__wp_077_p_dead ?poem)
      )
  )

  (:action writing_prompts__wp_077_a_echo-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (writing_prompts__wp_077_p_read ?reader ?poem)
          (not (writing_prompts__wp_077_p_echo ?reader ?poem))
        )
      )
    :effect
      (writing_prompts__wp_077_p_echo ?reader ?poem)
    :agents (?reader)
  )

  (:action writing_prompts__wp_091_a_forgive
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_feels-awful ?character)
          (not (writing_prompts__wp_091_p_forgiven ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_forgiven ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_learn
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_heartbroken ?character)
          (not (writing_prompts__wp_091_p_learned ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_learned ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_091_a_move-on
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_091_active)
        (writing_prompts__wp_091_type_character ?character)
        (and
          (writing_prompts__wp_091_p_thinks-about-breakup ?character)
          (writing_prompts__wp_091_p_forgiven ?character)
          (writing_prompts__wp_091_p_learned ?character)
          (not (writing_prompts__wp_091_p_moved-on ?character))
        )
      )
    :effect
      (writing_prompts__wp_091_p_moved-on ?character)
    :agents (?character)
  )
)
