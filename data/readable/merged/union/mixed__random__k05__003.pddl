(define (domain revised_merged)
  (:requirements :adl :intentionality :strips :typing)
  (:types)
  (:constants tiny_stories__story_005_o_tim - object)
  (:predicates
    (human_1fe4b2f08d46fd1e_active)
    (human_1fe4b2f08d46fd1e_type_creature ?x - object)
    (human_1fe4b2f08d46fd1e_type_item ?x - object)
    (human_1fe4b2f08d46fd1e_type_monster ?x - object)
    (human_1fe4b2f08d46fd1e_type_object ?x - object)
    (human_1fe4b2f08d46fd1e_type_person ?x - object)
    (human_1fe4b2f08d46fd1e_type_place ?x - object)
    (human_1fe4b2f08d46fd1e_type_valuable ?x - object)
    (human_1fe4b2f08d46fd1e_p_alive ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_single ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_rich ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_happy ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_at ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_has ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_belongsto ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_loves ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
    (tiny_stories__story_005_active)
    (tiny_stories__story_005_type_character ?x - object)
    (tiny_stories__story_005_type_object ?x - object)
    (tiny_stories__story_005_p_alive ?v0 - object)
    (tiny_stories__story_005_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_005_p_shaking-tree ?v0 - object)
    (tiny_stories__story_005_p_wind-blows)
    (tiny_stories__story_009_active)
    (tiny_stories__story_009_type_character ?x - object)
    (tiny_stories__story_009_type_object ?x - object)
    (tiny_stories__story_009_p_reading ?v0 - object)
    (tiny_stories__story_009_p_playing ?v0 - object)
    (tiny_stories__story_009_p_calm ?v0 - object)
    (tiny_stories__story_009_p_books-fall)
    (tiny_stories__story_093_active)
    (tiny_stories__story_093_type_character ?x - object)
    (tiny_stories__story_093_type_item ?x - object)
    (tiny_stories__story_093_type_mop ?x - object)
    (tiny_stories__story_093_type_object ?x - object)
    (tiny_stories__story_093_type_place ?x - object)
    (tiny_stories__story_093_p_at ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_has ?v0 - object ?v1 - object)
    (tiny_stories__story_093_p_clean ?v0 - object)
    (tiny_stories__story_093_p_pretty ?v0 - object)
    (tiny_stories__story_093_p_disgusting ?v0 - object)
    (tiny_stories__story_093_p_selected ?v0 - object)
    (writing_prompts__wp_077_active)
    (writing_prompts__wp_077_type_object ?x - object)
    (writing_prompts__wp_077_type_poem ?x - object)
    (writing_prompts__wp_077_type_reader ?x - object)
    (writing_prompts__wp_077_p_read ?v0 - object ?v1 - object)
    (writing_prompts__wp_077_p_alive ?v0 - object)
    (writing_prompts__wp_077_p_dead ?v0 - object)
    (writing_prompts__wp_077_p_echo ?v0 - object ?v1 - object)
  )

  (:action human_1fe4b2f08d46fd1e_a_travel
    :parameters (?creature - object ?from - object ?to - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?from)
        (human_1fe4b2f08d46fd1e_type_place ?to)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?creature)
          (human_1fe4b2f08d46fd1e_p_at ?creature ?from)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_at ?creature ?to)
        (not (human_1fe4b2f08d46fd1e_p_at ?creature ?from))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_propose
    :parameters (?proposer - object ?proposee - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_person ?proposee)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?proposer)
          (human_1fe4b2f08d46fd1e_p_at ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposee)
          (human_1fe4b2f08d46fd1e_p_at ?proposee ?place)
          (human_1fe4b2f08d46fd1e_p_loves ?proposer ?proposee)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?proposee)
    :agents (?proposer)
  )

  (:action human_1fe4b2f08d46fd1e_a_accept
    :parameters (?accepter - object ?proposer - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?accepter)
        (human_1fe4b2f08d46fd1e_type_person ?proposer)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?accepter)
          (human_1fe4b2f08d46fd1e_p_at ?accepter ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposer)
          (human_1fe4b2f08d46fd1e_p_at ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?proposer ?accepter)
        )
      )
    :effect
      (human_1fe4b2f08d46fd1e_p_hasaccepted ?accepter ?proposer)
    :agents (?accepter)
  )

  (:action human_1fe4b2f08d46fd1e_a_marry
    :parameters (?groom - object ?bride - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_person ?groom)
        (human_1fe4b2f08d46fd1e_type_person ?bride)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?groom)
          (human_1fe4b2f08d46fd1e_p_at ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (human_1fe4b2f08d46fd1e_p_alive ?bride)
          (human_1fe4b2f08d46fd1e_p_at ?bride ?place)
          (human_1fe4b2f08d46fd1e_p_hasaccepted ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_single ?bride)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_marriedto ?groom ?bride)
        (human_1fe4b2f08d46fd1e_p_marriedto ?bride ?groom)
        (not (human_1fe4b2f08d46fd1e_p_single ?groom))
        (not (human_1fe4b2f08d46fd1e_p_single ?bride))
        (forall
          (?v - object)
          (when
            (and
              (human_1fe4b2f08d46fd1e_type_valuable ?v)
              (human_1fe4b2f08d46fd1e_p_has ?groom ?v)
            )
            (human_1fe4b2f08d46fd1e_p_rich ?bride)
          )
        )
        (when
          (human_1fe4b2f08d46fd1e_p_loves ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_happy ?groom)
        )
        (when
          (human_1fe4b2f08d46fd1e_p_loves ?bride ?groom)
          (human_1fe4b2f08d46fd1e_p_happy ?bride)
        )
      )
    :agents (?groom ?bride)
  )

  (:action human_1fe4b2f08d46fd1e_a_steal
    :parameters (?thief - object ?victim - object ?item - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?thief)
        (human_1fe4b2f08d46fd1e_type_creature ?victim)
        (human_1fe4b2f08d46fd1e_type_item ?item)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (not (= ?thief ?victim))
          (human_1fe4b2f08d46fd1e_p_alive ?thief)
          (human_1fe4b2f08d46fd1e_p_at ?thief ?place)
          (human_1fe4b2f08d46fd1e_p_at ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_has ?thief ?item)
        (when
          (human_1fe4b2f08d46fd1e_p_at ?victim ?place)
          (intends ?victim (human_1fe4b2f08d46fd1e_p_has ?victim ?item))
        )
        (when
          (forall
            (?v - object)
            (or
              (not (human_1fe4b2f08d46fd1e_type_valuable ?v))
              (not (human_1fe4b2f08d46fd1e_p_has ?victim ?v))
            )
          )
          (not (human_1fe4b2f08d46fd1e_p_rich ?victim))
        )
      )
    :agents (?thief)
  )

  (:action human_1fe4b2f08d46fd1e_a_get-hungry
    :parameters (?creature - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (not (human_1fe4b2f08d46fd1e_p_hungry ?creature))
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_hungry ?creature)
        (intends ?creature (not (human_1fe4b2f08d46fd1e_p_hungry ?creature)))
      )
    :agents (?creature)
  )

  (:action human_1fe4b2f08d46fd1e_a_eat
    :parameters (?monster - object ?creature - object ?place - object)
    :precondition
      (and
        (human_1fe4b2f08d46fd1e_active)
        (human_1fe4b2f08d46fd1e_type_monster ?monster)
        (human_1fe4b2f08d46fd1e_type_creature ?creature)
        (human_1fe4b2f08d46fd1e_type_place ?place)
        (and
          (human_1fe4b2f08d46fd1e_p_alive ?monster)
          (human_1fe4b2f08d46fd1e_p_at ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (human_1fe4b2f08d46fd1e_p_alive ?creature)
          (human_1fe4b2f08d46fd1e_p_at ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (human_1fe4b2f08d46fd1e_p_alive ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (human_1fe4b2f08d46fd1e_p_happy ?creature))
      )
    :agents (?monster)
  )

  (:action tiny_stories__story_005_a_play
    :parameters (?character - object ?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?object)
        (and
          (tiny_stories__story_005_p_alive ?character)
          (tiny_stories__story_005_p_has ?character ?object)
        )
      )
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_shake-tree
    :parameters (?character - object ?tree - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_type_object ?tree)
        (and
          (tiny_stories__story_005_p_alive ?character)
          (tiny_stories__story_005_p_at ?character ?tree)
        )
      )
    :effect
      (tiny_stories__story_005_p_shaking-tree ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_stop-shaking-tree
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_character ?character)
        (tiny_stories__story_005_p_shaking-tree ?character)
      )
    :effect
      (not (tiny_stories__story_005_p_shaking-tree ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_005_a_wind-blows-object
    :parameters (?object - object)
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_type_object ?object)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_has tiny_stories__story_005_o_tim ?object))
  )

  (:action tiny_stories__story_005_a_start-wind
    :parameters ()
    :precondition
      (tiny_stories__story_005_active)
    :effect
      (tiny_stories__story_005_p_wind-blows)
  )

  (:action tiny_stories__story_005_a_stop-wind
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_005_active)
        (tiny_stories__story_005_p_wind-blows)
      )
    :effect
      (not (tiny_stories__story_005_p_wind-blows))
  )

  (:action tiny_stories__story_009_a_start-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_reading ?character))
      )
    :effect
      (tiny_stories__story_009_p_reading ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-reading
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_reading ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_reading ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_start-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_playing ?character))
      )
    :effect
      (tiny_stories__story_009_p_playing ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_stop-playing
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_playing ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_playing ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-calm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (not (tiny_stories__story_009_p_calm ?character))
      )
    :effect
      (tiny_stories__story_009_p_calm ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_become-uncalm
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_009_active)
        (tiny_stories__story_009_type_character ?character)
        (tiny_stories__story_009_p_calm ?character)
      )
    :effect
      (not (tiny_stories__story_009_p_calm ?character))
    :agents (?character)
  )

  (:action tiny_stories__story_009_a_books-fall
    :parameters ()
    :precondition
      (and
        (tiny_stories__story_009_active)
        (not (tiny_stories__story_009_p_books-fall))
      )
    :effect
      (tiny_stories__story_009_p_books-fall)
  )

  (:action tiny_stories__story_093_a_go-to
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_place ?place)
        (tiny_stories__story_093_p_at ?character ?place)
      )
    :effect
      (tiny_stories__story_093_p_at ?character ?place)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_select-mop
    :parameters (?character - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (tiny_stories__story_093_p_at ?character ?place)
          (tiny_stories__story_093_p_has ?character ?mop)
        )
      )
    :effect
      (tiny_stories__story_093_p_selected ?mop)
    :agents (?character)
  )

  (:action tiny_stories__story_093_a_receive-mop
    :parameters (?character - object ?dog - object ?mop - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_093_active)
        (tiny_stories__story_093_type_character ?character)
        (tiny_stories__story_093_type_character ?dog)
        (tiny_stories__story_093_type_mop ?mop)
        (tiny_stories__story_093_type_place ?place)
        (and
          (tiny_stories__story_093_p_at ?character ?place)
          (tiny_stories__story_093_p_at ?dog ?place)
          (tiny_stories__story_093_p_has ?dog ?mop)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_093_p_has ?dog ?mop))
        (tiny_stories__story_093_p_has ?character ?mop)
      )
    :agents (?character)
  )

  (:action writing_prompts__wp_077_a_read-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (not (writing_prompts__wp_077_p_read ?reader ?poem))
          (writing_prompts__wp_077_p_alive ?poem)
        )
      )
    :effect
      (and
        (writing_prompts__wp_077_p_read ?reader ?poem)
        (writing_prompts__wp_077_p_echo ?reader ?poem)
      )
    :agents (?reader)
  )

  (:action writing_prompts__wp_077_a_poem-dies
    :parameters (?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_poem ?poem)
        (writing_prompts__wp_077_p_alive ?poem)
      )
    :effect
      (and
        (not (writing_prompts__wp_077_p_alive ?poem))
        (writing_prompts__wp_077_p_dead ?poem)
      )
  )

  (:action writing_prompts__wp_077_a_echo-poem
    :parameters (?reader - object ?poem - object)
    :precondition
      (and
        (writing_prompts__wp_077_active)
        (writing_prompts__wp_077_type_reader ?reader)
        (writing_prompts__wp_077_type_poem ?poem)
        (and
          (writing_prompts__wp_077_p_read ?reader ?poem)
          (not (writing_prompts__wp_077_p_echo ?reader ?poem))
        )
      )
    :effect
      (writing_prompts__wp_077_p_echo ?reader ?poem)
    :agents (?reader)
  )
)
