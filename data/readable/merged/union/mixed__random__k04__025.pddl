(define (domain revised_merged)
  (:requirements :adl :disjunctive-preconditions :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:predicates
    (human_62959785b3ec220a_active)
    (human_62959785b3ec220a_type_character ?x - object)
    (human_62959785b3ec220a_type_location ?x - object)
    (human_62959785b3ec220a_type_object ?x - object)
    (human_62959785b3ec220a_type_thing ?x - object)
    (human_62959785b3ec220a_p_player ?v0 - object)
    (human_62959785b3ec220a_p_at ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_has ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_connected ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_apprehended ?v0 - object)
    (human_62959785b3ec220a_p_alive ?v0 - object)
    (human_62959785b3ec220a_p_saved ?v0 - object ?v1 - object)
    (human_62959785b3ec220a_p_knows ?v0 - object)
    (human_62959785b3ec220a_p_captured ?v0 - object)
    (human_62959785b3ec220a_p_henchman ?v0 - object)
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_028_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (tiny_stories__story_028_p_happy ?v0 - object)
    (tiny_stories__story_049_active)
    (tiny_stories__story_049_type_character ?x - object)
    (tiny_stories__story_049_type_object ?x - object)
    (tiny_stories__story_049_p_wearing-hat ?v0 - object)
    (tiny_stories__story_049_p_is-dog ?v0 - object)
    (tiny_stories__story_049_p_is-fairy ?v0 - object)
    (tiny_stories__story_049_p_has-magic-flower ?v0 - object)
    (tiny_stories__story_049_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_049_p_playing-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_active)
    (writing_prompts__wp_074_type_character ?x - object)
    (writing_prompts__wp_074_type_object ?x - object)
    (writing_prompts__wp_074_p_influenced ?v0 - object)
    (writing_prompts__wp_074_p_isolated ?v0 - object)
    (writing_prompts__wp_074_p_hates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_manipulates ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_despises ?v0 - object ?v1 - object)
    (writing_prompts__wp_074_p_apologized ?v0 - object ?v1 - object)
  )

  (:action human_62959785b3ec220a_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?character)
        (human_62959785b3ec220a_type_location ?to)
        (human_62959785b3ec220a_type_location ?from)
        (and
          (human_62959785b3ec220a_p_player ?character)
          (human_62959785b3ec220a_p_connected ?to ?from)
          (human_62959785b3ec220a_p_at ?character ?from)
          (human_62959785b3ec220a_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_at ?character ?from))
        (human_62959785b3ec220a_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_62959785b3ec220a_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?interrogator)
        (human_62959785b3ec220a_type_character ?interrogated)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?interrogator)
          (human_62959785b3ec220a_p_at ?interrogator ?location)
          (human_62959785b3ec220a_p_at ?interrogated ?location)
          (human_62959785b3ec220a_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_62959785b3ec220a_p_knows ?interrogator)
    :agents (?interrogator)
  )

  (:action human_62959785b3ec220a_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?placer)
        (human_62959785b3ec220a_type_character ?victim)
        (human_62959785b3ec220a_type_location ?location)
        (human_62959785b3ec220a_type_location ?placed)
        (and
          (human_62959785b3ec220a_p_henchman ?placer)
          (human_62959785b3ec220a_p_has ?placer ?victim)
          (human_62959785b3ec220a_p_at ?placer ?location)
          (human_62959785b3ec220a_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_62959785b3ec220a_p_has ?placer ?victim))
        (human_62959785b3ec220a_p_at ?victim ?placed)
        (human_62959785b3ec220a_p_captured ?victim)
      )
    :agents (?placer)
  )

  (:action human_62959785b3ec220a_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_62959785b3ec220a_active)
        (human_62959785b3ec220a_type_character ?saver)
        (human_62959785b3ec220a_type_character ?saved)
        (human_62959785b3ec220a_type_character ?notsaved)
        (human_62959785b3ec220a_type_location ?location)
        (and
          (human_62959785b3ec220a_p_player ?saver)
          (human_62959785b3ec220a_p_at ?saver ?location)
          (human_62959785b3ec220a_p_at ?saved ?location)
          (human_62959785b3ec220a_p_captured ?saved)
          (human_62959785b3ec220a_p_captured ?notsaved)
          (not (human_62959785b3ec220a_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_62959785b3ec220a_p_saved ?saved ?saver)
        (not (human_62959785b3ec220a_p_alive ?notsaved))
      )
    :agents (?saver)
  )

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (tiny_stories__story_028_p_has ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (tiny_stories__story_028_p_has ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_put-on-shelf
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (tiny_stories__story_028_type_place ?place)
        (and
          (tiny_stories__story_028_p_has ?character ?item)
          (tiny_stories__story_028_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_028_p_has ?character ?item))
        (tiny_stories__story_028_p_on-shelf ?item)
        (tiny_stories__story_028_p_organized ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_read
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_p_reads ?character)
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_smell-soap
    :parameters (?character - object ?soap - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?soap)
        (and
          (tiny_stories__story_028_p_on-shelf ?soap)
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
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
      (tiny_stories__story_049_p_friends ?character1 ?character2)
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
          (tiny_stories__story_049_p_friends ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_049_p_playing-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_074_a_influence
    :parameters (?influencer - object ?influenced - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?influencer)
        (writing_prompts__wp_074_type_character ?influenced)
        (and
          (not (= ?influencer ?influenced))
          (not (writing_prompts__wp_074_p_influenced ?influenced))
        )
      )
    :effect
      (writing_prompts__wp_074_p_influenced ?influenced)
    :agents (?influencer)
  )

  (:action writing_prompts__wp_074_a_isolate
    :parameters (?isolator - object ?isolated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?isolator)
        (writing_prompts__wp_074_type_character ?isolated)
        (and
          (not (= ?isolator ?isolated))
          (not (writing_prompts__wp_074_p_isolated ?isolated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_isolated ?isolated)
    :agents (?isolator)
  )

  (:action writing_prompts__wp_074_a_manipulate
    :parameters (?manipulator - object ?manipulated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?manipulator)
        (writing_prompts__wp_074_type_character ?manipulated)
        (and
          (not (= ?manipulator ?manipulated))
          (not (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_manipulates ?manipulator ?manipulated)
    :agents (?manipulator)
  )

  (:action writing_prompts__wp_074_a_hate
    :parameters (?hater - object ?hated - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?hater)
        (writing_prompts__wp_074_type_character ?hated)
        (and
          (not (= ?hater ?hated))
          (not (writing_prompts__wp_074_p_hates ?hater ?hated))
        )
      )
    :effect
      (writing_prompts__wp_074_p_hates ?hater ?hated)
    :agents (?hater)
  )

  (:action writing_prompts__wp_074_a_despise
    :parameters (?despiser - object ?despised - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?despiser)
        (writing_prompts__wp_074_type_character ?despised)
        (and
          (not (= ?despiser ?despised))
          (not (writing_prompts__wp_074_p_despises ?despiser ?despised))
        )
      )
    :effect
      (writing_prompts__wp_074_p_despises ?despiser ?despised)
    :agents (?despiser)
  )

  (:action writing_prompts__wp_074_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (writing_prompts__wp_074_active)
        (writing_prompts__wp_074_type_character ?apologizer)
        (writing_prompts__wp_074_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (writing_prompts__wp_074_p_apologized ?apologizer ?apologized))
        )
      )
    :effect
      (writing_prompts__wp_074_p_apologized ?apologizer ?apologized)
    :agents (?apologizer)
  )
)
