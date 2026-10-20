(define (problem problem_1)
    (:domain household)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              apple - HOUSEHOLD_OBJECT 
              bedroom - LOCATION 
              bowl - SMALL_RECEPTACLE 
              cloth - HOUSEHOLD_OBJECT 
              diningRoom - LOCATION 
              diningTable - FURNITURE_APPLIANCE 
              drawers - FURNITURE_APPLIANCE 
              handheldVacuum - HOUSEHOLD_OBJECT 
              kitchen - LOCATION 
              livingRoom - LOCATION 
              microwave - FURNITURE_APPLIANCE 
              robot - ROBOT 
              sideTable - FURNITURE_APPLIANCE 
    )
    (:init (isAt robot livingRoom)
		(isEmpty robot)
		(isOnHouseholdObject apple diningTable)
		(isOnHouseholdObject cloth sideTable))
    (:goal (and (isAt robot livingRoom)
		(isEmpty robot)
		(isIn apple bowl)))
)