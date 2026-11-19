(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_053_o_spade - object tiny_stories__story_053_o_small-box - object)
  (:predicates
    (tiny_stories__story_017_active)
    (tiny_stories__story_017_type_character ?x - object)
    (tiny_stories__story_017_type_object ?x - object)
    (tiny_stories__story_017_p_watches-tv ?v0 - object)
    (tiny_stories__story_017_p_happy ?v0 - object)
    (tiny_stories__story_017_p_rude ?v0 - object)
    (tiny_stories__story_017_p_nice ?v0 - object)
    (tiny_stories__story_017_p_wants-to-watch-tv ?v0 - object)
    (tiny_stories__story_051_active)
    (tiny_stories__story_051_type_animal ?x - object)
    (tiny_stories__story_051_type_character ?x - object)
    (tiny_stories__story_051_type_object ?x - object)
    (tiny_stories__story_051_type_place ?x - object)
    (shared_p_consensus_d5e96f86451e701f ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_hugged ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_door-open ?v0 - object)
    (tiny_stories__story_051_p_friendly ?v0 - object)
    (tiny_stories__story_053_active)
    (tiny_stories__story_053_type_character ?x - object)
    (tiny_stories__story_053_type_item ?x - object)
    (tiny_stories__story_053_type_object ?x - object)
    (tiny_stories__story_053_type_place ?x - object)
    (tiny_stories__story_053_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_digging ?v0 - object)
    (tiny_stories__story_053_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_opened ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_playing ?v0 - object)
    (writing_prompts__wp_018_active)
    (writing_prompts__wp_018_type_character ?x - object)
    (writing_prompts__wp_018_type_object ?x - object)
    (writing_prompts__wp_018_p_alive ?v0 - object)
    (writing_prompts__wp_018_p_dead ?v0 - object)
    (writing_prompts__wp_018_p_has-scythe ?v0 - object)
    (writing_prompts__wp_018_p_has-robe ?v0 - object)
    (writing_prompts__wp_018_p_retired ?v0 - object)
    (writing_prompts__wp_018_p_reaper ?v0 - object)
    (writing_prompts__wp_018_p_soul-called ?v0 - object)
    (writing_prompts__wp_045_active)
    (writing_prompts__wp_045_type_box ?x - object)
    (writing_prompts__wp_045_type_character ?x - object)
    (writing_prompts__wp_045_type_object ?x - object)
    (writing_prompts__wp_045_type_place ?x - object)
    (writing_prompts__wp_045_p_in-box ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_nervous ?v0 - object)
    (writing_prompts__wp_045_p_composed ?v0 - object)
    (writing_prompts__wp_045_p_noticed ?v0 - object ?v1 - object)
    (writing_prompts__wp_045_p_opened ?v0 - object)
  )
  (:axiom :vars (?character - object ?animal - object) :context (and (tiny_stories__story_051_active) (tiny_stories__story_051_type_character ?character) (tiny_stories__story_051_type_animal ?animal) (and (not (tiny_stories__story_051_p_friendly ?animal)) (tiny_stories__story_051_p_hugged ?character ?animal))) :implies (tiny_stories__story_051_p_friendly ?animal))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_018_active) (writing_prompts__wp_018_type_character ?character) (and (writing_prompts__wp_018_p_alive ?character) (writing_prompts__wp_018_p_dead ?character))) :implies (not (writing_prompts__wp_018_p_alive ?character)))

  (:action tiny_stories__story_017_a_start-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_wants-to-watch-tv ?character)
      )
    :effect
      (tiny_stories__story_017_p_watches-tv ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_stop-watching-tv
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_watches-tv ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_watches-tv ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_rude ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_rude ?character))
        (tiny_stories__story_017_p_nice ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-rude
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_nice ?character)
      )
    :effect
      (and
        (not (tiny_stories__story_017_p_nice ?character))
        (tiny_stories__story_017_p_rude ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
      )
    :effect
      (tiny_stories__story_017_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_017_a_become-unhappy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_017_active)
        (tiny_stories__story_017_type_character ?character)
        (tiny_stories__story_017_p_happy ?character)
      )
    :effect
      (not (tiny_stories__story_017_p_happy ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?from)
        (tiny_stories__story_051_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_d5e96f86451e701f ?character ?from)
          (tiny_stories__story_051_p_door-open ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_d5e96f86451e701f ?character ?from))
        (shared_p_consensus_d5e96f86451e701f ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_hug
    :parameters (?hugger - object ?hugged - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?hugger)
        (tiny_stories__story_051_type_object ?hugged)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_d5e96f86451e701f ?hugger ?place)
          (shared_p_consensus_d5e96f86451e701f ?hugged ?place)
        )
      )
    :effect
      (tiny_stories__story_051_p_hugged ?hugger ?hugged)
    :agents (?hugger)
  )

  (:action tiny_stories__story_051_a_open-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_d5e96f86451e701f ?character ?place)
          (not (tiny_stories__story_051_p_door-open ?place))
        )
      )
    :effect
      (tiny_stories__story_051_p_door-open ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_051_a_close-door
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_051_active)
        (tiny_stories__story_051_type_character ?character)
        (tiny_stories__story_051_type_place ?place)
        (and
          (shared_p_consensus_d5e96f86451e701f ?character ?place)
          (tiny_stories__story_051_p_door-open ?place)
        )
      )
    :effect
      (not (tiny_stories__story_051_p_door-open ?place))
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_place ?place)
        (and
          (not (tiny_stories__story_053_p_at ?character ?place))
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
        )
      )
    :effect
      (tiny_stories__story_053_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_dig
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (and
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
          (not (tiny_stories__story_053_p_digging ?character))
        )
      )
    :effect
      (tiny_stories__story_053_p_digging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_digging ?character)
          (not (tiny_stories__story_053_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_053_p_found ?character ?item)
        (tiny_stories__story_053_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_found ?character ?item)
          (not (tiny_stories__story_053_p_opened ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_053_p_opened ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_p_opened ?character tiny_stories__story_053_o_small-box)
      )
    :effect
      (tiny_stories__story_053_p_playing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_become-reaper
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (not (writing_prompts__wp_018_p_reaper ?character))
          (writing_prompts__wp_018_p_dead ?character)
          (writing_prompts__wp_018_p_has-scythe ?character)
          (writing_prompts__wp_018_p_has-robe ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_reaper ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_receive-items
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?giver)
        (writing_prompts__wp_018_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (writing_prompts__wp_018_p_alive ?giver)
          (writing_prompts__wp_018_p_dead ?receiver)
          (writing_prompts__wp_018_p_has-scythe ?giver)
          (writing_prompts__wp_018_p_has-robe ?giver)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_018_p_has-scythe ?giver))
        (not (writing_prompts__wp_018_p_has-robe ?giver))
        (writing_prompts__wp_018_p_has-scythe ?receiver)
        (writing_prompts__wp_018_p_has-robe ?receiver)
      )
    :agents (?giver ?receiver)
  )

  (:action writing_prompts__wp_018_a_retire
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?character)
        (and
          (writing_prompts__wp_018_p_alive ?character)
          (writing_prompts__wp_018_p_reaper ?character)
        )
      )
    :effect
      (writing_prompts__wp_018_p_retired ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_018_a_collect-soul
    :parameters (?reaper - object ?soul - object)
    :precondition
      (and
        (writing_prompts__wp_018_active)
        (writing_prompts__wp_018_type_character ?reaper)
        (writing_prompts__wp_018_type_character ?soul)
        (and
          (writing_prompts__wp_018_p_reaper ?reaper)
          (writing_prompts__wp_018_p_has-scythe ?reaper)
          (writing_prompts__wp_018_p_has-robe ?reaper)
          (writing_prompts__wp_018_p_soul-called ?soul)
        )
      )
    :effect
      (not (writing_prompts__wp_018_p_soul-called ?soul))
    :agents (?reaper)
  )

  (:action writing_prompts__wp_045_a_enter
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_place ?place)
        (not (shared_p_consensus_d5e96f86451e701f ?character ?place))
      )
    :effect
      (shared_p_consensus_d5e96f86451e701f ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_notice
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (shared_p_consensus_d5e96f86451e701f ?character ?place)
          (shared_p_consensus_d5e96f86451e701f ?box ?place)
        )
      )
    :effect
      (writing_prompts__wp_045_p_noticed ?character ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_open-box
    :parameters (?character - object ?box - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_box ?box)
        (writing_prompts__wp_045_type_place ?place)
        (and
          (shared_p_consensus_d5e96f86451e701f ?character ?place)
          (shared_p_consensus_d5e96f86451e701f ?box ?place)
          (writing_prompts__wp_045_p_noticed ?character ?box)
          (not (writing_prompts__wp_045_p_opened ?box))
        )
      )
    :effect
      (writing_prompts__wp_045_p_opened ?box)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-nervous
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_nervous ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_045_a_become-composed
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
      )
    :effect
      (writing_prompts__wp_045_p_composed ?character)
    :agents (?character)
  )
)
