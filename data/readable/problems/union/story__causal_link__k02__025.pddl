(define (problem story__causal_link__k02__025)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_060_active)
    (writing_prompts__wp_011_type_character r0)
    (writing_prompts__wp_011_type_object r0)
    (writing_prompts__wp_060_type_character r0)
    (writing_prompts__wp_060_type_object r0)
    (writing_prompts__wp_011_type_object r1)
    (writing_prompts__wp_060_type_item r1)
    (writing_prompts__wp_060_type_object r1)
    (writing_prompts__wp_011_type_object r2)
    (writing_prompts__wp_011_type_place r2)
    (writing_prompts__wp_011_p_alive r0)
    (writing_prompts__wp_011_p_at r0 r2)
    (intends r0 (writing_prompts__wp_060_p_fits r1 r0))
  )
  (:goal (writing_prompts__wp_060_p_fits r1 r0))
)
