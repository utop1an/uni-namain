(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_029_active)
    (tiny_stories__story_029_type_character ?x - object)
    (tiny_stories__story_029_type_item ?x - object)
    (tiny_stories__story_029_type_object ?x - object)
    (tiny_stories__story_029_type_place ?x - object)
    (tiny_stories__story_029_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_alive ?v0 - object)
    (tiny_stories__story_029_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_near ?v0 - object ?v1 - object)
    (tiny_stories__story_029_p_in-nest ?v0 - object)
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (tiny_stories__story_038_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_038_p_hiding ?v0 - object)
    (tiny_stories__story_038_p_seeking ?v0 - object)
    (tiny_stories__story_038_p_found ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_029_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_place ?from)
        (tiny_stories__story_029_type_place ?to)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_at ?character ?from)
          (not (tiny_stories__story_029_p_at ?character ?to))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_029_p_at ?character ?from))
        (tiny_stories__story_029_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_has ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_pick-up
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_item ?item)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_near ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_029_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_help-bird
    :parameters (?character - object ?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?character)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?character)
          (tiny_stories__story_029_p_alive ?bird)
          (not (tiny_stories__story_029_p_in-nest ?bird))
        )
      )
    :effect
      (tiny_stories__story_029_p_in-nest ?bird)
    :agents (?character)
  )

  (:action tiny_stories__story_029_a_bird-falls
    :parameters (?bird - object)
    :precondition
      (and
        (tiny_stories__story_029_active)
        (tiny_stories__story_029_type_character ?bird)
        (and
          (tiny_stories__story_029_p_alive ?bird)
          (tiny_stories__story_029_p_in-nest ?bird)
        )
      )
    :effect
      (not (tiny_stories__story_029_p_in-nest ?bird))
  )

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (tiny_stories__story_034_p_has ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_has ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_038_a_start-hiding
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_hiding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_start-seeking
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_seeking ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_find
    :parameters (?seeker - object ?hider - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?seeker)
        (tiny_stories__story_038_type_character ?hider)
        (tiny_stories__story_038_type_place ?place)
        (and
          (tiny_stories__story_038_p_seeking ?seeker)
          (tiny_stories__story_038_p_hiding ?hider)
          (tiny_stories__story_038_p_at ?seeker ?place)
          (tiny_stories__story_038_p_at ?hider ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_038_p_found ?seeker ?hider)
        (not (tiny_stories__story_038_p_hiding ?hider))
      )
    :agents (?seeker)
  )

  (:action tiny_stories__story_038_a_stop-seeking
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_p_seeking ?character)
      )
    :effect
      (not (tiny_stories__story_038_p_seeking ?character))
    :agents (?character)
  )
)
