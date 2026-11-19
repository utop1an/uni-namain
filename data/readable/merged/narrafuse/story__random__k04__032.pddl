(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_035_o_tim - object)
  (:predicates
    (tiny_stories__story_035_active)
    (tiny_stories__story_035_type_character ?x - object)
    (tiny_stories__story_035_type_object ?x - object)
    (tiny_stories__story_035_p_birthday ?v0 - object)
    (tiny_stories__story_035_p_box-closed)
    (tiny_stories__story_035_p_box-open)
    (tiny_stories__story_035_p_cake-spoiled)
    (tiny_stories__story_035_p_cake-good)
    (tiny_stories__story_035_p_listened-to-mom ?v0 - object)
    (tiny_stories__story_035_p_waited-for-birthday ?v0 - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_alive ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_active)
    (writing_prompts__wp_020_type_character ?x - object)
    (writing_prompts__wp_020_type_object ?x - object)
    (writing_prompts__wp_020_p_hurting ?v0 - object)
    (writing_prompts__wp_020_p_struggling ?v0 - object)
    (writing_prompts__wp_020_p_loved ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_letting-go ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_ready ?v0 - object)
    (writing_prompts__wp_020_p_better-times ?v0 - object)
  )

  (:action tiny_stories__story_035_a_wait-for-birthday
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_birthday ?character))
          (not (tiny_stories__story_035_p_waited-for-birthday ?character))
        )
      )
    :effect
      (tiny_stories__story_035_p_waited-for-birthday ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_listen-to-mom
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (not (tiny_stories__story_035_p_listened-to-mom ?character))
          (tiny_stories__story_035_p_waited-for-birthday ?character)
        )
      )
    :effect
      (tiny_stories__story_035_p_listened-to-mom ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_open-box
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_035_active)
        (tiny_stories__story_035_type_character ?character)
        (and
          (tiny_stories__story_035_p_box-closed)
          (tiny_stories__story_035_p_birthday ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_box-closed))
        (tiny_stories__story_035_p_box-open)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_035_a_spoil-cake
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (not (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim))
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_035_p_cake-good))
        (tiny_stories__story_035_p_cake-spoiled)
      )
  )

  (:action tiny_stories__story_035_a_keep-cake-good
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_035_active)
        (and
          (tiny_stories__story_035_p_box-open)
          (tiny_stories__story_035_p_listened-to-mom tiny_stories__story_035_o_tim)
          (tiny_stories__story_035_p_cake-good)
        )
      )
    :effect
      (tiny_stories__story_035_p_cake-good)
  )

  (:action tiny_stories__story_072_a_go-to-party
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (not (tiny_stories__story_072_p_at-party ?character))
      )
    :effect
      (tiny_stories__story_072_p_at-party ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_magic-trick
    :parameters (?magician - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?magician)
        (and
          (tiny_stories__story_072_p_at-party ?magician)
          (not (tiny_stories__story_072_p_cake-transformed))
        )
      )
    :effect
      (tiny_stories__story_072_p_cake-transformed)
    :agents (?magician)
  )

  (:action tiny_stories__story_072_a_eat-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_cake-transformed)
        )
      )
    :effect
      (tiny_stories__story_072_p_fast ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_fast ?character)
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_011_p_at ?character ?from))
        (writing_prompts__wp_011_p_at ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_020_a_acknowledge-pain
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character)
        (and
          (writing_prompts__wp_020_p_hurting ?character)
          (writing_prompts__wp_020_p_struggling ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_020_p_struggling ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_020_a_let-go
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character1)
        (writing_prompts__wp_020_type_character ?character2)
        (and
          (writing_prompts__wp_020_p_loved ?character1 ?character2)
          (not (writing_prompts__wp_020_p_ready ?character2))
        )
      )
    :effect
      (writing_prompts__wp_020_p_letting-go ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_020_a_believe-in-better-times
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_020_active)
        (writing_prompts__wp_020_type_character ?character)
        (writing_prompts__wp_020_p_hurting ?character)
      )
    :effect
      (writing_prompts__wp_020_p_better-times ?character)
    :agents (?character)
  )
)
