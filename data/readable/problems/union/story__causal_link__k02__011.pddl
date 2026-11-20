(define (problem story__causal_link__k02__011)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_011_type_character r0)
    (writing_prompts__wp_011_type_object r0)
    (writing_prompts__wp_035_type_character r0)
    (writing_prompts__wp_035_type_object r0)
    (writing_prompts__wp_011_type_object r1)
    (writing_prompts__wp_035_type_item r1)
    (writing_prompts__wp_035_type_object r1)
    (writing_prompts__wp_011_type_object r2)
    (writing_prompts__wp_011_type_place r2)
    (writing_prompts__wp_035_type_item r3)
    (writing_prompts__wp_035_type_object r3)
    (writing_prompts__wp_011_p_alive r0)
    (writing_prompts__wp_011_p_at r0 r2)
    (writing_prompts__wp_035_p_wearing r0 r3)
    (intends r0 (writing_prompts__wp_035_p_wearing r0 r1))
  )
  (:goal (writing_prompts__wp_035_p_wearing r0 r1))
)
