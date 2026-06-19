local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

local function bans()
    return {banned_cards = {}, banned_tags = {}, banned_other = {}}
end

local function adder(tbl)
    return function(v)
        table.insert(tbl, {id = v.key, type = "blind"})
    end
end

local function is_banned_from_pastry(v)
    return not ({Bakery = true, Roland = true})[(v.mod or {}).id]
end

local function is_center_banned_from_pastry(v)
    local arcana_boosters = {
        p_arcana_normal_1 = true,
        p_arcana_normal_2 = true,
        p_arcana_normal_3 = true,
        p_arcana_normal_4 = true,
        p_arcana_jumbo_1 = true,
        p_arcana_jumbo_2 = true,
        p_arcana_mega_1 = true,
        p_arcana_mega_2 = true,
    }

    local pastries_targets = {Enhanced = true, Joker = true, Tarot = true, Spectral = true}
    return arcana_boosters[v.key] or pastries_targets[v.set] and is_banned_from_pastry(v)
end

local function is_showdown_except(key)
    ---@param v SMODS.Blind
    ---@param k string
    ---@return boolean?
    return function(v, k)
        return v.boss and v.boss.showdown and key ~= k
    end
end

local pastries, amber, cerulean, crimson, verdant, violet =
    bans(), bans(), bans(), bans(), bans(), bans()

SMODS.Challenge {
    key = "Glass",
    rules = {custom = {{id = "Roland_Glass1"}, {id = "Roland_Glass2"}}},
    pronouns = "they_them",
    config = {extra = {odds = 2}},
    calculate = function(self, context)
        if not context.after or context.blueprint_card then
            return
        end

        f(G.play.cards):where(function(v)
            return not v:get_seal(true) and
                SMODS.pseudorandom_probability(self, self.key, 1, self.config.extra.odds, self.key)
        end):each(function(v)
            v:set_seal "Roland_glass"
        end)
    end,
}

SMODS.Challenge {
    key = "Go",
    rules = {custom = {{id = "Roland_Go"}}},
    jokers = {{id = "j_credit_card"}},
    pronouns = "he_him",
    calculate = function(self, context)
        if context.starting_shop then
            ease_dollars(-G.GAME.dollars)

            attention_text {
                text = localize "k_nope_ex",
                backdrop_colour = G.C.MONEY,
                offset = {x = 0, y = 0},
                silent = true,
                major = self,
                align = "cm",
                scale = 1.3,
                hold = 1.4,
            }
        end
    end,
}

local spin_to_win = SMODS.Challenge {
    key = "Spin_To_Win",
    jokers = f(4):map(f.const {id = "j_joker", eternal = true}):table(),
    restrictions = {banned_cards = {{id = "c_Roland_coolheaded"}}},
    pronouns = "they_them",
    apply = function(self)
        self.rotation = 0
    end,
    calculate = function(self, context)
        if not context.card_added or context.card.config.center.key ~= "j_Bakery_Spinner" then
            return
        end

        context.card.ability.extra.rotation = self.rotation
        self.rotation = self.rotation + 1
    end,
    rotation = 0,
}

SMODS.Challenge {
    key = "Pastries",
    rules = {custom = {{id = "Roland_Pastries"}}},
    restrictions = pastries,
    pronouns = "she_them",
}

SMODS.Challenge {
    key = "Eternally_Amber",
    rules = {custom = {{id = "Roland_Eternally_Amber"}, {id = "Roland_Showdown_Amber"}}},
    jokers = {{id = "j_Roland_amber"}},
    restrictions = amber,
    pronouns = "they_them",
    calculate = function(_, context)
        local function slide(pitch)
            q(function()
                G.jokers:shuffle "Roland_aajk"
                play_sound("cardSlide1", pitch)
            end)
        end

        if not context.setting_blind then
            return
        end

        G.jokers:unhighlight_all()

        f(G.jokers.cards):each(function(v)
            v:flip()
        end)

        local _ = #G.jokers.cards > 1 and q {
            trigger = "after",
            delay = 0.2,
            func = function()
                slide(0.85)
                delay(0.15)
                slide(1.15)
                delay(0.15)
                slide(1)
                delay(0.5)
            end,
        }
    end,
}

SMODS.Challenge {
    key = "Eternally_Cerulean",
    rules = {custom = {{id = "Roland_Eternally_Cerulean"}, {id = "Roland_Showdown_Cerulean"}}},
    jokers = {{id = "j_Roland_cerulean"}},
    restrictions = cerulean,
    pronouns = "she_her",
    calculate = function(_, context)
        if not context.hand_drawn then
            return
        end

        ---@type SMODS.Blind|{name: string}
        local blind = G.GAME.blind
        local copy = f(G.hand.cards):table()
        pseudoshuffle(copy, pseudoseed "Roland_cerulean_bell")
        G.hand:unhighlight_all()

        local count = (blind.name == "Cerulean Bell" and 2 or 1) -
            f(G.hand.cards):map "ability":count "forced_selection"

        f(copy):take(count):each(function(v)
            v.ability.forced_selection = true
            G.hand:add_to_highlighted(v)
        end)
    end,
}

