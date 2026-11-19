(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
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
    (human_4d95b598471c21ee_p_at ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_has ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (tiny_stories__story_017_active)
    (tiny_stories__story_017_type_character ?x - object)
    (tiny_stories__story_017_type_object ?x - object)
    (tiny_stories__story_017_p_watches-tv ?v0 - object)
    (tiny_stories__story_017_p_happy ?v0 - object)
    (tiny_stories__story_017_p_rude ?v0 - object)
    (tiny_stories__story_017_p_nice ?v0 - object)
    (tiny_stories__story_017_p_wants-to-watch-tv ?v0 - object)
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (tiny_stories__story_022_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_foggy ?v0 - object)
    (tiny_stories__story_022_p_found ?v0 - object)
    (tiny_stories__story_022_p_happy ?v0 - object)
    (tiny_stories__story_022_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_065_active)
    (writing_prompts__wp_065_type_bunker ?x - object)
    (writing_prompts__wp_065_type_character ?x - object)
    (writing_prompts__wp_065_type_god ?x - object)
    (writing_prompts__wp_065_type_object ?x - object)
    (writing_prompts__wp_065_type_place ?x - object)
    (writing_prompts__wp_065_p_in-bunker ?v0 - object ?v1 - object)
    (writing_prompts__wp_065_p_alive ?v0 - object)
    (writing_prompts__wp_065_p_has-followers ?v0 - object)
    (writing_prompts__wp_065_p_launching-bombs ?v0 - object)
    (writing_prompts__wp_065_p_disease-spreading)
    (writing_prompts__wp_065_p_bombs-launched)
  )
  (:axiom :vars (?character - object ?bunker - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (writing_prompts__wp_065_type_bunker ?bunker) (and (writing_prompts__wp_065_p_in-bunker ?character ?bunker) (writing_prompts__wp_065_p_disease-spreading))) :implies (not (writing_prompts__wp_065_p_alive ?character)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_065_active) (writing_prompts__wp_065_type_character ?character) (and (writing_prompts__wp_065_p_bombs-launched) (forall (?bunker - object) (or (not (writing_prompts__wp_065_type_bunker ?bunker)) (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker)))))) :implies (not (writing_prompts__wp_065_p_alive ?character)))

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (human_4d95b598471c21ee_p_connected ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (human_4d95b598471c21ee_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?character ?from))
        (human_4d95b598471c21ee_p_at ?character ?to)
      )
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
          (human_4d95b598471c21ee_p_at ?waker ?location)
          (human_4d95b598471c21ee_p_at ?woken ?location)
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
          (human_4d95b598471c21ee_p_at ?taker ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?thing ?location))
        (human_4d95b598471c21ee_p_has ?taker ?thing)
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
          (human_4d95b598471c21ee_p_at ?caster ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (human_4d95b598471c21ee_p_has ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
  )

  (:action tiny_stories__story_017_a_start-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_wants-to-watch-tv ?character)
      )
    :effect
      (tiny_stories__story_017_p_watches-tv ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_stop-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_watches-tv ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_watches-tv ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_rude ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_rude ?character))
        (tiny_stories__story_017_p_nice ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-rude
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_nice ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_nice ?character))
        (tiny_stories__story_017_p_rude ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
      )
    :effect
      (tiny_stories__story_017_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-unhappy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_happy ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_happy ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_place ?from)
        (tiny_stories__story_022_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_022_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_022_p_at ?character ?from))
        (tiny_stories__story_022_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_search
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_item ?item)
        (tiny_stories__story_022_type_place ?place)
        (and
          (tiny_stories__story_022_p_at ?character ?place)
          (not (tiny_stories__story_022_p_found ?item))
        )
      )
    :effect
      (when
        (not (tiny_stories__story_022_p_foggy ?place))
        (and
          (tiny_stories__story_022_p_found ?item)
          (tiny_stories__story_022_p_has ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character1)
        (tiny_stories__story_022_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_022_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_022_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
      )
    :effect
      (tiny_stories__story_022_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_clear-fog
    :parameters (?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_place ?place)
        (tiny_stories__story_022_p_foggy ?place)
      )
    :effect
      (not (tiny_stories__story_022_p_foggy ?place))
  )

  (:action writing_prompts__wp_065_a_enter-bunker
    :parameters (?character - object ?bunker - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (writing_prompts__wp_065_type_bunker ?bunker)
        (and
          (writing_prompts__wp_065_p_alive ?character)
          (not (writing_prompts__wp_065_p_in-bunker ?character ?bunker))
        )
      )
    :effect
      (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_launch-bombs
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (writing_prompts__wp_065_type_character ?character)
        (and
          (writing_prompts__wp_065_p_alive ?character)
          (exists
            (?bunker - object)
            (and
              (writing_prompts__wp_065_type_bunker ?bunker)
              (writing_prompts__wp_065_p_in-bunker ?character ?bunker)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_launching-bombs ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_065_a_spread-disease
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (not (writing_prompts__wp_065_p_disease-spreading))
      )
    :effect
      (writing_prompts__wp_065_p_disease-spreading)
  )

  (:action writing_prompts__wp_065_a_bombs-launched
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_065_active)
        (exists
          (?character - object)
          (and
            (writing_prompts__wp_065_type_character ?character)
            (writing_prompts__wp_065_p_launching-bombs ?character)
          )
        )
      )
    :effect
      (writing_prompts__wp_065_p_bombs-launched)
  )
)
