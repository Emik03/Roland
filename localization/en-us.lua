return {
    descriptions = {
        Back = {
            b_Roland_blossom = {
                name = "Blossom Deck",
                text = {
                    "{C:attention}Small{} and {C:attention}Big Blinds{} are",
                    "replaced with {C:attention}Boss Blinds",
                    "that are {C:dark_edition}debuffed #1# times",
                },
            },
            b_Roland_swapper = {
                name = "Swapper Deck",
                text = {
                    "{C:tarot}Tarot {}and {C:spectral}Spectral",
                    "cards swap places",
                },
            },
        },
        BakeryCharm = {
            BakeryCharm_Roland_cocacola = {
                name = "coca cola phone",
                text = {
                    "{C:attention}Discard 0 cards {}to",
                    "gain {C:red}#1# {}discards and",
                    "lose {C:attention}#2# {}hand size",
                    "this round",
                },
            },
            BakeryCharm_Roland_fat = {
                name = "fat i phone",
                text = {
                    "{C:attention}+#1# Booster Pack {}slots",
                    "All {C:attention}Booster Packs {}are {C:attention}Mega",
                    "{C:inactive}(Whenever applicable)",
                },
            },
            BakeryCharm_Roland_flexible = {
                name = "flexi ble phone",
                text = {unpack(G.localization.descriptions.Joker.j_ring_master.text)},
            },
            BakeryCharm_Roland_hand = {
                name = "hand phone",
                text = {"{C:attention}+#1# {}hand size", "{C:blue}#2# {}hands"},
            },
            BakeryCharm_Roland_wii = {
                name = "wii phone",
                text = {
                    "Enter the shop",
                    "when any {C:attention}Blind",
                    "is {C:attention}skipped",
                },
            },
        },
        Blind = {
            bl_Roland_blizzard = {
                name = "The Blizzard",
                text = {"All cards", "are Frozen"},
            },
            bl_Roland_divide = {
                name = "The Great Divide",
                text = {"Half of the deck", "is discarded"},
            },
            bl_Roland_equinox = {
                name = "The Equinox",
                text = {"No UI"},
            },
            bl_Roland_falseshuffle = {
                name = "The False Shuffle",
                text = {"Enhanced cards", "are drawn last"},
            },
            bl_Roland_improbable = {
                name = "The Improbable",
                text = {"All probabilities", "cannot happen"},
            },
            bl_Roland_mitotic = {
                name = "The Mitotic",
                text = {"Discarded cards", "are copied"},
            },
            bl_Roland_nimble = {
                name = "The Nimble",
                text = {"The first 5 cards", "drawn are played"},
            },
            bl_Roland_tranquilizer = {
                name = "The Tranquilizer",
                text = {"#1#s are debuffed", "Changes based on", "most common rank"},
            },
            bl_Roland_venerable_visage = {
                name = "Venerable Visage",
                text = {"Infinite discards", "Lose if any card was", "not played or discarded"},
                fail = {
                    "Blasphemy.",
                    "Blunder.",
                    "Crisis.",
                    "Denied.",
                    "Failure.",
                    "Fall.",
                    "Foolish.",
                    "Illiterate.",
                    "Judgement.",
                    "Mistake.",
                    "Perish.",
                    "Pity.",
                    "Unfortunate.",
                    "Weak.",
                },
            },
        },
        Edition = {
            e_Roland_frozen = {
                name = "Frozen",
                text = {"Values on", "this card do", "not change"},
            },
        },
        Enhanced = {
            m_wild = {
                name = "Wild Card",
                text = {"Can be used", "as any suit", "Can not be", "debuffed"},
            },
        },
        Joker = {
            j_Roland_amber = {
                name = "Amber Acorn",
                text = {"{X:mult,C:white}X#1#{} Mult", "Moves before", "hand is played"},
            },
            j_Roland_arctic = {
                name = "Arctic Circle",
                text = {"Retrigger {C:dark_edition}Frozen {}cards", "Retrigger playing cards"},
            },
            j_Roland_artemis = {
                name = "Artemis X",
                text = {
                    "Earn {C:money}$#1# {}at end of round",
                    "Payout increases by {C:money}$#2#",
                    "when these {C:planet}Planet {}cards",
                    "are used in order:",
                    "{V:1}Earth{C:inactive} - {V:2}Mars{C:inactive} - {V:3}Earth",
                },
            },
            j_Roland_basket = {
                name = "Basket",
                text = {
                    "Sell this Joker to",
                    "create {C:dark_edition}Negative {}copies",
                    "of every consumable",
                },
            },
            j_Roland_bulldozer = {
                name = "Bulldozer",
                text = {
                    "Give {X:red,C:white}XMult{} equal to",
                    "the current {C:attention}Blind Size{C:attention}",
                    "{C:inactive}(Currently {X:red,C:white}X#1#{C:inactive})",
                },
            },
            j_Roland_cold = {
                name = "Cold Turkey",
                text = {
                    "Third scored card",
                    "gives {X:red,C:white}X#1#{} Mult",
                    "if it is {C:dark_edition}Frozen",
                },
            },
            j_Roland_domino = {
                name = "Domino",
                text = {
                    "This Joker gains {C:mult}+#1# {}Mult",
                    "if played hand is a",
                    "{C:attention}#2#",
                    "{C:inactive}(Currently {C:red}+#3#{C:inactive} Mult)",
                },
            },
            j_Roland_hardboiled = {
                name = "Hard-Boiled",
                text = {
                    "Sell this Joker to",
                    "turn all cards in",
                    "hand {C:dark_edition}Frozen",
                },
            },
            j_Roland_idle = {
                name = "The Idle",
                text = {
                    "Use to add card's",
                    "rank and suit",
                    "First {C:attention}scoring {}card",
                    "of each entry",
                    "gives {X:mult,C:white}X#19#{} Mult",
                    "{C:inactive}(Must be distinct)",
                    "{V:1,s:0.75}#1#{C:inactive,s:0.75}#2#{V:2,s:0.75}#3#{C:inactive,s:0.75}, " ..
                    "{V:3,s:0.75}#4#{C:inactive,s:0.75}#5#{V:4,s:0.75}#6#{C:inactive,s:0.75}",
                    "{V:5,s:0.75}#7#{C:inactive,s:0.75}#8#{V:6,s:0.75}#9#, " ..
                    "{V:7,s:0.75}#10#{C:inactive,s:0.75}#11#{V:8,s:0.75}#12#{C:inactive,s:0.75}",
                    "{V:9,s:0.75}#13#{C:inactive,s:0.75}#14#{V:10,s:0.75}#15#{C:inactive,s:0.75}, " ..
                    "{V:11,s:0.75}#16#{C:inactive,s:0.75}#17#{V:12,s:0.75}#18#",
                },
            },
            j_Roland_jokersr = {
                name = "Joker Sr.",
                text = {"{X:mult,C:white}X#1#{} Mult"},
            },
            j_Roland_martingale = {
                name = "Martingale",
                text = {
                    "{C:green}#1# in #3#{} chance to give {X:mult,C:white}X#2#{} Mult",
                    "{s:0.9}Otherwise, {C:green,s:0.9}#1# in #3#{s:0.9} chance to give {X:mult,C:white,s:0.9}X#3#{s:0.9} Mult",
                    "{s:0.81}Otherwise, {C:green,s:0.81}#1# in #3#{s:0.81} chance to give {X:mult,C:white,s:0.81}X#4#{s:0.81} Mult",
                    "{s:0.6561}Otherwise, {C:green,s:0.6561}#1# in #3#{s:0.6561} chance to give {X:mult,C:white,s:0.6561}X#5#{s:0.6561} Mult",
                    "{s:0.43046721}Otherwise, {C:green,s:0.43046721}#1# in #3#{s:0.43046721} chance to give {X:mult,C:white,s:0.43046721}X#6#{s:0.43046721} Mult",
                    "{s:0.1853020188851841}Otherwise, {C:green,s:0.1853020188851841}#1# in #3#{s:0.1853020188851841} chance to give {X:mult,C:white,s:0.1853020188851841}X#7#{s:0.1853020188851841} Mult",
                    "{s:0.0343368382029250877861747139}Otherwise, {C:green,s:0.0343368382029250877861747139}#1# in #3#{s:0.0343368382029250877861747139} chance to give {X:mult,C:white,s:0.0343368382029250877861747139}X#8#{s:0.0343368382029250877861747139} Mult",
                    "{s:0}Otherwise, {C:green,s:0}#1# in #3#{s:0} chance to give {X:mult,C:white,s:0}X#9#{s:0} Mult",
                },
            },
            j_Roland_misfortune = {
                name = "Misfortune Cookie",
                text = {
                    "{C:tarot}Tarot{} cards created",
                    "by {C:tarot}Purple Seals",
                    "become {C:dark_edition}Negative",
                },
            },
            j_Roland_monomino = {
                name = "Monomino",
                text = {
                    "Gains {C:money}$#1#{} of",
                    "{C:attention}sell value{} if",
                    "played hand is a",
                    "{C:attention}#2#",
                },
            },
            j_Roland_mrsbones = {
                name = "Mrs. Bones",
                text = {
                    "{X:red,C:white}X#1#{} Mult",
                    "{C:red,E:1}Self destructs{} if {C:chips}chips",
                    "scored at the end of",
                    "the {C:attention}Blind{} are less than",
                    "{C:attention}#2#%{} of required {C:chips}chips",
                },
            },
            j_Roland_msjoker = {
                name = "Ms. Joker",
                text = {"{C:chips}+#1#{} Chips"},
            },
            j_Roland_nilly = {
                name = "Nilly",
                text = {
                    "Toggleable {X:mult,C:white}X0{} Mult",
                    "{C:inactive}(Currently {C:attention}#1#{C:inactive})",
                    "{C:inactive,s:0.75,E:1}Wait... what?",
                },
            },
            j_Roland_oops = {
                name = "Oops! All 7s",
                text = {
                    "{X:green,C:white}X#1#{C:green,E:1} probability {}after every",
                    "{C:blue}hand {}played this round",
                    "{C:inactive}(Currently {X:green,C:white}X#2#{C:inactive})",
                },
            },
            j_Roland_phytoestrogens = {
                name = "Phytoestrogens",
                text = {"{C:mult}+Chips{} Mult", "{X:mult,C:white}X#1#{} Mult"},
            },
            j_Roland_sapling = {
                name = "Sapling",
                text = {
                    "{C:mult}+#1# {}Mult if",
                    "scoring hand",
                    "contains at",
                    "least {C:attention}#2# suits",
                },
            },
            j_Roland_snowsquall = {
                name = "Snowsquall",
                text = {
                    "This Joker gains",
                    "{C:mult}+#1# {}Mult for every",
                    "played {C:dark_edition}Frozen {}card",
                    "{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)",
                },
            },
            j_Roland_suitable = {
                name = "Suitable",
                text = {"{V:1}#1# {}are {C:attention}Wild", "Suit changes", "every round"},
            },
            j_Roland_sunny = {
                name = "Sunny Side Up",
                text = {
                    "Sell this Joker to",
                    "{C:attention}draw{} the bottom",
                    "card of the {C:hand}deck",
                    "{C:inactive}(Currently {V:1}#1#{C:inactive}#2#{V:2}#3#{C:inactive})",
                },
            },
            j_Roland_temple = {
                name = "Temple",
                text = {
                    "{C:attention}Unscored Wild{} cards",
                    "give {X:red,C:white}X#1#{} Mult",
                },
            },
            j_Roland_trimino = {
                name = "Trimino",
                text = {
                    "Copies {C:attention}#1# {C:green}random",
                    "scoring cards and",
                    "{C:red,E:1}self-destructs {}if",
                    "played hand is a",
                    "{C:attention}#2#",
                },
            },
            j_Roland_yard = {
                name = "Yard Sale",
                text = {
                    "Gain {C:money}$#1#{} when a",
                    "card is {C:attention}removed",
                    "from the deck",
                },
            },
        },
        Other = {
            roland_glass_seal = {
                name = "Glass Seal",
                text = {
                    "{C:red,E:1}Shatters {}and creates",
                    "a random {C:attention}Tag {}if",
                    "drawn during a {C:attention}Blind",
                },
            },
        },
        Sleeve = {
            sleeve_Roland_blossom = {
                name = "Blossom Sleeve",
                text = {
                    "{C:attention}Small{} and {C:attention}Big Blinds{} are",
                    "replaced with {C:attention}Boss Blinds",
                    "that are {C:dark_edition}debuffed #1# times",
                },
            },
            sleeve_Roland_blossom_alt = {
                name = "Efflorescent Sleeve",
                text = {
                    "{C:attention}Blinds{} are {C:dark_edition}debuffed",
                    "{C:dark_edition}({X:dark_edition,C:white}(ante * #2#){C:dark_edition}) times",
                    "{C:inactive}(Instead of #1#)",
                },
            },
            sleeve_Roland_swapper = {
                name = "Swapper Sleeve",
                text = {
                    "{C:tarot}Tarot {}and {C:spectral}Spectral",
                    "cards swap places",
                },
            },
            sleeve_Roland_swapper_alt = {
                name = "Sleeve Swapper",
                text = {
                    "{C:attention}All {}consumable",
                    "types swap places",
                },
            },
        },
        Spectral = {
            c_Roland_afterimage = {
                name = "Afterimage",
                text = {
                    "Add random seals",
                    "to {C:attention}#1#{} random",
                    "cards in {C:hands}hand",
                },
            },
            c_Roland_primal = {
                name = "Primal Force",
                text = {
                    "Enhance {C:attention}all {}cards",
                    "held in hand to",
                    "{C:enhanced}Stone Cards",
                },
            },
            c_Roland_refract = {
                name = "Refract",
                text = {
                    "Add a {C:dark_edition}Glass Seal",
                    "to {C:attention}#1#{} selected",
                    "cards in {C:hands}hand",
                },
            },
            c_Roland_void = {
                name = "Void",
                text = {
                    "{C:red}Destroys {X:red,C:white}all{} owned",
                    "playing cards {}for",
                    "{C:attention}#1# {C:dark_edition}Negative {C:spectral}Cryptids",
                },
            },
        },
        Tag = {
            tag_Roland_freeze = {
                name = "Freeze Tag",
                text = {"Apply {C:dark_edition}Frozen", "to the next {C:attention}#1#", "scored cards"},
            },
            tag_Roland_invisible = {
                name = "Invisible Tag",
                text = {
                    "{C:attention}Duplicate {}a random",
                    "Joker after {C:attention}#1#{} rounds",
                    "{C:inactive}(Must have room)",
                    "{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)",
                },
            },
        },
        Tarot = {
            c_Roland_coolheaded = {
                name = "Coolheaded",
                text = {
                    "Add {C:dark_edition}Frozen {}to {C:attention}#1#",
                    "selected {C:attention}playing",
                    "{C:attention}card {}or {C:attention}Joker",
                },
            },
        },
    },
    misc = {
        challenge_names = {
            c_Roland_Eternally_Amber = "Eternally Amber",
            c_Roland_Eternally_Cerulean = "Eternally Cerulean",
            c_Roland_Eternally_Crimson = "Eternally Crimson",
            c_Roland_Eternally_Verdant = "Eternally Verdant",
            c_Roland_Eternally_Violet = "Eternally Violet",
            c_Roland_Go = "Pass GO",
            c_Roland_Jokerful = "Jokerful",
            c_Roland_Pastries = "Sweet Pastries",
            c_Roland_Spin_To_Win = "Spin to Win",
        },
        v_dictionary = {
            b_Roland_add = "ADD",
            b_Roland_bye = "Bye!",
            b_Roland_comma = ", ",
            b_Roland_debuffed = "DEBUFFED",
            b_Roland_disabled = "Disabled",
            b_Roland_enabled = "Enabled",
            b_Roland_entering_shop = "Entering shop!",
            b_Roland_equinox_assist = "Assist: Only hide text (Equinox)",
            b_Roland_faster_planets = "Faster Planets",
            b_Roland_full = "FULL",
            b_Roland_scribable_basket = "Scribable Basket (overpowered)",
            b_Roland_harsh_ante_scaling = "Harsh ante scaling (Ante 40+)",
            b_Roland_illusion_seal = "Allow seals from Illusion voucher",
            b_Roland_import_funky = "Debug: Import funky.lua",
            b_Roland_most_common_card = "(Rank)",
            b_Roland_no_wild_debuff = "No wild card debuffs",
            b_Roland_na = "N/A",
            b_Roland_of = " of ",
            b_Roland_toggle = "TOGGLE",
            b_Roland_unassigned = "(Unassigned)",
        },
        labels = {
            Roland_frozen = "Frozen",
            roland_glass_seal = "Glass Seal",
        },
        v_text = {
            ch_c_Roland_Eternally_Amber = {"{C:attention}Amber Acorn{}'s effect is active every blind"},
            ch_c_Roland_Eternally_Cerulean = {"{C:attention}Cerulean Bell{}'s effect is active every blind"},
            ch_c_Roland_Eternally_Crimson = {"{C:attention}Crimson Heart{}'s effect is active every blind"},
            ch_c_Roland_Eternally_Verdant = {"{C:attention}Verdant Leaf{}'s effect is active every blind"},
            ch_c_Roland_Eternally_Violet = {"{C:attention}Violet Vessel{}'s effect is active every blind"},
            ch_c_Roland_Go = {"Set money to {C:money}$0 {}when entering the shop"},
            ch_c_Roland_Jokerful = {"The only jokers are {C:mult}Joker{} and {C:chips}Ms. Joker"},
            ch_c_Roland_Pastries = {"All blinds, cards, and tags are of {C:gold}Bakery{} or {C:blue}Roland"},
            ch_c_Roland_Showdown_Amber = {"Showdown blinds are {C:attention}Amber Acorn {}(stacks with above)"},
            ch_c_Roland_Showdown_Cerulean = {"Showdown blinds are {C:attention}Cerulean Bell {}(stacks with above)"},
            ch_c_Roland_Showdown_Crimson = {"Showdown blinds are {C:attention}Crimson Heart {}(stacks with above)"},
            ch_c_Roland_Showdown_Verdant = {"Showdown blinds are {C:attention}Verdant Leaf {}(stacks with above)"},
            ch_c_Roland_Showdown_Violet = {"Showdown blinds are {C:attention}Violet Vessel {}(stacks with above)"},
        },
    },
}
