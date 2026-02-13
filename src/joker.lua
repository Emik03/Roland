local f, q, u = unpack(... or require "src.functional")

if false then
    Cryptid = Cryptid -- Suppresses warnings about the global.
end

local joker = (function()
    local z = 0

    ---@return {x: number, y: number}
    local function inc()
        local ret = {x = z % 6, y = math.floor(z / 6)}
        z = z + 1
        return ret
    end

    ---@param tbl SMODS.Joker|{artist?: string, sinis?: boolean|{x: number, y: number}, soul_pos?: boolean|{x: number, y: number}}
    return function(tbl)
        tbl.pos = inc()
        tbl.atlas = "joker"
        tbl.soul_pos = tbl.soul_pos and inc() or nil
        tbl.sinis = tbl.sinis and inc() or nil
        SMODS.Joker(tbl)

        local _ = tbl.artist and q(function()
            Bakery_API.contributors.Roland_char = Bakery_API.contributors.Roland_char or {
                name = "char (@irregulester)",
                fg = HEX "f8f8f2",
                bg = HEX "ff79c6",
            }

            Bakery_API.credit(tbl)
        end)
    end
end)()

local function destructible(card)
    return not card.highlighted and not (card.ability or {}).eternal
end

local function is_carbon(card)
    return card.edition and card.edition.key == "e_Bakery_Carbon"
end

local function is_mergeable_with(x)
    return function(y)
        return x.rank ~= y.rank and y.label == "j_Roland_escapey" and not (y.ability or {}).eternal
    end
end

local function level_up(hand, by, card)
    local function update(handname, chips, mult, level, pitch)
        update_hand_text(
            {sound = "button", volume = 0.7, pitch = pitch or 0.8, delay = 0.3},
            {handname = handname, chips = chips, level = level, mult = mult}
        )
    end

    if by <= 0 then
        return
    end

    hand = hand or "NO_HAND_SPECIFIED"
    local hand_obj = G.GAME.hands[hand]

    if hand == "all" or hand == "allhands" or hand == "all_hands" then
        update(localize "k_all_hands", "...", "...", "")

        f(G.GAME.hands):keys():foreach(function(k)
            level_up_hand(card, k, nil, by)
        end)
    elseif hand_obj then
        update(localize(hand, "poker_hands"), hand_obj.chips, hand_obj.mult, hand_obj.level)
        level_up_hand(card, hand, nil, by)
    end

    update("", 0, 0, "", 1.1)
end

SMODS.Atlas {
    key = "joker",
    path = "joker.png",
    px = 71,
    py = 95,
}

joker {
    key = "escapey",
    pronouns = "they_them",
    config = {extra = {hands = 2}},
    cost = 4,
    rarity = 2,
    sinis = true,
    soul_pos = true,
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local loc_self = G.localization.descriptions.Joker.j_Roland_escapey

        ---@diagnostic disable-next-line: undefined-global
        local sinister = (Jen or {}).sinister or G.escapey_sinister
        local quotes = loc_self.quotes

        local merge = G.jokers
            and f(G.jokers.cards):any(is_mergeable_with(card))
            and loc_self.merge or {}

        local normal = (merge[1] or sinister) and "" or
            pseudorandom_element(quotes.normal, pseudoseed "EscapeyQuotes") or ""

        local scared = (merge[1] or not sinister) and "" or
            pseudorandom_element(quotes.scared, pseudoseed "EscapeyQuotes") or ""

        return {
            vars = {
                card.ability.extra.hands,
                normal,
                scared,
                merge[1] or "",
                merge[1] and loc_self.name or "",
                merge[2] or "",
            },
        }
    end,
    calculate = function(_, _, context)
        local _ = type(G.escapey_debugger) == "function" and G.escapey_debugger(f(context):keys():conjoin(", "))
    end,
    Bakery_can_use = function(_, card)
        return not card.debuff and u() and (
            #G.GAME.tags ~= 0 or
            f(G.consumeables.cards):any(destructible) or
            f(G.jokers.cards):any(is_mergeable_with(card))
        )
    end,
    Bakery_use_button_text = function(_, card)
        if card.debuff then
            return "DEBUFFED"
        end

        return #G.GAME.tags == 0 and not f(G.consumeables.cards):filter(destructible):any() and
            f(G.jokers.cards):filter(is_mergeable_with(card)):any() and "FUSE" or "ESCAPE"
    end,
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
                level_sum = level_sum + v.ability.extra.hands * (v.getEvalQty and v:getEvalQty() or 1)
                sell_sum = sell_sum + v.sell_cost * (v.getEvalQty and v:getEvalQty() or 1)
                v:start_dissolve({HEX "57ecab"}, nil, 1.6)
            end)

            if not any_carbon then
                card.ability.extra.hands = card.ability.extra.hands + level_sum
            end

            card.sell_cost = card.sell_cost + sell_sum
            return
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

        local hands = f(G.GAME.hands):filter(f "visible"):keys():into()

        pseudoshuffle(hands, pseudoseed "RolandEscapey")
        local levels = destroyed * card.ability.extra.hands
        level_up("all", math.floor(levels / #hands), card)

        f(hands):take(levels % #hands):foreach(function(v)
            level_up(v, 1, card)
        end)
    end,
}

joker {
    key = "msjoker", -- Blue bow
    pronouns = "she_her",
    cost = 1,
    rarity = 1,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    config = {extra = {chips = 30}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.chips}}
    end,
    calculate = function(_, card, context)
        return context.joker_main and {card = card, chips = card.ability.extra.chips} or nil
    end,
}

