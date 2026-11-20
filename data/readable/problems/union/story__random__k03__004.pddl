(define (problem story__random__k03__004)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_011_active)
    (tiny_stories__story_038_active)
    (writing_prompts__wp_009_active)
    (tiny_stories__story_011_type_character r0)
    (tiny_stories__story_011_type_object r0)
    (tiny_stories__story_038_type_character r0)
    (tiny_stories__story_038_type_object r0)
    (tiny_stories__story_011_type_object r1)
    (tiny_stories__story_011_type_place r1)
    (tiny_stories__story_038_type_object r1)
    (tiny_stories__story_038_type_place r1)
    (tiny_stories__story_038_type_character r2)
    (tiny_stories__story_038_type_object r2)
    (tiny_stories__story_011_p_awake r0)
    (tiny_stories__story_038_p_seeking r0)
    (tiny_stories__story_038_p_hiding r2)
    (tiny_stories__story_038_p_at r2 r1)
    (intends r0 (tiny_stories__story_038_p_found r0 r2))
  )
  (:goal (tiny_stories__story_038_p_found r0 r2))
)
