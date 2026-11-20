(define (problem human__random__k02__007)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
    r4 - object
  )
  (:init
    (human_1fe4b2f08d46fd1e_active)
    (human_230a940d5d5977a6_active)
    (human_1fe4b2f08d46fd1e_type_creature r0)
    (human_1fe4b2f08d46fd1e_type_object r0)
    (human_230a940d5d5977a6_type_actor r0)
    (human_230a940d5d5977a6_type_object r0)
    (human_230a940d5d5977a6_type_police r0)
    (human_1fe4b2f08d46fd1e_type_object r1)
    (human_1fe4b2f08d46fd1e_type_place r1)
    (human_1fe4b2f08d46fd1e_type_object r2)
    (human_1fe4b2f08d46fd1e_type_place r2)
    (human_230a940d5d5977a6_type_object r2)
    (human_230a940d5d5977a6_type_place r2)
    (human_230a940d5d5977a6_type_crime r3)
    (human_230a940d5d5977a6_type_object r3)
    (human_230a940d5d5977a6_type_item r4)
    (human_230a940d5d5977a6_type_object r4)
    (human_1fe4b2f08d46fd1e_p_alive r0)
    (human_1fe4b2f08d46fd1e_p_at r0 r1)
    (human_230a940d5d5977a6_p_clue r3 r4 r2)
    (intends r0 (human_230a940d5d5977a6_p_knows-clue r0 r3 r4))
  )
  (:goal (human_230a940d5d5977a6_p_knows-clue r0 r3 r4))
)
