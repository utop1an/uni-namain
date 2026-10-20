(define (problem problem_1)
    (:domain household)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              apple - HOUSEHOLD_OBJECT 
              cloth - HOUSEHOLD_OBJECT 
              diningTableLoc - LOCATION 
              drawerLoc - LOCATION 
              kitchenCounterLoc - LOCATION 
              lunchBoxReceptacle - RECEPTACLE 
              robot1 - ROBOT 
    )
    (:init (isAt robot1 kitchenCounterLoc)
		(objectIsAt apple kitchenCounterLoc)
		(objectIsAt cloth diningTableLoc)
		(receptacleIsAt lunchBoxReceptacle drawerLoc))
    (:goal (and (objectIsInside apple lunchBoxReceptacle)
		(receptacleIsAt lunchBoxReceptacle diningTableLoc)
		(objectIsAt cloth kitchenCounterLoc)))
)