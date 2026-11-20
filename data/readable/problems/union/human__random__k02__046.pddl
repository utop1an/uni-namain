(define (problem human__random__k02__046)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (human_72bec7307b121ea5_active)
    (human_8fa5775aae174731_active)
    (human_72bec7307b121ea5_type_character r0)
    (human_72bec7307b121ea5_type_object r0)
    (human_8fa5775aae174731_type_character r0)
    (human_8fa5775aae174731_type_object r0)
    (human_72bec7307b121ea5_type_location r1)
    (human_72bec7307b121ea5_type_object r1)
    (human_72bec7307b121ea5_type_location r2)
    (human_72bec7307b121ea5_type_object r2)
    (human_8fa5775aae174731_type_object r2)
    (human_8fa5775aae174731_type_place r2)
    (human_8fa5775aae174731_type_item r3)
    (human_8fa5775aae174731_type_object r3)
    (human_8fa5775aae174731_type_item human_8fa5775aae174731_o_ark)
    (human_8fa5775aae174731_type_object human_8fa5775aae174731_o_ark)
    (human_72bec7307b121ea5_p_connected r2 r1)
    (human_72bec7307b121ea5_p_at r0 r1)
    (human_8fa5775aae174731_p_alive r0)
    (human_8fa5775aae174731_p_burried r3 r2)
    (human_8fa5775aae174731_p_knows-location r0 r3 r2)
    (intends r0 (human_8fa5775aae174731_p_has r0 r3))
  )
  (:goal (human_8fa5775aae174731_p_has r0 r3))
)
