(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_001_o_outside - object)
  (:predicates
    (tiny_stories__story_001_active)
    (tiny_stories__story_001_type_character ?x - object)
    (tiny_stories__story_001_type_object ?x - object)
    (tiny_stories__story_001_type_place ?x - object)
    (tiny_stories__story_001_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_001_p_raining)
    (tiny_stories__story_001_p_sunny)
    (tiny_stories__story_001_p_muddy ?v0 - object)
    (tiny_stories__story_001_p_playing ?v0 - object)
    (tiny_stories__story_001_p_scared ?v0 - object)
    (tiny_stories__story_001_p_brave ?v0 - object)
    (tiny_stories__story_001_p_safe ?v0 - object)
    (tiny_stories__story_001_p_inside ?v0 - object)
    (tiny_stories__story_085_active)
    (tiny_stories__story_085_type_character ?x - object)
    (tiny_stories__story_085_type_item ?x - object)
    (tiny_stories__story_085_type_object ?x - object)
    (tiny_stories__story_085_p_broken ?v0 - object)
    (tiny_stories__story_085_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_apologized ?v0 - object ?v1 - object)
    (tiny_stories__story_085_p_cleaned ?v0 - object)
    (tiny_stories__story_085_p_forgiven ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_alive ?v0 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
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

  (:action tiny_stories__story_001_a_go-outside
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_inside ?character)
          (tiny_stories__story_001_p_sunny)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_inside ?character))
        (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_go-inside
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside))
        (tiny_stories__story_001_p_inside ?character)
        (tiny_stories__story_001_p_safe ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_play-in-mud
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (tiny_stories__story_001_type_place ?place)
        (and
          (tiny_stories__story_001_p_at ?character ?place)
          (tiny_stories__story_001_p_muddy ?place)
        )
      )
    :effect
      (tiny_stories__story_001_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_become-scared
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
          (not (tiny_stories__story_001_p_scared ?character))
        )
      )
    :effect
      (tiny_stories__story_001_p_scared ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_become-brave
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_type_character ?character)
        (and
          (tiny_stories__story_001_p_at ?character tiny_stories__story_001_o_outside)
          (tiny_stories__story_001_p_scared ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_scared ?character))
        (tiny_stories__story_001_p_brave ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_001_a_stop-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_p_raining)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_raining))
        (tiny_stories__story_001_p_sunny)
      )
  )

  (:action tiny_stories__story_001_a_start-raining
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_001_active)
        (tiny_stories__story_001_p_sunny)
      )
    :effect
      (and
        (not (tiny_stories__story_001_p_sunny))
        (tiny_stories__story_001_p_raining)
      )
  )

  (:action tiny_stories__story_085_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?character)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_playing ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_085_a_break-item
    :parameters (?breaker - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?breaker)
        (tiny_stories__story_085_type_item ?item)
        (and
          (not (tiny_stories__story_085_p_broken ?item))
          (tiny_stories__story_085_p_playing ?breaker ?item)
        )
      )
    :effect
      (tiny_stories__story_085_p_broken ?item)
    :agents (?breaker)
  )

  (:action tiny_stories__story_085_a_apologize
    :parameters (?apologizer - object ?apologizee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?apologizer)
        (tiny_stories__story_085_type_character ?apologizee)
        (not (= ?apologizer ?apologizee))
      )
    :effect
      (tiny_stories__story_085_p_apologized ?apologizer ?apologizee)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_085_a_clean
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?cleaner)
        (tiny_stories__story_085_type_item ?item)
        (tiny_stories__story_085_p_broken ?item)
      )
    :effect
      (tiny_stories__story_085_p_cleaned ?cleaner)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_085_a_forgive
    :parameters (?forgiver - object ?forgivee - object)
    :precondition
      (and
        (tiny_stories__story_085_active)
        (tiny_stories__story_085_type_character ?forgiver)
        (tiny_stories__story_085_type_character ?forgivee)
        (and
          (not (= ?forgiver ?forgivee))
          (tiny_stories__story_085_p_apologized ?forgivee ?forgiver)
        )
      )
    :effect
      (tiny_stories__story_085_p_forgiven ?forgiver ?forgivee)
    :agents (?forgiver)
  )

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (not (writing_prompts__wp_063_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_063_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_call-police
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_063_p_called-police ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_follow-officer
    :parameters (?character - object ?officer - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_character ?officer)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_alive ?officer)
        )
      )
    :effect
      (writing_prompts__wp_063_p_follows ?character ?officer)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_avert-death
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_called-police ?character)
          (exists
            (?officer - object)
            (and
              (writing_prompts__wp_063_type_character ?officer)
              (writing_prompts__wp_063_p_follows ?character ?officer)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_063_p_death-averted ?character)
    :agents (?character)
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
