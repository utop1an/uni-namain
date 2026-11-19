(define (domain aladdin)

 (:requirements :adl :typing :negative-preconditions)

 (:types         
   character location thing - object
   person monster - character
   male female - person
	 princess - female

   knight king - canmarry
	 aristocrat monarch - male
   king emperor - monarch
   knight lord - aristocrat

   spirit dragon - monster
   genie zombie - spirit
   genie - ismagic
 )



(:predicates
  
  (bachelor ?x - canmarry)
  (bachelor-loves ?x - person)
  (loves-bachelor ?x - person)

  (magic-char ?x - character)
  (controls-magic ?x - person ?t - thing)
  (magic-char-alive)
 
  (scary ?x0 - monster)
  (single ?x0 - person)
  (beautiful ?x0 - female)

  (magic ?t - thing)

  (controls ?x0 - person ?x1 - ismagic ?t - thing)
  (married-to ?x0 - person ?x1 - person)
  (loves ?x0 - person ?x1 - person)
  (loyal-to ?x0 - character ?x1 - character)
  
  (at ?x0 - character ?x1 - location)
  (in ?x0 - spirit ?x1 - thing)
  (has ?x0 - character ?x1 - thing)

  (confined ?x0 - spirit)
  (alive ?x0 - character)


  (intends-not-alive ?intender ?c - character)
  (intends-has ?intender ?c - character ?t - thing)
  (intends-loves ?intender ?c1 ?c2 - character)
)


(:action travel
  :parameters (?traveller - character ?from ?to - location)
  :precondition (and 
  	(at ?traveller ?from)
  	(alive ?traveller)
  	(not (= ?from ?to))
  )
  :effect (and 
   	(at ?traveller ?to)
   	(not (at ?traveller ?from))
  )
)


(:action slay
  :parameters (?slayer - knight ?m - monster ?place - location)
  :precondition (and 
  	(at ?slayer ?place)
  	(at ?m ?place)
  	(alive ?slayer)
  	(alive ?m)
	  (not (= ?slayer ?m))
    (intends-not-alive ?slayer ?m)
  )
  :effect (and 
	  (not (alive ?m))
 )
)
(:action slay-magic-char
  :parameters (?slayer - knight ?m - monster ?place - location)
  :precondition (and 
  	(at ?slayer ?place)
  	(at ?m ?place)
  	(alive ?slayer)
	  (not (= ?slayer ?m))
    (intends-not-alive ?slayer ?m)
    (magic-char ?m)
  	(alive ?m)
    (magic-char-alive)
  )
  :effect (and 
	  (not (alive ?m))
    (magic-char ?m)
    (not (magic-char-alive))
 )
)



(:action pillage
  :parameters (?pillager ?body - character ?t - thing ?place - location)
  :precondition (and 
  	(at ?pillager ?place)
  	(at ?body ?place)
  	(alive ?pillager)
  	(not (alive ?body))
  	(has ?body ?t)
	  (not (has ?pillager ?t))
	  (not (= ?pillager ?body))
  )
  :effect (and 
   	(has ?pillager ?t)
   	(not (has ?body ?t))
  )
)

(:action give
  :parameters (?giver ?givee - character ?t - thing ?place - location)
  :precondition (and 
  	(not (= ?giver ?givee))
  	(at ?giver ?place)
  	(at ?givee ?place)
  	(alive ?givee)
  	(alive ?giver)
  	(has ?giver ?t)
	  (not (has ?givee ?t))
	  (intends-has ?giver ?givee ?t)
  )
  :effect (and 
   	(has ?givee ?t)
   	(not (has ?giver ?t))
  )
)

(:action summon
  :parameters (?char - person ?g - ismagic ?lamp - thing ?place - location)
  :precondition (and 
	  (confined ?g)
	  (magic ?lamp)
  	(at ?char ?place)
  	(has ?char ?lamp)
  	(in ?g ?lamp)
  	(alive ?char)
	  (not (= ?char ?g))
    (magic-char ?g)
    (magic-char-alive)
  )
  :effect (and
    	(at ?g ?place)
    	(controls ?char ?g ?lamp)
      (controls-magic ?char ?lamp)
    	(not (in ?g ?lamp))
    	(not (confined ?g))
  )
)

(:action love-spell
  :parameters (?g - genie ?target - person ?lover - canmarry )
  :precondition (and 
  	(not (confined ?g))
	  (not (loves ?target ?lover))
    (magic-char ?g)
    (magic-char-alive)
  	(alive ?target)
  	(alive ?lover)
  	(not (= ?g ?target))
  	(not (= ?g ?lover))
  	(not (= ?target ?lover))
	  (intends-loves ?g ?target ?lover)
    (bachelor ?lover)
  )
  :effect (and
    	(loves ?target ?lover)
      (loves-bachelor ?target)
  )
)

(:action marry
  :parameters (?groom - canmarry ?bride - person ?place - location )
  :precondition (and 
  	(alive ?groom)
  	(alive ?bride)
  	(at ?groom ?place)
  	(at ?bride ?place)
  	(loves ?groom ?bride)
  	(loves ?bride ?groom)
	  (single ?groom)
    (bachelor ?groom)
	  (single ?bride)
  	(not (= ?groom ?bride))
  )
  :effect (and
    	(married-to ?groom ?bride)
    	(married-to ?bride ?groom)
	    (not (single ?groom))
	    (not (single ?bride))
  )
)

(:action fall-in-love
  :parameters (?m - canmarry ?f - female ?place - location )
  :precondition (and 
    (bachelor ?m)
  	(at ?m ?place)
  	(at ?f ?place)
	  (single ?m)
  	(alive ?m)
  	(alive ?f)
	  (not (loves ?m ?f))
  	(beautiful ?f)
  )
  :effect (and
     (loves ?m ?f)
     (bachelor-loves ?f)
  )
)

(:action order
  :parameters (?ki - king ?kn - knight ?place - location ?t - thing)
  :precondition (and 
  	(loyal-to ?kn ?ki)
  	(alive ?kn)
  	(alive ?ki)
  	(at ?ki ?place)
  	(at ?kn ?place)
  )
  :effect (and
    	(intends-has ?kn ?ki ?t)
  )
)

(:action appear-threatening
  :parameters (?m - monster ?char - person ?place - location)
  :precondition (and 
  	(alive ?m)
  	(alive ?char)
  	(at ?m ?place)
  	(at ?char ?place)
  	(scary ?m)
  	(not (= ?m ?char))
  )
  :effect (and
    	(intends-not-alive ?char ?m)
  )
)

(:action command
  :parameters (?char - person ?g - genie ?love - person ?lamp - thing ?place - location)
  :precondition (and 
	  (magic ?lamp)
	  (has ?char ?lamp)
  	(controls ?char ?g ?lamp)
  	(alive ?char)
    (magic-char ?g)
    (magic-char-alive)

	  (alive ?love)
  	(at ?char ?place)
  	(at ?g ?place)
	  (loves ?char ?love)
	  (not (loves ?love ?char))
	  (not (= ?char ?g))
	  (not (= ?char ?love))
  )
  :effect (and
	  (intends-loves ?g ?love ?char)
  )
)

)
