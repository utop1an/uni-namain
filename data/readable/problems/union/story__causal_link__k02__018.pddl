(define (problem story__causal_link__k02__018)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_034_active)
    (tiny_stories__story_075_active)
    (tiny_stories__story_034_type_character r0)
    (tiny_stories__story_034_type_object r0)
    (tiny_stories__story_075_type_character r0)
    (tiny_stories__story_075_type_object r0)
    (tiny_stories__story_034_type_object r1)
    (tiny_stories__story_075_type_dress r1)
    (tiny_stories__story_075_type_item r1)
    (tiny_stories__story_075_type_object r1)
    (tiny_stories__story_075_type_dress r2)
    (tiny_stories__story_075_type_item r2)
    (tiny_stories__story_075_type_object r2)
    (tiny_stories__story_034_p_alive r0)
    (tiny_stories__story_075_p_damaged r1)
    (intends r0 (tiny_stories__story_075_p_has r0 r2))
  )
  (:goal (tiny_stories__story_075_p_has r0 r2))
)
