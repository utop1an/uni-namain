(define (problem problem_1)
    (:domain pizza)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              basilicum - INGREDIENT 
              bottle - CONTAINER 
              bowl - CONTAINER 
              gorgonzola - INGREDIENT 
              mozzarella - INGREDIENT 
              mushrooms - INGREDIENT 
              olive_oil - LIQUID 
              olives - INGREDIENT 
              oregano - INGREDIENT 
              oven - OVEN 
              peperoni - INGREDIENT 
              pepper - INGREDIENT 
              pizza - PIZZA 
              pizza_dough - DOUGH 
              plate - CONTAINER 
              salami - INGREDIENT 
              salt - INGREDIENT 
              tomato_sauce - LIQUID 
    )
    (:init (inContainer basilicum bowl)
		(inContainer gorgonzola bowl)
		(inContainer mozzarella bowl)
		(inContainer mushrooms bowl)
		(inContainer olives bowl)
		(inContainer oregano bowl)
		(inContainer peperoni bowl)
		(inContainer pepper bowl)
		(inContainer salami bowl)
		(inContainer salt bowl)
		(liquidInContainer olive_oil bottle)
		(liquidInContainer tomato_sauce bottle)
		(ovenWarm oven))
    (:goal (pizzaBaked pizza))
)