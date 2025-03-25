local jokerful = {banned_cards = {}}
local balanced_jokers = {banned_cards = {}}

SMODS.Challenge {
    key = "Jokerful",
    rules = {custom = {{id = "Roland_Jokerful"}}},
    restrictions = jokerful
}

local deck = {}
local card = {eternal = true, cry_absolute = true}

SMODS.Challenge {
    key = "Ascension",
    deck = deck,
    jokers = {card},
    rules = {custom = {{id = "Roland_Saint"}, {id = "Roland_Accelerated"}}},
}

SMODS.Challenge {
    key = "Soaring",
    deck = deck,
    jokers = {card},
    sleeve = "sleeve_cry_equilibrium_sleeve",
    rules = {custom = {{id = "Roland_Saint"}, {id = "Roland_Accelerated"}}},
}

SMODS.Challenge {
    key = "Balanced_Jokers",
    restrictions = balanced_jokers,
    rules = {custom = {{id = "Roland_Balanced_Jokers"}}},
}

G.E_MANAGER:add_event(Event {
    trigger = "immediate",
    func = function()
        if Jen or Jane then
            deck.type = Jen and "b_jen_nitro" or "b_jane_nitro"
            card.id = Jen and "j_jen_saint" or "j_jane_saint"
        end

        F.foreach(
            F.filter(
                G.P_CENTERS,
                function (v) return v.set == "Joker" end
            ),
            function (v) table.insert(jokerful.banned_cards, {id = v.key}) end
        )

        F.foreach(
            F.filter(
                jokerful.banned_cards,
                function (v) return v.id:sub(1, 6) == "j_cry_" or v.id:sub(1, 6) == "j_jen_" end
            ),
            function (v) table.insert(balanced_jokers.banned_cards, {id = v.key}) end
        )

        return true
    end
})
