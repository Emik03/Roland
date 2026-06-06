local f, q = unpack(... or require "lib.shared")

local negative = {key = "e_negative_consumable", set = "Edition", config = {extra = 1}}

local joker = (function()
    local z = 0

    ---@return {x: number, y: number}
    local function inc()
        local ret = {x = z % 6, y = math.floor(z / 6)}
        z = z + 1
        return ret
    end

    ---@param tbl SMODS.Joker|{artist?: string, Bakery_can_use: (fun(self: self, card: Card): boolean?), Bakery_use_button_text: (fun(self: self, card: Card): string|table|nil), Bakery_use_joker: fun(self: self, card: Card), sinis?: boolean|{x: number, y: number}, soul_pos?: boolean|{x: number, y: number}, attributes?: Attributes[]}
    return function(tbl)
        tbl.pos = inc()
        tbl.atlas = "joker"
        tbl.artist = tbl.artist and "Roland_" .. tbl.artist or nil
        tbl.soul_pos = tbl.soul_pos and inc() or nil
        tbl.sinis = tbl.sinis and inc() or nil

        if ((tbl.config or {}).extra or {}).flipped ~= nil then
            tbl.config.extra.front_pos = tbl.pos
            tbl.config.extra.back_pos = inc()
        end

        local joker = SMODS.Joker(tbl)

        q(function()
            Bakery_API.credit(joker)
        end)
    end
end)()

---@param card Card
local function is_frozen(card)
    return card.edition and card.edition.key == "e_Roland_frozen"
end

---@param card? Card|false|{suit: string, value: string}
---@param fallback? string
---@return {vars: {[number]: string|table|nil}|{colours: {[number]: {[1]: number, [2]: number, [3]: number, [4]: number}}}}
local function localize_card(card, fallback)
    if not card then
        return {
            vars = {
                "",
                localize {type = "variable", key = fallback or "b_Roland_na"},
                "",
                colours = {G.C.JOKER_GREY, G.C.JOKER_GREY},
            },
        }
    end

    local suit = (card.base or card).suit
    local value = (card.base or card).value
    local name = (card.ability or card).name or ""
    local no_suit = card.base and SMODS.has_no_suit(card) or not suit
    local no_rank = card.base and SMODS.has_no_rank(card) or not value

    return {
        vars = {
            (value and not no_rank) and localize(value or 14, "ranks") or name,
            (not no_rank and not no_suit) and localize {type = "variable", key = "b_Roland_of"} or "",
            no_suit and "" or localize(suit, "suits_plural"),
            colours = {G.C.IMPORTANT, G.C.SUITS[suit] or G.C.JOKER_GREY},
        },
    }
end

---@param card Card
---@return boolean
local function has_rank_and_suit(card)
    return not SMODS.has_no_rank(card) and not SMODS.has_no_suit(card)
end

---@param value table
---@return fun(other: table): boolean
local function ranksuitnq(value)
    return function(other)
        local v, o = value.base or value, other.base or other
        return value == other or v.suit ~= o.suit or v.value ~= o.value
    end
end

SMODS.Atlas {
    key = "joker",
    path = "joker.png",
    px = 71,
    py = 95,
}

SMODS.Sound {
    key = "nilly",
    path = "nilly.ogg",
}

joker {
    key = "msjoker",
    pronouns = "she_her",
    cost = 1,
    rarity = 1,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    config = {extra = {chips = 30}},
    attributes = {"chips"},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.chips}}
    end,
    calculate = function(_, card, context)
        return (context.joker_main or context.forcetrigger) and
            {card = card, chips = card.ability.extra.chips} or nil
    end,
}

