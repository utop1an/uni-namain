(define (domain Chicken-Licken)
  (:requirements :existential-preconditions :negative-preconditions :strips :typing)
  (:types
    entity item location - object
  )
  (:constants
    Chicken-licken Cock-lock Drake-lake Duck-luck Fox-lox Gander-lander Goose-loose Hen-len King Turkey-lurkey - entity
    Acorn Sky - item
    FoxHole Wood - location
  )
  (:predicates
    (at ?e - entity ?l - location)
    (decided_to_tell_king ?e - entity)
    (eaten_by_fox ?e - entity)
    (following_fox ?e - entity)
    (going_to_wood ?e - entity)
    (informed_about_sky_fall ?informer - entity ?listener - entity)
    (met ?e1 - entity ?e2 - entity)
    (sky_fell_on_head ?e - entity)
    (turned_back ?e - entity)
  )

  (:action be_eaten_by_fox
    :parameters (?e - entity ?l - location)
    :precondition (and (following_fox ?e) (at ?e ?l) (not (eaten_by_fox ?e)))
    :effect (and (at ?e FoxHole) (eaten_by_fox ?e) (not (at ?e ?l)) (not (following_fox ?e)))
  )

  (:action decide_to_tell_king
    :parameters (?e - entity)
    :precondition (and (exists (?inf - entity) (informed_about_sky_fall ?inf ?e)) (not (decided_to_tell_king ?e)))
    :effect (decided_to_tell_king ?e)
  )

  (:action follow_fox
    :parameters (?e - entity)
    :precondition (and (decided_to_tell_king ?e) (not (following_fox ?e)))
    :effect (following_fox ?e)
  )

  (:action go_to_wood
    :parameters (?e - entity)
    :precondition (and (not (at ?e Wood)) (not (going_to_wood ?e)))
    :effect (going_to_wood ?e)
  )

  (:action inform_about_sky_fall
    :parameters (?informer ?listener - entity)
    :precondition (and (met ?informer ?listener) (sky_fell_on_head Chicken-licken) (not (informed_about_sky_fall ?informer ?listener)))
    :effect (informed_about_sky_fall ?informer ?listener)
  )

  (:action meet_character
    :parameters (?e1 ?e2 - entity ?l - location)
    :precondition (and (at ?e1 ?l) (at ?e2 ?l) (not (met ?e1 ?e2)))
    :effect (and (met ?e1 ?e2) (met ?e2 ?e1))
  )

  (:action turn_back
    :parameters (?e - entity)
    :precondition (and (going_to_wood ?e) (not (turned_back ?e)))
    :effect (and (turned_back ?e) (not (going_to_wood ?e)))
  )
)
