local f, q, u = unpack(... or require "src.functional")

local function common_hand()
    return (G.GAME or {}).current_round and f(G.GAME.hands):reduce(
        {name = "High Card", order = -1 / 0, played = 0},
        function(a, v, k)
            return (a.played < v.played or (a.played == v.played) and (a.order > v.order)) and
                {name = k, order = v.order, played = v.played} or a
        end
    ).name or "High Card"
end

local function destructible(card)
    return not card.highlighted and not (card.ability or {}).eternal
end

local function is_carbon(card)
    return card.edition and card.edition.key == "e_Bakery_Carbon"
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

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "martingale",
    path = "martingale.png",
}

SMODS.Joker {
    key = "escapey",
    atlas = "escapey",
    pronouns = "they_them",
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
            and f(G.jokers.cards):filter(is_mergeable_with(card)):any()
            and loc_self.merge or {}

        local normal = (merge[1] or sinister) and {} or
            pseudorandom_element(quotes.normal, pseudoseed "EscapeyQuotes") or {}

        local scared = (merge[1] or not sinister) and {} or
            pseudorandom_element(quotes.scared, pseudoseed "EscapeyQuotes") or {}

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
            G.escapey_debugger(f(context):reduce("", function(acc, _, next)
                return acc .. ", " .. next
            end):sub(2))
        end
    end,
    ---@param card Card
    Bakery_can_use = function(_, card)
        return not card.debuff and u() and (
            #G.GAME.tags ~= 0 or
            f(G.consumeables.cards):filter(destructible):any() or
            f(G.jokers.cards):filter(is_mergeable_with(card)):any()
        )
    end,
    ---@param card Card
    Bakery_use_button_text = function(_, card)
        if card.debuff then
            return "DEBUFFED"
        end

        return #G.GAME.tags == 0 and not f(G.consumeables.cards):filter(destructible):any() and
            f(G.jokers.cards):filter(is_mergeable_with(card)):any() and "FUSE" or "ESCAPE"
    end,
    ---@param card Card
    Bakery_use_joker = function(_, card)
        if card.debuff then
            return
        end

        local consumables = f(G.consumeables.cards):filter(destructible):into()
        local consumable_count = #consumables
        local tag_count = #G.GAME.tags

        if consumable_count == 0 and tag_count == 0 then
            local level_sum, sell_sum = 0, 0
            local any_carbon = is_carbon(card)

            f(G.jokers.cards):filter(is_mergeable_with(card)):foreach(function(v)
                any_carbon = any_carbon or is_carbon(v)
                level_sum = level_sum + v.ability.extra.level_up_by * (v.getEvalQty and v:getEvalQty() or 1)
                sell_sum = sell_sum + v.sell_cost * (v.getEvalQty and v:getEvalQty() or 1)
                v:start_dissolve({HEX "57ecab"}, nil, 1.6)
            end)

            if not any_carbon then
                card.ability.extra.level_up_by = card.ability.extra.level_up_by + level_sum
            end

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
                attention_text {
                    scale = 0.7,
                    align = "cm",
                    text = "ESC",
                    cover = v.HUD_tag,
                    colour = G.C.WHITE,
                    cover_colour = G.C.BLACK,
                    hold = 0.3 / G.SETTINGS.GAMESPEED,
                }

                play_sound("cancel", 1.66, 0.5)
                v.HUD_tag.states.visible = false
                v:remove()
            end
        end

        local hand = common_hand()

        if hand == "all" or hand == "allhands" or hand == "all_hands" then
            update(localize "k_all_hands", "...", "...", "")
        elseif G.GAME.hands[hand or "NO_HAND_SPECIFIED"] then
            update(
                localize(hand, "poker_hands"),
                G.GAME.hands[hand].chips,
                G.GAME.hands[hand].mult,
                G.GAME.hands[hand].level
            )
        end

        local destroyed = 0

        if consumable_count == 0 then
            local trigger = #G.GAME.tags >= 30 and "immediate" or "before"
            local delay = #G.GAME.tags >= 30 and 0 or 1 / #G.GAME.tags

            f(G.GAME.tags):foreach(function(v)
                q {
                    trigger = trigger,
                    blocking = #G.GAME.tags < 30,
                    delay = delay,
                    func = fast_delete(v),
                }

                destroyed = destroyed + 1
            end)
        else
            f(consumables):foreach(function(v)
                v:start_dissolve({HEX "57ecab"}, nil, 1.6)
                destroyed = destroyed + 1
            end)
        end

        level_up_hand(card, hand, nil, destroyed * card.ability.extra.level_up_by)

        update_hand_text(
            {sound = "button", volume = 0.7, pitch = 1.1, delay = 0},
            {mult = 0, chips = 0, handname = "", level = ""}
        )
    end,
}

SMODS.Joker {
    key = "temp",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 1,
    rarity = 1,
    config = {extra = {chips = 30}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.chips}}
    end,
    calculate = function(_, card, context)
        return context.joker_main and {card = card, chips = card.ability.extra.chips} or nil
    end,
}

