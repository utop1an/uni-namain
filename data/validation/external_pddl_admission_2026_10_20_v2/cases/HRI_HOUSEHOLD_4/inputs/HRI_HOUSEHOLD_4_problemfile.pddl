(define (problem problem_1)
    (:domain household)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              apple - HOUSEHOLD_OBJECT 
              banana - HOUSEHOLD_OBJECT 
              bowl - HOUSEHOLD_OBJECT 
              cloth - HOUSEHOLD_OBJECT 
              diningTable - FURNITURE_APPLIANCE 
              drawer - FURNITURE_APPLIANCE 
              empty - STATE 
              lunchBox - HOUSEHOLD_OBJECT 
              microwave - FURNITURE_APPLIANCE 
              robot - ROBOT 
              sideTable - FURNITURE_APPLIANCE 
              stoveBurner - FURNITURE_APPLIANCE 
    )
    (:init (atRobot diningTable)
		(isEmpty empty)
		(supports diningTable apple)
		(supports diningTable banana)
		(supports diningTable cloth)
		(supports drawer lunchBox)
		(supports sideTable bowl))
    (:goal (and (contains bowl apple)
		(contains bowl banana)
		(supports diningTable bowl)
		(contains lunchBox cloth)
		(supports drawer lunchBox)))
)