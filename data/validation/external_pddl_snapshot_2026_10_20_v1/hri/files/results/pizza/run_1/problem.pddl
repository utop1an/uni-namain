(define (problem problem_1)
    (:domain pizza)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              basilicum - INGREDIENT 
              chef - AGENT 
              gorgonzola - INGREDIENT 
              mozzarella - INGREDIENT 
              mushrooms - INGREDIENT 
              olive_oil - LIQUID_INGREDIENT 
              olives - INGREDIENT 
              oregano - INGREDIENT 
              oven - TOOL 
              peperoni - INGREDIENT 
              pepper - INGREDIENT 
              pizza_dough - DOUGH 
              salami - INGREDIENT 
              salt - INGREDIENT 
              table - TOOL 
              tomato_sauce - LIQUID_INGREDIENT 
    )
    (:init (ovenWarm oven))
    (:goal (pizzaReady pizza_dough))
)