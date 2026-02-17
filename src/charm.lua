local _, q = unpack(... or require "src.functional")
local mod = SMODS.current_mod

SMODS.Atlas {
    key = "charm",
    path = "charm.png",
    px = 68,
    py = 68,
}

local charm = (function()
    local x = 0

    ---@param tbl SMODS.Joker|{alerted?: boolean}
    return function(tbl)
        q(function()
            local current_mod = SMODS.current_mod
            SMODS.current_mod = mod

            -- SMODS._save_d_u(charm)
            tbl.alerted = true
            tbl.unlocked = true
            tbl.discovered = true
            tbl.pos = {x = x, y = 0}
            tbl.atlas = "charm"
            x = x + 1

            local charm = Bakery_API.Charm(tbl)
            charm:inject()
            charm:process_loc_text()
            SMODS.current_mod = current_mod
        end)
    end
end)()

charm {
    key = "fat",
    pronouns = "he_they",
    config = {extra = {mod = 1}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.mod}}
    end,
    equip = function(_, card)
        SMODS.change_booster_limit(card.ability.extra.mod)
    end,
    unequip = function(card)
        SMODS.change_booster_limit(-card.ability.extra.mod)
    end,
}

charm {
    key = "flexible",
    pronouns = "any_all",
}

charm {
    key = "wii",
    pronouns = "they_them",
    calculate = function(_, card, context)
        if not context.skip_blind then
            return
        end

        local message = localize {type = "variable", key = "b_Roland_entering_shop"}
        SMODS.calculate_effect({card = card, message = message, sound = "whoosh1"}, card)

        q(function()
            G.blind_prompt_box = G.blind_prompt_box and G.blind_prompt_box:remove()
            G.blind_select = G.blind_select and G.blind_select:remove()
            G.round_eval = G.round_eval and G.round_eval:remove()
            G.GAME.current_round.jokers_purchased = 0
            G.STATE = G.STATES.SHOP
            G.GAME.shop_free = nil
            G.GAME.shop_d6ed = nil
            G.STATE_COMPLETE = false
            play_sound("whoosh1", 1.33333, 0.8)
            play_sound("whoosh1", 0.66666, 0.8)
        end)
    end,
}

local orig_showman = SMODS.showman

---@diagnostic disable-next-line: duplicate-set-field
function SMODS.showman(...)
    return G.GAME.Bakery_charm == "BakeryCharm_Roland_flexible" or orig_showman(...)
end

local orig_init = Card.init

---@diagnostic disable-next-line: duplicate-set-field
function Card:init(X, Y, W, H, card, center, params, ...)
    if G.GAME.Bakery_charm ~= "BakeryCharm_Roland_fat" or center.set ~= "Booster" then
        return orig_init(self, X, Y, W, H, card, center, params, ...)
    end

    local key = center.key:gsub("normal", "mega"):gsub("jumbo", "mega"):gsub("mini", "mega")

    if G.P_CENTERS[key] then
        return orig_init(self, X, Y, W, H, card, G.P_CENTERS[key], params, ...)
    end

    key = key:gsub("_?%d+$", "_1")

    if G.P_CENTERS[key] then
        return orig_init(self, X, Y, W, H, card, G.P_CENTERS[key], params, ...)
    end

    key = key:gsub("_?%d+$", "")

    if G.P_CENTERS[key] then
        return orig_init(self, X, Y, W, H, card, G.P_CENTERS[key], params, ...)
    end

    self.Roland_no_mega = true
    return orig_init(self, X, Y, W, H, card, center, params, ...)
end
