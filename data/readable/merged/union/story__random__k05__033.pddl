(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_039_active)
    (tiny_stories__story_039_type_cap ?x - object)
    (tiny_stories__story_039_type_character ?x - object)
    (tiny_stories__story_039_type_object ?x - object)
    (tiny_stories__story_039_type_place ?x - object)
    (tiny_stories__story_039_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_lost ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_searched ?v0 - object ?v1 - object)
    (tiny_stories__story_039_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_051_active)
    (tiny_stories__story_051_type_animal ?x - object)
    (tiny_stories__story_051_type_character ?x - object)
    (tiny_stories__story_051_type_object ?x - object)
    (tiny_stories__story_051_type_place ?x - object)
    (tiny_stories__story_051_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_hugged ?v0 - object ?v1 - object)
    (tiny_stories__story_051_p_door-open ?v0 - object)
    (tiny_stories__story_051_p_friendly ?v0 - object)
    (writing_prompts__wp_019_active)
    (writing_prompts__wp_019_type_character ?x - object)
    (writing_prompts__wp_019_type_item ?x - object)
    (writing_prompts__wp_019_type_object ?x - object)
    (writing_prompts__wp_019_type_place ?x - object)
    (writing_prompts__wp_019_p_alive ?v0 - object)
    (writing_prompts__wp_019_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_buried ?v0 - object ?v1 - object)
    (writing_prompts__wp_019_p_destroyed ?v0 - object)
    (writing_prompts__wp_019_p_explosives-set ?v0 - object)
    (writing_prompts__wp_059_active)
    (writing_prompts__wp_059_type_character ?x - object)
    (writing_prompts__wp_059_type_object ?x - object)
    (writing_prompts__wp_059_p_friend ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_needs-help ?v0 - object)
    (writing_prompts__wp_059_p_smiling ?v0 - object)
    (writing_prompts__wp_059_p_laughing ?v0 - object)
    (writing_prompts__wp_059_p_provides-help ?v0 - object ?v1 - object)
    (writing_prompts__wp_059_p_talks-to ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_active)
    (writing_prompts__wp_081_type_character ?x - object)
    (writing_prompts__wp_081_type_emotion ?x - object)
    (writing_prompts__wp_081_type_item ?x - object)
    (writing_prompts__wp_081_type_object ?x - object)
    (writing_prompts__wp_081_p_alive ?v0 - object)
    (writing_prompts__wp_081_p_has-emotion ?v0 - object ?v1 - object)
    (writing_prompts__wp_081_p_knows-change ?v0 - object)
    (writing_prompts__wp_081_p_memorize ?v0 - object)
  )
  (:axiom :vars (?character - object ?animal - object) :context (and (tiny_stories__story_051_active) (tiny_stories__story_051_type_character ?character) (tiny_stories__story_051_type_animal ?animal) (and (not (tiny_stories__story_051_p_friendly ?animal)) (tiny_stories__story_051_p_hugged ?character ?animal))) :implies (tiny_stories__story_051_p_friendly ?animal))

  (:action tiny_stories__story_039_a_search
    :parameters (?character - object ?cap - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_type_place ?place)
        (and
          (tiny_stories__story_039_p_at ?character ?place)
          (tiny_stories__story_039_p_lost ?character ?cap)
        )
      )
    :effect
      (tiny_stories__story_039_p_searched ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_find
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (and
          (tiny_stories__story_039_p_lost ?character ?cap)
          (forall
            (?place - object)
            (or
              (not (tiny_stories__story_039_type_place ?place))
              (tiny_stories__story_039_p_searched ?character ?place)
            )
          )
        )
      )
    :effect
      (and
        (tiny_stories__story_039_p_found ?character ?cap)
        (not (tiny_stories__story_039_p_lost ?character ?cap))
        (tiny_stories__story_039_p_has ?character ?cap)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_lose
    :parameters (?character - object ?cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?cap)
        (tiny_stories__story_039_p_has ?character ?cap)
      )
    :effect
      (and
        (tiny_stories__story_039_p_lost ?character ?cap)
        (not (tiny_stories__story_039_p_has ?character ?cap))
      )
    :agents (?character)
  )

  (:action tiny_stories__story_039_a_replace
    :parameters (?character - object ?old-cap - object ?new-cap - object)
    :precondition
      (and
        (tiny_stories__story_039_active)
        (tiny_stories__story_039_type_character ?character)
        (tiny_stories__story_039_type_cap ?old-cap)
        (tiny_stories__story_039_type_cap ?new-cap)
        (and
          (tiny_stories__story_039_p_found ?character ?old-cap)
          (not (tiny_stories__story_039_p_has ?character ?old-cap))
          (tiny_stories__story_039_p_has ?character ?new-cap)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_039_p_found ?character ?old-cap))
        (tiny_stories__story_039_p_has ?character ?old-cap)
        (not (tiny_stories__story_039_p_has ?character ?new-cap))
      )
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
          (tiny_stories__story_051_p_at ?character ?from)
          (tiny_stories__story_051_p_door-open ?to)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_051_p_at ?character ?from))
        (tiny_stories__story_051_p_at ?character ?to)
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
          (tiny_stories__story_051_p_at ?hugger ?place)
          (tiny_stories__story_051_p_at ?hugged ?place)
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
          (tiny_stories__story_051_p_at ?character ?place)
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
          (tiny_stories__story_051_p_at ?character ?place)
          (tiny_stories__story_051_p_door-open ?place)
        )
      )
    :effect
      (not (tiny_stories__story_051_p_door-open ?place))
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?from)
        (writing_prompts__wp_019_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_019_p_at ?character ?from))
        (writing_prompts__wp_019_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_set-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_019_p_explosives-set ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_detonate-explosives
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_place ?place)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_explosives-set ?place)
        )
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (writing_prompts__wp_019_type_item ?item)
            (writing_prompts__wp_019_p_buried ?item ?place)
          )
          (writing_prompts__wp_019_p_destroyed ?item)
        )
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_019_a_destroy-item
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (writing_prompts__wp_019_active)
        (writing_prompts__wp_019_type_character ?character)
        (writing_prompts__wp_019_type_item ?item)
        (and
          (writing_prompts__wp_019_p_alive ?character)
          (writing_prompts__wp_019_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_019_p_has ?character ?item))
        (writing_prompts__wp_019_p_destroyed ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_059_a_talk
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_talks-to ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_provide-help
    :parameters (?a - object ?b - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?a)
        (writing_prompts__wp_059_type_character ?b)
        (and
          (not (= ?a ?b))
          (writing_prompts__wp_059_p_friend ?a ?b)
          (writing_prompts__wp_059_p_needs-help ?b)
          (writing_prompts__wp_059_p_talks-to ?a ?b)
        )
      )
    :effect
      (writing_prompts__wp_059_p_provides-help ?a ?b)
    :agents (?a)
  )

  (:action writing_prompts__wp_059_a_start-smiling
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_smiling ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_smiling ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_059_a_start-laughing
    :parameters (?character - object ?a - object)
    :precondition
      (and
        (writing_prompts__wp_059_active)
        (writing_prompts__wp_059_type_character ?character)
        (writing_prompts__wp_059_type_character ?a)
        (and
          (not (writing_prompts__wp_059_p_laughing ?character))
          (writing_prompts__wp_059_p_provides-help ?a ?character)
        )
      )
    :effect
      (writing_prompts__wp_059_p_laughing ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_experience-emotion
    :parameters (?character - object ?emotion - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_type_emotion ?emotion)
        (writing_prompts__wp_081_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_081_p_has-emotion ?character ?emotion)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_notice-change
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (writing_prompts__wp_081_p_alive ?character)
      )
    :effect
      (writing_prompts__wp_081_p_knows-change ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_081_a_memorize-appearance
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_081_active)
        (writing_prompts__wp_081_type_character ?character)
        (and
          (writing_prompts__wp_081_p_alive ?character)
          (writing_prompts__wp_081_p_knows-change ?character)
        )
      )
    :effect
      (writing_prompts__wp_081_p_memorize ?character)
    :agents (?character)
  )
)
