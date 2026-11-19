(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_87bbd0acdf4611c5_active)
    (human_87bbd0acdf4611c5_type_character ?x - object)
    (human_87bbd0acdf4611c5_type_location ?x - object)
    (human_87bbd0acdf4611c5_type_object ?x - object)
    (human_87bbd0acdf4611c5_type_thing ?x - object)
    (human_87bbd0acdf4611c5_p_player ?v0 - object)
    (human_87bbd0acdf4611c5_p_at ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_has ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_connected ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_apprehended ?v0 - object)
    (human_87bbd0acdf4611c5_p_alive ?v0 - object)
    (human_87bbd0acdf4611c5_p_saved ?v0 - object ?v1 - object)
    (human_87bbd0acdf4611c5_p_knows ?v0 - object)
    (human_87bbd0acdf4611c5_p_captured ?v0 - object)
    (human_87bbd0acdf4611c5_p_henchman ?v0 - object)
    (tiny_stories__story_065_active)
    (tiny_stories__story_065_type_character ?x - object)
    (tiny_stories__story_065_type_object ?x - object)
    (tiny_stories__story_065_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_hurt ?v0 - object)
    (tiny_stories__story_065_p_touching ?v0 - object ?v1 - object)
    (tiny_stories__story_065_p_scared ?v0 - object)
    (tiny_stories__story_065_p_hugging ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_active)
    (writing_prompts__wp_061_type_character ?x - object)
    (writing_prompts__wp_061_type_object ?x - object)
    (writing_prompts__wp_061_p_alive ?v0 - object)
    (writing_prompts__wp_061_p_fan ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_vote ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_win ?v0 - object)
  )

  (:action human_87bbd0acdf4611c5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?character)
        (human_87bbd0acdf4611c5_type_location ?to)
        (human_87bbd0acdf4611c5_type_location ?from)
        (and
          (human_87bbd0acdf4611c5_p_player ?character)
          (human_87bbd0acdf4611c5_p_connected ?to ?from)
          (human_87bbd0acdf4611c5_p_at ?character ?from)
          (human_87bbd0acdf4611c5_p_knows ?character)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_at ?character ?from))
        (human_87bbd0acdf4611c5_p_at ?character ?to)
      )
  )

  (:action human_87bbd0acdf4611c5_a_interrogate-character
    :parameters (?interrogator - object ?interrogated - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?interrogator)
        (human_87bbd0acdf4611c5_type_character ?interrogated)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?interrogator)
          (human_87bbd0acdf4611c5_p_at ?interrogator ?location)
          (human_87bbd0acdf4611c5_p_at ?interrogated ?location)
          (human_87bbd0acdf4611c5_p_apprehended ?interrogated)
        )
      )
    :effect
      (human_87bbd0acdf4611c5_p_knows ?interrogator)
  )

  (:action human_87bbd0acdf4611c5_a_place-victim
    :parameters (?placer - object ?victim - object ?location - object ?placed - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?placer)
        (human_87bbd0acdf4611c5_type_character ?victim)
        (human_87bbd0acdf4611c5_type_location ?location)
        (human_87bbd0acdf4611c5_type_location ?placed)
        (and
          (human_87bbd0acdf4611c5_p_henchman ?placer)
          (human_87bbd0acdf4611c5_p_has ?placer ?victim)
          (human_87bbd0acdf4611c5_p_at ?placer ?location)
          (human_87bbd0acdf4611c5_p_connected ?placed ?location)
        )
      )
    :effect
      (and
        (not (human_87bbd0acdf4611c5_p_has ?placer ?victim))
        (human_87bbd0acdf4611c5_p_at ?victim ?placed)
        (human_87bbd0acdf4611c5_p_captured ?victim)
      )
  )

  (:action human_87bbd0acdf4611c5_a_save-character
    :parameters (?saver - object ?saved - object ?notsaved - object ?location - object)
    :precondition
      (and
        (human_87bbd0acdf4611c5_active)
        (human_87bbd0acdf4611c5_type_character ?saver)
        (human_87bbd0acdf4611c5_type_character ?saved)
        (human_87bbd0acdf4611c5_type_character ?notsaved)
        (human_87bbd0acdf4611c5_type_location ?location)
        (and
          (human_87bbd0acdf4611c5_p_player ?saver)
          (human_87bbd0acdf4611c5_p_at ?saver ?location)
          (human_87bbd0acdf4611c5_p_at ?saved ?location)
          (human_87bbd0acdf4611c5_p_captured ?saved)
          (human_87bbd0acdf4611c5_p_captured ?notsaved)
          (not (human_87bbd0acdf4611c5_p_at ?notsaved ?location))
        )
      )
    :effect
      (and
        (human_87bbd0acdf4611c5_p_saved ?saved ?saver)
        (not (human_87bbd0acdf4611c5_p_alive ?notsaved))
      )
  )

  (:action tiny_stories__story_065_a_move
    :parameters (?character - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_at ?character ?location))
          (not (tiny_stories__story_065_p_scared ?character))
        )
      )
    :effect
      (tiny_stories__story_065_p_at ?character ?location)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_touch
    :parameters (?character - object ?object - object ?location - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_type_object ?location)
        (and
          (not (tiny_stories__story_065_p_touching ?character ?object))
          (tiny_stories__story_065_p_at ?character ?location)
        )
      )
    :effect
      (tiny_stories__story_065_p_touching ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-touching
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_type_object ?object)
        (tiny_stories__story_065_p_touching ?character ?object)
      )
    :effect
      (not (tiny_stories__story_065_p_touching ?character ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-hurt
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_hurt ?character))
      )
    :effect
      (tiny_stories__story_065_p_hurt ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_get-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (not (tiny_stories__story_065_p_scared ?character))
      )
    :effect
      (tiny_stories__story_065_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_stop-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character)
        (tiny_stories__story_065_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_065_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_065_a_hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (and
          (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
          (not (tiny_stories__story_065_p_hugging ?character2 ?character1))
        )
      )
    :effect
      (tiny_stories__story_065_p_hugging ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_065_a_stop-hug
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_065_active)
        (tiny_stories__story_065_type_character ?character1)
        (tiny_stories__story_065_type_character ?character2)
        (tiny_stories__story_065_p_hugging ?character1 ?character2)
      )
    :effect
      (not (tiny_stories__story_065_p_hugging ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_061_a_read-story
    :parameters (?reader - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?reader)
        (writing_prompts__wp_061_type_object ?story)
        (writing_prompts__wp_061_p_alive ?reader)
      )
    :effect
      (writing_prompts__wp_061_p_read ?reader ?story)
    :agents (?reader)
  )

  (:action writing_prompts__wp_061_a_vote-for-story
    :parameters (?voter - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?voter)
        (writing_prompts__wp_061_type_object ?story)
        (and
          (writing_prompts__wp_061_p_alive ?voter)
          (writing_prompts__wp_061_p_read ?voter ?story)
        )
      )
    :effect
      (writing_prompts__wp_061_p_vote ?voter ?story)
    :agents (?voter)
  )

  (:action writing_prompts__wp_061_a_story-wins
    :parameters (?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_object ?story)
        (exists
          (?voter - object)
          (and
            (writing_prompts__wp_061_type_character ?voter)
            (writing_prompts__wp_061_p_vote ?voter ?story)
          )
        )
      )
    :effect
      (writing_prompts__wp_061_p_win ?story)
  )

  (:action writing_prompts__wp_061_a_become-fan
    :parameters (?fan - object ?idol - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?fan)
        (writing_prompts__wp_061_type_character ?idol)
        (and
          (writing_prompts__wp_061_p_alive ?fan)
          (writing_prompts__wp_061_p_alive ?idol)
          (not (= ?fan ?idol))
        )
      )
    :effect
      (writing_prompts__wp_061_p_fan ?fan ?idol)
    :agents (?fan)
  )
)
