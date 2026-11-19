(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_077_active)
    (tiny_stories__story_077_type_character ?x - object)
    (tiny_stories__story_077_type_object ?x - object)
    (tiny_stories__story_077_type_place ?x - object)
    (tiny_stories__story_077_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_077_p_happy ?v0 - object)
    (tiny_stories__story_077_p_tired ?v0 - object)
    (tiny_stories__story_077_p_played-together ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_active)
    (writing_prompts__wp_040_type_character ?x - object)
    (writing_prompts__wp_040_type_object ?x - object)
    (writing_prompts__wp_040_type_place ?x - object)
    (writing_prompts__wp_040_type_power ?x - object)
    (writing_prompts__wp_040_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_alive ?v0 - object)
    (writing_prompts__wp_040_p_has-power ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_brothers ?v0 - object ?v1 - object)
    (writing_prompts__wp_040_p_tyrant ?v0 - object)
    (writing_prompts__wp_092_active)
    (writing_prompts__wp_092_type_character ?x - object)
    (writing_prompts__wp_092_type_object ?x - object)
    (writing_prompts__wp_092_type_place ?x - object)
    (writing_prompts__wp_092_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_ready ?v0 - object)
    (writing_prompts__wp_092_p_has-lover ?v0 - object)
    (writing_prompts__wp_092_p_has-child ?v0 - object ?v1 - object)
    (writing_prompts__wp_092_p_is-grandmother ?v0 - object)
    (writing_prompts__wp_092_p_is-ill ?v0 - object)
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

  (:action writing_prompts__wp_040_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?character)
        (writing_prompts__wp_040_type_place ?from)
        (writing_prompts__wp_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_040_p_alive ?character)
          (writing_prompts__wp_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_040_p_at ?character ?from))
        (writing_prompts__wp_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_040_a_confront
    :parameters (?confronter - object ?confronted - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?confronter)
        (writing_prompts__wp_040_type_character ?confronted)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?confronter ?confronted))
          (writing_prompts__wp_040_p_alive ?confronter)
          (writing_prompts__wp_040_p_at ?confronter ?place)
          (writing_prompts__wp_040_p_alive ?confronted)
          (writing_prompts__wp_040_p_at ?confronted ?place)
        )
      )
    :agents (?confronter)
  )

  (:action writing_prompts__wp_040_a_defeat
    :parameters (?defeater - object ?defeated - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?defeater)
        (writing_prompts__wp_040_type_character ?defeated)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?defeater ?defeated))
          (writing_prompts__wp_040_p_alive ?defeater)
          (writing_prompts__wp_040_p_at ?defeater ?place)
          (writing_prompts__wp_040_p_alive ?defeated)
          (writing_prompts__wp_040_p_at ?defeated ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_040_p_alive ?defeated))
    :agents (?defeater)
  )

  (:action writing_prompts__wp_040_a_show-mercy
    :parameters (?merciful - object ?recipient - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_040_active)
        (writing_prompts__wp_040_type_character ?merciful)
        (writing_prompts__wp_040_type_character ?recipient)
        (writing_prompts__wp_040_type_place ?place)
        (and
          (not (= ?merciful ?recipient))
          (writing_prompts__wp_040_p_alive ?merciful)
          (writing_prompts__wp_040_p_at ?merciful ?place)
          (not (writing_prompts__wp_040_p_alive ?recipient))
          (writing_prompts__wp_040_p_at ?recipient ?place)
        )
      )
    :effect
      (writing_prompts__wp_040_p_alive ?recipient)
    :agents (?merciful)
  )

  (:action writing_prompts__wp_092_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_type_place ?from)
        (writing_prompts__wp_092_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_092_p_at ?character ?from)
          (writing_prompts__wp_092_p_ready ?character)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_092_p_at ?character ?from))
        (writing_prompts__wp_092_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_get-ready
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_ready ?character))
      )
    :effect
      (writing_prompts__wp_092_p_ready ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-grandmother
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (and
          (not (writing_prompts__wp_092_p_is-grandmother ?character))
          (exists
            (?child - object)
            (and
              (writing_prompts__wp_092_type_character ?child)
              (writing_prompts__wp_092_p_has-child ?character ?child)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_092_p_is-grandmother ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_become-ill
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (not (writing_prompts__wp_092_p_is-ill ?character))
      )
    :effect
      (writing_prompts__wp_092_p_is-ill ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_092_a_recover
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_092_active)
        (writing_prompts__wp_092_type_character ?character)
        (writing_prompts__wp_092_p_is-ill ?character)
      )
    :effect
      (not (writing_prompts__wp_092_p_is-ill ?character))
    :agents (?character)
  )
)
