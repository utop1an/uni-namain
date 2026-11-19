(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_053_o_spade - object tiny_stories__story_053_o_small-box - object)
  (:predicates
    (tiny_stories__story_053_active)
    (tiny_stories__story_053_type_character ?x - object)
    (tiny_stories__story_053_type_item ?x - object)
    (tiny_stories__story_053_type_object ?x - object)
    (tiny_stories__story_053_type_place ?x - object)
    (tiny_stories__story_053_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_digging ?v0 - object)
    (tiny_stories__story_053_p_found ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_opened ?v0 - object ?v1 - object)
    (tiny_stories__story_053_p_playing ?v0 - object)
    (tiny_stories__story_072_active)
    (tiny_stories__story_072_type_character ?x - object)
    (tiny_stories__story_072_type_object ?x - object)
    (tiny_stories__story_072_p_at-party ?v0 - object)
    (tiny_stories__story_072_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_072_p_fast ?v0 - object)
    (tiny_stories__story_072_p_cake-transformed)
    (tiny_stories__story_078_active)
    (tiny_stories__story_078_type_character ?x - object)
    (tiny_stories__story_078_type_object ?x - object)
    (tiny_stories__story_078_type_place ?x - object)
    (tiny_stories__story_078_type_project ?x - object)
    (tiny_stories__story_078_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_078_p_alive ?v0 - object)
    (tiny_stories__story_078_p_happy ?v0 - object)
    (tiny_stories__story_078_p_amazed ?v0 - object)
    (tiny_stories__story_078_p_supports ?v0 - object ?v1 - object)
    (tiny_stories__story_078_p_persistent ?v0 - object)
    (tiny_stories__story_078_p_completed ?v0 - object)
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (tiny_stories__story_092_p_worried ?v0 - object)
    (tiny_stories__story_092_p_accepted-to-university ?v0 - object)
    (tiny_stories__story_092_p_happy ?v0 - object)
    (tiny_stories__story_092_p_applauding ?v0 - object)
    (tiny_stories__story_092_p_hardworking ?v0 - object)
    (tiny_stories__story_092_p_dreams-come-true ?v0 - object)
  )

  (:action tiny_stories__story_053_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_place ?place)
        (and
          (not (tiny_stories__story_053_p_at ?character ?place))
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
        )
      )
    :effect
      (tiny_stories__story_053_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_dig
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (and
          (tiny_stories__story_053_p_has ?character tiny_stories__story_053_o_spade)
          (not (tiny_stories__story_053_p_digging ?character))
        )
      )
    :effect
      (tiny_stories__story_053_p_digging ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_find
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_digging ?character)
          (not (tiny_stories__story_053_p_found ?character ?item))
        )
      )
    :effect
      (and
        (tiny_stories__story_053_p_found ?character ?item)
        (tiny_stories__story_053_p_has ?character ?item)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_open
    :parameters (?character - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_type_item ?item)
        (and
          (tiny_stories__story_053_p_found ?character ?item)
          (not (tiny_stories__story_053_p_opened ?character ?item))
        )
      )
    :effect
      (tiny_stories__story_053_p_opened ?character ?item)
    :agents (?character)
  )

  (:action tiny_stories__story_053_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_053_active)
        (tiny_stories__story_053_type_character ?character)
        (tiny_stories__story_053_p_opened ?character tiny_stories__story_053_o_small-box)
      )
    :effect
      (tiny_stories__story_053_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_go-to-party
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (not (tiny_stories__story_072_p_at-party ?character))
      )
    :effect
      (tiny_stories__story_072_p_at-party ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_magic-trick
    :parameters (?magician - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?magician)
        (and
          (tiny_stories__story_072_p_at-party ?magician)
          (not (tiny_stories__story_072_p_cake-transformed))
        )
      )
    :effect
      (tiny_stories__story_072_p_cake-transformed)
    :agents (?magician)
  )

  (:action tiny_stories__story_072_a_eat-cake
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_cake-transformed)
        )
      )
    :effect
      (tiny_stories__story_072_p_fast ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_072_a_play
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_072_active)
        (tiny_stories__story_072_type_character ?character)
        (and
          (tiny_stories__story_072_p_at-party ?character)
          (tiny_stories__story_072_p_fast ?character)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_place ?from)
        (tiny_stories__story_078_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_078_p_alive ?character)
          (tiny_stories__story_078_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_078_p_at ?character ?from))
        (tiny_stories__story_078_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-amazed
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_amazed ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-happy
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_happy ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_support-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_supports ?character ?project)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_become-persistent
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_p_alive ?character)
      )
    :effect
      (tiny_stories__story_078_p_persistent ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_078_a_complete-project
    :parameters (?character - object ?project - object)
    :precondition
      (and
        (tiny_stories__story_078_active)
        (tiny_stories__story_078_type_character ?character)
        (tiny_stories__story_078_type_project ?project)
        (and
          (tiny_stories__story_078_p_alive ?character)
          (tiny_stories__story_078_p_supports ?character ?project)
          (tiny_stories__story_078_p_persistent ?character)
        )
      )
    :effect
      (tiny_stories__story_078_p_completed ?project)
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_get-accepted
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_worried ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (and
        (tiny_stories__story_092_p_accepted-to-university ?character)
        (not (tiny_stories__story_092_p_worried ?character))
        (tiny_stories__story_092_p_happy ?character)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_start-applauding
    :parameters (?character - object ?other - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_type_character ?other)
        (and
          (not (tiny_stories__story_092_p_applauding ?character))
          (tiny_stories__story_092_p_happy ?other)
        )
      )
    :effect
      (tiny_stories__story_092_p_applauding ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_stop-applauding
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (tiny_stories__story_092_p_applauding ?character)
      )
    :effect
      (not (tiny_stories__story_092_p_applauding ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_092_a_make-dreams-come-true
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_092_active)
        (tiny_stories__story_092_type_character ?character)
        (and
          (tiny_stories__story_092_p_accepted-to-university ?character)
          (tiny_stories__story_092_p_hardworking ?character)
        )
      )
    :effect
      (tiny_stories__story_092_p_dreams-come-true ?character)
    :agents (?character)
  )
)
