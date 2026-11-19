(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_014_p_at-park ?v0 - object)
    (tiny_stories__story_014_p_on-swing ?v0 - object)
    (tiny_stories__story_014_p_swinging ?v0 - object)
    (tiny_stories__story_014_p_sharing ?v0 - object ?v1 - object)
    (tiny_stories__story_014_p_happy ?v0 - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (tiny_stories__story_070_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_clean ?v0 - object)
    (tiny_stories__story_070_p_steal-intention ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_014_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_alive ?v0 - object)
    (writing_prompts__wp_014_p_riding ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_relaxed ?v0 - object)
    (writing_prompts__wp_014_p_flying ?v0 - object)
    (writing_prompts__wp_014_p_in-vehicle ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (writing_prompts__wp_044_p_alive ?v0 - object)
    (writing_prompts__wp_044_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_044_p_imprisoned ?v0 - object)
    (writing_prompts__wp_044_p_served-sentence ?v0 - object)
    (writing_prompts__wp_044_p_has-serum ?v0 - object)
    (writing_prompts__wp_044_p_religious ?v0 - object)
  )

  (:action tiny_stories__story_014_a_go-to-park
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (not (tiny_stories__story_014_p_at-park ?character))
      )
    :effect
      (tiny_stories__story_014_p_at-park ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_get-on-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_at-park ?character)
          (not (tiny_stories__story_014_p_on-swing ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_on-swing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_start-swinging
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (not (tiny_stories__story_014_p_swinging ?character))
        )
      )
    :effect
      (tiny_stories__story_014_p_swinging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_share-swing
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_swinging ?character1)
          (tiny_stories__story_014_p_swinging ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_sharing ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_014_a_get-off-swing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character)
        (and
          (tiny_stories__story_014_p_on-swing ?character)
          (tiny_stories__story_014_p_swinging ?character)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_014_p_on-swing ?character))
        (not (tiny_stories__story_014_p_swinging ?character))
        (tiny_stories__story_014_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_014_a_thank
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_014_active)
        (tiny_stories__story_014_type_character ?character1)
        (tiny_stories__story_014_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_014_p_sharing ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_014_p_happy ?character1)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_070_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?apologizer)
        (tiny_stories__story_070_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (tiny_stories__story_070_p_friends ?apologizer ?apologized))
        )
      )
    :effect
      (tiny_stories__story_070_p_friends ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_070_a_try-steal
    :parameters (?stealer - object ?item - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?stealer)
        (tiny_stories__story_070_type_item ?item)
        (tiny_stories__story_070_type_character ?owner)
        (and
          (not (= ?stealer ?owner))
          (tiny_stories__story_070_p_has ?owner ?item)
          (tiny_stories__story_070_p_steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_070_p_steal-intention ?stealer ?item))
        (not (tiny_stories__story_070_p_friends ?stealer ?owner))
        (tiny_stories__story_070_p_has ?stealer ?item)
        (not (tiny_stories__story_070_p_has ?owner ?item))
      )
    :agents (?stealer)
  )

  (:action tiny_stories__story_070_a_clean-item
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?cleaner)
        (tiny_stories__story_070_type_item ?item)
        (and
          (not (tiny_stories__story_070_p_clean ?item))
          (tiny_stories__story_070_p_has ?cleaner ?item)
        )
      )
    :effect
      (tiny_stories__story_070_p_clean ?item)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_070_a_drop-in-puddle
    :parameters (?dropper - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?dropper)
        (tiny_stories__story_070_type_item ?item)
        (and
          (tiny_stories__story_070_p_has ?dropper ?item)
          (tiny_stories__story_070_p_clean ?item)
        )
      )
    :effect
      (not (tiny_stories__story_070_p_clean ?item))
    :agents (?dropper)
  )

  (:action writing_prompts__wp_014_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_place ?from)
        (writing_prompts__wp_014_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_014_p_at ?character ?from))
        (writing_prompts__wp_014_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_has ?character ?vehicle)
          (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
        )
      )
    :effect
      (writing_prompts__wp_014_p_riding ?character ?vehicle)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-riding
    :parameters (?character - object ?vehicle - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (writing_prompts__wp_014_type_vehicle ?vehicle)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_riding ?character ?vehicle)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_riding ?character ?vehicle))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_start-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_flying ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_flying ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-flying
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_flying ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_flying ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_try-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (not (writing_prompts__wp_014_p_relaxed ?character))
        )
      )
    :effect
      (writing_prompts__wp_014_p_relaxed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_014_a_stop-relax
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_014_active)
        (writing_prompts__wp_014_type_character ?character)
        (and
          (writing_prompts__wp_014_p_alive ?character)
          (writing_prompts__wp_014_p_relaxed ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_014_p_relaxed ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_take-serum
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (not (writing_prompts__wp_044_p_has-serum ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_has-serum ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_serve-sentence
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (not (writing_prompts__wp_044_p_served-sentence ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_served-sentence ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_release
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_imprisoned ?character)
          (writing_prompts__wp_044_p_served-sentence ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_imprisoned ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_convert
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (not (writing_prompts__wp_044_p_religious ?character))
        )
      )
    :effect
      (writing_prompts__wp_044_p_religious ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_044_a_abandon-religion
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_044_active)
        (writing_prompts__wp_044_type_character ?character)
        (and
          (writing_prompts__wp_044_p_alive ?character)
          (writing_prompts__wp_044_p_religious ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_044_p_religious ?character))
    :agents (?character)
  )
)
