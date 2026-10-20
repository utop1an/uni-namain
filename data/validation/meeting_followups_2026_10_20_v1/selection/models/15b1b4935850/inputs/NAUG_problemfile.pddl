(define (problem The_Naughty_Comet_problem)
   (:domain The_Naughty_Comet)


   (:init 
      (at comet_master courtyard)
      (at short_tail_73 courtyard)
      (gate_open)
      (on_list short_tail_73)
   )

   (:goal 
      (and (burned short_tail_73) (crossed_out short_tail_73) (summoned no1_express) (has_mission no1_express) (arrested no1_express meteor) (detained meteor) (delivered meteor bungo) (punished meteor))
   )
)