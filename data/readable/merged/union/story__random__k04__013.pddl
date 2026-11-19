(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_018_active)
    (tiny_stories__story_018_type_character ?x - object)
    (tiny_stories__story_018_type_item ?x - object)
    (tiny_stories__story_018_type_object ?x - object)
    (tiny_stories__story_018_type_place ?x - object)
    (tiny_stories__story_018_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_hidden ?v0 - object ?v1 - object)
    (tiny_stories__story_018_p_open ?v0 - object)
    (tiny_stories__story_018_p_stored ?v0 - object ?v1 - object)
    (tiny_stories__story_038_active)
    (tiny_stories__story_038_type_character ?x - object)
    (tiny_stories__story_038_type_object ?x - object)
    (tiny_stories__story_038_type_place ?x - object)
    (tiny_stories__story_038_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_038_p_hiding ?v0 - object)
    (tiny_stories__story_038_p_seeking ?v0 - object)
    (tiny_stories__story_038_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (tiny_stories__story_093_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_035_type_character ?x - object)
    (writing_prompts__wp_035_type_item ?x - object)
    (writing_prompts__wp_035_type_object ?x - object)
    (writing_prompts__wp_035_type_place ?x - object)
    (writing_prompts__wp_035_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_alive ?v0 - object)
    (writing_prompts__wp_035_p_wearing ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_035_p_breathable ?v0 - object)
    (writing_prompts__wp_035_p_smoking ?v0 - object)
    (writing_prompts__wp_035_p_dancing ?v0 - object)
    (writing_prompts__wp_035_p_eating ?v0 - object)
    (writing_prompts__wp_035_p_shrunk ?v0 - object)
  )
  (:axiom :vars (?character - object ?place - object) :context (and (writing_prompts__wp_035_active) (writing_prompts__wp_035_type_character ?character) (writing_prompts__wp_035_type_place ?place) (and (writing_prompts__wp_035_p_at ?character ?place) (writing_prompts__wp_035_p_breathable ?place))) :implies (writing_prompts__wp_035_p_alive ?character))

  (:action tiny_stories__story_018_a_search
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_place ?place)
        (tiny_stories__story_018_p_at ?character ?place)
      )
    :effect
      (forall
        (?item - object)
        (when
          (and
            (tiny_stories__story_018_type_item ?item)
            (tiny_stories__story_018_p_hidden ?item ?place)
          )
          (tiny_stories__story_018_p_found ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (not (tiny_stories__story_018_p_open ?item))
        )
      )
    :effect
      (tiny_stories__story_018_p_open ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_018_a_store
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_018_active)
        (tiny_stories__story_018_type_character ?character)
        (tiny_stories__story_018_type_item ?item)
        (tiny_stories__story_018_type_place ?place)
        (and
          (tiny_stories__story_018_p_found ?character ?item)
          (tiny_stories__story_018_p_open ?item)
          (tiny_stories__story_018_p_at ?character ?place)
        )
      )
    :effect
      (tiny_stories__story_018_p_stored ?item ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_start-hiding
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_hiding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_start-seeking
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_type_place ?place)
        (tiny_stories__story_038_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_038_p_seeking ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_038_a_find
    :parameters (?seeker - object ?hider - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?seeker)
        (tiny_stories__story_038_type_character ?hider)
        (tiny_stories__story_038_type_place ?place)
        (and
          (tiny_stories__story_038_p_seeking ?seeker)
          (tiny_stories__story_038_p_hiding ?hider)
          (tiny_stories__story_038_p_at ?seeker ?place)
          (tiny_stories__story_038_p_at ?hider ?place)
        )
      )
    :effect
      (and
        (tiny_stories__story_038_p_found ?seeker ?hider)
        (not (tiny_stories__story_038_p_hiding ?hider))
      )
    :agents (?seeker)
  )

  (:action tiny_stories__story_038_a_stop-seeking
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_038_active)
        (tiny_stories__story_038_type_character ?character)
        (tiny_stories__story_038_p_seeking ?character)
      )
    :effect
      (not (tiny_stories__story_038_p_seeking ?character))
    :agents (?character)
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
          (tiny_stories__story_093_p_has ?character ?mop)
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
          (tiny_stories__story_093_p_has ?dog ?mop)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_093_p_has ?dog ?mop))
        (tiny_stories__story_093_p_has ?character ?mop)
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
          (not (writing_prompts__wp_035_p_at ?character ?to))
        )
      )
    :effect
      (writing_prompts__wp_035_p_at ?character ?to)
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
          (writing_prompts__wp_035_p_has ?character ?item)
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
          (writing_prompts__wp_035_p_has ?character ?item)
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
          (writing_prompts__wp_035_p_has ?character ?new-item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_035_p_wearing ?character ?old-item))
        (writing_prompts__wp_035_p_wearing ?character ?new-item)
      )
    :agents (?character)
  )
)
