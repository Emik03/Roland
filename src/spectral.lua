local f, q, u = (... or require "lib.shared")[1], (... or require "lib.shared")[2], (... or require "lib.shared")[3]

local spectral = (function()
    local x = 0

    ---@param tbl SMODS.Consumable|{artist?: string}
    ---@return SMODS.Consumable
    return function(tbl)
        tbl.artist = tbl.artist and "Roland_" .. tbl.artist or nil
        tbl.pos = {x = x, y = 0}
        tbl.atlas = "spectral"
        tbl.set = "Spectral"
        tbl.cost = 4
        x = x + 1
        return q(SMODS.Consumable(tbl))
    end
end)()

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "spectral",
    path = "spectral.png",
}

SMODS.Sound {
    key = "void",
    path = "void.ogg",
}

spectral {
    key = "afterimage",
    pronouns = "she_they",
    artist = "aster",
    config = {extra = {amount = 2}},
    attributes = {"seal", "modify_card", "spectral"},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function()
        return next(G.hand.cards) and u()
    end,
    use = function(_, card)
        local cards = f(G.hand.cards):table()
        pseudoshuffle(cards, pseudoseed "RolandDual")

        f(cards):take(card.ability.extra.amount):each(function(v)
            local seal = SMODS.poll_seal {
                guaranteed = true,
                options = f(G.P_SEALS):keys():where(f.nq "Roland_glass"):values():table(),
            }

            q {
                delay = 0.5,
                trigger = "after",
                func = function()
                    v:set_seal(seal, nil, true)
                end,
            }
        end)
    end,
    bulk_use = function(self, card, area, copier, number)
        f(number):map(f.const(self)):each(f.call("use", card, area, copier))
    end,
}

spectral {
    key = "primal",
    pronouns = "he_him",
    artist = "aster",
    attributes = {"enhancements", "modify_card", "spectral"},
    loc_vars = function(_, info_queue)
        table.insert(info_queue, G.P_CENTERS.m_stone)
    end,
    can_use = function()
        return next(G.hand.cards) and u()
    end,
    use = function(_, card)
        q {
            trigger = "after",
            delay = 0.4,
            func = function()
                card:juice_up(0.3, 0.5)
                play_sound "tarot1"
            end,
        }

        f(G.hand.cards):each(function(v, k)
            local percent = 1.15 - (k - 0.999) / (#G.hand.cards - 0.998) * 0.3

            q {
                trigger = "after",
                delay = 0.15,
                func = function()
                    v:flip()
                    v:juice_up(0.3, 0.3)
                    play_sound("card1", percent)
                    return true
                end,
            }
        end)

        f(G.hand.cards):each(function(v)
            q(function()
                v:set_ability(G.P_CENTERS.m_stone)
            end)
        end)

        f(G.hand.cards):each(function(v, k)
            local percent = 0.85 + (k - 0.999) / (#G.hand.cards - 0.998) * 0.3

            q {
                trigger = "after",
                delay = 0.15,
                func = function()
                    v:flip()
                    v:juice_up(0.3, 0.3)
                    play_sound("tarot2", percent, 0.6)
                    return true
                end,
            }
        end)

        delay(0.5)
    end,
}

spectral {
    key = "refract",
    pronouns = "it_its",
    artist = "aster",
    config = {extra = {amount = 2}},
    attributes = {"seal", "modify_card", "spectral"},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_SEALS.Roland_glass)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, card)
        local count = #Bakery_API.get_highlighted()
        return u() and count > 0 and count <= card.ability.extra.amount
    end,
    use = function()
        f(Bakery_API.get_highlighted()):each(function(v)
            v:set_seal "Roland_glass"
        end)
    end,
}

spectral {
    key = "void",
    pronouns = "it_its",
    artist = "aster",
    hidden = true,
    soul_rate = 0.003,
    soul_set = "Spectral",
    config = {extra = {amount = 2}},
    attributes = {"destroy_card", "generation", "spectral"},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, {key = "e_negative_consumable", set = "Edition", config = {extra = 1}})
        table.insert(info_queue, G.P_CENTERS.c_cryptid)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function()
        return next(G.playing_cards) and u()
    end,
    use = function(_, card)
        local function destructible(v)
            return not v.ability or not (v.ability.eternal or v.ability.cry_absolute)
        end

        local function destroy(v)
            if v.area then
                v.area:remove_card(v)
            end

            v.rhm = false
            v:start_dissolve()
        end

        local function void()
            local cards = f(G.playing_cards):where(destructible):table()

            local function calculate_joker(v)
                v:calculate_joker {remove_playing_cards = true, removed = cards}
            end

            f(cards):each(destroy)
            f(G.jokers.cards):each(calculate_joker)

            f(card.ability.extra.amount):each(function()
                local cryptid = create_card(nil, G.consumeables, nil, nil, nil, nil, "c_cryptid", "void")
                cryptid:set_edition({negative = true}, true)
                cryptid:add_to_deck()
                G.consumeables:emplace(cryptid)
            end)
        end

        play_sound("Roland_void", 1, 0.7)
        q {delay = 0.28, timer = "REAL", trigger = "after", func = void}
    end,
}
