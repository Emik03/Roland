local f, q = unpack(... or require "src.functional")

SMODS.Atlas {
    px = 34,
    py = 34,
    frames = 21,
    key = "blind",
    path = "blind.png",
    atlas_table = "ANIMATION_ATLAS",
}

local function common_rank()
    local tally = {}
    local to_name = {}

    --- Tallies up a card area's cards.
    ---@param card_area CardArea
    local function tally_up(card_area)
        f(card_area.cards):filter(function(v)
            return not SMODS.has_no_rank(v)
        end):foreach(function(v)
            local id = v:get_id()
            to_name[id] = v.base.value
            tally[id] = (tally[id] or 0) + 1
        end)
    end

    tally_up(G.deck)
    tally_up(G.hand)
    tally_up(G.discard)

    local max_key = f(tally):reduce({-1 / 0, -1 / 0}, function(a, v, k)
        if v > a[1] or k > a[2] and v == a[1] then
            return {v, k}
        end

        return a
    end)[2]

    return max_key, to_name[max_key]
end

local function disable_improbable()
    G.GAME.modifiers.Roland_improbable = nil
    local orig = (getmetatable(G.GAME.probabilities) or {}).orig

    if orig then
        G.GAME.probabilities = orig
    end
end

local function is_locked()
    return G.STATE ~= G.STATES.SELECTING_HAND or G.CONTROLLER.locked or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)
end

if cry_prob then
    local orig_prob = cry_prob

    ---@diagnostic disable-next-line: lowercase-global
    cry_prob = function(owned, den, rigged)
        return G.GAME.modifiers.Roland_improbable and 0 or orig_prob(owned, den, rigged)
    end
end

local orig_update = Game.update

---@diagnostic disable-next-line: duplicate-set-field
function Game:update(dt)
    orig_update(self, dt)
    local orig = G.GAME.probabilities

    if not G.GAME.modifiers.Roland_improbable or getmetatable(orig) then
        return
    end

    local normal = orig.normal

    local mt = {
        orig = orig,
        __index = function(_, k)
            return k == "normal" and 0 or orig[k]
        end,
        __newindex = function(_, k, v)
            orig[k] = (k == "normal" and v == 0) and normal or v
        end,
    }

    local proxy = {}
    setmetatable(proxy, mt)
    G.GAME.probabilities = proxy
end

SMODS.Blind {
    key = "improbable",
    boss = {min = 2, max = 10},
    boss_colour = HEX("009966"),
    atlas = "blind",
    pos = {x = 0, y = 0},
    pronouns = "it_its",
    mult = 2,
    dollars = 5,
    defeat = disable_improbable,
    disable = disable_improbable,
    set_blind = function(_)
        G.GAME.modifiers.Roland_improbable = true
    end,
}

SMODS.Blind {
    key = "nimble",
    boss = {min = 1, max = 10},
    boss_colour = HEX("0291fb"),
    atlas = "blind",
    pos = {x = 0, y = 1},
    pronouns = "she_her",
    mult = 2,
    dollars = 5,
    config = {draw = 5},
    defeat = function(self)
        self.disabled = false
    end,
    disable = function(self)
        self.disabled = true
    end,
    drawn_to_hand = function(self)
        local function force_hand()
            if is_locked() then
                return false
            end

            f(G.hand.cards, ipairs):take(self.config.draw):foreach(function(v)
                G.hand:add_to_highlighted(v, true)
            end)

            G.FUNCS.play_cards_from_highlighted(nil)
        end

        if not self.disabled then
            self.disabled = true
            q {func = force_hand, blocking = false}
        end
    end,
    set_blind = function(self)
        self.disabled = false
    end,
}

SMODS.Blind {
    key = "divide",
    boss = {min = 4, max = 10},
    boss_colour = HEX("0291fb"),
    atlas = "blind",
    pos = {x = 0, y = 1},
    pronouns = "they_them",
    mult = 2,
    dollars = 5,
    disable = function()
        local function disable()
            local count = #G.discard.cards

            f(G.discard.cards):take(count):foreach(function(v, i)
                draw_card(G.discard, G.hand, i / count * 100, "up", false, v, nil, nil, true)
            end)

            f(G.discard.cards):take(count):foreach(function(v, i)
                draw_card(G.hand, G.deck, i / count * 100, "up", false, v)
            end)
        end

        q(disable)
    end,
    set_blind = function()
        local function force_hand()
            local length = (#G.deck.cards - 2) / 2

            for i = 0, length do
                local card = G.deck.cards[#G.deck.cards - i]
                draw_card(G.deck, G.hand, i / length * 100, "down", false, card, nil, nil, true)
            end

            for i = 0, length do
                local card = G.deck.cards[#G.deck.cards - i]
                draw_card(G.hand, G.discard, i / length * 100, "down", false, card, nil, nil, true)
            end
        end

        -- Allows the background to ease in first before drawing cards.
        q(force_hand)
    end,
}

SMODS.Blind {
    key = "tranquilizer",
    boss = {min = 4, max = 10},
    boss_colour = HEX("0291fb"),
    atlas = "blind",
    pos = {x = 0, y = 1},
    pronouns = "they_them",
    mult = 2,
    dollars = 5,
    collection_loc_vars = function(_)
        return {
            vars = {localize {
                type = "variable", key = "b_Roland_most_common_card",
            }},
        }
    end,
    loc_vars = function(_)
        local _, name = common_rank()
        return {vars = {localize(name or "Ace", "ranks")}}
    end,
    disable = function(self)
        self.disabled = true
    end,
    calculate = function(self, _, context)
        if not context.card_added and
            not context.drawing_cards and
            not context.playing_card_added and
            not context.pre_discard and
            not context.press_play then
            return
        end

        local needs_text_change = false

        local function process(card_area)
            f(card_area.cards):foreach(function(v)
                local debuff = v.debuff
                v:set_debuff(self:recalc_debuff(v, false))
                needs_text_change = needs_text_change or debuff ~= v.debuff
            end)
        end

        process(G.deck)
        process(G.hand)
        process(G.discard)

        if needs_text_change then
            G.GAME.blind:wiggle()
            G.GAME.blind:set_text()
        end
    end,
    recalc_debuff = function(self, card)
        local id, _ = common_rank()
        return not self.disabled and id == card:get_id()
    end,
}

SMODS.Blind {
    key = "xerox",
    boss = {min = 2, max = 10},
    boss_colour = HEX("0291fb"),
    atlas = "blind",
    pos = {x = 0, y = 1},
    pronouns = "they_them",
    mult = 2,
    dollars = 5,
    disable = function(self)
        self.disabled = true
    end,
    calculate = function(_, blind, context)
        if blind.disabled or not context.pre_discard then
            return
        end

        local cards_added = {}
        local count = #G.hand.highlighted

        f(G.hand.highlighted, ipairs):take(count):foreach(function(v, i)
            local copy = copy_card(G.hand.highlighted[i])
            copy:add_to_deck()
            table.insert(G.hand, copy)
            table.insert(cards_added, copy)
            table.insert(G.playing_cards, copy)
            draw_card(G.hand, G.discard, i / count * 100, "down", false, copy, nil, nil, true)
        end)

        playing_card_joker_effects(cards_added)
    end,
}
