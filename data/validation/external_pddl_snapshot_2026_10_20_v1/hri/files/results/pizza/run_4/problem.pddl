(define (problem problem_1)
    (:domain pizza)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              basilicum - SOLID_INGREDIENT 
              bottle_for_olive_oil - CONTAINER 
              bottle_for_tomato_sauce - CONTAINER 
              bowl_for_basilicum - CONTAINER 
              bowl_for_gorgonzola - CONTAINER 
              bowl_for_mozzarella - CONTAINER 
              bowl_for_mushrooms - CONTAINER 
              bowl_for_olives - CONTAINER 
              bowl_for_oregano - CONTAINER 
              bowl_for_peperoni - CONTAINER 
              bowl_for_pepper - CONTAINER 
              bowl_for_salami - CONTAINER 
              bowl_for_salt - CONTAINER 
              gorgonzola - SOLID_INGREDIENT 
              mozzarella - SOLID_INGREDIENT 
              mushrooms - SOLID_INGREDIENT 
              olive_oil - LIQUID_INGREDIENT 
              olives - SOLID_INGREDIENT 
              oregano - SOLID_INGREDIENT 
              oven - FACILITY 
              peperoni - SOLID_INGREDIENT 
              pepper - SOLID_INGREDIENT 
              plate - SURFACE 
              salami - SOLID_INGREDIENT 
              salt - SOLID_INGREDIENT 
              table - FACILITY 
              tomato_sauce - LIQUID_INGREDIENT 
    )
    (:init (isEmpty plate)
		(isWarm oven)
		(onTable plate))
    (:goal (not (isEmpty plate)))
)