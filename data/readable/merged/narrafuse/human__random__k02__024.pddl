(define (domain revised_merged)
  (:requirements :adl :intentionality :negative-preconditions :strips :typing)
  (:types)
  (:predicates
    (human_281c51d26d5d4ff3_active)
    (human_281c51d26d5d4ff3_type_allworker ?x - object)
    (human_281c51d26d5d4ff3_type_axe ?x - object)
    (human_281c51d26d5d4ff3_type_beast ?x - object)
    (human_281c51d26d5d4ff3_type_blacksmith ?x - object)
    (human_281c51d26d5d4ff3_type_cake ?x - object)
    (human_281c51d26d5d4ff3_type_character ?x - object)
    (human_281c51d26d5d4ff3_type_fox ?x - object)
    (human_281c51d26d5d4ff3_type_girl ?x - object)
    (human_281c51d26d5d4ff3_type_grandmother ?x - object)
    (human_281c51d26d5d4ff3_type_house ?x - object)
    (human_281c51d26d5d4ff3_type_human ?x - object)
    (human_281c51d26d5d4ff3_type_hunter ?x - object)
    (human_281c51d26d5d4ff3_type_object ?x - object)
    (human_281c51d26d5d4ff3_type_thing ?x - object)
    (human_281c51d26d5d4ff3_type_wolf ?x - object)
    (human_281c51d26d5d4ff3_type_worker ?x - object)
    (human_281c51d26d5d4ff3_p_monster ?v0 - object)
    (human_281c51d26d5d4ff3_p_monster-alive)
    (human_281c51d26d5d4ff3_p_rescuer ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescuer-at ?v0 - object)
    (human_281c51d26d5d4ff3_p_alive ?v0 - object)
    (shared_p_consensus_c3518275a82e1926 ?v0 - object ?v1 - object)
    (human_281c51d26d5d4ff3_p_eaten ?v0 - object)
    (human_281c51d26d5d4ff3_p_rescued ?v0 - object)
    (shared_p_consensus_9ff1cab57ca7b157 ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_active)
    (human_67ab241b327ccef0_type_character ?x - object)
    (human_67ab241b327ccef0_type_key ?x - object)
    (human_67ab241b327ccef0_type_letter ?x - object)
    (human_67ab241b327ccef0_type_object ?x - object)
    (human_67ab241b327ccef0_type_room ?x - object)
    (human_67ab241b327ccef0_type_star ?x - object)
    (human_67ab241b327ccef0_type_thing ?x - object)
    (human_67ab241b327ccef0_p_locked ?v0 - object)
    (human_67ab241b327ccef0_p_unlocked-by ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_in ?v0 - object ?v1 - object)
    (human_67ab241b327ccef0_p_hidden ?v0 - object)
  )

  (:action human_281c51d26d5d4ff3_a_walk
    :parameters (?c - object ?h1 - object ?h2 - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_character ?c)
        (human_281c51d26d5d4ff3_type_house ?h1)
        (human_281c51d26d5d4ff3_type_house ?h2)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (shared_p_consensus_9ff1cab57ca7b157 ?c ?h1)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9ff1cab57ca7b157 ?c ?h1))
        (shared_p_consensus_9ff1cab57ca7b157 ?c ?h2)
        (when
          (human_281c51d26d5d4ff3_p_rescuer ?c)
          (and
            (human_281c51d26d5d4ff3_p_rescuer-at ?h2)
            (not (human_281c51d26d5d4ff3_p_rescuer-at ?h1))
          )
        )
      )
  )

  (:action human_281c51d26d5d4ff3_a_eat
    :parameters (?m - object ?c - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?m)
          (human_281c51d26d5d4ff3_p_alive ?c)
          (not (human_281c51d26d5d4ff3_p_eaten ?c))
          (shared_p_consensus_9ff1cab57ca7b157 ?m ?h)
          (shared_p_consensus_9ff1cab57ca7b157 ?c ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
        )
      )
    :effect
      (human_281c51d26d5d4ff3_p_eaten ?c)
  )

  (:action human_281c51d26d5d4ff3_a_kill
    :parameters (?c - object ?m - object ?a - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_worker ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_axe ?a)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_alive ?c)
          (human_281c51d26d5d4ff3_p_alive ?m)
          (shared_p_consensus_c3518275a82e1926 ?c ?a)
          (shared_p_consensus_9ff1cab57ca7b157 ?c ?h)
          (shared_p_consensus_9ff1cab57ca7b157 ?m ?h)
          (human_281c51d26d5d4ff3_p_monster ?m)
          (human_281c51d26d5d4ff3_p_monster-alive)
          (human_281c51d26d5d4ff3_p_rescuer ?c)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_alive ?m))
        (not (human_281c51d26d5d4ff3_p_monster-alive))
      )
  )

  (:action human_281c51d26d5d4ff3_a_escape
    :parameters (?c - object ?m - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c)
        (human_281c51d26d5d4ff3_type_wolf ?m)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (human_281c51d26d5d4ff3_p_eaten ?c)
          (not (human_281c51d26d5d4ff3_p_alive ?m))
          (shared_p_consensus_9ff1cab57ca7b157 ?m ?h)
        )
      )
    :effect
      (and
        (not (human_281c51d26d5d4ff3_p_eaten ?c))
        (human_281c51d26d5d4ff3_p_rescued ?c)
        (shared_p_consensus_9ff1cab57ca7b157 ?c ?h)
      )
  )

  (:action human_281c51d26d5d4ff3_a_give
    :parameters (?c1 - object ?c2 - object ?t - object ?h - object)
    :precondition
      (and
        (human_281c51d26d5d4ff3_active)
        (human_281c51d26d5d4ff3_type_human ?c1)
        (human_281c51d26d5d4ff3_type_human ?c2)
        (human_281c51d26d5d4ff3_type_thing ?t)
        (human_281c51d26d5d4ff3_type_house ?h)
        (and
          (not (human_281c51d26d5d4ff3_p_eaten ?c2))
          (human_281c51d26d5d4ff3_p_alive ?c1)
          (human_281c51d26d5d4ff3_p_alive ?c2)
          (shared_p_consensus_c3518275a82e1926 ?c1 ?t)
          (shared_p_consensus_9ff1cab57ca7b157 ?c1 ?h)
          (shared_p_consensus_9ff1cab57ca7b157 ?c2 ?h)
        )
      )
    :effect
      (and
        (shared_p_consensus_c3518275a82e1926 ?c2 ?t)
        (not (shared_p_consensus_c3518275a82e1926 ?c1 ?t))
      )
  )

  (:action human_67ab241b327ccef0_a_enter
    :parameters (?character - object ?roomfrom - object ?roomto - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_room ?roomfrom)
        (human_67ab241b327ccef0_type_room ?roomto)
        (and
          (not (human_67ab241b327ccef0_p_locked ?roomto))
          (shared_p_consensus_9ff1cab57ca7b157 ?character ?roomfrom)
        )
      )
    :effect
      (and
        (not (shared_p_consensus_9ff1cab57ca7b157 ?character ?roomfrom))
        (shared_p_consensus_9ff1cab57ca7b157 ?character ?roomto)
      )
  )

  (:action human_67ab241b327ccef0_a_search-for
    :parameters (?character - object ?thing - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_thing ?thing)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (shared_p_consensus_9ff1cab57ca7b157 ?character ?room)
          (human_67ab241b327ccef0_p_in ?thing ?room)
        )
      )
    :effect
      (and
        (shared_p_consensus_c3518275a82e1926 ?character ?thing)
        (not (human_67ab241b327ccef0_p_in ?thing ?room))
      )
  )

  (:action human_67ab241b327ccef0_a_unlock
    :parameters (?character - object ?key - object ?room - object)
    :precondition
      (and
        (human_67ab241b327ccef0_active)
        (human_67ab241b327ccef0_type_character ?character)
        (human_67ab241b327ccef0_type_key ?key)
        (human_67ab241b327ccef0_type_room ?room)
        (and
          (human_67ab241b327ccef0_p_locked ?room)
          (human_67ab241b327ccef0_p_unlocked-by ?room ?key)
          (shared_p_consensus_c3518275a82e1926 ?character ?key)
        )
      )
    :effect
      (not (human_67ab241b327ccef0_p_locked ?room))
  )
)
