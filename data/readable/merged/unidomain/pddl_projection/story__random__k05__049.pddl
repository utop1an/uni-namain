(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (has ?p0 ?p1)
    (wolves-attack ?p0)
    (wolves-killed ?p0)
    (alive ?p0)
    (imprisoned ?p0)
    (served-sentence ?p0)
    (has-serum ?p0)
    (religious ?p0)
    (at ?p0 ?p1)
    (performing ?p0)
    (applause)
    (satisfied ?p0)
    (disappeared ?p0)
    (trick-performed)
    (worried ?p0)
    (accepted-to-university ?p0)
    (happy ?p0)
    (applauding ?p0)
    (hardworking ?p0)
    (dreams-come-true ?p0)
    (asleep ?p0)
    (awake ?p0)
    (has-hoard ?p0)
    (robbed ?p0)
    (soundproof-door ?p0)
    (attacked ?p0)
  )

  (:action die
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (not (alive ?character))
  )

  (:action take-serum
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (has-serum ?character))
        )
      )
    :effect
      (has-serum ?character)
  )

  (:action serve-sentence
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (not (served-sentence ?character))
        )
      )
    :effect
      (served-sentence ?character)
  )

  (:action release
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (served-sentence ?character)
        )
      )
    :effect
      (not (imprisoned ?character))
  )

  (:action convert
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (religious ?character))
        )
      )
    :effect
      (religious ?character)
  )

  (:action abandon-religion
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (religious ?character)
        )
      )
    :effect
      (not (religious ?character))
  )

  (:action move
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?from)
          (writing_prompts__wp_032_type_place ?to)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?from)
          (writing_prompts__wp_032_type_place ?to)
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

  (:action kill-wolves
    :parameters (?character ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_032_active)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?place)
          (writing_prompts__wp_032_type_character ?character)
          (writing_prompts__wp_032_type_place ?place)
        )
        (and
          (alive ?character)
          (at ?character ?place)
          (wolves-attack ?place)
        )
      )
    :effect
      (wolves-killed ?character)
  )

  (:action perform-show
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (not (performing ?magician))
      )
    :effect
      (and
        (performing ?magician)
        (applause)
      )
  )

  (:action perform-final-trick
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (and
          (performing ?magician)
          (not (trick-performed))
        )
      )
    :effect
      (and
        (trick-performed)
        (disappeared ?magician)
      )
  )

  (:action stop-applause
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (applause)
      )
    :effect
      (not (applause))
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

  (:action sleep
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (awake ?character))
        (asleep ?character)
      )
  )

  (:action wake-up
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (asleep ?character)
      )
    :effect
      (and
        (not (asleep ?character))
        (awake ?character)
      )
  )

  (:action rob
    :parameters (?gang)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_character ?gang)
        )
        (awake ?gang)
      )
    :effect
      (robbed ?gang)
  )

  (:action become-satisfied
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?character)
          (writing_prompts__wp_096_type_character ?character)
        )
        (and
          (performing ?character)
          (trick-performed)
          (applause)
          (not (satisfied ?character))
        )
      )
    :effect
      (satisfied ?character)
  )

  (:action install-soundproof-door
    :parameters (?gang ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
          (writing_prompts__wp_029_type_character ?gang)
          (writing_prompts__wp_029_type_place ?place)
        )
        (and
          (awake ?gang)
          (at ?gang ?place)
          (not (soundproof-door ?place))
        )
      )
    :effect
      (soundproof-door ?place)
  )

  (:action attack
    :parameters (?attacker ?victim)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
          (writing_prompts__wp_029_type_character ?attacker)
          (writing_prompts__wp_029_type_character ?victim)
        )
        (and
          (awake ?attacker)
          (awake ?victim)
        )
      )
    :effect
      (attacked ?victim)
  )

  (:action clear-passage
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_029_active)
          (writing_prompts__wp_029_type_character ?character)
          (writing_prompts__wp_029_type_character ?character)
        )
        (awake ?character)
      )
    :effect
      (and
        (not (attacked ?character))
        (has-hoard ?character)
      )
  )
)
