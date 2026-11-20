(define (problem human__causal_link__k02__032)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (human_1fe4b2f08d46fd1e_active)
    (human_cf10335d299ae37f_active)
    (human_1fe4b2f08d46fd1e_type_creature r0)
    (human_1fe4b2f08d46fd1e_type_object r0)
    (human_cf10335d299ae37f_type_creature r0)
    (human_cf10335d299ae37f_type_object r0)
    (human_cf10335d299ae37f_type_place r0)
    (human_1fe4b2f08d46fd1e_type_object r1)
    (human_1fe4b2f08d46fd1e_type_place r1)
    (human_1fe4b2f08d46fd1e_type_object r2)
    (human_1fe4b2f08d46fd1e_type_place r2)
    (human_cf10335d299ae37f_type_object r2)
    (human_cf10335d299ae37f_type_place r2)
    (human_cf10335d299ae37f_type_creature r3)
    (human_cf10335d299ae37f_type_object r3)
    (human_cf10335d299ae37f_type_place r3)
    (human_1fe4b2f08d46fd1e_p_alive r0)
    (human_1fe4b2f08d46fd1e_p_at r0 r1)
    (human_cf10335d299ae37f_p_alive r3)
    (human_cf10335d299ae37f_p_at r3 r2)
    (intends r0 (human_cf10335d299ae37f_p_friends r0 r3))
  )
  (:goal (human_cf10335d299ae37f_p_friends r0 r3))
)
