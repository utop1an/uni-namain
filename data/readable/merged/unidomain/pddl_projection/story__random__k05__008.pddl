(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (tiny_stories__story_003_active)
    (tiny_stories__story_003_type_character ?x - object)
    (tiny_stories__story_003_type_object ?x - object)
    (tiny_stories__story_092_active)
    (tiny_stories__story_092_type_character ?x - object)
    (tiny_stories__story_092_type_object ?x - object)
    (tiny_stories__story_094_active)
    (tiny_stories__story_094_type_character ?x - object)
    (tiny_stories__story_094_type_item ?x - object)
    (tiny_stories__story_094_type_object ?x - object)
    (tiny_stories__story_094_type_place ?x - object)
    (tiny_stories__story_094_type_toy ?x - object)
    (writing_prompts__wp_051_active)
    (writing_prompts__wp_051_type_character ?x - object)
    (writing_prompts__wp_051_type_nation ?x - object)
    (writing_prompts__wp_051_type_object ?x - object)
    (writing_prompts__wp_098_active)
    (writing_prompts__wp_098_type_character ?x - object)
    (writing_prompts__wp_098_type_object ?x - object)
    (sad ?p0)
    (at ?p0 ?p1)
    (ruler ?p0 ?p1)
    (capital ?p0 ?p1)
    (at-war ?p0 ?p1)
    (navy-defeated ?p0 ?p1)
    (settled ?p0 ?p1)
    (built ?p0 ?p1 ?p2)
    (trading ?p0)
    (plantation ?p0 ?p1)
    (farm-estate ?p0 ?p1)
    (slave-trade ?p0)
    (has ?p0 ?p1)
    (happy ?p0)
    (alive ?p0)
    (feeling ?p0)
    (last-soul ?p0)
    (understand ?p0)
    (witness ?p0)
    (end ?p0)
    (broken-pedal ?p0)
    (fixed-pedal ?p0)
    (at-shop ?p0)
    (flying ?p0)
    (worried ?p0)
    (accepted-to-university ?p0)
    (applauding ?p0)
    (hardworking ?p0)
    (dreams-come-true ?p0)
  )
  (:constants writing_prompts__wp_051_o_ships - object)

  (:action declare-war
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation1)
          (writing_prompts__wp_051_type_nation ?nation2)
          (writing_prompts__wp_051_type_nation ?nation1)
          (writing_prompts__wp_051_type_nation ?nation2)
        )
        (not (= ?nation1 ?nation2))
      )
    :effect
      (at-war ?nation1 ?nation2)
  )

  (:action defeat-navy
    :parameters (?nation1 ?nation2)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation1)
          (writing_prompts__wp_051_type_nation ?nation2)
          (writing_prompts__wp_051_type_nation ?nation1)
          (writing_prompts__wp_051_type_nation ?nation2)
        )
        (and
          (not (= ?nation1 ?nation2))
          (at-war ?nation1 ?nation2)
        )
      )
    :effect
      (navy-defeated ?nation1 ?nation2)
  )

  (:action settle
    :parameters (?nation ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_object ?place)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (and)
      )
    :effect
      (settled ?nation ?place)
  )

  (:action establish-trading
    :parameters (?nation)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (and)
      )
    :effect
      (trading ?nation)
  )

  (:action establish-plantation
    :parameters (?nation ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_object ?place)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (and)
      )
    :effect
      (plantation ?nation ?place)
  )

  (:action establish-farm-estate
    :parameters (?nation ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_object ?place)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (and)
      )
    :effect
      (farm-estate ?nation ?place)
  )

  (:action engage-slave-trade
    :parameters (?nation)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (and)
      )
    :effect
      (slave-trade ?nation)
  )

  (:action take-toy
    :parameters (?taker ?victim ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
          (tiny_stories__story_094_type_item ?object)
          (tiny_stories__story_094_type_character ?taker)
          (tiny_stories__story_094_type_character ?victim)
        )
        (and
          (not (= ?taker ?victim))
          (has ?victim ?object)
          (not (has ?taker ?object))
        )
      )
    :effect
      (and
        (not (has ?victim ?object))
        (has ?taker ?object)
        (sad ?victim)
      )
  )

  (:action receive-gift
    :parameters (?receiver ?giver ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
          (tiny_stories__story_094_type_item ?object)
          (tiny_stories__story_094_type_character ?receiver)
          (tiny_stories__story_094_type_character ?giver)
        )
        (and
          (not (= ?receiver ?giver))
          (happy ?giver)
          (not (has ?receiver ?object))
          (has ?giver ?object)
        )
      )
    :effect
      (and
        (has ?receiver ?object)
        (happy ?receiver)
      )
  )

  (:action play
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?object)
          (tiny_stories__story_094_type_character ?character)
        )
        (and
          (has ?character ?object)
          (not (sad ?character))
        )
      )
    :effect
      (happy ?character)
  )

  (:action lose-toy
    :parameters (?character ?object)
    :precondition
      (and
        (and
          (tiny_stories__story_094_active)
          (tiny_stories__story_094_type_character ?character)
          (tiny_stories__story_094_type_item ?object)
          (tiny_stories__story_094_type_character ?character)
        )
        (and
          (has ?character ?object)
          (happy ?character)
        )
      )
    :effect
      (and
        (not (has ?character ?object))
        (sad ?character)
      )
  )

  (:action become-ruler
    :parameters (?character ?nation)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_character ?character)
          (writing_prompts__wp_051_type_nation ?nation)
          (writing_prompts__wp_051_type_character ?character)
          (writing_prompts__wp_051_type_nation ?nation)
        )
        (alive ?character)
      )
    :effect
      (ruler ?character ?nation)
  )

  (:action build
    :parameters (?character ?structure ?place)
    :precondition
      (and
        (and
          (writing_prompts__wp_051_active)
          (writing_prompts__wp_051_type_character ?character)
          (writing_prompts__wp_051_type_object ?structure)
          (writing_prompts__wp_051_type_object ?place)
          (writing_prompts__wp_051_type_character ?character)
        )
        (alive ?character)
      )
    :effect
      (built ?character ?structure ?place)
  )

  (:action go-to-shop
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_character ?character)
        )
        (not (at-shop ?character))
      )
    :effect
      (at-shop ?character)
  )

  (:action start-flying
    :parameters (?bike)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_object ?bike)
        )
        (and
          (fixed-pedal ?bike)
          (not (flying ?bike))
        )
      )
    :effect
      (flying ?bike)
  )

  (:action stop-applauding
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (applauding ?character)
      )
    :effect
      (not (applauding ?character))
  )

  (:action make-dreams-come-true
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (and
          (accepted-to-university ?character)
          (hardworking ?character)
        )
      )
    :effect
      (dreams-come-true ?character)
  )

  (:action fix-pedal
    :parameters (?character ?item)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_object ?item)
          (tiny_stories__story_003_type_character ?character)
        )
        (and
          (at-shop ?character)
          (has ?character ?item)
          (broken-pedal ?item)
        )
      )
    :effect
      (and
        (not (broken-pedal ?item))
        (fixed-pedal ?item)
      )
  )

  (:action become-happy
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_003_active)
          (tiny_stories__story_003_type_character ?character)
          (tiny_stories__story_003_type_character ?character)
        )
        (not (happy ?character))
      )
    :effect
      (happy ?character)
  )

  (:action get-accepted
    :parameters (?character)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?character)
        )
        (and
          (worried ?character)
          (hardworking ?character)
        )
      )
    :effect
      (and
        (accepted-to-university ?character)
        (not (worried ?character))
        (happy ?character)
      )
  )

  (:action start-applauding
    :parameters (?character ?other)
    :precondition
      (and
        (and
          (tiny_stories__story_092_active)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?other)
          (tiny_stories__story_092_type_character ?character)
          (tiny_stories__story_092_type_character ?other)
        )
        (and
          (not (applauding ?character))
          (happy ?other)
        )
      )
    :effect
      (applauding ?character)
  )

  (:action start-feeling
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (feeling ?character))
        )
      )
    :effect
      (feeling ?character)
  )

  (:action witness-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (not (witness ?character))
        )
      )
    :effect
      (witness ?character)
  )

  (:action understand-end
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (witness ?character)
          (not (understand ?character))
        )
      )
    :effect
      (understand ?character)
  )

  (:action last-soul-fades
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (last-soul ?character)
          (understand ?character)
        )
      )
    :effect
      (not (alive ?character))
  )

  (:action humanity-ends
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_098_active)
          (writing_prompts__wp_098_type_character ?character)
          (writing_prompts__wp_098_type_character ?character)
        )
        (and
          (alive ?character)
          (understand ?character)
          (not (end ?character))
        )
      )
    :effect
      (end ?character)
  )
)
