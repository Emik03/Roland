local jokerful = {banned_cards = {}}
local pastries = {banned_cards = {}, banned_tags = {}, banned_other = {}}

local function adder(tbl)
    return function(v)
        table.insert(tbl, {id = v.key})
    end
end

local function is_banned_from_pastry(_, k)
    return not k:find("_Bakery_") and not k:find("_Roland_")
end

local function is_center_banned_from_pastry(v, k)
    local pastries_targets = {Enhanced = true, Joker = true, Tarot = true, Spectral = true}
    return pastries_targets[v.set] and is_banned_from_pastry(v, k)
end

local function is_joker(v)
    return v.set == "Joker"
end

SMODS.Challenge {
    key = "Jokerful",
    rules = {custom = {{id = "Roland_Jokerful"}}},
    restrictions = jokerful,
    pronouns = "he_him",
}

SMODS.Challenge {
    key = "Pastries",
    rules = {custom = {{id = "Roland_Pastries"}}},
    restrictions = pastries,
    pronouns = "she_them",
}

G.E_MANAGER:add_event(Event {
    trigger = "immediate",
    func = function()
        F.foreach(F.filter(G.P_CENTERS, is_joker), adder(jokerful.banned_cards))
        F.foreach(F.filter(G.P_TAGS, is_banned_from_pastry), adder(pastries.banned_tags))
        F.foreach(F.filter(G.P_BLINDS, is_banned_from_pastry), adder(pastries.banned_other))
        F.foreach(F.filter(G.P_CENTERS, is_center_banned_from_pastry), adder(pastries.banned_cards))
        return true
    end,
})
