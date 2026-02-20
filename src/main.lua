local qol = assert(SMODS.load_file "lib/shared.lua")() or require "lib.shared"

qol[1] {"challenge", "spectral", "tweaks", "blind", "charm", "joker", "back", "seal"}:each(function(v)
    assert(SMODS.load_file("src/" .. v .. ".lua"))(qol)
end)

if Balatest then
    qol[1] {"joker", "blind", "spectral"}:each(function(v)
        assert(SMODS.load_file("src/tests/" .. v .. ".tests.lua"))(qol)
    end)
end

qol[2](function()
    ---@type table<string, {name: string, fg: table, bg: table}>
    local contributors = Bakery_API.contributors

    contributors.Roland_aster = {
        name = "asterSSH",
        fg = HEX "f8f8f2ff",
        bg = HEX "bd93f9ff",
    }

    contributors.Roland_char = {
        name = "char (@irregulester)",
        fg = HEX "f8f8f2ff",
        bg = HEX "ff79c6ff",
    }
end)

SMODS.Atlas {
    px = 256,
    py = 256,
    key = "modicon",
    path = "icon.png",
}

---@diagnostic disable-next-line: duplicate-set-field
function SMODS.current_mod.config_tab()
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
                    scale = 2,
                },
                SMODS.Mods.DebugPlus and UIBox_button {
                    label = {localize {type = "variable", key = "b_Roland_debug_export"}},
                    func = G.P_CENTERS.j_Roland_escapey.debug_export,
                    button = "Roland_debug_export",
                    colour = G.C.MULT,
                    col = true,
                    scale = 5,
                    minw = 5,
                },
            },
        }},
    }
end

function SMODS.current_mod.optional_features()
    return {cardareas = {deck = true, unscored = true}}
end

function G.FUNCS.Roland_debug_export(_, tbl)
    local to = tbl or _G
    to.f, to.q, to.u = unpack(qol)
end
