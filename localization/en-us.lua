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
                name = "placeholder",
                text = {"grr"},
            },
        },
        Blind = {
            bl_Roland_divide = {
                name = "The Great Divide",
                text = {"Half of the deck", "is {C:discard}discarded"},
            },
            bl_Roland_improbable = {
                name = "The Improbable",
                text = {"All probabilities", "cannot happen"},
            },
            bl_Roland_nimble = {
                name = "The Nimble",
                text = {"The first 5 cards", "drawn are played"},
            },
            bl_Roland_tranquilizer = {
                name = "The Tranquilizer",
                text = {"#1#s are debuffed", "Changes based on", "most common rank"},
            },
            bl_Roland_xerox = {
                name = "The Xerox",
                text = {"Discarded cards", "are copied"},
            },
        },
        Joker = {
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
            b_Roland_most_common_card = "(Rank)",
        },
        v_text = {
            ch_c_Roland_Jokerful = {"Only the {C:common}default Joker{} can appear in shops"},
            ch_c_Roland_Pastries = {"All blinds, cards, and tags are of {C:gold}Bakery{} or {C:blue}Roland"},
        },
    },
}
