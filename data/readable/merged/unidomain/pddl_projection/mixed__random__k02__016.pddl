(define (domain revised_merged)
  (:requirements :adl :typing :equality)
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
    (writing_prompts__wp_013_active)
    (writing_prompts__wp_013_type_character ?x - object)
    (writing_prompts__wp_013_type_object ?x - object)
    (bachelor ?p0)
    (bachelor-loves ?p0)
    (loves-bachelor ?p0)
    (magic-char ?p0)
    (controls-magic ?p0 ?p1)
    (magic-char-alive)
    (scary ?p0)
    (single ?p0)
    (beautiful ?p0)
    (magic ?p0)
    (controls ?p0 ?p1 ?p2)
    (married-to ?p0 ?p1)
    (loves ?p0 ?p1)
    (loyal-to ?p0 ?p1)
    (at ?p0 ?p1)
    (in ?p0 ?p1)
    (has ?p0 ?p1)
    (confined ?p0)
    (alive ?p0)
    (intends-not-alive ?p0 ?p1)
    (intends-has ?p0 ?p1 ?p2)
    (intends-loves ?p0 ?p1 ?p2)
    (human ?p0)
    (crow ?p0)
    (in-pain ?p0)
    (sunlight-available)
    (transformed ?p0)
  )

  (:action travel
    :parameters (?traveller ?from ?to)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_character ?traveller)
          (human_3cd8b87ba572801b_type_location ?from)
          (human_3cd8b87ba572801b_type_location ?to)
          (human_3cd8b87ba572801b_type_character ?traveller)
          (human_3cd8b87ba572801b_type_location ?from)
          (human_3cd8b87ba572801b_type_location ?to)
        )
        (and
          (at ?traveller ?from)
          (alive ?traveller)
          (not (= ?from ?to))
        )
      )
    :effect
      (and
        (at ?traveller ?to)
        (not (at ?traveller ?from))
      )
  )

  (:action slay
    :parameters (?slayer ?m ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_knight ?slayer)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_knight ?slayer)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (at ?slayer ?place)
          (at ?m ?place)
          (alive ?slayer)
          (alive ?m)
          (not (= ?slayer ?m))
          (intends-not-alive ?slayer ?m)
        )
      )
    :effect
      (not (alive ?m))
  )

  (:action slay-magic-char
    :parameters (?slayer ?m ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_knight ?slayer)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_knight ?slayer)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (at ?slayer ?place)
          (at ?m ?place)
          (alive ?slayer)
          (not (= ?slayer ?m))
          (intends-not-alive ?slayer ?m)
          (magic-char ?m)
          (alive ?m)
          (magic-char-alive)
        )
      )
    :effect
      (and
        (not (alive ?m))
        (magic-char ?m)
        (not (magic-char-alive))
      )
  )

  (:action pillage
    :parameters (?pillager ?body ?t ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_character ?pillager)
          (human_3cd8b87ba572801b_type_character ?body)
          (human_3cd8b87ba572801b_type_thing ?t)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_character ?pillager)
          (human_3cd8b87ba572801b_type_character ?body)
          (human_3cd8b87ba572801b_type_thing ?t)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (at ?pillager ?place)
          (at ?body ?place)
          (alive ?pillager)
          (not (alive ?body))
          (has ?body ?t)
          (not (has ?pillager ?t))
          (not (= ?pillager ?body))
        )
      )
    :effect
      (and
        (has ?pillager ?t)
        (not (has ?body ?t))
      )
  )

  (:action give
    :parameters (?giver ?givee ?t ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_character ?giver)
          (human_3cd8b87ba572801b_type_character ?givee)
          (human_3cd8b87ba572801b_type_thing ?t)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_character ?giver)
          (human_3cd8b87ba572801b_type_character ?givee)
          (human_3cd8b87ba572801b_type_thing ?t)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (not (= ?giver ?givee))
          (at ?giver ?place)
          (at ?givee ?place)
          (alive ?givee)
          (alive ?giver)
          (has ?giver ?t)
          (not (has ?givee ?t))
          (intends-has ?giver ?givee ?t)
        )
      )
    :effect
      (and
        (has ?givee ?t)
        (not (has ?giver ?t))
      )
  )

  (:action summon
    :parameters (?char ?g ?lamp ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_ismagic ?g)
          (human_3cd8b87ba572801b_type_thing ?lamp)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_ismagic ?g)
          (human_3cd8b87ba572801b_type_thing ?lamp)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (confined ?g)
          (magic ?lamp)
          (at ?char ?place)
          (has ?char ?lamp)
          (in ?g ?lamp)
          (alive ?char)
          (not (= ?char ?g))
          (magic-char ?g)
          (magic-char-alive)
        )
      )
    :effect
      (and
        (at ?g ?place)
        (controls ?char ?g ?lamp)
        (controls-magic ?char ?lamp)
        (not (in ?g ?lamp))
        (not (confined ?g))
      )
  )

  (:action love-spell
    :parameters (?g ?target ?lover)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_genie ?g)
          (human_3cd8b87ba572801b_type_person ?target)
          (human_3cd8b87ba572801b_type_canmarry ?lover)
          (human_3cd8b87ba572801b_type_genie ?g)
          (human_3cd8b87ba572801b_type_person ?target)
          (human_3cd8b87ba572801b_type_canmarry ?lover)
        )
        (and
          (not (confined ?g))
          (not (loves ?target ?lover))
          (magic-char ?g)
          (magic-char-alive)
          (alive ?target)
          (alive ?lover)
          (not (= ?g ?target))
          (not (= ?g ?lover))
          (not (= ?target ?lover))
          (intends-loves ?g ?target ?lover)
          (bachelor ?lover)
        )
      )
    :effect
      (and
        (loves ?target ?lover)
        (loves-bachelor ?target)
      )
  )

  (:action marry
    :parameters (?groom ?bride ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_canmarry ?groom)
          (human_3cd8b87ba572801b_type_person ?bride)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_canmarry ?groom)
          (human_3cd8b87ba572801b_type_person ?bride)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (alive ?groom)
          (alive ?bride)
          (at ?groom ?place)
          (at ?bride ?place)
          (loves ?groom ?bride)
          (loves ?bride ?groom)
          (single ?groom)
          (bachelor ?groom)
          (single ?bride)
          (not (= ?groom ?bride))
        )
      )
    :effect
      (and
        (married-to ?groom ?bride)
        (married-to ?bride ?groom)
        (not (single ?groom))
        (not (single ?bride))
      )
  )

  (:action fall-in-love
    :parameters (?m ?f ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_canmarry ?m)
          (human_3cd8b87ba572801b_type_female ?f)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_canmarry ?m)
          (human_3cd8b87ba572801b_type_female ?f)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (bachelor ?m)
          (at ?m ?place)
          (at ?f ?place)
          (single ?m)
          (alive ?m)
          (alive ?f)
          (not (loves ?m ?f))
          (beautiful ?f)
        )
      )
    :effect
      (and
        (loves ?m ?f)
        (bachelor-loves ?f)
      )
  )

  (:action order
    :parameters (?ki ?kn ?place ?t)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_king ?ki)
          (human_3cd8b87ba572801b_type_knight ?kn)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_thing ?t)
          (human_3cd8b87ba572801b_type_king ?ki)
          (human_3cd8b87ba572801b_type_knight ?kn)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_thing ?t)
        )
        (and
          (loyal-to ?kn ?ki)
          (alive ?kn)
          (alive ?ki)
          (at ?ki ?place)
          (at ?kn ?place)
        )
      )
    :effect
      (intends-has ?kn ?ki ?t)
  )

  (:action appear-threatening
    :parameters (?m ?char ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_monster ?m)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (alive ?m)
          (alive ?char)
          (at ?m ?place)
          (at ?char ?place)
          (scary ?m)
          (not (= ?m ?char))
        )
      )
    :effect
      (intends-not-alive ?char ?m)
  )

  (:action command
    :parameters (?char ?g ?love ?lamp ?place)
    :precondition
      (and
        (and
          (human_3cd8b87ba572801b_active)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_genie ?g)
          (human_3cd8b87ba572801b_type_person ?love)
          (human_3cd8b87ba572801b_type_thing ?lamp)
          (human_3cd8b87ba572801b_type_location ?place)
          (human_3cd8b87ba572801b_type_person ?char)
          (human_3cd8b87ba572801b_type_genie ?g)
          (human_3cd8b87ba572801b_type_person ?love)
          (human_3cd8b87ba572801b_type_thing ?lamp)
          (human_3cd8b87ba572801b_type_location ?place)
        )
        (and
          (magic ?lamp)
          (has ?char ?lamp)
          (controls ?char ?g ?lamp)
          (alive ?char)
          (magic-char ?g)
          (magic-char-alive)
          (alive ?love)
          (at ?char ?place)
          (at ?g ?place)
          (loves ?char ?love)
          (not (loves ?love ?char))
          (not (= ?char ?g))
          (not (= ?char ?love))
        )
      )
    :effect
      (intends-loves ?g ?love ?char)
  )

  (:action experience-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (human ?character)
      )
    :effect
      (in-pain ?character)
  )

  (:action transform-into-crow
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (and
          (human ?character)
          (in-pain ?character)
          (sunlight-available)
        )
      )
    :effect
      (and
        (not (human ?character))
        (crow ?character)
        (transformed ?character)
      )
  )

  (:action transform-back-into-human
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_013_active)
          (writing_prompts__wp_013_type_character ?character)
          (writing_prompts__wp_013_type_character ?character)
        )
        (crow ?character)
      )
    :effect
      (and
        (not (crow ?character))
        (human ?character)
      )
  )
)
