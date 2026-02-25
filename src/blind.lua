local f, q = unpack(... or require "lib.shared")

local blind = (function()
    local y = 0

    ---@param tbl SMODS.Blind
    ---@return SMODS.Blind
    return function(tbl)
        tbl.pos = {x = 0, y = y}
        tbl.atlas = "blind"
        local ret = SMODS.Blind(tbl)
        y = y + 1
        return ret
    end
end)()

SMODS.Atlas {
    px = 34,
    py = 34,
    frames = 21,
    key = "blind",
    path = "blind.png",
    atlas_table = "ANIMATION_ATLAS",
}

SMODS.Sound {
    key = "kick",
    path = "kick.ogg",
}

local function common_rank()
    local tally = {}
    local to_name = {}

    --- Tallies up a card area's cards.
    ---@param card_area CardArea
    local function tally_up(card_area)
        f(card_area.cards):where(function(v)
            return not SMODS.has_no_rank(v)
        end):each(function(v)
            local id = v:get_id()
            to_name[id] = v.base.value
            tally[id] = (tally[id] or 0) + 1
        end)
    end

    tally_up(G.deck)
    tally_up(G.hand)
    tally_up(G.discard)

    local max_key = f(tally):fold({-1 / 0, -1 / 0}, function(a, v, k)
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

local function has_enhancement(card)
    local e = SMODS.get_enhancements(card)
    return not not (e and next(e))
end

local function hsv_to_rgb(h, s, v)
    s, v = s or 1, v or 1

    if s <= 0 then
        return v, v, v
    end

    local c = v * s
    local r, g, b = 0, 0, 0
    local x, m = (1 - math.abs((h * 6 % 2) - 1)) * c, v - c

    if h < 1 / 6 then
        r, g, b = c, x, 0
    elseif h < 2 / 6 then
        r, g, b = x, c, 0
    elseif h < 3 / 6 then
        r, g, b = 0, c, x
    elseif h < 4 / 6 then
        r, g, b = 0, x, c
    elseif h < 5 / 6 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end

    return r + m, g + m, b + m
end

local function is_locked()
    return G.STATE ~= G.STATES.SELECTING_HAND or G.CONTROLLER.locked or
        (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)
end

blind {
    key = "nimble",
    boss = {min = 1},
    boss_colour = HEX "0291fbff",
    pronouns = "she_her",
    config = {draw = 5},
    defeat = function()
        G.GAME.Roland_nimble_disabled = nil
    end,
    disable = function()
        G.GAME.Roland_nimble_disabled = true
    end,
    drawn_to_hand = function(self)
        local function force_hand()
            if is_locked() then
                return false
            end

            f(G.hand.cards, ipairs):take(self.config.draw):each(function(v)
                G.hand:add_to_highlighted(v, true)
            end)

            G.FUNCS.play_cards_from_highlighted(nil)
            self:disable()
        end

        if not G.GAME.Roland_nimble_disabled then
            G.GAME.Roland_nimble_disabled = true
            q {func = force_hand, blocking = false}
        end
    end,
    set_blind = function()
        G.GAME.Roland_nimble_disabled = nil
    end,
}

blind {
    key = "falseshuffle",
    boss = {min = 3},
    boss_colour = HEX "ff7f3dff",
    pronouns = "any_all",
    disable = function()
        q(function()
            f(G.hand.cards):each(function(v, i)
                draw_card(G.hand, G.deck, i / #G.hand.cards * 100, "up", false, v)
            end)
        end)

        q(function()
            pseudoshuffle(G.deck.cards, pseudoseed "RolandFalseShuffle")
        end)
    end,
    calculate = function(_, b, context)
        if b.disabled or not context.drawing_cards then
            return
        end

        b:wiggle()

        table.sort(
            G.deck.cards,
            function(v1, v2)
                return has_enhancement(v1) and not has_enhancement(v2)
            end
        )
    end,
    in_pool = function()
        return G.playing_cards and f(G.playing_cards):any(has_enhancement)
    end,
}

blind {
    key = "divide",
    boss = {min = 1},
    boss_colour = HEX "b18480ff",
    pronouns = "he_they",
    disable = function()
        -- Ensures that this runs after 'set_blind' since it also gets added to queue.
        q {
            delay = 0.8,
            trigger = "after",
            func = function()
                G.FUNCS.draw_from_discard_to_deck()
            end,
        }
    end,
    set_blind = function()
        -- Allows the background to ease in first before drawing cards.
        q(function()
            local count = (#G.deck.cards - 2) / 2

            for i = 0, count do
                local card = G.deck.cards[#G.deck.cards - i]
                draw_card(G.deck, G.hand, i / count * 100, "down", false, card, nil, nil, true)
            end

            for i = 0, count do
                local card = G.deck.cards[#G.deck.cards - i]
                draw_card(G.hand, G.discard, i / count * 100, "down", false, card, nil, nil, true)
            end
        end)
    end,
}

blind {
    key = "mitotic",
    boss = {min = 3},
    boss_colour = HEX "80b48eff",
    pronouns = "it_its",
    calculate = function(_, b, context)
        if b.disabled or not context.pre_discard then
            return
        end

        local cards_added = {}
        local count = #G.hand.highlighted

        f(G.hand.highlighted, ipairs):take(count):each(function(v, i)
            local copy = copy_card(v)
            copy:add_to_deck()
            table.insert(G.hand, copy)
            table.insert(cards_added, copy)
            table.insert(G.playing_cards, copy)
            draw_card(G.hand, G.discard, i / count * 100, "down", false, copy, nil, nil, true)
        end)

        b:wiggle()
        b.triggered = true
        playing_card_joker_effects(cards_added)
    end,
}

blind {
    key = "tranquilizer",
    boss = {min = 6},
    boss_colour = HEX "bdaeccff",
    pronouns = "they_them",
    collection_loc_vars = function(_)
        return {
            vars = {localize {
                type = "variable",
                key = "b_Roland_most_common_card",
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
    calculate = function(self, b, context)
        if not context.card_added and
            not context.drawing_cards and
            not context.playing_card_added and
            not context.pre_discard and
            not context.press_play then
            return
        end

        local needs_text_change

        ---comment
        ---@param card_area CardArea|{cards: Card[]}
        local function process(card_area)
            f(card_area.cards):each(function(v)
                local debuff = v.debuff
                v:set_debuff(self:recalc_debuff(v, false))
                needs_text_change = needs_text_change or debuff ~= v.debuff
            end)
        end

        process(G.deck)
        process(G.hand)
        process(G.discard)

        if needs_text_change then
            b:wiggle()
            b:set_text()
        end
    end,
    recalc_debuff = function(self, card)
        local id, _ = common_rank()
        local ret = not self.disabled and id == card:get_id()
        self.triggered = ret
        return ret
    end,
}

blind {
    key = "improbable",
    boss = {min = 4},
    boss_colour = HEX "009966ff",
    pronouns = "it_its",
    mult = 2,
    dollars = 5,
    defeat = disable_improbable,
    disable = disable_improbable,
    set_blind = function(_)
        G.GAME.modifiers.Roland_improbable = true
    end,
}

if cry_prob then
    local orig_cry_prob = cry_prob

    ---@diagnostic disable-next-line: lowercase-global
    function cry_prob(...)
        return G.GAME.modifiers.Roland_improbable and 0 or orig_cry_prob(...)
    end
end

function SMODS.current_mod:calculate(context)
    if context.setting_blind and G.GAME.blind.name == "bl_mp_nemesis" then
        local modifiers = G.GAME.modifiers
        modifiers.Roland_martingale_seed = (modifiers.Roland_martingale_seed or 0) + 1
    end

    local _ = type(G.calc) == "function" and G.calc(f(context):keys():string())
    local improbable, orig = G.GAME.modifiers.Roland_improbable, G.GAME.probabilities

    -- Normally unreachable since we set it to nil ourselves,
    -- but other mods may want to use this modifier.
    if improbable == false then
        disable_improbable()
        return
    end

    if not improbable or getmetatable(orig) then
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

blind {
    key = "equinox",
    boss = {min = 6},
    boss_colour = HEX "000000ff",
    pronouns = "any_all",
    defeat = function()
        G.GAME.modifiers.Roland_equinox = nil
    end,
    disable = function()
        G.GAME.modifiers.Roland_equinox = nil
    end,
    set_blind = function()
        play_sound("Roland_kick", 1, 0.7)
        G.GAME.modifiers.Roland_equinox = true
    end,
}

local function equinox()
    return G.GAME and
        G.GAME.modifiers and
        G.GAME.modifiers.Roland_equinox and
        G.STATE ~= G.STATES.GAME_OVER
end

local orig_draw = Card.draw

---@diagnostic disable-next-line: duplicate-set-field
function Card:draw(...)
    if equinox() and
        not SMODS.Mods.Roland.config.equinox_assist and
        not self.states.hover.is and
        not self.states.focus.is then
        add_to_drawhash(self)
    else
        return orig_draw(self, ...)
    end
end

local orig_draw_self = UIElement.draw_self

---@diagnostic disable-next-line: duplicate-set-field
function UIElement:draw_self(...)
    if equinox() and
        not self.config.button and
        not self.config.button_UIE then
        add_to_drawhash(self)
    else
        return orig_draw_self(self, ...)
    end
end

local venerable_visage = blind {
    key = "venerable_visage",
    boss = {showdown = true},
    boss_colour = HEX "f6f6f2ff",
    pronouns = "any_all",
    calculate = function(self, b, context)
        if b.disabled then
            return
        end

        if context.pre_discard and next(G.hand.highlighted) then
            q(function()
                b:wiggle()
                ease_discard(1)
            end)
        end

        if b.Roland_vitriol or not context.end_of_round or not next(G.deck.cards) or not next(G.hand.cards) then
            return
        end

        b.Roland_vitriol = true
        self.vitriol(b)

        q {
            trigger = "before",
            func = function()
                G.STATE = G.STATES.GAME_OVER
                G.STATE_COMPLETE = false
            end,
        }
    end,
    vitriol = function(b)
        if type(b) == "table" and type(b.wiggle) == "function" then
            b:wiggle()
        end

        local fail = G.localization.descriptions.Blind.bl_Roland_venerable_visage.fail
        local speed = 0.1

        SMODS.draw_cards(#G.deck.cards)
        play_sound("gong", 0.6)

        attention_text {
            text = pseudorandom_element(fail, pseudoseed "RolandVenerableVisage"),
            offset = {x = 0, y = -3.6},
            major = G.play,
            scale = 3,
            hold = 2,
        }

        delay(1)

        f(G.playing_cards):each(function(v)
            q {
                trigger = "before",
                delay = speed,
                func = function()
                    v:start_dissolve()
                    v:shatter()
                end,
            }
        end)

        delay(1)

        f(G.P_CARDS):each(function(v)
            q {
                delay = speed,
                func = function()
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1

                    local card = Card(
                        b and b.T.x or 0,
                        b and b.T.y or 0,
                        G.CARD_W,
                        G.CARD_H,
                        v,
                        G.P_CENTERS.m_Bakery_Curse or G.P_CENTERS.c_base,
                        {playing_card = G.playing_card}
                    )

                    table.insert(G.playing_cards, card)
                    G.deck:emplace(card)
                    play_sound "card1"
                    card:add_to_deck()
                end,
            }
        end)

        delay(1)
    end,
}

local orig_game_draw = Game.draw

---@diagnostic disable-next-line: duplicate-set-field
function Game.draw(...)
    orig_game_draw(...)
    local boss_colour = venerable_visage.boss_colour

    if type(boss_colour) == "table" then
        boss_colour[1], boss_colour[2], boss_colour[3] = hsv_to_rgb(os.clock() / 6 % 1, 0.25, 0.75)
    end
end
