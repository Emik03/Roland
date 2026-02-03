local f, q, u = unpack(... or require "src.functional")

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

SMODS.Sound {
    key = "milestone",
    path = "milestone.ogg",
}

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
    config = {extra = {hands = 2}},
    cost = 6,
    rarity = 2,
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
        if type(G.escapey_debugger) == "function" then
            G.escapey_debugger(f(context):reduce("", function(acc, _, next)
                return acc .. ", " .. next
            end):sub(2))
        end
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

        local hands = f(G.GAME.hands):filter(function(v, _)
            return v.visible
        end):keys():into()

        pseudoshuffle(hands, pseudoseed "RolandEscapey")
        local levels = destroyed * card.ability.extra.hands
        level_up("all", math.floor(levels / #hands), card)

        f(hands):take(levels % #hands):foreach(function(v)
            level_up(v, 1, card)
        end)
    end,
    debug_export = function(self, obj)
        local to = obj or self
        to.f, to.q, to.u = f, q, u
    end,
}

SMODS.Joker {
    key = "msjoker", -- Blue bow
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
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

SMODS.Joker {
    key = "sunny", -- Cracked egg
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 2,
    rarity = 1,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local last = ((G.deck or {}).cards or {})[1]

        if last or card.area ~= G.jokers then
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
        local _ = context.selling_self and
            draw_card(G.deck, G.hand, 100, "up", false, G.deck.cards[1])
    end,
}

SMODS.Joker {
    key = "hexagon",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {money = 2}},
    cost = 4,
    rarity = 1,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.money}}
    end,
    calculate = function(_, card, context)
        return context.joker_main and
            context.scoring_name == "Four of a Kind" and
            {dollars = card.ability.extra.money} or nil
    end,
}

SMODS.Joker {
    key = "hexagoner",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {mult = 0}},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = false,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.mult}}
    end,
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
    key = "hexagonest",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {mult = 0}},
    cost = 8,
    rarity = 3,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
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
    key = "estrogen",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    calculate = function(_, _, context)
        return context.joker_main and {mult = hand_chips} or nil
    end,
}

SMODS.Joker {
    key = "yard",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
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

assert(SMODS.load_file("src/joker.rigged.lua"))({f, q, u})

SMODS.Joker {
    key = "misfortune",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
}

SMODS.Joker {
    key = "temple",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    config = {extra = {xmult = 1.5}},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
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

SMODS.Joker {
    key = "bulldozer",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
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
        return ((G.GAME or {}).blind or {}).mult or 1
    end,
}

SMODS.Joker {
    key = "mrsbones",
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
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

        if context.blind_defeated and G.GAME.chips / card.ability.extra.requirement < G.GAME.blind.chips then
            q(function()
                G.hand_text_area.blind_chips:juice_up()
                G.hand_text_area.game_chips:juice_up()
                play_sound("tarot1")
                card:start_dissolve()
            end)
        end
    end,
}

SMODS.Joker {
    key = "oops", -- Slot machine
    atlas = "void",
    pronouns = "they_them",
    pos = {x = 0, y = 0},
    cost = 8,
    rarity = 3,
    config = {extra = {probability = 1, delta = 1}},
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.probability}}
    end,
    calculate = function(_, card, context)
        if context.blueprint or not card.ability then
            return
        end

        local extra = card.ability.extra

        if context.mod_probability then
            return {numerator = extra.probability}
        end

        if context.blind_defeated then
            extra.probability = extra.delta
        elseif context.after then
            extra.probability = extra.probability + extra.delta
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