SMODS.Challenge {
    key = "Eternally_Crimson",
    rules = {custom = {{id = "Roland_Eternally_Crimson"}, {id = "Roland_Showdown_Crimson"}}},
    jokers = {{id = "j_Roland_crimson"}},
    restrictions = crimson,
    pronouns = "she_her",
    calculate = function(_, context)
        local _ = context.blind_defeated and f(G.jokers.cards):each(function(v)
            v.ability.Roland_crimson_heart_chosen = nil
        end)

        local mod = G.GAME.modifiers
        mod.Roland_Eternally_Crimson = not context.setting_blind and mod.Roland_Eternally_Crimson or nil
        local debuff = context.debuff_card
        local cards = G.jokers.cards

        if debuff and
            debuff.ability and
            debuff.area == G.jokers and
            debuff.ability.Roland_crimson_heart_chosen then
            return {debuff = true}
        end

        if context.press_play and next(cards) then
            mod.Roland_Eternally_Crimson = true
        end

        if context.hand_drawn and
            mod.Roland_Eternally_Crimson and
            next(cards) then
            local prev = {}
            local jokers = {}

            f(cards):where(function(v)
                return (v.ability or {}).Roland_crimson_heart_chosen
            end):each(function(v)
                prev[v] = true
                v.ability.Roland_crimson_heart_chosen = nil
                local _ = v.debuff and SMODS.recalc_debuff(v)
            end)

            jokers = next(jokers) and jokers or f(cards):where("debuff", false):map(function(v)
                local _ = not prev[v] and table.insert(jokers, v)
                return v
            end):table()

            local card = pseudorandom_element(jokers, pseudoseed "Roland_crimson_heart")

            if card then
                card.ability.Roland_crimson_heart_chosen = true
                SMODS.recalc_debuff(card)
                card:juice_up()
            end
        end

        mod.Roland_Eternally_Crimson = not context.hand_drawn and
            mod.Roland_Eternally_Crimson or nil
    end,
}

SMODS.Challenge {
    key = "Eternally_Verdant",
    rules = {custom = {{id = "Roland_Eternally_Verdant"}, {id = "Roland_Showdown_Verdant"}}},
    jokers = {{id = "j_Roland_verdant"}},
    restrictions = verdant,
    pronouns = "she_her",
    calculate = function(_, context)
        if context.setting_blind then
            G.GAME.modifiers.Roland_Eternally_Verdant = true
        end

        if context.debuff_card and context.debuff_card.area ~= G.jokers then
            return {debuff = G.GAME.modifiers.Roland_Eternally_Verdant}
        end

        if context.selling_card and context.card.ability.set == "Joker" then
            q(function()
                G.GAME.modifiers.Roland_Eternally_Verdant = nil
            end)
        end
    end,
}

SMODS.Challenge {
    key = "Eternally_Violet",
    rules = {custom = {{id = "Roland_Eternally_Violet"}, {id = "Roland_Showdown_Violet"}}},
    jokers = {{id = "j_Roland_violet"}},
    restrictions = violet,
    pronouns = "she_they",
    calculate = function(_, context)
        if not context.setting_blind then
            return
        end

        local mult = G.GAME.blind.mult < 6 and G.GAME.blind.mult or 1
        G.GAME.blind.chips = G.GAME.blind.chips * 6 / mult
        G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
    end,
}

q(function()
    f {
        {G.P_TAGS,    is_banned_from_pastry,                pastries.banned_tags},
        {G.P_BLINDS,  is_banned_from_pastry,                pastries.banned_other},
        {G.P_CENTERS, is_center_banned_from_pastry,         pastries.banned_cards},
        {G.P_BLINDS,  is_showdown_except "bl_final_acorn",  amber.banned_other},
        {G.P_BLINDS,  is_showdown_except "bl_final_bell",   cerulean.banned_other},
        {G.P_BLINDS,  is_showdown_except "bl_final_heart",  crimson.banned_other},
        {G.P_BLINDS,  is_showdown_except "bl_final_leaf",   verdant.banned_other},
        {G.P_BLINDS,  is_showdown_except "bl_final_vessel", violet.banned_other},
    }:each(function(v)
        f(v[1]):where(v[2]):each(adder(v[3]))
    end)
end)

q(function()
    if not G.P_CENTERS.j_Bakery_Spinner then
        return true
    end

    f(spin_to_win.jokers):each(function(v)
        v.id = "j_Bakery_Spinner"
    end)
end)
