(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (shared_p_consensus_6b19507d34dc251a ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
    (shared_p_consensus_8f4d52e08f8c6f6b ?v0 - object ?v1 - object)
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (shared_p_consensus_2500567f3da0f8a2 ?v0 - object ?v1 - object)
    (shared_p_consensus_9245e3ab4fda12c6 ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (shared_p_consensus_97b5e6041ae75f45 ?v0 - object)
    (tiny_stories__story_049_active)
    (tiny_stories__story_049_type_character ?x - object)
    (tiny_stories__story_049_type_object ?x - object)
    (tiny_stories__story_049_p_wearing-hat ?v0 - object)
    (tiny_stories__story_049_p_is-dog ?v0 - object)
    (tiny_stories__story_049_p_is-fairy ?v0 - object)
    (tiny_stories__story_049_p_has-magic-flower ?v0 - object)
    (tiny_stories__story_049_p_playing-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_033_type_item ?x - object)
    (writing_prompts__wp_033_type_object ?x - object)
    (writing_prompts__wp_033_type_place ?x - object)
    (writing_prompts__wp_033_type_robot ?x - object)
    (writing_prompts__wp_033_type_weapon ?x - object)
    (writing_prompts__wp_033_p_alive ?v0 - object)
    (shared_p_consensus_ea378ff6756b65f5 ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_thrown ?v0 - object ?v1 - object)
    (writing_prompts__wp_033_p_damaged ?v0 - object)
    (writing_prompts__wp_033_p_destroyed ?v0 - object)
    (writing_prompts__wp_033_p_revolution-started)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (writing_prompts__wp_035_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (shared_p_consensus_9245e3ab4fda12c6 ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (shared_p_consensus_2500567f3da0f8a2 ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (writing_prompts__wp_035_p_at ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (shared_p_consensus_97b5e6041ae75f45 ?character))

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_6b19507d34dc251a ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6b19507d34dc251a ?character ?roomfrom))
        (shared_p_consensus_6b19507d34dc251a ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_6b19507d34dc251a ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_8f4d52e08f8c6f6b ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (shared_p_consensus_8f4d52e08f8c6f6b ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
  )

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (shared_p_consensus_97b5e6041ae75f45 ?character)
      )
    :effect
      (shared_p_consensus_8f4d52e08f8c6f6b ?character ?mask)
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
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (shared_p_consensus_8f4d52e08f8c6f6b ?character ?mask)
          (not (shared_p_consensus_2500567f3da0f8a2 ?character ?mask))
        )
      )
    :effect
      (shared_p_consensus_2500567f3da0f8a2 ?character ?mask)
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
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (shared_p_consensus_2500567f3da0f8a2 ?character ?mask)
        )
      )
    :effect
      (not (shared_p_consensus_2500567f3da0f8a2 ?character ?mask))
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
          (shared_p_consensus_97b5e6041ae75f45 ?character1)
          (shared_p_consensus_97b5e6041ae75f45 ?character2)
          (shared_p_consensus_9245e3ab4fda12c6 ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_049_a_remove-hat
    :parameters (?remover - object ?wearer - object)
    :precondition
      (and
        (tiny_stories__story_049_active)
        (tiny_stories__story_049_type_character ?remover)
        (tiny_stories__story_049_type_character ?wearer)
        (and
          (not (= ?remover ?wearer))
          (tiny_stories__story_049_p_wearing-hat ?wearer)
        )
      )
    :effect
      (not (tiny_stories__story_049_p_wearing-hat ?wearer))
    :agents (?remover)
  )

  (:action tiny_stories__story_049_a_transform
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_049_active)
        (tiny_stories__story_049_type_character ?character)
        (tiny_stories__story_049_p_is-dog ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_049_p_is-dog ?character))
        (tiny_stories__story_049_p_is-fairy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_049_a_give-magic-flower
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_049_active)
        (tiny_stories__story_049_type_character ?giver)
        (tiny_stories__story_049_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (tiny_stories__story_049_p_is-fairy ?giver)
        )
      )
    :effect
      (tiny_stories__story_049_p_has-magic-flower ?receiver)
    :agents (?giver)
  )

  (:action tiny_stories__story_049_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_049_active)
        (tiny_stories__story_049_type_character ?character1)
        (tiny_stories__story_049_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (shared_p_consensus_9245e3ab4fda12c6 ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_049_a_play-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_049_active)
        (tiny_stories__story_049_type_character ?character1)
        (tiny_stories__story_049_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_9245e3ab4fda12c6 ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_049_p_playing-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_033_a_move
    :parameters (?robot - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_type_place ?from)
        (writing_prompts__wp_033_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_033_p_alive ?robot)
          (shared_p_consensus_6b19507d34dc251a ?robot ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_6b19507d34dc251a ?robot ?from))
        (shared_p_consensus_6b19507d34dc251a ?robot ?to)
      )
    :agents (?robot)
  )

  (:action writing_prompts__wp_033_a_throw-weapon
    :parameters (?thrower - object ?weapon - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?thrower)
        (writing_prompts__wp_033_type_weapon ?weapon)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?thrower)
          (shared_p_consensus_ea378ff6756b65f5 ?thrower ?weapon)
          (writing_prompts__wp_033_p_alive ?target)
        )
      )
    :effect
      (writing_prompts__wp_033_p_thrown ?weapon ?target)
    :agents (?thrower)
  )

  (:action writing_prompts__wp_033_a_damage
    :parameters (?damager - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?damager)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?damager)
          (writing_prompts__wp_033_p_alive ?target)
          (exists
            (?weapon - object)
            (and
              (writing_prompts__wp_033_type_weapon ?weapon)
              (writing_prompts__wp_033_p_thrown ?weapon ?target)
            )
          )
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_alive ?target))
        (writing_prompts__wp_033_p_damaged ?target)
      )
    :agents (?damager)
  )

  (:action writing_prompts__wp_033_a_destroy
    :parameters (?destroyer - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?destroyer)
        (writing_prompts__wp_033_type_robot ?target)
        (and
          (writing_prompts__wp_033_p_alive ?destroyer)
          (writing_prompts__wp_033_p_damaged ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_033_p_damaged ?target))
        (writing_prompts__wp_033_p_destroyed ?target)
      )
    :agents (?destroyer)
  )

  (:action writing_prompts__wp_033_a_start-revolution
    :parameters (?robot - object)
    :precondition
      (and
        (writing_prompts__wp_033_active)
        (writing_prompts__wp_033_type_robot ?robot)
        (writing_prompts__wp_033_p_alive ?robot)
      )
    :effect
      (writing_prompts__wp_033_p_revolution-started)
    :agents (?robot)
  )

  (:action writing_prompts__wp_035_a_travel
    :parameters (?character - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_place ?to)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (not (writing_prompts__wp_035_p_at ?character ?to))
        )
      )
    :effect
      (writing_prompts__wp_035_p_at ?character ?to)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-smoking
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (shared_p_consensus_ea378ff6756b65f5 ?character ?item)
          (not (writing_prompts__wp_035_p_smoking ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_smoking ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-dancing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (not (writing_prompts__wp_035_p_dancing ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_dancing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-eating
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (shared_p_consensus_ea378ff6756b65f5 ?character ?item)
          (not (writing_prompts__wp_035_p_eating ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_eating ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_shrink
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (not (writing_prompts__wp_035_p_shrunk ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_shrunk ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_change-clothes
    :parameters (?character - object ?old-item - object ?new-item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?old-item)
        (writing_prompts__wp_035_type_item ?new-item)
        (and
          (shared_p_consensus_97b5e6041ae75f45 ?character)
          (shared_p_consensus_2500567f3da0f8a2 ?character ?old-item)
          (shared_p_consensus_ea378ff6756b65f5 ?character ?new-item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2500567f3da0f8a2 ?character ?old-item))
        (shared_p_consensus_2500567f3da0f8a2 ?character ?new-item)
      )
    :agents (?character)
  )
)
