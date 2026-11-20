(define (problem story__random__k02__040)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
  )
  (:init
    (writing_prompts__wp_032_active)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character r0)
    (writing_prompts__wp_042_type_object r0)
    (writing_prompts__wp_032_type_character r0)
    (writing_prompts__wp_032_type_object r0)
    (writing_prompts__wp_042_type_object r1)
    (writing_prompts__wp_042_type_place r1)
    (writing_prompts__wp_032_type_object r1)
    (writing_prompts__wp_032_type_place r1)
    (writing_prompts__wp_042_p_alive r0)
    (writing_prompts__wp_032_p_wolves-attack r1)
    (intends r0 (writing_prompts__wp_032_p_wolves-killed r0))
  )
  (:goal (writing_prompts__wp_032_p_wolves-killed r0))
)
