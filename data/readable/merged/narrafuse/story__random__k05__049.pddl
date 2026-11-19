(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (tiny_stories__story_092_p_worried ?v0 - object)
    (tiny_stories__story_092_p_accepted-to-university ?v0 - object)
    (tiny_stories__story_092_p_happy ?v0 - object)
    (tiny_stories__story_092_p_applauding ?v0 - object)
    (tiny_stories__story_092_p_hardworking ?v0 - object)
    (tiny_stories__story_092_p_dreams-come-true ?v0 - object)
    (writing_prompts__wp_029_active)
    (writing_prompts__wp_029_type_character ?x - object)
    (writing_prompts__wp_029_type_gang ?x - object)
    (writing_prompts__wp_029_type_object ?x - object)
    (writing_prompts__wp_029_type_place ?x - object)
    (writing_prompts__wp_029_p_asleep ?v0 - object)
    (writing_prompts__wp_029_p_awake ?v0 - object)
    (shared_p_consensus_74ea7f715486cf22 ?v0 - object ?v1 - object)
    (writing_prompts__wp_029_p_has-hoard ?v0 - object)
    (writing_prompts__wp_029_p_robbed ?v0 - object)
    (writing_prompts__wp_029_p_soundproof-door ?v0 - object)
    (writing_prompts__wp_029_p_attacked ?v0 - object)
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_032_type_character ?x - object)
    (writing_prompts__wp_032_type_item ?x - object)
    (writing_prompts__wp_032_type_object ?x - object)
    (writing_prompts__wp_032_type_place ?x - object)
    (writing_prompts__wp_032_type_weapon ?x - object)
    (shared_p_consensus_8cfd149986ad139a ?v0 - object)
    (writing_prompts__wp_032_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_032_p_wolves-attack ?v0 - object)
    (writing_prompts__wp_032_p_wolves-killed ?v0 - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (writing_prompts__wp_044_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_p_imprisoned ?v0 - object)
    (writing_prompts__wp_044_p_served-sentence ?v0 - object)
    (writing_prompts__wp_044_p_has-serum ?v0 - object)
    (writing_prompts__wp_044_p_religious ?v0 - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (writing_prompts__wp_096_p_performing ?v0 - object)
    (writing_prompts__wp_096_p_applause)
    (writing_prompts__wp_096_p_satisfied ?v0 - object)
    (writing_prompts__wp_096_p_disappeared ?v0 - object)
    (writing_prompts__wp_096_p_trick-performed)
  )

  (:action tiny_stories__story_092_a_get-accepted
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_worried ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_092_p_accepted-to-university ?character)
        (not (tiny_stories__story_092_p_worried ?character))
        (tiny_stories__story_092_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_start-applauding
    :parameters (?character - object ?other - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_type_character ?other)
        (and
          (not (tiny_stories__story_092_p_applauding ?character))
          (tiny_stories__story_092_p_happy ?other)
        )
      )
    :effect
      (tiny_stories__story_092_p_applauding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_stop-applauding
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_p_applauding ?character)
      )
    :effect
      (not (tiny_stories__story_092_p_applauding ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_make-dreams-come-true
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_accepted-to-university ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (tiny_stories__story_092_p_dreams-come-true ?character)
    :agents (?character)
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
          (shared_p_consensus_74ea7f715486cf22 ?gang ?place)
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

  (:action writing_prompts__wp_032_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?from)
        (writing_prompts__wp_032_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_8cfd149986ad139a ?character)
          (shared_p_consensus_74ea7f715486cf22 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_74ea7f715486cf22 ?character ?from))
        (shared_p_consensus_74ea7f715486cf22 ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_kill-wolves
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (writing_prompts__wp_032_type_place ?place)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (shared_p_consensus_74ea7f715486cf22 ?character ?place)
          (writing_prompts__wp_032_p_wolves-attack ?place)
        )
      )
    :effect
      (writing_prompts__wp_032_p_wolves-killed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_032_a_die
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_032_active)
        (writing_prompts__wp_032_type_character ?character)
        (shared_p_consensus_8cfd149986ad139a ?character)
      )
    :effect
      (not (shared_p_consensus_8cfd149986ad139a ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_take-serum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (not (writing_prompts__wp_044_p_has-serum ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_has-serum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_serve-sentence
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (not (writing_prompts__wp_044_p_served-sentence ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_served-sentence ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_release
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (writing_prompts__wp_044_p_served-sentence ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_imprisoned ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_convert
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (not (writing_prompts__wp_044_p_religious ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_religious ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_abandon-religion
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (shared_p_consensus_8cfd149986ad139a ?character)
          (writing_prompts__wp_044_p_religious ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_religious ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_096_a_perform-show
    :parameters (?magician - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?magician)
        (not (writing_prompts__wp_096_p_performing ?magician))
      )
    :effect
      (and
        (writing_prompts__wp_096_p_performing ?magician)
        (writing_prompts__wp_096_p_applause)
      )
    :agents (?magician)
  )

  (:action writing_prompts__wp_096_a_perform-final-trick
    :parameters (?magician - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?magician)
        (and
          (writing_prompts__wp_096_p_performing ?magician)
          (not (writing_prompts__wp_096_p_trick-performed))
        )
      )
    :effect
      (and
        (writing_prompts__wp_096_p_trick-performed)
        (writing_prompts__wp_096_p_disappeared ?magician)
      )
    :agents (?magician)
  )

  (:action writing_prompts__wp_096_a_become-satisfied
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_type_character ?character)
        (and
          (writing_prompts__wp_096_p_performing ?character)
          (writing_prompts__wp_096_p_trick-performed)
          (writing_prompts__wp_096_p_applause)
          (not (writing_prompts__wp_096_p_satisfied ?character))
        )
      )
    :effect
      (writing_prompts__wp_096_p_satisfied ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_096_a_stop-applause
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (writing_prompts__wp_096_p_applause)
      )
    :effect
      (not (writing_prompts__wp_096_p_applause))
  )
)
