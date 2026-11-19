(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_019_o_colors - object writing_prompts__wp_051_o_ships - object)
  (:predicates
    (human_230a940d5d5977a6_active)
    (human_230a940d5d5977a6_type_actor ?x - object)
    (human_230a940d5d5977a6_type_allpolice ?x - object)
    (human_230a940d5d5977a6_type_car ?x - object)
    (human_230a940d5d5977a6_type_citizen ?x - object)
    (human_230a940d5d5977a6_type_crime ?x - object)
    (human_230a940d5d5977a6_type_detective ?x - object)
    (human_230a940d5d5977a6_type_inspector ?x - object)
    (human_230a940d5d5977a6_type_item ?x - object)
    (human_230a940d5d5977a6_type_motorbike ?x - object)
    (human_230a940d5d5977a6_type_object ?x - object)
    (human_230a940d5d5977a6_type_place ?x - object)
    (human_230a940d5d5977a6_type_police ?x - object)
    (human_230a940d5d5977a6_type_trafficcop ?x - object)
    (human_230a940d5d5977a6_type_vehicle ?x - object)
    (human_230a940d5d5977a6_p_arrester ?v0 - object)
    (human_230a940d5d5977a6_p_arrester-at ?v0 - object)
    (shared_p_consensus_c596b8d93e87e916 ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_has ?v0 - object ?v1 - object)
    (shared_p_consensus_ff4d043c98bd29c8 ?v0 - object)
    (human_230a940d5d5977a6_p_under-arrest ?v0 - object)
    (human_230a940d5d5977a6_p_angry ?v0 - object)
    (human_230a940d5d5977a6_p_knows-clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_suspect ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_murder-clue ?v0 - object)
    (human_230a940d5d5977a6_p_clue ?v0 - object ?v1 - object ?v2 - object)
    (human_230a940d5d5977a6_p_is-basketball-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-theft ?v0 - object)
    (human_230a940d5d5977a6_p_is-arrest-place ?v0 - object)
    (human_230a940d5d5977a6_p_is-murder ?v0 - object)
    (human_230a940d5d5977a6_p_has-car ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_working ?v0 - object)
    (tiny_stories__story_019_active)
    (tiny_stories__story_019_type_character ?x - object)
    (tiny_stories__story_019_type_object ?x - object)
    (tiny_stories__story_019_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_019_p_made-handprint ?v0 - object)
    (tiny_stories__story_019_p_celebrated ?v0 - object)
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
    (writing_prompts__wp_051_active)
    (writing_prompts__wp_051_type_character ?x - object)
    (writing_prompts__wp_051_type_nation ?x - object)
    (writing_prompts__wp_051_type_object ?x - object)
    (writing_prompts__wp_051_p_ruler ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_capital ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_at-war ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_navy-defeated ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_settled ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_built ?v0 - object ?v1 - object ?v2 - object)
    (writing_prompts__wp_051_p_trading ?v0 - object)
    (writing_prompts__wp_051_p_plantation ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_farm-estate ?v0 - object ?v1 - object)
    (writing_prompts__wp_051_p_slave-trade ?v0 - object)
  )

  (:action human_230a940d5d5977a6_a_travel
    :parameters (?a - object ?c - object ?p1 - object ?p2 - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_car ?c)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (and
          (human_230a940d5d5977a6_p_working ?c)
          (shared_p_consensus_c596b8d93e87e916 ?a ?p1)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_c596b8d93e87e916 ?a ?p2)
        (not (shared_p_consensus_c596b8d93e87e916 ?a ?p1))
        (when
          (human_230a940d5d5977a6_p_arrester ?a)
          (and
            (human_230a940d5d5977a6_p_arrester-at ?p2)
            (not (human_230a940d5d5977a6_p_arrester-at ?p1))
          )
        )
      )
  )

  (:action human_230a940d5d5977a6_a_arrest
    :parameters (?p - object ?a - object ?p1 - object ?p2 - object ?c - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?p)
        (human_230a940d5d5977a6_type_actor ?a)
        (human_230a940d5d5977a6_type_place ?p1)
        (human_230a940d5d5977a6_type_place ?p2)
        (human_230a940d5d5977a6_type_crime ?c)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?p ?p1)
          (shared_p_consensus_c596b8d93e87e916 ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (shared_p_consensus_ff4d043c98bd29c8 ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (shared_p_consensus_c596b8d93e87e916 ?a ?p2)
        (not (shared_p_consensus_c596b8d93e87e916 ?a ?p1))
        (shared_p_consensus_c596b8d93e87e916 ?p ?p2)
        (not (shared_p_consensus_c596b8d93e87e916 ?p ?p1))
        (human_230a940d5d5977a6_p_under-arrest ?a)
      )
  )

  (:action human_230a940d5d5977a6_a_steal
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_c596b8d93e87e916 ?b ?p)
          (human_230a940d5d5977a6_p_has ?b ?i)
          (not (= ?a ?b))
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_has ?a ?i)
        (not (human_230a940d5d5977a6_p_has ?b ?i))
        (human_230a940d5d5977a6_p_angry ?b)
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_play-basketball
    :parameters (?a - object ?b - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (human_230a940d5d5977a6_p_is-basketball-place ?p)
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (shared_p_consensus_c596b8d93e87e916 ?b ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?b)
          (not (= ?a ?b))
        )
      )
    :effect
      (and
        (not (human_230a940d5d5977a6_p_angry ?a))
        (not (human_230a940d5d5977a6_p_angry ?b))
      )
  )

  (:action human_230a940d5d5977a6_a_kill
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_citizen ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_c596b8d93e87e916 ?b ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (shared_p_consensus_ff4d043c98bd29c8 ?b)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_has ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ff4d043c98bd29c8 ?b))
        (human_230a940d5d5977a6_p_clue ?c ?i ?p)
      )
  )

  (:action human_230a940d5d5977a6_a_findclues
    :parameters (?a - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_shareclues
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_police ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (shared_p_consensus_c596b8d93e87e916 ?b ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?b)
          (human_230a940d5d5977a6_p_clue ?c ?i ?p)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_knows-clue ?b ?c ?i)
  )

  (:action human_230a940d5d5977a6_a_suspect-of-crime
    :parameters (?a - object ?b - object ?c - object ?i - object ?p - object)
    :precondition
      (and
        (human_230a940d5d5977a6_active)
        (human_230a940d5d5977a6_type_police ?a)
        (human_230a940d5d5977a6_type_citizen ?b)
        (human_230a940d5d5977a6_type_crime ?c)
        (human_230a940d5d5977a6_type_item ?i)
        (human_230a940d5d5977a6_type_place ?p)
        (and
          (shared_p_consensus_c596b8d93e87e916 ?a ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?a)
          (shared_p_consensus_c596b8d93e87e916 ?b ?p)
          (shared_p_consensus_ff4d043c98bd29c8 ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (human_230a940d5d5977a6_p_has ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
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

  (:action writing_prompts__wp_045_a_enter
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_045_active)
        (writing_prompts__wp_045_type_character ?character)
        (writing_prompts__wp_045_type_place ?place)
        (not (shared_p_consensus_c596b8d93e87e916 ?character ?place))
      )
    :effect
      (shared_p_consensus_c596b8d93e87e916 ?character ?place)
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
          (shared_p_consensus_c596b8d93e87e916 ?character ?place)
          (shared_p_consensus_c596b8d93e87e916 ?box ?place)
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
          (shared_p_consensus_c596b8d93e87e916 ?character ?place)
          (shared_p_consensus_c596b8d93e87e916 ?box ?place)
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

  (:action writing_prompts__wp_051_a_become-ruler
    :parameters (?character - object ?nation - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_character ?character)
        (writing_prompts__wp_051_type_nation ?nation)
        (shared_p_consensus_ff4d043c98bd29c8 ?character)
      )
    :effect
      (writing_prompts__wp_051_p_ruler ?character ?nation)
    :agents (?character)
  )

  (:action writing_prompts__wp_051_a_declare-war
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation1)
        (writing_prompts__wp_051_type_nation ?nation2)
        (not (= ?nation1 ?nation2))
      )
    :effect
      (writing_prompts__wp_051_p_at-war ?nation1 ?nation2)
    :agents (?nation1)
  )

  (:action writing_prompts__wp_051_a_defeat-navy
    :parameters (?nation1 - object ?nation2 - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation1)
        (writing_prompts__wp_051_type_nation ?nation2)
        (and
          (not (= ?nation1 ?nation2))
          (writing_prompts__wp_051_p_at-war ?nation1 ?nation2)
        )
      )
    :effect
      (writing_prompts__wp_051_p_navy-defeated ?nation1 ?nation2)
    :agents (?nation1)
  )

  (:action writing_prompts__wp_051_a_settle
    :parameters (?nation - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation)
        (writing_prompts__wp_051_type_object ?place)
      )
    :effect
      (writing_prompts__wp_051_p_settled ?nation ?place)
    :agents (?nation)
  )

  (:action writing_prompts__wp_051_a_build
    :parameters (?character - object ?structure - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_character ?character)
        (writing_prompts__wp_051_type_object ?structure)
        (writing_prompts__wp_051_type_object ?place)
        (shared_p_consensus_ff4d043c98bd29c8 ?character)
      )
    :effect
      (writing_prompts__wp_051_p_built ?character ?structure ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_051_a_establish-trading
    :parameters (?nation - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation)
      )
    :effect
      (writing_prompts__wp_051_p_trading ?nation)
    :agents (?nation)
  )

  (:action writing_prompts__wp_051_a_establish-plantation
    :parameters (?nation - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation)
        (writing_prompts__wp_051_type_object ?place)
      )
    :effect
      (writing_prompts__wp_051_p_plantation ?nation ?place)
    :agents (?nation)
  )

  (:action writing_prompts__wp_051_a_establish-farm-estate
    :parameters (?nation - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation)
        (writing_prompts__wp_051_type_object ?place)
      )
    :effect
      (writing_prompts__wp_051_p_farm-estate ?nation ?place)
    :agents (?nation)
  )

  (:action writing_prompts__wp_051_a_engage-slave-trade
    :parameters (?nation - object)
    :precondition
      (and
        (writing_prompts__wp_051_active)
        (writing_prompts__wp_051_type_nation ?nation)
      )
    :effect
      (writing_prompts__wp_051_p_slave-trade ?nation)
    :agents (?nation)
  )
)
