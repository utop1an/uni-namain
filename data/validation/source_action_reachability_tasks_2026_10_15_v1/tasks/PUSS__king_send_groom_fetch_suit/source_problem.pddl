(define (problem Puss_In_Boots_problem)
   (:domain Puss_In_Boots)


   (:init 
      (has jack bag)
      (has eldest_son mill)
      (has second_son ass)
      (at_item rabbit warren)
      (at_item suit royal_wardrobe)
      (alive jack)
      (alive puss)
      (alive king)
      (alive princess)
      (alive ogre)
      (alive coachman)
      (alive groom)
      (alive eldest_son)
      (alive second_son)
      (castle_owned_by ogre_castle ogre)
   )

   (:goal 
      (and (married jack princess) (at jack palace) (has puss boots) (wearing puss boots) (gate_open ogre_castle))
   )
)