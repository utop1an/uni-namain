(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
  (:predicates
    (tiny_stories__story_034_active)
    (tiny_stories__story_034_type_character ?x - object)
    (tiny_stories__story_034_type_object ?x - object)
    (tiny_stories__story_034_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_wearing ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_recognize ?v0 - object ?v1 - object)
    (tiny_stories__story_034_p_alive ?v0 - object)
    (tiny_stories__story_040_active)
    (tiny_stories__story_040_type_character ?x - object)
    (tiny_stories__story_040_type_object ?x - object)
    (tiny_stories__story_040_type_place ?x - object)
    (tiny_stories__story_040_type_toy ?x - object)
    (tiny_stories__story_040_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_on-top ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_040_p_scared ?v0 - object)
    (tiny_stories__story_063_active)
    (tiny_stories__story_063_type_character ?x - object)
    (tiny_stories__story_063_type_object ?x - object)
    (tiny_stories__story_063_p_in-tree ?v0 - object)
    (tiny_stories__story_063_p_wants-to-eat ?v0 - object ?v1 - object)
    (tiny_stories__story_063_p_hard ?v0 - object)
    (tiny_stories__story_063_p_broken ?v0 - object)
    (tiny_stories__story_063_p_eaten ?v0 - object)
    (tiny_stories__story_063_p_helping ?v0 - object ?v1 - object)
    (tiny_stories__story_070_active)
    (tiny_stories__story_070_type_character ?x - object)
    (tiny_stories__story_070_type_item ?x - object)
    (tiny_stories__story_070_type_object ?x - object)
    (tiny_stories__story_070_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_friends ?v0 - object ?v1 - object)
    (tiny_stories__story_070_p_clean ?v0 - object)
    (tiny_stories__story_070_p_steal-intention ?v0 - object ?v1 - object)
  )
  (:axiom :vars (?character1 - object ?character2 - object) :context (and (tiny_stories__story_034_active) (tiny_stories__story_034_type_character ?character1) (tiny_stories__story_034_type_character ?character2) (and (tiny_stories__story_034_p_friends ?character1 ?character2) (not (exists (?mask - object) (and (tiny_stories__story_034_type_object ?mask) (tiny_stories__story_034_p_wearing ?character2 ?mask)))))) :implies (tiny_stories__story_034_p_recognize ?character1 ?character2))

  (:action tiny_stories__story_034_a_find-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (tiny_stories__story_034_p_alive ?character)
      )
    :effect
      (tiny_stories__story_034_p_has ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_wear-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_has ?character ?mask)
          (not (tiny_stories__story_034_p_wearing ?character ?mask))
        )
      )
    :effect
      (tiny_stories__story_034_p_wearing ?character ?mask)
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_remove-mask
    :parameters (?character - object ?mask - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character)
        (tiny_stories__story_034_type_object ?mask)
        (and
          (tiny_stories__story_034_p_alive ?character)
          (tiny_stories__story_034_p_wearing ?character ?mask)
        )
      )
    :effect
      (not (tiny_stories__story_034_p_wearing ?character ?mask))
    :agents (?character)
  )

  (:action tiny_stories__story_034_a_recognize
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_034_active)
        (tiny_stories__story_034_type_character ?character1)
        (tiny_stories__story_034_type_character ?character2)
        (and
          (tiny_stories__story_034_p_alive ?character1)
          (tiny_stories__story_034_p_alive ?character2)
          (tiny_stories__story_034_p_friends ?character1 ?character2)
          (not (tiny_stories__story_034_p_recognize ?character1 ?character2))
        )
      )
    :effect
      (tiny_stories__story_034_p_recognize ?character1 ?character2)
    :agents (?character1)
  )

  (:action tiny_stories__story_040_a_move
    :parameters (?character - object ?from - object ?to - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_place ?from)
        (tiny_stories__story_040_type_place ?to)
        (and
          (not (= ?from ?to))
          (tiny_stories__story_040_p_at ?character ?from)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_at ?character ?from))
        (tiny_stories__story_040_p_at ?character ?to)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_retrieve-toy
    :parameters (?character - object ?toy - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_type_toy ?toy)
        (tiny_stories__story_040_type_place ?place)
        (and
          (tiny_stories__story_040_p_at ?character ?place)
          (tiny_stories__story_040_p_on-top ?toy ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_040_p_on-top ?toy ?place))
        (tiny_stories__story_040_p_has ?character ?toy)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_040_a_become-friends
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character1)
        (tiny_stories__story_040_type_character ?character2)
        (not (= ?character1 ?character2))
      )
    :effect
      (tiny_stories__story_040_p_friends ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_040_a_overcome-fear
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_040_active)
        (tiny_stories__story_040_type_character ?character)
        (tiny_stories__story_040_p_scared ?character)
      )
    :effect
      (not (tiny_stories__story_040_p_scared ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_climb-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (not (tiny_stories__story_063_p_in-tree ?character))
      )
    :effect
      (tiny_stories__story_063_p_in-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_want-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
      )
    :effect
      (tiny_stories__story_063_p_wants-to-eat ?character ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_try-to-eat
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_wants-to-eat ?character ?object)
          (tiny_stories__story_063_p_hard ?object)
        )
      )
    :effect
      (not (tiny_stories__story_063_p_eaten ?object))
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?helper)
        (tiny_stories__story_063_type_character ?helpee)
      )
    :effect
      (tiny_stories__story_063_p_helping ?helper ?helpee)
    :agents (?helper)
  )

  (:action tiny_stories__story_063_a_break-object
    :parameters (?character - object ?object - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character)
        (tiny_stories__story_063_type_object ?object)
        (tiny_stories__story_063_type_character ?helpee)
        (and
          (tiny_stories__story_063_p_hard ?object)
          (tiny_stories__story_063_p_helping ?character ?helpee)
        )
      )
    :effect
      (tiny_stories__story_063_p_broken ?object)
    :agents (?character)
  )

  (:action tiny_stories__story_063_a_eat-together
    :parameters (?character1 - object ?character2 - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_063_active)
        (tiny_stories__story_063_type_character ?character1)
        (tiny_stories__story_063_type_character ?character2)
        (tiny_stories__story_063_type_object ?object)
        (and
          (tiny_stories__story_063_p_broken ?object)
          (tiny_stories__story_063_p_helping ?character1 ?character2)
        )
      )
    :effect
      (tiny_stories__story_063_p_eaten ?object)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_070_a_apologize
    :parameters (?apologizer - object ?apologized - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?apologizer)
        (tiny_stories__story_070_type_character ?apologized)
        (and
          (not (= ?apologizer ?apologized))
          (not (tiny_stories__story_070_p_friends ?apologizer ?apologized))
        )
      )
    :effect
      (tiny_stories__story_070_p_friends ?apologizer ?apologized)
    :agents (?apologizer)
  )

  (:action tiny_stories__story_070_a_try-steal
    :parameters (?stealer - object ?item - object ?owner - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?stealer)
        (tiny_stories__story_070_type_item ?item)
        (tiny_stories__story_070_type_character ?owner)
        (and
          (not (= ?stealer ?owner))
          (tiny_stories__story_070_p_has ?owner ?item)
          (tiny_stories__story_070_p_steal-intention ?stealer ?item)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_070_p_steal-intention ?stealer ?item))
        (not (tiny_stories__story_070_p_friends ?stealer ?owner))
        (tiny_stories__story_070_p_has ?stealer ?item)
        (not (tiny_stories__story_070_p_has ?owner ?item))
      )
    :agents (?stealer)
  )

  (:action tiny_stories__story_070_a_clean-item
    :parameters (?cleaner - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?cleaner)
        (tiny_stories__story_070_type_item ?item)
        (and
          (not (tiny_stories__story_070_p_clean ?item))
          (tiny_stories__story_070_p_has ?cleaner ?item)
        )
      )
    :effect
      (tiny_stories__story_070_p_clean ?item)
    :agents (?cleaner)
  )

  (:action tiny_stories__story_070_a_drop-in-puddle
    :parameters (?dropper - object ?item - object)
    :precondition
      (and
        (tiny_stories__story_070_active)
        (tiny_stories__story_070_type_character ?dropper)
        (tiny_stories__story_070_type_item ?item)
        (and
          (tiny_stories__story_070_p_has ?dropper ?item)
          (tiny_stories__story_070_p_clean ?item)
        )
      )
    :effect
      (not (tiny_stories__story_070_p_clean ?item))
    :agents (?dropper)
  )
)
