return {
    descriptions = {
        Joker = {
            j_Roland_escapey = {
                name = "Escapey",
                text = {
                    "Destroy {C:attention}tags{} and {C:attention}non-selected",
                    "{C:attention}consumables{} on use. Level up",
                    "the {C:planet}most played hand{} by {C:planet}#1#{}",
                    "for each destroyed object",
                    "{C:inactive}(Currently #2#)",
                    " ",
                    "#3#{C:inactive,s:0.75,E:1}#4#{C:red,s:1.5,E:1}#5#",
                    "#6#{C:blue,E:1}#7#{}#8#{C:inactive,s:0.75,E:1}#9#{C:red,s:1.5,E:1}#10#",
                },
                merge = {"Since no objects apply, merge", "with other ", " jokers"},
                quotes = {
                    marble = {{"there is no escape..."}},
                    normal = {
                        {"I can't wait to", "work with you!"},
                        {"Did you need something", "from me?"},
                        {"Oh! I'm just so", "happy to see you!"},
                        {"Can I talk about something irrelevant?", "I promise it won't be long."},
                        {"Can you introduce me to your friends?", "Assuming you have friends of course!"},
                    },
                    scared = {
                        {"What am I", "going to do?!"},
                        {"I'm not scared,", "you are!"},
                        {"Tell me when", "this is over..."},
                        {"I can't keep", "looking at this!"},
                        {"Let me go hide in", "this corner... Okay?"},
                    },
                },
            }
        },
        Spectral = {
            c_Roland_void = {
                name = "Void",
                text = {
                    "{C:red}Destroys {X:red,C:white}all{} owned",
                    "{C:attention}playing cards",
                }
            }
        }
    },
    misc = {
        challenge_names = {
            c_Roland_Soaring = "Soaring",
            c_Roland_Jokerful = "Jokerful",
            c_Roland_Ascension = "Ascension",
            c_Roland_Balanced_Jokers = "Balanced Jokers",
        },
        v_text = {
            ch_c_Roland_Accelerated = {"Start with {C:blue}Accelerated Deck"},
            ch_c_Roland_Saint = {"Start with an {C:attention}Eternal {C:legendary}Saint"},
            ch_c_Roland_Jokerful = {"Only the {C:common}default Joker{} can appear in shops"},
            ch_c_Roland_Balanced_Jokers = {"All Cryptid and Jen's jokers {C:attention}cannot appear"},
        }
    }
}
