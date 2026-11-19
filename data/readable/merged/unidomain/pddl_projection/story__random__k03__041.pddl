(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_074_active)
    (tiny_stories__story_074_type_character ?x - object)
    (tiny_stories__story_074_type_object ?x - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (writing_prompts__wp_084_active)
    (writing_prompts__wp_084_type_character ?x - object)
    (writing_prompts__wp_084_type_object ?x - object)
    (loves ?p0 ?p1)
    (confessed ?p0 ?p1)
    (asked-question ?p0 ?p1)
    (took-pill ?p0)
    (has ?p0 ?p1)
    (happy ?p0)
    (magic ?p0)
    (granted-wish ?p0)
    (at ?p0 ?p1)
    (in-box ?p0 ?p1)
    (nervous ?p0)
    (composed ?p0)
    (noticed ?p0 ?p1)
    (opened ?p0)
  )

  (:action take-pill
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_084_active)
          (writing_prompts__wp_084_type_character ?character)
          (writing_prompts__wp_084_type_character ?character)
        )
        (not (took-pill ?character))
      )
    :effect
      (took-pill ?character)
  )

  (:action ask-love-question
    :parameters (?asker ?asked)
    :precondition
      (and
        (and
          (writing_prompts__wp_084_active)
          (writing_prompts__wp_084_type_character ?asker)
          (writing_prompts__wp_084_type_character ?asked)
          (writing_prompts__wp_084_type_character ?asker)
          (writing_prompts__wp_084_type_character ?asked)
        )
        (not (asked-question ?asker ?asked))
      )
    :effect
      (asked-question ?asker ?asked)
  )

  (:action confess-love
    :parameters (?confessor ?confessed-to)
    :precondition
      (and
        (and
          (writing_prompts__wp_084_active)
          (writing_prompts__wp_084_type_character ?confessor)
          (writing_prompts__wp_084_type_character ?confessed-to)
          (writing_prompts__wp_084_type_character ?confessor)
          (writing_prompts__wp_084_type_character ?confessed-to)
        )
        (and
          (not (confessed ?confessor ?confessed-to))
          (asked-question ?confessed-to ?confessor)
          (took-pill ?confessor)
        )
      )
    :effect
      (and
        (confessed ?confessor ?confessed-to)
        (loves ?confessor ?confessed-to)
      )
  )

  (:action sit-down
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (happy ?character))
      )
    :effect
      (happy ?character)
  )

  (:action share-snack
    :parameters (?sharer ?receiver ?snack)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?sharer)
          (tiny_stories__story_074_type_character ?receiver)
          (tiny_stories__story_074_type_object ?snack)
          (tiny_stories__story_074_type_character ?sharer)
          (tiny_stories__story_074_type_character ?receiver)
        )
        (and
          (has ?sharer ?snack)
          (not (has ?receiver ?snack))
        )
      )
    :effect
      (has ?receiver ?snack)
  )

  (:action become-magic
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (magic ?character))
      )
    :effect
      (magic ?character)
  )

  (:action grant-wish
    :parameters (?granter ?wish)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?granter)
          (tiny_stories__story_074_type_object ?wish)
          (tiny_stories__story_074_type_character ?granter)
        )
        (magic ?granter)
      )
    :effect
      (granted-wish ?wish)
  )

  (:action go-to
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_074_active)
          (tiny_stories__story_074_type_character ?character)
          (tiny_stories__story_074_type_object ?place)
          (tiny_stories__story_074_type_character ?character)
        )
        (not (at ?character ?place))
      )
    :effect
      (at ?character ?place)
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

  (:action enter
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_place ?object)
          (writing_prompts__wp_045_type_character ?character)
        )
        (not (at ?character ?object))
      )
    :effect
      (at ?character ?object)
  )

  (:action notice
    :parameters (?character ?box ?location)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?location)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
        )
        (and
          (at ?character ?location)
          (at ?box ?location)
        )
      )
    :effect
      (noticed ?character ?box)
  )

  (:action open-box
    :parameters (?character ?box ?location)
    :precondition
      (and
        (and
          (writing_prompts__wp_045_active)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
          (writing_prompts__wp_045_type_place ?location)
          (writing_prompts__wp_045_type_character ?character)
          (writing_prompts__wp_045_type_box ?box)
        )
        (and
          (at ?character ?location)
          (at ?box ?location)
          (noticed ?character ?box)
          (not (opened ?box))
        )
      )
    :effect
      (opened ?box)
  )
)
