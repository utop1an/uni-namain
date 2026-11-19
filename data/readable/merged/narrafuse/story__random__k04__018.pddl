(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (shared_p_consensus_2fba3c683d2218d4 ?v0 - object ?v1 - object)
    (shared_p_consensus_991dcfc205ff3d8b ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_foggy ?v0 - object)
    (tiny_stories__story_022_p_found ?v0 - object)
    (shared_p_consensus_6310fdec3b8dfd4d ?v0 - object)
    (tiny_stories__story_022_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_023_active)
    (tiny_stories__story_023_type_animal ?x - object)
    (tiny_stories__story_023_type_character ?x - object)
    (tiny_stories__story_023_type_location ?x - object)
    (tiny_stories__story_023_type_object ?x - object)
    (tiny_stories__story_023_type_place ?x - object)
    (tiny_stories__story_023_p_can-fly ?v0 - object)
    (tiny_stories__story_023_p_can-run ?v0 - object)
    (tiny_stories__story_023_p_playing ?v0 - object ?v1 - object)
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (tiny_stories__story_093_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_061_active)
    (writing_prompts__wp_061_type_character ?x - object)
    (writing_prompts__wp_061_type_object ?x - object)
    (writing_prompts__wp_061_p_alive ?v0 - object)
    (writing_prompts__wp_061_p_fan ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_vote ?v0 - object ?v1 - object)
    (writing_prompts__wp_061_p_win ?v0 - object)
  )

  (:action tiny_stories__story_022_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_place ?from)
        (tiny_stories__story_022_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_2fba3c683d2218d4 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2fba3c683d2218d4 ?character ?from))
        (shared_p_consensus_2fba3c683d2218d4 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_search
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_item ?item)
        (tiny_stories__story_022_type_place ?place)
        (and
          (shared_p_consensus_2fba3c683d2218d4 ?character ?place)
          (not (tiny_stories__story_022_p_found ?item))
        )
      )
    :effect
      (when
        (not (tiny_stories__story_022_p_foggy ?place))
        (and
          (tiny_stories__story_022_p_found ?item)
          (shared_p_consensus_991dcfc205ff3d8b ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character1)
        (tiny_stories__story_022_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_022_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_022_a_clear-fog
    :parameters (?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_place ?place)
        (tiny_stories__story_022_p_foggy ?place)
      )
    :effect
      (not (tiny_stories__story_022_p_foggy ?place))
  )

  (:action tiny_stories__story_023_a_play
    :parameters (?character - object ?animal - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_type_location ?place)
        (and
          (shared_p_consensus_2fba3c683d2218d4 ?character ?place)
          (shared_p_consensus_2fba3c683d2218d4 ?animal ?place)
        )
      )
    :effect
      (tiny_stories__story_023_p_playing ?character ?animal)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_stop-playing
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
        (tiny_stories__story_023_type_animal ?animal)
        (tiny_stories__story_023_p_playing ?character ?animal)
      )
    :effect
      (not (tiny_stories__story_023_p_playing ?character ?animal))
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_move
    :parameters (?object - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_object ?object)
        (tiny_stories__story_023_type_location ?from)
        (tiny_stories__story_023_type_location ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_2fba3c683d2218d4 ?object ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_2fba3c683d2218d4 ?object ?from))
        (shared_p_consensus_2fba3c683d2218d4 ?object ?to)
      )
    :agents (?object)
  )

  (:action tiny_stories__story_023_a_can-run
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_character ?character)
      )
    :effect
      (tiny_stories__story_023_p_can-run ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_023_a_can-fly
    :parameters (?animal - object)
    :precondition
      (and
        (tiny_stories__story_023_active)
        (tiny_stories__story_023_type_animal ?animal)
      )
    :effect
      (tiny_stories__story_023_p_can-fly ?animal)
    :agents (?animal)
  )

  (:action tiny_stories__story_093_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_place ?place)
        (tiny_stories__story_093_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_093_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_select-mop
    :parameters (?character - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (tiny_stories__story_093_p_at ?character ?place)
          (shared_p_consensus_991dcfc205ff3d8b ?character ?mop)
        )
      )
    :effect
      (tiny_stories__story_093_p_selected ?mop)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_receive-mop
    :parameters (?character - object ?dog - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_character ?dog)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (tiny_stories__story_093_p_at ?character ?place)
          (tiny_stories__story_093_p_at ?dog ?place)
          (shared_p_consensus_991dcfc205ff3d8b ?dog ?mop)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_991dcfc205ff3d8b ?dog ?mop))
        (shared_p_consensus_991dcfc205ff3d8b ?character ?mop)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_061_a_read-story
    :parameters (?reader - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?reader)
        (writing_prompts__wp_061_type_object ?story)
        (writing_prompts__wp_061_p_alive ?reader)
      )
    :effect
      (writing_prompts__wp_061_p_read ?reader ?story)
    :agents (?reader)
  )

  (:action writing_prompts__wp_061_a_vote-for-story
    :parameters (?voter - object ?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?voter)
        (writing_prompts__wp_061_type_object ?story)
        (and
          (writing_prompts__wp_061_p_alive ?voter)
          (writing_prompts__wp_061_p_read ?voter ?story)
        )
      )
    :effect
      (writing_prompts__wp_061_p_vote ?voter ?story)
    :agents (?voter)
  )

  (:action writing_prompts__wp_061_a_story-wins
    :parameters (?story - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_object ?story)
        (exists
          (?voter - object)
          (and
            (writing_prompts__wp_061_type_character ?voter)
            (writing_prompts__wp_061_p_vote ?voter ?story)
          )
        )
      )
    :effect
      (writing_prompts__wp_061_p_win ?story)
  )

  (:action writing_prompts__wp_061_a_become-fan
    :parameters (?fan - object ?idol - object)
    :precondition
      (and
        (writing_prompts__wp_061_active)
        (writing_prompts__wp_061_type_character ?fan)
        (writing_prompts__wp_061_type_character ?idol)
        (and
          (writing_prompts__wp_061_p_alive ?fan)
          (writing_prompts__wp_061_p_alive ?idol)
          (not (= ?fan ?idol))
        )
      )
    :effect
      (writing_prompts__wp_061_p_fan ?fan ?idol)
    :agents (?fan)
  )

  (:action fused_a_consensus_01837db483f2b606
    :parameters (?m0 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_022_active)
          (tiny_stories__story_022_type_character ?m0)
        )
        (and
          (tiny_stories__story_023_active)
          (tiny_stories__story_023_type_character ?m0)
        )
      )
    :effect
      (shared_p_consensus_6310fdec3b8dfd4d ?m0)
    :agents (?m0)
  )
)
