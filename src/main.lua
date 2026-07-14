local qol = assert(SMODS.load_file "src/lib/shared.lua")() or require "lib.shared"
local f, q = qol[1], qol[2]

q {
    front = true,
    no_delete = true,
    blocking = false,
    blockable = false,
    func = function()
        local contributors = (Bakery_API or {}).contributors

        if not contributors then
            return false
        end

        f(assert(SMODS.load_file "src/credits.lua")() or require "credits"):each(function(v, k)
            contributors["Roland_" .. k] = v
        end)

        if not SMODS.Mods.DebugPlus or not SMODS.Mods.Roland.config.import_funky then
            return
        end

        _G.f, _G.q, _G.u, _G.c = unpack(qol)
    end,
}

f {
    "challenge",
    "spectral",
    "edition",
    "voucher",
    "tweaks",
    "blind",
    "charm",
    "joker",
    "tarot",
    "back",
    "seal",
    "tag",
}:each(function(v)
    assert(SMODS.load_file("src/" .. v .. ".lua"))(qol)
end)

local _ = Balatest and f {"joker", "blind", "spectral"}:each(function(v)
    assert(SMODS.load_file("src/tests/" .. v .. ".tests.lua"))(qol)
end)

local function toggle(id)
    return create_toggle {
        label = localize {type = "variable", key = "b_Roland_" .. id},
        ref_table = SMODS.Mods.Roland.config,
        ref_value = id,
        scale = 1.5,
    }
end

SMODS.current_mod.qol = qol
local animated = SMODS.Mods.Roland.config.animated_icon

SMODS.Atlas {
    px = 256,
    py = 256,
    key = "modicon",
    fps = animated and 12 or nil,
    frames = animated and 12 or nil,
    path = animated and "icon.png" or "unicon.png",
    atlas_table = animated and "ANIMATION_ATLAS" or "ASSET_ATLAS",
}

function SMODS.current_mod.config_tab()
    return {
        n = G.UIT.ROOT,
        config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.BLACK},
        nodes = {{
            n = G.UIT.C,
            config = {minw = 1, minh = 1, align = "tl", padding = 0.1, colour = G.C.CLEAR},
            nodes = {
                toggle "animated_icon",
                toggle "cool_phones",
                toggle "faster_planets",
                -- toggle "illusion_seal",
                -- toggle "no_wild_debuff",
                toggle "vitriol",
                toggle "equinox_assist",
                SMODS.Mods.DebugPlus and toggle "import_funky",
                G.P_CENTERS.c_Bakery_Scribe and toggle "scribable_basket",
                Talisman and toggle "harsh_ante_scaling",
            },
        }},
    }
end
