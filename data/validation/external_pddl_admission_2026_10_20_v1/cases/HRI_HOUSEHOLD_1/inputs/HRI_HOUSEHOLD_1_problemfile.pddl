(define (problem problem_1)
    (:domain household)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              Apple - HOUSEHOLD_OBJECT 
              DiningTable - LOCATION 
              HandheldVacuumCleaner - HOUSEHOLD_OBJECT 
              KitchenCounter - LOCATION 
              LunchBox - SMALL_RECEPTACLE 
              Robot - ROBOT 
              SideTable - LOCATION 
    )
    (:init (isAt Robot DiningTable)
		(isGripperEmpty Robot)
		(isObjectAt Apple DiningTable)
		(isObjectAt HandheldVacuumCleaner SideTable))
    (:goal (and (isClean DiningTable)
		(isObjectIn Apple LunchBox)
		(isGripperEmpty Robot)))
)