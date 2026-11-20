(define (problem story__random__k04__009)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (tiny_stories__story_009_active)
    (tiny_stories__story_085_active)
    (writing_prompts__wp_033_active)
    (writing_prompts__wp_089_active)
    (writing_prompts__wp_089_type_character r0)
    (writing_prompts__wp_089_type_object r0)
    (writing_prompts__wp_089_type_item r1)
    (writing_prompts__wp_089_type_object r1)
    (writing_prompts__wp_089_type_thing r1)
    (tiny_stories__story_085_type_item r1)
    (tiny_stories__story_085_type_object r1)
    (writing_prompts__wp_089_type_object r2)
    (writing_prompts__wp_089_type_room r2)
    (writing_prompts__wp_089_type_character r3)
    (writing_prompts__wp_089_type_object r3)
    (tiny_stories__story_085_type_character r3)
    (tiny_stories__story_085_type_object r3)
    (writing_prompts__wp_089_p_at r0 r2)
    (writing_prompts__wp_089_p_has r0 r1)
    (writing_prompts__wp_089_p_at r3 r2)
    (intends r0 (tiny_stories__story_085_p_playing r3 r1))
    (intends r3 (tiny_stories__story_085_p_playing r3 r1))
  )
  (:goal (tiny_stories__story_085_p_playing r3 r1))
)
