(define (domain red)

(:requirements :adl :typing :negative-preconditions)

(:types         
	character - object
  human - character
  girl - human
  grandmother - human
  beast - character
  wolf fox - beast
  thing - object
  cake - thing
  axe - thing
  house  - object
  worker - human
  hunter - worker
  blacksmith - human
  allworker - human
)

(:predicates
  (monster ?c - beast)
  (monster-alive)
  (rescuer ?h - character)
  (rescuer-at ?h - house)
	(alive ?c - character)
	(has ?c - character ?t - thing)
	(eaten ?c - character)
  (rescued ?c - human)
  (at ?c - character ?h - house)
)

(:action walk
  :parameters (?c - character ?h1 ?h2 - house)
  :precondition (and
    (alive ?c)
    (at ?c ?h1)
    (not (eaten ?c))
  )
  :effect (and
    (not (at ?c ?h1))
    (at ?c ?h2)
    (when 
      (and (rescuer ?c))
      (and (rescuer-at ?h2)
        (not (rescuer-at ?h1))
    ))
  )
)

;; 3: Wolf Eat Red
(:action eat
  :parameters (?m - wolf ?c - human ?h - house)
  :precondition (and 
	  (alive ?m)
    (alive ?c)
    (not (eaten ?c))
    (at ?m ?h)
    (at ?c ?h)
    (monster ?m)
  )
  :effect (and 
  	(eaten ?c) 	
  )
)

;; 5: Hunter Kill Wolf
(:action kill 
  :parameters (?c - worker ?m - wolf ?a - axe ?h - house)
  :precondition (and 
	  (alive ?c)
	  (alive ?m)
	  (has ?c ?a)
    (at ?c ?h)
    (at ?m ?h)
    (monster ?m)
    (monster-alive)
    (rescuer ?c)
  )
  :effect (and 
	  (not (alive ?m))
    (not (monster-alive))
  )
)

(:action escape 
  :parameters (?c - human ?m - wolf ?h - house)
  :precondition (and 
  	(eaten ?c)
    (not (alive ?m))
    (at ?m ?h)
  )
  :effect (and 
	  (not (eaten ?c))
    (rescued ?c)
    (at ?c ?h)
  )
)

;; 8: Red Give Granny Cake
(:action give 
  :parameters (?c1 ?c2 - human ?t - thing ?h - house)
  :precondition (and 
    (not (eaten ?c2))
  	(alive ?c1)
	  (alive ?c2)
	  (has ?c1 ?t)
    (at ?c1 ?h)
    (at ?c2 ?h)
  )
  :effect (and 
	  (has ?c2 ?t)
    (not (has ?c1 ?t))
  )
)

)
