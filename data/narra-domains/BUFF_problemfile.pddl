(define (problem The_Buffoon_And_The_Countryman_problem)
   (:domain The_Buffoon_And_The_Countryman)


   (:init 
      (theater_opened rich_nobleman theater)
      (reward_announced rich_nobleman)
      (crowd_present audience theater)
      (on_platform buffoon platform)
      (on_platform countryman platform)
   )

   (:goal 
      (and (theater_opened rich_nobleman theater) (reward_announced rich_nobleman) (on_platform buffoon platform) (performs_without_apparatus buffoon) (imitates_pig buffoon) (audience_demands_shake_cloak audience buffoon cloak) (cloak_shaken buffoon cloak) (applause_given audience buffoon) (countryman_declares_intent countryman) (on_platform countryman platform) (countryman_performs_with_real_pig countryman little_pig) (audience_calls_for_kickout audience countryman) (pig_revealed countryman little_pig))
   )
)