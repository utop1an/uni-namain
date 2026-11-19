(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants human_8fa5775aae174731_o_ark - object)
  (:predicates
    (human_8fa5775aae174731_active)
    (human_8fa5775aae174731_type_character ?x - object)
    (human_8fa5775aae174731_type_item ?x - object)
    (human_8fa5775aae174731_type_object ?x - object)
    (human_8fa5775aae174731_type_place ?x - object)
    (human_8fa5775aae174731_type_weapon ?x - object)
    (human_8fa5775aae174731_p_open ?v0 - object)
    (human_8fa5775aae174731_p_alive ?v0 - object)
    (human_8fa5775aae174731_p_armed ?v0 - object)
    (human_8fa5775aae174731_p_burried ?v0 - object ?v1 - object)
    (human_8fa5775aae174731_p_knows-location ?v0 - object ?v1 - object ?v2 - object)
    (shared_p_consensus_099c36231bddb279 ?v0 - object ?v1 - object)
    (shared_p_consensus_ab4e864fb5b1d91c ?v0 - object ?v1 - object)
    (tiny_stories__story_027_active)
    (tiny_stories__story_027_type_character ?x - object)
    (tiny_stories__story_027_type_location ?x - object)
    (tiny_stories__story_027_type_object ?x - object)
    (tiny_stories__story_027_type_place ?x - object)
    (tiny_stories__story_027_type_toy ?x - object)
    (tiny_stories__story_027_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_027_p_found ?v0 - object)
    (tiny_stories__story_027_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_028_active)
    (tiny_stories__story_028_type_character ?x - object)
    (tiny_stories__story_028_type_item ?x - object)
    (tiny_stories__story_028_type_object ?x - object)
    (tiny_stories__story_028_type_place ?x - object)
    (tiny_stories__story_028_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_028_p_on-shelf ?v0 - object)
    (tiny_stories__story_028_p_organized ?v0 - object)
    (tiny_stories__story_028_p_reads ?v0 - object)
    (shared_p_consensus_56a05c5a999b1478 ?v0 - object)
    (tiny_stories__story_086_active)
    (tiny_stories__story_086_type_character ?x - object)
    (tiny_stories__story_086_type_object ?x - object)
    (tiny_stories__story_086_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_086_p_scared ?v0 - object)
    (tiny_stories__story_086_p_spider-on-wall)
    (tiny_stories__story_086_p_cake-made)
    (writing_prompts__wp_049_active)
    (writing_prompts__wp_049_type_character ?x - object)
    (writing_prompts__wp_049_type_object ?x - object)
    (writing_prompts__wp_049_p_needs-walk ?v0 - object)
    (writing_prompts__wp_049_p_in-herenow ?v0 - object)
    (writing_prompts__wp_049_p_ancient-oath ?v0 - object)
    (writing_prompts__wp_049_p_guardian ?v0 - object)
    (writing_prompts__wp_049_p_master ?v0 - object)
    (writing_prompts__wp_049_p_time-of-passing)
  )
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (not (human_8fa5775aae174731_p_armed ?character)) (exists (?w - object) (and (human_8fa5775aae174731_type_weapon ?w) (shared_p_consensus_ab4e864fb5b1d91c ?character ?w))))) :implies (human_8fa5775aae174731_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (human_8fa5775aae174731_active) (human_8fa5775aae174731_type_character ?character) (and (human_8fa5775aae174731_p_armed ?character) (forall (?w - object) (or (not (human_8fa5775aae174731_type_weapon ?w)) (not (shared_p_consensus_ab4e864fb5b1d91c ?character ?w)))))) :implies (not (human_8fa5775aae174731_p_armed ?character)))

  (:action human_8fa5775aae174731_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_place ?from)
        (human_8fa5775aae174731_type_place ?to)
        (and
          (not (= ?from ?to))
          (human_8fa5775aae174731_p_alive ?character)
          (shared_p_consensus_099c36231bddb279 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_099c36231bddb279 ?character ?from))
        (shared_p_consensus_099c36231bddb279 ?character ?to)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_excavate
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (human_8fa5775aae174731_p_alive ?character)
          (shared_p_consensus_099c36231bddb279 ?character ?place)
          (human_8fa5775aae174731_p_burried ?item ?place)
          (human_8fa5775aae174731_p_knows-location ?character ?item ?place)
        )
      )
    :effect
      (and
        (not (human_8fa5775aae174731_p_burried ?item ?place))
        (shared_p_consensus_ab4e864fb5b1d91c ?character ?item)
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_give
    :parameters (?giver - object ?item - object ?receiver - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?giver)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?receiver)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?giver ?receiver))
          (human_8fa5775aae174731_p_alive ?giver)
          (shared_p_consensus_099c36231bddb279 ?giver ?place)
          (shared_p_consensus_ab4e864fb5b1d91c ?giver ?item)
          (human_8fa5775aae174731_p_alive ?receiver)
          (shared_p_consensus_099c36231bddb279 ?receiver ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ab4e864fb5b1d91c ?giver ?item))
        (shared_p_consensus_ab4e864fb5b1d91c ?receiver ?item)
      )
    :agents (?giver ?receiver)
  )

  (:action human_8fa5775aae174731_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?killer)
        (human_8fa5775aae174731_type_weapon ?weapon)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (human_8fa5775aae174731_p_alive ?killer)
          (shared_p_consensus_099c36231bddb279 ?killer ?place)
          (shared_p_consensus_ab4e864fb5b1d91c ?killer ?weapon)
          (human_8fa5775aae174731_p_alive ?victim)
          (shared_p_consensus_099c36231bddb279 ?victim ?place)
        )
      )
    :effect
      (not (human_8fa5775aae174731_p_alive ?victim))
    :agents (?killer)
  )

  (:action human_8fa5775aae174731_a_take
    :parameters (?taker - object ?item - object ?victim - object ?place - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?taker)
        (human_8fa5775aae174731_type_item ?item)
        (human_8fa5775aae174731_type_character ?victim)
        (human_8fa5775aae174731_type_place ?place)
        (and
          (not (= ?taker ?victim))
          (human_8fa5775aae174731_p_alive ?taker)
          (shared_p_consensus_099c36231bddb279 ?taker ?place)
          (or
            (not (human_8fa5775aae174731_p_alive ?victim))
            (and
              (human_8fa5775aae174731_p_armed ?taker)
              (not (human_8fa5775aae174731_p_armed ?victim))
            )
          )
          (shared_p_consensus_099c36231bddb279 ?victim ?place)
          (shared_p_consensus_ab4e864fb5b1d91c ?victim ?item)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ab4e864fb5b1d91c ?victim ?item))
        (shared_p_consensus_ab4e864fb5b1d91c ?taker ?item)
      )
    :agents (?taker)
  )

  (:action human_8fa5775aae174731_a_open-ark
    :parameters (?character - object)
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_type_character ?character)
        (and
          (human_8fa5775aae174731_p_alive ?character)
          (shared_p_consensus_ab4e864fb5b1d91c ?character human_8fa5775aae174731_o_ark)
        )
      )
    :effect
      (and
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
        (not (human_8fa5775aae174731_p_alive ?character))
      )
    :agents (?character)
  )

  (:action human_8fa5775aae174731_a_close-ark
    :parameters ()
    :precondition
      (and
        (human_8fa5775aae174731_active)
        (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark)
      )
    :effect
      (not (human_8fa5775aae174731_p_open human_8fa5775aae174731_o_ark))
  )

  (:action tiny_stories__story_027_a_hide
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (shared_p_consensus_099c36231bddb279 ?character ?place)
      )
    :effect
      (tiny_stories__story_027_p_hidden ?toy ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?place)
        (and
          (shared_p_consensus_099c36231bddb279 ?character ?place)
          (not (tiny_stories__story_027_p_searched ?character ?place))
        )
      )
    :effect
      (tiny_stories__story_027_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_find
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_toy ?toy)
        (tiny_stories__story_027_type_place ?place)
        (and
          (shared_p_consensus_099c36231bddb279 ?character ?place)
          (tiny_stories__story_027_p_hidden ?toy ?place)
          (tiny_stories__story_027_p_searched ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_027_p_found ?toy)
    :agents (?character)
  )

  (:action tiny_stories__story_027_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_027_active)
        (tiny_stories__story_027_type_character ?character)
        (tiny_stories__story_027_type_place ?from)
        (tiny_stories__story_027_type_place ?to)
        (and
          (not (= ?from ?to))
          (shared_p_consensus_099c36231bddb279 ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_099c36231bddb279 ?character ?from))
        (shared_p_consensus_099c36231bddb279 ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_028_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_028_active)
        (tiny_stories__story_028_type_character ?character)
        (tiny_stories__story_028_type_item ?item)
        (and
          (not (shared_p_consensus_ab4e864fb5b1d91c ?character ?item))
          (tiny_stories__story_028_p_reads ?character)
        )
      )
    :effect
      (shared_p_consensus_ab4e864fb5b1d91c ?character ?item)
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
          (shared_p_consensus_ab4e864fb5b1d91c ?character ?item)
          (tiny_stories__story_028_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ab4e864fb5b1d91c ?character ?item))
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
      (shared_p_consensus_56a05c5a999b1478 ?character)
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
      (shared_p_consensus_56a05c5a999b1478 ?character)
    :agents (?character)
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
        (shared_p_consensus_56a05c5a999b1478 ?helpee)
        (tiny_stories__story_086_p_helping ?helper ?helpee)
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
          (shared_p_consensus_56a05c5a999b1478 ?character)
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
          (tiny_stories__story_086_p_helping ?character ?helpee)
        )
      )
    :effect
      (not (tiny_stories__story_086_p_spider-on-wall))
    :agents (?character)
  )

  (:action writing_prompts__wp_049_a_remind-ancient-oath
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_ancient-oath ?dog)
        )
      )
    :effect
      (writing_prompts__wp_049_p_needs-walk ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_bring-to-herenow
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (not (writing_prompts__wp_049_p_in-herenow ?master))
        )
      )
    :effect
      (writing_prompts__wp_049_p_in-herenow ?master)
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_walk
    :parameters (?dog - object ?master - object)
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (writing_prompts__wp_049_type_character ?dog)
        (writing_prompts__wp_049_type_character ?master)
        (and
          (writing_prompts__wp_049_p_guardian ?dog)
          (writing_prompts__wp_049_p_master ?master)
          (writing_prompts__wp_049_p_needs-walk ?master)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_049_p_needs-walk ?master))
        (writing_prompts__wp_049_p_in-herenow ?master)
      )
    :agents (?dog)
  )

  (:action writing_prompts__wp_049_a_time-of-passing
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_049_active)
        (not (writing_prompts__wp_049_p_time-of-passing))
      )
    :effect
      (writing_prompts__wp_049_p_time-of-passing)
  )
)
