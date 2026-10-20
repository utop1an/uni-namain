(define (problem Soup_From_A_Sausage_Skewer_problem)
   (:domain Soup_From_A_Sausage_Skewer)


   (:init 
      (at mouse_king kitchen)
      (at old_lady_mouse kitchen)
      (at young_lady_mouse kitchen)
      (at first_traveler_mouse kitchen)
      (at second_traveler_mouse kitchen)
      (at third_traveler_mouse kitchen)
      (holds first_traveler_mouse sausage_skewer)
      (holds second_traveler_mouse sausage_skewer)
      (holds third_traveler_mouse sausage_skewer)
   )

   (:goal 
      (is_queen third_traveler_mouse)
   )
)