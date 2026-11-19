(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_009_p_reading ?v0 - object)
    (tiny_stories__story_009_p_playing ?v0 - object)
    (tiny_stories__story_009_p_calm ?v0 - object)
    (tiny_stories__story_009_p_books-fall)
    (tiny_stories__story_049_active)
    (tiny_stories__story_049_type_character ?x - object)
    (tiny_stories__story_049_type_object ?x - object)
    (tiny_stories__story_049_p_wearing-hat ?v0 - object)
    (tiny_stories__story_049_p_is-dog ?v0 - object)
    (tiny_stories__story_049_p_is-fairy ?v0 - object)
    (tiny_stories__story_049_p_has-magic-flower ?v0 - object)
    (tiny_stories__story_049_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_049_p_playing-together ?v0 - object ?v1 - object)
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (tiny_stories__story_077_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_077_p_happy ?v0 - object)
    (tiny_stories__story_077_p_tired ?v0 - object)
    (tiny_stories__story_077_p_played-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))

  (:action tiny_stories__story_009_a_start-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_reading ?character))
      )
    :effect
      (tiny_stories__story_009_p_reading ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_reading ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_reading ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_playing ?character))
      )
    :effect
      (tiny_stories__story_009_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_playing ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_playing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-calm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_calm ?character))
      )
    :effect
      (tiny_stories__story_009_p_calm ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-uncalm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_calm ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_calm ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (tiny_stories__story_009_p_books-fall))
      )
    :effect
      (tiny_stories__story_009_p_books-fall)
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

  (:action tiny_stories__story_077_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_type_place ?from)
        (tiny_stories__story_077_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_077_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_077_p_at ?character ?from))
        (tiny_stories__story_077_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_077_a_play
    :parameters (?character1 - object ?character2 - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character1)
        (tiny_stories__story_077_type_character ?character2)
        (tiny_stories__story_077_type_place ?place)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_077_p_at ?character1 ?place)
          (tiny_stories__story_077_p_at ?character2 ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_077_p_played-together ?character1 ?character2)
        (tiny_stories__story_077_p_happy ?character1)
        (tiny_stories__story_077_p_happy ?character2)
        (tiny_stories__story_077_p_tired ?character1)
        (tiny_stories__story_077_p_tired ?character2)
      )
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_077_a_rest
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_077_active)
        (tiny_stories__story_077_type_character ?character)
        (tiny_stories__story_077_p_tired ?character)
      )
    :effect
      (not (tiny_stories__story_077_p_tired ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )
)
