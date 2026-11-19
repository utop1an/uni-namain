(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_067_o_factory - object)
  (:predicates
    (tiny_stories__story_015_active)
    (tiny_stories__story_015_type_character ?x - object)
    (tiny_stories__story_015_type_dog ?x - object)
    (tiny_stories__story_015_type_object ?x - object)
    (tiny_stories__story_015_p_friend ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_practices ?v0 - object ?v1 - object)
    (tiny_stories__story_015_p_participates ?v0 - object)
    (tiny_stories__story_015_p_wins ?v0 - object)
    (tiny_stories__story_015_p_plays-with-toy-stack ?v0 - object)
    (tiny_stories__story_022_active)
    (tiny_stories__story_022_type_character ?x - object)
    (tiny_stories__story_022_type_item ?x - object)
    (tiny_stories__story_022_type_object ?x - object)
    (tiny_stories__story_022_type_place ?x - object)
    (tiny_stories__story_022_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_022_p_foggy ?v0 - object)
    (tiny_stories__story_022_p_found ?v0 - object)
    (tiny_stories__story_022_p_happy ?v0 - object)
    (tiny_stories__story_022_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_067_active)
    (tiny_stories__story_067_type_character ?x - object)
    (tiny_stories__story_067_type_object ?x - object)
    (tiny_stories__story_067_p_worker ?v0 - object)
    (tiny_stories__story_067_p_clean ?v0 - object)
    (tiny_stories__story_067_p_makes-toys ?v0 - object)
    (tiny_stories__story_067_p_nervous ?v0 - object)
    (tiny_stories__story_067_p_friends-with ?v0 - object ?v1 - object)
    (tiny_stories__story_067_p_happy ?v0 - object)
  )

  (:action tiny_stories__story_015_a_practice-running
    :parameters (?helper - object ?runner - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?helper)
        (tiny_stories__story_015_type_dog ?runner)
        (and
          (tiny_stories__story_015_p_friend ?helper ?runner)
          (not (tiny_stories__story_015_p_practices ?helper ?runner))
        )
      )
    :effect
      (tiny_stories__story_015_p_practices ?helper ?runner)
    :agents (?helper ?runner)
  )

  (:action tiny_stories__story_015_a_participate-in-race
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_participates ?dog))
      )
    :effect
      (tiny_stories__story_015_p_participates ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_win-race
    :parameters (?dog - object ?helper - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (tiny_stories__story_015_type_dog ?helper)
        (and
          (tiny_stories__story_015_p_participates ?dog)
          (tiny_stories__story_015_p_practices ?dog ?helper)
        )
      )
    :effect
      (tiny_stories__story_015_p_wins ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_015_a_play-with-toy-stack
    :parameters (?dog - object)
    :precondition
      (and
        (tiny_stories__story_015_active)
        (tiny_stories__story_015_type_dog ?dog)
        (not (tiny_stories__story_015_p_plays-with-toy-stack ?dog))
      )
    :effect
      (tiny_stories__story_015_p_plays-with-toy-stack ?dog)
    :agents (?dog)
  )

  (:action tiny_stories__story_022_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_place ?from)
        (tiny_stories__story_022_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_022_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_022_p_at ?character ?from))
        (tiny_stories__story_022_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_search
    :parameters (?character - object ?item - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
        (tiny_stories__story_022_type_item ?item)
        (tiny_stories__story_022_type_place ?place)
        (and
          (tiny_stories__story_022_p_at ?character ?place)
          (not (tiny_stories__story_022_p_found ?item))
        )
      )
    :effect
      (when
        (not (tiny_stories__story_022_p_foggy ?place))
        (and
          (tiny_stories__story_022_p_found ?item)
          (tiny_stories__story_022_p_has ?character ?item)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character1)
        (tiny_stories__story_022_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_022_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_022_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_character ?character)
      )
    :effect
      (tiny_stories__story_022_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_022_a_clear-fog
    :parameters (?place - object)
    :precondition
      (and
        (tiny_stories__story_022_active)
        (tiny_stories__story_022_type_place ?place)
        (tiny_stories__story_022_p_foggy ?place)
      )
    :effect
      (not (tiny_stories__story_022_p_foggy ?place))
  )

  (:action tiny_stories__story_067_a_start-working
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
      )
    :effect
      (tiny_stories__story_067_p_worker ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_clean-factory
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_clean tiny_stories__story_067_o_factory)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_make-toys
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_makes-toys ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character1)
        (tiny_stories__story_067_type_character ?character2)
        (and
          (tiny_stories__story_067_p_worker ?character1)
          (tiny_stories__story_067_p_worker ?character2)
          (not (= ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_067_p_friends-with ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_067_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (tiny_stories__story_067_p_worker ?character)
      )
    :effect
      (tiny_stories__story_067_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_067_a_become-less-nervous
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_067_active)
        (tiny_stories__story_067_type_character ?character)
        (and
          (tiny_stories__story_067_p_worker ?character)
          (tiny_stories__story_067_p_nervous ?character)
        )
      )
    :effect
      (not (tiny_stories__story_067_p_nervous ?character))
    :agents (?character)
  )
)
