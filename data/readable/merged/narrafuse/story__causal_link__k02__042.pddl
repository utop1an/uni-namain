(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_028_p_at ?v0 - object ?v1 - object)
    (shared_p_consensus_e78f0e9e9c614567 ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (shared_p_consensus_5d58a177b564db1f ?v0 - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (tiny_stories__story_094_p_sad ?v0 - object)
    (tiny_stories__story_094_p_at ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (shared_p_consensus_e78f0e9e9c614567 ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (shared_p_consensus_e78f0e9e9c614567 ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_put-on-shelf
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (tiny_stories__story_028_type_place ?place)
        (and
          (shared_p_consensus_e78f0e9e9c614567 ?character ?item)
          (tiny_stories__story_028_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e78f0e9e9c614567 ?character ?item))
        (tiny_stories__story_028_p_on-shelf ?item)
        (tiny_stories__story_028_p_organized ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_read
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_p_reads ?character)
      )
    :effect
      (shared_p_consensus_5d58a177b564db1f ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_smell-soap
    :parameters (?character - object ?soap - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?soap)
        (and
          (tiny_stories__story_028_p_on-shelf ?soap)
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (shared_p_consensus_5d58a177b564db1f ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_receive-gift
    :parameters (?receiver - object ?giver - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?receiver)
        (tiny_stories__story_094_type_character ?giver)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?receiver ?giver))
          (shared_p_consensus_5d58a177b564db1f ?giver)
          (not (shared_p_consensus_e78f0e9e9c614567 ?receiver ?item))
          (shared_p_consensus_e78f0e9e9c614567 ?giver ?item)
        )
      )
    :effect
      (and
        (shared_p_consensus_e78f0e9e9c614567 ?receiver ?item)
        (shared_p_consensus_5d58a177b564db1f ?receiver)
      )
    :agents (?receiver ?giver)
  )

  (:action tiny_stories__story_094_a_play
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (shared_p_consensus_e78f0e9e9c614567 ?character ?item)
          (not (tiny_stories__story_094_p_sad ?character))
        )
      )
    :effect
      (shared_p_consensus_5d58a177b564db1f ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_094_a_take-toy
    :parameters (?taker - object ?victim - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?taker)
        (tiny_stories__story_094_type_character ?victim)
        (tiny_stories__story_094_type_item ?item)
        (and
          (not (= ?taker ?victim))
          (shared_p_consensus_e78f0e9e9c614567 ?victim ?item)
          (not (shared_p_consensus_e78f0e9e9c614567 ?taker ?item))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e78f0e9e9c614567 ?victim ?item))
        (shared_p_consensus_e78f0e9e9c614567 ?taker ?item)
        (tiny_stories__story_094_p_sad ?victim)
      )
    :agents (?taker)
  )

  (:action tiny_stories__story_094_a_lose-toy
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_094_active)
        (tiny_stories__story_094_type_character ?character)
        (tiny_stories__story_094_type_item ?item)
        (and
          (shared_p_consensus_e78f0e9e9c614567 ?character ?item)
          (shared_p_consensus_5d58a177b564db1f ?character)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e78f0e9e9c614567 ?character ?item))
        (tiny_stories__story_094_p_sad ?character)
      )
    :agents (?character)
  )
)
