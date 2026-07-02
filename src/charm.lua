local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]
local mod = SMODS.current_mod
local cool_phones = SMODS.Mods.Roland.config.cool_phones

SMODS.Atlas {
    key = "charm",
    path = cool_phones and "phorm.png" or "charm.png",
    px = 68,
    py = 68,
}

local _ = cool_phones and SMODS.Sound {
    key = "phone",
    path = "phone.ogg",
}

local charm = (function()
    local x = 0

    ---@param tbl SMODS.Joker|{alerted?: boolean, artist?: string, equip?: fun(self: self, card: Card)}
    return function(tbl)
        q {
            blocking = false,
            no_delete = true,
            func = function()
                if not Bakery_API or not Bakery_API.Charm then
                    return false
                end

                local current_mod = SMODS.current_mod
                SMODS.current_mod = mod

                -- SMODS._save_d_u(charm)
                tbl.alerted = true
                tbl.unlocked = true
                tbl.discovered = true
                tbl.pos = {x = x, y = 0}
                tbl.atlas = "charm"
                tbl.artist = not cool_phones and "Roland_bakersdozenbagels" or nil
                x = x + 1

                local orig_equip = tbl.equip

                function tbl.equip(...)
                    local _ = cool_phones and play_sound("Roland_phone", 1, 0.5)

                    if orig_equip then
                        return orig_equip(...)
                    end
                end

                local charm = Bakery_API.credit(Bakery_API.Charm(tbl))
                charm:inject()
                charm:process_loc_text()
                SMODS.current_mod = current_mod
            end,
        }
    end
end)()

local function can_discard_zero()
    return G.GAME.current_round.discards_left > 0 and
        not next(G.hand.highlighted) and
        G.hand.config.card_limit > 0 and
        G.GAME.Bakery_charm == "BakeryCharm_Roland_cocacola"
end

charm {
    key = "hand",
    pronouns = "he_him",
    config = {extra = {hands = -2, hand_size = 5}},
    attributes = {"hands", "hand_size", "passive"},
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.hand_size, extra.hands}}
    end,
    equip = function(_, card)
        local extra = card.ability.extra
        local round = G.GAME.round_resets
        ease_hands_played(extra.hands)
        G.hand:change_size(extra.hand_size)
        round.hands = round.hands + extra.hands
    end,
    unequip = function(_, card)
        local extra = card.ability.extra
        local round = G.GAME.round_resets
        ease_hands_played(-extra.hands)
        G.hand:change_size(-extra.hand_size)
        round.hands = round.hands - extra.hands
    end,
}

charm {
    key = "cocacola",
    pronouns = "he_they",
    attributes = {"passive", "tarot", "spectral"},
    config = {extra = {discard = 2, hand_size = 1, refund = 0}},
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.discard, extra.hand_size}}
    end,
    calculate = function(_, card, context)
        if not context.end_of_round then
            return
        end

        local extra = card.ability.extra
        G.hand:change_size(extra.refund)
        extra.refund = 0
    end,
}

local orig_can_discard = G.FUNCS.can_discard

function G.FUNCS.can_discard(e, ...)
    if can_discard_zero() then
        e.config.button, e.config.colour = "Roland_cocacola", G.C.RED
    else
        return orig_can_discard(e, ...)
    end
end

G.FUNCS.Roland_cocacola = function()
    stop_use()
    G.CONTROLLER.interrupt.focus = true
    G.CONTROLLER:save_cardarea_focus "hand"

    f(G.playing_cards):map "ability":each(function(v)
        v.forced_selection = nil
    end)

    G.card_area_focus_reset = (G.CONTROLLER.focused.target or {}).area == G.hand and
        {area = G.hand, rank = G.CONTROLLER.focused.target.rank} or G.card_area_focus_reset

    SMODS.calculate_context {pre_discard = true, full_hand = G.hand.highlighted}
    G.GAME.current_round.discards_used = G.GAME.current_round.discards_used + 1

    local c = G.Bakery_charm_area.cards[1]
    local extra = c.ability.extra or {}
    juice_card(c)
    ease_discard(extra.discard - 1)
    G.hand:change_size(-extra.hand_size)
    extra.refund = extra.refund + extra.hand_size

    local _ = G.GAME.modifiers.discard_cost and ease_dollars(-G.GAME.modifiers.discard_cost)
    G.STATE = G.STATES.DRAW_TO_HAND

    q {
        trigger = "immediate",
        func = function()
            if G.SCORING_COROUTINE then
                return false
            end

            G.STATE_COMPLETE = false
            return true
        end,
    }
end

charm {
    key = "fat",
    pronouns = "he_they",
    attributes = {"passive"},
    config = {extra = {mod = 2}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.mod}}
    end,
    equip = function(_, card)
        SMODS.change_booster_limit(card.ability.extra.mod)
    end,
    unequip = function(_, card)
        SMODS.change_booster_limit(-card.ability.extra.mod)
    end,
}

local orig_init = Card.init

function Card:init(X, Y, W, H, card, center, params, ...)
    if G.GAME.Bakery_charm ~= "BakeryCharm_Roland_fat" or center.set ~= "Booster" then
        return orig_init(self, X, Y, W, H, card, center, params, ...)
    end

    local key = f {"mini", "jumbo", "normal"}:fold(center.key, function(a, v)
        return a:gsub(v, "mega")
    end)

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
    key = "flexible",
    pronouns = "any_all",
}

local orig_showman = SMODS.showman

function SMODS.showman(...)
    return G.GAME.Bakery_charm == "BakeryCharm_Roland_flexible" or orig_showman(...)
end

charm {
    key = "wii",
    pronouns = "they_them",
    attributes = {"skip"},
    config = {extra = {active = true}},
    calculate = function(_, card, context)
        if context.prevent_tag_trigger and card.ability.extra.active then
            return {prevent_trigger = true}
        end

        if not context.skip_blind then
            return
        end

        card.ability.extra.active = true
        local message = localize {type = "variable", key = "b_Roland_entering_shop"}
        SMODS.calculate_effect({card = card, message = message, sound = "whoosh1"}, card)

        q(function()
            G.blind_prompt_box = G.blind_prompt_box and G.blind_prompt_box:remove()
            G.blind_select = G.blind_select and G.blind_select:remove()
            G.round_eval = G.round_eval and G.round_eval:remove()
            G.GAME.current_round.jokers_purchased = 0
            G.GAME.shop_free = nil
            G.GAME.shop_d6ed = nil
            play_sound("whoosh1", 1.33333, 0.8)
            play_sound("whoosh1", 0.66666, 0.8)

            q(function()
                G.STATE = G.STATES.SHOP
                G.STATE_COMPLETE = false
                delay(1)

                q(function()
                    f((G.GAME.modifiers.extra_boosters or 0) + 2)
                        :map(f.const(nil))
                        :each(SMODS.add_booster_to_shop)

                    q(function()
                        card.ability.extra.active = false
                    end)
                end)
            end)
        end)
    end,
}

local orig_apply_to_run = Tag.apply_to_run

function Tag:apply_to_run(...)
    if G.GAME.Bakery_charm == "BakeryCharm_Roland_wii" and
        G.Bakery_charm_area.cards[1].ability.extra.active then
        return
    end

    return orig_apply_to_run(self, ...)
end
