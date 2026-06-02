local qol = assert(SMODS.load_file "src/lib/shared.lua")() or require "lib.shared"
local f, q = unpack(qol)

f {"challenge", "spectral", "edition", "tweaks", "blind", "charm", "joker", "tarot", "back", "seal", "tag"}
    :each(function(v)
        assert(SMODS.load_file("src/" .. v .. ".lua"))(qol)
    end)

if _G["Balatest"] then
    f {"joker", "blind", "spectral"}:each(function(v)
        assert(SMODS.load_file("src/tests/" .. v .. ".tests.lua"))(qol)
    end)
end

q(function()
    -- Special shoutout to all contributors. <3
    ---@type table<string, {name: string, fg: table, bg: table}>
    local contributors, mods = Bakery_API.contributors, SMODS.Mods

    contributors.Roland_aster = {
        name = "asterSSH",
        fg = HEX "f8f8f2ff",
        bg = HEX "bd93f9ff",
    }

    contributors.Roland_bakersdozenbagels = {
        name = "BakersDozenBagels",
        fg = HEX "362708",
        bg = HEX "EDD198",
    }

    contributors.Roland_char = {
        name = "char (@irregulester)",
        fg = HEX "f8f8f2ff",
        bg = HEX "ff79c6ff",
    }

    if mods.DebugPlus and mods.Roland.config.import_funky then
        _G.f, _G.q, _G.u = unpack(qol)
    end
end, true)

local function toggle(id)
    return create_toggle {
        label = localize {type = "variable", key = "b_Roland_" .. id},
        ref_table = SMODS.Mods.Roland.config,
        ref_value = id,
        scale = 1.5,
    }
end

SMODS.Atlas {
    px = 256,
    py = 256,
    fps = 12,
    frames = 12,
    key = "modicon",
    path = "icon.png",
    atlas_table = "ANIMATION_ATLAS",
}

SMODS.current_mod.qol = qol

function SMODS.current_mod.config_tab()
    return {
        n = G.UIT.ROOT,
        config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.CLEAR},
            nodes = {
                toggle "faster_planets",
                toggle "illusion_seal",
                toggle "no_wild_debuff",
                _G["Talisman"] and toggle "harsh_ante_scaling",
                G.P_CENTERS.c_Bakery_Scribe and toggle "scribable_basket",
                toggle "equinox_assist",
                SMODS.Mods.DebugPlus and toggle "import_funky",
            },
        }},
    }
end
