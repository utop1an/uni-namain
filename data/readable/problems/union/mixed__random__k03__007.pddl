(define (problem mixed__random__k03__007)
  (:domain revised_merged)
  (:objects
    r0 - object
    r1 - object
    r2 - object
    r3 - object
  )
  (:init
    (human_1fe4b2f08d46fd1e_active)
    (tiny_stories__story_038_active)
    (tiny_stories__story_045_active)
    (human_1fe4b2f08d46fd1e_type_creature r0)
    (human_1fe4b2f08d46fd1e_type_object r0)
    (tiny_stories__story_038_type_character r0)
    (tiny_stories__story_038_type_object r0)
    (human_1fe4b2f08d46fd1e_type_object r1)
    (human_1fe4b2f08d46fd1e_type_place r1)
    (human_1fe4b2f08d46fd1e_type_object r2)
    (human_1fe4b2f08d46fd1e_type_place r2)
    (tiny_stories__story_038_type_object r2)
    (tiny_stories__story_038_type_place r2)
    (tiny_stories__story_038_type_character r3)
    (tiny_stories__story_038_type_object r3)
    (tiny_stories__story_045_type_object tiny_stories__story_045_o_mirror)
    (human_1fe4b2f08d46fd1e_p_alive r0)
    (human_1fe4b2f08d46fd1e_p_at r0 r1)
    (tiny_stories__story_038_p_seeking r0)
    (tiny_stories__story_038_p_hiding r3)
    (tiny_stories__story_038_p_at r3 r2)
    (intends r0 (tiny_stories__story_038_p_found r0 r3))
  )
  (:goal (tiny_stories__story_038_p_found r0 r3))
)
