(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
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
    (tiny_stories__story_051_active)
    (tiny_stories__story_051_type_animal ?x - object)
    (tiny_stories__story_051_type_character ?x - object)
    (tiny_stories__story_051_type_object ?x - object)
    (tiny_stories__story_051_type_place ?x - object)
    (tiny_stories__story_051_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_hugged ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_door-open ?v0 - object)
    (tiny_stories__story_051_p_friendly ?v0 - object)
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (tiny_stories__story_085_p_broken ?v0 - object)
    (tiny_stories__story_085_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_apologized ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_cleaned ?v0 - object)
    (tiny_stories__story_085_p_forgiven ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_active)
    (writing_prompts__wp_038_type_character ?x - object)
    (writing_prompts__wp_038_type_object ?x - object)
    (writing_prompts__wp_038_type_place ?x - object)
    (writing_prompts__wp_038_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_alive ?v0 - object)
    (writing_prompts__wp_038_p_abducted ?v0 - object)
    (writing_prompts__wp_038_p_has-translator ?v0 - object)
    (writing_prompts__wp_038_p_knows-mistake ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_playing-game ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_friends ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object ?animal - object) :context (and (tiny_stories__story_051_active) (tiny_stories__story_051_type_character ?character) (tiny_stories__story_051_type_animal ?animal) (and (not (tiny_stories__story_051_p_friendly ?animal)) (tiny_stories__story_051_p_hugged ?character ?animal))) :implies (tiny_stories__story_051_p_friendly ?animal))

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

  (:action tiny_stories__story_051_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?from)
        (tiny_stories__story_051_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_051_p_at ?character ?from)
          (tiny_stories__story_051_p_door-open ?to)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_051_p_at ?character ?from))
        (tiny_stories__story_051_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_hug
    :parameters (?hugger - object ?hugged - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?hugger)
        (tiny_stories__story_051_type_object ?hugged)
        (tiny_stories__story_051_type_place ?place)
        (and
          (tiny_stories__story_051_p_at ?hugger ?place)
          (tiny_stories__story_051_p_at ?hugged ?place)
        )
      )
    :effect
      (tiny_stories__story_051_p_hugged ?hugger ?hugged)
    :agents (?hugger)
  )

  (:action tiny_stories__story_051_a_open-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (tiny_stories__story_051_p_at ?character ?place)
          (not (tiny_stories__story_051_p_door-open ?place))
        )
      )
    :effect
      (tiny_stories__story_051_p_door-open ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_close-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (tiny_stories__story_051_p_at ?character ?place)
          (tiny_stories__story_051_p_door-open ?place)
        )
      )
    :effect
      (not (tiny_stories__story_051_p_door-open ?place))
    :agents (?character)
  )

  (:action tiny_stories__story_085_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?character)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_playing ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_085_a_break-item
    :parameters (?breaker - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?breaker)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_playing ?breaker ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_broken ?item)
    :agents (?breaker)
  )

  (:action tiny_stories__story_085_a_apologize
    :parameters (?apologizer - object ?apologizee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?apologizer)
        (tiny_stories__story_085_type_character ?apologizee)
        (not (= ?apologizer ?apologizee))
      )
    :effect
      (tiny_stories__story_085_p_apologized ?apologizer ?apologizee)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_085_a_clean
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?cleaner)
        (tiny_stories__story_085_type_item ?item)
        (tiny_stories__story_085_p_broken ?item)
      )
    :effect
      (tiny_stories__story_085_p_cleaned ?cleaner)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_085_a_forgive
    :parameters (?forgiver - object ?forgivee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?forgiver)
        (tiny_stories__story_085_type_character ?forgivee)
        (and
          (not (= ?forgiver ?forgivee))
          (tiny_stories__story_085_p_apologized ?forgivee ?forgiver)
        )
      )
    :effect
      (tiny_stories__story_085_p_forgiven ?forgiver ?forgivee)
    :agents (?forgiver)
  )

  (:action writing_prompts__wp_038_a_abduct
    :parameters (?abductor - object ?abductee - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?abductor)
        (writing_prompts__wp_038_type_character ?abductee)
        (writing_prompts__wp_038_type_place ?place)
        (and
          (not (= ?abductor ?abductee))
          (writing_prompts__wp_038_p_alive ?abductor)
          (writing_prompts__wp_038_p_at ?abductor ?place)
          (writing_prompts__wp_038_p_alive ?abductee)
          (writing_prompts__wp_038_p_at ?abductee ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_038_p_abducted ?abductee)
        (not (writing_prompts__wp_038_p_at ?abductee ?place))
      )
    :agents (?abductor)
  )

  (:action writing_prompts__wp_038_a_give-translator
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?giver)
        (writing_prompts__wp_038_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_038_p_alive ?giver)
          (writing_prompts__wp_038_p_alive ?receiver)
          (writing_prompts__wp_038_p_abducted ?receiver)
        )
      )
    :effect
      (writing_prompts__wp_038_p_has-translator ?receiver)
    :agents (?giver)
  )

  (:action writing_prompts__wp_038_a_reveal-mistake
    :parameters (?mistaken - object ?informed - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?mistaken)
        (writing_prompts__wp_038_type_character ?informed)
        (and
          (not (= ?mistaken ?informed))
          (writing_prompts__wp_038_p_alive ?mistaken)
          (writing_prompts__wp_038_p_alive ?informed)
          (writing_prompts__wp_038_p_has-translator ?informed)
        )
      )
    :effect
      (writing_prompts__wp_038_p_knows-mistake ?informed ?mistaken)
    :agents (?mistaken)
  )

  (:action writing_prompts__wp_038_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_has-translator ?character1)
        )
      )
    :effect
      (writing_prompts__wp_038_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_play-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_stop-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
        )
      )
    :effect
      (not (writing_prompts__wp_038_p_playing-game ?character1 ?character2))
    :agents (?character1 ?character2)
  )
)
