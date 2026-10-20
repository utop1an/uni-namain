(define (domain narrative_union)
  (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
  (:types
    d000__t_agent d000__t_basilicum d000__t_chef d000__t_dough d000__t_gorgonzola d000__t_ingredient d000__t_liquid_ingredient d000__t_mozzarella d000__t_mushrooms d000__t_olive_oil d000__t_olives d000__t_oregano d000__t_oven d000__t_peperoni d000__t_pepper d000__t_pizza_dough d000__t_salami d000__t_salt d000__t_table d000__t_tomato_sauce d000__t_tool - d000__t_object
    d000__t_object - object
  )
  (:predicates
    (d000__p_doughhasliquid ?Dough - d000__t_dough)
    (d000__p_doughhassolid ?Dough - d000__t_dough)
    (d000__p_ingredientready ?Ingredient - d000__t_ingredient)
    (d000__p_liquidingredientready ?LiquidIngredient - d000__t_liquid_ingredient)
    (d000__p_ovencontains ?Oven - d000__t_tool ?Dough - d000__t_dough)
    (d000__p_ovenwarm ?Oven - d000__t_tool)
    (d000__p_pizzacooked ?Dough - d000__t_dough)
    (d000__p_pizzaready ?Dough - d000__t_dough)
  )

  (:action d000__a_addliquidtodough
    :parameters (?LiquidIngredient - d000__t_liquid_ingredient ?Dough - d000__t_dough)
    :precondition (d000__p_liquidingredientready ?LiquidIngredient)
    :effect (d000__p_doughhasliquid ?Dough)
  )

  (:action d000__a_addsolidtodough
    :parameters (?Ingredient - d000__t_ingredient ?Dough - d000__t_dough)
    :precondition (d000__p_ingredientready ?Ingredient)
    :effect (d000__p_doughhassolid ?Dough)
  )

  (:action d000__a_bakepizza
    :parameters (?Oven - d000__t_tool ?Dough - d000__t_dough)
    :precondition (d000__p_ovencontains ?Oven ?Dough)
    :effect (and (not (d000__p_ovencontains ?Oven ?Dough)) (d000__p_pizzacooked ?Dough))
  )

  (:action d000__a_chooseliquid
    :parameters (?LiquidIngredient - d000__t_liquid_ingredient)
    :precondition (and)
    :effect (d000__p_liquidingredientready ?LiquidIngredient)
  )

  (:action d000__a_choosesolid
    :parameters (?Ingredient - d000__t_ingredient)
    :precondition (and)
    :effect (d000__p_ingredientready ?Ingredient)
  )

  (:action d000__a_placeinoven
    :parameters (?Dough - d000__t_dough ?Oven - d000__t_tool)
    :precondition (and (d000__p_doughhassolid ?Dough) (d000__p_doughhasliquid ?Dough) (d000__p_ovenwarm ?Oven))
    :effect (d000__p_ovencontains ?Oven ?Dough)
  )

  (:action d000__a_takeoutpizza
    :parameters (?Dough - d000__t_dough)
    :precondition (d000__p_pizzacooked ?Dough)
    :effect (d000__p_pizzaready ?Dough)
  )
)
