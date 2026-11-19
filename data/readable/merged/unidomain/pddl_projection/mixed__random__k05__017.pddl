(define (domain revised_merged)
  (:requirements :adl :typing :equality)
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
    (tiny_stories__story_073_active)
    (tiny_stories__story_073_type_character ?x - object)
    (tiny_stories__story_073_type_object ?x - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (helping ?p0 ?p1)
    (scared ?p0)
    (spider-on-wall)
    (cake-made)
    (sad ?p0)
    (happy ?p0)
    (has ?p0 ?p1)
    (at ?p0 ?p1)
    (president ?p0)
    (speaker ?p0)
    (vice-president ?p0)
    (belongs-to ?p0 ?p1)
    (economy-collapsed)
    (real-estate-monopoly)
    (planned-parenthood-defunded)
    (planned-parenthood-shutdown)
    (planned-parenthood-criminalized)
    (prison-population-increased)
    (political-prisoner ?p0)
    (player ?p0)
    (asleep ?p0)
    (connected ?p0 ?p1)
    (enchanted ?p0)
    (is ?p0 ?p1)
    (play-chess ?p0 ?p1)
    (feel-better ?p0)
    (sit-together ?p0 ?p1)
    (sick ?p0)
  )

  (:action see-spider
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?character)
        )
        (and
          (not (scared ?character))
          (not (spider-on-wall))
        )
      )
    :effect
      (and
        (scared ?character)
        (spider-on-wall)
      )
  )

  (:action remove-spider
    :parameters (?character ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?helpee)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?helpee)
        )
        (and
          (spider-on-wall)
          (helping ?character ?helpee)
        )
      )
    :effect
      (not (spider-on-wall))
  )

  (:action help
    :parameters (?helper ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?helper)
          (tiny_stories__story_086_type_character ?helpee)
          (tiny_stories__story_086_type_character ?helper)
          (tiny_stories__story_086_type_character ?helpee)
        )
        (and
          (not (= ?helper ?helpee))
          (scared ?helpee)
        )
      )
    :effect
      (and
        (not (scared ?helpee))
        (happy ?helpee)
        (helping ?helper ?helpee)
      )
  )

  (:action make-cake
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_086_active)
          (tiny_stories__story_086_type_character ?character)
          (tiny_stories__story_086_type_character ?character)
        )
        (and
          (not (cake-made))
          (happy ?character)
        )
      )
    :effect
      (cake-made)
  )

  (:action take-toy
    :parameters (?taker ?victim ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (not (= ?taker ?victim))
          (has ?victim ?item)
          (not (has ?taker ?item))
        )
      )
    :effect
      (and
        (not (has ?victim ?item))
        (has ?taker ?item)
        (sad ?victim)
      )
  )

  (:action receive-gift
    :parameters (?receiver ?giver ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (not (= ?receiver ?giver))
          (happy ?giver)
          (not (has ?receiver ?item))
          (has ?giver ?item)
        )
      )
    :effect
      (and
        (has ?receiver ?item)
        (happy ?receiver)
      )
  )

  (:action play
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (has ?character ?item)
          (not (sad ?character))
        )
      )
    :effect
      (happy ?character)
  )

  (:action lose-toy
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?item)
        )
        (and
          (has ?character ?item)
          (happy ?character)
        )
      )
    :effect
      (and
        (not (has ?character ?item))
        (sad ?character)
      )
  )

  (:action introduce-president
    :parameters (?speaker ?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?speaker)
          (writing_prompts__wp_075_type_character ?president)
        )
        (and
          (speaker ?speaker)
          (president ?president)
        )
      )
    :effect
      (and)
  )

  (:action get-sick
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_073_active)
          (tiny_stories__story_073_type_character ?character)
          (tiny_stories__story_073_type_character ?character)
        )
        (and)
      )
    :effect
      (sick ?character)
  )

  (:action feel-better
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_073_active)
          (tiny_stories__story_073_type_character ?character)
          (tiny_stories__story_073_type_character ?character)
        )
        (sick ?character)
      )
    :effect
      (not (sick ?character))
  )

  (:action sit-together
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_073_active)
          (tiny_stories__story_073_type_character ?character1)
          (tiny_stories__story_073_type_character ?character2)
          (tiny_stories__story_073_type_character ?character1)
          (tiny_stories__story_073_type_character ?character2)
        )
        (not (= ?character1 ?character2))
      )
    :effect
      (sit-together ?character1 ?character2)
  )

  (:action play-chess
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_073_active)
          (tiny_stories__story_073_type_character ?character1)
          (tiny_stories__story_073_type_character ?character2)
          (tiny_stories__story_073_type_character ?character1)
          (tiny_stories__story_073_type_character ?character2)
        )
        (and
          (not (sick ?character1))
          (not (sick ?character2))
          (not (= ?character1 ?character2))
          (sit-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (play-chess ?character1 ?character2)
        (happy ?character1)
        (happy ?character2)
      )
  )

  (:action announce-state-of-the-union
    :parameters (?president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?president)
          (writing_prompts__wp_075_type_character ?president)
        )
        (president ?president)
      )
    :effect
      (and)
  )

  (:action attend-state-of-the-union
    :parameters (?vice-president)
    :precondition
      (and
        (and
          (writing_prompts__wp_075_active)
          (writing_prompts__wp_075_type_character ?vice-president)
          (writing_prompts__wp_075_type_character ?vice-president)
        )
        (vice-president ?vice-president)
      )
    :effect
      (and)
  )

  (:action move-location
    :parameters (?character ?to ?from)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?character)
          (human_4d95b598471c21ee_type_location ?to)
          (human_4d95b598471c21ee_type_location ?from)
          (human_4d95b598471c21ee_type_character ?character)
          (human_4d95b598471c21ee_type_location ?to)
          (human_4d95b598471c21ee_type_location ?from)
        )
        (and
          (connected ?to ?from)
          (not (asleep ?character))
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action wake-person
    :parameters (?waker ?woken ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?waker)
          (human_4d95b598471c21ee_type_character ?woken)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?waker)
          (human_4d95b598471c21ee_type_character ?woken)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?waker ?location)
          (at ?woken ?location)
          (asleep ?woken)
          (not (asleep ?waker))
        )
      )
    :effect
      (not (asleep ?woken))
  )

  (:action take-thing
    :parameters (?taker ?thing ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?taker)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?taker)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?taker ?location)
          (at ?thing ?location)
          (not (asleep ?taker))
          (not (enchanted ?thing))
        )
      )
    :effect
      (and
        (not (at ?thing ?location))
        (has ?taker ?thing)
      )
  )

  (:action disenchant-thing
    :parameters (?caster ?thing ?book ?location)
    :precondition
      (and
        (and
          (human_4d95b598471c21ee_active)
          (human_4d95b598471c21ee_type_character ?caster)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_book ?book)
          (human_4d95b598471c21ee_type_location ?location)
          (human_4d95b598471c21ee_type_character ?caster)
          (human_4d95b598471c21ee_type_item ?thing)
          (human_4d95b598471c21ee_type_book ?book)
          (human_4d95b598471c21ee_type_location ?location)
        )
        (and
          (at ?caster ?location)
          (at ?thing ?location)
          (not (asleep ?caster))
          (has ?caster ?book)
          (enchanted ?thing)
        )
      )
    :effect
      (not (enchanted ?thing))
  )
)
