(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (writing_prompts__wp_038_active)
    (writing_prompts__wp_038_type_character ?x - object)
    (writing_prompts__wp_038_type_object ?x - object)
    (writing_prompts__wp_038_type_place ?x - object)
    (writing_prompts__wp_038_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_alive ?v0 - object)
    (writing_prompts__wp_038_p_abducted ?v0 - object)
    (writing_prompts__wp_038_p_has-translator ?v0 - object)
    (writing_prompts__wp_038_p_knows-mistake ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_playing-game ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (writing_prompts__wp_096_p_performing ?v0 - object)
    (writing_prompts__wp_096_p_applause)
    (writing_prompts__wp_096_p_satisfied ?v0 - object)
    (writing_prompts__wp_096_p_disappeared ?v0 - object)
    (writing_prompts__wp_096_p_trick-performed)
  )

  (:action writing_prompts__wp_038_a_abduct
    :parameters (?abductor - object ?abductee - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?abductor)
        (writing_prompts__wp_038_type_character ?abductee)
        (writing_prompts__wp_038_type_place ?place)
        (and
          (not (= ?abductor ?abductee))
          (writing_prompts__wp_038_p_alive ?abductor)
          (writing_prompts__wp_038_p_at ?abductor ?place)
          (writing_prompts__wp_038_p_alive ?abductee)
          (writing_prompts__wp_038_p_at ?abductee ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_038_p_abducted ?abductee)
        (not (writing_prompts__wp_038_p_at ?abductee ?place))
      )
    :agents (?abductor)
  )

  (:action writing_prompts__wp_038_a_give-translator
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?giver)
        (writing_prompts__wp_038_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_038_p_alive ?giver)
          (writing_prompts__wp_038_p_alive ?receiver)
          (writing_prompts__wp_038_p_abducted ?receiver)
        )
      )
    :effect
      (writing_prompts__wp_038_p_has-translator ?receiver)
    :agents (?giver)
  )

  (:action writing_prompts__wp_038_a_reveal-mistake
    :parameters (?mistaken - object ?informed - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?mistaken)
        (writing_prompts__wp_038_type_character ?informed)
        (and
          (not (= ?mistaken ?informed))
          (writing_prompts__wp_038_p_alive ?mistaken)
          (writing_prompts__wp_038_p_alive ?informed)
          (writing_prompts__wp_038_p_has-translator ?informed)
        )
      )
    :effect
      (writing_prompts__wp_038_p_knows-mistake ?informed ?mistaken)
    :agents (?mistaken)
  )

  (:action writing_prompts__wp_038_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_has-translator ?character1)
        )
      )
    :effect
      (writing_prompts__wp_038_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_play-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_stop-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_038_p_alive ?character1)
          (writing_prompts__wp_038_p_alive ?character2)
          (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
        )
      )
    :effect
      (not (writing_prompts__wp_038_p_playing-game ?character1 ?character2))
    :agents (?character1 ?character2)
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
