(define (problem story__random__k03__016)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
  )
  (:init
    (tiny_stories__story_029_active)
    (tiny_stories__story_034_active)
    (tiny_stories__story_038_active)
    (tiny_stories__story_029_type_character r0)
    (tiny_stories__story_029_type_object r0)
    (tiny_stories__story_034_type_character r0)
    (tiny_stories__story_034_type_object r0)
    (tiny_stories__story_029_type_item r1)
    (tiny_stories__story_029_type_object r1)
    (tiny_stories__story_034_type_object r1)
    (tiny_stories__story_029_p_alive r0)
    (tiny_stories__story_029_p_near r0 r1)
    (intends r0 (tiny_stories__story_034_p_wearing r0 r1))
  )
  (:goal (tiny_stories__story_034_p_wearing r0 r1))
)
