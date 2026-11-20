(define (problem story__causal_link__k02__045)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
  )
  (:init
    (tiny_stories__story_011_active)
    (tiny_stories__story_027_active)
    (tiny_stories__story_011_type_character r0)
    (tiny_stories__story_011_type_object r0)
    (tiny_stories__story_027_type_character r0)
    (tiny_stories__story_027_type_object r0)
    (tiny_stories__story_011_type_object r1)
    (tiny_stories__story_011_type_place r1)
    (tiny_stories__story_027_type_location r1)
    (tiny_stories__story_027_type_object r1)
    (tiny_stories__story_027_type_place r1)
    (tiny_stories__story_027_type_object r2)
    (tiny_stories__story_027_type_toy r2)
    (tiny_stories__story_011_p_awake r0)
    (tiny_stories__story_027_p_hidden r2 r1)
    (tiny_stories__story_027_p_searched r0 r1)
    (intends r0 (tiny_stories__story_027_p_found r2))
  )
  (:goal (tiny_stories__story_027_p_found r2))
)