joker {
    key = "jokersr",
    pronouns = "he_him",
    config = {extra = {xmult = 1.25}},
    attributes = {"xmult"},
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
    key = "mrsbones",
    pronouns = "she_her",
    artist = "char",
    config = {extra = {xmult = 4, requirement = 4}},
    attributes = {"xmult"},
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
            return {card = card, xmult = card.ability.extra.xmult}
        end

        if not card.getting_sliced and
            context.end_of_round and
            G.GAME.chips / card.ability.extra.requirement < G.GAME.blind.chips then
            card.getting_sliced = true
            local message = localize {type = "variable", key = "b_Roland_bye"}
            SMODS.calculate_effect({message = message, colour = G.C.RED, message_card = card}, card)

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
    key = "sunny",
    pronouns = "it_its",
    artist = "char",
    attributes = {"food", "on_sell"},
    cost = 2,
    rarity = 1,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        return localize_card(card.area == G.jokers and ((G.deck or {}).cards or {})[1])
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
    pronouns = "it_its",
    attributes = {"food", "editions", "modify_card", "on_sell"},
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
    attributes = {"food", "generation", "on_sell"},
    cost = 8,
    rarity = 3,
    eternal_compat = false,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, negative)
    end,
    calculate = function(_, _, context)
        return (context.selling_self or context.forcetrigger) and f(G.consumeables.cards):where(function(v)
            return v.config.center.set ~= "Joker"
        end):each(function(v)
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
    key = "monomino",
    pronouns = "it_its",
    artist = "char",
    config = {extra = {price = 4, hand_name = "Four of a Kind"}},
    attributes = {"sell_value", "scaling", "economy", "hand_type"},
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
        return {message = localize "k_val_up", colour = G.C.MONEY, message_card = card}
    end,
}

joker {
    key = "domino",
    pronouns = "it_its",
    artist = "char",
    config = {extra = {mult_gain = 4, hand_name = "Four of a Kind", mult = 0}},
    attributes = {"mult", "scaling", "hand_type"},
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
            return {card = card, mult = extra.mult}
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
    attributes = {"generation", "hand_type"},
    cost = 8,
    rarity = 3,
    eternal_compat = false,
    blueprint_compat = false,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local extra = card.ability.extra
        return {vars = {extra.times, localize(extra.hand_name, "poker_hands")}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if (not context.before or
                context.blueprint or
                card.getting_sliced or
                context.scoring_name ~= extra.hand_name) and
            not context.forcetrigger then
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

            f(extra.times):each(function()
                G.playing_card = (G.playing_card or 0) + 1
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                local chosen = pseudorandom_element(scored_cards, pseudoseed "Roland_trimino")
                local copy = copy_card(chosen, nil, nil, G.playing_card)
                copy:add_to_deck()
                G.hand:emplace(copy)
                copy:start_materialize()
                table.insert(copied, copy)
                table.insert(G.playing_cards, copy)
            end)

            SMODS.calculate_effect({{message = localize "k_copied_ex", message_card = card}}, card)
            playing_card_joker_effects(copied)

            if not context.forcetrigger then
                card:start_dissolve()
            end
        end)
    end,
}

joker {
    key = "cold",
    pronouns = "he_him",
    config = {extra = {xmult = 2}},
    attributes = {"xmult"},
    cost = 4,
    rarity = 1,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(_, card, context)
        local target = (context.scoring_hand or {})[3]

        return (context.individual and
                context.cardarea == G.play and
                context.other_card == target and
                is_frozen(context.other_card) or
                context.forcetrigger) and
            {xmult = card.ability.extra.xmult} or nil
    end,
}

