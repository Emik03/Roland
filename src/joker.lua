local f, q, u = unpack(... or require "lib.shared")

local negative = {key = "e_negative_consumable", set = "Edition", config = {extra = 1}}

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
        tbl.artist = tbl.artist and "Roland_" .. tbl.artist or nil
        tbl.soul_pos = tbl.soul_pos and inc() or nil
        tbl.sinis = tbl.sinis and inc() or nil
        local joker = SMODS.Joker(tbl)

        q(function()
            Bakery_API.credit(joker)
        end)
    end
end)()

local function destructible(card)
    return not card.highlighted and not (card.ability or {}).eternal
end

---@param card Card
local function is_carbon(card)
    return card.edition and card.edition.key == "e_Bakery_Carbon"
end

---@param card Card
local function is_frozen(card)
    return card.edition and card.edition.key == "e_Roland_frozen"
end

local function is_mergeable_with(x)
    return function(y)
        return x.rank ~= y.rank and
            y.label == "j_Roland_escapey" and
            not (y.ability or {}).eternal
    end
end

---@param hand? string|true
---@param by integer
---@param card Card
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

    if hand == true then
        update(localize "k_all_hands", "...", "...", "")
        delay(2)

        f(G.GAME.hands):where "visible":keys():each(function(k)
            level_up_hand(card, k, true, by)
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
    loc_vars = function(self, _, card)
        local sinister = (_G["Jen"] or _G["pwx"] or {}).sinister or G.escapey_sinister
        local loc = G.localization.descriptions.Joker.j_Roland_escapey
        local merge = self.fusable(card) and loc.merge or {}
        local quotes = loc.quotes

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
                merge[1] and loc.name or "",
                merge[2] or "",
            },
        }
    end,
    Bakery_can_use = function(self, card)
        return not card.debuff and u() and (self.exchangable() or self.fusable(card))
    end,
    Bakery_use_button_text = function(self, card)
        return localize {
            type = "variable",
            key = card.debuff and "b_Roland_debuffed" or
                ((not self.exchangable() and self.fusable(card)) and
                    "b_Roland_fuse" or "b_Roland_escape"),
        }
    end,
    calculate = function(self, card, context)
        return context.forcetrigger and self.proc(card) or nil
    end,
    Bakery_use_joker = function(self, card)
        if card.debuff then
            return
        end

        if not self.exchangable() then
            local level_sum, sell_sum = 0, 0
            local any_carbon = is_carbon(card)

            f(G.jokers.cards):where(is_mergeable_with(card)):each(function(v)
                any_carbon = any_carbon or is_carbon(v)
                level_sum = level_sum + v.ability.extra.hands * (v.getEvalQty and v:getEvalQty() or 1)
                sell_sum = sell_sum + v.sell_cost * (v.getEvalQty and v:getEvalQty() or 1)
                v:start_dissolve({HEX "57ecabff"}, nil, 1.6)
            end)

            if not any_carbon then
                card.ability.extra.hands = card.ability.extra.hands + level_sum
            end

            card.sell_cost = card.sell_cost + sell_sum
            return
        end

        local function fast_delete(tag)
            return function()
                attention_text {
                    scale = 0.7,
                    align = "cm",
                    text = "ESC",
                    cover = tag.HUD_tag,
                    colour = G.C.WHITE,
                    cover_colour = G.C.BLACK,
                    hold = 0.3 / G.SETTINGS.GAMESPEED,
                }

                play_sound("cancel", 1.66, 0.5)
                tag.HUD_tag.states.visible = false
                tag:remove()
            end
        end

        local destroyed = 0

        f(G.consumeables.cards):where(destructible):each(function(v)
            v:start_dissolve({HEX "57ecabff"}, nil, 1.6)
            destroyed = destroyed + 1
        end)

        if destroyed == 0 then
            local delay = #G.GAME.tags >= self.tag_threshold and 0 or 1 / #G.GAME.tags
            local trigger = #G.GAME.tags >= self.tag_threshold and "immediate" or "before"

            f(G.GAME.tags):each(function(v)
                q {
                    trigger = trigger,
                    blocking = #G.GAME.tags < 30,
                    delay = delay,
                    func = fast_delete(v),
                }

                destroyed = destroyed + 1
            end)
        end

        self.proc(card, destroyed)
    end,
    exchangable = function()
        return next(G.GAME.tags) or f(G.consumeables.cards):any(destructible)
    end,
    ---@param card Card
    fusable = function(card)
        return SMODS.Mods.Roland.config.fusable_escapey and
            f((G.jokers or {}).cards):any(is_mergeable_with(card))
    end,
    ---@param card Card
    ---@param times? integer
    proc = function(card, times)
        local hands = f(G.GAME.hands):where "visible":keys():table()
        local levels = card.ability.extra.hands * (times or 1)
        pseudoshuffle(hands, pseudoseed "RolandEscapey")
        level_up(true, math.floor(levels / #hands), card)

        f(hands):take(levels % #hands):each(function(v)
            level_up(v, 1, card)
        end)
    end,
    tag_threshold = 30,
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
        return (context.joker_main or context.forcetrigger) and
            {card = card, chips = card.ability.extra.chips} or nil
    end,
}

joker {
    key = "mrsbones",
    pronouns = "she_her",
    artist = "char",
    config = {extra = {xmult = 4, requirement = 4}},
    cost = G.P_CENTERS.j_mr_bones.cost - 1,
    rarity = 2,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.xmult, card.ability.extra.requirement * 100}}
    end,
    calculate = function(_, card, context)
        if context.joker_main or context.forcetrigger then
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
                play_sound "tarot1"
            end)
        end
    end,
}

