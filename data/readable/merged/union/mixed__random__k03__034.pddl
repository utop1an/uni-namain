(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_054_o_crucifix - object)
  (:predicates
    (human_72bec7307b121ea5_active)
    (human_72bec7307b121ea5_type_book ?x - object)
    (human_72bec7307b121ea5_type_character ?x - object)
    (human_72bec7307b121ea5_type_item ?x - object)
    (human_72bec7307b121ea5_type_location ?x - object)
    (human_72bec7307b121ea5_type_object ?x - object)
    (human_72bec7307b121ea5_type_ring ?x - object)
    (human_72bec7307b121ea5_type_sword ?x - object)
    (human_72bec7307b121ea5_type_thing ?x - object)
    (human_72bec7307b121ea5_p_player ?v0 - object)
    (human_72bec7307b121ea5_p_at ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_has ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_asleep ?v0 - object)
    (human_72bec7307b121ea5_p_connected ?v0 - object ?v1 - object)
    (human_72bec7307b121ea5_p_enchanted ?v0 - object)
    (human_72bec7307b121ea5_p_is ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_active)
    (writing_prompts__wp_054_type_character ?x - object)
    (writing_prompts__wp_054_type_item ?x - object)
    (writing_prompts__wp_054_type_object ?x - object)
    (writing_prompts__wp_054_type_place ?x - object)
    (writing_prompts__wp_054_type_weapon ?x - object)
    (writing_prompts__wp_054_p_alive ?v0 - object)
    (writing_prompts__wp_054_p_armed ?v0 - object)
    (writing_prompts__wp_054_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_hidden ?v0 - object ?v1 - object)
    (writing_prompts__wp_054_p_informant ?v0 - object)
    (writing_prompts__wp_054_p_target ?v0 - object)
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
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (not (writing_prompts__wp_054_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_054_type_weapon ?w) (writing_prompts__wp_054_p_has ?character ?w))))) :implies (writing_prompts__wp_054_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_054_active) (writing_prompts__wp_054_type_character ?character) (and (writing_prompts__wp_054_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_054_type_weapon ?w)) (not (writing_prompts__wp_054_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_054_p_armed ?character)))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (not (writing_prompts__wp_056_p_armed ?character)) (exists (?w - object) (and (writing_prompts__wp_056_type_weapon ?w) (writing_prompts__wp_056_p_has ?character ?w))))) :implies (writing_prompts__wp_056_p_armed ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_056_active) (writing_prompts__wp_056_type_character ?character) (and (writing_prompts__wp_056_p_armed ?character) (forall (?w - object) (or (not (writing_prompts__wp_056_type_weapon ?w)) (not (writing_prompts__wp_056_p_has ?character ?w)))))) :implies (not (writing_prompts__wp_056_p_armed ?character)))

  (:action human_72bec7307b121ea5_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?character)
        (human_72bec7307b121ea5_type_location ?to)
        (human_72bec7307b121ea5_type_location ?from)
        (and
          (human_72bec7307b121ea5_p_connected ?to ?from)
          (not (human_72bec7307b121ea5_p_asleep ?character))
          (human_72bec7307b121ea5_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (human_72bec7307b121ea5_p_at ?character ?from))
        (human_72bec7307b121ea5_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action human_72bec7307b121ea5_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?waker)
        (human_72bec7307b121ea5_type_character ?woken)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?waker ?location)
          (human_72bec7307b121ea5_p_at ?woken ?location)
          (human_72bec7307b121ea5_p_asleep ?woken)
          (not (human_72bec7307b121ea5_p_asleep ?waker))
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_asleep ?woken))
    :agents (?waker)
  )

  (:action human_72bec7307b121ea5_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?taker)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?taker ?location)
          (human_72bec7307b121ea5_p_at ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?taker))
          (not (human_72bec7307b121ea5_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (human_72bec7307b121ea5_p_at ?thing ?location))
        (human_72bec7307b121ea5_p_has ?taker ?thing)
      )
    :agents (?taker)
  )

  (:action human_72bec7307b121ea5_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_72bec7307b121ea5_active)
        (human_72bec7307b121ea5_type_character ?caster)
        (human_72bec7307b121ea5_type_item ?thing)
        (human_72bec7307b121ea5_type_book ?book)
        (human_72bec7307b121ea5_type_location ?location)
        (and
          (human_72bec7307b121ea5_p_at ?caster ?location)
          (human_72bec7307b121ea5_p_at ?thing ?location)
          (not (human_72bec7307b121ea5_p_asleep ?caster))
          (human_72bec7307b121ea5_p_has ?caster ?book)
          (human_72bec7307b121ea5_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_72bec7307b121ea5_p_enchanted ?thing))
    :agents (?caster)
  )

  (:action writing_prompts__wp_054_a_retrieve
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_hidden ?item ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_hidden ?item ?place))
        (writing_prompts__wp_054_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_hide
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_item ?item)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?place)
          (writing_prompts__wp_054_p_has ?character ?item)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_has ?character ?item))
        (writing_prompts__wp_054_p_hidden ?item ?place)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_054_a_kill
    :parameters (?killer - object ?weapon - object ?victim - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?killer)
        (writing_prompts__wp_054_type_weapon ?weapon)
        (writing_prompts__wp_054_type_character ?victim)
        (writing_prompts__wp_054_type_place ?place)
        (and
          (writing_prompts__wp_054_p_alive ?killer)
          (writing_prompts__wp_054_p_at ?killer ?place)
          (writing_prompts__wp_054_p_has ?killer ?weapon)
          (writing_prompts__wp_054_p_alive ?victim)
          (writing_prompts__wp_054_p_at ?victim ?place)
        )
      )
    :effect
      (not (writing_prompts__wp_054_p_alive ?victim))
    :agents (?killer)
  )

  (:action writing_prompts__wp_054_a_travel
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_054_active)
        (writing_prompts__wp_054_type_character ?character)
        (writing_prompts__wp_054_type_place ?from)
        (writing_prompts__wp_054_type_place ?to)
        (and
          (not (= ?from ?to))
          (writing_prompts__wp_054_p_alive ?character)
          (writing_prompts__wp_054_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_054_p_at ?character ?from))
        (writing_prompts__wp_054_p_at ?character ?to)
      )
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
