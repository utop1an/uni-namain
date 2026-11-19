(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_060_o_vase - object tiny_stories__story_067_o_factory - object)
  (:predicates
    (tiny_stories__story_060_active)
    (tiny_stories__story_060_type_character ?x - object)
    (tiny_stories__story_060_type_item ?x - object)
    (tiny_stories__story_060_type_object ?x - object)
    (shared_p_consensus_d24170e3c2db6ed5 ?v0 - object)
    (tiny_stories__story_060_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_060_p_party ?v0 - object)
    (tiny_stories__story_060_p_cake ?v0 - object)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (tiny_stories__story_067_p_worker ?v0 - object)
    (tiny_stories__story_067_p_clean ?v0 - object)
    (tiny_stories__story_067_p_makes-toys ?v0 - object)
    (tiny_stories__story_067_p_nervous ?v0 - object)
    (tiny_stories__story_067_p_friends-with ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_060_a_make-cake
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_d24170e3c2db6ed5 ?character)
      )
    :effect
      (tiny_stories__story_060_p_cake ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_put
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_item ?item)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_d24170e3c2db6ed5 ?character)
          (tiny_stories__story_060_p_has ?character ?item)
        )
      )
    :effect
      (tiny_stories__story_060_p_at ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_start-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (shared_p_consensus_d24170e3c2db6ed5 ?character)
      )
    :effect
      (tiny_stories__story_060_p_party ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_060_a_enjoy-party
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_060_active)
        (tiny_stories__story_060_type_character ?character)
        (tiny_stories__story_060_type_object ?place)
        (and
          (shared_p_consensus_d24170e3c2db6ed5 ?character)
          (tiny_stories__story_060_p_party ?place)
        )
      )
    :effect
      (shared_p_consensus_d24170e3c2db6ed5 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_start-working
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
      )
    :effect
      (tiny_stories__story_067_p_worker ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_clean-factory
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_clean tiny_stories__story_067_o_factory)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_make-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_makes-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character1)
        (tiny_stories__story_067_type_character ?character2)
        (and
          (tiny_stories__story_067_p_worker ?character1)
          (tiny_stories__story_067_p_worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_067_p_friends-with ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_067_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (shared_p_consensus_d24170e3c2db6ed5 ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-less-nervous
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (and
          (tiny_stories__story_067_p_worker ?character)
          (tiny_stories__story_067_p_nervous ?character)
        )
      )
    :effect
      (not (tiny_stories__story_067_p_nervous ?character))
    :agents (?character)
  )
)
