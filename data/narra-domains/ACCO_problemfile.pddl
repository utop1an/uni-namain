(define (problem The_Accomplished_And_Lucky_Teakettle_problem)
   (:domain The_Accomplished_And_Lucky_Teakettle)


   (:init 
      (has priest teakettle)
      (has tinker copper_coins)
      (has tinker pack)
      (located teakettle morinji)
      (located box morinji)
   )

   (:goal 
      (and (located teakettle morinji) (treasured teakettle) (worshipped teakettle) (wealthy tinker))
   )
)