(define (domain narrative_union)
  (:requirements :disjunctive-preconditions :equality :existential-preconditions :strips :typing)
  (:types
    d000__t_basilicum d000__t_bottle_for_olive_oil d000__t_bottle_for_tomato_sauce d000__t_bowl_for_basilicum d000__t_bowl_for_gorgonzola d000__t_bowl_for_mozzarella d000__t_bowl_for_mushrooms d000__t_bowl_for_olives d000__t_bowl_for_oregano d000__t_bowl_for_peperoni d000__t_bowl_for_pepper d000__t_bowl_for_salami d000__t_bowl_for_salt d000__t_container d000__t_facility d000__t_gorgonzola d000__t_liquid_ingredient d000__t_mozzarella d000__t_mushrooms d000__t_olive_oil d000__t_olives d000__t_oregano d000__t_oven d000__t_peperoni d000__t_pepper d000__t_plate d000__t_salami d000__t_salt d000__t_solid_ingredient d000__t_surface d000__t_table d000__t_tomato_sauce - d000__t_object
    d000__t_object - object
  )
  (:predicates
    (d000__p_isempty ?surface - d000__t_surface)
    (d000__p_isliquid ?liquidIngredient - d000__t_liquid_ingredient)
    (d000__p_issolid ?solidIngredient - d000__t_solid_ingredient)
    (d000__p_iswarm ?facility - d000__t_facility)
    (d000__p_ontable ?surface - d000__t_surface)
    (d000__p_surfacecontainsliquid ?surface - d000__t_surface ?liquidIngredient - d000__t_liquid_ingredient)
    (d000__p_surfacecontainssolid ?surface - d000__t_surface ?solidIngredient - d000__t_solid_ingredient)
  )

  (:action d000__a_addliquidtopping
    :parameters (?liquidIngredient - d000__t_liquid_ingredient ?surface - d000__t_surface)
    :precondition (and (d000__p_isliquid ?liquidIngredient) (d000__p_ontable ?surface))
    :effect (d000__p_surfacecontainsliquid ?surface ?liquidIngredient)
  )

  (:action d000__a_addsolidtopping
    :parameters (?solidIngredient - d000__t_solid_ingredient ?surface - d000__t_surface)
    :precondition (and (d000__p_issolid ?solidIngredient) (d000__p_ontable ?surface) (d000__p_isempty ?surface))
    :effect (and (d000__p_surfacecontainssolid ?surface ?solidIngredient) (not (d000__p_isempty ?surface)))
  )

  (:action d000__a_bakepizza
    :parameters (?facility - d000__t_facility ?surface - d000__t_surface)
    :precondition (and (d000__p_iswarm ?facility) (d000__p_ontable ?surface))
    :effect (not (d000__p_isempty ?surface))
  )
)