joker {
    key = "phytoestrogens",
    pronouns = "she_her",
    config = {extra = {xmult = 0.25}},
    cost = 8,
    rarity = 3,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(_, card, context)
        if not context.joker_main and not context.forcetrigger then
            return
        end

        SMODS.calculate_effect({mult = hand_chips}, card)
        SMODS.calculate_effect({xmult = card.ability.extra.xmult}, card)
    end,
}

joker {
    key = "monomino",
    pronouns = "it_its",
    artist = "char",
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

        if (not context.before or context.scoring_name ~= extra.hand_name) and not context.forcetrigger then
            return
        end

        local c = context.blueprint_card or card
        c.ability.extra_value = c.ability.extra_value + extra.price
        c:set_cost()
        return {message = localize "k_val_up", colour = G.C.MONEY}
    end,
}

joker {
    key = "domino",
    pronouns = "it_its",
    artist = "char",
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

        if context.joker_main or context.forcetrigger then
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
    artist = "char",
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

        if (not context.before or card.getting_sliced or context.scoring_name ~= extra.hand_name) and not context.forcetrigger then
            return
        end

        card.getting_sliced = not context.forcetrigger

        q(function()
            local scored_cards = f(G.play.cards):where "highlighted":table()
            local copied = {}

            if not next(scored_cards) then
                card.getting_sliced = nil
                return
            end

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

            if not context.forcetrigger then
                card:start_dissolve()
            end
        end)
    end,
}

joker {
    key = "sunny",
    pronouns = "they_them",
    artist = "char",
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
        if not context.selling_self and not context.forcetrigger then
            return
        end

        draw_card(G.deck, G.hand, 100, "up", false, G.deck.cards[1])
        local current_round = G.GAME.current_round
        local facing_blind = G.GAME.facing_blind
        SMODS.calculate_context {drawing_cards = true, draw = {G.deck.cards}}

        SMODS.calculate_context {
            first_hand_drawn = not current_round.any_hand_drawn and facing_blind or nil,
            hand_drawn = facing_blind and {G.deck.cards[1]} --[[@as true]],
            other_drawn = not facing_blind and {G.deck.cards[1]},
        }

        if type(facing_blind) == "table" then
            facing_blind.any_hand_drawn = facing_blind.any_hand_drawn or facing_blind
        end
    end,
}

joker {
    key = "hardboiled",
    pronouns = "they_them",
    cost = 5,
    rarity = 2,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
    end,
    calculate = function(_, _, context)
        return (context.selling_self or context.forcetrigger) and f(G.hand.cards):each(function(v)
            q {
                delay = 0.1,
                func = function()
                    v:set_edition {Roland_frozen = true}
                end,
            }
        end) or nil
    end,
}

joker {
    key = "basket",
    pronouns = "they_them",
    cost = 8,
    rarity = 3,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, negative)
    end,
    calculate = function(_, _, context)
        return (context.selling_self or context.forcetrigger) and f(G.consumeables.cards):each(function(v)
            q {
                delay = 1,
                func = function()
                    play_sound "timpani"
                    SMODS.add_card {edition = "e_negative", key = v.config.center.key}
                end,
            }
        end) or nil
    end,
}

joker {
    key = "sapling",
    pronouns = "they_them",
    artist = "char",
    cost = 4,
    rarity = 1,
    config = {extra = {mult = 15, suits = 3}},
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.mult, extra.suits}}
    end,
    calculate = function(_, card, context)
        local function count(_, k)
            return f(context.scoring_hand):any(function(v)
                return v:is_suit(k)
            end)
        end

        if not context.joker_main and not context.forcetrigger then
            return
        end

        local extra = card.ability.extra

        if f(SMODS.Suits):count(count) >= card.ability.extra.suits or context.forcetrigger then
            return {mult = extra.mult}
        end
    end,
}

