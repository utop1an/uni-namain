(define (problem Little_Snow-White_problem)
   (:domain Little_Snow-White)


   (:init 
      (alive queen)
      (alive king)
      (alive huntsman)
      (alive boar)
      (alive dwarf1)
      (alive dwarf2)
      (alive dwarf3)
      (alive dwarf4)
      (alive dwarf5)
      (alive dwarf6)
      (alive dwarf7)
      (alive prince)
      (has queen needle)
      (has queen looking_glass)
   )

   (:goal 
      (and (alive snow_white) (alive prince) (dead queen) (fair prince))
   )
)