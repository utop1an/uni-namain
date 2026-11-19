(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_050_active)
    (tiny_stories__story_050_type_character ?x - object)
    (tiny_stories__story_050_type_object ?x - object)
    (tiny_stories__story_050_p_playing-with-toys ?v0 - object)
    (tiny_stories__story_050_p_found-blocks ?v0 - object)
    (tiny_stories__story_050_p_stacking-blocks ?v0 - object)
    (tiny_stories__story_050_p_stack-tall ?v0 - object)
    (tiny_stories__story_050_p_stack-strong ?v0 - object)
    (tiny_stories__story_050_p_happy ?v0 - object)
    (tiny_stories__story_050_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_alive ?v0 - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_057_p_liberated ?v0 - object)
    (writing_prompts__wp_057_p_defeated-illuminati)
    (writing_prompts__wp_057_p_alien-exists ?v0 - object)
    (writing_prompts__wp_057_p_alien-gone ?v0 - object)
    (writing_prompts__wp_093_active)
    (writing_prompts__wp_093_type_character ?x - object)
    (writing_prompts__wp_093_type_object ?x - object)
    (writing_prompts__wp_093_type_subreddit ?x - object)
    (writing_prompts__wp_093_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_united ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_truce ?v0 - object ?v1 - object)
    (writing_prompts__wp_093_p_exists ?v0 - object)
    (writing_prompts__wp_093_p_wall-built)
    (writing_prompts__wp_093_p_filled-with-water)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (writing_prompts__wp_054_p_has ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (writing_prompts__wp_054_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_050_a_play-with-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
      )
    :effect
      (tiny_stories__story_050_p_playing-with-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_find-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_playing-with-toys ?character)
      )
    :effect
      (tiny_stories__story_050_p_found-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_stack-blocks
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_found-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stacking-blocks ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_make-stack-tall
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stacking-blocks ?character)
      )
    :effect
      (tiny_stories__story_050_p_stack-tall ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?helper)
        (tiny_stories__story_050_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_050_p_stack-tall ?helpee)
        )
      )
    :effect
      (tiny_stories__story_050_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_050_a_make-stack-strong
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (and
          (tiny_stories__story_050_p_stack-tall ?character)
          (tiny_stories__story_050_p_helping ?character ?character)
        )
      )
    :effect
      (tiny_stories__story_050_p_stack-strong ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_050_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_050_active)
        (tiny_stories__story_050_type_character ?character)
        (tiny_stories__story_050_p_stack-strong ?character)
      )
    :effect
      (tiny_stories__story_050_p_happy ?character)
    :agents (?character)
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

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (writing_prompts__wp_054_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_has ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (writing_prompts__wp_054_p_has ?killer ?weapon)
          (writing_prompts__wp_054_p_alive ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_054_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_at ?character ?from))
        (writing_prompts__wp_054_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_057_a_liberate
    :parameters (?alien - object ?human - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_type_character ?human)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_liberated ?human))
        )
      )
    :effect
      (writing_prompts__wp_057_p_liberated ?human)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_defeat-illuminati
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_defeated-illuminati))
        )
      )
    :effect
      (writing_prompts__wp_057_p_defeated-illuminati)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_disappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-exists ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-gone ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_reappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-gone ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-exists ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_093_a_wear
    :parameters (?character - object ?clothing - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_character ?character)
        (writing_prompts__wp_093_type_object ?clothing)
      )
    :effect
      (writing_prompts__wp_093_p_wearing ?character ?clothing)
    :agents (?character)
  )

  (:action writing_prompts__wp_093_a_unite
    :parameters (?subreddit1 - object ?subreddit2 - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit1)
        (writing_prompts__wp_093_type_subreddit ?subreddit2)
        (not (writing_prompts__wp_093_p_united ?subreddit1 ?subreddit2))
      )
    :effect
      (writing_prompts__wp_093_p_united ?subreddit1 ?subreddit2)
    :agents (?subreddit1 ?subreddit2)
  )

  (:action writing_prompts__wp_093_a_establish-truce
    :parameters (?subreddit1 - object ?subreddit2 - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit1)
        (writing_prompts__wp_093_type_subreddit ?subreddit2)
        (not (writing_prompts__wp_093_p_truce ?subreddit1 ?subreddit2))
      )
    :effect
      (writing_prompts__wp_093_p_truce ?subreddit1 ?subreddit2)
    :agents (?subreddit1 ?subreddit2)
  )

  (:action writing_prompts__wp_093_a_create-subreddit
    :parameters (?subreddit - object)
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_type_subreddit ?subreddit)
      )
    :effect
      (writing_prompts__wp_093_p_exists ?subreddit)
    :agents (?subreddit)
  )

  (:action writing_prompts__wp_093_a_build-wall
    :parameters ()
    :precondition
      (writing_prompts__wp_093_active)
    :effect
      (writing_prompts__wp_093_p_wall-built)
  )

  (:action writing_prompts__wp_093_a_fill-wall-with-water
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_093_active)
        (writing_prompts__wp_093_p_wall-built)
      )
    :effect
      (writing_prompts__wp_093_p_filled-with-water)
  )
)
