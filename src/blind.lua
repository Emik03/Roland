local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

local blind = (function()
    local y = 0

    ---@param tbl SMODS.Blind|{idea?: string}
    ---@return SMODS.Blind
    return function(tbl)
        tbl.idea = tbl.idea and "Roland_" .. tbl.idea or nil
        tbl.pos = {x = 0, y = y}
        tbl.atlas = "blind"
        y = y + 1
        return q(SMODS.Blind(tbl))
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

SMODS.Sound {key = "kick", path = "kick.ogg"}

local function common_rank()
    local tally, to_name = {}, {}

    f(G.playing_cards):where(SMODS.has_no_rank, false):each(function(v)
        local id = v:get_id()
        to_name[id] = v.base.value
        tally[id] = (tally[id] or 0) + 1
    end)

    local max_key = f(tally, pairs):fold({-1 / 0, -1 / 0}, function(a, v, k)
        return (v > a[1] or v == a[1] and k > a[2]) and {v, k} or a
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
    return e and next(e)
end

local function set_freeze(state)
    local function copy(x)
        return type(x) == "table" and f(x):map(copy):table() or x
    end

    ---@param card Card|{ Roland_blizzard: true|nil }
    return function(card)
        if not card.Roland_blizzard and card.edition and card.edition.Roland_frozen then
            return
        end

        local last_edition = card.Roland_blizzard
        card.Roland_blizzard = state and (copy(card.edition) or true) or nil

        q {
            delay = 0.1,
            func = function()
                local edition = state and {Roland_frozen = true} or last_edition or card.Roland_blizzard
                card:set_edition(edition ~= true and edition or nil)
            end,
        }
    end
end

local function sort_by_enhancement(v1, v2)
    return has_enhancement(v1) and not has_enhancement(v2)
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
    drawn_to_hand = function(self)
        local function force_hand()
            if is_locked() then
                return false
            end

            f(G.hand.cards):take(self.config.draw):each(function(v)
                G.hand:add_to_highlighted(v, true)
            end)

            G.FUNCS.play_cards_from_highlighted()
        end

        local g = G.GAME

        if not g.blind.disabled and not g.Roland_nimble_disabled then
            g.Roland_nimble_disabled = true
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
        G.FUNCS.draw_from_hand_to_deck()

        q(function()
            pseudoshuffle(G.deck.cards, pseudoseed "RolandFalseShuffle")
        end)
    end,
    calculate = function(_, b, context)
        local _ = not b.disabled and context.drawing_cards and table.sort(G.deck.cards, sort_by_enhancement)
    end,
    in_pool = function()
        return G.playing_cards and not not f(G.playing_cards):any(has_enhancement)
    end,
}

blind {
    key = "divide",
    boss = {min = 1},
    boss_colour = HEX "b18480ff",
    pronouns = "he_they",
    disable = function()
        -- Ensures that this runs after 'set_blind' since it also gets added to queue.
        q {delay = 0.8, trigger = "after", func = G.FUNCS.draw_from_discard_to_deck}
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

        f(G.hand.highlighted):take(count):each(function(v, i)
            local copy = copy_card(v)
            copy:add_to_deck()
            table.insert(G.hand, copy)
            table.insert(cards_added, copy)
            table.insert(G.playing_cards, copy)
            draw_card(G.hand, G.discard, i / count * 100, "down", false, copy, nil, nil, true)
        end)

        if not next(cards_added) then
            return
        end

        b:wiggle()
        b.triggered = true
        playing_card_joker_effects(cards_added)
    end,
}

blind {
    key = "blizzard",
    idea = "redstoad",
    boss = {min = 3},
    boss_colour = HEX "102a41ff",
    pronouns = "it_its",
    defeat = function(self)
        self.cards():where "Roland_blizzard":each(set_freeze())
        G.GAME.blind.disabled = true
    end,
    disable = function(self)
        self:defeat()
    end,
    calculate = function(self, b, context)
        return not b.disabled and
            context.hand_drawn and
            self.cards()
            :where("Roland_blizzard", false)
            :where("facing", "front")
            :each(set_freeze(true)) or nil
    end,
    cards = function()
        return f(G):where(getmetatable, CardArea):flatmap("cards", ipairs)
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
    disable = function()
        G.GAME.blind.disabled = true
    end,
    recalc_debuff = function(self, card)
        local id, _ = common_rank()
        local ret = not G.GAME.blind.disabled and id == card:get_id()
        self.triggered = ret
        return ret
    end,
}

blind {
    key = "improbable",
    boss = {min = 3},
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

    function cry_prob(...)
        return G.GAME.modifiers.Roland_improbable and 0 or orig_cry_prob(...)
    end
end

local function call(key, value)
    local obj = G[key .. "obj"]
    local _ = type(obj) == "function" and obj(value)

    if not G[key] or value == "Bakery_nothing" then
        return
    end

    if type(G[key]) == "function" then
        G[key] = {G[key]}
    end

    if type(G[key]) ~= "table" then
        return
    end

    local str

    local _ = f(type(value) == "table" and value or {[value] = true})
        :keys()
        :map(f.index_into(G[key]))
        :where(type, "function")
        :each(function(v)
            str = str or type(value) == "table" and f(value):keys():string() or value
            v(str)
        end)

    local _ = not str and
        type(G[key][1]) == "function" and
        G[key][1](type(value) == "table" and f(value):keys():string() or value)
end

local orig_check_for_unlock = check_for_unlock

function check_for_unlock(args, ...)
    call("lock", type(args) == "table" and args.type or args)
    return orig_check_for_unlock(args, ...)
end

function SMODS.current_mod:calculate(context)
    call("calc", context)

    local _ = context.before and
        f {"v_Roland_ceres", "v_Roland_neptune"}
        :where(f.index_into(G.GAME.used_vouchers))
        :map(f.index_into(G.P_CENTERS))
        :where("config.extra.hand_type", context.scoring_name)
        :pun "SMODS.Voucher"
        :each(function(v, _)
            SMODS.smart_level_up_hand(nil, v.config.extra.hand_type, false, v.config.extra.amount)
        end)

    local improbable, orig = G.GAME.modifiers.Roland_improbable, G.GAME.probabilities

    local _ = context.end_of_round and
        context.main_eval and
        not context.blueprint and
        G.P_TAGS.tag_Roland_invisible.increment()

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

    G.GAME.probabilities = setmetatable({}, {
        orig = orig,
        __index = function(_, k)
            return k == "normal" and 0 or orig[k]
        end,
        __newindex = function(_, k, v)
            orig[k] = (k == "normal" and v == 0) and normal or v
        end,
    })
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
    dollars = 8,
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

        if b.Roland_vitriol or
            not context.end_of_round or
            G.GAME.chips == G.GAME.blind.chips or
            not (next(G.deck.cards) or next(G.hand.cards)) then
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
        local vitriol = SMODS.Mods.Roland.config.vitriol
        local resize_to_w, resize_to_h = 320, 200
        local is_fullscreen = love.window.getFullscreen()

        if vitriol then
            love.window.setFullscreen(false)
            delay(1.5)
        end

        local function jitter()
            local x, y = love.window.getDesktopDimensions()

            return pseudorandom(pseudoseed "RolandVenerableVisageX", 0, x) - x / 2,
                pseudorandom(pseudoseed "RolandVenerableVisageY", 0, y) - y / 2
        end

        if type(b) == "table" and type(b.wiggle) == "function" then
            b:wiggle()
        end

        f(G.playing_cards):each(function(v, k)
            return v.area ~= G.hand and draw_card(v.area, G.hand, k * 100 / #G.playing_cards, "up", true, v)
        end)

        local fail = G.localization.descriptions.Blind.bl_Roland_venerable_visage.fail

        attention_text {
            text = pseudorandom_element(fail, pseudoseed "RolandVenerableVisage"),
            offset = {x = 0, y = -3.6},
            major = G.play,
            scale = 3,
            hold = 2,
        }

        f {0.15, 0.3, 0.45, 0.6}:each(function(v)
            play_sound("gong", v)
        end)

        ---@type number, number, table
        local w, h, flags = love.window.getMode()
        local len = #G.playing_cards

        if vitriol then
            love.window.setMode(resize_to_w, resize_to_h)
            love.resize(resize_to_w, resize_to_h)
        end

        local x, y = love.window.getPosition()

        f(G.playing_cards):each(function(v, i)
            q {
                trigger = "before",
                delay = 6 / len,
                func = function()
                    if vitriol then
                        local x_random, y_random = jitter()
                        love.window.setPosition(x + x_random * i / len, y + y_random * i / len)
                    end

                    v:start_dissolve()
                    v:shatter()
                    b:wiggle()
                end,
            }
        end)

        local _ = vitriol and q {
            trigger = "before",
            delay = 1.5,
            func = function()
                love.window.setPosition(x, y)
                love.window.setMode(w, h, flags)
                love.resize(w, h)
                love.window.setFullscreen(is_fullscreen)
            end,
        }

        delay(1.5)
    end,
}

local orig_game_draw = Game.draw

function Game.draw(...)
    orig_game_draw(...)
    local boss_colour = venerable_visage.boss_colour

    if type(boss_colour) == "table" then
        boss_colour[1], boss_colour[2], boss_colour[3] = hsv_to_rgb(os.clock() / 6 % 1, 0.25, 0.75)
    end
end
