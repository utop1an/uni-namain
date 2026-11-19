(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_019_o_colors - object)
  (:predicates
    (tiny_stories__story_015_active)
    (tiny_stories__story_015_type_character ?x - object)
    (tiny_stories__story_015_type_dog ?x - object)
    (tiny_stories__story_015_type_object ?x - object)
    (shared_p_consensus_7613c04c12585b50 ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_practices ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_participates ?v0 - object)
    (tiny_stories__story_015_p_wins ?v0 - object)
    (tiny_stories__story_015_p_plays-with-toy-stack ?v0 - object)
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (tiny_stories__story_019_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_made-handprint ?v0 - object)
    (tiny_stories__story_019_p_celebrated ?v0 - object)
    (tiny_stories__story_030_active)
    (tiny_stories__story_030_type_character ?x - object)
    (tiny_stories__story_030_type_object ?x - object)
    (tiny_stories__story_030_p_hungry ?v0 - object)
    (shared_p_consensus_781d7b4bad949897 ?v0 - object)
    (tiny_stories__story_030_p_food-available)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
    (writing_prompts__wp_022_active)
    (writing_prompts__wp_022_type_character ?x - object)
    (writing_prompts__wp_022_type_object ?x - object)
    (writing_prompts__wp_022_p_pranked ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_015_a_practice-running
    :parameters (?helper - object ?runner - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?helper)
        (tiny_stories__story_015_type_dog ?runner)
        (and
          (shared_p_consensus_7613c04c12585b50 ?helper ?runner)
          (not (tiny_stories__story_015_p_practices ?helper ?runner))
        )
      )
    :effect
      (tiny_stories__story_015_p_practices ?helper ?runner)
    :agents (?helper ?runner)
  )

  (:action tiny_stories__story_015_a_participate-in-race
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_participates ?dog))
      )
    :effect
      (tiny_stories__story_015_p_participates ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_win-race
    :parameters (?dog - object ?helper - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (tiny_stories__story_015_type_dog ?helper)
        (and
          (tiny_stories__story_015_p_participates ?dog)
          (tiny_stories__story_015_p_practices ?dog ?helper)
        )
      )
    :effect
      (tiny_stories__story_015_p_wins ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_play-with-toy-stack
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_plays-with-toy-stack ?dog))
      )
    :effect
      (tiny_stories__story_015_p_plays-with-toy-stack ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_019_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?character)
        (tiny_stories__story_019_type_object ?object)
        (not (tiny_stories__story_019_p_found ?character ?object))
      )
    :effect
      (tiny_stories__story_019_p_found ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_019_a_make-handprint
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?character)
        (tiny_stories__story_019_p_found ?character tiny_stories__story_019_o_colors)
      )
    :effect
      (tiny_stories__story_019_p_made-handprint ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_019_a_show-handprint
    :parameters (?shower - object ?viewer - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?shower)
        (tiny_stories__story_019_type_character ?viewer)
        (and
          (tiny_stories__story_019_p_made-handprint ?shower)
          (not (= ?shower ?viewer))
        )
      )
    :effect
      (tiny_stories__story_019_p_celebrated ?viewer)
    :agents (?shower ?viewer)
  )

  (:action tiny_stories__story_019_a_celebrate
    :parameters (?celebrator - object ?celebratee - object)
    :precondition
      (and
        (tiny_stories__story_019_active)
        (tiny_stories__story_019_type_character ?celebrator)
        (tiny_stories__story_019_type_character ?celebratee)
        (and
          (tiny_stories__story_019_p_celebrated ?celebrator)
          (not (= ?celebrator ?celebratee))
        )
      )
    :effect
      (tiny_stories__story_019_p_celebrated ?celebratee)
    :agents (?celebrator ?celebratee)
  )

  (:action tiny_stories__story_030_a_ask-to-be-friends
    :parameters (?asker - object ?askee - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?asker)
        (tiny_stories__story_030_type_character ?askee)
        (and
          (shared_p_consensus_781d7b4bad949897 ?asker)
          (shared_p_consensus_781d7b4bad949897 ?askee)
          (not (shared_p_consensus_7613c04c12585b50 ?asker ?askee))
        )
      )
    :effect
      (shared_p_consensus_7613c04c12585b50 ?asker ?askee)
    :agents (?asker)
  )

  (:action tiny_stories__story_030_a_search-for-food
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?character)
        (shared_p_consensus_781d7b4bad949897 ?character)
      )
    :effect
      (tiny_stories__story_030_p_food-available)
    :agents (?character)
  )

  (:action tiny_stories__story_030_a_feed
    :parameters (?feeder - object ?eater - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?feeder)
        (tiny_stories__story_030_type_character ?eater)
        (and
          (shared_p_consensus_781d7b4bad949897 ?feeder)
          (shared_p_consensus_781d7b4bad949897 ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (tiny_stories__story_030_p_food-available)
        )
      )
    :effect
      (not (tiny_stories__story_030_p_hungry ?eater))
    :agents (?feeder)
  )

  (:action tiny_stories__story_030_a_eat
    :parameters (?eater - object ?eaten - object)
    :precondition
      (and
        (tiny_stories__story_030_active)
        (tiny_stories__story_030_type_character ?eater)
        (tiny_stories__story_030_type_character ?eaten)
        (and
          (shared_p_consensus_781d7b4bad949897 ?eater)
          (tiny_stories__story_030_p_hungry ?eater)
          (shared_p_consensus_781d7b4bad949897 ?eaten)
        )
      )
    :effect
      (not (shared_p_consensus_781d7b4bad949897 ?eaten))
    :agents (?eater)
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
          (shared_p_consensus_781d7b4bad949897 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
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
          (shared_p_consensus_781d7b4bad949897 ?character)
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
          (shared_p_consensus_781d7b4bad949897 ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
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
          (shared_p_consensus_781d7b4bad949897 ?character)
          (writing_prompts__wp_011_p_at ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_011_p_at ?character ?from))
        (writing_prompts__wp_011_p_at ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_022_a_prank
    :parameters (?pranker - object ?target - object)
    :precondition
      (and
        (writing_prompts__wp_022_active)
        (writing_prompts__wp_022_type_character ?pranker)
        (writing_prompts__wp_022_type_character ?target)
      )
    :effect
      (writing_prompts__wp_022_p_pranked ?pranker ?target)
    :agents (?pranker)
  )
)
