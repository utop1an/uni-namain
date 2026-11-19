(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_048_o_blood - object writing_prompts__wp_048_o_sweat - object writing_prompts__wp_048_o_tears - object writing_prompts__wp_048_o_death - object)
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
    (writing_prompts__wp_048_active)
    (writing_prompts__wp_048_type_character ?x - object)
    (writing_prompts__wp_048_type_object ?x - object)
    (writing_prompts__wp_048_type_trial ?x - object)
    (writing_prompts__wp_048_p_dead ?v0 - object)
    (writing_prompts__wp_048_p_alive ?v0 - object)
    (writing_prompts__wp_048_p_completed ?v0 - object ?v1 - object)
    (writing_prompts__wp_048_p_offered ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_alive ?character))) :implies (writing_prompts__wp_048_p_dead ?character))
  (:axiom :vars (?character - object) :context (and (writing_prompts__wp_048_active) (writing_prompts__wp_048_type_character ?character) (not (writing_prompts__wp_048_p_dead ?character))) :implies (writing_prompts__wp_048_p_alive ?character))

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

  (:action writing_prompts__wp_048_a_offer-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (not (writing_prompts__wp_048_p_offered ?character ?trial))
        )
      )
    :effect
      (writing_prompts__wp_048_p_offered ?character ?trial)
    :agents (writing_prompts__wp_048_o_death)
  )

  (:action writing_prompts__wp_048_a_choose-trial
    :parameters (?character - object ?trial - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (writing_prompts__wp_048_type_trial ?trial)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (writing_prompts__wp_048_p_offered ?character ?trial)
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_completed ?character ?trial)
        (not (writing_prompts__wp_048_p_offered ?character ?trial))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_048_a_rebirth
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_048_active)
        (writing_prompts__wp_048_type_character ?character)
        (and
          (writing_prompts__wp_048_p_dead ?character)
          (or
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat)
            (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears)
          )
        )
      )
    :effect
      (and
        (writing_prompts__wp_048_p_alive ?character)
        (not (writing_prompts__wp_048_p_dead ?character))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_blood))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_sweat))
        (not (writing_prompts__wp_048_p_completed ?character writing_prompts__wp_048_o_tears))
      )
    :agents (writing_prompts__wp_048_o_death)
  )
)
