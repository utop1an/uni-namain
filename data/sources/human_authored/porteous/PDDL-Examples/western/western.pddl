;; Western domain Adapted from the following:
;; ------------------------------------------
;;; A domain for modeling stories in the Wild West
;;; Created by Stephen G. Ware
;;; https://www.cs.uky.edu/ ̃sgware/projects/glaive/


(define (domain western-type)
(:requirements :typing :equality :negative-preconditions) 
(:types 
  sickness place item person animal - object
  sheriff rancher son - person
  dairyfarmer - person
  texasranger - person
  valuable - item
  city ranch saloon - place
)

(:predicates 
  (theFarmChar ?p - person)
  (theMover ?p - person)
  (theCriminal ?p - person)
  (theInvalid ?p - person)
  (invalid-unwell)
  (invalid-recovered)
  (done-crime ?p - person)
  (crime-done)
  (arrested ?person - person)
  (criminal-arrested)
  (theArrester ?p - person)
  (family ?p1 ?p2 - person)
  (survived-winter)
  (has-axe ?p - person)
  (spring)
  (autumn)
  (winter)
  (prepared-for-winter)
  (has-medicine ?p - person)
  (healthy ?p - person)
  (family-ok)
  (winter-proofed-house)
  (has-firewood ?p - person) 
  (decided-move-city)
  (has-cash ?p - person)
  (wants ?p - person ?l - place)
  (owns ?p - person ?l - place)
  (has-ticket ?p - person)
  (moved-to-city)
  (alive ?person - person)
  (at ?object - object ?place - place)
  (belongsto ?item - item ?person - person)
  (has ?person - person ?item - item)
  (sick ?person - person ?sickness - sickness)
  (cures ?item - item ?sickness - sickness)
  (loves ?lover - person ?love - person)
  (recovered ?p - person)
)

(:action arrest
  :parameters (?s - sheriff ?p - person ?l - place)
  :precondition (and
    (at ?s ?l)
    (at ?p ?l)
    (done-crime ?p)
    (not (arrested ?p))
    (theCriminal ?p)
    (not (criminal-arrested))
    (theArrester ?s)
  )
  :effect (and
    (arrested ?p)
    (criminal-arrested)
  ))


(:action repair-house
  :parameters (?p - person)
  :precondition (and
    (alive ?p)
  )
  :effect (and 
    (winter-proofed-house)
  )
)


(:action prepare-for-winter
  :parameters (?p - person)
  :precondition (and
    (autumn)
    (alive ?p)
    (winter-proofed-house)
    (has-firewood ?p)
  )
  :effect (and 
    (prepared-for-winter)
  )
)

(:action turn-into-winter
  :parameters ()
  :precondition (and
    (autumn)
    (prepared-for-winter)
  )
  :effect (and
    (not (autumn))
    (winter)
  )
)


(:action live-through-winter
  :parameters (?p ?f - person)
  :precondition (and
    (winter)
    (family ?p ?f)
    (healthy ?f)
  )
  :effect (and 
    (not (winter))
    (spring)
  )
)

(:action survived
  :parameters (?p - rancher ?f - person)
  :precondition (and
    (spring)
    (theFarmChar ?p)
    (alive ?p)
    (family ?p ?f)
    (alive ?f)
  )
  :effect (and 
    (survived-winter)
  )
)

(:action travel
  :parameters (?person - person ?from - place ?to - place)
  :precondition (and 
    (not (= ?to theCity))
    (not (= ?to ?from))
    (alive ?person)
    (healthy ?person)
    (not (arrested ?person))
    (at ?person ?from)
  )
  :effect (and 
    (at ?person ?to)
    (not (at ?person ?from)))
)

(:action travel-to-city
  :parameters (?p - person ?f ?t - place)
  :precondition (and 
    (= ?t theCity)
    (not (= ?t ?f))
    (has-ticket ?p)
    (alive ?p)
    (at ?p ?f)
    (theMover ?p)
    (decided-move-city)
  )
  :effect (and 
    (moved-to-city)
    (at ?p ?t)
    (not (at ?p ?t))
  )
)

(:action sell-land
  :parameters (?p1 - rancher ?p2 - person ?l - place)
  :precondition (and
    (owns ?p1 ?l)
    (wants ?p2 ?l)
    (has-cash ?p2)
    (decided-move-city)
  )
  :effect (and
    (has-cash ?p1)
    (not (has-cash ?p2))
    (owns ?p2 ?l)
    (not (owns ?p1 ?l))
  )
)

(:action decide-to-move-to-city
  :parameters (?p - rancher ?l - place)
  :precondition (and
    (at ?p ?l)
    (theMover ?p)
  )
  :effect (and
    (decided-move-city)
  )
)
(:action buy-ticket
  :parameters (?p ?r - person ?l - place)
  :precondition (and
    (has-cash ?p)
    (= ?r railwaydeveloper)
  )
  :effect (and
    (has-ticket ?p)
    (not (has-cash ?p))
    (has-cash ?r)
  )
)

(:action steal-cash
  :parameters (?p1 ?p2 - person ?l - place)
  :precondition (and
    (at ?p1 ?l)
    (at ?p2 ?l)
    (has-cash ?p2)
    (theCriminal ?p1)
    )
  :effect (and
    (has-cash ?p1)
    (not (has-cash ?p2))
    (done-crime ?p1)
    (crime-done)
  ))

(:action steal-medicine
  :parameters (?p - person ?l - place)
  :precondition (and
    (at ?p ?l)
    (theInvalid ?p)
    (invalid-unwell)
    (not (has-cash ?p))
    )
  :effect (and
    (has-medicine ?p)
  ))


(:action steal-firewood
  :parameters (?p1 ?p2 - person)
  :precondition (and
    (has-firewood ?p2)
  )
  :effect (and
    (not (has-firewood ?p2))
  )
)

(:action chop-wood
  :parameters (?p - person)
  :precondition (and
    (not (has-firewood ?p))
  )
  :effect (and
    (has-firewood ?p)
  )
)


; A character gets bitten by a rattlesnake and becomes sick.
(:action get-snake-bite
  :parameters (?v - person)
  :precondition (and
    (healthy ?v)
    (theInvalid ?v)
  )
  :effect (and 
    (not (healthy ?v))
    (invalid-unwell)
    (not (invalid-recovered))
  )
)

(:action get-medicine
  :parameters (?p ?h - person ?l - place)
  :precondition (and
    (has-cash ?p)
    (not (has-medicine ?p))
    (has-medicine ?h)
    (at ?p ?l)
    (at ?h ?l)
  )
  :effect (and
    (has-medicine ?p)
    (not (has-cash ?p))
    (has-cash ?h)
    (not (has-medicine ?h))
  )
)

(:action heal
  :parameters (?h - rancher)
  :precondition (and 
    (has-medicine ?h)
    (not (healthy ?h))
    (theInvalid ?h)
    (invalid-unwell)
  )
  :effect (and 
    (healthy ?h)
    (not (has-medicine ?h))
    (recovered ?h)
    (not (invalid-unwell))
    (invalid-recovered)
  )
)

(:action recover
  :parameters (?p - person)
  :precondition (and 
    (not (= ?p thefarmer))
    (has-medicine ?p)
    (not (healthy ?p))
    (theInvalid ?p)
    (invalid-unwell)
  )
  :effect (and 
    (healthy ?p)
    (not (has-medicine ?p))
    (recovered ?p)
    (not (invalid-unwell))
    (invalid-recovered)
  )
)


)
