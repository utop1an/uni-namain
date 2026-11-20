(define (problem story__random__k04__003)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_003_active)
    (tiny_stories__story_051_active)
    (tiny_stories__story_066_active)
    (writing_prompts__wp_063_active)
    (tiny_stories__story_066_type_character r0)
    (tiny_stories__story_066_type_object r0)
    (tiny_stories__story_003_type_character r0)
    (tiny_stories__story_003_type_object r0)
    (tiny_stories__story_066_type_item r1)
    (tiny_stories__story_066_type_object r1)
    (tiny_stories__story_003_type_object r1)
    (tiny_stories__story_066_type_object r2)
    (tiny_stories__story_066_type_place r2)
    (tiny_stories__story_066_p_at r0 r2)
    (tiny_stories__story_003_p_at-shop r0)
    (tiny_stories__story_003_p_broken-pedal r1)
    (intends r0 (tiny_stories__story_003_p_fixed-pedal r1))
  )
  (:goal (tiny_stories__story_003_p_fixed-pedal r1))
)
