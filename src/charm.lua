local f, q = unpack(... or require "src.functional")
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
            x = x + 1
            tbl.atlas = "charm"

            local charm = Bakery_API.Charm(tbl)
            charm:inject()
            charm:process_loc_text()
            SMODS.current_mod = current_mod
        end, true)
    end
end)()

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

charm {
    key = "flexible",
    pronouns = "any_all",
}

local orig_showman = SMODS.showman

---@diagnostic disable-next-line: duplicate-set-field
function SMODS.showman(...)
    return G.GAME.Bakery_charm == "BakeryCharm_Roland_flexible" or orig_showman(...)
end

charm {
    key = "fat",
    pronouns = "he_they",
    -- config = {extra = {mod = 1}},
    -- loc_vars = function(_, _, card)
    --     return {vars = {card.ability.extra.mod}}
    -- end,
    -- equip = function(_, card)
    --     SMODS.change_booster_limit(card.ability.extra.mod)
    -- end,
    -- unequip = function(card)
    --     SMODS.change_booster_limit(-card.ability.extra.mod)
    -- end,
}

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

charm {
    key = "cocacola",
    pronouns = "he_they",
}

local orig_debuff_card = SMODS.debuff_card

---@diagnostic disable-next-line: duplicate-set-field
function SMODS.debuff_card(...)
    if G.GAME.Bakery_charm ~= "BakeryCharm_Roland_cocacola" then
        return orig_debuff_card(...)
    end
end

charm {
    key = "hand",
    pronouns = "he_him",
    config = {extra = {hands = 1, hand_size = 5}},
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.hand_size, extra.hands}}
    end,
    equip = function(_, card)
        local extra = card.ability.extra
        G.hand:change_size(extra.hand_size)
        card.Roland_hands = G.GAME.round_resets.hands - card.ability.extra.hands
        G.GAME.round_resets.hands = card.ability.extra.hands
        ease_hands_played(-card.Roland_hands)
    end,
    unequip = function(_, card)
        local extra = card.ability.extra
        G.hand:change_size(-extra.hand_size)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + (card.Roland_hands or 0)
        ease_hands_played(card.Roland_hands or 0)
        card.Roland_hands = nil
    end,
}
