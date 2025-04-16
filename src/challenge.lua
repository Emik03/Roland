local jokerful = {banned_cards = {}}

SMODS.Challenge {
    key = "Jokerful",
    rules = {custom = {{id = "Roland_Jokerful"}}},
    restrictions = jokerful,
}

G.E_MANAGER:add_event(Event {
    trigger = "immediate",
    func = function()
        F.foreach(
            F.filter(
                G.P_CENTERS,
                function(v) return v.set == "Joker" end
            ),
            function(v) table.insert(jokerful.banned_cards, {id = v.key}) end
        )

        return true
    end,
})