joker {
    key = "mrsbones",
    pronouns = "she_her",
    config = {extra = {xmult = 4, requirement = 4}},
    cost = 4,
    rarity = 2,
    eternal_compat = false,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.requirement * 100}}
    end,
    calculate = function(_, card, context)
        if context.blueprint then
            return
        end

        if context.joker_main then
            return {xmult = card.ability.extra.xmult}
        end

        if not card.getting_sliced and
            context.end_of_round and
            G.GAME.chips / card.ability.extra.requirement < G.GAME.blind.chips then
            card.getting_sliced = true
            local message = localize {type = "variable", key = "b_Roland_bye"}
            SMODS.calculate_effect({message = message, colour = G.C.RED}, card)

            q(function()
                G.hand_text_area.blind_chips:juice_up()
                G.hand_text_area.game_chips:juice_up()
                card:start_dissolve()
                play_sound("tarot1")
            end)
        end
    end,
}

joker {
    key = "phytoestrogens",
    pronouns = "she_her",
    config = {extra = {division = Cryptid and 1 or 4}},
    cost = 8,
    rarity = 3,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local division = card.ability.extra.division
        return {vars = {division == 1 and "" or "/" .. number_format(division)}}
    end,
    calculate = function(_, card, context)
        return context.joker_main and {mult = hand_chips / card.ability.extra.division} or nil
    end,
}

joker {
    key = "monomino",
    pronouns = "it_its",
    config = {extra = {price = 4, hand_name = "Four of a Kind"}},
    cost = 4,
    rarity = 1,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.price, localize(extra.hand_name, "poker_hands")}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if not context.before or context.scoring_name ~= extra.hand_name then
            return
        end

        card.ability.extra_value = card.ability.extra_value + extra.price
        card:set_cost()
        return {message = localize "k_val_up", colour = G.C.MONEY}
    end,
}

joker {
    key = "domino",
    pronouns = "it_its",
    config = {extra = {mult_gain = 4, hand_name = "Four of a Kind", mult = 0}},
    cost = 4,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = false,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.mult_gain, localize(extra.hand_name, "poker_hands"), extra.mult}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if context.joker_main then
            return {mult = extra.mult}
        end

        if not context.before or context.scoring_name ~= extra.hand_name then
            return
        end

        extra.mult = extra.mult + extra.mult_gain
        return {message = localize "k_upgrade_ex", colour = G.C.RED, message_card = card}
    end,
}

joker {
    key = "trimino",
    pronouns = "it_its",
    config = {extra = {times = 4, hand_name = "Four of a Kind"}},
    cost = 8,
    rarity = 3,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.times, localize(extra.hand_name, "poker_hands")}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if not context.before or card.getting_sliced or context.scoring_name ~= extra.hand_name then
            return
        end

        card.getting_sliced = true

        q(function()
            local scored_cards = f(G.play.cards):filter(f "highlighted"):into()
            local copied = {}

            for _ = 1, extra.times do
                G.playing_card = (G.playing_card or 0) + 1
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                local chosen = pseudorandom_element(scored_cards, pseudoseed "Roland_trimino")
                local copy = copy_card(chosen, nil, nil, G.playing_card)
                copy:add_to_deck()
                G.hand:emplace(copy)
                copy:start_materialize()
                table.insert(copied, copy)
                table.insert(G.playing_cards, copy)
            end

            SMODS.calculate_effect({{message = localize "k_copied_ex", message_card = card}}, card)
            playing_card_joker_effects(copied)
            card:start_dissolve()
        end)
    end,
}

