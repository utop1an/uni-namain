(define (domain revised_merged)
  (:requirements :adl :equality :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:constants tiny_stories__story_045_o_mirror - object)
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
    (shared_p_consensus_fb98ea4d4bfcc129 ?v0 - object ?v1 - object)
    (shared_p_consensus_0cf4f5988ef049fb ?v0 - object ?v1 - object)
    (shared_p_consensus_8a3f1c24ab5cc89a ?v0 - object)
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
    (tiny_stories__story_045_active)
    (tiny_stories__story_045_type_character ?x - object)
    (tiny_stories__story_045_type_object ?x - object)
    (tiny_stories__story_045_p_shares ?v0 - object ?v1 - object ?v2 - object)
    (writing_prompts__wp_038_active)
    (writing_prompts__wp_038_type_character ?x - object)
    (writing_prompts__wp_038_type_object ?x - object)
    (writing_prompts__wp_038_type_place ?x - object)
    (writing_prompts__wp_038_p_abducted ?v0 - object)
    (writing_prompts__wp_038_p_has-translator ?v0 - object)
    (writing_prompts__wp_038_p_knows-mistake ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_playing-game ?v0 - object ?v1 - object)
    (writing_prompts__wp_038_p_friends ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_active)
    (writing_prompts__wp_063_type_character ?x - object)
    (writing_prompts__wp_063_type_object ?x - object)
    (writing_prompts__wp_063_type_place ?x - object)
    (writing_prompts__wp_063_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_alive ?v0 - object)
    (writing_prompts__wp_063_p_locked ?v0 - object)
    (writing_prompts__wp_063_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_063_p_called-police ?v0 - object)
    (writing_prompts__wp_063_p_death-averted ?v0 - object)
    (writing_prompts__wp_063_p_follows ?v0 - object ?v1 - object)
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p1)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (human_230a940d5d5977a6_p_has-car ?a ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p2)
        (not (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p1))
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?p ?p1)
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p1)
          (not (= ?p1 ?p2))
          (human_230a940d5d5977a6_p_is-arrest-place ?p2)
          (shared_p_consensus_8a3f1c24ab5cc89a ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (human_230a940d5d5977a6_p_suspect ?a ?c)
          (human_230a940d5d5977a6_p_arrester ?p)
        )
      )
    :effect
      (and
        (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p2)
        (not (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p1))
        (shared_p_consensus_fb98ea4d4bfcc129 ?p ?p2)
        (not (shared_p_consensus_fb98ea4d4bfcc129 ?p ?p1))
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_fb98ea4d4bfcc129 ?b ?p)
          (shared_p_consensus_0cf4f5988ef049fb ?b ?i)
          (not (= ?a ?b))
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (human_230a940d5d5977a6_p_is-theft ?c)
        )
      )
    :effect
      (and
        (shared_p_consensus_0cf4f5988ef049fb ?a ?i)
        (not (shared_p_consensus_0cf4f5988ef049fb ?b ?i))
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (shared_p_consensus_fb98ea4d4bfcc129 ?b ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?b)
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_fb98ea4d4bfcc129 ?b ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (shared_p_consensus_8a3f1c24ab5cc89a ?b)
          (not (= ?a ?b))
          (shared_p_consensus_0cf4f5988ef049fb ?a ?i)
          (human_230a940d5d5977a6_p_is-murder ?c)
          (not (human_230a940d5d5977a6_p_under-arrest ?a))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_8a3f1c24ab5cc89a ?b))
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (shared_p_consensus_fb98ea4d4bfcc129 ?b ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?b)
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
          (shared_p_consensus_fb98ea4d4bfcc129 ?a ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?a)
          (shared_p_consensus_fb98ea4d4bfcc129 ?b ?p)
          (shared_p_consensus_8a3f1c24ab5cc89a ?b)
          (human_230a940d5d5977a6_p_knows-clue ?a ?c ?i)
          (shared_p_consensus_0cf4f5988ef049fb ?b ?i)
        )
      )
    :effect
      (human_230a940d5d5977a6_p_suspect ?b ?c)
  )

  (:action tiny_stories__story_045_a_find
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?character)
        (tiny_stories__story_045_type_object ?object)
        (not (shared_p_consensus_0cf4f5988ef049fb ?character ?object))
      )
    :effect
      (shared_p_consensus_0cf4f5988ef049fb ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_045_a_share
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (and
          (shared_p_consensus_0cf4f5988ef049fb ?sharer ?object)
          (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
        )
      )
    :effect
      (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
    :agents (?sharer ?receiver)
  )

  (:action tiny_stories__story_045_a_unshare
    :parameters (?sharer - object ?object - object ?receiver - object)
    :precondition
      (and
        (tiny_stories__story_045_active)
        (tiny_stories__story_045_type_character ?sharer)
        (tiny_stories__story_045_type_object ?object)
        (tiny_stories__story_045_type_character ?receiver)
        (tiny_stories__story_045_p_shares ?sharer ?receiver ?object)
      )
    :effect
      (not (tiny_stories__story_045_p_shares ?sharer ?receiver ?object))
    :agents (?sharer ?receiver)
  )

  (:action writing_prompts__wp_038_a_abduct
    :parameters (?abductor - object ?abductee - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?abductor)
        (writing_prompts__wp_038_type_character ?abductee)
        (writing_prompts__wp_038_type_place ?place)
        (and
          (not (= ?abductor ?abductee))
          (shared_p_consensus_8a3f1c24ab5cc89a ?abductor)
          (shared_p_consensus_fb98ea4d4bfcc129 ?abductor ?place)
          (shared_p_consensus_8a3f1c24ab5cc89a ?abductee)
          (shared_p_consensus_fb98ea4d4bfcc129 ?abductee ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_038_p_abducted ?abductee)
        (not (shared_p_consensus_fb98ea4d4bfcc129 ?abductee ?place))
      )
    :agents (?abductor)
  )

  (:action writing_prompts__wp_038_a_give-translator
    :parameters (?giver - object ?receiver - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?giver)
        (writing_prompts__wp_038_type_character ?receiver)
        (and
          (not (= ?giver ?receiver))
          (shared_p_consensus_8a3f1c24ab5cc89a ?giver)
          (shared_p_consensus_8a3f1c24ab5cc89a ?receiver)
          (writing_prompts__wp_038_p_abducted ?receiver)
        )
      )
    :effect
      (writing_prompts__wp_038_p_has-translator ?receiver)
    :agents (?giver)
  )

  (:action writing_prompts__wp_038_a_reveal-mistake
    :parameters (?mistaken - object ?informed - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?mistaken)
        (writing_prompts__wp_038_type_character ?informed)
        (and
          (not (= ?mistaken ?informed))
          (shared_p_consensus_8a3f1c24ab5cc89a ?mistaken)
          (shared_p_consensus_8a3f1c24ab5cc89a ?informed)
          (writing_prompts__wp_038_p_has-translator ?informed)
        )
      )
    :effect
      (writing_prompts__wp_038_p_knows-mistake ?informed ?mistaken)
    :agents (?mistaken)
  )

  (:action writing_prompts__wp_038_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_8a3f1c24ab5cc89a ?character1)
          (shared_p_consensus_8a3f1c24ab5cc89a ?character2)
          (writing_prompts__wp_038_p_has-translator ?character1)
        )
      )
    :effect
      (writing_prompts__wp_038_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_play-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_8a3f1c24ab5cc89a ?character1)
          (shared_p_consensus_8a3f1c24ab5cc89a ?character2)
          (writing_prompts__wp_038_p_friends ?character1 ?character2)
        )
      )
    :effect
      (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_038_a_stop-game
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (writing_prompts__wp_038_active)
        (writing_prompts__wp_038_type_character ?character1)
        (writing_prompts__wp_038_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_8a3f1c24ab5cc89a ?character1)
          (shared_p_consensus_8a3f1c24ab5cc89a ?character2)
          (writing_prompts__wp_038_p_playing-game ?character1 ?character2)
        )
      )
    :effect
      (not (writing_prompts__wp_038_p_playing-game ?character1 ?character2))
    :agents (?character1 ?character2)
  )

  (:action writing_prompts__wp_063_a_lock-door
    :parameters (?character - object ?door - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_object ?door)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (not (writing_prompts__wp_063_p_locked ?door))
        )
      )
    :effect
      (writing_prompts__wp_063_p_locked ?door)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_call-police
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_063_p_called-police ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_follow-officer
    :parameters (?character - object ?officer - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (writing_prompts__wp_063_type_character ?officer)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_alive ?officer)
        )
      )
    :effect
      (writing_prompts__wp_063_p_follows ?character ?officer)
    :agents (?character)
  )

  (:action writing_prompts__wp_063_a_avert-death
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_063_active)
        (writing_prompts__wp_063_type_character ?character)
        (and
          (writing_prompts__wp_063_p_alive ?character)
          (writing_prompts__wp_063_p_called-police ?character)
          (exists
            (?officer - object)
            (and
              (writing_prompts__wp_063_type_character ?officer)
              (writing_prompts__wp_063_p_follows ?character ?officer)
            )
          )
        )
      )
    :effect
      (writing_prompts__wp_063_p_death-averted ?character)
    :agents (?character)
  )
)
