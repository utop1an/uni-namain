(define (problem problem_1)
    (:domain pizza)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              basil - INGREDIENT_SOLID 
              dough - DOUGH 
              gorgonzola - INGREDIENT_SOLID 
              mozzarella - INGREDIENT_SOLID 
              mushrooms - INGREDIENT_SOLID 
              oliveOil - INGREDIENT_LIQUID 
              olives - INGREDIENT_SOLID 
              oregano - INGREDIENT_SOLID 
              oven - OTHER 
              peperoni - INGREDIENT_SOLID 
              pepper - INGREDIENT_SOLID 
              salami - INGREDIENT_SOLID 
              salt - INGREDIENT_SOLID 
              table - LOCATION 
              tomatoSauce - INGREDIENT_LIQUID 
    )
    (:init (isWarm oven)
		(onTable dough table))
    (:goal (baked dough))
)