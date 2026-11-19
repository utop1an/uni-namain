(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_014_active)
    (tiny_stories__story_014_type_character ?x - object)
    (tiny_stories__story_014_type_object ?x - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_044_active)
    (writing_prompts__wp_044_type_character ?x - object)
    (writing_prompts__wp_044_type_object ?x - object)
    (writing_prompts__wp_044_type_place ?x - object)
    (at-park ?p0)
    (on-swing ?p0)
    (swinging ?p0)
    (sharing ?p0 ?p1)
    (happy ?p0)
    (friends ?p0 ?p1)
    (clean ?p0)
    (steal-intention ?p0 ?p1)
    (has ?p0 ?p1)
    (riding ?p0 ?p1)
    (relaxed ?p0)
    (flying ?p0)
    (in-vehicle ?p0 ?p1)
    (at ?p0 ?p1)
    (alive ?p0)
    (imprisoned ?p0)
    (served-sentence ?p0)
    (has-serum ?p0)
    (religious ?p0)
  )

  (:action go-to-park
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character)
          (tiny_stories__story_014_type_character ?character)
        )
        (not (at-park ?character))
      )
    :effect
      (at-park ?character)
  )

  (:action get-on-swing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character)
          (tiny_stories__story_014_type_character ?character)
        )
        (and
          (at-park ?character)
          (not (on-swing ?character))
        )
      )
    :effect
      (on-swing ?character)
  )

  (:action start-swinging
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character)
          (tiny_stories__story_014_type_character ?character)
        )
        (and
          (on-swing ?character)
          (not (swinging ?character))
        )
      )
    :effect
      (swinging ?character)
  )

  (:action share-swing
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character1)
          (tiny_stories__story_014_type_character ?character2)
          (tiny_stories__story_014_type_character ?character1)
          (tiny_stories__story_014_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (swinging ?character1)
          (swinging ?character2)
        )
      )
    :effect
      (sharing ?character1 ?character2)
  )

  (:action get-off-swing
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character)
          (tiny_stories__story_014_type_character ?character)
        )
        (and
          (on-swing ?character)
          (swinging ?character)
        )
      )
    :effect
      (and
        (not (on-swing ?character))
        (not (swinging ?character))
        (happy ?character)
      )
  )

  (:action thank
    :parameters (?character1 ?character2)
    :precondition
      (and
        (and
          (tiny_stories__story_014_active)
          (tiny_stories__story_014_type_character ?character1)
          (tiny_stories__story_014_type_character ?character2)
          (tiny_stories__story_014_type_character ?character1)
          (tiny_stories__story_014_type_character ?character2)
        )
        (and
          (not (= ?character1 ?character2))
          (sharing ?character1 ?character2)
        )
      )
    :effect
      (happy ?character1)
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

  (:action stop-riding
    :parameters (?character ?vehicle)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
        )
        (and
          (alive ?character)
          (riding ?character ?vehicle)
        )
      )
    :effect
      (not (riding ?character ?vehicle))
  )

  (:action start-flying
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (not (flying ?character))
        )
      )
    :effect
      (flying ?character)
  )

  (:action stop-flying
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (flying ?character)
        )
      )
    :effect
      (not (flying ?character))
  )

  (:action try-relax
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (not (relaxed ?character))
        )
      )
    :effect
      (relaxed ?character)
  )

  (:action stop-relax
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_character ?character)
        )
        (and
          (alive ?character)
          (relaxed ?character)
        )
      )
    :effect
      (not (relaxed ?character))
  )

  (:action travel
    :parameters (?character ?from ?to)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_place ?from)
          (writing_prompts__wp_014_type_place ?to)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_place ?from)
          (writing_prompts__wp_014_type_place ?to)
        )
        (and
          (not (= ?from ?to))
          (alive ?character)
          (at ?character ?from)
        )
      )
    :effect
      (and
        (not (at ?character ?from))
        (at ?character ?to)
      )
  )

  (:action serve-sentence
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (not (served-sentence ?character))
        )
      )
    :effect
      (served-sentence ?character)
  )

  (:action release
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (imprisoned ?character)
          (served-sentence ?character)
        )
      )
    :effect
      (not (imprisoned ?character))
  )

  (:action convert
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (religious ?character))
        )
      )
    :effect
      (religious ?character)
  )

  (:action abandon-religion
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (religious ?character)
        )
      )
    :effect
      (not (religious ?character))
  )

  (:action start-riding
    :parameters (?character ?vehicle)
    :precondition
      (and
        (and
          (writing_prompts__wp_014_active)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
          (writing_prompts__wp_014_type_character ?character)
          (writing_prompts__wp_014_type_vehicle ?vehicle)
        )
        (and
          (alive ?character)
          (has ?character ?vehicle)
          (not (riding ?character ?vehicle))
        )
      )
    :effect
      (riding ?character ?vehicle)
  )

  (:action take-serum
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_044_active)
          (writing_prompts__wp_044_type_character ?character)
          (writing_prompts__wp_044_type_character ?character)
        )
        (and
          (alive ?character)
          (not (has-serum ?character))
        )
      )
    :effect
      (has-serum ?character)
  )
)
