(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
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
    (human_4d95b598471c21ee_p_player ?v0 - object)
    (human_4d95b598471c21ee_p_at ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_has ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (tiny_stories__story_097_active)
    (tiny_stories__story_097_type_character ?x - object)
    (tiny_stories__story_097_type_object ?x - object)
    (shared_p_consensus_c2f6ade2fd2374a9 ?v0 - object ?v1 - object)
    (tiny_stories__story_097_p_happy ?v0 - object)
    (tiny_stories__story_097_p_sad ?v0 - object)
    (tiny_stories__story_097_p_ready ?v0 - object)
    (tiny_stories__story_097_p_practice ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_active)
    (writing_prompts__wp_020_type_character ?x - object)
    (writing_prompts__wp_020_type_object ?x - object)
    (writing_prompts__wp_020_p_hurting ?v0 - object)
    (writing_prompts__wp_020_p_struggling ?v0 - object)
    (writing_prompts__wp_020_p_loved ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_letting-go ?v0 - object ?v1 - object)
    (writing_prompts__wp_020_p_ready ?v0 - object)
    (writing_prompts__wp_020_p_better-times ?v0 - object)
    (writing_prompts__wp_083_active)
    (writing_prompts__wp_083_type_character ?x - object)
    (writing_prompts__wp_083_type_object ?x - object)
    (writing_prompts__wp_083_type_place ?x - object)
    (writing_prompts__wp_083_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_betrayed ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_peace ?v0 - object)
  )

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (human_4d95b598471c21ee_p_connected ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (human_4d95b598471c21ee_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?character ?from))
        (human_4d95b598471c21ee_p_at ?character ?to)
      )
  )

  (:action human_4d95b598471c21ee_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?waker)
        (human_4d95b598471c21ee_type_character ?woken)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?waker ?location)
          (human_4d95b598471c21ee_p_at ?woken ?location)
          (human_4d95b598471c21ee_p_asleep ?woken)
          (not (human_4d95b598471c21ee_p_asleep ?waker))
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_asleep ?woken))
  )

  (:action human_4d95b598471c21ee_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?taker)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?taker ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_4d95b598471c21ee_p_at ?thing ?location))
        (human_4d95b598471c21ee_p_has ?taker ?thing)
      )
  )

  (:action human_4d95b598471c21ee_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?caster)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_book ?book)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (human_4d95b598471c21ee_p_at ?caster ?location)
          (human_4d95b598471c21ee_p_at ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (human_4d95b598471c21ee_p_has ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
  )

  (:action tiny_stories__story_097_a_cheer-up
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_c2f6ade2fd2374a9 ?character1 ?character2)
          (tiny_stories__story_097_p_sad ?character2)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_097_p_sad ?character2))
        (tiny_stories__story_097_p_happy ?character2)
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_097_a_help-practice
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_c2f6ade2fd2374a9 ?character1 ?character2)
          (not (tiny_stories__story_097_p_ready ?character2))
        )
      )
    :effect
      (tiny_stories__story_097_p_practice ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_097_a_become-ready
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character)
        (exists
          (?helper - object)
          (and
            (tiny_stories__story_097_type_character ?helper)
            (tiny_stories__story_097_p_practice ?helper ?character)
          )
        )
      )
    :effect
      (tiny_stories__story_097_p_ready ?character)
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

  (:action writing_prompts__wp_083_a_fall-in-love
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_in-love ?character1 ?character2))
          (shared_p_consensus_c2f6ade2fd2374a9 ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_in-love ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_083_a_betray
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_in-love ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_redeem
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (writing_prompts__wp_083_p_betrayed ?character1 ?character2)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_083_p_betrayed ?character1 ?character2))
        (writing_prompts__wp_083_p_in-love ?character1 ?character2)
      )
    :agents (?character1)
  )

  (:action writing_prompts__wp_083_a_bring-peace
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character)
        (writing_prompts__wp_083_type_place ?place)
        (and
          (not (writing_prompts__wp_083_p_peace ?place))
          (exists
            (?character2 - object)
            (and
              (writing_prompts__wp_083_type_character ?character2)
              (writing_prompts__wp_083_p_in-love ?character ?character2)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_083_p_peace ?place)
    :agents (?character)
  )

  (:action fused_a_consensus_19f39057977494ac
    :parameters (?m0 - object ?m1 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_097_active)
          (tiny_stories__story_097_type_character ?m0)
          (tiny_stories__story_097_type_character ?m1)
          (not (= ?m0 ?m1))
        )
        (and
          (writing_prompts__wp_083_active)
          (writing_prompts__wp_083_type_character ?m0)
          (writing_prompts__wp_083_type_character ?m1)
          (and
            (not (= ?m0 ?m1))
            (not (shared_p_consensus_c2f6ade2fd2374a9 ?m0 ?m1))
          )
        )
      )
    :effect
      (shared_p_consensus_c2f6ade2fd2374a9 ?m0 ?m1)
    :agents (?m0 ?m1)
  )
)
