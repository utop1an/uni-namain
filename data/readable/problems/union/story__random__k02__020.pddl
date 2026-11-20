(define (problem story__random__k02__020)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (tiny_stories__story_075_active)
    (writing_prompts__wp_064_active)
    (tiny_stories__story_075_type_character r0)
    (tiny_stories__story_075_type_object r0)
    (writing_prompts__wp_064_type_character r0)
    (writing_prompts__wp_064_type_object r0)
    (tiny_stories__story_075_type_dress r1)
    (tiny_stories__story_075_type_item r1)
    (tiny_stories__story_075_type_object r1)
    (writing_prompts__wp_064_type_item r1)
    (writing_prompts__wp_064_type_object r1)
    (tiny_stories__story_075_type_dress r2)
    (tiny_stories__story_075_type_item r2)
    (tiny_stories__story_075_type_object r2)
    (writing_prompts__wp_064_type_object r3)
    (writing_prompts__wp_064_type_place r3)
    (tiny_stories__story_075_p_damaged r2)
    (tiny_stories__story_075_p_wearing r0 r2)
    (writing_prompts__wp_064_p_alive r0)
    (writing_prompts__wp_064_p_at r0 r3)
    (intends r0 (writing_prompts__wp_064_p_delivered r1))
  )
  (:goal (writing_prompts__wp_064_p_delivered r1))
)
