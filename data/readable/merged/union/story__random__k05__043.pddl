(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (tiny_stories__story_063_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_096_active)
    (tiny_stories__story_096_type_character ?x - object)
    (tiny_stories__story_096_type_object ?x - object)
    (tiny_stories__story_096_p_has-swing ?v0 - object)
    (tiny_stories__story_096_p_playing-together ?v0 - object ?v1 - object)
    (tiny_stories__story_096_p_happy ?v0 - object)
    (tiny_stories__story_100_active)
    (tiny_stories__story_100_type_character ?x - object)
    (tiny_stories__story_100_type_object ?x - object)
    (tiny_stories__story_100_p_bored ?v0 - object)
    (tiny_stories__story_100_p_dizzy ?v0 - object)
    (tiny_stories__story_100_p_happy ?v0 - object)
    (tiny_stories__story_100_p_rolling ?v0 - object)
    (tiny_stories__story_100_p_lying-down ?v0 - object)
    (writing_prompts__wp_036_active)
    (writing_prompts__wp_036_type_character ?x - object)
    (writing_prompts__wp_036_type_item ?x - object)
    (writing_prompts__wp_036_type_lightbox ?x - object)
    (writing_prompts__wp_036_type_object ?x - object)
    (writing_prompts__wp_036_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_alive ?v0 - object)
    (writing_prompts__wp_036_p_anchored ?v0 - object)
    (writing_prompts__wp_036_p_charged ?v0 - object)
    (writing_prompts__wp_036_p_created ?v0 - object ?v1 - object)
    (writing_prompts__wp_036_p_used ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_active)
    (writing_prompts__wp_061_type_character ?x - object)
    (writing_prompts__wp_061_type_object ?x - object)
    (writing_prompts__wp_061_p_alive ?v0 - object)
    (writing_prompts__wp_061_p_fan ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_vote ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_win ?v0 - object)
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (tiny_stories__story_063_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (tiny_stories__story_063_p_helping ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (tiny_stories__story_063_p_helping ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_096_a_invite
    :parameters (?inviter - object ?invitee - object)
    :precondition
      (and
        (tiny_stories__story_096_active)
        (tiny_stories__story_096_type_character ?inviter)
        (tiny_stories__story_096_type_character ?invitee)
        (and
          (not (= ?inviter ?invitee))
          (tiny_stories__story_096_p_has-swing ?inviter)
        )
      )
    :effect
      (tiny_stories__story_096_p_playing-together ?inviter ?invitee)
    :agents (?inviter)
  )

  (:action tiny_stories__story_096_a_play-on-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_096_active)
        (tiny_stories__story_096_type_character ?character1)
        (tiny_stories__story_096_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_096_p_playing-together ?character1 ?character2)
        )
      )
    :effect
      (and
        (tiny_stories__story_096_p_happy ?character1)
        (tiny_stories__story_096_p_happy ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_100_a_start-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_bored ?character)
          (not (tiny_stories__story_100_p_rolling ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_bored ?character))
        (tiny_stories__story_100_p_rolling ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_stop-rolling
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_rolling ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_rolling ?character))
        (tiny_stories__story_100_p_dizzy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_lie-down
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (and
          (tiny_stories__story_100_p_dizzy ?character)
          (not (tiny_stories__story_100_p_lying-down ?character))
        )
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_dizzy ?character))
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_100_a_get-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_100_active)
        (tiny_stories__story_100_type_character ?character)
        (tiny_stories__story_100_p_lying-down ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_100_p_lying-down ?character))
        (tiny_stories__story_100_p_happy ?character)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_create-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (writing_prompts__wp_036_p_alive ?character)
      )
    :effect
      (and
        (writing_prompts__wp_036_p_created ?character ?lightbox)
        (writing_prompts__wp_036_p_has ?character ?lightbox)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_anchor-light
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_anchored ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_charge-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_anchored ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
        )
      )
    :effect
      (writing_prompts__wp_036_p_charged ?lightbox)
    :agents (?character)
  )

  (:action writing_prompts__wp_036_a_use-lightbox
    :parameters (?character - object ?lightbox - object)
    :precondition
      (and
        (writing_prompts__wp_036_active)
        (writing_prompts__wp_036_type_character ?character)
        (writing_prompts__wp_036_type_lightbox ?lightbox)
        (and
          (writing_prompts__wp_036_p_alive ?character)
          (writing_prompts__wp_036_p_charged ?lightbox)
          (writing_prompts__wp_036_p_created ?character ?lightbox)
          (writing_prompts__wp_036_p_has ?character ?lightbox)
        )
      )
    :effect
      (and
        (writing_prompts__wp_036_p_used ?character ?lightbox)
        (not (writing_prompts__wp_036_p_charged ?lightbox))
      )
    :agents (?character)
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
