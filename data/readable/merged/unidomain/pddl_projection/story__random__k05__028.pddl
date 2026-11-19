(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_080_active)
    (tiny_stories__story_080_type_book ?x - object)
    (tiny_stories__story_080_type_bookshelf ?x - object)
    (tiny_stories__story_080_type_character ?x - object)
    (tiny_stories__story_080_type_item ?x - object)
    (tiny_stories__story_080_type_object ?x - object)
    (writing_prompts__wp_006_active)
    (writing_prompts__wp_006_type_character ?x - object)
    (writing_prompts__wp_006_type_object ?x - object)
    (writing_prompts__wp_006_type_place ?x - object)
    (writing_prompts__wp_023_active)
    (writing_prompts__wp_023_type_character ?x - object)
    (writing_prompts__wp_023_type_object ?x - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (in-love ?p0 ?p1)
    (accepts-past ?p0 ?p1)
    (knows-self ?p0)
    (sings ?p0)
    (alive ?p0)
    (dead ?p0)
    (has-plan ?p0)
    (has-time ?p0)
    (has-idea ?p0)
    (has-tv-show-reference ?p0)
    (has-creative-plan ?p0)
    (has-better-plan ?p0)
    (at ?p0 ?p1)
    (in-box ?p0 ?p1)
    (nervous ?p0)
    (composed ?p0)
    (noticed ?p0 ?p1)
    (opened ?p0)
    (has-skin ?p0)
    (kneel ?p0)
    (rewarded ?p0)
    (tried ?p0)
    (voice-happy ?p0)
    (has ?p0 ?p1)
    (on-shelf ?p0 ?p1)
    (fell-down ?p0)
    (sneezed ?p0)
    (scared ?p0)
    (in-room ?p0)
    (in-kitchen ?p0)
    (likes ?p0 ?p1)
  )
  (:constants tiny_stories__story_031_o_old-house - object)

  (:action sing
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character)
          (writing_prompts__wp_006_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (sings ?character)
  )

  (:action fall-in-love
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (alive ?character1)
          (alive ?character2)
        )
      )
    :effect
      (in-love ?character1 ?character2)
  )

  (:action accept-past
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
          (writing_prompts__wp_006_type_character ?character1)
          (writing_prompts__wp_006_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (alive ?character1)
          (alive ?character2)
        )
      )
    :effect
      (accepts-past ?character1 ?character2)
  )

  (:action know-self
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_006_active)
          (writing_prompts__wp_006_type_character ?character)
          (writing_prompts__wp_006_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (knows-self ?character)
  )

  (:action die
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_023_active)
          (writing_prompts__wp_023_type_character ?character)
          (writing_prompts__wp_023_type_character ?character)
        )
        (and
          (alive ?character)
          (not (has-time ?character))
        )
      )
    :effect
      (dead ?character)
  )

  (:action present-plan
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_023_active)
          (writing_prompts__wp_023_type_character ?character)
          (writing_prompts__wp_023_type_character ?character)
        )
        (and
          (alive ?character)
          (has-plan ?character)
        )
      )
    :effect
      (and
        (has-idea ?character)
        (when
          (has-tv-show-reference ?character)
          (not (has-creative-plan ?character))
        )
      )
  )

  (:action decide-fate
    :parameters (?council ?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_023_active)
          (writing_prompts__wp_023_type_character ?council)
          (writing_prompts__wp_023_type_character ?character)
          (writing_prompts__wp_023_type_character ?council)
          (writing_prompts__wp_023_type_character ?character)
        )
        (and
          (alive ?council)
          (alive ?character)
          (has-idea ?character)
        )
      )
    :effect
      (when
        (has-creative-plan ?character)
        (and
          (has-better-plan ?character)
          (has-time ?character)
        )
      )
  )

  (:action become-nervous
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_character ?character)
        )
        (and)
      )
    :effect
      (nervous ?character)
  )

  (:action become-composed
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_character ?character)
        )
        (and)
      )
    :effect
      (composed ?character)
  )

  (:action try
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (kneel ?character)
      )
    :effect
      (tried ?character)
  )

  (:action reward
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (voice-happy ?character)
      )
    :effect
      (rewarded ?character)
  )

  (:action take-skin
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (and
          (not (voice-happy ?character))
          (has-skin ?character)
        )
      )
    :effect
      (not (has-skin ?character))
  )

  (:action read
    :parameters (?character ?book)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_book ?book)
        )
        (and
          (has ?character ?book)
          (not (fell-down ?book))
        )
      )
    :effect
      (and)
  )

  (:action sneeze
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (and)
      )
    :effect
      (sneezed ?character)
  )

  (:action book-fall
    :parameters (?book ?bookshelf)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_bookshelf ?bookshelf)
          (tiny_stories__story_080_type_book ?book)
          (tiny_stories__story_080_type_bookshelf ?bookshelf)
        )
        (on-shelf ?book ?bookshelf)
      )
    :effect
      (and
        (fell-down ?book)
        (not (on-shelf ?book ?bookshelf))
      )
  )

  (:action get-scared
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (sneezed ?character)
      )
    :effect
      (scared ?character)
  )

  (:action move-to-kitchen
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (in-room ?character)
      )
    :effect
      (and
        (not (in-room ?character))
        (in-kitchen ?character)
      )
  )

  (:action move-to-room
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_080_active)
          (tiny_stories__story_080_type_character ?character)
          (tiny_stories__story_080_type_character ?character)
        )
        (in-kitchen ?character)
      )
    :effect
      (and
        (not (in-kitchen ?character))
        (in-room ?character)
      )
  )

  (:action enter
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_place ?place)
        )
        (not (at ?character ?place))
      )
    :effect
      (at ?character ?place)
  )

  (:action notice
    :parameters (?character ?box ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
        )
        (and
          (at ?character ?place)
          (at ?box ?place)
        )
      )
    :effect
      (noticed ?character ?box)
  )

  (:action open-box
    :parameters (?character ?box ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?place)
        )
        (and
          (at ?character ?place)
          (at ?box ?place)
          (noticed ?character ?box)
          (not (opened ?box))
        )
      )
    :effect
      (opened ?box)
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (or
          (and
            (writing_prompts__wp_006_active)
            (writing_prompts__wp_006_type_character ?character)
            (writing_prompts__wp_006_type_place ?from)
            (writing_prompts__wp_006_type_place ?to)
            (writing_prompts__wp_006_type_character ?character)
            (writing_prompts__wp_006_type_place ?from)
            (writing_prompts__wp_006_type_place ?to)
          )
          (and
            (tiny_stories__story_031_active)
            (tiny_stories__story_031_type_character ?character)
            (tiny_stories__story_031_type_place ?from)
            (tiny_stories__story_031_type_place ?to)
            (tiny_stories__story_031_type_character ?character)
            (tiny_stories__story_031_type_place ?from)
            (tiny_stories__story_031_type_place ?to)
          )
        )
        (and
          (not (= ?from ?to))
          (alive ?character)
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action kneel
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (at ?character tiny_stories__story_031_o_old-house)
      )
    :effect
      (kneel ?character)
  )

  (:action evaluate
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_031_active)
          (tiny_stories__story_031_type_character ?character)
          (tiny_stories__story_031_type_character ?character)
        )
        (tried ?character)
      )
    :effect
      (voice-happy ?character)
  )
)
