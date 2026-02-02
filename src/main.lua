local qol = assert(SMODS.load_file "src/functional.lua")() or require "src.functional"

qol[1] {"challenge", "spectral", "blind", "charm", "joker", "back", "seal"}:foreach(function(v)
    assert(SMODS.load_file("src/" .. v .. ".lua"))(qol)
end)

if Balatest then
    qol[1] {"joker", "blind", "spectral"}:foreach(function(v)
        assert(SMODS.load_file("src/tests/" .. v .. ".tests.lua"))(qol)
    end)
end

SMODS.Joker:take_ownership("joker", {cost = 1}, true)

SMODS.Atlas {
    px = 256,
    py = 256,
    key = "modicon",
    path = "icon.png",
}

SMODS.current_mod.optional_features = function()
    return {cardareas = {deck = true, unscored = true}}
end