joker {
    key = "yard",
    pronouns = "he_him",
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
        return (context.remove_playing_cards or context.forcetrigger) and
            {dollars = card.ability.extra.money * #context.removed, card = card} or nil
    end,
}

joker {
    key = "suitable",
    pronouns = "she_they",
    cost = 4,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_CENTERS.m_wild)
        local suit = (G.GAME.current_round.Roland_suitable or {}).suit or "Spades"
        return {vars = {localize(suit, "suits_plural"), colours = {G.C.SUITS[suit]}}}
    end,
}

function SMODS.current_mod.reset_game_globals()
    local suitable = {suit = "Spades"}
    G.GAME.current_round.Roland_suitable = suitable
    local suits = f(G.playing_cards):where(SMODS.has_no_suit, false):table()
    local card = pseudorandom_element(suits, "Roland_suitable" .. G.GAME.round_resets.ante)
    suitable.suit = card and card.base.suit or suitable.suit
end

local orig_get_enhancements = SMODS.get_enhancements

function SMODS.get_enhancements(card, ...)
    if not next(SMODS.find_card "j_Roland_suitable") or
        card.base.suit ~= G.GAME.current_round.Roland_suitable.suit then
        return orig_get_enhancements(card, ...)
    end

    local ret = orig_get_enhancements(card, ...) or {}
    table.insert(ret, "m_wild")
    return ret
end

joker {
    key = "misfortune",
    pronouns = "she_they",
    artist = "char",
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_SEALS.Purple)
        table.insert(info_queue, negative)
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
        return ((context.individual and
            context.cardarea == "unscored" and
            SMODS.has_enhancement(context.other_card, "m_wild")
        ) or context.forcetrigger) and {xmult = card.ability.extra.xmult} or nil
    end,
    in_pool = function()
        return f(G.playing_cards):any(function(v)
            return SMODS.has_enhancement(v, "m_wild")
        end)
    end,
}

joker {
    key = "jokersr",
    pronouns = "he_him",
    config = {extra = {xmult = 1.25}},
    cost = 2,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(_, card, context)
        return (context.joker_main or context.forcetrigger) and
            {card = card, xmult = card.ability.extra.xmult} or nil
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
    loc_vars = function(self, card, _)
        return {vars = {self:xmult_frozen(card)}}
    end,
    calculate = function(self, card, context)
        return (context.joker_main or context.forcetrigger) and {card = card, xmult = self:xmult_frozen(card)} or nil
    end,
    xmult_frozen = function(self, card)
        if not is_frozen(card) then
            return self.xmult()
        end

        local ability = card.Roland_frozen_ability or {}
        card.Roland_frozen_ability = ability
        ability.Roland_frozen_xmult = ability.Roland_frozen_xmult or self.xmult()
        return ability.Roland_frozen_xmult
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
    key = "martingale",
    pronouns = "he_him",
    config = {extra = {odds = 2}},
    cost = 8,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local normal = G.GAME.probabilities.normal
        local odds   = card.ability.extra.odds
        local vars   = {normal}

        for i = 0, 7 do
            table.insert(vars, math.pow(odds, i))
        end

        return {vars = vars}
    end,
    calculate = function(self, card, context)
        if not context.joker_main and not context.forcetrigger then
            return
        end

        local extra, numerator, xmult = card.ability.extra, 1, 1

        for _ = 1, 64 do
            local g = G.GAME
            local key = "RolandMartingale" .. tostring(g.modifiers.Roland_martingale_seed or "")

            if SMODS.pseudorandom_probability(card, self.key, 1, extra.odds, key) then
                break
            end

            numerator = numerator * (extra.odds - g.probabilities.normal)
            local message = number_format(numerator) .. "/" .. number_format(xmult)
            SMODS.calculate_effect({card = card, repetitions = 1, message = message}, card)
            xmult = xmult * extra.odds
        end

        SMODS.calculate_effect({card = card, xmult = xmult}, card)
    end,
}

joker {
    key = "oops",
    pronouns = "she_they",
    artist = "char",
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
        if context.blueprint and not context.forcetrigger or not card.ability then
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
    key = "arctic",
    pronouns = "it_its",
    cost = 10,
    rarity = 3,
    config = {extra = {repetitions = 1}},
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
    end,
    calculate = function(_, card, context)
        return (context.repetition and is_frozen(context.other_card)) and {repetitions = 1} or SMODS.merge_effects(
            f(G.jokers.cards):where(is_frozen):map(function(v)
                return SMODS.blueprint_effect(card, v, context) or true
            end):where(function(v)
                return type(v) == "table"
            end):map(function(v)
                v.colour = G.C.BLACK
                return v
            end):table()
        )
    end,
}
