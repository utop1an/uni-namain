(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (writing_prompts__wp_047_active)
    (writing_prompts__wp_047_type_nation ?x - object)
    (writing_prompts__wp_047_type_object ?x - object)
    (writing_prompts__wp_077_active)
    (writing_prompts__wp_077_type_object ?x - object)
    (writing_prompts__wp_077_type_poem ?x - object)
    (writing_prompts__wp_077_type_reader ?x - object)
    (writing_prompts__wp_084_active)
    (writing_prompts__wp_084_type_character ?x - object)
    (writing_prompts__wp_084_type_object ?x - object)
    (at-peace ?p0)
    (sharing-technology ?p0 ?p1)
    (advanced-technology ?p0)
    (facing-destruction)
    (read ?p0 ?p1)
    (alive ?p0)
    (dead ?p0)
    (echo ?p0 ?p1)
    (loves ?p0 ?p1)
    (confessed ?p0 ?p1)
    (asked-question ?p0 ?p1)
    (took-pill ?p0)
    (at ?p0 ?p1)
    (awake ?p0)
    (friends ?p0 ?p1)
    (interesting ?p0)
    (singing ?p0)
    (worried ?p0)
    (accepted-to-university ?p0)
    (happy ?p0)
    (applauding ?p0)
    (hardworking ?p0)
    (dreams-come-true ?p0)
  )
  (:constants writing_prompts__wp_047_o_nation1 - object writing_prompts__wp_047_o_nation2 - object writing_prompts__wp_047_o_nation3 - object)

  (:action unite
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (facing-destruction)
        )
      )
    :effect
      (and
        (at-peace ?nation1)
        (at-peace ?nation2)
        (sharing-technology ?nation1 ?nation2)
      )
  )

  (:action develop-technology
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (advanced-technology ?nation1)
        (advanced-technology ?nation2)
      )
  )

  (:action avoid-destruction
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_047_active)
        (and
          (advanced-technology writing_prompts__wp_047_o_nation1)
          (advanced-technology writing_prompts__wp_047_o_nation2)
          (advanced-technology writing_prompts__wp_047_o_nation3)
        )
      )
    :effect
      (not (facing-destruction))
  )

  (:action maintain-peace
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_047_active)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
          (writing_prompts__wp_047_type_nation ?nation1)
          (writing_prompts__wp_047_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (at-peace ?nation1)
          (at-peace ?nation2)
          (sharing-technology ?nation1 ?nation2)
        )
      )
    :effect
      (and
        (at-peace ?nation1)
        (at-peace ?nation2)
        (sharing-technology ?nation1 ?nation2)
      )
  )

  (:action read-poem
    :parameters (?reader ?poem)
    :precondition
      (and
        (and
          (writing_prompts__wp_077_active)
          (writing_prompts__wp_077_type_reader ?reader)
          (writing_prompts__wp_077_type_poem ?poem)
          (writing_prompts__wp_077_type_reader ?reader)
          (writing_prompts__wp_077_type_poem ?poem)
        )
        (and
          (not (read ?reader ?poem))
          (alive ?poem)
        )
      )
    :effect
      (and
        (read ?reader ?poem)
        (echo ?reader ?poem)
      )
  )

  (:action poem-dies
    :parameters (?poem)
    :precondition
      (and
        (and
          (writing_prompts__wp_077_active)
          (writing_prompts__wp_077_type_poem ?poem)
          (writing_prompts__wp_077_type_poem ?poem)
        )
        (alive ?poem)
      )
    :effect
      (and
        (not (alive ?poem))
        (dead ?poem)
      )
  )

  (:action echo-poem
    :parameters (?reader ?poem)
    :precondition
      (and
        (and
          (writing_prompts__wp_077_active)
          (writing_prompts__wp_077_type_reader ?reader)
          (writing_prompts__wp_077_type_poem ?poem)
          (writing_prompts__wp_077_type_reader ?reader)
          (writing_prompts__wp_077_type_poem ?poem)
        )
        (and
          (read ?reader ?poem)
          (not (echo ?reader ?poem))
        )
      )
    :effect
      (echo ?reader ?poem)
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

  (:action move
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
        )
        (and
          (awake ?character)
          (not (at ?character ?place))
        )
      )
    :effect
      (at ?character ?place)
  )

  (:action sleep
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_place ?place)
        )
        (and
          (awake ?character)
          (at ?character ?place)
          (interesting ?place)
        )
      )
    :effect
      (not (awake ?character))
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (not (awake ?character))
      )
    :effect
      (awake ?character)
  )

  (:action sing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (singing ?character)
  )

  (:action stop-singing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character)
          (tiny_stories__story_011_type_character ?character)
        )
        (singing ?character)
      )
    :effect
      (not (singing ?character))
  )

  (:action make-friends
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_011_active)
          (tiny_stories__story_011_type_character ?character1)
          (tiny_stories__story_011_type_character ?character2)
          (tiny_stories__story_011_type_character ?character1)
          (tiny_stories__story_011_type_character ?character2)
        )
        (and
          (awake ?character1)
          (awake ?character2)
          (not (friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (friends ?character1 ?character2)
  )

  (:action get-accepted
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (and
          (worried ?character)
          (hardworking ?character)
        )
      )
    :effect
      (and
        (accepted-to-university ?character)
        (not (worried ?character))
        (happy ?character)
      )
  )

  (:action start-applauding
    :parameters (?character ?other)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?other)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?other)
        )
        (and
          (not (applauding ?character))
          (happy ?other)
        )
      )
    :effect
      (applauding ?character)
  )

  (:action stop-applauding
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (applauding ?character)
      )
    :effect
      (not (applauding ?character))
  )

  (:action make-dreams-come-true
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (and
          (accepted-to-university ?character)
          (hardworking ?character)
        )
      )
    :effect
      (dreams-come-true ?character)
  )
)