SMODS.Joker {
    key = "temp2",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 6,
    rarity = 2,
    loc_vars = function(self, _, _)
        return {vars = {self.xmult()}}
    end,
    calculate = function(self, card, context)
        return context.joker_main and {card = card, xmult = self.xmult()} or nil
    end,
    xmult = function()
        return ((G.GAME or {}).blind or {}).mult or 1
    end,
}

SMODS.Joker {
    key = "temp3",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 8,
    rarity = 3,
    config = {extra = {probability = 1}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.probability}}
    end,
    calculate = function(_, card, context)
        if context.mod_probability then
            return {numerator = card.ability.extra.probability}
        elseif context.after and not context.blueprint then
            card.ability.extra.probability = card.ability.extra.probability + 1
        end
    end,
}

SMODS.Joker {
    key = "temp4",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 8,
    rarity = 3,
    calculate = function(_, _, context)
        return context.joker_main and {mult = hand_chips} or nil
    end,
}

SMODS.Joker {
    key = "temp5",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 2,
    rarity = 1,
    calculate = function(_, _, context)
        local _ = context.selling_self and
            draw_card(G.deck, G.hand, 100, "up", false, G.deck.cards[#G.deck.cards])
    end,
}

SMODS.Joker {
    key = "temp6",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {money = 2}},
    cost = 6,
    rarity = 2,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.money}}
    end,
    calculate = function(_, card, context)
        return context.remove_playing_cards and
            {dollars = card.ability.extra.money * #context.removed, card = card} or nil
    end,
}

SMODS.Joker {
    key = "temp7",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 3,
    rarity = 1,
    calculate = function(_, _, context)
        return context.repetition and
            context.cardarea == G.play and
            context.scoring_name == "Four of a Kind" and {repetitions = 1} or nil
    end,
}

SMODS.Joker {
    key = "temp8",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {mult = 0}},
    cost = 8,
    rarity = 2,
    calculate = function(_, card, context)
        if context.joker_main then
            return {mult = card.ability.extra.mult}
        end

        if context.individual and
            context.cardarea == "unscored" and
            context.scoring_name == "Four of a Kind" then
            card.ability.extra.mult = card.ability.extra.mult + context.other_card.base.nominal
        end
    end,
}

SMODS.Joker {
    key = "temp9",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {mult = 0}},
    cost = 8,
    rarity = 3,
    calculate = function(_, _, context)
        if not context.individual or
            context.cardarea ~= "unscored" or
            context.scoring_name ~= "Four of a Kind" then
            return
        end

        q(function()
            playing_card_joker_effects(f(G.play):take(#G.play):map(function(v)
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                local copy = copy_card(v, nil, nil, G.playing_card)
                copy:add_to_deck()
                G.hand:emplace(copy)
                copy:start_materialize()
                table.insert(G.playing_cards, copy)
                return copy
            end):into())
        end)
    end,
}

SMODS.Joker {
    key = "temp10",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {xmult = 1.5}},
    cost = 8,
    rarity = 3,
    calculate = function(_, card, context)
        if context.individual and
            context.cardarea == "unscored" and
            SMODS.has_enhancement(context.other_card, "m_wild") then
            return {xmult = card.ability.extra.xmult}
        end
    end,
}

SMODS.Joker {
    key = "negative",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 6,
    rarity = 2,
}

SMODS.Joker {
    key = "mrsbones",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {xmult = 4}},
    cost = 8,
    rarity = 3,
    calculate = function(_, card, context)
        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end

        if context.blind_defeated and G.GAME.chips / card.ability.extra.xmult < G.GAME.blind.chips then
            q(function()
                G.hand_text_area.blind_chips:juice_up()
                G.hand_text_area.game_chips:juice_up()
                play_sound("tarot1")
                card:start_dissolve()
                return true
            end)
        end
    end,
}

SMODS.Joker {
    key = "martingale",
    atlas = "martingale",
    pronouns = "he_him",
    pos = {x = 0, y = 0},
    config = {extra = {odds = 2, times = 0, martingale = true}},
    cost = 7,
    rarity = 3,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local normal = G.GAME.probabilities.normal
        local odds   = card.ability.extra.odds
        local vars   = {normal}

        for i = #vars, 9 do
            table.insert(vars, math.pow(odds, i))
        end

        return {vars = vars}
    end,
    calculate = function(_, card, context)
        if not context.joker_main then
            return
        end

        local extra = card.ability.extra
        local xmult = extra.odds
        local numerator = 1

        for _ = 1, 31 do
            if SMODS.pseudorandom_probability(card, "j_Roland_martingale", 1, extra.odds, "Martingale") then
                break
            end

            numerator = numerator * (extra.odds - G.GAME.probabilities.normal)
            local message = number_format(numerator) .. "/" .. number_format(xmult)
            SMODS.calculate_effect({card = card, repetitions = 1, message = message}, card)
            xmult = xmult * extra.odds
        end

        SMODS.calculate_effect({card = card, xmult = xmult}, card)
    end,
}
