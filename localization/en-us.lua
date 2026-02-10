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
            b_Roland_go = {
                name = "Pass GO Deck",
                text = {
                    "Start with a {C:attention}Credit Card",
                    "Set money to {C:money}$0",
                    "when entering the shop",
                },
            },
        },
        BakeryCharm = {
            BakeryCharm_Roland_iphone = {
                name = "fat i phone",
                text = {
                    "Enter the shop",
                    "when any {C:attention}Blind",
                    "is {C:attention}skipped",
                },
            },
        },
        Blind = {
            bl_Roland_divide = {
                name = "The Great Divide",
                text = {"Half of the deck", "is discarded"},
            },
            bl_Roland_equinox = {
                name = "The Equinox",
                text = {"No UI"},
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
        },
        Enhanced = {
            m_wild = {
                name = "Wild Card",
                text = {"Can not be", "debuffed", unpack(G.localization.descriptions.Enhanced.m_wild.text)},
            },
        },
        Joker = {
            j_Roland_bulldozer = {
                name = "Bulldozer",
                text = {
                    "Give {X:red,C:white}XMult{} equal to",
                    "the current {C:attention}Blind Size{C:attention}",
                    "{C:inactive}(Currently {X:red,C:white}X#1#{C:inactive})",
                },
            },
            j_Roland_escapey = {
                name = "Escapey",
                text = {
                    "Use to {C:attention}destroy tags{} or {C:attention}unselected consumables",
                    "in exchange for {C:planet}leveling up #1# random hands",
                    "{C:inactive,s:0.75,E:1}#2#{C:red,s:1.5,E:1}#3#{s:0.9}#4#{C:blue,E:1,s:0.9}#5#{s:0.9}#6#",
                },
                merge = {"Since none apply, fuse with other ", " jokers"},
                quotes = {
                    marble = {"there is no escape..."},
                    normal = {
                        "I can't wait to work with you!",
                        "Did you need something from me?",
                        "Oh! I'm just so happy to see you!",
                        "Can I say something irrelevant? I promise it won't be long.",
                        "Tell me about your buddies! Assuming you have them, anyway.",
                    },
                    scared = {
                        "What am I going to do?!",
                        "I'm not scared, you are!",
                        "Tell me when this is over...",
                        "I can't keep looking at this!",
                        "Let me go hide in this corner... Okay?",
                    },
                },
            },
            j_Roland_estrogen = {
                name = "Estrogen",
                text = {"{C:mult}+(Chips/#1#){} Mult"},
            },
            j_Roland_hexagon = {
                name = "Hexagon",
                text = {
                    "Gains {C:money}$#1#{} of",
                    "{C:attention}sell value{} if",
                    "played hand is a",
                    "{C:attention}Four of a Kind",
                },
            },
            j_Roland_hexagoner = {
                name = "Hexagoner",
                text = {
                    "This Joker gains the",
                    "rank of {C:attention}unscored cards",
                    "to Mult if played hand",
                    "is a {C:attention}Four of a Kind",
                    "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)",
                },
            },
            j_Roland_hexagonest = {
                name = "Hexagonest",
                text = {
                    "{C:attention}Unscored cards{} add a",
                    "permanent copy to deck",
                    "if played hand is a",
                    "{C:attention}Four of a Kind",
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
            j_Roland_martingale = {
                name = "Martingale",
                text = {
                    "{C:green}#1# in #2#{} chance to give {X:mult,C:white}X#2#{} Mult",
                    "{s:0.9}Otherwise {C:green,s:0.9}#1# in #2#{s:0.9} chance to give {X:mult,C:white,s:0.9}X#3#{s:0.9} Mult",
                    "{s:0.81}Otherwise {C:green,s:0.81}#1# in #2#{s:0.81} chance to give {X:mult,C:white,s:0.81}X#4#{s:0.81} Mult",
                    "{s:0.6561}Otherwise {C:green,s:0.6561}#1# in #2#{s:0.6561} chance to give {X:mult,C:white,s:0.6561}X#5#{s:0.6561} Mult",
                    "{s:0.43046721}Otherwise {C:green,s:0.43046721}#1# in #2#{s:0.43046721} chance to give {X:mult,C:white,s:0.43046721}X#6#{s:0.43046721} Mult",
                    "{s:0.1853020188851841}Otherwise {C:green,s:0.1853020188851841}#1# in #2#{s:0.1853020188851841} chance to give {X:mult,C:white,s:0.1853020188851841}X#7#{s:0.1853020188851841} Mult",
                    "{s:0.0343368382029250877861747139}Otherwise {C:green,s:0.0343368382029250877861747139}#1# in #2#{s:0.0343368382029250877861747139} chance to give {X:mult,C:white,s:0.0343368382029250877861747139}X#8#{s:0.0343368382029250877861747139} Mult",
                    "{s:0}Otherwise {C:green,s:0}#1# in #2#{s:0} chance to give {X:mult,C:white,s:0}X#9#{s:0} Mult",
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
            j_Roland_oops = {
                name = "Oops! All 7s",
                text = {
                    "Listed {C:green,E:1}probabilities",
                    "{C:attention}increase{} for each",
                    "{C:hand}hand played this round",
                    "{C:inactive}(Currently {C:green}X#1#{C:inactive})",
                },
            },
            j_Roland_rigged = {
                name = "Rigged",
                text = {
                    "{C:blue}#1#{}#2#{C:green}#3#{}#4#{C:red}#5#{}#6#{C:edition}#7#{}#8#{C:legendary}#9#{}#10#{C:dark_edition}#11#",
                    "jokers cannot appear",
                    "{C:attention}Upgrade{} this card by",
                    "obtaining another {C:attention}Rigged",
                },
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
                    "{C:attention}Unscored {C:enhanced}wild{} cards",
                    "give {X:red,C:white}X#1#{} Mult",
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
                    "Creates a random {C:attention}Tag",
                    "at the end of the {C:attention}Ante",
                    "{C:red,E:1}Self destructs{} if {C:attention}drawn",
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
                    "{C:dark_edition}({X:dark_edition,C:white}ante{} {X:dark_edition,C:white}number{C:dark_edition}) times",
                    "{C:inactive}(Instead of #1#)",
                },
            },
            sleeve_Roland_go = {
                name = "Pass GO Sleeve",
                text = {
                    "Start with a {C:attention}Credit Card",
                    "Set money to {C:money}$0",
                    "when entering the shop",
                },
            },
            sleeve_Roland_go_alt = {
                name = "Free Parking Sleeve",
                text = {
                    "Start with an additional",
                    "{X:attention,C:white}#1#{C:attention} Credit Cards",
                },
            },
        },
        Spectral = {
            c_Roland_afterimage = {
                name = "Afterimage",
                text = {
                    "Add {C:dark_edition}Negative {}to {C:attention}#1#",
                    "selected card in hand",
                    "{C:red}#2#{} hand size",
                },
            },
            c_Roland_dual = {
                name = "Dual",
                text = {
                    "Add random seals",
                    "to {C:attention}#1#{} random",
                    "cards in {C:hands}hand",
                },
            },
            c_Roland_mirror = {
                name = "Mirror",
                text = {
                    "Add a {C:dark_edition}Glass Tag",
                    "to {C:attention}#1#{} selected",
                    "card in {C:hands}hand",
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
    },
    misc = {
        challenge_names = {
            c_Roland_Jokerful = "Jokerful",
            c_Roland_Pastries = "Sweet Pastries",
        },
        v_dictionary = {
            b_Roland_comma = ", ",
            b_Roland_of = " of ",
            b_Roland_most_common_card = "(Rank)",
            b_Roland_na = "N/A",
        },
        labels = {
            roland_glass_seal = "Glass Seal",
        },
        v_text = {
            ch_c_Roland_Jokerful = {"Only the {C:common}default Joker{} can appear in shops"},
            ch_c_Roland_Pastries = {"All blinds, cards, and tags are of {C:gold}Bakery{} or {C:blue}Roland"},
        },
    },
}
