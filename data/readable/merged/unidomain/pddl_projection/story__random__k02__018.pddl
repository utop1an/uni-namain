(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (writing_prompts__wp_020_active)
    (writing_prompts__wp_020_type_character ?x - object)
    (writing_prompts__wp_020_type_object ?x - object)
    (has ?p0 ?p1)
    (friends ?p0 ?p1)
    (clean ?p0)
    (steal-intention ?p0 ?p1)
    (hurting ?p0)
    (struggling ?p0)
    (loved ?p0 ?p1)
    (letting-go ?p0 ?p1)
    (ready ?p0)
    (better-times ?p0)
  )

  (:action apologize
    :parameters (?apologizer ?apologized)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?apologizer)
          (tiny_stories__story_070_type_character ?apologized)
          (tiny_stories__story_070_type_character ?apologizer)
          (tiny_stories__story_070_type_character ?apologized)
        )
        (and
          (not (= ?apologizer ?apologized))
          (not (friends ?apologizer ?apologized))
        )
      )
    :effect
      (friends ?apologizer ?apologized)
  )

  (:action try-steal
    :parameters (?stealer ?item ?owner)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?stealer)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?owner)
          (tiny_stories__story_070_type_character ?stealer)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?owner)
        )
        (and
          (not (= ?stealer ?owner))
          (has ?owner ?item)
          (steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (steal-intention ?stealer ?item))
        (not (friends ?stealer ?owner))
        (has ?stealer ?item)
        (not (has ?owner ?item))
      )
  )

  (:action clean-item
    :parameters (?cleaner ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?cleaner)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?cleaner)
          (tiny_stories__story_070_type_item ?item)
        )
        (and
          (not (clean ?item))
          (has ?cleaner ?item)
        )
      )
    :effect
      (clean ?item)
  )

  (:action drop-in-puddle
    :parameters (?dropper ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_070_active)
          (tiny_stories__story_070_type_character ?dropper)
          (tiny_stories__story_070_type_item ?item)
          (tiny_stories__story_070_type_character ?dropper)
          (tiny_stories__story_070_type_item ?item)
        )
        (and
          (has ?dropper ?item)
          (clean ?item)
        )
      )
    :effect
      (not (clean ?item))
  )

  (:action acknowledge-pain
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character)
          (writing_prompts__wp_020_type_character ?character)
        )
        (and
          (hurting ?character)
          (struggling ?character)
        )
      )
    :effect
      (not (struggling ?character))
  )

  (:action let-go
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character1)
          (writing_prompts__wp_020_type_character ?character2)
          (writing_prompts__wp_020_type_character ?character1)
          (writing_prompts__wp_020_type_character ?character2)
        )
        (and
          (loved ?character1 ?character2)
          (not (ready ?character2))
        )
      )
    :effect
      (letting-go ?character1 ?character2)
  )

  (:action believe-in-better-times
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_020_active)
          (writing_prompts__wp_020_type_character ?character)
          (writing_prompts__wp_020_type_character ?character)
        )
        (hurting ?character)
      )
    :effect
      (better-times ?character)
  )
)
