local f, q = unpack(... or require "lib.shared")

local function bans()
    return {banned_cards = {}, banned_tags = {}, banned_other = {}}
end

local jokerful, pastries, vanillas = bans(), bans(), bans()
-- local surgery = bans()
local function adder(tbl)
    return function(v)
        table.insert(tbl, {id = v.key})
    end
end

local function is_banned_from_pastry(_, k)
    return not k:find "_Bakery_" and not k:find "_Roland_"
end

-- local function is_blind_banned_from_surgery(v, k)
--     return k ~= "bl_Roland_tranquilizer" and not (v.boss or {}).showdown
-- end
local function is_center_banned_from_pastry(v, k)
    local pastries_targets = {Enhanced = true, Joker = true, Tarot = true, Spectral = true}
    return pastries_targets[v.set] and is_banned_from_pastry(v, k)
end

local function is_joker(v)
    return v.set == "Joker"
end

local function is_vanilla(v)
    return v.set and not v.mod and f(G.P_CENTERS):concat(G.P_CARDS, G.P_TAGS):any(function(c)
        return c.mod and not c.in_pool and c.set == v.set
    end)
end

SMODS.Challenge {
    key = "Jokerful",
    rules = {custom = {{id = "Roland_Jokerful"}}},
    restrictions = jokerful,
    pronouns = "he_him",
}

SMODS.Challenge {
    key = "Ornate",
    rules = {custom = {{id = "Roland_Ornate"}}},
    restrictions = vanillas,
    pronouns = "any_all",
}

SMODS.Challenge {
    key = "Pastries",
    rules = {custom = {{id = "Roland_Pastries"}}},
    restrictions = pastries,
    pronouns = "she_them",
}

-- SMODS.Challenge {
--     key = "Surgery",
--     rules = {custom = {{id = "Roland_Oops_All_Tranquilizers"}, {id = "Roland_Linked_Rank"}}},
--     restrictions = surgery,
--     pronouns = "she_them",
--     calculate = function()
--         f(G.playing_cards):skip(1):take(5):foreach(function(v)
--             ---@type Card
--             v = v
--             v.config.center = G.playing_cards[1].config.center
--         end)
--     end,
-- }
q(function()
    f {
        {G.P_CENTERS, is_joker,                     jokerful.banned_cards},
        {G.P_TAGS,    is_vanilla,                   vanillas.banned_tags},
        {G.P_BLINDS,  is_vanilla,                   vanillas.banned_other},
        {G.P_CENTERS, is_vanilla,                   vanillas.banned_cards},
        {G.P_TAGS,    is_banned_from_pastry,        pastries.banned_tags},
        {G.P_BLINDS,  is_banned_from_pastry,        pastries.banned_other},
        {G.P_CENTERS, is_center_banned_from_pastry, pastries.banned_cards},
        -- {G.P_BLINDS,  is_blind_banned_from_surgery, surgery.banned_other},
    }:each(function(v)
        f(v[1]):where(v[2]):each(adder(v[3]))
    end)
end)
