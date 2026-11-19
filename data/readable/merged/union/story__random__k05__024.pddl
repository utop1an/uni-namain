(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants writing_prompts__wp_085_o_outside - object)
  (:predicates
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
    (tiny_stories__story_098_active)
    (tiny_stories__story_098_type_character ?x - object)
    (tiny_stories__story_098_type_object ?x - object)
    (tiny_stories__story_098_p_sailor ?v0 - object)
    (tiny_stories__story_098_p_nice ?v0 - object)
    (tiny_stories__story_098_p_sailing ?v0 - object)
    (tiny_stories__story_098_p_together ?v0 - object ?v1 - object)
    (tiny_stories__story_098_p_helping ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_active)
    (writing_prompts__wp_042_type_character ?x - object)
    (writing_prompts__wp_042_type_drink ?x - object)
    (writing_prompts__wp_042_type_item ?x - object)
    (writing_prompts__wp_042_type_object ?x - object)
    (writing_prompts__wp_042_type_place ?x - object)
    (writing_prompts__wp_042_p_alive ?v0 - object)
    (writing_prompts__wp_042_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_drunk ?v0 - object)
    (writing_prompts__wp_042_p_has ?v0 - object ?v1 - object)
    (writing_prompts__wp_042_p_night-show ?v0 - object)
    (writing_prompts__wp_042_p_vomit-stain ?v0 - object)
    (writing_prompts__wp_057_active)
    (writing_prompts__wp_057_type_character ?x - object)
    (writing_prompts__wp_057_type_object ?x - object)
    (writing_prompts__wp_057_p_liberated ?v0 - object)
    (writing_prompts__wp_057_p_defeated-illuminati)
    (writing_prompts__wp_057_p_alien-exists ?v0 - object)
    (writing_prompts__wp_057_p_alien-gone ?v0 - object)
    (writing_prompts__wp_085_active)
    (writing_prompts__wp_085_type_character ?x - object)
    (writing_prompts__wp_085_type_device ?x - object)
    (writing_prompts__wp_085_type_item ?x - object)
    (writing_prompts__wp_085_type_object ?x - object)
    (writing_prompts__wp_085_type_place ?x - object)
    (writing_prompts__wp_085_p_awake ?v0 - object)
    (writing_prompts__wp_085_p_wearing-clothes ?v0 - object)
    (writing_prompts__wp_085_p_has-device ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_device-on ?v0 - object)
    (writing_prompts__wp_085_p_device-connected ?v0 - object)
    (writing_prompts__wp_085_p_electricity ?v0 - object)
    (writing_prompts__wp_085_p_at ?v0 - object ?v1 - object)
    (writing_prompts__wp_085_p_working ?v0 - object)
    (writing_prompts__wp_085_p_school-canceled)
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

  (:action tiny_stories__story_098_a_learn-to-sail
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_sailor ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_become-nice
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character)
      )
    :effect
      (tiny_stories__story_098_p_nice ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_098_a_help
    :parameters (?helper - object ?helpee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?helper)
        (tiny_stories__story_098_type_character ?helpee)
        (not (= ?helper ?helpee))
      )
    :effect
      (tiny_stories__story_098_p_helping ?helper ?helpee)
    :agents (?helper ?helpee)
  )

  (:action tiny_stories__story_098_a_sail-together
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?character1)
        (tiny_stories__story_098_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (tiny_stories__story_098_p_sailor ?character1)
          (tiny_stories__story_098_p_sailor ?character2)
        )
      )
    :effect
      (tiny_stories__story_098_p_together ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_098_a_thank
    :parameters (?thanker - object ?thankee - object)
    :precondition
      (and
        (tiny_stories__story_098_active)
        (tiny_stories__story_098_type_character ?thanker)
        (tiny_stories__story_098_type_character ?thankee)
        (not (= ?thanker ?thankee))
      )
    :effect
      (tiny_stories__story_098_p_nice ?thanker)
    :agents (?thanker)
  )

  (:action writing_prompts__wp_042_a_drink
    :parameters (?character - object ?drink - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_drink ?drink)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (writing_prompts__wp_042_p_has ?character ?drink)
        )
      )
    :effect
      (and
        (writing_prompts__wp_042_p_drunk ?character)
        (not (writing_prompts__wp_042_p_has ?character ?drink))
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_move
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (not (writing_prompts__wp_042_p_at ?character ?place))
        )
      )
    :effect
      (writing_prompts__wp_042_p_at ?character ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_vomit
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_type_place ?place)
        (and
          (writing_prompts__wp_042_p_alive ?character)
          (writing_prompts__wp_042_p_drunk ?character)
          (writing_prompts__wp_042_p_at ?character ?place)
        )
      )
    :effect
      (writing_prompts__wp_042_p_vomit-stain ?place)
    :agents (?character)
  )

  (:action writing_prompts__wp_042_a_sober-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_042_active)
        (writing_prompts__wp_042_type_character ?character)
        (writing_prompts__wp_042_p_drunk ?character)
      )
    :effect
      (not (writing_prompts__wp_042_p_drunk ?character))
    :agents (?character)
  )

  (:action writing_prompts__wp_057_a_liberate
    :parameters (?alien - object ?human - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_type_character ?human)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_liberated ?human))
        )
      )
    :effect
      (writing_prompts__wp_057_p_liberated ?human)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_defeat-illuminati
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (and
          (writing_prompts__wp_057_p_alien-exists ?alien)
          (not (writing_prompts__wp_057_p_defeated-illuminati))
        )
      )
    :effect
      (writing_prompts__wp_057_p_defeated-illuminati)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_disappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-exists ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-gone ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_057_a_reappear
    :parameters (?alien - object)
    :precondition
      (and
        (writing_prompts__wp_057_active)
        (writing_prompts__wp_057_type_character ?alien)
        (writing_prompts__wp_057_p_alien-gone ?alien)
      )
    :effect
      (writing_prompts__wp_057_p_alien-exists ?alien)
    :agents (?alien)
  )

  (:action writing_prompts__wp_085_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (not (writing_prompts__wp_085_p_awake ?character))
      )
    :effect
      (writing_prompts__wp_085_p_awake ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_put-on-clothes
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (not (writing_prompts__wp_085_p_wearing-clothes ?character))
        )
      )
    :effect
      (writing_prompts__wp_085_p_wearing-clothes ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_turn-on-device
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_has-device ?character ?device)
          (not (writing_prompts__wp_085_p_device-on ?device))
        )
      )
    :effect
      (writing_prompts__wp_085_p_device-on ?device)
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_check-connectivity
    :parameters (?character - object ?device - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_device ?device)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_device-on ?device)
          (writing_prompts__wp_085_p_has-device ?character ?device)
        )
      )
    :effect
      (when
        (writing_prompts__wp_085_p_device-connected ?device)
        (writing_prompts__wp_085_p_working ?device)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_go-outside
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?character)
        (writing_prompts__wp_085_type_place ?place)
        (and
          (writing_prompts__wp_085_p_awake ?character)
          (writing_prompts__wp_085_p_wearing-clothes ?character)
          (writing_prompts__wp_085_p_at ?character ?place)
        )
      )
    :effect
      (and
        (not (writing_prompts__wp_085_p_at ?character ?place))
        (writing_prompts__wp_085_p_at ?character writing_prompts__wp_085_o_outside)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_085_a_talk
    :parameters (?speaker - object ?listener - object)
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (writing_prompts__wp_085_type_character ?speaker)
        (writing_prompts__wp_085_type_character ?listener)
        (and
          (writing_prompts__wp_085_p_awake ?speaker)
          (writing_prompts__wp_085_p_awake ?listener)
          (writing_prompts__wp_085_p_at ?speaker writing_prompts__wp_085_o_outside)
          (writing_prompts__wp_085_p_at ?listener writing_prompts__wp_085_o_outside)
        )
      )
    :agents (?speaker ?listener)
  )

  (:action writing_prompts__wp_085_a_cancel-school
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_085_active)
        (not (writing_prompts__wp_085_p_school-canceled))
      )
    :effect
      (writing_prompts__wp_085_p_school-canceled)
  )
)
