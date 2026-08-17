(define (domain Little_Snow-White)
   (:requirements
      :strips :typing)

   (:types 
      entity - object
      item - object
      location - object
   )

   (:constants 
      apple - item
      bed - item
      blood_drop - item
      boar - entity
      boar_heart - item
      candle - item
      coffin - item
      comb - item
      cottage - location
      dove - entity
      dwarf1 - entity
      dwarf2 - entity
      dwarf3 - entity
      dwarf4 - entity
      dwarf5 - entity
      dwarf6 - entity
      dwarf7 - entity
      forest - location
      fork - item
      golden_letter - item
      huntsman - entity
      iron_slippers - item
      king - entity
      knife - item
      lace - item
      looking_glass - item
      mountain - location
      mug - item
      needle - item
      owl - entity
      plate - item
      prince - entity
      queen - entity
      raven - entity
      red_hot_shoes - item
      salt - item
      snow_white - entity
      spoon - item
   )

   (:predicates 
      (alive ?e - entity)
      (at ?e - entity ?l - location)
      (at_item ?i - item ?l - location)
      (awake ?e - entity)
      (dead ?e - entity)
      (disguised_as ?e - entity ?d - entity)
      (envious ?e - entity)
      (fair ?e - entity)
      (fairest ?e - entity)
      (has ?e - entity ?i - item)
      (in_coffin ?e - entity)
      (laced ?e - entity ?i - item)
      (poisoned ?i - item)
      (sleeping ?e - entity)
      (visited ?e - entity ?l - location)
      (wearing ?e - entity ?i - item)
   )

   (:action queen_sews_at_window
     :parameters (?q - entity ?l - location)
     :precondition (and (alive ?q) (at ?q ?l))
     :effect (has ?q needle)
   )
   
   (:action queen_pricks_finger
     :parameters (?q - entity ?blood ?needle - item)
     :precondition (and (alive ?q) (has ?q ?needle))
     :effect (has ?q ?blood)
   )
   
   (:action queen_wishes_child_white_red_black
     :parameters (?c ?q - entity)
     :precondition (alive ?q)
     :effect (fair ?c)
   )
   
   (:action child_is_born_and_queen_dies
     :parameters (?c ?q - entity)
     :precondition (and (not (alive ?c)) (alive ?q))
     :effect (and (alive ?c) (dead ?q) (not (alive ?q)))
   )
   
   (:action king_marries_stepmother
     :parameters (?k ?s - entity)
     :precondition (and (alive ?k) (alive ?s))
     :effect (fair ?s)
   )
   
   (:action stepmother_asks_looking_glass_fairest
     :parameters (?s - entity ?g - item)
     :precondition (and (alive ?s) (has ?s ?g))
     :effect (fairest ?s)
   )
   
   (:action stepmother_becomes_envious_of_snow_white
     :parameters (?c ?s - entity)
     :precondition (and (fairest ?c) (fair ?c) (alive ?s))
     :effect (envious ?s)
   )
   
   (:action stepmother_orders_huntsman_to_kill_snow_white
     :parameters (?c ?h ?s - entity)
     :precondition (and (envious ?s) (alive ?h) (alive ?c))
     :effect (fair ?s)
   )
   
   (:action huntsman_spares_snow_white_and_brings_boar_heart
     :parameters (?b ?c ?h - entity ?heart - item)
     :precondition (and (alive ?h) (alive ?c) (alive ?b))
     :effect (and (has ?h ?heart) (dead ?b))
   )
   
   (:action stepmother_eats_boar_heart_thinking_it_is_snow_white_heart
     :parameters (?s - entity ?heart - item)
     :precondition (has ?s ?heart)
     :effect (not (has ?s ?heart))
   )
   
   (:action snow_white_flees_into_forest
     :parameters (?c - entity ?f - location)
     :precondition (alive ?c)
     :effect (at ?c ?f)
   )
   
   (:action snow_white_finds_dwarfs_cottage
     :parameters (?c - entity ?cottage - location)
     :precondition (alive ?c)
     :effect (at ?c ?cottage)
   )
   
   (:action snow_white_eats_vegetables_and_bread_and_drinks_wine
     :parameters (?c - entity ?mug ?plate - item)
     :precondition (alive ?c)
     :effect (and (has ?c ?plate) (has ?c ?mug))
   )
   
   (:action snow_white_sleeps_in_seventh_bed
     :parameters (?c - entity ?bed - item)
     :precondition (alive ?c)
     :effect (sleeping ?c)
   )
   
   (:action dwarfs_return_and_discover_snow_white
     :parameters (?c ?d - entity)
     :precondition (and (alive ?d) (sleeping ?c))
     :effect (awake ?d)
   )
   
   (:action dwarfs_offer_snow_white_to_maintain_house
     :parameters (?c ?d - entity)
     :precondition (and (alive ?d) (alive ?c) (sleeping ?c))
     :effect (and (awake ?c) (not (sleeping ?c)))
   )
   
   (:action stepmother_disguises_as_old_woman_and_visits_cottage
     :parameters (?old_woman ?s - entity ?cottage - location)
     :precondition (alive ?s)
     :effect (and (disguised_as ?s ?old_woman) (visited ?s ?cottage))
   )
   
   (:action stepmother_laces_snow_white_tightly
     :parameters (?c ?s - entity ?lace - item)
     :precondition (and (alive ?c) (has ?c ?lace))
     :effect (and (laced ?c ?lace) (dead ?c) (not (alive ?c)) (not (sleeping ?c)))
   )
   
   (:action dwarfs_cut_laces_rescue_snow_white
     :parameters (?c ?d - entity ?lace - item)
     :precondition (and (laced ?c ?lace) (dead ?c))
     :effect (and (alive ?c) (awake ?c) (not (laced ?c ?lace)) (not (dead ?c)))
   )
   
   (:action stepmother_makes_poisonous_comb_and_visits_cottage
     :parameters (?s - entity ?comb - item ?cottage - location)
     :precondition (alive ?s)
     :effect (and (poisoned ?comb) (has ?s ?comb) (visited ?s ?cottage))
   )
   
   (:action stepmother_comb_poison_snow_white
     :parameters (?c ?s - entity ?comb - item)
     :precondition (and (has ?s ?comb) (poisoned ?comb) (alive ?c))
     :effect (and (dead ?c) (not (alive ?c)))
   )
   
   (:action dwarfs_remove_comb_rescue_snow_white
     :parameters (?c ?d - entity ?comb - item)
     :precondition (and (dead ?c) (poisoned ?comb) (has ?d ?comb))
     :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?comb)))
   )
   
   (:action stepmother_makes_poisonous_apple_and_visits_cottage
     :parameters (?s - entity ?apple - item ?cottage - location)
     :precondition (alive ?s)
     :effect (and (poisoned ?apple) (has ?s ?apple) (visited ?s ?cottage))
   )
   
   (:action snow_white_eats_poisoned_apple_and_dies
     :parameters (?c - entity ?apple - item)
     :precondition (and (poisoned ?apple) (alive ?c))
     :effect (and (dead ?c) (not (alive ?c)))
   )
   
   (:action dwarfs_prepare_glass_coffin_for_snow_white
     :parameters (?c ?d - entity ?coffin - item)
     :precondition (dead ?c)
     :effect (and (in_coffin ?c) (has ?d ?coffin))
   )
   
   (:action prince_discovers_coffin_and_moves_it
     :parameters (?c ?p - entity ?coffin - item ?mountain - location)
     :precondition (and (in_coffin ?c) (alive ?p))
     :effect (at_item ?coffin ?mountain)
   )
   
   (:action apple_piece_falls_out_reviving_snow_white
     :parameters (?c - entity ?apple - item)
     :precondition (and (dead ?c) (poisoned ?apple))
     :effect (and (alive ?c) (not (dead ?c)) (not (poisoned ?apple)))
   )
   
   (:action prince_marries_snow_white
     :parameters (?c ?p - entity)
     :precondition (and (alive ?p) (alive ?c))
     :effect (fair ?p)
   )
   
   (:action stepmother_attends_wedding_and_is_forced_to_wear_hot_slippers_and_dies
     :parameters (?s - entity ?slippers - item)
     :precondition (alive ?s)
     :effect (and (wearing ?s ?slippers) (dead ?s) (not (alive ?s)))
   )
)