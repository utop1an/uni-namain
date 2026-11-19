(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_053_o_spade - object tiny_stories__story_053_o_small-box - object)
  (:predicates
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (tiny_stories__story_027_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_found ?v0 - object)
    (tiny_stories__story_027_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_053_active)
    (tiny_stories__story_053_type_character ?x - object)
    (tiny_stories__story_053_type_item ?x - object)
    (tiny_stories__story_053_type_object ?x - object)
    (tiny_stories__story_053_type_place ?x - object)
    (tiny_stories__story_053_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_digging ?v0 - object)
    (tiny_stories__story_053_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_opened ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_playing ?v0 - object)
    (writing_prompts__wp_083_active)
    (writing_prompts__wp_083_type_character ?x - object)
    (writing_prompts__wp_083_type_object ?x - object)
    (writing_prompts__wp_083_type_place ?x - object)
    (writing_prompts__wp_083_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_in-love ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_betrayed ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_083_p_peace ?v0 - object)
  )

  (:action tiny_stories__story_027_a_hide
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (tiny_stories__story_027_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_027_p_hidden ?toy ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?place)
        (and
          (tiny_stories__story_027_p_at ?character ?place)
          (not (tiny_stories__story_027_p_searched ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_027_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_find
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (and
          (tiny_stories__story_027_p_at ?character ?place)
          (tiny_stories__story_027_p_hidden ?toy ?place)
          (tiny_stories__story_027_p_searched ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_027_p_found ?toy)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?from)
        (tiny_stories__story_027_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_027_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_027_p_at ?character ?from))
        (tiny_stories__story_027_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_place ?place)
        (and
          (not (tiny_stories__story_053_p_at ?character ?place))
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
        )
      )
    :effect
      (tiny_stories__story_053_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_dig
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (and
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
          (not (tiny_stories__story_053_p_digging ?character))
        )
      )
    :effect
      (tiny_stories__story_053_p_digging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_digging ?character)
          (not (tiny_stories__story_053_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_053_p_found ?character ?item)
        (tiny_stories__story_053_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_found ?character ?item)
          (not (tiny_stories__story_053_p_opened ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_053_p_opened ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_p_opened ?character tiny_stories__story_053_o_small-box)
      )
    :effect
      (tiny_stories__story_053_p_playing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_083_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_083_active)
        (writing_prompts__wp_083_type_character ?character1)
        (writing_prompts__wp_083_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_083_p_friends ?character1 ?character2))
        )
      )
    :effect
      (writing_prompts__wp_083_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
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
          (writing_prompts__wp_083_p_friends ?character1 ?character2)
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
)
