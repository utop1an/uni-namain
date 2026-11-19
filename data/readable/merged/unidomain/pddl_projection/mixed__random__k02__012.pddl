(define (domain revised_merged)
  (:requirements :adl :typing :equality)
  (:predicates
    (human_36d2ec3e17905e8a_active)
    (human_36d2ec3e17905e8a_type_animal ?x - object)
    (human_36d2ec3e17905e8a_type_city ?x - object)
    (human_36d2ec3e17905e8a_type_dairyfarmer ?x - object)
    (human_36d2ec3e17905e8a_type_item ?x - object)
    (human_36d2ec3e17905e8a_type_object ?x - object)
    (human_36d2ec3e17905e8a_type_person ?x - object)
    (human_36d2ec3e17905e8a_type_place ?x - object)
    (human_36d2ec3e17905e8a_type_ranch ?x - object)
    (human_36d2ec3e17905e8a_type_rancher ?x - object)
    (human_36d2ec3e17905e8a_type_saloon ?x - object)
    (human_36d2ec3e17905e8a_type_sheriff ?x - object)
    (human_36d2ec3e17905e8a_type_sickness ?x - object)
    (human_36d2ec3e17905e8a_type_son ?x - object)
    (human_36d2ec3e17905e8a_type_texasranger ?x - object)
    (human_36d2ec3e17905e8a_type_valuable ?x - object)
    (writing_prompts__wp_096_active)
    (writing_prompts__wp_096_type_character ?x - object)
    (writing_prompts__wp_096_type_object ?x - object)
    (thefarmchar ?p0)
    (themover ?p0)
    (thecriminal ?p0)
    (theinvalid ?p0)
    (invalid-unwell)
    (invalid-recovered)
    (done-crime ?p0)
    (crime-done)
    (arrested ?p0)
    (criminal-arrested)
    (thearrester ?p0)
    (family ?p0 ?p1)
    (survived-winter)
    (has-axe ?p0)
    (spring)
    (autumn)
    (winter)
    (prepared-for-winter)
    (has-medicine ?p0)
    (healthy ?p0)
    (family-ok)
    (winter-proofed-house)
    (has-firewood ?p0)
    (decided-move-city)
    (has-cash ?p0)
    (wants ?p0 ?p1)
    (owns ?p0 ?p1)
    (has-ticket ?p0)
    (moved-to-city)
    (alive ?p0)
    (at ?p0 ?p1)
    (belongsto ?p0 ?p1)
    (has ?p0 ?p1)
    (sick ?p0 ?p1)
    (cures ?p0 ?p1)
    (loves ?p0 ?p1)
    (recovered ?p0)
    (performing ?p0)
    (applause)
    (satisfied ?p0)
    (disappeared ?p0)
    (trick-performed)
  )
  (:constants human_36d2ec3e17905e8a_o_railwaydeveloper - object human_36d2ec3e17905e8a_o_thecity - object human_36d2ec3e17905e8a_o_thefarmer - object)

  (:action arrest
    :parameters (?s ?p ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_sheriff ?s)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_sheriff ?s)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (at ?s ?l)
          (at ?p ?l)
          (done-crime ?p)
          (not (arrested ?p))
          (thecriminal ?p)
          (not (criminal-arrested))
          (thearrester ?s)
        )
      )
    :effect
      (and
        (arrested ?p)
        (criminal-arrested)
      )
  )

  (:action repair-house
    :parameters (?p)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?p)
        )
        (alive ?p)
      )
    :effect
      (winter-proofed-house)
  )

  (:action prepare-for-winter
    :parameters (?p)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?p)
        )
        (and
          (autumn)
          (alive ?p)
          (winter-proofed-house)
          (has-firewood ?p)
        )
      )
    :effect
      (prepared-for-winter)
  )

  (:action turn-into-winter
    :parameters ()
    :precondition
      (and
        (human_36d2ec3e17905e8a_active)
        (and
          (autumn)
          (prepared-for-winter)
        )
      )
    :effect
      (and
        (not (autumn))
        (winter)
      )
  )

  (:action live-through-winter
    :parameters (?p ?f)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?f)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?f)
        )
        (and
          (winter)
          (family ?p ?f)
          (healthy ?f)
        )
      )
    :effect
      (and
        (not (winter))
        (spring)
      )
  )

  (:action survived
    :parameters (?p ?f)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_rancher ?p)
          (human_36d2ec3e17905e8a_type_person ?f)
          (human_36d2ec3e17905e8a_type_rancher ?p)
          (human_36d2ec3e17905e8a_type_person ?f)
        )
        (and
          (spring)
          (thefarmchar ?p)
          (alive ?p)
          (family ?p ?f)
          (alive ?f)
        )
      )
    :effect
      (survived-winter)
  )

  (:action travel
    :parameters (?person ?from ?to)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?person)
          (human_36d2ec3e17905e8a_type_place ?from)
          (human_36d2ec3e17905e8a_type_place ?to)
          (human_36d2ec3e17905e8a_type_person ?person)
          (human_36d2ec3e17905e8a_type_place ?from)
          (human_36d2ec3e17905e8a_type_place ?to)
        )
        (and
          (not (= ?to human_36d2ec3e17905e8a_o_thecity))
          (not (= ?to ?from))
          (alive ?person)
          (healthy ?person)
          (not (arrested ?person))
          (at ?person ?from)
        )
      )
    :effect
      (and
        (at ?person ?to)
        (not (at ?person ?from))
      )
  )

  (:action travel-to-city
    :parameters (?p ?f ?t)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?f)
          (human_36d2ec3e17905e8a_type_place ?t)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?f)
          (human_36d2ec3e17905e8a_type_place ?t)
        )
        (and
          (= ?t human_36d2ec3e17905e8a_o_thecity)
          (not (= ?t ?f))
          (has-ticket ?p)
          (alive ?p)
          (at ?p ?f)
          (themover ?p)
          (decided-move-city)
        )
      )
    :effect
      (and
        (moved-to-city)
        (at ?p ?t)
        (not (at ?p ?t))
      )
  )

  (:action sell-land
    :parameters (?p1 ?p2 ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_rancher ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_rancher ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (owns ?p1 ?l)
          (wants ?p2 ?l)
          (has-cash ?p2)
          (decided-move-city)
        )
      )
    :effect
      (and
        (has-cash ?p1)
        (not (has-cash ?p2))
        (owns ?p2 ?l)
        (not (owns ?p1 ?l))
      )
  )

  (:action decide-to-move-to-city
    :parameters (?p ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_rancher ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_rancher ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (at ?p ?l)
          (themover ?p)
        )
      )
    :effect
      (decided-move-city)
  )

  (:action buy-ticket
    :parameters (?p ?r ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?r)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?r)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (has-cash ?p)
          (= ?r human_36d2ec3e17905e8a_o_railwaydeveloper)
        )
      )
    :effect
      (and
        (has-ticket ?p)
        (not (has-cash ?p))
        (has-cash ?r)
      )
  )

  (:action steal-cash
    :parameters (?p1 ?p2 ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_person ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (at ?p1 ?l)
          (at ?p2 ?l)
          (has-cash ?p2)
          (thecriminal ?p1)
        )
      )
    :effect
      (and
        (has-cash ?p1)
        (not (has-cash ?p2))
        (done-crime ?p1)
        (crime-done)
      )
  )

  (:action steal-medicine
    :parameters (?p ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (at ?p ?l)
          (theinvalid ?p)
          (invalid-unwell)
          (not (has-cash ?p))
        )
      )
    :effect
      (has-medicine ?p)
  )

  (:action steal-firewood
    :parameters (?p1 ?p2)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
          (human_36d2ec3e17905e8a_type_person ?p1)
          (human_36d2ec3e17905e8a_type_person ?p2)
        )
        (has-firewood ?p2)
      )
    :effect
      (not (has-firewood ?p2))
  )

  (:action chop-wood
    :parameters (?p)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?p)
        )
        (not (has-firewood ?p))
      )
    :effect
      (has-firewood ?p)
  )

  (:action get-snake-bite
    :parameters (?v)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?v)
          (human_36d2ec3e17905e8a_type_person ?v)
        )
        (and
          (healthy ?v)
          (theinvalid ?v)
        )
      )
    :effect
      (and
        (not (healthy ?v))
        (invalid-unwell)
        (not (invalid-recovered))
      )
  )

  (:action get-medicine
    :parameters (?p ?h ?l)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?h)
          (human_36d2ec3e17905e8a_type_place ?l)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?h)
          (human_36d2ec3e17905e8a_type_place ?l)
        )
        (and
          (has-cash ?p)
          (not (has-medicine ?p))
          (has-medicine ?h)
          (at ?p ?l)
          (at ?h ?l)
        )
      )
    :effect
      (and
        (has-medicine ?p)
        (not (has-cash ?p))
        (has-cash ?h)
        (not (has-medicine ?h))
      )
  )

  (:action heal
    :parameters (?h)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_rancher ?h)
          (human_36d2ec3e17905e8a_type_rancher ?h)
        )
        (and
          (has-medicine ?h)
          (not (healthy ?h))
          (theinvalid ?h)
          (invalid-unwell)
        )
      )
    :effect
      (and
        (healthy ?h)
        (not (has-medicine ?h))
        (recovered ?h)
        (not (invalid-unwell))
        (invalid-recovered)
      )
  )

  (:action recover
    :parameters (?p)
    :precondition
      (and
        (and
          (human_36d2ec3e17905e8a_active)
          (human_36d2ec3e17905e8a_type_person ?p)
          (human_36d2ec3e17905e8a_type_person ?p)
        )
        (and
          (not (= ?p human_36d2ec3e17905e8a_o_thefarmer))
          (has-medicine ?p)
          (not (healthy ?p))
          (theinvalid ?p)
          (invalid-unwell)
        )
      )
    :effect
      (and
        (healthy ?p)
        (not (has-medicine ?p))
        (recovered ?p)
        (not (invalid-unwell))
        (invalid-recovered)
      )
  )

  (:action perform-show
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (not (performing ?magician))
      )
    :effect
      (and
        (performing ?magician)
        (applause)
      )
  )

  (:action perform-final-trick
    :parameters (?magician)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?magician)
          (writing_prompts__wp_096_type_character ?magician)
        )
        (and
          (performing ?magician)
          (not (trick-performed))
        )
      )
    :effect
      (and
        (trick-performed)
        (disappeared ?magician)
      )
  )

  (:action become-satisfied
    :parameters (?character)
    :precondition
      (and
        (and
          (writing_prompts__wp_096_active)
          (writing_prompts__wp_096_type_character ?character)
          (writing_prompts__wp_096_type_character ?character)
        )
        (and
          (performing ?character)
          (trick-performed)
          (applause)
          (not (satisfied ?character))
        )
      )
    :effect
      (satisfied ?character)
  )

  (:action stop-applause
    :parameters ()
    :precondition
      (and
        (writing_prompts__wp_096_active)
        (applause)
      )
    :effect
      (not (applause))
  )
)
