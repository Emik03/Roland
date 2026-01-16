local function can_use()
    return not ((G.play and #G.play.cards > 0 or
            G.CONTROLLER.locked or
            (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and
        G.STATE ~= G.STATES.HAND_PLAYED and
        G.STATE ~= G.STATES.DRAW_TO_HAND and
        G.STATE ~= G.STATES.PLAY_TAROT)
end

local function common_hand()
    return (G.GAME or {}).current_round and F.reduce(
        G.GAME.hands,
        {name = "High Card", order = -1 / 0, played = 0},
        function(a, v, k)
            return (a.played < v.played or (a.played == v.played) and (a.order > v.order)) and
                {name = k, order = v.order, played = v.played} or a
        end,
        pairs
    ).name or "High Card"
end

local function destructible(card)
    return not card.highlighted and not (card.ability or {}).eternal
end

local function is_mergeable_with(it)
    return function(card)
        return it.rank ~= card.rank and
            card.label == "j_Roland_escapey" and not
            (card.ability or {}).eternal
    end
end

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "escapey",
    path = "escapey.png",
}

SMODS.Joker {
    key = "escapey",
    atlas = "escapey",
    pos = {x = 0, y = 0},
    sinis = {x = 2, y = 0},
    soul_pos = {x = 1, y = 0},
    config = {extra = {level_up_by = 1}},
    cost = 8,
    rarity = 3,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = false,
    loc_vars = function(_, _, card)
        local loc_self = G.localization.descriptions.Joker.j_Roland_escapey

        ---@diagnostic disable-next-line: undefined-global
        local sinister = (Jen or {}).sinister or G.escapey_sinister
        local quotes = loc_self.quotes

        local merge = G.jokers
            and F.count(F.filter(G.jokers.cards, is_mergeable_with(card))) > 0
            and loc_self.merge or {}

        local normal = (merge[1] or sinister) and {} or
            pseudorandom_element(quotes.normal, pseudoseed("EscapeyQuotes")) or {}

        local scared = (merge[1] or not sinister) and {} or
            pseudorandom_element(quotes.scared, pseudoseed("EscapeyQuotes")) or {}

        return {
            vars = {
                card.ability.extra.level_up_by,
                localize(common_hand(), "poker_hands"),
                merge[1] or "",
                normal[1] or "",
                scared[1] or "",
                merge[2] or "",
                merge[3] and loc_self.name or "",
                merge[3] or "",
                normal[2] or "",
                scared[2] or "",
            },
        }
    end,
    calculate = function(_, _, context)
        if type(G.escapey_debugger) == "function" then
            G.escapey_debugger(F.reduce(context, "", function(acc, _, next) return acc .. ", " .. next end, pairs):sub(2))
        end
    end,
    ---@param card Card
    Bakery_can_use = function(_, card)
        return not card.debuff and can_use() and (
            #G.GAME.tags ~= 0 or
            F.any(G.consumeables.cards, destructible) or
            F.any(F.filter(G.jokers.cards, is_mergeable_with(card)))
        )
    end,
    ---@param card Card
    Bakery_use_button_text = function(_, card)
        if card.debuff then
            return "DEBUFFED"
        end

        return #G.GAME.tags == 0 and F.count(G.consumeables.cards, destructible) == 0 and
            F.any(F.filter(G.jokers.cards, is_mergeable_with(card))) and "FUSE" or "ESCAPE"
    end,
    ---@param card Card
    Bakery_use_joker = function(_, card)
        if card.debuff then
            return
        end

        local consumables = F.filter(G.consumeables.cards, destructible)
        local consumable_count = F.count(consumables)
        local object_count = consumable_count + #G.GAME.tags

        if object_count == 0 then
            local level_sum, sell_sum = 0, 0

            F.foreach(
                F.filter(G.jokers.cards, is_mergeable_with(card)),
                function(v)
                    level_sum = level_sum + v.ability.extra.level_up_by * (v.getEvalQty and v:getEvalQty() or 1)
                    sell_sum = sell_sum + v.sell_cost * (v.getEvalQty and v:getEvalQty() or 1)
                    v:start_dissolve({HEX("57ecab")}, nil, 1.6)
                end
            )

            card.ability.extra.level_up_by = card.ability.extra.level_up_by + level_sum
            card.sell_cost = card.sell_cost + sell_sum
            return
        end

        local function update(name, chip, mul, lv, notif, snd, vol, pit, de)
            update_hand_text({
                sound = type(snd) == "string" and snd or type(snd) == "nil" and "button",
                volume = vol or 0.7,
                pitch = pit or 0.8,
                delay = de or 0.3,
            }, {
                handname = name or "????",
                chips = chip or "?",
                level = lv or "?",
                mult = mul or "?",
                StatusText = notif,
            })
        end

        local function fast_delete(v)
            return function()
                attention_text({
                    scale = 0.7,
                    align = "cm",
                    text = "ESC",
                    cover = v.HUD_tag,
                    colour = G.C.WHITE,
                    cover_colour = G.C.BLACK,
                    hold = 0.3 / G.SETTINGS.GAMESPEED,
                })

                play_sound("cancel", 1.66, 0.5)
                v.HUD_tag.states.visible = false
                v:remove()
                return true
            end
        end

        local hand = common_hand()

        if hand == "all" or hand == "allhands" or hand == "all_hands" then
            update(localize("k_all_hands"), "...", "...", "")
        elseif G.GAME.hands[hand or "NO_HAND_SPECIFIED"] then
            update(
                localize(hand, "poker_hands"),
                G.GAME.hands[hand].chips,
                G.GAME.hands[hand].mult,
                G.GAME.hands[hand].level
            )
        end

        if consumable_count == 0 then
            local trigger = #G.GAME.tags >= 30 and "immediate" or "before"
            local delay = #G.GAME.tags >= 30 and 0 or 1 / #G.GAME.tags

            F.foreach(
                G.GAME.tags,
                function(v)
                    G.E_MANAGER:add_event(Event {trigger = trigger, blocking = #G.GAME.tags < 30, delay = delay, func = fast_delete(v)})
                end
            )
        else
            F.foreach(
                consumables,
                function(v)
                    v:start_dissolve({HEX("57ecab")}, nil, 1.6)
                end
            )
        end

        level_up_hand(card, hand, nil, object_count * card.ability.extra.level_up_by)

        update_hand_text(
            {sound = "button", volume = 0.7, pitch = 1.1, delay = 0},
            {mult = 0, chips = 0, handname = "", level = ""}
        )
    end,
}
