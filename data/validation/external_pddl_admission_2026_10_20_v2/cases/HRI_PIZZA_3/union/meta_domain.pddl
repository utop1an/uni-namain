(define (domain narrative_union)
  (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
  (:types
    d000__t_basilicum d000__t_gorgonzola d000__t_ingredient_liquid d000__t_ingredient_solid d000__t_mozzarella d000__t_mushrooms d000__t_oliveoil d000__t_olives d000__t_oregano d000__t_other_object d000__t_oven d000__t_pepper d000__t_pepperoni d000__t_pizzadough d000__t_salami d000__t_salt d000__t_table d000__t_tomatosauce - d000__t_object
    d000__t_object - object
  )
  (:predicates
    (d000__p_hasliquidingredient ?pizzaDough - d000__t_other_object ?tomatoSauce - d000__t_ingredient_liquid)
    (d000__p_hassolidingredient ?pizzaDough - d000__t_other_object ?ingredient - d000__t_ingredient_solid)
    (d000__p_isbaked ?pizzaDough - d000__t_other_object)
    (d000__p_isliquidontable ?tomatoSauce - d000__t_ingredient_liquid)
    (d000__p_isotherobjectontable ?pizzaDough - d000__t_other_object)
    (d000__p_issolidontable ?ingredient - d000__t_ingredient_solid)
    (d000__p_isuntopped ?pizzaDough - d000__t_other_object)
    (d000__p_iswarm ?oven - d000__t_other_object)
  )

  (:action d000__a_addsolid
    :parameters (?ingredient - d000__t_ingredient_solid ?pizzaDough - d000__t_other_object)
    :precondition (d000__p_issolidontable ?ingredient)
    :effect (d000__p_hassolidingredient ?pizzaDough ?ingredient)
  )

  (:action d000__a_bake
    :parameters (?oven - d000__t_other_object ?pizzaDough - d000__t_other_object)
    :precondition (and (d000__p_iswarm ?oven) (d000__p_isotherobjectontable ?pizzaDough))
    :effect (d000__p_isbaked ?pizzaDough)
  )

  (:action d000__a_drizzle
    :parameters (?oliveOil - d000__t_ingredient_liquid ?pizzaDough - d000__t_other_object)
    :precondition (d000__p_isliquidontable ?oliveOil)
    :effect (d000__p_hasliquidingredient ?pizzaDough ?oliveOil)
  )

  (:action d000__a_spread
    :parameters (?pizzaDough - d000__t_other_object ?tomatoSauce - d000__t_ingredient_liquid)
    :precondition (and (d000__p_isuntopped ?pizzaDough) (d000__p_isliquidontable ?tomatoSauce))
    :effect (and (not (d000__p_isuntopped ?pizzaDough)) (d000__p_hasliquidingredient ?pizzaDough ?tomatoSauce))
  )
)
