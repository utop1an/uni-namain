(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_051_active)
    (tiny_stories__story_051_type_animal ?x - object)
    (tiny_stories__story_051_type_character ?x - object)
    (tiny_stories__story_051_type_object ?x - object)
    (tiny_stories__story_051_type_place ?x - object)
    (shared_p_consensus_e2f5310cd92be945 ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_hugged ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_door-open ?v0 - object)
    (tiny_stories__story_051_p_friendly ?v0 - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (shared_p_consensus_c96ac82b1f0a2ee1 ?v0 - object ?v1 - object)
    (tiny_stories__story_076_active)
    (tiny_stories__story_076_type_character ?x - object)
    (tiny_stories__story_076_type_item ?x - object)
    (tiny_stories__story_076_type_object ?x - object)
    (tiny_stories__story_076_type_toy ?x - object)
    (shared_p_consensus_2296d88a942821bf ?v0 - object ?v1 - object)
    (tiny_stories__story_076_p_playing-together ?v0 - object ?v1 - object)
    (tiny_stories__story_076_p_shares ?v0 - object)
    (tiny_stories__story_076_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (tiny_stories__story_086_p_scared ?v0 - object)
    (tiny_stories__story_086_p_spider-on-wall)
    (tiny_stories__story_086_p_happy ?v0 - object)
    (tiny_stories__story_086_p_cake-made)
    (writing_prompts__wp_014_active)
    (writing_prompts__wp_014_type_character ?x - object)
    (writing_prompts__wp_014_type_item ?x - object)
    (writing_prompts__wp_014_type_object ?x - object)
    (writing_prompts__wp_014_type_place ?x - object)
    (writing_prompts__wp_014_type_vehicle ?x - object)
    (writing_prompts__wp_014_p_alive ?v0 - object)
    (writing_prompts__wp_014_p_riding ?v0 - object ?v1 - object)
    (writing_prompts__wp_014_p_relaxed ?v0 - object)
    (writing_prompts__wp_014_p_flying ?v0 - object)
    (writing_prompts__wp_014_p_in-vehicle ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object ?animal - object) :context (and (tiny_stories__story_051_active) (tiny_stories__story_051_type_character ?character) (tiny_stories__story_051_type_animal ?animal) (and (not (tiny_stories__story_051_p_friendly ?animal)) (tiny_stories__story_051_p_hugged ?character ?animal))) :implies (tiny_stories__story_051_p_friendly ?animal))

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
          (shared_p_consensus_e2f5310cd92be945 ?character ?from)
          (tiny_stories__story_051_p_door-open ?to)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2f5310cd92be945 ?character ?from))
        (shared_p_consensus_e2f5310cd92be945 ?character ?to)
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
          (shared_p_consensus_e2f5310cd92be945 ?hugger ?place)
          (shared_p_consensus_e2f5310cd92be945 ?hugged ?place)
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
          (shared_p_consensus_e2f5310cd92be945 ?character ?place)
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
          (shared_p_consensus_e2f5310cd92be945 ?character ?place)
          (tiny_stories__story_051_p_door-open ?place)
        )
      )
    :effect
      (not (tiny_stories__story_051_p_door-open ?place))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (shared_p_consensus_c96ac82b1f0a2ee1 ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (shared_p_consensus_c96ac82b1f0a2ee1 ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (shared_p_consensus_c96ac82b1f0a2ee1 ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_076_a_share
    :parameters (?sharer - object ?item - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_076_active)
        (tiny_stories__story_076_type_character ?sharer)
        (tiny_stories__story_076_type_item ?item)
        (tiny_stories__story_076_type_character ?receiver)
        (and
          (not (= ?sharer ?receiver))
          (shared_p_consensus_2296d88a942821bf ?sharer ?item)
          (tiny_stories__story_076_p_friends ?sharer ?receiver)
        )
      )
    :effect
      (and
        (tiny_stories__story_076_p_shares ?sharer)
        (shared_p_consensus_2296d88a942821bf ?receiver ?item)
      )
    :agents (?sharer)
  )

  (:action tiny_stories__story_076_a_play-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_076_active)
        (tiny_stories__story_076_type_character ?character1)
        (tiny_stories__story_076_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_076_p_friends ?character1 ?character2)
          (tiny_stories__story_076_p_shares ?character1)
        )
      )
    :effect
      (tiny_stories__story_076_p_playing-together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_076_a_apologize
    :parameters (?apologizer - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_076_active)
        (tiny_stories__story_076_type_character ?apologizer)
        (tiny_stories__story_076_type_character ?receiver)
        (and
          (not (= ?apologizer ?receiver))
          (tiny_stories__story_076_p_friends ?apologizer ?receiver)
        )
      )
    :effect
      (tiny_stories__story_076_p_shares ?apologizer)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_076_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_076_active)
        (tiny_stories__story_076_type_character ?character1)
        (tiny_stories__story_076_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_076_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_086_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?helper)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (not (= ?helper ?helpee))
          (tiny_stories__story_086_p_scared ?helpee)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_086_p_scared ?helpee))
        (tiny_stories__story_086_p_happy ?helpee)
        (shared_p_consensus_c96ac82b1f0a2ee1 ?helper ?helpee)
      )
    :agents (?helper)
  )

  (:action tiny_stories__story_086_a_make-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_cake-made))
          (tiny_stories__story_086_p_happy ?character)
        )
      )
    :effect
      (tiny_stories__story_086_p_cake-made)
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_see-spider
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (and
          (not (tiny_stories__story_086_p_scared ?character))
          (not (tiny_stories__story_086_p_spider-on-wall))
        )
      )
    :effect
      (and
        (tiny_stories__story_086_p_scared ?character)
        (tiny_stories__story_086_p_spider-on-wall)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_086_a_remove-spider
    :parameters (?character - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_086_active)
        (tiny_stories__story_086_type_character ?character)
        (tiny_stories__story_086_type_character ?helpee)
        (and
          (tiny_stories__story_086_p_spider-on-wall)
          (shared_p_consensus_c96ac82b1f0a2ee1 ?character ?helpee)
        )
      )
    :effect
      (not (tiny_stories__story_086_p_spider-on-wall))
    :agents (?character)
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
          (shared_p_consensus_e2f5310cd92be945 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_e2f5310cd92be945 ?character ?from))
        (shared_p_consensus_e2f5310cd92be945 ?character ?to)
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
          (shared_p_consensus_2296d88a942821bf ?character ?vehicle)
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
)
