(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing :universal-preconditions)
  (:types)
  (:predicates
    (human_4d95b598471c21ee_active)
    (human_4d95b598471c21ee_type_book ?x - object)
    (human_4d95b598471c21ee_type_character ?x - object)
    (human_4d95b598471c21ee_type_item ?x - object)
    (human_4d95b598471c21ee_type_location ?x - object)
    (human_4d95b598471c21ee_type_object ?x - object)
    (human_4d95b598471c21ee_type_ring ?x - object)
    (human_4d95b598471c21ee_type_sword ?x - object)
    (human_4d95b598471c21ee_type_thing ?x - object)
    (human_4d95b598471c21ee_p_player ?v0 - object)
    (shared_p_consensus_ba2ff19473b3f8fa ?v0 - object ?v1 - object)
    (shared_p_consensus_24958e47a226ea84 ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_asleep ?v0 - object)
    (human_4d95b598471c21ee_p_connected ?v0 - object ?v1 - object)
    (human_4d95b598471c21ee_p_enchanted ?v0 - object)
    (human_4d95b598471c21ee_p_is ?v0 - object ?v1 - object)
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (tiny_stories__story_092_p_worried ?v0 - object)
    (tiny_stories__story_092_p_accepted-to-university ?v0 - object)
    (tiny_stories__story_092_p_happy ?v0 - object)
    (tiny_stories__story_092_p_applauding ?v0 - object)
    (tiny_stories__story_092_p_hardworking ?v0 - object)
    (tiny_stories__story_092_p_dreams-come-true ?v0 - object)
    (tiny_stories__story_095_active)
    (tiny_stories__story_095_type_character ?x - object)
    (tiny_stories__story_095_type_object ?x - object)
    (tiny_stories__story_095_type_place ?x - object)
    (tiny_stories__story_095_type_seat ?x - object)
    (tiny_stories__story_095_p_sitting ?v0 - object ?v1 - object)
    (tiny_stories__story_095_p_broken ?v0 - object)
    (tiny_stories__story_095_p_big ?v0 - object)
    (tiny_stories__story_095_p_small ?v0 - object)
    (tiny_stories__story_095_p_important ?v0 - object)
    (writing_prompts__wp_077_active)
    (writing_prompts__wp_077_type_object ?x - object)
    (writing_prompts__wp_077_type_poem ?x - object)
    (writing_prompts__wp_077_type_reader ?x - object)
    (writing_prompts__wp_077_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_077_p_alive ?v0 - object)
    (writing_prompts__wp_077_p_dead ?v0 - object)
    (writing_prompts__wp_077_p_echo ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action human_4d95b598471c21ee_a_move-location
    :parameters (?character - object ?to - object ?from - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?character)
        (human_4d95b598471c21ee_type_location ?to)
        (human_4d95b598471c21ee_type_location ?from)
        (and
          (human_4d95b598471c21ee_p_connected ?to ?from)
          (not (human_4d95b598471c21ee_p_asleep ?character))
          (shared_p_consensus_ba2ff19473b3f8fa ?character ?from)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ba2ff19473b3f8fa ?character ?from))
        (shared_p_consensus_ba2ff19473b3f8fa ?character ?to)
      )
  )

  (:action human_4d95b598471c21ee_a_wake-person
    :parameters (?waker - object ?woken - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?waker)
        (human_4d95b598471c21ee_type_character ?woken)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_ba2ff19473b3f8fa ?waker ?location)
          (shared_p_consensus_ba2ff19473b3f8fa ?woken ?location)
          (human_4d95b598471c21ee_p_asleep ?woken)
          (not (human_4d95b598471c21ee_p_asleep ?waker))
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_asleep ?woken))
  )

  (:action human_4d95b598471c21ee_a_take-thing
    :parameters (?taker - object ?thing - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?taker)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_ba2ff19473b3f8fa ?taker ?location)
          (shared_p_consensus_ba2ff19473b3f8fa ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?taker))
          (not (human_4d95b598471c21ee_p_enchanted ?thing))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_ba2ff19473b3f8fa ?thing ?location))
        (shared_p_consensus_24958e47a226ea84 ?taker ?thing)
      )
  )

  (:action human_4d95b598471c21ee_a_disenchant-thing
    :parameters (?caster - object ?thing - object ?book - object ?location - object)
    :precondition
      (and
        (human_4d95b598471c21ee_active)
        (human_4d95b598471c21ee_type_character ?caster)
        (human_4d95b598471c21ee_type_item ?thing)
        (human_4d95b598471c21ee_type_book ?book)
        (human_4d95b598471c21ee_type_location ?location)
        (and
          (shared_p_consensus_ba2ff19473b3f8fa ?caster ?location)
          (shared_p_consensus_ba2ff19473b3f8fa ?thing ?location)
          (not (human_4d95b598471c21ee_p_asleep ?caster))
          (shared_p_consensus_24958e47a226ea84 ?caster ?book)
          (human_4d95b598471c21ee_p_enchanted ?thing)
        )
      )
    :effect
      (not (human_4d95b598471c21ee_p_enchanted ?thing))
  )

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (shared_p_consensus_24958e47a226ea84 ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (shared_p_consensus_24958e47a226ea84 ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_092_a_get-accepted
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_worried ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_092_p_accepted-to-university ?character)
        (not (tiny_stories__story_092_p_worried ?character))
        (tiny_stories__story_092_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_start-applauding
    :parameters (?character - object ?other - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_type_character ?other)
        (and
          (not (tiny_stories__story_092_p_applauding ?character))
          (tiny_stories__story_092_p_happy ?other)
        )
      )
    :effect
      (tiny_stories__story_092_p_applauding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_stop-applauding
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_p_applauding ?character)
      )
    :effect
      (not (tiny_stories__story_092_p_applauding ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_make-dreams-come-true
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_accepted-to-university ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (tiny_stories__story_092_p_dreams-come-true ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_place ?place)
        (not (shared_p_consensus_ba2ff19473b3f8fa ?character ?place))
      )
    :effect
      (shared_p_consensus_ba2ff19473b3f8fa ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_sit
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (and
          (not (tiny_stories__story_095_p_sitting ?character ?seat))
          (not (tiny_stories__story_095_p_broken ?seat))
        )
      )
    :effect
      (tiny_stories__story_095_p_sitting ?character ?seat)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_leave
    :parameters (?character - object ?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_type_seat ?seat)
        (tiny_stories__story_095_p_sitting ?character ?seat)
      )
    :effect
      (not (tiny_stories__story_095_p_sitting ?character ?seat))
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_break-seat
    :parameters (?seat - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_seat ?seat)
        (not (tiny_stories__story_095_p_broken ?seat))
      )
    :effect
      (tiny_stories__story_095_p_broken ?seat)
  )

  (:action tiny_stories__story_095_a_become-important
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (not (tiny_stories__story_095_p_important ?character))
      )
    :effect
      (tiny_stories__story_095_p_important ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_095_a_become-unimportant
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_095_active)
        (tiny_stories__story_095_type_character ?character)
        (tiny_stories__story_095_p_important ?character)
      )
    :effect
      (not (tiny_stories__story_095_p_important ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_077_a_read-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (not (writing_prompts__wp_077_p_read ?reader ?poem))
          (writing_prompts__wp_077_p_alive ?poem)
        )
      )
    :effect
      (and
        (writing_prompts__wp_077_p_read ?reader ?poem)
        (writing_prompts__wp_077_p_echo ?reader ?poem)
      )
    :agents (?reader)
  )

  (:action writing_prompts__wp_077_a_poem-dies
    :parameters (?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_poem ?poem)
        (writing_prompts__wp_077_p_alive ?poem)
      )
    :effect
      (and
        (not (writing_prompts__wp_077_p_alive ?poem))
        (writing_prompts__wp_077_p_dead ?poem)
      )
  )

  (:action writing_prompts__wp_077_a_echo-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (writing_prompts__wp_077_p_read ?reader ?poem)
          (not (writing_prompts__wp_077_p_echo ?reader ?poem))
        )
      )
    :effect
      (writing_prompts__wp_077_p_echo ?reader ?poem)
    :agents (?reader)
  )
)
