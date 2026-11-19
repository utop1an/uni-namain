(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
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
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_happy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
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
    (writing_prompts__wp_043_active)
    (writing_prompts__wp_043_type_character ?x - object)
    (writing_prompts__wp_043_type_object ?x - object)
    (writing_prompts__wp_043_type_place ?x - object)
    (writing_prompts__wp_043_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_043_p_alive ?v0 - object)
    (writing_prompts__wp_043_p_discovered ?v0 - object)
    (writing_prompts__wp_043_p_knows-about ?v0 - object ?v1 - object)
    (writing_prompts__wp_043_p_is-ceo ?v0 - object)
    (writing_prompts__wp_043_p_is-alien ?v0 - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (writing_prompts__wp_075_p_president ?v0 - object)
    (writing_prompts__wp_075_p_speaker ?v0 - object)
    (writing_prompts__wp_075_p_vice-president ?v0 - object)
    (writing_prompts__wp_075_p_belongs-to ?v0 - object ?v1 - object)
    (writing_prompts__wp_075_p_economy-collapsed)
    (writing_prompts__wp_075_p_real-estate-monopoly)
    (writing_prompts__wp_075_p_planned-parenthood-defunded)
    (writing_prompts__wp_075_p_planned-parenthood-shutdown)
    (writing_prompts__wp_075_p_planned-parenthood-criminalized)
    (writing_prompts__wp_075_p_prison-population-increased)
    (writing_prompts__wp_075_p_political-prisoner ?v0 - object)
  )

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

  (:action tiny_stories__story_100_a_start-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_bored ?character)
          (not (tiny_stories__story_100_p_rolling ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_bored ?character))
        (tiny_stories__story_100_p_rolling ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_stop-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_rolling ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_rolling ?character))
        (tiny_stories__story_100_p_dizzy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_lie-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_dizzy ?character)
          (not (tiny_stories__story_100_p_lying-down ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_dizzy ?character))
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_get-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_lying-down ?character))
        (tiny_stories__story_100_p_happy ?character)
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

  (:action writing_prompts__wp_043_a_discover
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?character)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?character)
          (writing_prompts__wp_043_p_at ?character ?place)
          (not (writing_prompts__wp_043_p_discovered ?place))
        )
      )
    :effect
      (writing_prompts__wp_043_p_discovered ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_043_a_learn
    :parameters (?learner - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?learner)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?learner)
          (writing_prompts__wp_043_p_discovered ?place)
        )
      )
    :effect
      (writing_prompts__wp_043_p_knows-about ?learner ?place)
    :agents (?learner)
  )

  (:action writing_prompts__wp_043_a_hold-press-conference
    :parameters (?speaker - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?speaker)
        (writing_prompts__wp_043_type_place ?place)
        (and
          (writing_prompts__wp_043_p_alive ?speaker)
          (writing_prompts__wp_043_p_is-ceo ?speaker)
          (writing_prompts__wp_043_p_knows-about ?speaker ?place)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?place)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_043_a_reveal
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_043_active)
        (writing_prompts__wp_043_type_character ?alien)
        (and
          (writing_prompts__wp_043_p_alive ?alien)
          (writing_prompts__wp_043_p_is-alien ?alien)
        )
      )
    :effect
      (forall
        (?listener - object)
        (when
          (writing_prompts__wp_043_type_character ?listener)
          (writing_prompts__wp_043_p_knows-about ?listener ?alien)
        )
      )
    :agents (?alien)
  )

  (:action writing_prompts__wp_075_a_announce-state-of-the-union
    :parameters (?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?president)
        (writing_prompts__wp_075_p_president ?president)
      )
    :agents (?president)
  )

  (:action writing_prompts__wp_075_a_introduce-president
    :parameters (?speaker - object ?president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?speaker)
        (writing_prompts__wp_075_type_character ?president)
        (and
          (writing_prompts__wp_075_p_speaker ?speaker)
          (writing_prompts__wp_075_p_president ?president)
        )
      )
    :agents (?speaker)
  )

  (:action writing_prompts__wp_075_a_attend-state-of-the-union
    :parameters (?vice-president - object)
    :precondition
      (and
        (writing_prompts__wp_075_active)
        (writing_prompts__wp_075_type_character ?vice-president)
        (writing_prompts__wp_075_p_vice-president ?vice-president)
      )
    :agents (?vice-president)
  )
)
