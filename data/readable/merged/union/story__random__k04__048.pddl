(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (tiny_stories__story_098_p_sailor ?v0 - object)
    (tiny_stories__story_098_p_nice ?v0 - object)
    (tiny_stories__story_098_p_sailing ?v0 - object)
    (tiny_stories__story_098_p_together ?v0 - object ?v1 - object)
    (tiny_stories__story_098_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_awake ?v0 - object)
    (writing_prompts__wp_029_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
    (writing_prompts__wp_061_active)
    (writing_prompts__wp_061_type_character ?x - object)
    (writing_prompts__wp_061_type_object ?x - object)
    (writing_prompts__wp_061_p_alive ?v0 - object)
    (writing_prompts__wp_061_p_fan ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_vote ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_win ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))

  (:action tiny_stories__story_098_a_learn-to-sail
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_sailor ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?helper)
        (tiny_stories__story_098_type_character ?helpee)
        (not (= ?helper ?helpee))
      )
    :effect
      (tiny_stories__story_098_p_helping ?helper ?helpee)
    :agents (?helper ?helpee)
  )

  (:action tiny_stories__story_098_a_sail-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character1)
        (tiny_stories__story_098_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_098_p_sailor ?character1)
          (tiny_stories__story_098_p_sailor ?character2)
        )
      )
    :effect
      (tiny_stories__story_098_p_together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_098_a_thank
    :parameters (?thanker - object ?thankee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?thanker)
        (tiny_stories__story_098_type_character ?thankee)
        (not (= ?thanker ?thankee))
      )
    :effect
      (tiny_stories__story_098_p_nice ?thanker)
    :agents (?thanker)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )

  (:action writing_prompts__wp_029_a_sleep
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_awake ?character))
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_asleep ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_asleep ?character))
        (writing_prompts__wp_029_p_awake ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_029_a_install-soundproof-door
    :parameters (?gang - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_type_place ?place)
        (and
          (writing_prompts__wp_029_p_awake ?gang)
          (writing_prompts__wp_029_p_at ?gang ?place)
          (not (writing_prompts__wp_029_p_soundproof-door ?place))
        )
      )
    :effect
      (writing_prompts__wp_029_p_soundproof-door ?place)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_rob
    :parameters (?gang - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?gang)
        (writing_prompts__wp_029_p_awake ?gang)
      )
    :effect
      (writing_prompts__wp_029_p_robbed ?gang)
    :agents (?gang)
  )

  (:action writing_prompts__wp_029_a_attack
    :parameters (?attacker - object ?victim - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?attacker)
        (writing_prompts__wp_029_type_character ?victim)
        (and
          (writing_prompts__wp_029_p_awake ?attacker)
          (writing_prompts__wp_029_p_awake ?victim)
        )
      )
    :effect
      (writing_prompts__wp_029_p_attacked ?victim)
    :agents (?attacker)
  )

  (:action writing_prompts__wp_029_a_clear-passage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_029_active)
        (writing_prompts__wp_029_type_character ?character)
        (writing_prompts__wp_029_p_awake ?character)
      )
    :effect
      (and
        (not (writing_prompts__wp_029_p_attacked ?character))
        (writing_prompts__wp_029_p_has-hoard ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_061_a_read-story
    :parameters (?reader - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?reader)
        (writing_prompts__wp_061_type_object ?story)
        (writing_prompts__wp_061_p_alive ?reader)
      )
    :effect
      (writing_prompts__wp_061_p_read ?reader ?story)
    :agents (?reader)
  )

  (:action writing_prompts__wp_061_a_vote-for-story
    :parameters (?voter - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?voter)
        (writing_prompts__wp_061_type_object ?story)
        (and
          (writing_prompts__wp_061_p_alive ?voter)
          (writing_prompts__wp_061_p_read ?voter ?story)
        )
      )
    :effect
      (writing_prompts__wp_061_p_vote ?voter ?story)
    :agents (?voter)
  )

  (:action writing_prompts__wp_061_a_story-wins
    :parameters (?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_object ?story)
        (exists
          (?voter - object)
          (and
            (writing_prompts__wp_061_type_character ?voter)
            (writing_prompts__wp_061_p_vote ?voter ?story)
          )
        )
      )
    :effect
      (writing_prompts__wp_061_p_win ?story)
  )

  (:action writing_prompts__wp_061_a_become-fan
    :parameters (?fan - object ?idol - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?fan)
        (writing_prompts__wp_061_type_character ?idol)
        (and
          (writing_prompts__wp_061_p_alive ?fan)
          (writing_prompts__wp_061_p_alive ?idol)
          (not (= ?fan ?idol))
        )
      )
    :effect
      (writing_prompts__wp_061_p_fan ?fan ?idol)
    :agents (?fan)
  )
)
