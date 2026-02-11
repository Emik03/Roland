local qol = assert(SMODS.load_file "src/functional.lua")() or require "src.functional"

qol[1] {"challenge", "spectral", "tweaks", "blind", "charm", "joker", "back", "seal"}:foreach(function(v)
    assert(SMODS.load_file("src/" .. v .. ".lua"))(qol)
end)

if Balatest then
    qol[1] {"joker", "blind", "spectral"}:foreach(function(v)
        assert(SMODS.load_file("src/tests/" .. v .. ".tests.lua"))(qol)
    end)
end

SMODS.Atlas {
    px = 256,
    py = 256,
    key = "modicon",
    path = "icon.png",
}

SMODS.current_mod.optional_features = function()
    return {cardareas = {deck = true, unscored = true}}
end

SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {r = 0.1, minw = 8, minh = 6, align = "tl", padding = 0.2, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tl", colour = G.C.CLEAR, padding = 0.15},
            nodes = {create_toggle({
                label = "Assist: Only hide text during Equinox Blind",
                ref_table = SMODS.Mods.Roland.config,
                ref_value = "equinox_assist",
            })},
        }},
    }
end
