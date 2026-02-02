local f, q = unpack(... or require "src.functional")
local jokerful = {banned_cards = {}}
local pastries = {banned_cards = {}, banned_tags = {}, banned_other = {}}

local function adder(tbl)
    return function(v)
        table.insert(tbl, {id = v.key})
    end
end

local function is_banned_from_pastry(_, k)
    return not k:find "_Bakery_" and not k:find "_Roland_"
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

q(function()
    f {
        {G.P_CENTERS, is_joker,                     jokerful.banned_cards},
        {G.P_TAGS,    is_banned_from_pastry,        pastries.banned_tags},
        {G.P_BLINDS,  is_banned_from_pastry,        pastries.banned_other},
        {G.P_CENTERS, is_center_banned_from_pastry, pastries.banned_cards},
    }:foreach(function(v)
        f(v[1]):filter(v[2]):foreach(adder(v[3]))
    end)
end)
