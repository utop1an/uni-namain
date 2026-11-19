(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_090_active)
    (tiny_stories__story_090_type_character ?x - object)
    (tiny_stories__story_090_type_object ?x - object)
    (tiny_stories__story_090_type_toy ?x - object)
    (tiny_stories__story_090_p_in-drawer ?v0 - object)
    (tiny_stories__story_090_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_wants-to-take ?v0 - object ?v1 - object)
    (tiny_stories__story_090_p_brave ?v0 - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_057_p_liberated ?v0 - object)
    (writing_prompts__wp_057_p_defeated-illuminati)
    (writing_prompts__wp_057_p_alien-exists ?v0 - object)
    (writing_prompts__wp_057_p_alien-gone ?v0 - object)
  )

  (:action tiny_stories__story_090_a_find-toy
    :parameters (?character - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?character)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_p_in-drawer ?toy)
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_in-drawer ?toy))
        (tiny_stories__story_090_p_friends ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_090_a_want-to-take
    :parameters (?taker - object ?toy - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (tiny_stories__story_090_type_character ?owner)
        (and
          (not (= ?taker ?owner))
          (tiny_stories__story_090_p_friends ?owner ?toy)
        )
      )
    :effect
      (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
    :agents (?taker)
  )

  (:action tiny_stories__story_090_a_stand-up
    :parameters (?defender - object ?taker - object ?toy - object)
    :precondition
      (and
        (tiny_stories__story_090_active)
        (tiny_stories__story_090_type_character ?defender)
        (tiny_stories__story_090_type_character ?taker)
        (tiny_stories__story_090_type_toy ?toy)
        (and
          (not (= ?defender ?taker))
          (tiny_stories__story_090_p_wants-to-take ?taker ?toy)
          (tiny_stories__story_090_p_friends ?defender ?toy)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_090_p_wants-to-take ?taker ?toy))
        (tiny_stories__story_090_p_brave ?defender)
      )
    :agents (?defender)
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
)
