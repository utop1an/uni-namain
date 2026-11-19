(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
  (:predicates
    (tiny_stories__story_018_active)
    (tiny_stories__story_018_type_character ?x - object)
    (tiny_stories__story_018_type_item ?x - object)
    (tiny_stories__story_018_type_object ?x - object)
    (tiny_stories__story_018_type_place ?x - object)
    (shared_p_consensus_0940de02ea324032 ?v0 - object ?v1 - object)
    (shared_p_consensus_ece18bc1e442dc2e ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_open ?v0 - object)
    (tiny_stories__story_018_p_stored ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_active)
    (writing_prompts__wp_037_type_character ?x - object)
    (writing_prompts__wp_037_type_object ?x - object)
    (writing_prompts__wp_037_p_knows ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_together ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_missing ?v0 - object)
    (writing_prompts__wp_037_p_relationship ?v0 - object ?v1 - object)
    (writing_prompts__wp_037_p_searching ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_has-device ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
  )

  (:action tiny_stories__story_018_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_place ?place)
        (shared_p_consensus_0940de02ea324032 ?character ?place)
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (tiny_stories__story_018_type_item ?item)
            (tiny_stories__story_018_p_hidden ?item ?place)
          )
          (shared_p_consensus_ece18bc1e442dc2e ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (and
          (shared_p_consensus_ece18bc1e442dc2e ?character ?item)
          (not (tiny_stories__story_018_p_open ?item))
        )
      )
    :effect
      (tiny_stories__story_018_p_open ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_store
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (tiny_stories__story_018_type_place ?place)
        (and
          (shared_p_consensus_ece18bc1e442dc2e ?character ?item)
          (tiny_stories__story_018_p_open ?item)
          (shared_p_consensus_0940de02ea324032 ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_018_p_stored ?item ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_037_a_start-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (not (= ?searcher ?target))
          (not (writing_prompts__wp_037_p_searching ?searcher ?target))
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (writing_prompts__wp_037_p_searching ?searcher ?target)
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_stop-search
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (writing_prompts__wp_037_p_searching ?searcher ?target)
      )
    :effect
      (not (writing_prompts__wp_037_p_searching ?searcher ?target))
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_find
    :parameters (?searcher - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?searcher)
        (writing_prompts__wp_037_type_character ?target)
        (and
          (writing_prompts__wp_037_p_searching ?searcher ?target)
          (writing_prompts__wp_037_p_missing ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_037_p_missing ?target))
        (shared_p_consensus_ece18bc1e442dc2e ?searcher ?target)
      )
    :agents (?searcher)
  )

  (:action writing_prompts__wp_037_a_start-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
          (writing_prompts__wp_037_p_knows ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_037_p_relationship ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_037_a_end-relationship
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_037_active)
        (writing_prompts__wp_037_type_character ?character1)
        (writing_prompts__wp_037_type_character ?character2)
        (writing_prompts__wp_037_p_relationship ?character1 ?character2)
      )
    :effect
      (not (writing_prompts__wp_037_p_relationship ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_085_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (not (writing_prompts__wp_085_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_085_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_put-on-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (not (writing_prompts__wp_085_p_wearing-clothes ?character))
        )
      )
    :effect
      (writing_prompts__wp_085_p_wearing-clothes ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_turn-on-device
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_has-device ?character ?device)
          (not (writing_prompts__wp_085_p_device-on ?device))
        )
      )
    :effect
      (writing_prompts__wp_085_p_device-on ?device)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_check-connectivity
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_device-on ?device)
          (writing_prompts__wp_085_p_has-device ?character ?device)
        )
      )
    :effect
      (when
        (writing_prompts__wp_085_p_device-connected ?device)
        (writing_prompts__wp_085_p_working ?device)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_go-outside
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_place ?place)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_wearing-clothes ?character)
          (shared_p_consensus_0940de02ea324032 ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_0940de02ea324032 ?character ?place))
        (shared_p_consensus_0940de02ea324032 ?character writing_prompts__wp_085_o_outside)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_talk
    :parameters (?speaker - object ?listener - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?speaker)
        (writing_prompts__wp_085_type_character ?listener)
        (and
          (writing_prompts__wp_085_p_awake ?speaker)
          (writing_prompts__wp_085_p_awake ?listener)
          (shared_p_consensus_0940de02ea324032 ?speaker writing_prompts__wp_085_o_outside)
          (shared_p_consensus_0940de02ea324032 ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :agents (?speaker ?listener)
  )

  (:action writing_prompts__wp_085_a_cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (writing_prompts__wp_085_p_school-canceled))
      )
    :effect
      (writing_prompts__wp_085_p_school-canceled)
  )
)
