(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_046_o_ball - object tiny_stories__story_046_o_perfume - object)
  (:predicates
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_009_p_reading ?v0 - object)
    (tiny_stories__story_009_p_playing ?v0 - object)
    (tiny_stories__story_009_p_calm ?v0 - object)
    (tiny_stories__story_009_p_books-fall)
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
    (tiny_stories__story_046_active)
    (tiny_stories__story_046_type_character ?x - object)
    (tiny_stories__story_046_type_object ?x - object)
    (tiny_stories__story_046_p_impatient ?v0 - object)
    (tiny_stories__story_046_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_046_p_on-table ?v0 - object)
    (tiny_stories__story_046_p_smells-nice ?v0 - object)
    (tiny_stories__story_046_p_playing-with-ball ?v0 - object)
    (writing_prompts__wp_011_active)
    (writing_prompts__wp_011_type_character ?x - object)
    (writing_prompts__wp_011_type_object ?x - object)
    (writing_prompts__wp_011_type_place ?x - object)
    (writing_prompts__wp_011_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_alive ?v0 - object)
    (writing_prompts__wp_011_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_011_p_in-stasis ?v0 - object)
    (writing_prompts__wp_011_p_ancient-technology ?v0 - object)
    (writing_prompts__wp_011_p_propellant-device ?v0 - object)
    (writing_prompts__wp_011_p_shielded ?v0 - object)
    (writing_prompts__wp_011_p_requested-tow ?v0 - object ?v1 - object)
  )

  (:action tiny_stories__story_009_a_start-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_reading ?character))
      )
    :effect
      (tiny_stories__story_009_p_reading ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_reading ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_reading ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_playing ?character))
      )
    :effect
      (tiny_stories__story_009_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_playing ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_playing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-calm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_calm ?character))
      )
    :effect
      (tiny_stories__story_009_p_calm ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-uncalm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_calm ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_calm ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (tiny_stories__story_009_p_books-fall))
      )
    :effect
      (tiny_stories__story_009_p_books-fall)
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

  (:action tiny_stories__story_046_a_try-get
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_type_object ?object)
        (and
          (tiny_stories__story_046_p_impatient ?character)
          (tiny_stories__story_046_p_on-table ?object)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_046_p_on-table ?object))
        (tiny_stories__story_046_p_has ?character ?object)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_smell-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_perfume)
      )
    :effect
      (tiny_stories__story_046_p_smells-nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_046_a_play-with-ball
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_046_active)
        (tiny_stories__story_046_type_character ?character)
        (tiny_stories__story_046_p_has ?character tiny_stories__story_046_o_ball)
      )
    :effect
      (tiny_stories__story_046_p_playing-with-ball ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_discover-technology
    :parameters (?character - object ?object - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (and
        (writing_prompts__wp_011_p_has ?character ?object)
        (writing_prompts__wp_011_p_ancient-technology ?object)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_detect-stasis
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_ancient-technology ?object)
        )
      )
    :effect
      (writing_prompts__wp_011_p_in-stasis ?object)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_request-tow
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_place ?place)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_011_p_requested-tow ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_011_a_transport-object
    :parameters (?character - object ?object - object ?from - object ?to - object)
    :precondition
      (and
        (writing_prompts__wp_011_active)
        (writing_prompts__wp_011_type_character ?character)
        (writing_prompts__wp_011_type_object ?object)
        (writing_prompts__wp_011_type_place ?from)
        (writing_prompts__wp_011_type_place ?to)
        (and
          (writing_prompts__wp_011_p_alive ?character)
          (writing_prompts__wp_011_p_at ?character ?from)
          (writing_prompts__wp_011_p_has ?character ?object)
          (writing_prompts__wp_011_p_requested-tow ?character ?to)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_011_p_at ?character ?from))
        (writing_prompts__wp_011_p_at ?character ?to)
        (not (writing_prompts__wp_011_p_has ?character ?object))
      )
    :agents (?character)
  )
)
