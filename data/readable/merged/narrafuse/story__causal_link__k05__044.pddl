(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (shared_p_consensus_c61176c4354007b1 ?v0 - object ?v1 - object)
    (shared_p_consensus_c0b972e78570f185 ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (tiny_stories__story_028_p_happy ?v0 - object)
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_046_p_impatient ?v0 - object)
    (shared_p_consensus_aeae5a0c3275ec72 ?v0 - object ?v1 - object)
    (tiny_stories__story_046_p_on-table ?v0 - object)
    (tiny_stories__story_046_p_smells-nice ?v0 - object)
    (tiny_stories__story_046_p_playing-with-ball ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (shared_p_consensus_e8b8896763c573ac ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (shared_p_consensus_8ee28d7ee67a5420 ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_alive ?v0 - object)
    (writing_prompts__wp_035_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (shared_p_consensus_8ee28d7ee67a5420 ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (writing_prompts__wp_035_p_alive ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (shared_p_consensus_c0b972e78570f185 ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (shared_p_consensus_c0b972e78570f185 ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (shared_p_consensus_c0b972e78570f185 ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (shared_p_consensus_c0b972e78570f185 ?character ?item)
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
          (shared_p_consensus_c0b972e78570f185 ?character ?item)
          (shared_p_consensus_c61176c4354007b1 ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c0b972e78570f185 ?character ?item))
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
      (tiny_stories__story_028_p_happy ?character)
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
      (tiny_stories__story_028_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_try-get
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_type_object ?object)
        (and
          (tiny_stories__story_046_p_impatient ?character)
          (tiny_stories__story_046_p_on-table ?object)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_046_p_on-table ?object))
        (shared_p_consensus_aeae5a0c3275ec72 ?character ?object)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_smell-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (shared_p_consensus_aeae5a0c3275ec72 ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (tiny_stories__story_046_p_smells-nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_play-with-ball
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (shared_p_consensus_aeae5a0c3275ec72 ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (tiny_stories__story_046_p_playing-with-ball ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_c61176c4354007b1 ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_c61176c4354007b1 ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_c61176c4354007b1 ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c61176c4354007b1 ?character ?from))
        (shared_p_consensus_c61176c4354007b1 ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_travel
    :parameters (?character - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_place ?to)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (shared_p_consensus_8ee28d7ee67a5420 ?character ?to))
        )
      )
    :effect
      (shared_p_consensus_8ee28d7ee67a5420 ?character ?to)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-smoking
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (shared_p_consensus_aeae5a0c3275ec72 ?character ?item)
          (not (writing_prompts__wp_035_p_smoking ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_smoking ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-dancing
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_dancing ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_dancing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_start-eating
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (shared_p_consensus_aeae5a0c3275ec72 ?character ?item)
          (not (writing_prompts__wp_035_p_eating ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_eating ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_shrink
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (not (writing_prompts__wp_035_p_shrunk ?character))
        )
      )
    :effect
      (writing_prompts__wp_035_p_shrunk ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_035_a_change-clothes
    :parameters (?character - object ?old-item - object ?new-item - object)
    :precondition
      (and
        (writing_prompts__wp_035_active)
        (writing_prompts__wp_035_type_character ?character)
        (writing_prompts__wp_035_type_item ?old-item)
        (writing_prompts__wp_035_type_item ?new-item)
        (and
          (writing_prompts__wp_035_p_alive ?character)
          (writing_prompts__wp_035_p_wearing ?character ?old-item)
          (shared_p_consensus_aeae5a0c3275ec72 ?character ?new-item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_035_p_wearing ?character ?old-item))
        (writing_prompts__wp_035_p_wearing ?character ?new-item)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (shared_p_consensus_c0b972e78570f185 ?character ?item)
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?place)
          (shared_p_consensus_c0b972e78570f185 ?character ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_c0b972e78570f185 ?character ?item))
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
          (shared_p_consensus_e8b8896763c573ac ?killer)
          (shared_p_consensus_8ee28d7ee67a5420 ?killer ?place)
          (shared_p_consensus_c0b972e78570f185 ?killer ?weapon)
          (shared_p_consensus_e8b8896763c573ac ?victim)
          (shared_p_consensus_8ee28d7ee67a5420 ?victim ?place)
        )
      )
    :effect
      (not (shared_p_consensus_e8b8896763c573ac ?victim))
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
          (shared_p_consensus_e8b8896763c573ac ?character)
          (shared_p_consensus_8ee28d7ee67a5420 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8ee28d7ee67a5420 ?character ?from))
        (shared_p_consensus_8ee28d7ee67a5420 ?character ?to)
      )
    :agents (?character)
  )
)
