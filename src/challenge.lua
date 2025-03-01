local jokerful = {banned_cards = {}}
local balanced_jokers = {banned_cards = {}}

SMODS.Challenge {
    key = "Jokerful",
    rules = {custom = {{id = "Roland_Jokerful"}}},
    restrictions = jokerful
}

if Jen then
    SMODS.Challenge {
        key = "Ascension",
        deck = {type = "b_jen_nitro"},
        rules = {custom = {{id = "Roland_Saint"}, {id = "Roland_Accelerated"}}},
        jokers = {{id = "j_jen_saint", eternal = true}},
    }

    SMODS.Challenge {
        key = "Soaring",
        deck = {type = "b_jen_nitro"},
        sleeve = "sleeve_cry_equilibrium_sleeve",
        rules = {custom = {{id = "Roland_Saint"}, {id = "Roland_Accelerated"}}},
        jokers = {{id = "j_jen_saint", eternal = true}},
    }

    SMODS.Challenge {
        key = "Balanced_Jokers",
        rules = {custom = {{id = "Roland_Balanced_Jokers"}}},
        restrictions = balanced_jokers
    }
end

G.E_MANAGER:add_event(Event {
    trigger = "immediate",
    func = function()
        jokerful.banned_cards = F.map(
            F.filter(
                G.P_CENTERS,
                function (v) return v.set == "Joker" end
            ),
            function (v) return { id = v.key } end
        )

        balanced_jokers.banned_cards = F.filter(
            jokerful.banned_cards,
            function (v) return v.id:sub(1, 6) == "j_cry_" or v.id:sub(1, 6) == "j_jen_" end
        )

        return true
    end
})
