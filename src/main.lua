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
        config = {r = 0.1, minw = 4, minh = 4, align = "tr", padding = 0.2, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tr", padding = 0.2, colour = G.C.CLEAR},
            nodes = {
                create_toggle {
                    label = localize {type = "variable", key = "b_Roland_equinox_assist"},
                    ref_table = SMODS.Mods.Roland.config,
                    ref_value = "equinox_assist",
                },
                SMODS.Mods.DebugPlus and create_toggle {
                    label = localize {type = "variable", key = "b_Roland_escapey_debugger"},
                    ref_table = SMODS.Mods.Roland.config,
                    ref_value = "escapey_debugger",
                    callback = function(v)
                        G.escapey_debugger = v and print or nil
                    end,
                },
                SMODS.Mods.DebugPlus and UIBox_button {
                    label = {localize {type = "variable", key = "b_Roland_debug_export"}},
                    func = G.P_CENTERS.j_Roland_escapey.debug_export,
                    button = "Roland_debug_export",
                    colour = G.C.MULT,
                    col = true,
                    scale = 8,
                },
            },
        }},
    }
end

function G.FUNCS.Roland_debug_export(_, tbl)
    local to = tbl or _G
    to.f, to.q, to.u = unpack(qol)
end
