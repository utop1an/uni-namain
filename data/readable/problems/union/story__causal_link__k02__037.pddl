(define (problem story__causal_link__k02__037)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (tiny_stories__story_060_active)
    (tiny_stories__story_066_active)
    (tiny_stories__story_060_type_character r0)
    (tiny_stories__story_060_type_object r0)
    (tiny_stories__story_060_type_item r1)
    (tiny_stories__story_060_type_object r1)
    (tiny_stories__story_066_type_character r1)
    (tiny_stories__story_066_type_object r1)
    (tiny_stories__story_060_type_object r2)
    (tiny_stories__story_066_type_object r2)
    (tiny_stories__story_066_type_place r2)
    (tiny_stories__story_066_type_item r3)
    (tiny_stories__story_066_type_object r3)
    (tiny_stories__story_060_type_item tiny_stories__story_060_o_vase)
    (tiny_stories__story_060_type_object tiny_stories__story_060_o_vase)
    (tiny_stories__story_060_p_happy r0)
    (tiny_stories__story_060_p_has r0 r1)
    (intends r0 (tiny_stories__story_066_p_has r1 r3))
    (intends r1 (tiny_stories__story_066_p_has r1 r3))
  )
  (:goal (tiny_stories__story_066_p_has r1 r3))
)
