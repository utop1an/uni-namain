(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_045_o_mirror - object)
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
    (tiny_stories__story_045_active)
    (tiny_stories__story_045_type_character ?x - object)
    (tiny_stories__story_045_type_object ?x - object)
    (shared_p_consensus_f72eadccf7db8658 ?v0 - object ?v1 - object)
    (tiny_stories__story_045_p_shares ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_066_active)
    (tiny_stories__story_066_type_character ?x - object)
    (tiny_stories__story_066_type_item ?x - object)
    (tiny_stories__story_066_type_object ?x - object)
    (tiny_stories__story_066_type_place ?x - object)
    (shared_p_consensus_ce0bdfa4a1bc75c3 ?v0 - object ?v1 - object)
    (tiny_stories__story_066_p_happy ?v0 - object)
    (tiny_stories__story_066_p_gave-gift ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (tiny_stories__story_093_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_007_active)
    (writing_prompts__wp_007_type_item ?x - object)
    (writing_prompts__wp_007_type_object ?x - object)
    (writing_prompts__wp_007_type_room ?x - object)
    (writing_prompts__wp_007_p_in ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_occupied ?v0 - object)
    (writing_prompts__wp_007_p_plugged-in ?v0 - object)
    (writing_prompts__wp_007_p_connected ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_well-lit ?v0 - object)
    (writing_prompts__wp_007_p_morning)
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

  (:action tiny_stories__story_045_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?character)
        (tiny_stories__story_045_type_object ?object)
        (not (shared_p_consensus_f72eadccf7db8658 ?character ?object))
      )
    :effect
      (shared_p_consensus_f72eadccf7db8658 ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_share
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (and
          (shared_p_consensus_f72eadccf7db8658 ?sharer ?object)
          (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
        )
      )
    :effect
      (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_045_a_unshare
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
      )
    :effect
      (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_066_a_find
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
          (not (shared_p_consensus_f72eadccf7db8658 ?character ?item))
        )
      )
    :effect
      (shared_p_consensus_f72eadccf7db8658 ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?giver)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_character ?receiver)
        (tiny_stories__story_066_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?giver ?place)
          (shared_p_consensus_f72eadccf7db8658 ?giver ?item)
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_f72eadccf7db8658 ?giver ?item))
        (shared_p_consensus_f72eadccf7db8658 ?receiver ?item)
        (tiny_stories__story_066_p_gave-gift ?giver ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action tiny_stories__story_066_a_play
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_item ?item)
        (tiny_stories__story_066_type_place ?place)
        (and
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
          (shared_p_consensus_f72eadccf7db8658 ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_066_a_make-happy
    :parameters (?character - object ?target - object)
    :precondition
      (and
        (tiny_stories__story_066_active)
        (tiny_stories__story_066_type_character ?character)
        (tiny_stories__story_066_type_character ?target)
        (and
          (not (= ?character ?target))
          (not (tiny_stories__story_066_p_happy ?target))
        )
      )
    :effect
      (tiny_stories__story_066_p_happy ?target)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_place ?place)
        (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
      )
    :effect
      (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_select-mop
    :parameters (?character - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
          (tiny_stories__story_093_p_has ?character ?mop)
        )
      )
    :effect
      (tiny_stories__story_093_p_selected ?mop)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_receive-mop
    :parameters (?character - object ?dog - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_character ?dog)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?character ?place)
          (shared_p_consensus_ce0bdfa4a1bc75c3 ?dog ?place)
          (tiny_stories__story_093_p_has ?dog ?mop)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_093_p_has ?dog ?mop))
        (tiny_stories__story_093_p_has ?character ?mop)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_007_a_move-item
    :parameters (?item - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_type_room ?from)
        (writing_prompts__wp_007_type_room ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_007_p_in ?item ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_007_p_in ?item ?from))
        (writing_prompts__wp_007_p_in ?item ?to)
      )
  )

  (:action writing_prompts__wp_007_a_plug-in
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_plugged-in ?item))
      )
    :effect
      (writing_prompts__wp_007_p_plugged-in ?item)
  )

  (:action writing_prompts__wp_007_a_connect
    :parameters (?item1 - object ?item2 - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item1)
        (writing_prompts__wp_007_type_item ?item2)
        (and
          (not (writing_prompts__wp_007_p_connected ?item1 ?item2))
          (not (= ?item1 ?item2))
        )
      )
    :effect
      (writing_prompts__wp_007_p_connected ?item1 ?item2)
  )

  (:action writing_prompts__wp_007_a_morning-comes
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (not (writing_prompts__wp_007_p_well-lit ?room))
          (writing_prompts__wp_007_p_morning)
        )
      )
    :effect
      (writing_prompts__wp_007_p_well-lit ?room)
  )

  (:action writing_prompts__wp_007_a_night-falls
    :parameters (?room - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_room ?room)
        (and
          (writing_prompts__wp_007_p_well-lit ?room)
          (not (writing_prompts__wp_007_p_morning))
        )
      )
    :effect
      (not (writing_prompts__wp_007_p_well-lit ?room))
  )

  (:action writing_prompts__wp_007_a_occupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (not (writing_prompts__wp_007_p_occupied ?item))
      )
    :effect
      (writing_prompts__wp_007_p_occupied ?item)
  )

  (:action writing_prompts__wp_007_a_unoccupy
    :parameters (?item - object)
    :precondition
      (and
        (writing_prompts__wp_007_active)
        (writing_prompts__wp_007_type_item ?item)
        (writing_prompts__wp_007_p_occupied ?item)
      )
    :effect
      (not (writing_prompts__wp_007_p_occupied ?item))
  )
)
