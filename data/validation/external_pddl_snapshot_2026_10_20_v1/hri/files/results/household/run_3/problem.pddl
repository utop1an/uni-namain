(define (problem problem_1)
    (:domain household)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              apple - HOUSEHOLD_OBJECT 
              banana - HOUSEHOLD_OBJECT 
              cloth - HOUSEHOLD_OBJECT 
              diningTable - FURNITURE 
              drawer - FURNITURE 
              lunchBox - RECEPTACLE 
              microwave - APPLIANCE 
              robot - ROBOT 
    )
    (:init (isAt robot diningTable)
		(isClosed drawer)
		(isOnTopObject apple diningTable)
		(isOnTopObject banana diningTable)
		(isOnTopObject cloth diningTable)
		(not (isOpenDrawer drawer)))
    (:goal (and (contains lunchBox apple)
		(isOnTop lunchBox diningTable)
		(not (isOpenDrawer drawer))
		(isClosed drawer)))
)