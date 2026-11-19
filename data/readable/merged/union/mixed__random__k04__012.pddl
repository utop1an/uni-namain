(define (domain revised_merged)
  (:requirements :adl :domain-axioms :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_031_o_old-house - object)
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
    (human_230a940d5d5977a6_p_at ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_has ?v0 - object ?v1 - object)
    (human_230a940d5d5977a6_p_alive ?v0 - object)
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
    (tiny_stories__story_011_active)
    (tiny_stories__story_011_type_character ?x - object)
    (tiny_stories__story_011_type_object ?x - object)
    (tiny_stories__story_011_type_place ?x - object)
    (tiny_stories__story_011_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_awake ?v0 - object)
    (tiny_stories__story_011_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_011_p_interesting ?v0 - object)
    (tiny_stories__story_011_p_singing ?v0 - object)
    (tiny_stories__story_031_active)
    (tiny_stories__story_031_type_character ?x - object)
    (tiny_stories__story_031_type_object ?x - object)
    (tiny_stories__story_031_type_place ?x - object)
    (tiny_stories__story_031_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_031_p_has-skin ?v0 - object)
    (tiny_stories__story_031_p_kneel ?v0 - object)
    (tiny_stories__story_031_p_rewarded ?v0 - object)
    (tiny_stories__story_031_p_tried ?v0 - object)
    (tiny_stories__story_031_p_voice-happy ?v0 - object)
    (writing_prompts__wp_056_active)
    (writing_prompts__wp_056_type_character ?x - object)
    (writing_prompts__wp_056_type_item ?x - object)
    (writing_prompts__wp_056_type_object ?x - object)
    (writing_prompts__wp_056_type_side ?x - object)
    (writing_prompts__wp_056_type_weapon ?x - object)
    (writing_prompts__wp_056_p_alive ?v0 - object)
    (writing_prompts__wp_056_p_armed ?v0 - object)
    (writing_prompts__wp_056_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_fights-for ?v0 - object ?v1 - object)
    (writing_prompts__wp_056_p_in-formation ?v0 - object)
    (writing_prompts__wp_056_p_eyes-glow-red ?v0 - object)
    (writing_prompts__wp_056_p_damaged ?v0 - object)
    (writing_prompts__wp_056_p_aware ?v0 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (writing_prompts__wp_056_p_has ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (writing_prompts__wp_056_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

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
          (human_230a940d5d5977a6_p_at ?a ?p1)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_at ?a ?p2)
        (not (human_230a940d5d5977a6_p_at ?a ?p1))
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
          (human_230a940d5d5977a6_p_at ?p ?p1)
          (human_230a940d5d5977a6_p_at ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (human_230a940d5d5977a6_p_alive ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (human_230a940d5d5977a6_p_at ?a ?p2)
        (not (human_230a940d5d5977a6_p_at ?a ?p1))
        (human_230a940d5d5977a6_p_at ?p ?p2)
        (not (human_230a940d5d5977a6_p_at ?p ?p1))
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_has ?b ?i)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_alive ?a)
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_alive ?b)
          (not (= ?a ?b))
          (human_230a940d5d5977a6_p_has ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (human_230a940d5d5977a6_p_alive ?b))
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
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
          (human_230a940d5d5977a6_p_at ?a ?p)
          (human_230a940d5d5977a6_p_alive ?a)
          (human_230a940d5d5977a6_p_at ?b ?p)
          (human_230a940d5d5977a6_p_alive ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (human_230a940d5d5977a6_p_has ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action tiny_stories__story_011_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (not (tiny_stories__story_011_p_at ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_011_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sleep
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_type_place ?place)
        (and
          (tiny_stories__story_011_p_awake ?character)
          (tiny_stories__story_011_p_at ?character ?place)
          (tiny_stories__story_011_p_interesting ?place)
        )
      )
    :effect
      (not (tiny_stories__story_011_p_awake ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (not (tiny_stories__story_011_p_awake ?character))
      )
    :effect
      (tiny_stories__story_011_p_awake ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_sing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_awake ?character)
      )
    :effect
      (tiny_stories__story_011_p_singing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_stop-singing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character)
        (tiny_stories__story_011_p_singing ?character)
      )
    :effect
      (not (tiny_stories__story_011_p_singing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_011_a_make-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_011_active)
        (tiny_stories__story_011_type_character ?character1)
        (tiny_stories__story_011_type_character ?character2)
        (and
          (tiny_stories__story_011_p_awake ?character1)
          (tiny_stories__story_011_p_awake ?character2)
          (not (tiny_stories__story_011_p_friends ?character1 ?character2))
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_011_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_031_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_type_place ?from)
        (tiny_stories__story_031_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_031_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_031_p_at ?character ?from))
        (tiny_stories__story_031_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_kneel
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_at ?character tiny_stories__story_031_o_old-house)
      )
    :effect
      (tiny_stories__story_031_p_kneel ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_try
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_kneel ?character)
      )
    :effect
      (tiny_stories__story_031_p_tried ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_evaluate
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_tried ?character)
      )
    :effect
      (tiny_stories__story_031_p_voice-happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_reward
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (tiny_stories__story_031_p_voice-happy ?character)
      )
    :effect
      (tiny_stories__story_031_p_rewarded ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_031_a_take-skin
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_031_active)
        (tiny_stories__story_031_type_character ?character)
        (and
          (not (tiny_stories__story_031_p_voice-happy ?character))
          (tiny_stories__story_031_p_has-skin ?character)
        )
      )
    :effect
      (not (tiny_stories__story_031_p_has-skin ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_fire
    :parameters (?shooter - object ?target - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?shooter)
        (writing_prompts__wp_056_type_character ?target)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (not (= ?shooter ?target))
          (writing_prompts__wp_056_p_alive ?shooter)
          (writing_prompts__wp_056_p_armed ?shooter)
          (writing_prompts__wp_056_p_has ?shooter ?weapon)
          (writing_prompts__wp_056_p_alive ?target)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_056_p_alive ?target))
        (intends ?shooter (not (writing_prompts__wp_056_p_alive ?target)))
      )
    :agents (?shooter)
  )

  (:action writing_prompts__wp_056_a_damage
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_damaged ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_damaged ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_become-aware
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (not (writing_prompts__wp_056_p_aware ?character))
        )
      )
    :effect
      (writing_prompts__wp_056_p_aware ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_056_a_suicide
    :parameters (?character - object ?weapon - object)
    :precondition
      (and
        (writing_prompts__wp_056_active)
        (writing_prompts__wp_056_type_character ?character)
        (writing_prompts__wp_056_type_weapon ?weapon)
        (and
          (writing_prompts__wp_056_p_alive ?character)
          (writing_prompts__wp_056_p_armed ?character)
          (writing_prompts__wp_056_p_has ?character ?weapon)
          (writing_prompts__wp_056_p_aware ?character)
        )
      )
    :effect
      (not (writing_prompts__wp_056_p_alive ?character))
    :agents (?character)
  )
)
