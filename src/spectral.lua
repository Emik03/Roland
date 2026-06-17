local f, q, u = unpack(... or require "lib.shared")

local spectral = (function()
    local x = 0

    ---@param tbl SMODS.Consumable|{artist?: string}
    ---@return SMODS.Consumable
    return function(tbl)
        tbl.cost = 4
        tbl.set = "Spectral"
        tbl.atlas = "spectral"
        tbl.pos = {x = x, y = 0}
        tbl.artist = tbl.artist and "Roland_" .. tbl.artist or nil
        local spectral = SMODS.Consumable(tbl)
        x = x + 1

        q(function()
            Bakery_API.credit(spectral)
        end)

        return spectral
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
        return u() and #G.hand.cards > 0
    end,
    use = function(_, card, _)
        local cards = f(G.hand.cards):table()
        pseudoshuffle(cards, pseudoseed "RolandDual")

        f(cards):take(card.ability.extra.amount):each(function(v)
            local seal

            for _ = 1, 64 do
                seal = SMODS.poll_seal {guaranteed = true}

                if seal ~= "Roland_glass" then
                    break
                end
            end

            v:set_seal(seal == "Roland_glass" and "Red" or seal)
        end)
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
        return u() and not not next(G.hand.cards)
    end,
    use = function(_, card)
        q {
            trigger = "after",
            delay = 0.4,
            func = function()
                play_sound("tarot1")
                card:juice_up(0.3, 0.5)
            end,
        }

        f(G.hand.cards):each(function(v, k)
            local percent = 1.15 - (k - 0.999) / (#G.hand.cards - 0.998) * 0.3

            q {
                trigger = "after",
                delay = 0.15,
                func = function()
                    v:flip()
                    play_sound("card1", percent)
                    v:juice_up(0.3, 0.3)
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
                    play_sound("tarot2", percent, 0.6)
                    v:juice_up(0.3, 0.3)
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
        return u() and #Bakery_API.get_highlighted() == card.ability.extra.amount
    end,
    use = function(_, _, _)
        f(Bakery_API.get_highlighted()):each(function(v)
            v:set_seal "Roland_glass"
        end)
    end,
}

spectral {
    key = "void",
    pronouns = "it_its",
    artist = "aster",
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
        return #G.playing_cards > 1 and not not u()
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

        q {
            delay = 0.28,
            timer = "REAL",
            trigger = "after",
            func = void,
        }
    end,
}
