(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants writing_prompts__wp_001_o_tv - object)
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
    (shared_p_consensus_91581f979bf7d7fc ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_in ?v0 - object ?v1 - object)
    (shared_p_consensus_9a684d2dfaa82367 ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_confined ?v0 - object)
    (shared_p_consensus_fd0fe589a4ac09d1 ?v0 - object)
    (human_3cd8b87ba572801b_p_intends-not-alive ?v0 - object ?v1 - object)
    (human_3cd8b87ba572801b_p_intends-has ?v0 - object ?v1 - object ?v2 - object)
    (human_3cd8b87ba572801b_p_intends-loves ?v0 - object ?v1 - object ?v2 - object)
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (shared_p_consensus_3e9849717e5fed23 ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (tiny_stories__story_028_p_happy ?v0 - object)
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (shared_p_consensus_b74983ba69c28da1 ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_on-top ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_scared ?v0 - object)
    (writing_prompts__wp_001_active)
    (writing_prompts__wp_001_type_character ?x - object)
    (writing_prompts__wp_001_type_item ?x - object)
    (writing_prompts__wp_001_type_object ?x - object)
    (writing_prompts__wp_001_type_place ?x - object)
    (writing_prompts__wp_001_type_weapon ?x - object)
    (writing_prompts__wp_001_p_on ?v0 - object)
    (writing_prompts__wp_001_p_broadcasting ?v0 - object)
    (writing_prompts__wp_001_p_generator-active ?v0 - object)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_alive ?v0 - object)
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
  )
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)) (writing_prompts__wp_001_p_generator-active ?place))) :implies (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv))
  (:axiom :vars (?place - object) :context (and (writing_prompts__wp_001_active) (writing_prompts__wp_001_type_place ?place) (and (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv) (not (writing_prompts__wp_001_p_generator-active ?place)))) :implies (not (writing_prompts__wp_001_p_broadcasting writing_prompts__wp_001_o_tv)))

  (:action human_3cd8b87ba572801b_a_travel
    :parameters (?traveller - object ?from - object ?to - object)
    :precondition
      (and
        (human_3cd8b87ba572801b_active)
        (human_3cd8b87ba572801b_type_character ?traveller)
        (human_3cd8b87ba572801b_type_location ?from)
        (human_3cd8b87ba572801b_type_location ?to)
        (and
          (shared_p_consensus_91581f979bf7d7fc ?traveller ?from)
          (shared_p_consensus_fd0fe589a4ac09d1 ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (shared_p_consensus_91581f979bf7d7fc ?traveller ?to)
        (not (shared_p_consensus_91581f979bf7d7fc ?traveller ?from))
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
          (shared_p_consensus_91581f979bf7d7fc ?slayer ?place)
          (shared_p_consensus_91581f979bf7d7fc ?m ?place)
          (shared_p_consensus_fd0fe589a4ac09d1 ?slayer)
          (shared_p_consensus_fd0fe589a4ac09d1 ?m)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (shared_p_consensus_fd0fe589a4ac09d1 ?m))
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
          (shared_p_consensus_91581f979bf7d7fc ?slayer ?place)
          (shared_p_consensus_91581f979bf7d7fc ?m ?place)
          (shared_p_consensus_fd0fe589a4ac09d1 ?slayer)
          (not (= ?slayer ?m))
          (human_3cd8b87ba572801b_p_intends-not-alive ?slayer ?m)
          (human_3cd8b87ba572801b_p_magic-char ?m)
          (shared_p_consensus_fd0fe589a4ac09d1 ?m)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_fd0fe589a4ac09d1 ?m))
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
          (shared_p_consensus_91581f979bf7d7fc ?pillager ?place)
          (shared_p_consensus_91581f979bf7d7fc ?body ?place)
          (shared_p_consensus_fd0fe589a4ac09d1 ?pillager)
          (not (shared_p_consensus_fd0fe589a4ac09d1 ?body))
          (shared_p_consensus_9a684d2dfaa82367 ?body ?t)
          (not (shared_p_consensus_9a684d2dfaa82367 ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (shared_p_consensus_9a684d2dfaa82367 ?pillager ?t)
        (not (shared_p_consensus_9a684d2dfaa82367 ?body ?t))
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
          (shared_p_consensus_91581f979bf7d7fc ?giver ?place)
          (shared_p_consensus_91581f979bf7d7fc ?givee ?place)
          (shared_p_consensus_fd0fe589a4ac09d1 ?givee)
          (shared_p_consensus_fd0fe589a4ac09d1 ?giver)
          (shared_p_consensus_9a684d2dfaa82367 ?giver ?t)
          (not (shared_p_consensus_9a684d2dfaa82367 ?givee ?t))
          (human_3cd8b87ba572801b_p_intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (shared_p_consensus_9a684d2dfaa82367 ?givee ?t)
        (not (shared_p_consensus_9a684d2dfaa82367 ?giver ?t))
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
          (shared_p_consensus_91581f979bf7d7fc ?char ?place)
          (shared_p_consensus_9a684d2dfaa82367 ?char ?lamp)
          (human_3cd8b87ba572801b_p_in ?g ?lamp)
          (shared_p_consensus_fd0fe589a4ac09d1 ?char)
          (not (= ?char ?g))
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
        )
      )
    :effect
      (and
        (shared_p_consensus_91581f979bf7d7fc ?g ?place)
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
          (shared_p_consensus_fd0fe589a4ac09d1 ?target)
          (shared_p_consensus_fd0fe589a4ac09d1 ?lover)
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
          (shared_p_consensus_fd0fe589a4ac09d1 ?groom)
          (shared_p_consensus_fd0fe589a4ac09d1 ?bride)
          (shared_p_consensus_91581f979bf7d7fc ?groom ?place)
          (shared_p_consensus_91581f979bf7d7fc ?bride ?place)
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
          (shared_p_consensus_91581f979bf7d7fc ?m ?place)
          (shared_p_consensus_91581f979bf7d7fc ?f ?place)
          (human_3cd8b87ba572801b_p_single ?m)
          (shared_p_consensus_fd0fe589a4ac09d1 ?m)
          (shared_p_consensus_fd0fe589a4ac09d1 ?f)
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
          (shared_p_consensus_fd0fe589a4ac09d1 ?kn)
          (shared_p_consensus_fd0fe589a4ac09d1 ?ki)
          (shared_p_consensus_91581f979bf7d7fc ?ki ?place)
          (shared_p_consensus_91581f979bf7d7fc ?kn ?place)
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
          (shared_p_consensus_fd0fe589a4ac09d1 ?m)
          (shared_p_consensus_fd0fe589a4ac09d1 ?char)
          (shared_p_consensus_91581f979bf7d7fc ?m ?place)
          (shared_p_consensus_91581f979bf7d7fc ?char ?place)
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
          (shared_p_consensus_9a684d2dfaa82367 ?char ?lamp)
          (human_3cd8b87ba572801b_p_controls ?char ?g ?lamp)
          (shared_p_consensus_fd0fe589a4ac09d1 ?char)
          (human_3cd8b87ba572801b_p_magic-char ?g)
          (human_3cd8b87ba572801b_p_magic-char-alive)
          (shared_p_consensus_fd0fe589a4ac09d1 ?love)
          (shared_p_consensus_91581f979bf7d7fc ?char ?place)
          (shared_p_consensus_91581f979bf7d7fc ?g ?place)
          (human_3cd8b87ba572801b_p_loves ?char ?love)
          (not (human_3cd8b87ba572801b_p_loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (human_3cd8b87ba572801b_p_intends-loves ?g ?love ?char)
  )

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (shared_p_consensus_9a684d2dfaa82367 ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (shared_p_consensus_9a684d2dfaa82367 ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_put-on-shelf
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (tiny_stories__story_028_type_place ?place)
        (and
          (shared_p_consensus_9a684d2dfaa82367 ?character ?item)
          (shared_p_consensus_3e9849717e5fed23 ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9a684d2dfaa82367 ?character ?item))
        (tiny_stories__story_028_p_on-shelf ?item)
        (tiny_stories__story_028_p_organized ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_read
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_p_reads ?character)
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_smell-soap
    :parameters (?character - object ?soap - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?soap)
        (and
          (tiny_stories__story_028_p_on-shelf ?soap)
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_place ?from)
        (tiny_stories__story_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_91581f979bf7d7fc ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_91581f979bf7d7fc ?character ?from))
        (shared_p_consensus_91581f979bf7d7fc ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_retrieve-toy
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_toy ?toy)
        (tiny_stories__story_040_type_place ?place)
        (and
          (shared_p_consensus_91581f979bf7d7fc ?character ?place)
          (tiny_stories__story_040_p_on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_on-top ?toy ?place))
        (shared_p_consensus_b74983ba69c28da1 ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character1)
        (tiny_stories__story_040_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_040_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_040_a_overcome-fear
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_040_p_scared ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?from)
        (writing_prompts__wp_001_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_fd0fe589a4ac09d1 ?character)
          (shared_p_consensus_3e9849717e5fed23 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_3e9849717e5fed23 ?character ?from))
        (shared_p_consensus_3e9849717e5fed23 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-on
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (shared_p_consensus_fd0fe589a4ac09d1 ?character)
          (shared_p_consensus_b74983ba69c28da1 ?character ?item)
          (not (writing_prompts__wp_001_p_on ?item))
        )
      )
    :effect
      (writing_prompts__wp_001_p_on ?item)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_turn-off
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_item ?item)
        (and
          (shared_p_consensus_fd0fe589a4ac09d1 ?character)
          (shared_p_consensus_b74983ba69c28da1 ?character ?item)
          (writing_prompts__wp_001_p_on ?item)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_on ?item))
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_start-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (shared_p_consensus_fd0fe589a4ac09d1 ?character)
          (shared_p_consensus_3e9849717e5fed23 ?character ?place)
          (not (writing_prompts__wp_001_p_generator-active ?place))
        )
      )
    :effect
      (writing_prompts__wp_001_p_generator-active ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_001_a_stop-generator
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_001_active)
        (writing_prompts__wp_001_type_character ?character)
        (writing_prompts__wp_001_type_place ?place)
        (and
          (shared_p_consensus_fd0fe589a4ac09d1 ?character)
          (shared_p_consensus_3e9849717e5fed23 ?character ?place)
          (writing_prompts__wp_001_p_generator-active ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_001_p_generator-active ?place))
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?character)
        (writing_prompts__wp_040_type_place ?from)
        (writing_prompts__wp_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_040_p_alive ?character)
          (writing_prompts__wp_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_040_p_at ?character ?from))
        (writing_prompts__wp_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_confront
    :parameters (?confronter - object ?confronted - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?confronter)
        (writing_prompts__wp_040_type_character ?confronted)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?confronter ?confronted))
          (writing_prompts__wp_040_p_alive ?confronter)
          (writing_prompts__wp_040_p_at ?confronter ?place)
          (writing_prompts__wp_040_p_alive ?confronted)
          (writing_prompts__wp_040_p_at ?confronted ?place)
        )
      )
    :agents (?confronter)
  )

  (:action writing_prompts__wp_040_a_defeat
    :parameters (?defeater - object ?defeated - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?defeater)
        (writing_prompts__wp_040_type_character ?defeated)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?defeater ?defeated))
          (writing_prompts__wp_040_p_alive ?defeater)
          (writing_prompts__wp_040_p_at ?defeater ?place)
          (writing_prompts__wp_040_p_alive ?defeated)
          (writing_prompts__wp_040_p_at ?defeated ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_040_p_alive ?defeated))
    :agents (?defeater)
  )

  (:action writing_prompts__wp_040_a_show-mercy
    :parameters (?merciful - object ?recipient - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?merciful)
        (writing_prompts__wp_040_type_character ?recipient)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?merciful ?recipient))
          (writing_prompts__wp_040_p_alive ?merciful)
          (writing_prompts__wp_040_p_at ?merciful ?place)
          (not (writing_prompts__wp_040_p_alive ?recipient))
          (writing_prompts__wp_040_p_at ?recipient ?place)
        )
      )
    :effect
      (writing_prompts__wp_040_p_alive ?recipient)
    :agents (?merciful)
  )
)
