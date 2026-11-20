(define (problem human__random__k02__010)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (human_1fe4b2f08d46fd1e_active)
    (human_7c98a61edf861243_active)
    (human_1fe4b2f08d46fd1e_type_creature r0)
    (human_1fe4b2f08d46fd1e_type_object r0)
    (human_7c98a61edf861243_type_character r0)
    (human_7c98a61edf861243_type_object r0)
    (human_1fe4b2f08d46fd1e_type_object r1)
    (human_1fe4b2f08d46fd1e_type_place r1)
    (human_1fe4b2f08d46fd1e_type_object r2)
    (human_1fe4b2f08d46fd1e_type_place r2)
    (human_7c98a61edf861243_type_object r2)
    (human_7c98a61edf861243_type_room r2)
    (human_7c98a61edf861243_type_object r3)
    (human_7c98a61edf861243_type_thing r3)
    (human_1fe4b2f08d46fd1e_p_alive r0)
    (human_1fe4b2f08d46fd1e_p_at r0 r1)
    (human_7c98a61edf861243_p_believes-at r0 r0 r2)
    (human_7c98a61edf861243_p_believes-in r0 r3 r2)
    (human_7c98a61edf861243_p_in r3 r2)
    (intends r0 (human_7c98a61edf861243_p_has r0 r3))
  )
  (:goal (human_7c98a61edf861243_p_has r0 r3))
)