joker {
    key = "sunny", -- Cracked egg
    pronouns = "they_them",
    cost = 2,
    rarity = 1,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local last = ((G.deck or {}).cards or {})[1]

        if not last or card.area ~= G.jokers then
            return {
                vars = {
                    "",
                    localize {type = "variable", key = "b_Roland_na"},
                    "",
                    colours = {G.C.JOKER_GREY, G.C.JOKER_GREY},
                },
            }
        end

        local suit = last.base.suit
        local value = last.base.value
        local name = last.ability.name or ""
        local no_rank = SMODS.has_no_rank(last)
        local no_suit = SMODS.has_no_suit(last)

        return {
            vars = {
                value and not no_rank and localize(value or 14, "ranks") or name,
                not no_rank and not no_suit and localize {type = "variable", key = "b_Roland_of"} or "",
                no_suit and "" or localize(suit, "suits_plural"),
                colours = {G.C.IMPORTANT, G.C.SUITS[suit] or G.C.JOKER_GREY},
            },
        }
    end,
    calculate = function(_, _, context)
        local _ = context.selling_self and draw_card(G.deck, G.hand, 100, "up", false, G.deck.cards[1])
    end,
}

joker {
    key = "yard",
    pronouns = "he_him",
    config = {extra = {money = 2}},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.money}}
    end,
    calculate = function(_, card, context)
        return context.remove_playing_cards and
            {dollars = card.ability.extra.money * #context.removed, card = card} or nil
    end,
}

joker {
    key = "misfortune",
    pronouns = "she_they",
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_SEALS.Purple)
        table.insert(info_queue, G.P_CENTERS.e_negative)
    end,
    in_pool = function()
        return f(G.playing_cards):any(function(v)
            return v.seal == "Purple"
        end)
    end,
}

joker {
    key = "temple",
    pronouns = "any_all",
    config = {extra = {xmult = 1.5}},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.m_wild)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(_, card, context)
        if context.individual and
            context.cardarea == "unscored" and
            SMODS.has_enhancement(context.other_card, "m_wild") then
            return {xmult = card.ability.extra.xmult}
        end
    end,
}

joker {
    key = "bulldozer",
    pronouns = "it_its",
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(self, _, _)
        return {vars = {self.xmult()}}
    end,
    calculate = function(self, card, context)
        return context.joker_main and {card = card, xmult = self.xmult()} or nil
    end,
    xmult = function()
        local function mult(id)
            local next = {Select = true, Upcoming = true}
            local states = G.GAME.round_resets.blind_states
            local choices = G.GAME.round_resets.blind_choices
            return next[states[id]] and G.P_BLINDS[choices[id]].mult
        end

        local m = ((G.GAME or {}).blind or {}).mult
        return m and m ~= 0 and m or mult "Small" or mult "Big" or mult "Boss" or 1
    end,
}

joker {
    key = "oops",
    pronouns = "he_they",
    artist = "Roland_char",
    cost = 7,
    rarity = 3,
    config = {extra = {probability = 1, probability_mult = 2, reset = 1}},
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.probability_mult, extra.probability}}
    end,
    calculate = function(_, card, context)
        if context.blueprint or not card.ability then
            return
        end

        local extra = card.ability.extra

        if context.mod_probability then
            return {numerator = extra.probability}
        end

        if context.end_of_round and extra.probability ~= extra.reset then
            extra.probability = extra.reset
            return {message = localize "k_reset", colour = G.C.RED}
        end

        if context.after then
            extra.probability = extra.probability * extra.probability_mult
            return {message = localize "k_upgrade_ex", colour = G.C.GREEN}
        end
    end,
}

joker {
    key = "martingale",
    pronouns = "he_him",
    config = {extra = {odds = 2}},
    cost = 8,
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

        local extra, numerator, xmult = card.ability.extra, 1, 1

        for _ = 1, 64 do
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
