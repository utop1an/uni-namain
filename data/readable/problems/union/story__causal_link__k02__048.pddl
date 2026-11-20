(define (problem story__causal_link__k02__048)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (writing_prompts__wp_035_active)
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_035_type_character r0)
    (writing_prompts__wp_035_type_object r0)
    (writing_prompts__wp_089_type_character r0)
    (writing_prompts__wp_089_type_object r0)
    (writing_prompts__wp_035_type_object r1)
    (writing_prompts__wp_035_type_place r1)
    (writing_prompts__wp_089_type_object r1)
    (writing_prompts__wp_089_type_room r1)
    (writing_prompts__wp_089_type_item r2)
    (writing_prompts__wp_089_type_object r2)
    (writing_prompts__wp_089_type_thing r2)
    (writing_prompts__wp_035_p_alive r0)
    (writing_prompts__wp_089_p_has r0 r2)
    (intends r0 (writing_prompts__wp_089_p_in r2 r1))
  )
  (:goal (writing_prompts__wp_089_p_in r2 r1))
)
