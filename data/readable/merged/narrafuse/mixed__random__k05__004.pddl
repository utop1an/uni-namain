(define (domain revised_merged)
  (:requirements :adl :domain-axioms :intentionality :strips :typing)
  (:types)
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
    (shared_p_consensus_57c71c7675e3190f ?v0 - object)
    (human_1fe4b2f08d46fd1e_p_hungry ?v0 - object)
    (shared_p_consensus_3aebbe42b29c6cb8 ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_has ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_belongsto ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_loves ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasproposed ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_hasaccepted ?v0 - object ?v1 - object)
    (human_1fe4b2f08d46fd1e_p_marriedto ?v0 - object ?v1 - object)
    (tiny_stories__story_048_active)
    (tiny_stories__story_048_type_character ?x - object)
    (tiny_stories__story_048_type_object ?x - object)
    (tiny_stories__story_048_type_place ?x - object)
    (tiny_stories__story_048_p_dry ?v0 - object)
    (tiny_stories__story_048_p_wet ?v0 - object)
    (tiny_stories__story_048_p_sad ?v0 - object)
    (shared_p_consensus_784b4811611fee97 ?v0 - object ?v1 - object)
    (tiny_stories__story_091_active)
    (tiny_stories__story_091_type_animal ?x - object)
    (tiny_stories__story_091_type_object ?x - object)
    (tiny_stories__story_091_type_plant ?x - object)
    (tiny_stories__story_091_type_sun ?x - object)
    (shared_p_consensus_b43e64c129005afa ?v0 - object)
    (shared_p_consensus_6ff15ab49cfb884c ?v0 - object)
    (tiny_stories__story_091_p_growing ?v0 - object)
    (tiny_stories__story_091_p_strong ?v0 - object)
    (tiny_stories__story_091_p_provides-shade ?v0 - object)
    (tiny_stories__story_091_p_provides-home ?v0 - object)
    (tiny_stories__story_091_p_generous ?v0 - object)
    (tiny_stories__story_091_p_gives-heat ?v0 - object)
    (tiny_stories__story_097_active)
    (tiny_stories__story_097_type_character ?x - object)
    (tiny_stories__story_097_type_object ?x - object)
    (tiny_stories__story_097_p_sad ?v0 - object)
    (tiny_stories__story_097_p_ready ?v0 - object)
    (tiny_stories__story_097_p_practice ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_active)
    (writing_prompts__wp_017_type_animal ?x - object)
    (writing_prompts__wp_017_type_character ?x - object)
    (writing_prompts__wp_017_type_direction ?x - object)
    (writing_prompts__wp_017_type_object ?x - object)
    (writing_prompts__wp_017_p_wearing-pajamas ?v0 - object)
    (writing_prompts__wp_017_p_on-floor ?v0 - object)
    (writing_prompts__wp_017_p_dressed ?v0 - object)
    (writing_prompts__wp_017_p_holding ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_walking ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_petting ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_bites ?v0 - object)
    (writing_prompts__wp_017_p_owns ?v0 - object ?v1 - object)
    (writing_prompts__wp_017_p_life-is-a-joke ?v0 - object)
  )
  (:axiom :vars (?sun - object) :context (and (tiny_stories__story_091_active) (tiny_stories__story_091_type_sun ?sun) (and (not (tiny_stories__story_091_p_generous ?sun)) (tiny_stories__story_091_p_gives-heat ?sun))) :implies (tiny_stories__story_091_p_generous ?sun))

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
          (shared_p_consensus_3aebbe42b29c6cb8 ?proposer ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposee)
          (shared_p_consensus_3aebbe42b29c6cb8 ?proposee ?place)
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
          (shared_p_consensus_3aebbe42b29c6cb8 ?accepter ?place)
          (human_1fe4b2f08d46fd1e_p_alive ?proposer)
          (shared_p_consensus_3aebbe42b29c6cb8 ?proposer ?place)
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
          (shared_p_consensus_3aebbe42b29c6cb8 ?groom ?place)
          (human_1fe4b2f08d46fd1e_p_hasproposed ?groom ?bride)
          (human_1fe4b2f08d46fd1e_p_single ?groom)
          (human_1fe4b2f08d46fd1e_p_alive ?bride)
          (shared_p_consensus_3aebbe42b29c6cb8 ?bride ?place)
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
          (shared_p_consensus_57c71c7675e3190f ?groom)
        )
        (when
          (human_1fe4b2f08d46fd1e_p_loves ?bride ?groom)
          (shared_p_consensus_57c71c7675e3190f ?bride)
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
          (shared_p_consensus_3aebbe42b29c6cb8 ?thief ?place)
          (shared_p_consensus_3aebbe42b29c6cb8 ?item ?place)
          (human_1fe4b2f08d46fd1e_p_belongsto ?item ?victim)
        )
      )
    :effect
      (and
        (human_1fe4b2f08d46fd1e_p_has ?thief ?item)
        (when
          (shared_p_consensus_3aebbe42b29c6cb8 ?victim ?place)
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
          (shared_p_consensus_3aebbe42b29c6cb8 ?monster ?place)
          (human_1fe4b2f08d46fd1e_p_hungry ?monster)
          (human_1fe4b2f08d46fd1e_p_alive ?creature)
          (shared_p_consensus_3aebbe42b29c6cb8 ?creature ?place)
        )
      )
    :effect
      (and
        (not (human_1fe4b2f08d46fd1e_p_hungry ?monster))
        (not (human_1fe4b2f08d46fd1e_p_alive ?creature))
        (not (human_1fe4b2f08d46fd1e_p_rich ?creature))
        (not (shared_p_consensus_57c71c7675e3190f ?creature))
      )
    :agents (?monster)
  )

  (:action tiny_stories__story_048_a_play
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (shared_p_consensus_3aebbe42b29c6cb8 ?character ?place)
          (tiny_stories__story_048_p_dry ?place)
        )
      )
    :effect
      (shared_p_consensus_57c71c7675e3190f ?character)
    :agents (?character)
  )

  (:action tiny_stories__story_048_a_dry-place
    :parameters (?character - object ?place - object)
    :precondition
      (and
        (tiny_stories__story_048_active)
        (tiny_stories__story_048_type_character ?character)
        (tiny_stories__story_048_type_place ?place)
        (and
          (shared_p_consensus_3aebbe42b29c6cb8 ?character ?place)
          (tiny_stories__story_048_p_wet ?place)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_048_p_wet ?place))
        (tiny_stories__story_048_p_dry ?place)
      )
    :agents (?character)
  )

  (:action tiny_stories__story_091_a_wake-up
    :parameters (?sun - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_animal ?animal)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (not (shared_p_consensus_b43e64c129005afa ?animal))
        )
      )
    :effect
      (shared_p_consensus_b43e64c129005afa ?animal)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_make-happy
    :parameters (?sun - object ?animal - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_animal ?animal)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (shared_p_consensus_b43e64c129005afa ?animal)
          (not (shared_p_consensus_6ff15ab49cfb884c ?animal))
        )
      )
    :effect
      (shared_p_consensus_6ff15ab49cfb884c ?animal)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_help-grow
    :parameters (?sun - object ?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_sun ?sun)
        (tiny_stories__story_091_type_plant ?plant)
        (and
          (tiny_stories__story_091_p_generous ?sun)
          (tiny_stories__story_091_p_gives-heat ?sun)
          (not (tiny_stories__story_091_p_growing ?plant))
        )
      )
    :effect
      (tiny_stories__story_091_p_growing ?plant)
    :agents (?sun)
  )

  (:action tiny_stories__story_091_a_become-strong
    :parameters (?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_plant ?plant)
        (tiny_stories__story_091_p_growing ?plant)
      )
    :effect
      (tiny_stories__story_091_p_strong ?plant)
  )

  (:action tiny_stories__story_091_a_provide-shade-and-home
    :parameters (?plant - object)
    :precondition
      (and
        (tiny_stories__story_091_active)
        (tiny_stories__story_091_type_plant ?plant)
        (tiny_stories__story_091_p_strong ?plant)
      )
    :effect
      (and
        (tiny_stories__story_091_p_provides-shade ?plant)
        (tiny_stories__story_091_p_provides-home ?plant)
      )
  )

  (:action tiny_stories__story_097_a_cheer-up
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_784b4811611fee97 ?character1 ?character2)
          (tiny_stories__story_097_p_sad ?character2)
        )
      )
    :effect
      (and
        (not (tiny_stories__story_097_p_sad ?character2))
        (shared_p_consensus_6ff15ab49cfb884c ?character2)
      )
    :agents (?character1)
  )

  (:action tiny_stories__story_097_a_help-practice
    :parameters (?character1 - object ?character2 - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character1)
        (tiny_stories__story_097_type_character ?character2)
        (and
          (not (= ?character1 ?character2))
          (shared_p_consensus_784b4811611fee97 ?character1 ?character2)
          (not (tiny_stories__story_097_p_ready ?character2))
        )
      )
    :effect
      (tiny_stories__story_097_p_practice ?character1 ?character2)
    :agents (?character1 ?character2)
  )

  (:action tiny_stories__story_097_a_become-ready
    :parameters (?character - object)
    :precondition
      (and
        (tiny_stories__story_097_active)
        (tiny_stories__story_097_type_character ?character)
        (exists
          (?helper - object)
          (and
            (tiny_stories__story_097_type_character ?helper)
            (tiny_stories__story_097_p_practice ?helper ?character)
          )
        )
      )
    :effect
      (tiny_stories__story_097_p_ready ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_wake-up
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (not (shared_p_consensus_b43e64c129005afa ?character))
      )
    :effect
      (shared_p_consensus_b43e64c129005afa ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_dress
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (and
          (shared_p_consensus_b43e64c129005afa ?character)
          (writing_prompts__wp_017_p_on-floor ?character)
          (not (writing_prompts__wp_017_p_dressed ?character))
        )
      )
    :effect
      (writing_prompts__wp_017_p_dressed ?character)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_pet
    :parameters (?character - object ?animal - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (writing_prompts__wp_017_type_animal ?animal)
        (and
          (shared_p_consensus_b43e64c129005afa ?character)
          (writing_prompts__wp_017_p_dressed ?character)
          (not (writing_prompts__wp_017_p_bites ?animal))
        )
      )
    :effect
      (writing_prompts__wp_017_p_petting ?character ?animal)
    :agents (?character)
  )

  (:action writing_prompts__wp_017_a_realize-life-is-a-joke
    :parameters (?character - object)
    :precondition
      (and
        (writing_prompts__wp_017_active)
        (writing_prompts__wp_017_type_character ?character)
        (shared_p_consensus_b43e64c129005afa ?character)
      )
    :effect
      (writing_prompts__wp_017_p_life-is-a-joke ?character)
    :agents (?character)
  )

  (:action fused_a_consensus_60a883a6b3e21ec6
    :parameters (?m0 - object ?m1 - object)
    :precondition
      (or
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?m0)
          (tiny_stories__story_048_type_character ?m1)
          (and
            (not (= ?m0 ?m1))
            (shared_p_consensus_57c71c7675e3190f ?m0)
            (shared_p_consensus_57c71c7675e3190f ?m1)
          )
        )
        (and
          (tiny_stories__story_097_active)
          (tiny_stories__story_097_type_character ?m0)
          (tiny_stories__story_097_type_character ?m1)
          (not (= ?m0 ?m1))
        )
      )
    :effect
      (shared_p_consensus_784b4811611fee97 ?m0 ?m1)
    :agents (?m0 ?m1)
  )

  (:action fused_a_consensus_45b888c09d4f6753
    :parameters (?m0 - object ?m1 - object ?m2 - object)
    :precondition
      (or
        (and
          (human_1fe4b2f08d46fd1e_active)
          (human_1fe4b2f08d46fd1e_type_creature ?m0)
          (human_1fe4b2f08d46fd1e_type_place ?m1)
          (human_1fe4b2f08d46fd1e_type_place ?m2)
          (and
            (human_1fe4b2f08d46fd1e_p_alive ?m0)
            (shared_p_consensus_3aebbe42b29c6cb8 ?m0 ?m1)
          )
        )
        (and
          (tiny_stories__story_048_active)
          (tiny_stories__story_048_type_character ?m0)
          (tiny_stories__story_048_type_place ?m1)
          (tiny_stories__story_048_type_place ?m2)
          (and
            (not (= ?m1 ?m2))
            (shared_p_consensus_3aebbe42b29c6cb8 ?m0 ?m1)
          )
        )
      )
    :effect
      (and
        (shared_p_consensus_3aebbe42b29c6cb8 ?m0 ?m2)
        (not (shared_p_consensus_3aebbe42b29c6cb8 ?m0 ?m1))
      )
    :agents (?m0)
  )
)
