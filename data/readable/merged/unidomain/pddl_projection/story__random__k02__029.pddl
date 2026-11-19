(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (writing_prompts__wp_075_active)
    (writing_prompts__wp_075_type_character ?x - object)
    (writing_prompts__wp_075_type_object ?x - object)
    (writing_prompts__wp_075_type_organization ?x - object)
    (sailor ?p0)
    (nice ?p0)
    (sailing ?p0)
    (together ?p0 ?p1)
    (helping ?p0 ?p1)
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
  )

  (:action learn-to-sail
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character)
          (tiny_stories__story_098_type_character ?character)
        )
        (and)
      )
    :effect
      (sailor ?character)
  )

  (:action become-nice
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character)
          (tiny_stories__story_098_type_character ?character)
        )
        (and)
      )
    :effect
      (nice ?character)
  )

  (:action help
    :parameters (?helper ?helpee)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?helper)
          (tiny_stories__story_098_type_character ?helpee)
          (tiny_stories__story_098_type_character ?helper)
          (tiny_stories__story_098_type_character ?helpee)
        )
        (not (= ?helper ?helpee))
      )
    :effect
      (helping ?helper ?helpee)
  )

  (:action sail-together
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?character1)
          (tiny_stories__story_098_type_character ?character2)
          (tiny_stories__story_098_type_character ?character1)
          (tiny_stories__story_098_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (sailor ?character1)
          (sailor ?character2)
        )
      )
    :effect
      (together ?character1 ?character2)
  )

  (:action thank
    :parameters (?thanker ?thankee)
    :precondition
      (and
        (and
          (tiny_stories__story_098_active)
          (tiny_stories__story_098_type_character ?thanker)
          (tiny_stories__story_098_type_character ?thankee)
          (tiny_stories__story_098_type_character ?thanker)
          (tiny_stories__story_098_type_character ?thankee)
        )
        (not (= ?thanker ?thankee))
      )
    :effect
      (nice ?thanker)
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
)