joker {
    key = "snowsquall",
    pronouns = "he_they",
    config = {extra = {mult_gain = 1, mult = 0}},
    attributes = {"mult", "scaling", "hand_type"},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = false,
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
        local extra = card.ability.extra
        return {vars = {extra.mult_gain, extra.mult}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if context.joker_main or context.forcetrigger then
            return {card = card, mult = extra.mult}
        end

        if context.blueprint or
            not context.individual or
            context.cardarea ~= G.play or
            not is_frozen(context.other_card) then
            return
        end

        extra.mult = extra.mult + extra.mult_gain
        return {message = localize "k_upgrade_ex", colour = G.C.RED, message_card = card}
    end,
}

joker {
    key = "arctic",
    pronouns = "they_them",
    cost = 10,
    rarity = 3,
    config = {extra = {frozen = 1, non_frozen = 0, max_stack = 6, color = "DARK_EDITION"}},
    attributes = {"retrigger", "editions"},
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if extra.max_stack and
            context.blueprint_copiers_stack and
            extra.max_stack < #context.blueprint_copiers_stack then
            return
        end

        if context.repetition and context.other_card then
            local repetitions = is_frozen(context.other_card) and extra.frozen or extra.non_frozen

            if repetitions and repetitions > 0 then
                return {card = card, colour = G.C[extra.color], repetitions = repetitions}
            end
        end

        local key = card.config.center.key

        local merged = SMODS.merge_effects(
            f(G.jokers.cards):where(is_frozen):where(function(v)
                return v.config.center.key ~= key
            end):map(function(v)
                return SMODS.blueprint_effect(card, v, context)
            end):where(type, "table"):map(function(v)
                v.colour = G.C[extra.color]
                return v
            end):values():table()
        )

        return merged
    end,
}

joker {
    key = "sapling",
    pronouns = "they_them",
    artist = "char",
    attributes = {"mult", "suit"},
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
            return {card = card, mult = extra.mult}
        end
    end,
}

joker {
    key = "yard",
    pronouns = "he_him",
    config = {extra = {money = 2}},
    attributes = {"economy"},
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
    key = "misfortune",
    pronouns = "she_they",
    artist = "char",
    attributes = {"discard", "generation", "seals"},
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
    key = "bulldozer",
    pronouns = "she_her",
    attributes = {"xmult"},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(self, _, card)
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
    key = "phytoestrogens",
    pronouns = "she_her",
    config = {extra = {xmult = 0.3}},
    attributes = {"mult", "xmult"},
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
    key = "nilly",
    pronouns = "any_all",
    config = {extra = {flipped = false}},
    attributes = {"xmult", "bakery_double_sided"},
    cost = 0,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local key = card.ability.extra.flipped and "b_Roland_enabled" or "b_Roland_disabled"
        return {vars = {localize {type = "variable", key = key}}}
    end,
    calculate = function(_, card, context)
        if (not context.joker_main or not card.ability.extra.flipped) and not context.forcetrigger then
            return
        end

        mult = mod_mult(0)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        return {sound = "Roland_nilly", message = "0X " .. localize "k_mult", colour = G.C.MULT, message_card = card}
    end,
    Bakery_can_use = function(_, card)
        return not card.debuff
    end,
    Bakery_use_button_text = function(_, card)
        return localize {type = "variable", key = card.debuff and "b_Roland_debuffed" or "b_Roland_toggle"}
    end,
    Bakery_use_joker = function(_, card)
        local _ = card.debuff or Bakery_API.flip_double_sided(card)
    end,
}

joker {
    key = "amber",
    pronouns = "they_them",
    config = {extra = {xmult = 3}},
    pixel_size = {w = 68, h = 68},
    attributes = {"xmult"},
    cost = 6,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = false,
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.xmult}}
    end,
    calculate = function(_, card, context)
        if context.joker_main or context.forcetrigger then
            return {card = card, xmult = card.ability.extra.xmult}
        end

        card.Roland_amber_waiting = card.Roland_amber_waiting and not context.after

        local no = card.debuff or
            context.blueprint or
            card.Roland_amber_waiting or
            not context.press_play

        if no and not context.forcetrigger then
            return
        end

        card.Roland_amber_waiting = true
        local cards = card.area.cards
        local keys = f(cards):where(f().nq(card)):keys():table()

        if not next(keys) then
            return
        end

        local key = pseudorandom_element(keys, pseudoseed "Roland_amber") or card.rank
        local next = card.rank < key and 1 or -1

        for i = card.rank, key - next, next do
            cards[i], cards[i + next] = cards[i + next], cards[i]
        end
    end,
}

