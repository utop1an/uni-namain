(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_3cd8b87ba572801b_active)
    (human_3cd8b87ba572801b_type_aristocrat ?x - object)
    (human_3cd8b87ba572801b_type_canmarry ?x - object)
    (human_3cd8b87ba572801b_type_character ?x - object)
    (human_3cd8b87ba572801b_type_dragon ?x - object)
    (human_3cd8b87ba572801b_type_emperor ?x - object)
    (human_3cd8b87ba572801b_type_female ?x - object)
    (human_3cd8b87ba572801b_type_genie ?x - object)
    (human_3cd8b87ba572801b_type_ismagic ?x - object)
    (human_3cd8b87ba572801b_type_king ?x - object)
    (human_3cd8b87ba572801b_type_knight ?x - object)
    (human_3cd8b87ba572801b_type_location ?x - object)
    (human_3cd8b87ba572801b_type_lord ?x - object)
    (human_3cd8b87ba572801b_type_male ?x - object)
    (human_3cd8b87ba572801b_type_monarch ?x - object)
    (human_3cd8b87ba572801b_type_monster ?x - object)
    (human_3cd8b87ba572801b_type_object ?x - object)
    (human_3cd8b87ba572801b_type_person ?x - object)
    (human_3cd8b87ba572801b_type_princess ?x - object)
    (human_3cd8b87ba572801b_type_spirit ?x - object)
    (human_3cd8b87ba572801b_type_thing ?x - object)
    (human_3cd8b87ba572801b_type_zombie ?x - object)
    (human_3cd8b87ba572801b_p_bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_bachelor-loves ?v0 - object)
    (human_3cd8b87ba572801b_p_loves-bachelor ?v0 - object)
    (human_3cd8b87ba572801b_p_magic-char ?v0 - object)
    (human_3cd8b87ba572801b_p_controls-magic ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_magic-char-alive)
    (human_3cd8b87ba572801b_p_scary ?v0 - object)
    (human_3cd8b87ba572801b_p_single ?v0 - object)
    (human_3cd8b87ba572801b_p_beautiful ?v0 - object)
    (human_3cd8b87ba572801b_p_magic ?v0 - object)
    (human_3cd8b87ba572801b_p_controls ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_married-to ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loves ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loyal-to ?v0 - object ?v1 - object)
    (shared_p_consensus_9b6660cbbe84b8af ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (shared_p_consensus_6222018a35ad9de9 ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (human_3cd8b87ba572801b_p_alive ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
    (human_4d95b598471c21ee_active)
    (human_4d95b598471c21ee_type_book ?x - object)
    (human_4d95b598471c21ee_type_character ?x - object)
    (human_4d95b598471c21ee_type_item ?x - object)
    (human_4d95b598471c21ee_type_location ?x - object)
    (human_4d95b598471c21ee_type_object ?x - object)
    (human_4d95b598471c21ee_type_ring ?x - object)
    (human_4d95b598471c21ee_type_sword ?x - object)
    (human_4d95b598471c21ee_type_thing ?x - object)
    (human_4d95b598471c21ee_p_player ?v0 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
  )

  (:action human_3cd8b87ba572801b_a_slay
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?slayer ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?m ?place)
          (human_3cd8b87ba572801b_p_alive ?slayer)
          (human_3cd8b87ba572801b_p_alive ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (human_3cd8b87ba572801b_p_alive ?m))
  )

  (:action human_3cd8b87ba572801b_a_slay-magic-char
    :parameters (?slayer - object ?m - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_knight ?slayer)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?slayer ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?m ?place)
          (human_3cd8b87ba572801b_p_alive ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (human_3cd8b87ba572801b_p_alive ?m))
        (human_3cd8b87ba572801b_p_magic-char ?m)
        (not (human_3cd8b87ba572801b_p_magic-char-alive))
      )
  )

  (:action human_3cd8b87ba572801b_a_pillage
    :parameters (?pillager - object ?body - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?pillager)
        (human_3cd8b87ba572801b_type_character ?body)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?pillager ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?body ?place)
          (human_3cd8b87ba572801b_p_alive ?pillager)
          (not (human_3cd8b87ba572801b_p_alive ?body))
          (shared_p_consensus_6222018a35ad9de9 ?body ?t)
          (not (shared_p_consensus_6222018a35ad9de9 ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (shared_p_consensus_6222018a35ad9de9 ?pillager ?t)
        (not (shared_p_consensus_6222018a35ad9de9 ?body ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_give
    :parameters (?giver - object ?givee - object ?t - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?giver)
        (human_3cd8b87ba572801b_type_character ?givee)
        (human_3cd8b87ba572801b_type_thing ?t)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (not (= ?giver ?givee))
          (shared_p_consensus_9b6660cbbe84b8af ?giver ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?givee ?place)
          (human_3cd8b87ba572801b_p_alive ?givee)
          (human_3cd8b87ba572801b_p_alive ?giver)
          (shared_p_consensus_6222018a35ad9de9 ?giver ?t)
          (not (shared_p_consensus_6222018a35ad9de9 ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (shared_p_consensus_6222018a35ad9de9 ?givee ?t)
        (not (shared_p_consensus_6222018a35ad9de9 ?giver ?t))
      )
  )

  (:action human_3cd8b87ba572801b_a_summon
    :parameters (?char - object ?g - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_ismagic ?g)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_confined ?g)
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (shared_p_consensus_9b6660cbbe84b8af ?char ?place)
          (shared_p_consensus_6222018a35ad9de9 ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (human_3cd8b87ba572801b_p_alive ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_9b6660cbbe84b8af ?g ?place)
        (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
        (human_3cd8b87ba572801b_p_controls-magic ?char ?lamp)
        (not (human_3cd8b87ba572801b_p_in ?g ?lamp))
        (not (human_3cd8b87ba572801b_p_confined ?g))
      )
  )

  (:action human_3cd8b87ba572801b_a_love-spell
    :parameters (?g - object ?target - object ?lover - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?target)
        (human_3cd8b87ba572801b_type_canmarry ?lover)
        (and
          (not (human_3cd8b87ba572801b_p_confined ?g))
          (not (human_3cd8b87ba572801b_p_loves ?target ?lover))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (human_3cd8b87ba572801b_p_alive ?target)
          (human_3cd8b87ba572801b_p_alive ?lover)
          (not (= ?g ?target))
          (not (= ?g ?lover))
          (not (= ?target ?lover))
          (human_3cd8b87ba572801b_p_intends-loves ?g ?target ?lover)
          (human_3cd8b87ba572801b_p_bachelor ?lover)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?target ?lover)
        (human_3cd8b87ba572801b_p_loves-bachelor ?target)
      )
  )

  (:action human_3cd8b87ba572801b_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?groom)
        (human_3cd8b87ba572801b_type_person ?bride)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_alive ?groom)
          (human_3cd8b87ba572801b_p_alive ?bride)
          (shared_p_consensus_9b6660cbbe84b8af ?groom ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?bride ?place)
          (human_3cd8b87ba572801b_p_loves ?groom ?bride)
          (human_3cd8b87ba572801b_p_loves ?bride ?groom)
          (human_3cd8b87ba572801b_p_single ?groom)
          (human_3cd8b87ba572801b_p_bachelor ?groom)
          (human_3cd8b87ba572801b_p_single ?bride)
          (not (= ?groom ?bride))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_married-to ?groom ?bride)
        (human_3cd8b87ba572801b_p_married-to ?bride ?groom)
        (not (human_3cd8b87ba572801b_p_single ?groom))
        (not (human_3cd8b87ba572801b_p_single ?bride))
      )
  )

  (:action human_3cd8b87ba572801b_a_fall-in-love
    :parameters (?m - object ?f - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_canmarry ?m)
        (human_3cd8b87ba572801b_type_female ?f)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_bachelor ?m)
          (shared_p_consensus_9b6660cbbe84b8af ?m ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_alive ?f)
          (not (human_3cd8b87ba572801b_p_loves ?m ?f))
          (human_3cd8b87ba572801b_p_beautiful ?f)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_loves ?m ?f)
        (human_3cd8b87ba572801b_p_bachelor-loves ?f)
      )
  )

  (:action human_3cd8b87ba572801b_a_order
    :parameters (?ki - object ?kn - object ?place - object ?t - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_king ?ki)
        (human_3cd8b87ba572801b_type_knight ?kn)
        (human_3cd8b87ba572801b_type_location ?place)
        (human_3cd8b87ba572801b_type_thing ?t)
        (and
          (human_3cd8b87ba572801b_p_loyal-to ?kn ?ki)
          (human_3cd8b87ba572801b_p_alive ?kn)
          (human_3cd8b87ba572801b_p_alive ?ki)
          (shared_p_consensus_9b6660cbbe84b8af ?ki ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?kn ?place)
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-has ?kn ?ki ?t)
  )

  (:action human_3cd8b87ba572801b_a_appear-threatening
    :parameters (?m - object ?char - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_monster ?m)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_alive ?m)
          (human_3cd8b87ba572801b_p_alive ?char)
          (shared_p_consensus_9b6660cbbe84b8af ?m ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?char ?place)
          (human_3cd8b87ba572801b_p_scary ?m)
          (not (= ?m ?char))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-not-alive ?char ?m)
  )

  (:action human_3cd8b87ba572801b_a_command
    :parameters (?char - object ?g - object ?love - object ?lamp - object ?place - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_person ?char)
        (human_3cd8b87ba572801b_type_genie ?g)
        (human_3cd8b87ba572801b_type_person ?love)
        (human_3cd8b87ba572801b_type_thing ?lamp)
        (human_3cd8b87ba572801b_type_location ?place)
        (and
          (human_3cd8b87ba572801b_p_magic ?lamp)
          (shared_p_consensus_6222018a35ad9de9 ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (human_3cd8b87ba572801b_p_alive ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (human_3cd8b87ba572801b_p_alive ?love)
          (shared_p_consensus_9b6660cbbe84b8af ?char ?place)
          (shared_p_consensus_9b6660cbbe84b8af ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )

  (:action human_4d95b598471c21ee_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?waker)
        (human_4d95b598471c21ee_type_character ?woken)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?waker ?location)
          (shared_p_consensus_9b6660cbbe84b8af ?woken ?location)
          (human_4d95b598471c21ee_p_asleep ?woken)
          (not (human_4d95b598471c21ee_p_asleep ?waker))
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_asleep ?woken))
  )

  (:action human_4d95b598471c21ee_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?taker)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?taker ?location)
          (shared_p_consensus_9b6660cbbe84b8af ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9b6660cbbe84b8af ?thing ?location))
        (shared_p_consensus_6222018a35ad9de9 ?taker ?thing)
      )
  )

  (:action human_4d95b598471c21ee_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?caster)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_book ?book)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_9b6660cbbe84b8af ?caster ?location)
          (shared_p_consensus_9b6660cbbe84b8af ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (shared_p_consensus_6222018a35ad9de9 ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
  )

  (:action fused_a_consensus_dee1cd495b90b50f
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_character ?m0)
          (human_3cd8b87ba572801b_type_location ?m1)
          (human_3cd8b87ba572801b_type_location ?m2)
          (and
            (shared_p_consensus_9b6660cbbe84b8af ?m0 ?m1)
            (human_3cd8b87ba572801b_p_alive ?m0)
            (not (= ?m1 ?m2))
          )
        )
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?m0)
          (human_4d95b598471c21ee_type_location ?m2)
          (human_4d95b598471c21ee_type_location ?m1)
          (and
            (human_4d95b598471c21ee_p_connected ?m2 ?m1)
            (not (human_4d95b598471c21ee_p_asleep ?m0))
            (shared_p_consensus_9b6660cbbe84b8af ?m0 ?m1)
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_9b6660cbbe84b8af ?m0 ?m2)
        (not (shared_p_consensus_9b6660cbbe84b8af ?m0 ?m1))
      )
  )
)
