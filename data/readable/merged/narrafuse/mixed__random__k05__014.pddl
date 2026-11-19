(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing)
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
    (shared_p_consensus_d427e80e3922ecdf ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_loyal-to ?v0 - object ?v1 - object)
    (shared_p_consensus_c62be62715a7eb1e ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_has ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (shared_p_consensus_d1d801b1e5bcfb2b ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (writing_prompts__wp_007_active)
    (writing_prompts__wp_007_type_item ?x - object)
    (writing_prompts__wp_007_type_object ?x - object)
    (writing_prompts__wp_007_type_room ?x - object)
    (writing_prompts__wp_007_p_occupied ?v0 - object)
    (writing_prompts__wp_007_p_plugged-in ?v0 - object)
    (writing_prompts__wp_007_p_connected ?v0 - object ?v1 - object)
    (writing_prompts__wp_007_p_well-lit ?v0 - object)
    (writing_prompts__wp_007_p_morning)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_active)
    (writing_prompts__wp_084_type_character ?x - object)
    (writing_prompts__wp_084_type_object ?x - object)
    (writing_prompts__wp_084_p_confessed ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_p_asked-question ?v0 - object ?v1 - object)
    (writing_prompts__wp_084_p_took-pill ?v0 - object)
  )

  (:action human_3cd8b87ba572801b_a_travel
    :parameters (?traveller - object ?from - object ?to - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?traveller)
        (human_3cd8b87ba572801b_type_location ?from)
        (human_3cd8b87ba572801b_type_location ?to)
        (and
          (shared_p_consensus_c62be62715a7eb1e ?traveller ?from)
          (shared_p_consensus_d1d801b1e5bcfb2b ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (shared_p_consensus_c62be62715a7eb1e ?traveller ?to)
        (not (shared_p_consensus_c62be62715a7eb1e ?traveller ?from))
      )
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
          (shared_p_consensus_c62be62715a7eb1e ?slayer ?place)
          (shared_p_consensus_c62be62715a7eb1e ?m ?place)
          (shared_p_consensus_d1d801b1e5bcfb2b ?slayer)
          (shared_p_consensus_d1d801b1e5bcfb2b ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (shared_p_consensus_d1d801b1e5bcfb2b ?m))
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
          (shared_p_consensus_c62be62715a7eb1e ?slayer ?place)
          (shared_p_consensus_c62be62715a7eb1e ?m ?place)
          (shared_p_consensus_d1d801b1e5bcfb2b ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (shared_p_consensus_d1d801b1e5bcfb2b ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d1d801b1e5bcfb2b ?m))
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
          (shared_p_consensus_c62be62715a7eb1e ?pillager ?place)
          (shared_p_consensus_c62be62715a7eb1e ?body ?place)
          (shared_p_consensus_d1d801b1e5bcfb2b ?pillager)
          (not (shared_p_consensus_d1d801b1e5bcfb2b ?body))
          (human_3cd8b87ba572801b_p_has ?body ?t)
          (not (human_3cd8b87ba572801b_p_has ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?pillager ?t)
        (not (human_3cd8b87ba572801b_p_has ?body ?t))
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
          (shared_p_consensus_c62be62715a7eb1e ?giver ?place)
          (shared_p_consensus_c62be62715a7eb1e ?givee ?place)
          (shared_p_consensus_d1d801b1e5bcfb2b ?givee)
          (shared_p_consensus_d1d801b1e5bcfb2b ?giver)
          (human_3cd8b87ba572801b_p_has ?giver ?t)
          (not (human_3cd8b87ba572801b_p_has ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (human_3cd8b87ba572801b_p_has ?givee ?t)
        (not (human_3cd8b87ba572801b_p_has ?giver ?t))
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
          (shared_p_consensus_c62be62715a7eb1e ?char ?place)
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (shared_p_consensus_d1d801b1e5bcfb2b ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_c62be62715a7eb1e ?g ?place)
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
          (not (shared_p_consensus_d427e80e3922ecdf ?target ?lover))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_d1d801b1e5bcfb2b ?target)
          (shared_p_consensus_d1d801b1e5bcfb2b ?lover)
          (not (= ?g ?target))
          (not (= ?g ?lover))
          (not (= ?target ?lover))
          (human_3cd8b87ba572801b_p_intends-loves ?g ?target ?lover)
          (human_3cd8b87ba572801b_p_bachelor ?lover)
        )
      )
    :effect
      (and
        (shared_p_consensus_d427e80e3922ecdf ?target ?lover)
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
          (shared_p_consensus_d1d801b1e5bcfb2b ?groom)
          (shared_p_consensus_d1d801b1e5bcfb2b ?bride)
          (shared_p_consensus_c62be62715a7eb1e ?groom ?place)
          (shared_p_consensus_c62be62715a7eb1e ?bride ?place)
          (shared_p_consensus_d427e80e3922ecdf ?groom ?bride)
          (shared_p_consensus_d427e80e3922ecdf ?bride ?groom)
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
          (shared_p_consensus_c62be62715a7eb1e ?m ?place)
          (shared_p_consensus_c62be62715a7eb1e ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (shared_p_consensus_d1d801b1e5bcfb2b ?m)
          (shared_p_consensus_d1d801b1e5bcfb2b ?f)
          (not (shared_p_consensus_d427e80e3922ecdf ?m ?f))
          (human_3cd8b87ba572801b_p_beautiful ?f)
        )
      )
    :effect
      (and
        (shared_p_consensus_d427e80e3922ecdf ?m ?f)
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
          (shared_p_consensus_d1d801b1e5bcfb2b ?kn)
          (shared_p_consensus_d1d801b1e5bcfb2b ?ki)
          (shared_p_consensus_c62be62715a7eb1e ?ki ?place)
          (shared_p_consensus_c62be62715a7eb1e ?kn ?place)
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
          (shared_p_consensus_d1d801b1e5bcfb2b ?m)
          (shared_p_consensus_d1d801b1e5bcfb2b ?char)
          (shared_p_consensus_c62be62715a7eb1e ?m ?place)
          (shared_p_consensus_c62be62715a7eb1e ?char ?place)
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
          (human_3cd8b87ba572801b_p_has ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (shared_p_consensus_d1d801b1e5bcfb2b ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_d1d801b1e5bcfb2b ?love)
          (shared_p_consensus_c62be62715a7eb1e ?char ?place)
          (shared_p_consensus_c62be62715a7eb1e ?g ?place)
          (shared_p_consensus_d427e80e3922ecdf ?char ?love)
          (not (shared_p_consensus_d427e80e3922ecdf ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )

  (:action tiny_stories__story_072_a_go-to-party
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (not (tiny_stories__story_072_p_at-party ?character))
      )
    :effect
      (tiny_stories__story_072_p_at-party ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_magic-trick
    :parameters (?magician - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?magician)
        (and
          (tiny_stories__story_072_p_at-party ?magician)
          (not (tiny_stories__story_072_p_cake-transformed))
        )
      )
    :effect
      (tiny_stories__story_072_p_cake-transformed)
    :agents (?magician)
  )

  (:action tiny_stories__story_072_a_eat-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_cake-transformed)
        )
      )
    :effect
      (tiny_stories__story_072_p_fast ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_fast ?character)
        )
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
          (shared_p_consensus_c62be62715a7eb1e ?item ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c62be62715a7eb1e ?item ?from))
        (shared_p_consensus_c62be62715a7eb1e ?item ?to)
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

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (shared_p_consensus_d1d801b1e5bcfb2b ?character)
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
        (shared_p_consensus_d1d801b1e5bcfb2b ?character)
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
          (shared_p_consensus_d1d801b1e5bcfb2b ?character)
          (shared_p_consensus_d1d801b1e5bcfb2b ?officer)
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
          (shared_p_consensus_d1d801b1e5bcfb2b ?character)
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

  (:action writing_prompts__wp_084_a_take-pill
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?character)
        (not (writing_prompts__wp_084_p_took-pill ?character))
      )
    :effect
      (writing_prompts__wp_084_p_took-pill ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_084_a_ask-love-question
    :parameters (?asker - object ?asked - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?asker)
        (writing_prompts__wp_084_type_character ?asked)
        (not (writing_prompts__wp_084_p_asked-question ?asker ?asked))
      )
    :effect
      (writing_prompts__wp_084_p_asked-question ?asker ?asked)
    :agents (?asker)
  )

  (:action writing_prompts__wp_084_a_confess-love
    :parameters (?confessor - object ?confessed-to - object)
    :precondition
      (and
        (writing_prompts__wp_084_active)
        (writing_prompts__wp_084_type_character ?confessor)
        (writing_prompts__wp_084_type_character ?confessed-to)
        (and
          (not (writing_prompts__wp_084_p_confessed ?confessor ?confessed-to))
          (writing_prompts__wp_084_p_asked-question ?confessed-to ?confessor)
          (writing_prompts__wp_084_p_took-pill ?confessor)
        )
      )
    :effect
      (and
        (writing_prompts__wp_084_p_confessed ?confessor ?confessed-to)
        (shared_p_consensus_d427e80e3922ecdf ?confessor ?confessed-to)
      )
    :agents (?confessor)
  )
)