joker {
    key = "martingale",
    pronouns = "he_him",
    config = {extra = {odds = 2}},
    attributes = {"xmult", "chance"},
    cost = 8,
    rarity = 2,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(_, _, card)
        local odds   = card.ability.extra.odds
        local normal = SMODS.get_probability_vars(card, 1, odds, "RolandMartingaleLoc")
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

        if G.GAME.blind.name == "bl_mp_nemesis" then
            return {card = card, xmult = extra.odds}
        end

        for _ = 1, 256 do
            local key = "RolandMartingale" .. tostring(G.GAME.modifiers.Roland_martingale_seed or "")

            if SMODS.pseudorandom_probability(card, self.key, 1, extra.odds, key) then
                break
            end

            local other_key = "RolandMartingaleNumerator"
            numerator = numerator * (extra.odds - SMODS.get_probability_vars(card, 1, extra.odds, other_key))
            xmult = xmult * extra.odds
            local message = number_format(numerator) .. "/" .. number_format(xmult)
            SMODS.calculate_effect({card = card, repetitions = 1, message = message, message_card = card}, card)
        end

        SMODS.calculate_effect({card = card, xmult = xmult}, card)
    end,
}

joker {
    key = "idle",
    pronouns = "any_all",
    rarity = 2,
    Roland_idle_capacity = 6,
    cost = G.P_CENTERS.j_idol.cost,
    config = {extra = {cards = {}, xmult = 2}},
    attributes = {"rank", "suit", "xmult"},
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = true,
    loc_vars = function(self, _, card)
        local extra = card.ability.extra
        local col = {}

        ---@type { [number]: string|table|nil }|{colours: {[number]: {[1]: number, [2]: number, [3]: number, [4]: number}}}
        local vars = f(self.Roland_idle_capacity):flatmap(function(v)
            local l = localize_card(extra.cards[v], "b_Roland_unassigned").vars

            f(l.colours):each(function(c)
                col[#col + 1] = c
            end)

            l.colours = nil
            return l
        end):values():table()

        table.insert(vars, extra.xmult)
        vars.colours = col
        return {vars = vars}
    end,
    calculate = function(_, card, context)
        return context.forcetrigger or
            context.individual and
            context.cardarea == G.play and
            f(card.ability.extra.cards or {}):map(function(v)
                return f(context.scoring_hand):any(function(x)
                    return x:is_suit(v.suit) and x.base.value == v.value
                end) or {}
            end):any(f().eq(context.other_card)) and {xmult = card.ability.extra.xmult} or nil
    end,
    Bakery_can_use = function(self, card)
        local key = self:Roland_idle_status(card)
        local new_cards = G.hand.highlighted
        local extra = card.ability.extra

        if extra.last_text ~= key then
            extra.last_text = key
            Bakery_API.rehighlight(card)
        end

        local function all_cards()
            return f(new_cards):concat(extra.cards or {})
        end

        return not card.debuff and
            next(new_cards) and
            self.Roland_idle_capacity - #extra.cards - #new_cards >= 0 and
            f(new_cards):all(has_rank_and_suit) and
            all_cards():all(function(v)
                return all_cards():all(ranksuitnq(v))
            end)
    end,
    Bakery_use_button_text = function(self, card)
        return localize {type = "variable", key = self:Roland_idle_status(card)}
    end,
    Bakery_use_joker = function(_, card)
        f(G.hand.highlighted):each(function(v)
            table.insert(card.ability.extra.cards, {suit = v.base.suit, value = v.base.value})
        end)
    end,
    Roland_idle_status = function(self, card)
        return card.debuff and "b_Roland_debuffed" or
            (self.Roland_idle_capacity - #card.ability.extra.cards > 0 and "b_Roland_add" or "b_Roland_full")
    end,
}

joker {
    key = "suitable",
    pronouns = "she_they",
    attributes = {"suit", "passive", "hearts", "diamonds", "spades", "clubs"},
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
    add_to_deck = function()
        G.GAME.modifiers.Roland_suitable = (G.GAME.modifiers.Roland_suitable or 0) + 1
    end,
    remove_from_deck = function()
        G.GAME.modifiers.Roland_suitable = (G.GAME.modifiers.Roland_suitable or 0) - 1
    end,
}

function SMODS.current_mod.reset_game_globals()
    local immutable = f(SMODS.find_card "j_Roland_suitable"):any(is_frozen)
    local suitable = {suit = "Spades"}

    G.GAME.current_round.Roland_suitable = immutable and
        G.GAME.current_round.Roland_suitable or suitable

    if immutable then
        return
    end

    local suits = f(G.playing_cards):where(SMODS.has_no_suit, false):table()
    local card = pseudorandom_element(suits, "Roland_suitable" .. G.GAME.round_resets.ante)
    suitable.suit = card and card.base.suit or suitable.suit
end

local orig_get_enhancements = SMODS.get_enhancements

function SMODS.get_enhancements(card, ...)
    if (G.GAME.modifiers.Roland_suitable or 0) <= 0 or
        card.base.suit ~= G.GAME.current_round.Roland_suitable.suit or
        (card.area ~= G.hand and card.area ~= G.play) then
        return orig_get_enhancements(card, ...)
    end

    local ret = orig_get_enhancements(card, ...) or {}
    ret.m_wild = true
    return ret
end

joker {
    key = "artemis",
    pronouns = "any_all",
    cost = 6,
    rarity = 2,
    config = {extra = {
        dollars = 3,
        increase = 4,
        progress = 0,
        flipped = false,
        sequence = {"c_earth", "c_mars", "c_earth"},
    }},
    attributes = {"economy", "scaling", "planet", "space", "bakery_double_sided"},
    eternal_compat = true,
    blueprint_compat = false,
    perishable_compat = false,
    calc_dollar_bonus = function(_, card)
        return card.ability.extra.dollars
    end,
    loc_vars = function(_, info_queue, card)
        local extra = card.ability.extra

        local function color(i)
            return i == extra.progress + 1 and (i == 2 and G.C.ORANGE or G.C.BLUE) or G.C.JOKER_GREY
        end

        f(extra.sequence):each(function(v)
            table.insert(info_queue, G.P_CENTERS[v])
        end)

        return {vars = {extra.dollars, extra.increase, colours = f(#extra.sequence):map(color):table()}}
    end,
    calculate = function(_, card, context)
        local extra = card.ability.extra

        if context.blueprint or
            not context.using_consumeable or
            context.consumeable.config.center.key ~= extra.sequence[extra.progress + 1] then
            return
        end

        extra.progress = extra.progress + 1
        _ = (extra.progress == 1) ~= extra.flipped and Bakery_API.flip_double_sided(card)

        if extra.sequence[extra.progress + 1] then
            return {
                message = localize "k_progress",
                colour = extra.progress == 2 and G.C.ORANGE or G.C.BLUE,
                message_card = card,
            }
        end

        extra.progress = 0
        extra.dollars = extra.dollars + extra.increase

        return {
            message = localize "k_upgrade_ex",
            colour = G.C.MONEY,
            message_card = card,
        }
    end,
}

joker {
    key = "oops",
    pronouns = "she_they",
    artist = "char",
    cost = 7,
    rarity = 3,
    config = {extra = {probability = 1, probability_mult = 2, reset = 1}},
    attributes = {"hands", "mod_chance", "scaling", "reset"},
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
            return {card = card, numerator = extra.probability}
        end

        if context.end_of_round and extra.probability ~= extra.reset then
            extra.probability = extra.reset
            return {message = localize "k_reset", colour = G.C.RED, message_card = card}
        end

        if context.after then
            extra.probability = extra.probability * extra.probability_mult
            return {message = localize "k_upgrade_ex", colour = G.C.GREEN, message_card = card}
        end
    end,
}
