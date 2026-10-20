(define (problem problem_1)
    (:domain pizza)
    (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
    (:objects 
              basilicum - INGREDIENT_SOLID 
              gorgonzola - INGREDIENT_SOLID 
              mozzarella - INGREDIENT_SOLID 
              mushrooms - INGREDIENT_SOLID 
              oliveOil - INGREDIENT_LIQUID 
              olives - INGREDIENT_SOLID 
              oregano - INGREDIENT_SOLID 
              oven - OTHER_OBJECT 
              pepper - INGREDIENT_SOLID 
              pepperoni - INGREDIENT_SOLID 
              pizzaDough - OTHER_OBJECT 
              salami - INGREDIENT_SOLID 
              salt - INGREDIENT_SOLID 
              table - OTHER_OBJECT 
              tomatoSauce - INGREDIENT_LIQUID 
    )
    (:init (isLiquidOnTable oliveOil)
		(isLiquidOnTable tomatoSauce)
		(isOtherObjectOnTable pizzaDough)
		(isSolidOnTable basilicum)
		(isSolidOnTable gorgonzola)
		(isSolidOnTable mozzarella)
		(isSolidOnTable mushrooms)
		(isSolidOnTable olives)
		(isSolidOnTable oregano)
		(isSolidOnTable pepper)
		(isSolidOnTable pepperoni)
		(isSolidOnTable salami)
		(isSolidOnTable salt)
		(isUntopped pizzaDough)
		(isWarm oven))
    (:goal (isBaked pizzaDough))
)