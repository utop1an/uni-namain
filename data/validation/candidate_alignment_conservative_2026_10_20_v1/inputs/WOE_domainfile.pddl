(define (domain Woe_Bogotir)
   (:requirements
      :existential-preconditions :strips :typing)

   (:types 
      entity - object
      item - object
      location - object
   )

   (:constants 
      big_house - location
      bitter_woe - entity
      cattle - item
      children - entity
      copecks_25 - item
      forest - location
      gold_pot - item
      grove - item
      harrow - item
      honey - item
      izba - location
      kabak - location
      large_town - location
      loaf_bread - item
      new_home - location
      plow - item
      poor_brother - entity
      rich_brother - entity
      sledge - item
      stone - item
      telega - item
      treasure_pit - location
      village - location
      well - location
      wife - entity
      wine - item
      yard - location
   )

   (:predicates 
      (at ?e - entity ?l - location)
      (banquet_at ?l - location)
      (bowed ?e - entity ?l - location)
      (concealed ?i - item)
      (drunk ?e - entity)
      (employed ?worker - entity ?employer - entity)
      (gold_at ?g - item ?l - location)
      (guest_present ?guest - entity ?l - location)
      (has ?e - entity ?i - item)
      (has_fatigue ?e - entity)
      (has_strength ?e - entity)
      (invitation_sent ?sender - entity ?receiver - entity)
      (invited ?invitee - entity ?host - entity)
      (need_help ?e - entity)
      (poor ?e - entity)
      (rich ?e - entity)
      (singing ?e - entity)
      (stone_at ?s - item ?l - location)
      (stone_moved ?s - item)
      (trapped ?m - entity)
      (woe_on_shoulder ?monster - entity ?carrier - entity)
      (work_done ?worker - entity ?employer - entity)
   )

   (:action request_help_from_rich_brother
     :parameters (?poor ?rich - entity)
     :precondition (and (need_help ?poor) (rich ?rich))
     :effect (and (employed ?poor ?rich) (not (need_help ?poor)))
   )
   
   (:action perform_work_for_rich_brother
     :parameters (?employer ?worker - entity)
     :precondition (and (employed ?worker ?employer) (has_strength ?worker))
     :effect (and (work_done ?worker ?employer) (has_fatigue ?worker))
   )
   
   (:action receive_payment
     :parameters (?employer ?worker - entity ?bread ?money - item)
     :precondition (and (work_done ?worker ?employer) (has ?employer ?money) (has ?employer ?bread))
     :effect (and (has ?worker ?money) (has ?worker ?bread) (not (has ?employer ?money)) (not (has ?employer ?bread)))
   )
   
   (:action stay_for_banquet
     :parameters (?guest ?host - entity ?loc - location)
     :precondition (and (at ?guest ?loc) (at ?host ?loc) (banquet_at ?loc) (invited ?guest ?host))
     :effect (guest_present ?guest ?loc)
   )
   
   (:action bow_to_guests
     :parameters (?poor - entity ?loc - location)
     :precondition (and (at ?poor ?loc) (exists (?guest - entity) (guest_present ?guest ?loc)))
     :effect (bowed ?poor ?loc)
   )
   
   (:action sing_cheerful_song
     :parameters (?poor - entity ?loc - location)
     :precondition (at ?poor ?loc)
     :effect (singing ?poor)
   )
   
   (:action encounter_bitter_woe
     :parameters (?poor ?woe - entity ?loc - location)
     :precondition (and (at ?poor ?loc) (at ?woe ?loc))
     :effect (has_fatigue ?poor)
   )
   
   (:action make_sign_of_cross
     :parameters (?poor ?woe - entity ?loc - location)
     :precondition (and (at ?poor ?loc) (at ?woe ?loc))
     :effect (has_fatigue ?poor)
   )
   
   (:action allow_woe_to_ride_on_shoulder
     :parameters (?poor ?woe - entity ?loc - location)
     :precondition (and (at ?poor ?loc) (at ?woe ?loc) (has_fatigue ?poor))
     :effect (woe_on_shoulder ?woe ?poor)
   )
   
   (:action spend_money_on_drink
     :parameters (?poor - entity ?money ?wine - item ?kabak - location)
     :precondition (and (has ?poor ?money) (at ?poor ?kabak))
     :effect (and (has ?poor ?wine) (drunk ?poor) (not (has ?poor ?money)))
   )
   
   (:action trade_assets_for_money
     :parameters (?poor - entity ?asset ?money - item)
     :precondition (has ?poor ?asset)
     :effect (and (has ?poor ?money) (not (has ?poor ?asset)))
   )
   
   (:action move_heavy_stone
     :parameters (?carrier - entity ?stone - item ?loc - location)
     :precondition (and (stone_at ?stone ?loc) (has_strength ?carrier))
     :effect (and (stone_moved ?stone) (not (stone_at ?stone ?loc)))
   )
   
   (:action hide_woe_under_stone
     :parameters (?poor ?woe - entity ?stone - item ?loc - location)
     :precondition (and (woe_on_shoulder ?woe ?poor) (stone_at ?stone ?loc))
     :effect (and (trapped ?woe) (stone_at ?stone ?loc) (not (woe_on_shoulder ?woe ?poor)) (not (stone_moved ?stone)))
   )
   
   (:action take_gold_pot_and_hide
     :parameters (?poor - entity ?gold - item ?loc - location)
     :precondition (and (gold_at ?gold ?loc) (at ?poor ?loc))
     :effect (and (has ?poor ?gold) (concealed ?gold) (not (gold_at ?gold ?loc)))
   )
   
   (:action invite_rich_brother_to_feast
     :parameters (?poor ?rich - entity ?loc - location)
     :precondition (at ?poor ?loc)
     :effect (and (invitation_sent ?poor ?rich) (invited ?rich ?poor))
   )
   
   (:action rich_brother_attempt_to_move_stone
     :parameters (?rich - entity ?stone - item ?loc - location)
     :precondition (and (stone_at ?stone ?loc) (rich ?rich))
     :effect (and (stone_moved ?stone) (woe_on_shoulder bitter_woe ?rich) (not (stone_at ?stone ?loc)))
   )
   
   (:action accept_woe_as_burden
     :parameters (?rich ?woe - entity)
     :precondition (woe_on_shoulder ?woe ?rich)
     :effect (has_fatigue ?rich)
   )
)