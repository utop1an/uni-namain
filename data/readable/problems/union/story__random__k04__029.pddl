(define (problem story__random__k04__029)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_034_active)
    (tiny_stories__story_040_active)
    (tiny_stories__story_063_active)
    (tiny_stories__story_070_active)
    (tiny_stories__story_040_type_character r0)
    (tiny_stories__story_040_type_object r0)
    (tiny_stories__story_034_type_character r0)
    (tiny_stories__story_034_type_object r0)
    (tiny_stories__story_040_type_object r1)
    (tiny_stories__story_040_type_place r1)
    (tiny_stories__story_040_type_object r2)
    (tiny_stories__story_040_type_toy r2)
    (tiny_stories__story_034_type_object r2)
    (tiny_stories__story_040_p_at r0 r1)
    (tiny_stories__story_040_p_on-top r2 r1)
    (tiny_stories__story_034_p_alive r0)
    (intends r0 (tiny_stories__story_034_p_wearing r0 r2))
  )
  (:goal (tiny_stories__story_034_p_wearing r0 r2))
)
