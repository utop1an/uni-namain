(define (problem human__random__k02__044)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (human_67ab241b327ccef0_active)
    (human_cf10335d299ae37f_active)
    (human_67ab241b327ccef0_type_character r0)
    (human_67ab241b327ccef0_type_object r0)
    (human_cf10335d299ae37f_type_creature r0)
    (human_cf10335d299ae37f_type_object r0)
    (human_cf10335d299ae37f_type_place r0)
    (human_67ab241b327ccef0_type_object r1)
    (human_67ab241b327ccef0_type_room r1)
    (human_67ab241b327ccef0_type_object r2)
    (human_67ab241b327ccef0_type_room r2)
    (human_cf10335d299ae37f_type_object r2)
    (human_cf10335d299ae37f_type_place r2)
    (human_cf10335d299ae37f_type_creature r3)
    (human_cf10335d299ae37f_type_object r3)
    (human_cf10335d299ae37f_type_place r3)
    (shared_p_consensus_c4fc74abf4689d2b r0 r1)
    (human_cf10335d299ae37f_p_alive r0)
    (human_cf10335d299ae37f_p_alive r3)
    (shared_p_consensus_c4fc74abf4689d2b r3 r2)
    (intends r0 (human_cf10335d299ae37f_p_friends r0 r3))
  )
  (:goal (human_cf10335d299ae37f_p_friends r0 r3))
)
