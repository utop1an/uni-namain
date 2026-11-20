(define (problem story__random__k02__017)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_066_active)
    (tiny_stories__story_070_active)
    (tiny_stories__story_066_type_character r0)
    (tiny_stories__story_066_type_object r0)
    (tiny_stories__story_070_type_character r0)
    (tiny_stories__story_070_type_object r0)
    (tiny_stories__story_066_type_item r1)
    (tiny_stories__story_066_type_object r1)
    (tiny_stories__story_070_type_item r1)
    (tiny_stories__story_070_type_object r1)
    (tiny_stories__story_066_type_object r2)
    (tiny_stories__story_066_type_place r2)
    (tiny_stories__story_066_p_at r0 r2)
    (intends r0 (tiny_stories__story_070_p_clean r1))
  )
  (:goal (tiny_stories__story_070_p_clean r1))
)
